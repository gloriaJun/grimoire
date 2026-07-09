# Step 2: Diagnose (six fixed categories)

Cross-check Step 1 evidence against the exercised definitions. Every finding
needs one evidence line: file:line or a conversation quote. What cannot be
verified is marked `미확인` with how to verify it.

| Cat | Name | Test |
|---|---|---|
| A | ambiguous | a rule in an exercised definition readable two ways: procedure-less verb, undefined term, numberless criterion |
| B | stale | a reference to something that no longer exists (run the mechanical check below); includes a recalled memory contradicted by this session |
| C | conflict | two definitions gave incompatible directions this session, or a definition contradicts the actual file structure |
| D | missing | a situation this session that no definition covered (from evidence list C) |
| E | verbal repetition | the user hand-instructed the same thing 2+ times and no definition covers it. A repeated instruction that also fits D counts as E only |
| F | lightweight-model executability | per exercised skill/hook/agent, excluding g-insight itself: PASS or WEAK on all three - (a) exact commands written, (b) every comparative criterion (more, large, enough, recent) carries a number, (c) termination conditions for empty result and error. WEAK requires quoting the failing line |

## B mechanical check

Set EXERCISED to the Step 1 exercised file paths (space-separated), then run:

```bash
EXERCISED="<paste the exercised file paths here>"
for f in $EXERCISED; do
  grep -oE '(~|\$HOME)/[A-Za-z0-9._/-]+' "$f" | sort -u | while read -r p; do
    p="${p%.}"
    e="${p/#\~/$HOME}"; e="${e/#\$HOME/$HOME}"
    [ -e "$e" ] || echo "MISSING $p (referenced in $f)"
  done
done
```

Each MISSING line is a B finding. Grep finding nothing = pass, not an error.
Known limit: the pattern stops at glob characters, so a reference like
`projects/*/memory/` is verified only up to `projects/`. Stale glob
references are outside this check; verify one manually only when a finding
depends on it.

## Scope bounds

- A and F apply only to artifacts exercised this session or directly named by
  a Step 1 evidence entry (unexercised files: out of scope per SKILL.md).
- Findings may target ANY definition artifact (instructions, skills, hooks,
  agents, memory) when the evidence points there.

## Termination

Zero findings across A-F: output exactly `No suggestions.` and end.
Otherwise load `steps/step-3-decide.md`.
