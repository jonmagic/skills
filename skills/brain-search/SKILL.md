---
name: brain-search
description: Query the Brain index for files by text, tags, type, links, or timeline. Use when searching for Brain content, finding related notes, or exploring what's been written about a topic.
---

# Brain Search

Search and query the Brain's structured index. Supports full-text search, tag filtering, type filtering, link traversal, timeline views, and recent file discovery.

## Prerequisites

Build the index first (takes ~2 seconds):

```bash
node ~/.copilot/skills/brain-search/scripts/brain-index.js ~/Brain --stats
```

The index is written to `~/.brain-index.json`. Rebuild it whenever you need fresh results.

## Search Modes

### Full-text search

Search across titles, summaries, paths, and tags:

```bash
node ~/.copilot/skills/brain-search/scripts/brain-search.js "proxima abuse"
```

### Tag search

Find files with a specific tag:

```bash
node ~/.copilot/skills/brain-search/scripts/brain-search.js --tag hamzo
```

### Type filter

Find files of a specific collection type:

```bash
node ~/.copilot/skills/brain-search/scripts/brain-search.js --type daily.project --tag proxima
```

### Timeline view

See how thinking on a topic evolved chronologically:

```bash
node ~/.copilot/skills/brain-search/scripts/brain-search.js --timeline "nuanced-enforcement"
```

### Link traversal

Find everything linking to a specific record:

```bash
node ~/.copilot/skills/brain-search/scripts/brain-search.js --linked-to 3lz7nwvh4zc2u
```

### Recent files

Files modified in the last N days:

```bash
node ~/.copilot/skills/brain-search/scripts/brain-search.js --recent 7
```

### Index statistics

```bash
node ~/.copilot/skills/brain-search/scripts/brain-search.js --stats
```

## Options

| Option | Description |
|--------|-------------|
| `--tag <tag>` | Filter by tag (combinable with other filters) |
| `--type <type>` | Filter by collection type |
| `--linked-to <uid>` | Find records linking to this UID |
| `--timeline <query>` | Chronological view of a topic |
| `--recent <days>` | Files modified in last N days |
| `--limit <n>` | Max results (default: 20) |
| `--compact` | Compact output (paths only) |
| `--index <path>` | Custom index path (default: `~/.brain-index.json`) |
| `--stats` | Show index statistics |

## Collection Types

`daily.project`, `weekly.note`, `meeting.note`, `project`, `snippet`, `transcript`, `executive.summary`, `archive`, `reference`

## Agent Usage

When an agent needs to answer "what do I know about X?":

1. Rebuild the index: `node ~/.copilot/skills/brain-search/scripts/brain-index.js ~/Brain`
2. Search: `node ~/.copilot/skills/brain-search/scripts/brain-search.js "query"`
3. Read the most relevant files for deeper context

For timeline questions ("how has my thinking on X evolved?"):

1. Use `--timeline "topic"` to get chronological results
2. Read key files at different time points to trace the evolution
