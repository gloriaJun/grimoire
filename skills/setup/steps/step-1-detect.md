# Step 1: Detect Existing Config

Scan the project root for existing lint, formatter, type-check, and Husky configuration.
Never assume — always read the filesystem first.

---

## Detection Targets

Run the following checks from the current working directory:

### ESLint

Check in this order:

| File pattern | Result |
|-------------|--------|
| `eslint.config.{js,mjs,cjs,ts}` | `v9-flat` — present |
| `.eslintrc`, `.eslintrc.{js,cjs,json,yml,yaml}` | `legacy` — migration recommended |
| `"eslintConfig"` key in `package.json` | `legacy` — migration recommended |
| None of the above | `missing` |

> If both v9 flat config and legacy config exist, report `v9-flat` and note that the legacy file should be removed.

### Prettier

| File pattern | Result |
|-------------|--------|
| `.prettierrc`, `.prettierrc.{js,cjs,json,yml,yaml,ts}` | `present` |
| `prettier.config.{js,cjs,ts}` | `present` |
| `"prettier"` key in `package.json` | `present` |
| None of the above | `missing` |

### TypeScript

Check two things independently:

1. `tsconfig.json` exists → `present` / `missing`
2. `package.json` has a script whose value contains `tsc --noEmit` → `script: present` / `script: missing`

### Husky

| File pattern | Result |
|-------------|--------|
| `.husky/` directory exists | `present` |
| `"prepare"` script in `package.json` contains `"husky"` | `present` |
| Neither | `missing` |

---

## Output Format

Print a detection summary table:

```
Setup Detection Results
──────────────────────
ESLint     : <status>
Prettier   : <status>
TypeScript : <status>  (tsconfig: <present|missing>, tsc script: <present|missing>)
Husky      : <status>

Items requiring setup : <comma-separated list, or "none">
Items already configured : <comma-separated list, or "none">
```

Examples:

```
ESLint     : legacy (.eslintrc.js) → migration recommended
Prettier   : present (prettier.config.ts)
TypeScript : present (tsconfig.json, no typecheck script)
Husky      : missing

Items requiring setup : ESLint migration, TypeScript tsc script, Husky
Items already configured : Prettier
```

```
ESLint     : missing
Prettier   : missing
TypeScript : missing (no tsconfig.json, no tsc script)
Husky      : missing

Items requiring setup : ESLint, Prettier, TypeScript, Husky
Items already configured : none
```

---

## Routing After Detection

**All items already configured:**
```
✅ All tools are already configured. Nothing to set up.

Run /dev setup again if you want to reconfigure a specific tool.
```
→ Stop here. Do not proceed to Step 2.

**Any item missing or legacy:**
→ Proceed to Step 2 (configure only the missing/legacy items).
Pass the detection result so Step 2 knows which tools to set up.

---

## Legacy ESLint Handling

When `legacy` ESLint is detected, present a choice before proceeding:

```
Legacy ESLint config detected: <filename>
ESLint v9 introduced flat config (eslint.config.*) which is now the standard.

Options:
  1. Migrate to v9 flat config (eslint.config.ts)  ← recommended
  2. Keep existing config, skip ESLint setup
  3. Skip ESLint setup entirely

> Enter number
```

- Option 1 → Step 2 will generate `eslint.config.ts` and offer to delete the legacy file.
- Option 2 → Read existing command from `package.json["scripts"]["lint"]`; register as `lintConfig.eslint.command`. Skip ESLint in Step 2.
- Option 3 → Skip ESLint entirely. Skip ESLint in Step 2.
