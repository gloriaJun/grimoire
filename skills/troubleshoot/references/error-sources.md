# Error Source Format Reference

Quick reference for recognizing and parsing common error source formats.
Used by Step 0 (Triage) to identify the error source type.

## Sentry JSON Event

**Recognition**: JSON object containing `event_id`, `exception`, or `breadcrumbs` keys.

**Key structure**:
```json
{
  "event_id": "abc123...",
  "timestamp": "2024-01-15T10:30:00Z",
  "platform": "javascript",
  "exception": {
    "values": [
      {
        "type": "TypeError",
        "value": "Cannot read properties of null",
        "stacktrace": {
          "frames": [
            { "filename": "app://src/api/user.ts", "function": "fetchUser", "lineno": 42 }
          ]
        }
      }
    ]
  },
  "breadcrumbs": {
    "values": [
      { "category": "navigation", "message": "/dashboard → /profile", "timestamp": "..." },
      { "category": "xhr", "data": { "url": "/api/user/123", "status_code": 200 }, "timestamp": "..." }
    ]
  },
  "tags": { "environment": "production", "release": "v2.3.1" },
  "contexts": { "browser": { "name": "Chrome", "version": "120.0" } }
}
```

**Note**: Frames are ordered bottom-to-top — the last frame in `values[0].stacktrace.frames`
is the throw site.

## OpenSearch / Elasticsearch Log

**Recognition**: JSON with `@timestamp`, `level`, and `message` fields. Often includes
`trace_id` for distributed tracing.

**Key structure**:
```json
{
  "@timestamp": "2024-01-15T10:30:00.123Z",
  "level": "ERROR",
  "logger_name": "com.example.api.UserService",
  "message": "Failed to fetch user profile",
  "stack_trace": "java.lang.NullPointerException: ...\n\tat com.example.api.UserService.getProfile(UserService.java:87)\n\t...",
  "trace_id": "abc123def456",
  "span_id": "789ghi",
  "service": { "name": "user-service", "version": "1.2.0" }
}
```

## Browser Console Error

**Recognition**: Starts with `Uncaught`, `TypeError`, `ReferenceError`, or similar.
May include webpack/source-map references.

**Formats**:
```
Uncaught TypeError: Cannot read properties of undefined (reading 'map')
    at UserList (webpack:///src/components/UserList.tsx:23:15)
    at renderWithHooks (react-dom.development.js:14985:18)
    at mountIndeterminateComponent (react-dom.development.js:17811:13)
```

```
Failed to load resource: the server responded with a status of 500 ()
POST https://api.example.com/graphql 500 (Internal Server Error)
```

## Node.js Stack Trace

**Recognition**: `Error:` or error type name followed by `at` lines.
Read top-to-bottom (first `at` line = throw site).

**Format**:
```
Error: ENOENT: no such file or directory, open '/app/config/settings.json'
    at Object.openSync (node:fs:603:3)
    at Object.readFileSync (node:fs:471:35)
    at loadConfig (/app/src/config/loader.ts:15:22)
    at bootstrap (/app/src/index.ts:8:3)
```

## Python Traceback

**Recognition**: Starts with `Traceback (most recent call last):`.
Read bottom-to-top (last line = error, preceding lines = call chain).

**Format**:
```
Traceback (most recent call last):
  File "/app/api/views.py", line 45, in get_user
    profile = user_service.get_profile(user_id)
  File "/app/services/user.py", line 23, in get_profile
    return self.db.query(User).filter_by(id=user_id).one()
sqlalchemy.orm.exc.NoResultFound: No row was found when one was required
```

**Chained exceptions**:
```
During handling of the above exception, another exception occurred:
```
This indicates the original exception was caught and re-raised or a new
exception was raised during error handling.
