---
name: roundtable
description: Run an explicitly requested multi-model review or adjudicate a consequential disagreement between a driver and reviewer. Uses one different-provider reviewer by default and a third provider only when direct verification cannot resolve the dispute. Not for routine ambiguity or fleet mode.
---

# Roundtable

Roundtable is a bounded multi-model review protocol. The top-level CLI session remains the driver, produces a provisional recommendation, and owns the final synthesis. One model from a different provider challenges that recommendation. A third provider is an adjudicator only when the disagreement is consequential and tests, source inspection, prototypes, or other direct evidence cannot resolve it.

This is not fleet mode. Fleet mode is the exceptional all-provider workflow for explicitly requested, contested, and irreversible decisions.

## When to Use

Use this skill when the user explicitly asks for:

- a roundtable
- multiple model opinions or perspectives
- another provider to challenge a recommendation
- adjudication after two models disagree

Do not activate this skill merely because a question involves architecture, API design, strategy, planning, investigation framing, or an ambiguous tradeoff. The top-level driver should handle those questions directly unless the user asks for multi-model review or a consequential driver/reviewer disagreement remains unresolved.

Do not use this skill for:

- fleet mode
- simple fact lookups
- routine code edits
- file searches
- running queries
- formatting or mechanical changes
- tasks where direct tools can answer the disputed question
- tasks that require live tool loops from every model

If the prompt is really a tool-use task or factual lookup, say that roundtable is unnecessary and proceed with the direct workflow.

## Provider Selection

Read the live model list from the `task` tool. Do not hard-code model IDs because they go stale.

1. Keep the top-level session as the driver.
2. Choose the strongest suitable reviewer from a different provider.
3. If adjudication is required, choose the strongest suitable model from a third provider.
4. Avoid narrow coding, mini, flash, or picker variants unless the task specifically benefits from them.
5. State the actual model IDs used in the synthesis.

If the user names a lineup, use it when available. If a requested model is unavailable, omit it and state that directly. Never silently substitute a requested provider.

If the environment cannot enumerate or select another provider, state the capability gap instead of fabricating a review. Ask the user to name an available reviewer only when the environment requires manual model selection.

## Step 1 - Driver Recommendation

The top-level session gathers the relevant evidence and writes a provisional recommendation before invoking another model.

Keep it concise:

```text
RECOMMENDATION:
<one sentence>

REASONING:
<the smallest evidence-backed explanation>

MATERIAL UNCERTAINTY:
<the claim or assumption most worth challenging>
```

Do not present the provisional recommendation to the user as settled.

## Step 2 - Independent Reviewer

Spawn one reviewer from a different provider with the bounded prompt:

```text
You are the independent reviewer for a multi-model decision. Challenge the driver's recommendation rather than producing a broad second essay.

USER QUESTION:
<verbatim user prompt>

CONTEXT:
<minimal relevant context>

DRIVER RECOMMENDATION:
<driver recommendation and reasoning>

INSTRUCTIONS:
1. State whether you agree or disagree with the recommendation.
2. Identify the strongest material failure mode, missing assumption, or counterexample.
3. Name the exact claim that would need verification to settle any disagreement.
4. Recommend the smallest correction if one is needed.
5. Keep the response under 300 words.
```

Do not launch several reviewers. If clarification is needed, send a focused follow-up to the same reviewer when possible.

## Step 3 - Resolve Disagreement Directly

Compare the driver and reviewer.

Stop without another model when:

- they agree on the recommendation,
- the disagreement does not affect the decision,
- the disputed claim can be resolved with tests, source inspection, prototypes, calculations, or authoritative documentation,
- or the available evidence already favors one position.

Use direct tools to verify checkable claims. Record the evidence that resolved the disagreement.

## Step 4 - Conditional Adjudicator

Invoke one third-provider adjudicator only when all of the following are true:

1. The driver and reviewer disagree.
2. The disagreement affects correctness, safety, reversibility, user impact, or a committed architecture decision.
3. Direct verification cannot resolve the disputed claim.

Use this bounded prompt:

```text
You are adjudicating one unresolved disagreement. Decide the disputed claim from the supplied evidence. Do not restart the whole analysis.

USER QUESTION:
<verbatim user prompt>

CONTEXT:
<minimal relevant context>

DRIVER POSITION:
<driver recommendation>

REVIEWER POSITION:
<reviewer critique>

DISPUTED CLAIM:
<one concrete claim>

INSTRUCTIONS:
1. Decide which position is better supported, or state that the evidence is insufficient.
2. Explain the deciding reason in no more than 200 words.
3. Name the evidence or assumption that would reverse the decision.
```

The adjudicator is not a third vote in a popularity contest. Its job is to resolve the named dispute or state that the evidence remains insufficient.

## Synthesis Format

Use this structure:

```markdown
## Recommendation
<one to three sentences with the final recommendation and confidence>

## Driver
**<model ID>**: <provisional position>

## Independent review
**<model ID>**: <strongest challenge and whether it changed the recommendation>

## Resolution
<direct evidence that settled the disagreement, or why direct verification was unavailable>

## Adjudication
**<model ID or "Not needed">**: <decision on the disputed claim>

## Dissent worth keeping
<remaining minority concern, or "None">

## Assumptions that would change the answer
- <assumption>
```

Keep the synthesis under roughly 400 words unless the user asks for depth. Do not dump full model transcripts by default.

## Relationship to Fleet Mode

Roundtable uses one reviewer and, only when necessary, one adjudicator. Fleet mode uses one model per major provider from the start. Route explicit requests for all three providers, a full panel, or fleet mode to that workflow.

## Gotchas

- Explicit multi-model wording is required for discovery; ordinary ambiguity stays with the top-level driver.
- Prefer direct verification over adjudication.
- Do not treat minor stylistic disagreement as consequential.
- Do not run a critique round for every model.
- Do not broaden this skill into adjacent workflows just because the topic sounds related.
- Preserve the user's communication and git hygiene preferences when drafting, committing, posting, or saving artifacts.

## Examples

Should trigger:

- "run a roundtable on this architecture tradeoff"
- "get another provider to challenge this recommendation"
- "two models disagree and I want a third provider to adjudicate"

Should not trigger:

- "ask all three providers and synthesize the result"
- "which architecture would you choose?"
- "investigate why this test is failing"
- "make a quick one-model wording edit"
