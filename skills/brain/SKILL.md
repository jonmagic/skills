---
name: brain
description: "Complete operating system for jonmagic's second brain — search, create, capture, commit, and maintain Brain content. Use for any Brain operation: search, daily projects, bookmarks, weekly notes, meetings, sessions, catch-ups, commits, frontmatter, and context loading."
---

# Brain

Unified skill for all operations on jonmagic's second brain repository (`~/Brain`). Covers searching, creating files, capturing content, committing changes, and loading context.

## When to Use

Use this skill when the user wants to do anything with the Brain. Common triggers:

| Intent | Example phrases |
|--------|----------------|
| Search | "search my brain", "what do I know about X", "find notes about X" |
| Context | "brain context", "load context for X", "what's the latest on X" |
| Commit | "commit brain", "push brain changes", "save my notes" |
| Daily project | "new daily project", "create a daily project note for X" |
| Bookmark | "bookmark this", "save this link", "bookmark that URL" |
| Weekly note | "new weekly note", "start the week", "create this week's note" |
| Archive meeting | "archive meeting", "archive my last meeting", "process transcripts" |
| Archive session | "archive this session", "save this session to brain" |
| Catch me up | "catch me up", "fill in my weekly note", "what happened this week" |
| Frontmatter | "add frontmatter", "generate a TID", "backfill frontmatter" |

The user may also say `/brain <anything>` as a convenience.

---

## Common Patterns

These patterns are shared across all operations. They are defined here once and referenced throughout.

### Git Sync

Before reading or writing any Brain content, sync from remote:

```bash
cd ~/Brain && git pull --rebase --autostash
```

If the pull **fails with a merge conflict**, abort and report — do NOT auto-resolve:

```bash
cd ~/Brain && git rebase --abort
```

Then tell the user about the conflict so they can resolve it manually. **Never use `-X theirs` or `-X ours`** — these strategies can silently destroy data on frequently-edited files like Weekly Notes.

If the pull fails for a non-conflict reason (network error, etc.), warn and proceed with local state.

### Frontmatter & TIDs

All new Brain markdown files require YAML frontmatter:

```yaml
---
uid: <TID>              # Required. 13-char base32-sortable timestamp ID
type: <collection>      # Required. See collection types below
created: <ISO 8601>     # Required. When the content was created
tags: []                # Optional. Controlled vocabulary (see .brain/tag-vocabulary.md)
links:                  # Optional. Structured relationships
  parent: []
  source: []
  related: []
---
```

**Collection types:** `daily.project`, `weekly.note`, `meeting.note`, `project`, `snippet`, `transcript`, `executive.summary`, `bookmark`, `archive`, `reference`

**Generate a TID:**

```bash
ruby ~/.copilot/skills/brain/scripts/generate-tid.rb
```

**Add frontmatter to an existing file:**

```bash
ruby ~/.copilot/skills/brain/scripts/add-frontmatter.rb <file>
```

Options: `--dry-run`, `--type <type>`, `--created <date>`, `--force` (adds missing fields to existing frontmatter)

**Timestamp detection:** If the path contains `YYYY-MM-DD`, that date is used for `created`. Otherwise, file mtime is used. The script is idempotent — existing frontmatter is not modified unless `--force` is passed.

**Tags:** Consult `.brain/tag-vocabulary.md` before assigning. Pick 1-4 specific tags per file. Tags span six categories: Work Projects, Technical Domains, Activities, Teams, Personal, and Meta.

### File Numbering

Many Brain directories use dated folders with sequential numbering:

```
<Directory>/YYYY-MM-DD/
  01 first topic.md
  02 second topic.md
  03 third topic.md
```

When creating files: check the folder for the highest existing number and increment. Create the date folder if it doesn't exist.

### Wikilinks

Use Obsidian-style wikilinks to connect documents:
- `[[Daily Projects/2026-02-02/05 threadwaste questions evidence.md]]`
- `[[Projects/hamzo/executive summary]]`
- `[[uid:TID|Display Text]]`

---

## Operations

### Search & Index

Search and query the Brain's structured index. Supports full-text search, tag filtering, type filtering, link traversal, timeline views, and recent file discovery.

**Build the index first** (takes ~2 seconds, produces `~/Brain/.brain/index.json`):

```bash
ruby ~/.copilot/skills/brain/scripts/brain-index.rb ~/Brain --stats
```

**Search modes:**

```bash
# Full-text search (titles, summaries, paths, tags)
ruby ~/.copilot/skills/brain/scripts/brain-search.rb "proxima abuse"

# Tag search
ruby ~/.copilot/skills/brain/scripts/brain-search.rb --tag hamzo

# Type filter (combinable with tag)
ruby ~/.copilot/skills/brain/scripts/brain-search.rb --type daily.project --tag proxima

# Timeline view (chronological evolution of a topic)
ruby ~/.copilot/skills/brain/scripts/brain-search.rb --timeline "nuanced-enforcement"

# Link traversal (find everything linking to a UID)
ruby ~/.copilot/skills/brain/scripts/brain-search.rb --linked-to 3lz7nwvh4zc2u

# Recent files (modified in last N days)
ruby ~/.copilot/skills/brain/scripts/brain-search.rb --recent 7

# Index statistics
ruby ~/.copilot/skills/brain/scripts/brain-search.rb --stats
```

**Options:** `--tag <tag>`, `--type <type>`, `--linked-to <uid>`, `--timeline <query>`, `--recent <days>`, `--limit <n>` (default: 20), `--compact` (paths only), `--index <path>`, `--stats`

---

### Context Loading

Load relevant Brain content at session start. Use when starting work on a project/topic, preparing for a meeting, or answering "what do I know about X?"

**Workflow:**

1. **Sync** — `cd ~/Brain && git pull --rebase --autostash`
2. **Rebuild index** — `ruby ~/.copilot/skills/brain/scripts/brain-index.rb ~/Brain`
3. **Search** — by keyword, tag, type, or timeline depending on what the user needs
4. **Read key files** in priority order:
   - Project executive summary (`Projects/<slug>/executive summary.md`)
   - Recent Daily Projects on the topic
   - Connected files from other time periods

**Quick context for a known project:**

```bash
ruby ~/.copilot/skills/brain/scripts/brain-index.rb ~/Brain
cat ~/Brain/Projects/<slug>/executive\ summary.md
ruby ~/.copilot/skills/brain/scripts/brain-search.rb --tag <project-tag> --type daily.project --limit 5
```

---

### Commit & Push

Analyze Brain changes, create semantic commits, and push. Non-interactive — do the best job without asking for confirmation.

**Workflow:**

1. `cd ~/Brain`
2. Sync from remote (see Common Patterns)
3. `git status` to see changes
4. Group files by type/purpose and create commits:

| Directory | Commit format |
|-----------|--------------|
| `Weekly Notes/` | `docs(weekly): ...` |
| `Daily Projects/` | `docs(daily): ...` |
| `Meeting Notes/` | `docs(meetings): ...` |
| `Snippets/` | `docs(snippets): ...` |
| `Executive Summaries/` | `docs(summaries): ...` |
| `Transcripts/` | `docs(transcripts): ...` |
| `Projects/` | `docs(projects): ...` |
| `Bookmarks/` | `docs(bookmarks): ...` |
| `Archive/` | `chore(archive): ...` |
| Skills/config | `chore: ...` |

5. `git push` after all commits
6. Report what was committed

**Safety rules:**
- Never auto-resolve merge conflicts
- Never force push
- Never amend commits unless explicitly asked
- Show what will be committed but do not pause for confirmation

**Auto-commit cron** (`scripts/auto-commit.sh`): Hourly safety net that commits and pushes uncommitted changes. Install with `crontab -e`:
```
0 * * * * ~/.copilot/skills/brain/scripts/auto-commit.sh
```

---

### Create Daily Project Note

Create a numbered markdown file in today's `Daily Projects/YYYY-MM-DD/` folder.

**Workflow:**

1. Sync from remote
2. User provides a title/description
3. Create `Daily Projects/YYYY-MM-DD/` folder if needed
4. Find next available number prefix (`01`, `02`, ...)
5. Create `NN title.md` with frontmatter:

```yaml
---
uid: <TID>
type: daily.project
created: <date folder date>T00:00:00Z
session: <agent resume command>
---

# title
```

**Session auto-detection** for the `session` frontmatter field:

| Tool | Env Variable | Resume Command |
|------|-------------|----------------|
| OpenCode | `OPENCODE=1` | `opencode -s <session-id>` |
| Copilot | `COPILOT_PROXY_TOKEN_CMD` | `copilot --resume=<uuid>` |
| Claude | `CLAUDE_CODE=1` | `claude --resume <uuid>` |

Run `ruby ~/.copilot/skills/brain/scripts/detect-session.rb --project-dir ~/Brain` to detect. If it exits non-zero, omit the session field.

---

### Create Bookmark

Save a URL as a dated bookmark file with structured frontmatter and an executive-summary-style narrative body.

**File format:** `Bookmarks/YYYY-MM-DD/NN title.md`

```yaml
---
uid: <TID>
type: bookmark
created: <date>T00:00:00Z
url: https://example.com/article
title: "Article Title"
source: hacker-news
tags: [pkm, architecture]
---
```

**Workflow:**

1. Sync from remote
2. Extract URL(s) from user message
3. Get optional context: blurb, source (e.g. `hacker-news`, `slack`), tags
4. Fetch page title via WebFetch
5. Generate body: user's blurb if provided, otherwise generate executive-summary-style narrative
6. Create file with frontmatter + body
7. Confirm to user

**Body rules** (when generating, not when user provides blurb):

1. Start with a clear title line (not a markdown header)
2. Narrative paragraphs only — no bullets, headers, or lists
3. Contextual linking: link to source when referencing claims. For GitHub: `@username` unlinked, with separate `([ref](URL))` links
4. Focus on critical content: key arguments, evidence, implications, business impact
5. Close with personal relevance paragraph
6. Formal tone, dense prose

If fetch fails or returns thin metadata, still create the bookmark with a short narrative based on title/URL.

**Multiple URLs:** Create one file per URL with sequential numbering.

---

### Create Weekly Note

Create a weekly planning note from template with dates filled in, then interactively review carryover items from last week.

**Workflow:**

1. Sync from remote
2. Run: `~/.copilot/skills/brain/scripts/create-weekly-note`
3. Review previous week's Active Projects — confirm what's still active
4. Review unchecked items from previous week's Parked, Sessions, TODO sections:
   - Mark done, keep for this week, or drop
5. Copy confirmed carryover items to new note
6. Add frontmatter:

```yaml
---
uid: <TID>
type: weekly.note
created: <Sunday date ISO 8601>
tags: []
links:
  related: []
---
```

**Template:** Edit `assets/weekly-note-template.md` to customize. Placeholders: `{{sunday:YYYY-MM-DD}}` through `{{saturday:YYYY-MM-DD}}`. The default recurring schedule includes `{{Meeting Notes/tgthorley}}` on Tuesdays at `1400`.

---

### Archive Meeting

Archive meeting transcripts (Zoom folders or Teams .vtt files) into structured Brain artifacts.

**Outputs:**
- `Transcripts/YYYY-MM-DD/NN.md` — imported transcript
- `Executive Summaries/YYYY-MM-DD/NN.md` — generated summary
- `Meeting Notes/<target>/YYYY-MM-DD/NN.md` — meeting notes
- Weekly note checkbox marked complete

**Workflow — use the CLI:**

```bash
archive-meeting \
    --brain-dir ~/Brain \
    --executive-summary-prompt-path ~/code/jonmagic/prompts/summarize/zoom-transcript-executive-summary.md \
    --detailed-notes-prompt-path ~/code/jonmagic/prompts/summarize/transcript-meeting-notes.md
```

Interactive mode uses fzf to select from recent meetings and pending meeting note targets.

**Explicit mode** (when user specifies input and target):

```bash
archive-meeting \
    --brain-dir ~/Brain \
    --input "/path/to/transcript.vtt" \
    --meeting-notes-target "jonmagic" \
    --executive-summary-prompt-path ~/code/jonmagic/prompts/summarize/zoom-transcript-executive-summary.md \
    --detailed-notes-prompt-path ~/code/jonmagic/prompts/summarize/transcript-meeting-notes.md
```

**CLI options:** `--brain-dir`, `--input`, `--meeting-notes-target`, `--executive-summary-prompt-path`, `--detailed-notes-prompt-path`, `--date`, `--dry-run`

**Prerequisites:** The `archive-meeting` CLI from `~/code/jonmagic/scripts` must be on PATH. Verify with `which archive-meeting`.

**Frontmatter for outputs:** Add to any files the CLI doesn't frontmatter automatically. Link executive summaries and meeting notes back to their transcript via `links.source: [<transcript TID>]`.

**References:** `references/formats.md` (Zoom/Teams conventions), `references/meeting_notes_routing.yml` (routing overrides)

---

### Archive Session

Archive a Copilot CLI session to the Brain — creates a daily project file with the session transcript and adds a resume link to the weekly note.

**Inputs needed:** Session ID (from session context path `~/.copilot/session-state/UUID/`) and focus (1-5 word description from user).

**Workflow:**

1. Sync from remote
2. Ask user for the **focus**
3. Extract transcript:
   ```bash
   ~/.copilot/skills/brain/scripts/extract-transcript \
     --session-id "SESSION_ID" \
     --output "/tmp/session-transcript.md"
   ```
4. Create daily project file:
   ```bash
   ~/.copilot/skills/brain/scripts/create-daily-project \
     --focus "FOCUS" \
     --session-id "SESSION_ID" \
     --transcript "/tmp/session-transcript.md"
   ```
5. Add frontmatter to created file:
   ```bash
   ruby ~/.copilot/skills/brain/scripts/add-frontmatter.rb "PATH_FROM_STEP_4"
   ```
6. Update weekly note:
   ```bash
   ~/.copilot/skills/brain/scripts/update-weekly-note \
     --focus "FOCUS" \
     --session-id "SESSION_ID" \
     --daily-project-path "PATH_FROM_STEP_4"
   ```
7. Report the daily project path and which weekly note was updated

---

### Catch Me Up

Synthesize daily activity (daily projects, meeting notes, GitHub issues/PRs) into narrative summaries for weekly note day sections. Fills gaps where the user didn't write context notes.

**Workflow:**

1. Sync from remote
2. **Determine date range:**
   - "this week" → current week (Sunday through today)
   - "last week" → previous full week
   - "catch me up" with no qualifier → current week
3. **Read the weekly note** — identify which day sections need filling:
   - A day has substantive content only if it has narrative bullets (sentences describing what happened)
   - Just wikilinks, session commands, or `-` placeholders do NOT count
4. **Gather activity:**
   ```bash
   ~/.copilot/skills/brain/scripts/gather-activity --week YYYY-MM-DD --lines 100
   ```
   Options: `--date`, `--from`/`--to`, `--files` (paths only), `--no-github`, `--github-user <user>`
5. **Read full content** of daily projects and meeting notes for days needing summaries
6. **Write first-person narrative bullets** under each day heading

**GitHub activity classification — critical rules:**

The gather-activity script classifies GitHub items into summary-safe and context-only:

- `issues` / `pull_requests` arrays → **safe to summarize** (created or merged that day)
- `context_only_issues` / `context_only_pull_requests` → **advisory only**, ignore unless corroborated by daily project or meeting note

**Activity kind rules:**

| `activity_kind` | Safe to say |
|-----------------|-------------|
| `opened` | User opened/filed it that day |
| `merged` | User merged/shipped it that day |
| `opened_and_merged` | Opened and merged same day |
| `updated_existing` | **NOT safe** for day-specific claims — skip unless corroborated |

**Validation gate:** Never write "opened", "filed", "merged", "shipped", "reviewed" or similar day-specific language unless backed by a summary-safe GitHub item or corroborating daily project / meeting note. **Fail closed on ambiguity.**

**Voice and format:**

- First person, informal, concise
- Short bullet points (one line each)
- Capture what was worked on, key decisions, what happened
- Include meeting highlights: who, key outcomes
- Include session resume commands from daily project frontmatter
- Link to daily project files with wikilinks
- Tone: quick capture of state of mind and progress, like end-of-day notes

**Good example:**
```markdown
## Monday
- rescheduled with znull to next week to talk about the abuse data plane idea
- attended team sync
- synced with romanofoti
- started the morning by getting spamurai-next and hamzo PRs closer to shipping
```

**Avoid:** listing just file/meeting names, corporate language, bold prefixes, fabricating information.

**Day heading formats:** Day section headings may use either `## Monday` or `## Monday (2026-02-09)`. Match whichever format the existing note uses.

**Options:** Augment existing days, specific days only, dry run, multi-week ranges.

---

## Brain Reference

### Directory Map

| Directory | Purpose |
|-----------|---------|
| `Daily Projects/YYYY-MM-DD/` | Day-level execution work (numbered files) |
| `Weekly Notes/Week of YYYY-MM-DD.md` | Weekly planning, schedule, daily logs |
| `Meeting Notes/<person-or-team>/YYYY-MM-DD/` | Per-meeting files |
| `Snippets/YYYY-MM-DD-to-YYYY-MM-DD.md` | Weekly accomplishments (Fri-Thu) |
| `Executive Summaries/YYYY-MM-DD/` | Leadership summaries |
| `Transcripts/YYYY-MM-DD/` | Raw meeting transcripts |
| `Projects/<slug>/` | Multi-week initiatives |
| `Bookmarks/YYYY-MM-DD/` | Saved external references |
| `Wiki/` | Compiled, human-reviewed knowledge (see wiki skill) |
| `Archive/YYYY-MM-DD/` | Cold storage |

### Append-Only Discipline

- **Weekly Notes, Meeting Notes**: New entries at top (reverse-chronological)
- **Daily Projects**: Append running log to bottom
- **Snippets, Executive Summaries**: Create new files for new time periods

### Before Editing Existing Notes

1. Scan the last few entries to understand current state
2. Check for linked documents that provide context
3. Maintain chronological or thematic continuity
4. If a concept exists elsewhere, link to it rather than restating

### File Creation Decision Tree

1. Daily execution work? → `Daily Projects/YYYY-MM-DD/`
2. Weekly planning? → `Weekly Notes/Week of YYYY-MM-DD.md`
3. Meeting record? → `Meeting Notes/<person-or-team>/YYYY-MM-DD/`
4. Multi-week initiative? → `Projects/<slug>/`
5. External link to save? → `Bookmarks/YYYY-MM-DD/`
6. Transcript? → `Transcripts/YYYY-MM-DD/`
7. Leadership summary? → `Executive Summaries/YYYY-MM-DD/`
8. Accomplishment tracking? → `Snippets/`
9. **When in doubt**: Start in `Daily Projects/` and migrate later.

---

## Script Reference

All scripts live in `~/.copilot/skills/brain/scripts/`.

| Script | Purpose |
|--------|---------|
| `brain-index.rb` | Build the Brain index (`~/Brain/.brain/index.json`) |
| `brain-search.rb` | Query the index (full-text, tag, type, timeline, links, recent) |
| `generate-tid.rb` | Generate a 13-char TID |
| `add-frontmatter.rb` | Add YAML frontmatter to a file |
| `auto-tag.rb` | Auto-suggest tags for a file |
| `backfill-frontmatter.rb` | Bulk-add frontmatter to existing files |
| `detect-session.rb` | Detect running agent session for resume commands |
| `auto-commit.sh` | Hourly cron safety net for uncommitted changes |
| `create-weekly-note` | Generate weekly note from template with dates |
| `create-daily-project` | Create numbered daily project file (session-to-brain) |
| `extract-transcript` | Parse session events.jsonl into markdown |
| `update-weekly-note` | Add wikilink + resume command to weekly note |
| `gather-activity` | Discover daily projects, meetings, and GitHub activity |
| `archive_single_meeting.rb` | Orchestrate single meeting archive (legacy) |
| `check_off_weekly_note.rb` | Mark meeting checkbox in weekly note (legacy) |
| `list_recent_meetings.rb` | Discover recent Zoom/Teams transcripts (legacy) |
| `next_file_number.rb` | Find next sequential file number (legacy) |
| `update_meeting_notes.rb` | Append to meeting notes (legacy) |
| `vtt_to_markdown.rb` | Convert Teams VTT to markdown (legacy) |
