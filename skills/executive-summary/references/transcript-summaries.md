# Meeting Transcript Executive Summaries

This reference details the specific rules and patterns for synthesizing executive summaries from meeting transcripts (Zoom, Teams, Google Meet, etc.).

## Guiding Rules

### 1. Concise, Informative Title

Begin with a **clear, succinct h2 markdown title** that encapsulates the meeting's main topic or central decision. The title should immediately set context and importance. For example:

- `## Q4 Product Roadmap Planning Session`
- `## Budget Review and Resource Allocation for Engineering`
- `## Post-Mortem: Incident Response for Database Outage`

### 2. Narrative Structure

Present the summary as **3–5 dense, logically-connected paragraphs** in formal, authoritative tone. Avoid bullet points, subheaders, or lists. Each paragraph should:

- Build on the previous one
- Convey the meeting's arc: from opening context → key discussions → decisions/outcomes → next steps
- Use complete, well-structured sentences

### 3. Attribution by Participant Name

- Attribute all statements and viewpoints directly to **named participants**
- Use first names or full names (whichever is appropriate for your organization)
- Do not use markdown link formatting for names; they appear as plain text
- Paraphrase and synthesize rather than quote verbatim

Examples:
> Alice outlined the current performance metrics, noting a 15% decline in Q3.
>
> Bob proposed accelerating the timeline, while Carol expressed concerns about resource constraints.

### 4. Reference Shared Documents and Screens

If the meeting referenced slides, documents, recordings, or shared screens:

- Note what was shared and its relevance
- Reference by title or description if possible
- Link to any documents if they are accessible (e.g., Confluence pages, Google Docs)

Example:
> The team reviewed the [proposal deck](https://example.com/proposal) that outlined three implementation scenarios. Alice highlighted the cost implications of each scenario, which became the basis for the final recommendation.

### 5. Focus on Meaningful Content

**Include:**
- Major decisions and the reasoning behind them
- Key debates and points of disagreement (if they shaped the outcome)
- Alternatives discussed and why they were rejected
- Action items, owners, and deadlines
- Business or user impact of decisions
- Constraints or risks identified

**Exclude:**
- Routine pleasantries or opening/closing remarks ("Thanks everyone for joining")
- Procedural matters ("Let's use this link for next week")
- Transcript technical notes (inaudible, connection issues)
- Small talk or off-topic discussions
- Exact timestamps or durations

### 6. Summarize Decisions, Alternatives, and Next Steps

Clearly articulate:

- **What was decided**: Be explicit about commitments, approvals, or resolutions
- **Why that decision**: What factors (data, constraints, risks) influenced it?
- **Alternatives considered**: What other options were discussed and why were they not chosen?
- **Next steps**: Who owns what actions? What are the deadlines?

Example:
> The team decided to proceed with a phased rollout over three quarters rather than a single launch. Sarah favored the phased approach to mitigate customer disruption, while Marcus noted that a faster timeline could improve time-to-market. The phased approach was chosen to balance these concerns. Carol will own the rollout plan and present it at the next steering committee meeting.

### 7. Formal Tone and Professional Voice

- Use complete sentences and formal language
- Avoid contractions (don't → do not)
- Write for educated, time-constrained readers (leaders, decision-makers)
- Integrate references seamlessly
- Avoid editorial asides or opinions not attributed to a meeting participant

### 8. Handling Special Cases

#### Disputed Decisions

If participants disagreed but a decision was made:

> Although Alice expressed concern about the timeline ([noting resource limitations](timestamp/reference)), the team agreed to proceed with the accelerated schedule. Bob confirmed that additional budget would be available to support the effort.

#### Action Items and Owners

Clearly attribute ownership:

> Carol agreed to revise the implementation plan by December 31st and share it with the team for feedback. Marcus will coordinate with the legal team regarding compliance requirements.

#### Deferred Decisions

If a decision was postponed or requires further information:

> The team deferred the decision on vendor selection pending a cost-benefit analysis, which Alice will complete by December 20th.

#### Meeting Context (Recurring vs. One-Time)

If context matters:

> In this monthly product sync, the team reviewed progress against Q4 goals and identified three areas requiring additional focus.

## Structure Template

A well-structured transcript executive summary typically follows this arc:

1. **Opening paragraph**: What is the meeting about? Why did it happen now? Who attended (if relevant)?
2. **Middle paragraphs**: What were the key topics discussed? What trade-offs or debates emerged? What data or analysis informed thinking?
3. **Decision paragraph**: What were the key decisions? Why were they made? What alternatives were considered?
4. **Closing paragraph**: What happens next? Who owns what? What are deadlines? What are the implications or risks?

## Tips for Transcripts

- **Parse for speakers early**: Extract speaker names and their roles to ensure consistent attribution throughout
- **Identify the throughline**: What is the meeting really about? Lead with that in the title
- **Watch for tentative vs. firm language**: Distinguish between "We will do X" (decision) and "We might explore Y" (exploration)
- **Synthesize rather than summarize**: Don't repeat every point; highlight what moved the conversation forward
- **Note tone shifts**: If the conversation moved from uncertain to confident, or vice versa, that's worth capturing
