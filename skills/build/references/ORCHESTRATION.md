# Build orchestration reference

Use this reference when the `build` skill needs to decide how much orchestration a task deserves.

## External patterns worth preserving

### Progressive-disclosure skills

The Agent Skills specification describes skills as portable folders with a `SKILL.md` file plus optional scripts, references, and assets. Agents discover skills by name and description, then load detailed instructions only when the task matches.

Source: https://agentskills.io/specification

What to borrow:

- keep `build` as a conductor rather than copying every specialist workflow
- link to references only for tuning or edge cases
- compose narrower skills instead of duplicating them

### Anthropic workflow, context, and delegation guidance

Anthropic describes sequential workflows for dependent stages, parallel workflows for independent checks, orchestrator-worker patterns for bounded delegation, and evaluator-optimizer loops for improving an output against clear criteria. Its context-engineering guidance recommends giving each subagent a clear objective, output format, tool or source guidance, and task boundary.

Sources:

- https://www.anthropic.com/engineering/building-effective-agents
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- https://www.anthropic.com/engineering/multi-agent-research-system
- https://claude.com/blog/subagents-in-claude-code

What to borrow:

- default to sequential work because it is easier to reason about
- use parallel work only for independent tasks or perspectives
- define the aggregation strategy before fanning out
- require distilled subagent findings rather than raw context dumps
- stop iterating when the quality bar is met or the loop plateaus

### OpenAI manager, guardrail, and evaluation guidance

OpenAI distinguishes manager-style agents-as-tools from handoffs. `build` uses the manager pattern: specialists return bounded results while the conductor retains the user-facing task and final synthesis. OpenAI also recommends deterministic orchestration where possible, approvals at side-effect boundaries, structured outputs for programmatic gates, and trace-backed evaluations for durable workflows.

Sources:

- https://openai.github.io/openai-agents-python/multi_agent/
- https://openai.github.io/openai-agents-python/guardrails/
- https://openai.github.io/openai-agents-python/human_in_the_loop/
- https://developers.openai.com/blog/eval-skills
- https://developers.openai.com/blog/skills-agents-sdk

What to borrow:

- keep the default tool and agent surface small
- place approval and validation on the action causing the side effect
- use structured evaluator outputs when code consumes the verdict
- evaluate outcome, process, style, and efficiency, including routing as a process check
- add specialists only when their contract materially differs from the conductor's

## Routing matrix

| Task condition | Preferred state | Notes |
| --- | --- | --- |
| Clear plan, low blast radius | Narrow build | Direct tools, red-green-refactor, targeted validation |
| Fuzzy plan with decision-changing ambiguity | Clarification | Ask one question with a recommended default |
| Multiple credible designs with material tradeoffs | Wide design | Prefer prototypes or source-backed comparison |
| First pass fails or becomes brittle | Recovery | Identify the failed assumption instead of patching symptoms |
| Security, auth, permissions, persistence, migrations, or data handling | Review hardening | Select one reviewer for the unresolved risk |
| UI, setup, voice, audio, or CLI UX | UX validation | Validate the real user path or provide a manual handoff |
| Ready to ship, review, or use | Ready | Documentation updated and status clean or intentionally explained |

## Delegation checklist

Before launching a subagent, state:

1. **Objective:** one bounded result the subagent owns.
2. **Context:** only the files, decisions, and evidence needed for that result.
3. **Sources and tools:** what it may inspect or execute.
4. **Output contract:** concise findings, evidence, changed files, commands, and unresolved risks as applicable.
5. **Boundaries:** prohibited side effects, unrelated edits, secrets, and raw context dumps.

Avoid delegation when work is sequentially dependent, requires repeated coordination between agents, or would put multiple agents in the same files. Broad exploration across roughly ten or more files or three or more independent workstreams can justify delegation, but these are heuristics rather than automatic triggers.

## Reviewer selection

Use at most one reviewer for a decision or artifact scope:

- use an independent different-provider reviewer for ambiguous plans, architecture, rollback, or broad-blast-radius reasoning
- use a code reviewer for a concrete diff when correctness or logic is unresolved
- use a security specialist when the user explicitly requests exploitability-focused security review
- use a principal-engineer review posture when the user explicitly requests it
- reuse fresh same-scope review evidence rather than launching another reviewer

```text
Critique this bounded plan or completed artifact. Challenge assumptions, missing constraints, correctness or safety risks, validation gaps, rollback risk, and overbuilding. Raise only issues that materially change readiness, and recommend the smallest safer change.
```

Use a plan-stress workflow instead when the blocker is a user decision rather than model critique.

## Conditional adjudication

When the driver and reviewer disagree:

1. Name the exact disputed claim and why it matters.
2. Use tests, source inspection, prototypes, calculations, or authoritative documentation to verify it.
3. Stop if direct evidence resolves the question or the disagreement is not consequential.
4. If the claim remains unresolved and affects correctness, safety, reversibility, user impact, or a committed architecture decision, invoke one third-provider adjudicator.
5. Give the adjudicator the original question, relevant context, both positions, and the disputed claim. Do not request another broad review.

Honor an explicit request for all three providers as a deliberate override.

## Stop criteria

Stop and ask the user before continuing when:

- the next action would publish or mutate an external system without prior approval
- credentials, MFA, billing, permissions, or destructive actions are involved
- two plausible interpretations would produce materially different user-facing behavior
- validation requires unavailable access or tools and no safe substitute exists
- continuing requires a dependency that cannot be adequately reviewed

Stop and report a blocker when:

- required source context is inaccessible
- tests or builds fail for unrelated reasons that cannot be isolated
- implementation conflicts with explicit user or repository constraints
- review finds a serious issue that cannot be fixed without a scope decision
