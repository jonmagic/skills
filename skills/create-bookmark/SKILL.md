---
name: create-bookmark
description: Save a URL as a bookmark with frontmatter and a blurb or AI summary. Use when the user says "bookmark this", "save this link", or shares a URL they want to remember.
---

# Create Bookmark

Save a URL as a dated bookmark file in the Brain with structured frontmatter and a human blurb or AI-generated summary.

## Overview

Bookmarks are stored as individual markdown files in `Bookmarks/YYYY-MM-DD/` with sequential numbering, following the same pattern as Daily Projects. Each bookmark has frontmatter (uid, type, url, title, source, tags) and a markdown body containing the user's blurb or an AI summary of the linked content.

## When to Use

Use this skill when the user:

- Says "bookmark this", "save this link", "bookmark that URL"
- Shares a URL and asks you to save or remember it
- Asks to import bookmarks from a file or list
- References a link they want to come back to later

## File Format

```
Bookmarks/
  2026-02-13/
    01 using an engineering notebook.md
    02 roblox sentinel risk detection.md
  2026-02-14/
    01 spiral funnel adr.md
```

Each file looks like:

```yaml
---
uid: 3medhoffc22xy
type: bookmark
created: 2026-02-13T00:00:00Z
url: https://ntietz.com/blog/engineering-notebook/
title: "Using an Engineering Notebook"
source: hacker-news
tags: [pkm, architecture]
---
Nicole's take on engineering notebooks as thinking tools, not reference material.
The key insight is that she rarely reads her notes back — "the writing is the
work, in a lot of ways, since it's the thinking."
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `uid` | yes | TID (auto-generated) |
| `type` | yes | Always `bookmark` |
| `created` | yes | ISO 8601 date |
| `url` | yes | The bookmarked URL |
| `title` | yes | Page title (fetched or provided) |
| `source` | no | Where it was found (e.g. `hacker-news`, `slack`, `colleague`) |
| `tags` | no | From the tag vocabulary |

### Body

The markdown body contains either:
- **User's blurb** — if they provide context about why they're saving it
- **AI summary** — if no blurb is given, fetch the URL content and write a 1-3 sentence summary explaining what the page is about and why it's interesting

## Workflow

### Step 0: Sync Brain from remote

Before doing anything else, pull the latest changes from the remote to ensure you're working with the most current Brain content:

```bash
cd ~/Brain && git pull --rebase --autostash -X theirs
```

If rebase fails, fallback to merge:

```bash
cd ~/Brain && git rebase --abort && git pull --no-rebase -X theirs --no-edit
```

### Step 1: Extract the URL

Get the URL from the user's message. If they share multiple URLs, create one bookmark per URL.

### Step 2: Get context from the user

Check if the user provided:
- A **blurb** (their own description of why this is interesting)
- A **source** (where they found it: hacker-news, slack, colleague, twitter, etc.)
- **Tags** from the tag vocabulary

If any of these aren't provided, that's fine — they're all optional except the blurb/summary.

### Step 3: Fetch the page title

Use the WebFetch tool to load the URL and extract the page title. If the fetch fails, derive a title from the URL path.

### Step 4: Generate AI summary (if no blurb)

If the user didn't provide a blurb, use the fetched page content to write a 1-3 sentence summary. Write it in first person as if explaining why the user saved it. Be concise and focus on what makes it interesting or useful.

### Step 5: Create the bookmark file

Create the file at `Bookmarks/YYYY-MM-DD/NN title.md` where:
- `YYYY-MM-DD` is today's date
- `NN` is the next sequential number in that date folder
- `title` is the slugified page title (lowercase, spaces preserved, unsafe chars stripped)

Use the `generateTid()` function for the UID, or generate a TID manually (13-char base32-sortable timestamp).

### Step 6: Confirm to the user

Tell the user the bookmark was created and show the path. If they want to add tags or edit the blurb, they can do so directly.

## Examples

### User provides blurb and source

```
User: bookmark this https://ntietz.com/blog/engineering-notebook/ — found it on HN, great take on using notebooks as thinking tools not reference material

Agent creates:
  Bookmarks/2026-02-13/01 using an engineering notebook.md
  with source: hacker-news
  with user's blurb as body
```

### User provides just a URL

```
User: save this link https://corp.roblox.com/newsroom/2025/08/open-sourcing-roblox-sentinel-preemptive-risk-detection

Agent:
  1. Fetches the page
  2. Extracts title: "Open Sourcing Roblox Sentinel: Preemptive Risk Detection"
  3. Generates AI summary from page content
  4. Creates: Bookmarks/2026-02-13/01 open sourcing roblox sentinel preemptive risk detection.md
```

### Multiple bookmarks at once

```
User: bookmark these:
- https://example.com/article1
- https://example.com/article2
- https://example.com/article3

Agent creates three separate files in Bookmarks/YYYY-MM-DD/, numbered 01, 02, 03.
```

## Querying Bookmarks

Users may ask to find bookmarks. When they do:
- Search `Bookmarks/` directory by filename, tags, or content
- Use grep/glob to find bookmarks matching keywords
- Report results with the URL, title, and blurb

## Important Notes

- The `Bookmarks/` directory is in the Brain root (`~/Brain/Bookmarks/`)
- One file per bookmark, organized into date folders
- Sequential numbering within each date folder (same pattern as Daily Projects)
- Tags should come from the Brain's tag vocabulary when possible
- The `source` field uses lowercase hyphenated names (e.g. `hacker-news`, not `Hacker News`)
- Titles are quoted in frontmatter to handle special characters
- If the URL is unreachable, still create the bookmark with whatever title/info is available
