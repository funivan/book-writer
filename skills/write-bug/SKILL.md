---
name: write-bug
description: Create a structured bug report from a user description, saving it as a markdown file with reproduction steps, expected/actual behavior, and environment details.
---

# Write Bug Report

Create a well-structured bug report from a user's description of an issue, saving it as a markdown file.

## When to use

- Reporting a bug found during story generation or conversion
- Documenting an issue with any skill or script
- Triggered by: "write bug", "report bug", "log bug", "write-bug", "file a bug"

## Parameters

- `title` (required): short, descriptive title for the bug
- `description` (required): what went wrong — the user's account of the issue
- `output_folder` (optional): folder to save the bug report (default: `bugs/` in project root)
- `severity` (optional): `critical`, `high`, `medium`, `low` (default: `medium`)
- `related_skill` (optional): name of the skill where the bug was found (e.g. `generate-full-story`)

## Instructions

### Step 1: Gather context

1. Read the user-provided `title` and `description`.
2. If `related_skill` is provided, read the corresponding `skills/{related_skill}/SKILL.md` to understand the expected behavior.
3. Check for recent error output or logs if the user mentions a failure.

### Step 2: Build the bug report

Construct a markdown bug report with the following sections:

```markdown
# Bug: {title}

**Severity:** {severity}
**Date:** {YYYY-MM-DD}
**Related skill:** {related_skill or "N/A"}
**Status:** Open

## Description

{Clear summary of what went wrong, based on user description}

## Steps to Reproduce

1. {Step 1}
2. {Step 2}
3. ...

## Expected Behavior

{What should have happened}

## Actual Behavior

{What actually happened}

## Environment

- OS: {detected OS}
- Shell: {detected shell}
- Related tools: {any relevant tool versions, e.g. pandoc, imagemagick}

## Additional Context

{Any extra notes, logs, screenshots, or references}
```

### Step 3: Generate a unique filename

Use the script to generate a slug from the title:

```bash
scripts/slugify.sh "{title}"
```

The filename will be: `bug-{slug}-{YYYY-MM-DD}.md`

### Step 4: Save the report

1. Ensure the output folder exists (default: `bugs/`).
2. Save the report as `{output_folder}/bug-{slug}-{date}.md`.
3. Confirm the file path to the user.

### Step 5: Summary

Report back to the user:
- File path of the saved bug report
- Bug title and severity
- Suggest next steps (e.g., "You can edit the report or open a GitHub issue from it")

## Example

```
User: write bug --title "EPUB missing chapters" --description "When converting with prefix s, chapters s10-s12 are skipped" --related_skill convert-md-to-epub --severity high

Agent:
1. Reads convert-md-to-epub/SKILL.md for context
2. Generates slug: epub-missing-chapters
3. Creates bugs/bug-epub-missing-chapters-2026-04-12.md
4. Reports: "Bug report saved to bugs/bug-epub-missing-chapters-2026-04-12.md (severity: high)"
```

## Important Notes

- Always ask the user to confirm reproduction steps if they seem ambiguous
- Include tool versions in the environment section when the bug relates to external dependencies
- If the bug is `critical` severity, suggest the user also opens a GitHub issue immediately
- Do not overwrite existing bug reports — always generate a unique filename with the date
