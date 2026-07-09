# g-insight

Post-task mini-audit: diagnoses gaps between this session's actual work and the definitions that could have governed it, in six fixed categories, with mandatory evidence per finding.

## Features

- **Full Definition Coverage** - enumerates CLAUDE.md, instructions, skills, hooks (incl. settings hooks), agents, and recalled memory; marks what this session actually exercised
- **Six Audit Categories** - A ambiguous, B stale, C conflicting, D missing, E verbally repeated, F lightweight-model executability (PASS/WEAK per exercised skill/hook/agent)
- **Mechanical Staleness Check** - paths referenced by exercised files are verified with `test -e`
- **Evidence Gate** - verbatim quote, named tool call, or file:line per finding; unverifiable items become 미확인 notes
- **Bounded Output** - max 8 ranked findings (conflicts first) + one-line backlog; "No suggestions." when nothing qualifies
- **Read-Only Until Decision** - Apply / Defer / Skip per finding; Apply edits the source of truth and must meet the lightweight-model bar

## Usage

```
/g-insight
```

May also be invoked from another skill's completion step with task context.

## How It Works

```
/g-insight
  -> Step 1: enumerate definition layer + mark exercised + extract evidence (quotes)
  -> Step 2: diagnose A-F (mechanical checks where possible)
  -> Step 3: ranked report (max 8) -> per finding: Apply / Defer / Skip
             undecidable findings become multiple-choice questions (max 3 per batch)
```
