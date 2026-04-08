# Step 0: Triage — Information Gathering + Mode Detection

Goal: Collect enough context to determine the troubleshooting mode and locate
relevant code before deep analysis begins.

## 0a. Check Existing Context

Scan the current conversation for:
- Error logs, stack traces, or exception messages
- Sentry alert links or JSON payloads
- OpenSearch/Elasticsearch log entries
- Screenshots of error screens
- User descriptions of unexpected behavior or performance issues

If sufficient context exists, skip to 0c.

## 0b. Request Missing Information

If the conversation lacks actionable error context, ask the user:

```
What information do you have about the issue?

1. Error log or stack trace (paste or file path)
2. Sentry alert (link or event JSON)
3. OpenSearch log (query or entry)
4. Symptom description (what's happening vs what's expected)
```

Accept any combination. The more context, the better the analysis.

## 0c. Detect Error Source

Match the provided information against known formats.
Read `references/error-sources.md` for format recognition patterns.

| Pattern | Source |
|---------|--------|
| `"event_id"`, `"exception"`, `"breadcrumbs"` keys | Sentry JSON |
| `@timestamp`, `level`, `message` with trace_id | OpenSearch log |
| File path + line number in stack frames | Local stack trace |
| Browser console format (`Uncaught TypeError: ...`) | Browser error |
| No structured log, user describes behavior | Symptom only |

## 0d. Auto-Detect Mode

Based on the collected information:

| Signal | Mode | Load file |
|--------|------|-----------|
| Error message, exception, or stack trace present | **error-analysis** | modes/error-analysis.md |
| No clear error, unexpected behavior described | **debug** | modes/debug.md |
| Keywords: slow, timeout, high memory, latency, CPU | **performance** | modes/performance.md |

Present the detected mode to the user and allow override:

```
Detected mode: <mode>
Reason: <why this mode was selected>

Proceed with this mode, or choose a different one?
1. error-analysis — Analyze from error logs
2. debug — Hypothesis-driven investigation
3. performance — Bottleneck analysis
```

## 0e. Dispatch Explore Agent (Parallel)

While waiting for user confirmation, dispatch an Explore agent to search the codebase:

**Extract search keywords from error context:**
- Class names, function names, file paths from stack traces
- Error message strings (for Grep)
- Module or package names mentioned in logs

**Agent prompt template:**
```
Search the codebase for code related to this error:
- Error: <error message or key phrase>
- Keywords: <extracted class/function/file names>
- Find: related source files, recent changes (git log), similar error patterns
- Report: file paths, relevant code sections, recent commits touching these files
```

Use `subagent_type: Explore` with `model: sonnet`.

## 0f. Merge and Summarize

Combine user-provided context with Explore agent results:

```
## Triage Summary
- **Error source**: <Sentry / OpenSearch / Local / Symptom>
- **Mode**: <error-analysis / debug / performance>
- **Key error**: <primary error message or symptom>
- **Related files**: <list from Explore agent>
- **Recent changes**: <relevant commits if found>
```

**Confirm with user before proceeding to Step 1.**
