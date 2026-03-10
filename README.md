# Skills

A collection of [Agent Skills](https://github.com/agentskills/agentskills) I have developed for GitHub Copilot and other AI agents. Each skill is a folder containing a `SKILL.md` file with specialized instructions, examples, and resources for specific tasks.

## Skills

<!-- SKILLS-LIST:START -->
- [archive-meeting](skills/archive-meeting/) — Archive one or more meetings into the brain repo by importing Zoom transcript folders (~/Documents/Zoom/*) and/or downloaded Teams .vtt files (~/Downloads/*.vtt), then generating a transcript markdown file, an executive summary, and creating meeting notes. Use when the user says "archive meeting", "archive my last meeting", "process these transcripts", or similar.
- [brain-commit](skills/brain-commit/) — Analyze changes in the Brain repo and create semantic commits. Use when the user wants to commit their brain changes with meaningful, organized commit messages. Analyzes staged/unstaged changes, groups related files, creates appropriate commits, and pushes without user interaction.
- [brain-operating-system](skills/brain-operating-system/) — Quick reference for operating within jonmagic's second-brain workspace. Use when working with files in the brain repository—provides directory structure, naming conventions, append-only norms, wikilink patterns, frontmatter requirements, project conventions, and file organization rules. Essential for understanding where to create files, how to name them, and how to maintain continuity with existing structures.
- [brain-search](skills/brain-search/) — Query the Brain index for files by text, tags, type, links, or timeline. Use when searching for Brain content, finding related notes, or exploring what's been written about a topic.
- [catch-me-up](skills/catch-me-up/) — Gather daily activity (daily projects, meeting notes) and synthesize narrative summaries into weekly note day sections. Use when the user says "catch me up", "fill in my weekly note", "what happened this week", or similar.
- [create-bookmark](skills/create-bookmark/) — Save a URL as a bookmark with frontmatter and a blurb or AI summary. Use when the user says "bookmark this", "save this link", or shares a URL they want to remember.
- [d2-diagrams](skills/d2-diagrams/) — Create, modify, and render D2 diagrams using the d2 CLI. Use when the user asks for diagrams, architecture visuals, ERDs, sequence diagrams, flowcharts, grid layouts, or any declarative diagramming task. Trigger phrases include "d2 diagram", "create a diagram", "architecture diagram", "sequence diagram", "ERD", "flowchart", "draw", "visualize".
- [executive-summary](skills/executive-summary/) — Create formal executive summaries from GitHub conversations or meeting transcripts. Use when generating leadership-ready summaries that distill key decisions, alternatives, outcomes, and next steps from complex conversations or meetings. Supports GitHub issues/PRs and transcript URIs (Zoom, Teams, etc.). Outputs are saved to Executive Summaries/ with date-organized structure, and source inputs are archived to Transcripts/ with matching naming.
- [header-image-prompt](skills/header-image-prompt/) — Generate an AI art prompt for a blog post or GitHub discussion header image. Interactive skill that reads the content, interviews the user about their vision, and produces a ready-to-use prompt for any AI image generation tool. Use when the user says "header image", "create a header", "generate art for my post", or similar.
- [markdown-to-standalone-html](skills/markdown-to-standalone-html/) — Convert Markdown documents (*.md files) to self-contained HTML files with embedded images. Use when you need a portable, offline-friendly single HTML file from Markdown—ideal for blog posts, essays, reports, or any content that should work without external dependencies.
- [semantic-commit](skills/semantic-commit/) — Generate semantic commit messages from staged changes. Use when committing code to produce consistent, well-structured commit messages following conventional commit format.
- [session-to-brain](skills/session-to-brain/) — Archive a Copilot CLI session to the brain. Creates a daily project file with the session transcript and adds a resume link to the weekly note. Use when ending a significant work session to preserve context for future reference.
<!-- SKILLS-LIST:END -->

## Contributors

- [jonmagic](https://github.com/jonmagic)

## License

This project is licensed under the [ISC License](LICENSE).
