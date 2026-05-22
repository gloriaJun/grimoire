# Breakdown (Deprecated)

> **This step has been removed.** Feature decomposition is now part of the `design` step.
>
> Features are defined as a checklist in `architecture.md` (see `steps/design.md`).
> Individual `feature-NN-*.md` spec files are no longer pre-generated.
> Each feature is designed just-in-time via mini-design at the start of its build session.

If you arrived here from a legacy task with `currentStep: "breakdown"`:
1. Migrate the task to a memory file (see `schemas/state.md` Migration section)
2. Set `current-step` to `"build"` (design is considered complete)
3. Continue with `/dev build`
