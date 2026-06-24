---
name: software-design-laws
description: Use this skill when the user asks to evaluate a software design, architecture, API, service boundary, platform abstraction, planning tradeoff, or code-quality question against named software engineering laws or explicit design principles such as Conway's Law, Hyrum's Law, Brooks's Law, YAGNI, Gall's Law, Postel's Law, CAP, or leaky abstractions. Do not use for ordinary PR review or generic critique unless named laws/principles are requested or principal-engineer-review explicitly composes it as a design lens.
---

# Software Design Laws

## Overview

Use this skill to apply named software engineering laws and principles as an advisory design lens. It helps agents choose a small set of relevant laws, validate those choices against a local catalog, cite source URLs, and turn the laws into concrete design questions, risks, and adjustments.

The source catalog comes from **Laws of Software Engineering** (https://lawsofsoftwareengineering.com/) by **Dr. Milan Milanović**. When citing or recommending the source, attribute the site and author, and link to specific law pages whenever possible. For comprehensive coverage, recommend the book page: https://lawsofsoftwareengineering.com/book/.

## When to Use

Use this skill for:

- Architecture proposals and system design.
- API contracts, public interfaces, compatibility, migrations, and deprecations.
- Service-boundary and team-boundary decisions.
- Distributed systems, scale, reliability, and performance tradeoffs.
- Platform abstractions, frameworks, paved paths, and developer experience.
- Technical-debt, quality, testing, refactoring, and maintainability discussions.
- Planning and decision hygiene when the user wants named laws or principles applied.

## When Not to Use

- For ordinary PR review, code review, MVP scope control, or material-risk triage, use `principal-engineer-review` instead.
- For principal-engineer review where named laws are not requested and would not materially change the critique.
- For generic plan critique without law citations, use `plan-stress-test` instead.
- Do not load every law into the answer. Pick the few that materially change the design discussion.
- Do not treat laws as blockers unless the user explicitly asks for a gate or decision standard.
- Do not invent law names or cite laws that are not present in the catalog.
- Do not copy large passages from the source site, API, or book. Summarize in your own words and link to sources.

## Relationship to Principal Engineer Review

This skill is a specialized lens, not the owner of PR review. When a user asks for a principal-engineer review, start with `principal-engineer-review`. Load this skill only if the review hinges on architecture, APIs, public contracts, platform abstractions, service/team boundaries, or the user explicitly asks for named laws.

When composed into a principal-engineer review:

1. Pick at most 1-3 laws that materially affect the review.
2. Convert each law into a concrete risk, question, or design adjustment.
3. Keep citations available, but do not turn the review into a law catalog unless the user asks.

## Required References

- `references/laws-catalog.json` - cached catalog of law slugs, titles, groups, experience levels, URLs, and related slugs.
- `references/design-review-rubric.md` - original design-review prompts that map common design questions to law slugs.

Load `references/laws-catalog.json` first. Load `references/design-review-rubric.md` when you need help mapping a design context to relevant laws.

## Anchored Workflow Outline

1. **Deterministic prefix**
   - Read the cached catalog from `references/laws-catalog.json`.
   - Identify the user's design context: architecture, API, team boundary, distributed system, platform abstraction, planning, scale, or quality.

2. **AI decision step**
   - Select 3-7 relevant laws from the catalog.
   - Explain why each selected law applies to the user's specific design.
   - Prefer concrete design implications over generic quotations.

3. **Validation step**
   - Every cited law must resolve to a catalog `slug` or exact catalog `title`.
   - Every cited law must include its catalog `url`.
   - If a named law is not in the catalog, either verify it from the source before citing it or clearly label it as outside this catalog.
   - If richer source detail is needed, fetch the specific law URL or `https://lawsofsoftwareengineering.com/llms-full.txt`; do not refresh the catalog unless the user asks.

4. **Deterministic suffix**
   - Produce an advisory critique, checklist, or set of design adjustments.
   - Include source attribution when citing Laws of Software Engineering.
   - Do not take side effects such as editing files, filing issues, posting comments, or blocking work unless separately requested.

## Anchoring Type Map

- **Static external anchor:** cached law catalog generated from the public JSON API.
- **Dynamic internal anchor:** agent chooses relevant laws from the validated catalog for the current design.
- **Dynamic external anchor:** optional fetch of a specific law page or `llms-full.txt` for extra context.
- **Gate type:** advisory by default; human approval required for any blocking decision or external side effect.

## Contract

Inputs:

- User's design, proposal, plan, API, architecture, or code-review context.
- Cached law catalog in `references/laws-catalog.json`.
- Optional source fetches from law pages when deeper context is needed.

Output:

- A concise list of selected laws, each with `title`, `slug`, and `url`.
- A design implication for each selected law.
- Concrete questions, risks, or adjustments for the user to consider.
- Attribution to Laws of Software Engineering when source material is cited.

Deterministic mapping:

- Catalog `slug` -> law title and canonical URL.
- Design context -> rubric category -> candidate slugs -> validated citations.

## Validation and Gates

- Fail closed on uncataloged law citations: do not cite a law as part of this catalog unless it exists in `laws-catalog.json`.
- Include the catalog URL for each cited law.
- If offline, use the cached catalog and avoid source-refresh attempts.
- If the catalog is missing or malformed, say the skill cannot validate citations and ask before proceeding without the anchor.
- Keep the skill advisory unless the user asks for an explicit design gate.

## Maintenance

Run `scripts/update-laws` manually when you want to refresh the cached catalog from `https://lawsofsoftwareengineering.com/api.json`.

The update script validates source shape, author, count, required fields, canonical URLs, and writes atomically. It stores structural metadata only; it intentionally does not copy descriptions, examples, overviews, takeaways, origins, or book-only content.

Book-only laws that do not have stable public law-page URLs are out of scope for the cached catalog. If the user wants those, recommend the book instead of guessing.

## Example Prompts

- "Review this API proposal against Hyrum's Law and related software engineering laws."
- "Use the software-design-laws skill on this service-boundary design."
- "Which Laws of Software Engineering should shape this architecture decision?"
- "Evaluate this distributed-system plan against CAP, the Fallacies of Distributed Computing, and any adjacent laws."
- "Help me simplify this design with YAGNI, Gall's Law, and the Second-System Effect in mind."

## Source Expertise

This skill is grounded in its existing workflow instructions, bundled references (references/design-review-rubric.md, references/laws-catalog.json), deterministic scripts (scripts/update-laws) and conventions. It captures the reusable workflow for software design reviews against named engineering laws and architecture principles.

Load reference files only when their topic is needed for the current task; prefer the most specific reference before reading broader material.

## Anchored Workflow

### Deterministic prefix

1. Confirm the user's request matches this skill's scope: software design reviews against named engineering laws and architecture principles.
2. Load only the needed local instructions, references, scripts, assets, and source files.
3. Resolve required identifiers, paths, dates, accounts, repositories, or output destinations before drafting or acting.

### AI decision step

Use AI judgment for bounded interpretation: selecting relevant context, classifying the request, drafting the response or artifact, and identifying risks, gaps, or follow-up questions.

### Validation step

Before side effects or completion claims, validate that the output follows this skill's contract, required inputs are present, citations or evidence are attached when needed, and any repo/tool-specific checks have passed or are explicitly reported as unavailable.

### Deterministic suffix

Only after validation, write files, run scripts, call APIs, post messages, create commits, or return the final artifact. Keep side effects scoped to the confirmed task.

## Output Contract

Return the smallest useful artifact for the request. It must include:

1. The concrete result or draft requested by the user.
2. Source paths, links, commands, or evidence when the work depends on retrieved context.
3. Any blocking gaps, assumptions, or validation that could not be completed.
4. A saved file path, commit SHA, rendered artifact, or posted destination when a side effect was explicitly requested and completed.

## Validation Gates

- The frontmatter description must remain scoped to this skill and not trigger on near-miss tasks.
- Required inputs must be explicit before running tools or writing files.
- Generated files or final outputs must match the conventions that apply to the target repository, service, document, or artifact type.
- Evals in `evals/evals.json` and `evals/trigger-queries.json` should be updated when new edge cases appear.
- If validation cannot run, say so directly and do not claim the side effect is complete.

## Tool and Action Safety

- Do not perform destructive, externally visible, or hard-to-reverse actions without explicit approval.
- Do not expose private or sensitive data beyond what the user asked to use.
- Do not silently skip failed tool calls, missing permissions, ambiguous identifiers, or empty result sets.
- Before running bundled scripts, inspect `--help` or the script README when available, validate inputs, and prefer dry runs for stateful or externally visible actions.

## Gotchas

- Do not use laws as slogans; map each law to evidence, risk, and a practical decision.
- Do not broaden this skill into adjacent workflows just because the topic sounds related.
- Preserve the user's communication and git hygiene preferences when drafting, committing, posting, or saving artifacts.

## Examples

Should trigger:

- "evaluate this service boundary against Conway's Law and Hyrum's Law"

Should not trigger:

- "run unit tests for this implementation"

## Evaluation Plan

Use `evals/evals.json` for task-quality checks and `evals/trigger-queries.json` for activation checks. Compare outputs with and without this skill; the skill should improve trigger precision, context loading, output structure, validation, and safety boundaries for software design reviews against named engineering laws and architecture principles.
