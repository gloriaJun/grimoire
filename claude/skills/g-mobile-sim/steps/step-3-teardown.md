# Step 3: Teardown

## When to run

- The mobile check is done -> ask once whether to shut the device down now.
- Approved -> run the default command below.
- Deferred -> leave it booted, and name both `/g-mobile-sim down` and the state
  file path `${TMPDIR:-/tmp}/g-mobile-sim-state.tsv` so it can be found in a
  later session.
- Entered directly through `/g-mobile-sim down` -> run immediately, no question.

## Default run

```bash
scripts/teardown.sh
```

| Output | Meaning | Action |
|---|---|---|
| `DOWN_OK` | device is down | report the name |
| `PRUNED` | already gone, row dropped | mention only if the user asked about that device |
| `DOWN_FAIL` | still alive after 8 s, row kept | report the name and that rerunning `down` is the next step; do not loop |
| `KEPT_EXTERNAL` | running but not owned | list the ids and say they were left running |
| `NOTHING_TO_DO` | no owned device recorded | say nothing was owned; `KEPT_EXTERNAL` lines can still appear above it |
| `TEARDOWN_ERROR` | the script could not run, no device was touched | report the reason field; the state file is unchanged, so rerunning `down` is safe |

## down --all

This shuts down devices the skill does not own, so it needs an approval gate.

1. Run `scripts/list-devices.sh` and collect every row whose state column is
   `booted` (the column is lowercase for both platforms).
2. Show that list and ask for explicit approval to shut all of them down.
3. Only after approval run `scripts/teardown.sh --all`. It prints
   `DOWN_ALL ios_booted=<n> android_booted=<n>`; both counts must be 0. A
   non-zero count means a device refused to stop: report it, do not loop.

Approval refused -> run the default `scripts/teardown.sh` instead.
