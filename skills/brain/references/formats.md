# Input formats: Zoom + Teams

This skill supports two durable sources of meeting transcripts.

## Zoom (folder-based)

Typical location:

- `~/Documents/Zoom/<meeting-folder>/`

The existing `archive-meeting` Ruby script treats a *meeting* as a folder and includes all matching files in that folder.

Common file types:

- `*.txt` (Zoom transcript)
- `*.vtt` (sometimes Zoom exports WebVTT)
- chat logs (varies, may also be `*.txt`)

Heuristic:

- Choose the most recently modified folder as “last meeting” unless user specifies otherwise.

## Teams (downloaded .vtt)

Typical location:

- `~/Downloads/*.vtt`

Heuristic:

- Choose the most recently modified `.vtt` as “last Teams meeting” unless user specifies otherwise.

Conversion:

- Convert VTT to Markdown transcript via `scripts/vtt_to_markdown.py`.
- The conversion is intentionally simple; downstream summarization can clean it up.
