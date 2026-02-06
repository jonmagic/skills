---
name: session-to-brain
description: Archive a Copilot CLI session to the brain. Creates a daily project file with the session transcript and adds a resume link to the weekly note. Use when ending a significant work session to preserve context for future reference.
---

# Session to Brain

Archive Copilot CLI sessions to your brain for future reference.

## Overview

This skill captures a Copilot session and saves it to your brain in two places:

1. **Daily Projects** - A markdown file with the full session transcript
2. **Weekly Note** - A bullet with the session focus and resume command

## When to Use

- At the end of a significant work session you want to preserve
- When switching contexts and want to capture what you accomplished
- Before closing a session you might want to resume later

## Inputs

The skill needs:

1. **Session ID** - Available from the session context (look for the session folder path)
2. **Focus** - A brief description of what the session was about (1-5 words)

## Detailed Instructions

### Step 1: Gather Information

Ask the user for the **focus** (what was this session about?). The session ID is available from the session context - look for the path like `~/.copilot/session-state/UUID/`.

### Step 2: Extract Transcript

Run the transcript extraction script:

```bash
~/.copilot/skills/session-to-brain/scripts/extract-transcript \
  --session-id "SESSION_ID" \
  --output "/tmp/session-transcript.md"
```

### Step 3: Create Daily Project File

Run the daily project creation script:

```bash
~/.copilot/skills/session-to-brain/scripts/create-daily-project \
  --focus "FOCUS" \
  --session-id "SESSION_ID" \
  --transcript "/tmp/session-transcript.md"
```

This outputs the path to the created file.

### Step 4: Update Weekly Note

Run the weekly note update script with the path from step 3:

```bash
~/.copilot/skills/session-to-brain/scripts/update-weekly-note \
  --focus "FOCUS" \
  --session-id "SESSION_ID" \
  --daily-project-path "PATH_FROM_STEP_3"
```

### Step 5: Confirm Completion

Report what was created:
- The daily project file path
- The weekly note that was updated

## Scripts

All scripts are in `~/.copilot/skills/session-to-brain/scripts/`:

| Script | Purpose |
|--------|---------|
| `extract-transcript` | Parse events.jsonl into readable markdown |
| `create-daily-project` | Create numbered file in Daily Projects folder |
| `update-weekly-note` | Add wikilink + resume command to today's section |

## Example Prompts

### Archive current session

```
Archive this session to my brain. The focus was "Proxima abuse research"
```

### Quick archive

```
Save this session as "OKR pivot planning"
```
