/**
 * Bilingual doc viewer builder.
 *
 * Scans the markdown files of every root defined in doc-viewer.config.json,
 * pairs each file with an optional translation sidecar
 * (translations/<root>/<relpath>.json), and emits a single self-contained
 * dist/index.html: file tree on the left, original text with the Korean
 * translation interleaved below each block on the right. Files with
 * uncommitted git changes get a tree badge and a collapsible diff panel.
 *
 * Translation sidecar format (produced by a Claude session, display-only,
 * never authoritative - the English source file is the single source of truth):
 *   { "segments": [ { "src": "<markdown block>", "ko": "<korean markdown>" } ] }
 * A segment with an empty "ko" (e.g. code fences) renders the source only.
 *
 * Usage (from tools/doc-viewer):
 *   pnpm build            - emit dist/index.html
 *   pnpm build skeleton   - (re)write translation sidecars with src blocks
 *                           extracted from the current sources; existing ko
 *                           values are carried over where the src block is
 *                           unchanged, so only new/changed blocks need filling.
 */
import { spawnSync } from 'node:child_process';
import { mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, isAbsolute, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const TOOL_DIR = dirname(fileURLToPath(import.meta.url));
const TRANSLATIONS_DIR = join(TOOL_DIR, 'translations');
const DIST_DIR = join(TOOL_DIR, 'dist');

interface RootConfig {
  name: string;
  path: string;
}

interface Config {
  roots: RootConfig[];
  ignore?: string[];
}

interface Segment {
  src: string;
  ko: string;
}

interface DocFile {
  /** "<root name>/<path relative to root>", used as tree label and hash route */
  path: string;
  /** pre-rendered interleaved HTML */
  html: string;
  translated: boolean;
  stale: boolean;
  /** pre-rendered HTML of the uncommitted git diff, if any */
  diffHtml: string;
}

marked.setOptions({ gfm: true });
// Instruction files quote Korean verb patterns like "~해줘" and "~를 통해";
// GFM single-tilde strikethrough would render them struck through. Disable del.
marked.use({ tokenizer: { del: () => undefined } });

function loadConfig(): Config {
  const raw = JSON.parse(readFileSync(join(TOOL_DIR, 'doc-viewer.config.json'), 'utf8')) as Config;
  if (!Array.isArray(raw.roots) || raw.roots.length === 0) {
    throw new Error('doc-viewer.config.json: "roots" must be a non-empty array');
  }
  return raw;
}

function expandPath(p: string): string {
  const expanded = p.startsWith('~/') ? join(homedir(), p.slice(2)) : p;
  return isAbsolute(expanded) ? expanded : resolve(TOOL_DIR, expanded);
}

function walkMarkdown(dir: string, ignore: Set<string>): string[] {
  const out: string[] = [];
  for (const entry of readdirSync(dir).sort()) {
    if (ignore.has(entry)) continue;
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      out.push(...walkMarkdown(full, ignore));
    } else if (entry.endsWith('.md')) {
      out.push(full);
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// git diff collection
// ---------------------------------------------------------------------------

function git(cwd: string, args: string[], okStatuses: number[] = [0]): string | null {
  const r = spawnSync('git', args, { cwd, encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
  if (r.error || r.status === null || !okStatuses.includes(r.status)) return null;
  return r.stdout;
}

/** Map of absolute file path -> raw uncommitted diff text, for one root. */
function collectDiffs(rootPath: string): Map<string, string> {
  const diffs = new Map<string, string>();
  const top = git(rootPath, ['rev-parse', '--show-toplevel'])?.trim();
  if (!top) return diffs; // not a git repo - skip silently

  const tracked = (git(top, ['diff', 'HEAD', '--name-only']) ?? '')
    .split('\n')
    .filter(Boolean);
  for (const rel of tracked) {
    const abs = resolve(top, rel);
    const diff = git(top, ['diff', 'HEAD', '--', rel]);
    if (diff) diffs.set(abs, diff);
  }

  const untracked = (git(top, ['ls-files', '--others', '--exclude-standard']) ?? '')
    .split('\n')
    .filter(Boolean);
  for (const rel of untracked) {
    const abs = resolve(top, rel);
    // --no-index exits 1 when files differ; that is the expected case here.
    const diff = git(top, ['diff', '--no-index', '--', '/dev/null', rel], [0, 1]);
    if (diff) diffs.set(abs, diff);
  }
  return diffs;
}

function escapeHtml(text: string): string {
  return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function renderDiff(diff: string): string {
  const lines = diff.split('\n').map((line) => {
    let cls = 'ctx';
    if (line.startsWith('+++') || line.startsWith('---')) cls = 'file';
    else if (line.startsWith('@@')) cls = 'hunk';
    else if (line.startsWith('+')) cls = 'add';
    else if (line.startsWith('-')) cls = 'del';
    return `<span class="${cls}">${escapeHtml(line)}\n</span>`;
  });
  return `<details class="diff"><summary>Uncommitted changes (git diff)</summary><pre>${lines.join('')}</pre></details>`;
}

// ---------------------------------------------------------------------------
// document rendering
// ---------------------------------------------------------------------------

function loadSegments(docPath: string): Segment[] | null {
  try {
    const raw = readFileSync(join(TRANSLATIONS_DIR, `${docPath}.json`), 'utf8');
    const parsed = JSON.parse(raw) as { segments?: Segment[] };
    if (!Array.isArray(parsed.segments)) return null;
    return parsed.segments.filter((s) => typeof s.src === 'string');
  } catch {
    return null;
  }
}

/** Whitespace-insensitive equality so cosmetic reflows don't flag staleness. */
function normalize(text: string): string {
  return text.replace(/\s+/g, ' ').trim();
}

/** Split markdown into blank-line-separated blocks, keeping code fences intact. */
function splitBlocks(source: string): string[] {
  const blocks: string[] = [];
  let cur: string[] = [];
  let inFence = false;
  for (const line of source.split('\n')) {
    if (/^(```|~~~)/.test(line.trim())) inFence = !inFence;
    if (!inFence && line.trim() === '') {
      if (cur.length) {
        blocks.push(cur.join('\n'));
        cur = [];
      }
    } else {
      cur.push(line);
    }
  }
  if (cur.length) blocks.push(cur.join('\n'));
  return blocks;
}

function render(md: string): string {
  return marked.parse(md, { async: false });
}

interface ListPart {
  /** item content, dedented so nested items render as plain lists */
  text: string;
  /** original leading-space count, used to restore visual nesting */
  indent: number;
}

/**
 * Split a block at every list item at ANY nesting depth (plus an optional
 * leading prose part), so src/ko can be interleaved per item. Each item is
 * dedented for rendering and carries its original indent for CSS nesting.
 * Returns null when the block is not list-shaped.
 */
function splitListDeep(block: string): ListPart[] | null {
  const parts: Array<{ lines: string[]; indent: number }> = [];
  let cur: { lines: string[]; indent: number } | null = null;
  let sawItem = false;
  for (const line of block.split('\n')) {
    const m = line.match(/^(\s*)([-*]|\d+[.)])\s/);
    if (m) {
      if (cur) parts.push(cur);
      cur = { lines: [line], indent: m[1].length };
      sawItem = true;
    } else if (cur) {
      cur.lines.push(line); // wrapped continuation line
    } else {
      cur = { lines: [line], indent: 0 }; // leading prose before the first item
    }
  }
  if (cur) parts.push(cur);
  if (!sawItem || parts.length < 2) return null;
  return parts.map((p) => ({
    text: p.lines.map((l) => l.slice(Math.min(p.indent, l.length - l.trimStart().length))).join('\n'),
    indent: p.indent,
  }));
}

function renderSegment(s: Segment): string {
  const srcTrim = s.src.trim();
  // headings read fine in English; suppress their translation
  const isHeading = /^#{1,6}\s/.test(srcTrim) && !srcTrim.includes('\n');
  if (!s.ko.trim() || isHeading) {
    return `<section class="seg"><div class="src">${render(s.src)}</div></section>`;
  }
  const srcItems = splitListDeep(s.src);
  const koItems = splitListDeep(s.ko);
  if (srcItems && koItems && srcItems.length === koItems.length) {
    const rows = srcItems
      .map((item, i) => {
        const indent = item.indent ? ` style="margin-left:${item.indent * 9}px"` : '';
        const ko = koItems[i].text.trim()
          ? `<div class="ko"${indent}>${render(koItems[i].text)}</div>`
          : '';
        return `<div class="src"${indent}>${render(item.text)}</div>${ko}`;
      })
      .join('');
    return `<section class="seg">${rows}</section>`;
  }
  return `<section class="seg"><div class="src">${render(s.src)}</div><div class="ko">${render(s.ko)}</div></section>`;
}

function buildDoc(absPath: string, docPath: string, diff: string | undefined): DocFile {
  const source = readFileSync(absPath, 'utf8');
  const segments = loadSegments(docPath);
  const diffHtml = diff ? renderDiff(diff) : '';

  if (!segments) {
    return { path: docPath, html: render(source), translated: false, stale: false, diffHtml };
  }

  const stale = normalize(segments.map((s) => s.src).join('\n\n')) !== normalize(source);
  const html = segments.map(renderSegment).join('\n');
  return { path: docPath, html, translated: true, stale, diffHtml };
}

function writeSkeletons(entries: Array<{ abs: string; docPath: string }>): void {
  for (const { abs, docPath } of entries) {
    const blocks = splitBlocks(readFileSync(abs, 'utf8'));
    const existing = loadSegments(docPath) ?? [];
    const koBySrc = new Map(existing.map((s) => [normalize(s.src), s.ko]));
    const segments = blocks.map((src) => ({ src, ko: koBySrc.get(normalize(src)) ?? '' }));
    const out = join(TRANSLATIONS_DIR, `${docPath}.json`);
    mkdirSync(dirname(out), { recursive: true });
    writeFileSync(out, `${JSON.stringify({ segments }, null, 2)}\n`);
    const empty = segments.filter((s) => !s.ko).length;
    console.log(`${docPath}: ${segments.length} segments, ${empty} untranslated`);
  }
}

// ---------------------------------------------------------------------------
// page assembly
// ---------------------------------------------------------------------------

function buildPage(docs: DocFile[]): string {
  // <-escape so embedded JSON can never break out of the script tag.
  const data = JSON.stringify(docs).replace(/</g, '\\u003c');
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>grimoire docs - bilingual viewer</title>
<style>
  :root {
    --fg: #1f2328; --fg-soft: #6b7280; --border: #e5e7eb;
    --bg: #ffffff; --bg-side: #f8fafc; --accent: #2563eb;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; color: var(--fg); background: var(--bg);
    font: 15px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", "Apple SD Gothic Neo", sans-serif;
  }
  #app { display: flex; min-height: 100vh; }
  nav {
    width: 300px; flex: none; border-right: 1px solid var(--border);
    background: var(--bg-side); padding: 16px 12px; position: sticky; top: 0;
    height: 100vh; overflow-y: auto;
  }
  nav h1 { font-size: 13px; text-transform: uppercase; letter-spacing: .06em; color: var(--fg-soft); margin: 4px 8px 12px; }
  nav ul { list-style: none; margin: 0; padding-left: 14px; }
  nav > div > ul { padding-left: 0; }
  nav summary.dir {
    font-weight: 600; font-size: 13px; color: var(--fg-soft);
    padding: 4px 8px; cursor: pointer; user-select: none; border-radius: 6px;
  }
  nav summary.dir:hover { background: #eef2f7; }
  nav a {
    display: block; padding: 4px 8px; border-radius: 6px;
    color: var(--fg); text-decoration: none; font-size: 14px;
  }
  nav a:hover { background: #eef2f7; }
  nav a.changed { color: #b45309; }
  nav a.active { background: var(--accent); color: #fff; }
  nav a .badge { font-size: 11px; color: var(--fg-soft); margin-left: 4px; }
  nav a.active .badge { color: #dbeafe; }
  main { flex: 1; min-width: 0; padding: 32px 48px 96px; max-width: 900px; }
  .notice {
    border: 1px solid #fde68a; background: #fffbeb; color: #92400e;
    border-radius: 8px; padding: 8px 14px; font-size: 13px; margin-bottom: 20px;
  }
  details.diff { margin-bottom: 20px; border: 1px solid var(--border); border-radius: 8px; }
  details.diff summary {
    cursor: pointer; padding: 8px 14px; font-size: 13px; font-weight: 600; color: #b45309;
  }
  details.diff pre {
    margin: 0; padding: 12px 16px; font-size: 12.5px; line-height: 1.5;
    white-space: pre-wrap; overflow-wrap: anywhere;
    max-height: 380px; overflow-y: auto;
    background: #fafafa; border-top: 1px solid var(--border);
    border-radius: 0 0 8px 8px;
  }
  details.diff .add { color: #16803c; background: #f0fdf4; display: block; }
  details.diff .del { color: #b91c1c; background: #fef2f2; display: block; }
  details.diff .hunk { color: #2563eb; }
  details.diff .file { color: var(--fg-soft); font-weight: 600; }
  .seg { margin-bottom: 4px; }
  .seg .src > ul, .seg .src > ol { margin: 2px 0; }
  .ko { color: var(--fg-soft); padding-left: 14px; border-left: 3px solid var(--border); margin: 2px 0 14px; }
  .ko > * { margin-top: 4px; margin-bottom: 4px; }
  .ko ul, .ko ol { list-style: none; padding-left: 4px; }
  main h1, main h2, main h3 { line-height: 1.3; }
  main pre { background: #f6f8fa; padding: 12px 16px; border-radius: 8px; overflow-x: auto; font-size: 13px; }
  main code { background: #f6f8fa; padding: 1px 5px; border-radius: 4px; font-size: 13px; }
  main pre code { background: none; padding: 0; }
  main table { border-collapse: collapse; }
  main th, main td { border: 1px solid var(--border); padding: 5px 10px; }
  main blockquote { border-left: 3px solid var(--border); margin-left: 0; padding-left: 14px; color: var(--fg-soft); }
</style>
</head>
<body>
<div id="app">
  <nav><h1>grimoire docs</h1><div id="tree"></div></nav>
  <main id="content"></main>
</div>
<script>
const DOCS = ${data};
const byPath = new Map(DOCS.map(d => [d.path, d]));

function buildTree() {
  const root = {};
  for (const d of DOCS) {
    let node = root;
    const parts = d.path.split('/');
    parts.forEach((part, i) => {
      if (i === parts.length - 1) (node.files ||= []).push(d);
      else node = (node.dirs ||= {})[part] ||= {};
    });
  }
  return root;
}

function renderTree(node, depth = 0) {
  const ul = document.createElement('ul');
  for (const [name, child] of Object.entries(node.dirs || {})) {
    const li = document.createElement('li');
    const det = document.createElement('details');
    det.open = depth === 0; // roots expanded, subdirs collapsed
    const sum = document.createElement('summary');
    sum.className = 'dir';
    sum.textContent = name + '/';
    det.append(sum, renderTree(child, depth + 1));
    li.append(det);
    ul.append(li);
  }
  for (const doc of node.files || []) {
    const li = document.createElement('li');
    const a = document.createElement('a');
    a.href = '#' + encodeURIComponent(doc.path);
    a.dataset.path = doc.path;
    a.textContent = doc.path.split('/').pop();
    if (doc.diffHtml) { a.classList.add('changed'); a.title = 'uncommitted changes'; }
    if (!doc.translated) a.innerHTML += ' <span class="badge">EN</span>';
    li.append(a);
    ul.append(li);
  }
  return ul;
}

function show(path) {
  const doc = byPath.get(path) || DOCS[0];
  if (!doc) return;
  let banner = '';
  if (!doc.translated) banner = '<div class="notice">No Korean translation generated yet - showing source only.</div>';
  else if (doc.stale) banner = '<div class="notice">Source changed after this translation was generated - Korean text may be stale.</div>';
  document.getElementById('content').innerHTML = banner + doc.diffHtml + doc.html;
  document.querySelectorAll('nav a').forEach(a =>
    a.classList.toggle('active', a.dataset.path === doc.path));
  // expand the tree path to the active file
  const active = document.querySelector('nav a.active');
  for (let el = active && active.parentElement; el && el.tagName !== 'NAV'; el = el.parentElement) {
    if (el.tagName === 'DETAILS') el.open = true;
  }
  window.scrollTo(0, 0);
}

document.getElementById('tree').append(renderTree(buildTree()));
window.addEventListener('hashchange', () =>
  show(decodeURIComponent(location.hash.slice(1))));
show(decodeURIComponent(location.hash.slice(1)) || (DOCS[0] && DOCS[0].path));
</script>
</body>
</html>
`;
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

const config = loadConfig();
const ignore = new Set(config.ignore ?? ['node_modules', '.git', 'dist']);

const entries: Array<{ abs: string; docPath: string; rootPath: string }> = [];
for (const root of config.roots) {
  const rootPath = expandPath(root.path);
  try {
    statSync(rootPath);
  } catch {
    console.warn(`skip root "${root.name}": ${rootPath} not found`);
    continue;
  }
  for (const abs of walkMarkdown(rootPath, ignore)) {
    entries.push({ abs, docPath: `${root.name}/${relative(rootPath, abs)}`, rootPath });
  }
}

if (process.argv[2] === 'skeleton') {
  // optional root-name filter: pnpm build skeleton grimoire
  const only = process.argv[3];
  writeSkeletons(only ? entries.filter((e) => e.docPath.startsWith(`${only}/`)) : entries);
} else {
  const diffsByRoot = new Map<string, Map<string, string>>();
  for (const root of config.roots) {
    const rootPath = expandPath(root.path);
    if (!diffsByRoot.has(rootPath)) diffsByRoot.set(rootPath, collectDiffs(rootPath));
  }

  const docs = entries.map(({ abs, docPath, rootPath }) =>
    buildDoc(abs, docPath, diffsByRoot.get(rootPath)?.get(abs)),
  );
  mkdirSync(DIST_DIR, { recursive: true });
  writeFileSync(join(DIST_DIR, 'index.html'), buildPage(docs));

  const translated = docs.filter((d) => d.translated).length;
  const changed = docs.filter((d) => d.diffHtml).length;
  const stale = docs.filter((d) => d.stale).map((d) => d.path);
  console.log(
    `built dist/index.html: ${docs.length} files, ${translated} translated, ${changed} with uncommitted changes`,
  );
  if (stale.length) console.log(`stale translations: ${stale.join(', ')}`);
}
