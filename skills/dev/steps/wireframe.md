# Wireframe: UI Design

Goal: Produce a text mockup and design tool prompt before feature decomposition.

## Skip Condition

Skip if **either** is true:
- No UI or visual changes involved (logic-only work)
- User provides existing design assets (Figma URL, image paths, etc.)

If skipping:
1. Set `artifacts.wireframe` to `"skipped"`
2. Inform the user and proceed to Breakdown

If the user provides existing assets:
1. Register the asset path/URL in `artifacts.wireframe.design`
2. Set `artifacts.wireframe.mockup` to `null`
3. Proceed to Breakdown

## Input

- `artifacts.prd` (required)
- `artifacts.trd` (required, may be `"skipped"`)

## Process

### 1. Analyze PRD + TRD

Read both artifacts and extract:
- List of screens and pages that need design
- UI components and their relationships
- Interaction flows and state transitions
- Data display requirements

### 2. Generate Text Mockup (Primary Artifact)

Produce an ASCII/markdown wireframe for each screen:
- Layout structure and component placement
- Navigation and interaction flows
- Key UI states (empty, loading, error, filled)
- Annotations for behavior or data binding

Write to `wireframe-<task-name>.md` in the task subdirectory.

### 3. Generate Design Tool Prompt (Secondary Artifact)

Ask the user which tool they will use:
```
Which design tool will you use?
  1. Google Stitch
  2. Figma Maker
  3. Claude Design
  4. Other (describe)
```

Generate a tool-optimized prompt as a section in `wireframe-<task-name>.md`:
- **Google Stitch**: screen description + component list + style guide keywords
- **Figma Maker**: layout structure + component spec + spacing/typography hints
- **Claude Design**: visual rendering prompt with layout, color, and interaction description
- **Other**: generic design brief format

### 4. User Design Work

The user runs the generated prompt in the chosen tool.
After completing the design, the user optionally provides:
- Figma link, Google Stitch export URL, or local image paths

### 5. Register Artifacts

Accept the user's design asset reference (optional) and register in `_state.json`.

## State Update

`currentStep` ← `"breakdown"`, append `"wireframe"` to `completedSteps`
`artifacts.wireframe.mockup` ← path to `wireframe-<task-name>.md` (or `null` if skipped)
`artifacts.wireframe.design` ← URL/path (user-provided, or `null`)

If skipped entirely: `artifacts.wireframe` ← `"skipped"`

Follow update mechanics from `schemas/state.md`.

## Session Handoff

Read `steps/_handoff.md` and follow the handoff instructions.
Next sub-command: `/dev breakdown`
