---
name: catch-me-up
description: Gather daily activity (daily projects, meeting notes) and synthesize narrative summaries into weekly note day sections. Use when the user says "catch me up", "fill in my weekly note", "what happened this week", or similar.
---

# Catch Me Up

Synthesize daily activity into narrative summaries for weekly note day sections.

## Overview

This skill gathers daily projects and meeting notes for a date range, reads the relevant files, and writes first-person narrative bullet summaries into the corresponding day sections (`## Monday`, `## Tuesday`, etc.) of the weekly note.

The goal is to fill gaps: days where the user didn't write context notes get an automated summary based on their actual activity. Days that already have notes are left alone unless the user explicitly asks to augment them.

## When to Use

Use this skill when the user says:

- "catch me up"
- "fill in my weekly note"
- "what happened this week / last week / on Monday"
- "summarize my week"
- "backfill my weekly notes"

## Workflow

### Step 1: Determine the date range

- If the user specifies a week or date range, use that.
- If the user says "this week", use the current week (Sunday through today).
- If the user says "last week", use the previous full week (Sunday through Saturday).
- If the user says "catch me up" with no qualifier, default to the current week.

Identify the weekly note file: `Weekly Notes/Week of YYYY-MM-DD.md` where the date is the Sunday that starts the week.

### Step 2: Read the weekly note

Read the weekly note to understand:

1. Which day sections exist (`## Sunday`, `## Monday`, etc.)
2. Which day sections already have substantive narrative content (actual context bullets describing what happened)
3. Which day sections are empty, missing, or only contain bare wikilinks / session resume commands

**Determining if a day section "has content":** A day section counts as having substantive content only if it contains narrative bullets — sentences describing what happened, decisions made, context about the day. The following do NOT count as substantive content (and the day should still be filled in):
- Just a `-` placeholder
- Only wikilinks to daily projects (e.g., `- [[Daily Projects/2026-01-26/01 test agent sandbox]]`)
- Only session resume commands (e.g., `- opencode -s ses_...`)
- A combination of only wikilinks and session resume commands

If a day section has a mix of narrative bullets AND wikilinks/session commands, treat it as having content and skip it (unless the user asks to augment).

### Step 3: Gather activity

Run the gather-activity script to discover daily projects and meeting notes:

```bash
scripts/gather-activity --week YYYY-MM-DD --lines 100
```

The script outputs JSON with per-day breakdown. Each day includes:
- `daily_projects` — list of daily project files with title and content preview
- `meetings` — list of meeting note files with meeting name and content preview

### Step 4: Read full content for days that need summaries

For each day that has activity but lacks substantive narrative content in the weekly note:

1. Read the full content of each daily project file listed for that day
2. Read the full content of each meeting note file listed for that day
3. Skip days that already have narrative content (see Step 2 criteria), unless the user explicitly asks to augment them

If a day section already has bare wikilinks or session commands, preserve them and add narrative bullets around or below them. The narrative should provide context that the wikilinks alone don't convey.

Use the Read tool to get the full file contents — the gather-activity preview is just for triage.

### Step 5: Write summaries

For each day that needs a summary, write first-person narrative bullets under the day's heading in the weekly note. Follow these rules:

**Voice and format:**
- First person, informal, concise
- Short bullet points (one line each, occasionally two for complex items)
- Capture what was worked on, key decisions, what happened — not just a list of file titles
- Include meeting highlights: who was met with, key outcomes or decisions
- Include agent session resume commands when they appear in the daily project frontmatter (`session:` field)
- Link to daily project files with wikilinks when referencing specific artifacts: `[[Daily Projects/2026-02-02/05 threadwaste questions evidence.md]]`
- The tone should read like what the user would write at the end of a workday — quick capture of state of mind and progress

**What good summaries look like (from actual weekly notes):**

```markdown
## Monday
- rescheduled with znull to next week to talk about the abuse data plane idea
- attended team sync
- synced with romanofoti
- synced with yoodan on nuanced enforcement work and i'm working on next steps now
- need to prepare my key deliverables the past 3 months, their impact, and what i've got next
```

```markdown
## Tuesday
- started the morning by getting spamurai-next and hamzo PRs closer to shipping
- good wide ranging meeting with znull, highlights I need to interview more people
- holy shit today took an interesting turn when Steph and Jaylin reached out
```

```markdown
## Sunday
- Deep dive on the DataDome ↔ Arkose trial and correlation strategy; wrote up the recommended approach
- Did a broader "data serving / enrichment" architecture pass prompted by Dan's PR
- Captured a couple of tooling/process ideas I want to come back to
```

**What to avoid:**
- Don't just list file names or meeting names
- Don't be overly formal or use corporate language
- Don't add bold prefixes like "**Meeting:** ..." — start bullets directly with content
- Don't include content that's already in the weekly note elsewhere (TODOs, schedule, etc.)
- Don't fabricate information — only summarize what's actually in the files

### Step 6: Present the result

After writing summaries, show the user what was added. Summarize:
- Which days were filled in
- Which days were skipped (already had content)
- Which days had no activity found

Ask if they want to adjust anything.

## Options

The user can customize behavior:

- **Augment existing**: "catch me up and augment existing notes" — adds to days that already have content instead of skipping them. Append new bullets below existing ones.
- **Specific days**: "catch me up on Monday and Tuesday" — only process those days.
- **Dry run**: "show me what you'd write" — display the proposed summaries without modifying the weekly note.
- **Date range**: "catch me up for last 3 weeks" — process multiple weeks. Run gather-activity for each week and update each weekly note.

## Script Reference

### gather-activity

```
scripts/gather-activity --week 2026-01-04          # Sunday through Saturday
scripts/gather-activity --date 2026-01-05          # Single day
scripts/gather-activity --from 2026-01-05 --to 2026-01-09  # Custom range
scripts/gather-activity --week 2026-01-04 --files  # File paths only (no content)
scripts/gather-activity --week 2026-01-04 --lines 100  # More content preview
```

The `--brain` flag defaults to `~/Brain`. Override if needed.

## Important Notes

- The weekly note file must already exist. If it doesn't, suggest the user create it first using the `weekly-note` skill.
- Day section headings in the weekly note may use either format: `## Monday` or `## Monday (2026-02-09)`. Both are valid; match whichever format the existing note uses.
- Some days may have activity in daily projects but no meeting notes, or vice versa. That's normal.
- Session resume commands (e.g., `opencode -s ses_...`, `copilot --resume=...`) found in daily project frontmatter should be included as bullets so the user can easily resume those sessions.
