# g-pr

Global PR creation entry point: one command, and the most specific PR
guide for the current directory wins.

## Features

- Follows the user-global PR guide (`templates/pr.md`) by default.
- Defers to any directory-scoped PR skill or workspace instruction that
  covers the current directory - no workspace names hardcoded here.
- Passes arguments through: base branch override and `--preview` mode.
- Always creates draft PRs with an explicit base branch.

## Usage

- `/g-pr` - create a draft PR against the detected base branch
- `/g-pr release/1.2.3` - create a draft PR against a specific base
- `/g-pr --preview` - write and review the body only, no submission
- `/g-pr help` - print the sub-command table

## How It Works

Pure router. If an available skill declares a PR workflow scoped to a
directory containing the cwd, it is invoked with the same arguments.
Otherwise loaded workspace instructions win over the global guide, and
the global guide handles everything else.
