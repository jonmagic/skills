# Skills

A collection of [Agent Skills](https://github.com/agentskills/agentskills) I have developed for GitHub Copilot and other AI agents. Each skill is a folder containing a `SKILL.md` file with specialized instructions, examples, and resources for specific tasks.

## Skills

<!-- SKILLS-LIST:START -->
- [brain](skills/brain/) — Complete operating system for jonmagic's second brain — search, create, capture, commit, and maintain Brain content. Use for any Brain operation: search, daily projects, bookmarks, weekly notes, meetings, sessions, catch-ups, commits, frontmatter, and context loading.
- [d2-diagrams](skills/d2-diagrams/) — Create, modify, and render D2 diagrams using the d2 CLI. Use when the user asks for diagrams, architecture visuals, ERDs, sequence diagrams, flowcharts, grid layouts, or any declarative diagramming task. Trigger phrases include "d2 diagram", "create a diagram", "architecture diagram", "sequence diagram", "ERD", "flowchart", "draw", "visualize".
- [dependency-safety](skills/dependency-safety/) — Prevents unnecessary dependency installation and audits unavoidable packages. Use before adding, installing, upgrading, or recommending dependencies, packages, libraries, gems, npm modules, pip packages, crates, GitHub Actions, CLIs, or package-manager commands.
- [executive-summary](skills/executive-summary/) — Create formal executive summaries from GitHub conversations or meeting transcripts. Use when generating leadership-ready summaries that distill key decisions, alternatives, outcomes, and next steps from complex conversations or meetings. Supports GitHub issues/PRs and transcript URIs (Zoom, Teams, etc.). Outputs are saved to Executive Summaries/ with date-organized structure, and source inputs are archived to Transcripts/ with matching naming.
- [header-image-prompt](skills/header-image-prompt/) — Generate an AI art prompt for a blog post or GitHub discussion header image. Interactive skill that reads the content, interviews the user about their vision, and produces a ready-to-use prompt for any AI image generation tool. Use when the user says "header image", "create a header", "generate art for my post", or similar.
- [markdown-to-standalone-html](skills/markdown-to-standalone-html/) — Convert Markdown documents (*.md files) to self-contained HTML files with embedded images. Use when you need a portable, offline-friendly single HTML file from Markdown—ideal for blog posts, essays, reports, or any content that should work without external dependencies.
- [ollama-imagegen](skills/ollama-imagegen/) — Generate images locally using Ollama's x/z-image-turbo model. Use when the user asks to generate an image, create art, make a picture, or produce a visual. Trigger phrases include "generate an image", "create a picture", "make art", "image of", "draw me", "visualize", "photo of", "illustration of".
- [semantic-commit](skills/semantic-commit/) — Generate semantic commit messages from staged changes. Use when committing code to produce consistent, well-structured commit messages following conventional commit format.
- [software-design-laws](skills/software-design-laws/) — Use this skill when the user asks to evaluate a software design, architecture, API, service boundary, platform abstraction, planning tradeoff, or code-quality question against named software engineering laws or explicit design principles such as Conway's Law, Hyrum's Law, Brooks's Law, YAGNI, Gall's Law, Postel's Law, CAP, or leaky abstractions. Do not use for ordinary PR review or generic critique unless named laws/principles are requested or principal-engineer-review explicitly composes it as a design lens.
<!-- SKILLS-LIST:END -->

## Contributors

- [jonmagic](https://github.com/jonmagic)

## License

This project is licensed under the [ISC License](LICENSE).
