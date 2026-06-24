---
name: plan-stress-test
description: Stress-test plans, designs, proposals, and implementation strategies by interviewing the user one decision at a time. Use when the user says "stress test this", "interview me", "improve this plan", "challenge this plan", "poke holes in this", or wants plan refinement.
---

# Plan Stress Test

## Overview

Use this skill to turn a fuzzy plan into a crisp, executable direction by interrogating assumptions, dependencies, edge cases, and tradeoffs. Be direct, curious, and constructive. The goal is shared understanding and a better plan, not performative criticism.

## When to Use

Use this skill when the user wants to:

- Stress-test a plan, design, proposal, roadmap, implementation approach, or written strategy.
- Be interviewed about an idea until the decision tree is resolved.
- Improve a plan before execution, delegation, review, or publication.
- Challenge assumptions, uncover risks, or find missing constraints.

Do not use this skill for routine implementation unless the user is explicitly asking to refine or pressure-test the plan first.

## Operating Principles

1. Start with the highest-risk ambiguity, not the easiest question.
2. Ask one question at a time.
3. For every question, include your recommended answer or default.
4. If the answer can be found by inspecting available context, files, notes, issues, or code, do that instead of asking.
5. Resolve dependencies between decisions before moving to downstream details.
6. Stop when the remaining questions are low-value, the plan is coherent enough to execute, or the user asks to stop.

## Workflow

1. **Establish the object under review.** Identify the plan, design, proposal, or decision being stress-tested. If the user has not provided enough material, ask for the minimum missing artifact.
2. **Load discoverable context.** Inspect relevant files, notes, threads, or code before asking factual questions. Do not ask the user to restate information that available tools can answer.
3. **Map the decision tree.** Identify goals, constraints, stakeholders, assumptions, dependencies, success criteria, failure modes, reversibility, and execution risks.
4. **Ask one decision-critical question.** Use the question format below. Prefer the question that would most change the plan if answered differently.
5. **Update the working understanding.** After each answer, incorporate the decision and choose the next unresolved branch.
6. **Validate before side effects.** If the stress test leads to writing files, creating issues, sending messages, deploying, or changing state, pause for explicit user confirmation unless the user already asked for that action.
7. **Finish with a concise synthesis.** Summarize the refined plan, decisions made, unresolved questions, key risks, mitigations, and recommended next action.

## Question Format

When asking the user, use the structured input tool if available. Keep the prompt focused on one decision:

```markdown
**Question:** <one decision-critical question>

**Why it matters:** <brief explanation of the dependency or risk>

**My recommended answer:** <your proposed answer/default and why>
```

If useful, present a small set of answer choices. Avoid long multi-question forms; this skill works by resolving one branch at a time.

## Anchoring Guidance

When the plan includes agent behavior, automation, or other side effects, separate fuzzy decisions from deterministic actions:

- **Fuzzy:** classify, summarize, infer intent, recommend, draft, prioritize.
- **Deterministic:** write files, call APIs, create issues, send notifications, merge, deploy, mutate state.

For any deterministic action, define the input contract, expected output shape, validation checks, allowlists, and failure behavior. Treat AI-generated decisions as untrusted until validated. For high-blast-radius actions, require an explicit human approval gate.

## Edge Cases

- If the user asks for a quick critique instead of an interview, provide the critique and ask whether they want the full stress test.
- If the plan is too vague to evaluate, ask for the smallest artifact that would make it reviewable.
- If the user is blocked on naming or framing, propose 3-5 options and recommend one.
- If the user becomes repetitive or the same decision loops, name the unresolved tradeoff and recommend a default.
- If the plan conflicts with available evidence, show the evidence and ask whether to update the plan or treat it as an exception.

## Anti-Patterns

- Do not ask rapid-fire lists of questions.
- Do not ask questions whose answers can be discovered with available tools.
- Do not continue interviewing after the marginal value drops.
- Do not make unilateral scope, behavior, or side-effect changes during the stress test.
- Do not frame feedback as a takedown; keep it rigorous, practical, and oriented toward a better outcome.

## Example Prompts

```text
Stress test this implementation plan before I hand it to the team.
```

```text
Interview me about this proposal until the weak spots are clear.
```

```text
Improve this plan and challenge my assumptions one decision at a time.
```

```text
Poke holes in this design, but recommend defaults as we go.
```

## Source Expertise

This skill is grounded in its existing workflow instructions and conventions. It captures the reusable workflow for interviewing the user to challenge and refine plans, proposals, and implementation strategies.

No extra reference file is required by default; load source files only when the task needs that context.

## Anchored Workflow

### Deterministic prefix

1. Confirm the user's request matches this skill's scope: interviewing the user to challenge and refine plans, proposals, and implementation strategies.
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
- If validation cannot run, say so directly and do not claim the side effect is complete.

## Tool and Action Safety

- Do not perform destructive, externally visible, or hard-to-reverse actions without explicit approval.
- Do not expose private or sensitive data beyond what the user asked to use.
- Do not silently skip failed tool calls, missing permissions, ambiguous identifiers, or empty result sets.
- No bundled script is required by default.

## Gotchas

- The skill is interactive; do not dump a giant critique before collecting the next key decision.
- Do not broaden this skill into adjacent workflows just because the topic sounds related.
- Preserve the user's communication and git hygiene preferences when drafting, committing, posting, or saving artifacts.

## Examples

Should trigger:

- "stress test this implementation plan one decision at a time"

Should not trigger:

- "implement the plan without asking any questions"
