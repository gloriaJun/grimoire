# Error Analysis Mode

Guide for analyzing errors when structured logs or stack traces are available.
This mode assumes the error has already manifested — the goal is to trace it
back to its root cause in the codebase.

## Analysis Flow

```
Error log/trace → Parse structure → Extract exception chain
→ Locate throw site → Trace call chain upward → Identify root cause
→ Verify cause explains all symptoms
```

## Parsing by Source

### Sentry Event

Key fields to extract:
- `exception.values[]` — exception type, value, and stacktrace
- `exception.values[].stacktrace.frames[]` — file, function, line (bottom frame = throw site)
- `breadcrumbs.values[]` — chronological trail of events before the error
- `tags` — environment, release, transaction name
- `contexts` — OS, browser, device, runtime info

**Pattern**: Read frames bottom-to-top. The lowest frame in application code
(not library/framework) is usually the throw site. Breadcrumbs reveal what
the user or system was doing before the error.

### OpenSearch / Elasticsearch Log

Key fields to extract:
- `@timestamp` — when the error occurred
- `level` — ERROR, WARN, FATAL
- `message` — the log message
- `stack_trace` or `error.stack` — if present, parse as local stack trace
- `trace_id` / `span_id` — for correlating across services
- `service.name` — which service produced the log

**Pattern**: Use trace_id to find related logs across services. Sort by
timestamp to reconstruct the sequence of events. Look for the earliest
ERROR entry — downstream errors are often symptoms, not causes.

### Local Stack Trace

**Node.js / JavaScript**:
- Read top-to-bottom: first line is the error, subsequent lines are the call stack
- `at functionName (file:line:column)` format
- Filter out `node_modules/` frames to focus on application code

**Python**:
- Read bottom-to-top: last line is the error, traceback above shows the call chain
- `File "path", line N, in function_name` format
- Chained exceptions (`During handling of...`, `The above exception...`) indicate error chains

**Browser Console**:
- `Uncaught TypeError: ...` — unhandled exception
- Source map references (`webpack:///src/...`) point to original source
- Network errors (`Failed to fetch`, `ERR_CONNECTION_REFUSED`) indicate backend issues

## Code Tracing Pattern

Once the throw site is identified:

1. **Read the throw site** — understand what condition caused the error
2. **Trace the data** — where did the problematic value come from? Follow it
   backward through function parameters, API responses, database queries
3. **Find the contract violation** — where did reality diverge from the code's
   assumption? This is the root cause
4. **Verify completeness** — does this cause explain ALL observed symptoms?
   If not, there may be multiple contributing factors

## Common Error Patterns

| Error type | Typical root cause | Where to look |
|-----------|-------------------|---------------|
| TypeError / null reference | Missing null check, unexpected API response shape | Data flow from API/DB to usage site |
| NetworkError / timeout | Backend down, DNS issue, CORS misconfiguration | Network layer, proxy config, API gateway |
| SyntaxError / parse error | Malformed JSON/XML, encoding issues | Data serialization/deserialization boundary |
| Permission / auth error | Expired token, missing scope, role misconfiguration | Auth middleware, token refresh logic |
| Race condition | Async operations completing in unexpected order | Promise chains, concurrent state mutations |
| Memory / resource leak | Unclosed connections, uncleared intervals, growing caches | Lifecycle hooks, cleanup functions |
