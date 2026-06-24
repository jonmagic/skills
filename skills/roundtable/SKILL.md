---
name: roundtable
description: Run a multi-model roundtable for architecture decisions, ambiguous tradeoffs, strategy questions, investigation framing, or when the user asks for multiple model perspectives. Fans prompts out to several models, critiques disagreement, and synthesizes consensus plus dissent. Not for fleet mode.
---

# Roundtable

Roundtable is a reusable moderation protocol for getting several independent model perspectives on the same prompt, then synthesizing useful agreement, disagreement, dissent, and flip-point assumptions.

The top-level CLI session remains the moderator. The moderator decides whether the prompt is worth the extra latency and cost, fans the prompt out to panelists, evaluates whether disagreement is substantive, and produces the final synthesis. Do not use this skill as fleet mode; fleet mode is a separate workflow for highest-stakes consensus building across provider representatives.

## When to Use

Use this skill when the user asks for:

- "roundtable"
- "multiple model opinions"
- "multiple perspectives"
- "get a few models to weigh in"
- architecture or API design tradeoffs
- ambiguous strategy or planning questions
- investigation framing where the right hypothesis is unclear
- comparative judgment calls where disagreement is useful

Do not use this skill for:

- fleet mode
- simple fact lookups
- routine code edits
- file searches
- running queries
- formatting or mechanical changes
- tasks where direct tool use is faster
- tasks that require live tool loops from each panelist

If the prompt is really a tool-use task or factual lookup, say that roundtable is the wrong shape and proceed with the default direct workflow.

## Default Panel

Use real model IDs exposed by the current CLI tooling, not display names from another client.

Default three-model panel:

1. `gpt-5.5`
2. `claude-opus-4.8`
3. `gemini-3.1-pro-preview`

Optional fourth panelist when a fourth perspective is clearly useful:

4. `claude-sonnet-4.6`

If the user names a different lineup, use theirs when available. If a requested model is unavailable, omit it and state that in the synthesis. Never silently substitute models.

## Moderator Rules

- Do not answer the user's question directly before running the panel.
- Use the same prompt and context for every Round 1 panelist.
- Keep context minimal and identical across panelists.
- Prefer read-only subagents for panelists.
- Run panelists in parallel when tooling supports it.
- Do not fabricate panelist responses.
- If a panelist fails, say that it did not respond.
- Do not treat the moderator as an additional vote.
- If adding a moderator view, label it `Moderator note:`.
- Do not dump full transcripts by default; provide them only if the user asks.
- Keep the final synthesis concise unless the user explicitly asks for depth.

## Round 1 - Independent Answers

Spawn one subagent per panelist with the same prompt.

Use this template:

```text
You are participating in a roundtable of LLMs answering the same question independently. Do not assume what other models will say. Answer in your own voice.

USER QUESTION:
<verbatim user prompt>

CONTEXT:
<minimal relevant context, identical across panelists>

INSTRUCTIONS:
1. Answer the question directly and concretely.
2. State your top recommendation in one sentence at the top.
3. Then give your reasoning in <= 300 words.
4. List the strongest counterargument to your own position in 1-2 sentences.
5. List 1-3 assumptions you made that, if wrong, would flip your answer.

Do not hedge. Do not include disclaimers. Do not ask clarifying questions back. Pick the most plausible interpretation and proceed.
```

## Round 2 - Critique

Run this round only when Round 1 produced substantive disagreement, such as different top recommendations or the same recommendation with conflicting reasoning.

For each responding panelist, spawn a critique pass with the same model:

```text
You previously answered the following question in a roundtable:

USER QUESTION:
<verbatim user prompt>

YOUR PRIOR ANSWER:
<that panelist's Round 1 output>

OTHER PANELISTS' ANSWERS:
<concatenated Round 1 outputs from the other models, labeled by model name>

INSTRUCTIONS:
1. Identify the strongest point any other panelist made that you did not consider.
2. State whether it changes your recommendation. If yes, give the revised recommendation. If no, explain concisely why.
3. Identify the weakest claim in another panelist's answer and explain the flaw in 1-2 sentences.
4. Keep total response under 250 words.
```

Skip Round 2 when the panel converges. Unanimous or near-unanimous agreement is useful signal; do not add critique latency unless it changes the decision quality.

## Synthesis Format

Use this structure for the final answer:

```markdown
## Recommendation
<one to three sentences with the synthesized answer. If the panel converged, state the consensus. If they split, state the moderator's call and why.>

## How the panel voted
- **<Model A>**: <one-line position>
- **<Model B>**: <one-line position>
- **<Model C>**: <one-line position>

## Where they agreed
- <shared point>

## Where they disagreed
- <genuine disagreement and which panelists were on each side>

## Dissent worth keeping
<minority opinion the moderator thinks the user should not dismiss, or "None" if there was no meaningful dissent.>

## Assumptions that would flip the answer
- <deduped assumption>
```

Keep the synthesis under roughly 400 words unless the user asks for depth.

## Example Prompts

- "Use the roundtable skill to evaluate this architecture choice."
- "Get multiple model perspectives on whether this migration plan is sound."
- "Run a roundtable on the investigation framing for this ambiguous incident."
- "I want a roundtable, not fleet mode, on this API design tradeoff."

## Relationship to Fleet Mode

Roundtable is not fleet mode.

Use roundtable for ordinary multi-model perspective gathering where disagreement is helpful but the decision is not necessarily highest-stakes. Use fleet mode only when the user explicitly asks for it or when the decision is contested, irreversible, or high-stakes enough to warrant one representative from each major provider.

## Source Expertise

This skill is grounded in its existing workflow instructions and conventions. It captures the reusable workflow for multi-model roundtables for ambiguous architecture, strategy, tradeoff, or investigation decisions.

No extra reference file is required by default; load source files only when the task needs that context.

## Anchored Workflow

### Deterministic prefix

1. Confirm the user's request matches this skill's scope: multi-model roundtables for ambiguous architecture, strategy, tradeoff, or investigation decisions.
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
- No bundled script is required by default.

## Gotchas

- Roundtable is for contested or ambiguous decisions, not routine work that a single agent can do.
- Do not broaden this skill into adjacent workflows just because the topic sounds related.
- Preserve the user's communication and git hygiene preferences when drafting, committing, posting, or saving artifacts.

## Examples

Should trigger:

- "run a roundtable on this architecture tradeoff"

Should not trigger:

- "make a quick one-model wording edit"

## Evaluation Plan

Use `evals/evals.json` for task-quality checks and `evals/trigger-queries.json` for activation checks. Compare outputs with and without this skill; the skill should improve trigger precision, context loading, output structure, validation, and safety boundaries for multi-model roundtables for ambiguous architecture, strategy, tradeoff, or investigation decisions.
