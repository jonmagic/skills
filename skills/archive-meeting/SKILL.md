---
name: archive-meeting
description: Archive one or more meetings into the brain repo by importing Zoom transcript folders (~/Documents/Zoom/*) and/or downloaded Teams .vtt files (~/Downloads/*.vtt), then generating a transcript markdown file, an executive summary, and creating meeting notes. Use when the user says "archive meeting", "archive my last meeting", "process these transcripts", or similar.
---

# Archive Meeting

## Overview

Turn "there's a transcript somewhere" into structured, linked artifacts in the brain repo:

- `Transcripts/YYYY-MM-DD/NN.md` (imported transcript with frontmatter)
- `Executive Summaries/YYYY-MM-DD/NN.md` (generated summary with frontmatter)
- `Meeting Notes/<target>/YYYY-MM-DD/NN.md` (meeting notes with links and detailed notes)
- `Weekly Notes/Week of YYYY-MM-DD.md` checkbox for the meeting marked as complete (if found)
- Pending `{{Meeting Notes/<target>}}` placeholders replaced with wikilinks

## Agent Responsibilities

The agent's job is simple: **call the CLI**. Everything else is handled automatically.

For interactive mode (recommended), just run:
```bash
archive-meeting \
    --brain-dir ~/code/jonmagic/Brain \
    --executive-summary-prompt-path ~/code/jonmagic/prompts/summarize/zoom-transcript-executive-summary.md \
    --detailed-notes-prompt-path ~/code/jonmagic/prompts/summarize/transcript-meeting-notes.md
```

The CLI will use fzf to:
1. Select from recent meetings (Zoom folders + Teams VTTs)
2. Select from pending meeting note targets in weekly notes

## Explicit Mode

If the user specifies the input and target:

```bash
archive-meeting \
    --brain-dir ~/code/jonmagic/Brain \
    --input "/path/to/transcript.vtt" \
    --meeting-notes-target "jonmagic" \
    --executive-summary-prompt-path ~/code/jonmagic/prompts/summarize/zoom-transcript-executive-summary.md \
    --detailed-notes-prompt-path ~/code/jonmagic/prompts/summarize/transcript-meeting-notes.md
```

## CLI Options

| Option | Required | Description |
|--------|----------|-------------|
| `--brain-dir` | Yes | Path to Brain directory |
| `--input` | No | Path to input (VTT file or Zoom folder). If omitted, uses fzf selection |
| `--meeting-notes-target` | No | Meeting Notes target basename (e.g., "jonmagic"). If omitted, uses fzf selection |
| `--executive-summary-prompt-path` | Yes | Path to prompt file for executive summary |
| `--detailed-notes-prompt-path` | Yes | Path to prompt file for detailed notes |
| `--date` | No | Override meeting date (YYYY-MM-DD). Defaults to file mtime |
| `--dry-run` | No | Show what would be done without writing files |

## Batch Workflow

For multiple meetings, call the CLI once per meeting with explicit arguments.

## Prerequisites

The `archive-meeting` CLI from `~/code/jonmagic/scripts` must be on PATH.

To verify:
```bash
which archive-meeting
archive-meeting --help
```

If not available:
```bash
cd ~/code/jonmagic/scripts && bun install
# Ensure ~/code/jonmagic/scripts/bin is on PATH
```

## References

- `references/formats.md` — Zoom folder conventions and Teams VTT quirks
- `references/meeting_notes_routing.yml` — manual overrides/aliases for Meeting Notes routing
- `assets/transcript-meeting-notes.prompt.md` — prompt template for meeting notes (legacy)
- `assets/zoom-transcript-executive-summary.prompt.md` — prompt template for executive summary (legacy)
