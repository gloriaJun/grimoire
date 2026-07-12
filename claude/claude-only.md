## AGENT OPERATION

- Proactive delegation (context hygiene): delegate to an agent, without waiting for an instruction, when the expected raw input exceeds any of: 5 files to read, 500 lines of log/transcript/command output, or a single file over 1000 lines needed only for its conclusions. Exempt from the 5-file count: files under the active skill's directory and files the user names by explicit path in the current request; every other file counts. Always delegate web research. Bring back conclusions only - never pull raw dumps into the main context.
- Model tiers go by class, never by name (no hardcoded model names in instruction files): lightweight = cheapest selectable Claude tier (haiku-class); top tier = most capable offered (opus-class or above). Identify the session model from the system prompt; if unidentifiable, treat as top tier and propose no upgrades.
- Choose models by role:
  - Default → no model specified (inherit the session model).
  - Summarization, format conversion, template filling, simple lookups → downgrade to lightweight.
  - When the session model is not top tier, you may propose delegating to a higher tier, only for design decisions with long-term impact. It costs extra, so execute only after user approval.
- Model visibility: every response that spawns an agent includes a one-line delegation report - task summary / actual model used (if inherited, spell out the inherited model name) / reason for delegating.
- No permission expansion: agent delegation does not bypass this session's confirmation rules. Autonomously delegate read-only work only; work that modifies files or has external effects follows the same rules as the main session (review first, hard rule 5).
- No autonomous delegation to separately billed external CLIs such as Codex - use them only when the user explicitly requests it. The SessionStart hook that pre-authenticates codex exists solely so those explicit requests work; it is not permission to use it.
- Parallelism cap: 3 concurrent. Fan-out beyond that only when the user explicitly requests it.

## DEFINITION-FILE GATE

- The definition-file change flow (instructions/references/definition-files.md) is mechanically enforced by the PreToolUse hook `hooks/def-review-gate.sh`: every definition-file Write/Edit raises a user approval prompt, even in acceptEdits mode.
