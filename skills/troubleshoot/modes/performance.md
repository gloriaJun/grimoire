# Performance Analysis Mode

> This mode is planned for future implementation.

When this mode is detected at triage, inform the user:

```
Performance analysis mode is currently in development.

In the meantime, here are recommended approaches:
1. Browser DevTools Performance tab — record and analyze runtime
2. Lighthouse audit — for web performance metrics
3. Node.js --inspect + Chrome DevTools — for server-side profiling
4. Database query analysis — EXPLAIN ANALYZE for slow queries

I can still help analyze specific performance issues if you share
profiling results, slow query logs, or Lighthouse reports.
```

If the user provides profiling data, proceed with error-analysis mode
using the profiling output as the "error log" input.
