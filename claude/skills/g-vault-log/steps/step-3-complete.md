# Step 3: Project completion

Target project from args (`complete <domain>/<slug>`) or mode detection.
Read the formal doc and check `$VAULT/projects/<domain>/assets/<slug>/`
existence first.

## A. Archive proposal

1. Compute the target: `$VAULT/archive/<domain>/<year>/<slug>.md`, year =
   `date +%Y`. Target already exists -> report the collision and stop;
   never overwrite an archive entry.
2. Ask for the record URL (PR or release link) once. Provided -> set
   frontmatter `url:` at move time; none -> omit the key (it is only ever
   written at archive time, per the vault's RULE.md).
3. Present the move plan (doc -> target, plus section B) and execute ONLY
   after the user confirms: `mkdir -p` the year directory, then `mv`.

## B. Assets disposition (g-dev projects)

Assets folder present -> propose exactly this, one confirmation per item:

- `architecture.md` -> move into `archive/<domain>/<year>/<slug>/` (the
  multi-file folder exception in the vault's RULE.md), so design rationale
  survives next to the archived doc
- `state.md` and `tasks/` -> delete; they are machine scaffolding and the
  formal doc's log already carries the outcomes

The user may keep everything instead: then move the whole assets folder
under the archive slug folder. Never delete anything without its per-item
confirmation.

## C. Wiki candidates

1. From the doc's decision and work-log sections, list at most 3 entries
   passing the vault RULE.md test: a concrete situation in which the user
   would reopen this knowledge, named in one line each.
2. Zero candidates -> say so and go to D.
3. For picked candidates, check for a wiki template:
   `ls "$VAULT/_system/templates/" | grep -i wiki`. Found -> draft one wiki
   note per pick from that template at the RULE.md wiki path
   (`wiki/<domain>/<topic>.md`), show the draft, write only on the user's
   approval. Not found -> tell the user distillation needs a wiki template
   first (the vault's template rule) and record the picks as one follow-up
   line in the archived doc instead.

## D. Finish

Report every executed move and deletion as `old -> new` paths, plus what
was declined and left in place. Never commit in the vault.
