---
name: brain-operating-system
description: Quick reference for operating within jonmagic's second-brain workspace. Use when working with files in the brain repository—provides directory structure, naming conventions, append-only norms, wikilink patterns, frontmatter requirements, project conventions, and file organization rules. Essential for understanding where to create files, how to name them, and how to maintain continuity with existing structures.
---

# Brain Operating System

Navigation guide for jonmagic's second-brain workspace covering directory intents, naming conventions, operational norms, frontmatter, and project conventions.

## How This Brain Works

Thinking is multimodal and distributed. AI agent conversations are the primary capture mechanism -- Daily Project files are collaborative AI output, not pre-work journals. Human meetings are captured as transcripts and feed into meeting notes and executive summaries. Walk-and-talk voice memos get recorded, transcribed, and mixed with other inputs. The mixing is where insights crystallize, but thinking happens at every stage.

The Brain is **bidirectionally accessed from any project**. When working in hamzo, spamurai-next, or any other repo, agents both write to the Brain and read from it. This skill is globally available for that reason.

## Directory Map

| Directory | Purpose | Notes |
|-----------|---------|-------|
| `Daily Projects/YYYY-MM-DD/` | Day-level execution work | Numbered files (`01 topic.md`). Start new work here. |
| `Weekly Notes/Week of YYYY-MM-DD.md` | Weekly planning, schedule, OKRs, daily logs | New entries at top (reverse-chronological). |
| `Meeting Notes/<person-or-team>/YYYY-MM-DD/` | Per-meeting files with transcript links and action items | Numbered files per meeting per day. |
| `Snippets/YYYY-MM-DD-to-YYYY-MM-DD.md` | Weekly accomplishment summaries (Ships, Collabs, Risks, etc.) | Friday-Thursday cycles. Primary feed for retros. |
| `Executive Summaries/YYYY-MM-DD/` | Distilled updates for leadership | Keep concise (1-2 pages). Reference snippets and priorities. |
| `Transcripts/YYYY-MM-DD/` | Raw meeting transcripts | Sequential numbering (`01.md`, `02.md`). Reference via wikilinks. |
| `Projects/<slug>/` | Multi-week initiatives | Short-slug folders with `executive summary.md`, `references.md`, and artifacts. |
| `Projections/` | Auto-generated concept summaries | Regenerated from source material. Clearly marked as generated. |
| `Bookmarks/YYYY-MM-DD/` | Saved external references with frontmatter | Numbered files (`01 title.md`). One bookmark per file. |
| `Archive/YYYY-MM-DD/` | Cold storage for inactive artifacts | Only move files once captured elsewhere. |

## Naming Conventions

- **Filenames**: lowercase with hyphens (`my-file-name.md`), except Daily Project files which use numbered prefixes (`01 topic.md`)
- **Date folders**: `YYYY-MM-DD` format
- **Project slugs**: short kebab-case (`nuanced-enforcement`, `proxima-abuse-prevention`)
- **Sequential files**: Numeric prefixes within date folders (`01 topic.md`, `02 follow-up.md`)
- **Prefer appending**: Always try to append to existing date folders rather than creating duplicates

## Frontmatter

All new markdown files should include YAML frontmatter:

```yaml
---
uid: <TID>              # Sortable timestamp ID (AT Protocol style, 13 chars)
type: <collection>      # daily.project, weekly.note, meeting.note, project, snippet, transcript, executive.summary, bookmark
created: <ISO 8601>     # When the content was created
tags: []                # Controlled vocabulary tags (see tag-vocabulary.md at repo root)
links:                  # Structured relationships
  parent: []
  source: []
  related: []
---
```

TIDs are 13-character base32-sortable identifiers encoding microseconds since Unix epoch. They give every file a stable address that survives renames and moves. Use the `frontmatter-add` skill to generate TIDs and add frontmatter to files.

Tags use a controlled vocabulary defined in `tag-vocabulary.md` at the Brain repo root. Consult that file before assigning tags -- pick 1-4 of the most specific applicable tags per file.

## Operational Norms

### Append-Only Discipline

- **Weekly Notes, Meeting Notes**: Always append new entries at top (reverse-chronological)
- **Daily Projects**: When asked, append a running log of steps to the bottom of the existing file
- **Context files** (e.g., `snippets-context-*.txt`, `retro-context-*.txt`): Always append to end, never edit middle sections
- **Snippets, Executive Summaries**: Create new files for new time periods

### Wikilink Patterns

Use `[[...]]` wikilinks to connect documents:
- `[[Snippets/2025-11-24-to-2025-11-30]]`
- `[[Projects/nuanced-enforcement/executive summary]]`
- `[[Meeting Notes/alice/2026-02-10/01]]`
- `[[uid:TID|Display Text]]` for TID-based links

### Thread Awareness

Before editing any document:
1. Scan the last few entries to understand current state
2. Check for linked documents that provide context
3. Maintain chronological or thematic continuity

### Minimal Duplication

- If concept exists elsewhere, link to it rather than restating
- Use wikilinks to connect related content
- Consolidate learnings into appropriate long-term documents (Weekly Notes, Projects, etc.)

## Projects

Projects are multi-week efforts that accumulate artifacts. Each project folder contains:

| File | Purpose | Updated by |
|------|---------|-----------|
| `executive summary.md` | GitHub issue link, current status, brief narrative summary | Agent (regenerated periodically) |
| `references.md` | Links to all related Daily Projects, meetings, transcripts, PRs | Agent (auto-appended) |
| Other `*.md` files | Artifacts: proposals, ADRs, analysis reports, interview notes | Created during work |

### Project Lifecycle

- **Active** -- working on this week/month
- **Parked** -- paused but may resume; stays in `Projects/` with parked status in executive summary
- **Completed** -- done; stays in `Projects/` briefly for reference, then archived
- **Archived** -- moved to `Archive/YYYY-MM-DD/Projects/`

## File Creation Decision Tree

**Creating a new file?**
1. Is it daily execution work? → `Daily Projects/YYYY-MM-DD/`
2. Is it weekly planning? → `Weekly Notes/Week of YYYY-MM-DD.md`
3. Is it accomplishment tracking? → `Snippets/YYYY-MM-DD-to-YYYY-MM-DD.md`
4. Is it a meeting record? → `Meeting Notes/<person-or-team>/YYYY-MM-DD/` (numbered files)
5. Is it a multi-week initiative? → `Projects/<slug>/`
6. Is it a project artifact (proposal, ADR, analysis)? → `Projects/<slug>/`
7. Is it a transcript? → `Transcripts/YYYY-MM-DD/`
8. Is it a leadership summary? → `Executive Summaries/YYYY-MM-DD/`

9. Is it an external link to save? → `Bookmarks/YYYY-MM-DD/` (numbered files)

**When in doubt**: Start in `Daily Projects/YYYY-MM-DD/` and migrate later if it becomes evergreen.

## Workflow Expectations

1. **Start in Daily Projects**: Kick off new work in `Daily Projects/YYYY-MM-DD/`
2. **Propagate learnings**: Copy distilled notes into relevant Weekly Note, Snippet, or Project file
3. **Follow breadcrumbs**: Use wikilinks to trace decision history
4. **Version-friendly**: Use Markdown headings, tables, bullet lists; avoid inline HTML
5. **Cross-project access**: When working in another repo, use `project-paths` skill to resolve the Brain path

## Brain Infrastructure

The Brain has a structured index and search system. Use these tools to find and connect content:

| Tool | Purpose | Command |
|------|---------|---------|
| `brain-search` | Build index, search by text/tag/type/timeline | `node ~/.copilot/skills/brain-search/scripts/brain-index.js ~/Brain` |
| `brain-connections` | Find related files by tag overlap and content similarity | `node ~/.copilot/skills/brain-connections/scripts/brain-connections.js <file>` |
| `brain-project` | Generate concept projections gathering all content on a topic | `node ~/.copilot/skills/brain-project/scripts/brain-project.js --tag <topic> ~/Brain` |
| `brain-context` | Load relevant context at session start | See `brain-context` skill |

**Before searching**, rebuild the index (takes ~2 seconds):

```bash
node ~/.copilot/skills/brain-search/scripts/brain-index.js ~/Brain
```

**Projections** live in `Projections/` and are generated artifacts. They gather all content about a topic into a single reference. Refresh with `--refresh`.

