# GitHub Conversation Executive Summaries

This reference details the specific rules and patterns for synthesizing executive summaries from GitHub conversations (issues, pull requests, discussions).

## Guiding Rules

### 1. Concise, Informative Title

Begin with a **clear, succinct title** (markdown h2) that encapsulates the main subject or decision at hand. The title should immediately set context and importance. For example:

- `## Decision on API Authentication Strategy`
- `## Resolution for Critical Database Performance Regression`
- `## Feature Design Review: Real-Time Notifications`

### 2. Narrative Structure

Present the summary as a series of **well-structured paragraphs** (no bullets, subheaders, or lists). Use formal, professional tone. Each paragraph should:

- Build logically on the previous one
- Convey the conversation's evolution: from initial problem/request → discussion/debate → decision(s) → implications
- Be dense but readable (full sentences, clear reasoning)

### 3. Complete Contextual Linking

Every time you reference information from the conversation, provide a direct link to the source:

#### Linking Comments by Contributors

When you cite or paraphrase a statement from a contributor:

- Mention their name plainly (not as a link): `As Alice suggested...`
- Immediately follow with a link to their comment: `(see [comment](https://github.com/.../issues/123#issuecomment-456789))`
- Alternatively, integrate the link into the sentence: `According to the guidance provided by Alice ([in her comment](https://github.com/.../issues/123#issuecomment-456789)), the remediation plan...`
- **Important**: The `@username` itself is not linked; the link refers to the actual comment or event

Example:
> As @alice suggested ([comment](https://github.com/repo/issues/1#issuecomment-123)), the remediation plan requires additional time.

#### Linking Events, Labels, or Status Changes

When referencing a point where the conversation moved stages (label added, status changed, etc.):

- Describe the event plainly
- Follow with a link showing when it occurred: `(see [timeline](https://github.com/repo/issues/1#timeline))`

Example:
> Following the addition of the `needs-review` label ([event](https://github.com/repo/issues/1#timeline)), the conversation shifted toward implementation details.

#### Linking Referenced Documentation or Resources

If a guide, documentation page, or external resource is mentioned or central to the decision:

- Embed the link in a descriptive phrase that clearly points to it
- Provide contextual framing so the reader understands why it matters

Example:
> According to the shared [authentication guidelines](https://example.com/auth-docs), this approach is discouraged for production systems.

### 4. Focus on Critical Content

**Include:**
- Key debates and the reasoning behind them
- Decisions made and why
- Constraints that shaped the decision
- Business or user impact
- Alternatives that were explored and rejected (with rationale)

**Exclude:**
- Routine subscription messages ("I'm watching this repo")
- Superficial technical details (exact code diffs, merge timestamps, commit SHAs)
- Administrative commentary ("Closing this now")
- Automated bot events (unless they introduced crucial information)
- Pleasantries or procedural remarks

### 5. Alternatives, Status, and Next Steps

Clearly explain:

- **Alternative solutions** discussed: Why were they rejected? What trade-offs were considered?
- **Current status**: Is the issue resolved, in progress, or blocked?
- **Next steps and responsibilities**: Who is responsible for what, and when?

Link to the specific comments or resources where these alternatives or next steps were discussed.

Example:
> The team explored two approaches: caching at the database layer ([discussed here](https://github.com/repo/issues/1#issuecomment-xyz)) and implementing a distributed cache ([proposal](https://github.com/repo/issues/1#issuecomment-abc)). The caching approach was ultimately chosen because it reduced operational complexity, though it requires schema changes. Alice will lead the implementation by [end of quarter](https://github.com/repo/issues/1#issuecomment-def).

### 6. Formal Tone and Dense Prose

- Write in complete, well-structured sentences
- Avoid contractions and conversational language
- Integrate links seamlessly without extraneous formatting or line breaks
- Maintain an authoritative voice suitable for leadership review

### 7. Handling Special Cases

#### Partial Resolutions

If the conversation resolved part of the issue but leaves follow-up work:

> The primary concern regarding API authentication was resolved through the adoption of OAuth 2.0 ([decision](https://github.com/repo/issues/1#issuecomment-xyz)). However, the team identified a follow-up needed for token rotation, documented in [issue #456](https://github.com/repo/issues/456), which will be addressed in the next quarter.

#### Decisions with Strong Dissent

If a decision was made despite disagreement, acknowledge the dissent and the reasoning that won:

> Although Charlie raised concerns about performance impacts ([comment](https://github.com/repo/issues/1#issuecomment-aaa)), the team proceeded with the redesign because monitoring data showed the current approach degrading at scale ([analysis](https://github.com/repo/issues/1#issuecomment-bbb)).

#### Long-Running Conversations

For issues spanning weeks or months:

- Focus on the final decision and the key pivots that led to it
- Link to major turning points rather than every comment
- Summarize the overall arc in the opening paragraph

#### Ignore Bot Events

Do not include commentary, updates, or event records added by automated bots (e.g., `@github-actions[bot]`, `@dependabot[bot]`) unless they introduced a crucial piece of information that directly influenced the final decision.

## Structure Template

A well-structured GitHub executive summary typically follows this arc:

1. **Opening paragraph**: What was the initial problem or request? What triggered the conversation?
2. **Middle paragraphs**: How did the discussion evolve? What alternatives were considered? What constraints emerged?
3. **Resolution paragraph**: What decision was made? Why? What trade-offs were accepted?
4. **Closing paragraph**: What happens next? Who is responsible? What are the implications?
