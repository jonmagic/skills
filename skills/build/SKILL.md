---
name: build
description: Use when the user asks to build, implement, finish, or make a plan real from a URL, file path, issue, spec, or repository context. Orchestrates end-to-end implementation with clarification, red-green-refactor, validation, risk-gated review, recovery, and final handoff. Do not use for merely compiling or running a build command.
license: ISC
---

# Build

Build turns a URL, local path, issue, plan, specification, or repository task into a finished, usable project or change. It is a conductor skill: the top-level agent owns context, decisions, synthesis, and user communication while invoking narrower skills, tools, and subagents only when they materially improve the result.

## When to Use

Use this skill when the user asks to:

- "build this", "implement this", "finish this", "make this real", or "take this from plan to working project"
- execute a multi-step plan through implementation, validation, review, and polish
- recover from a first pass that failed or became brittle
- produce a project or change ready to use, demo, review, or ship

Do not use this skill for:

- merely running a compiler or build command such as `npm run build`, `xcodebuild`, `make`, or `go build`
- simple one-file edits that are faster through direct tools
- pure research or planning when the user explicitly excludes implementation
- PR creation, PR review, or CI iteration after implementation is already complete
- review-only requests

## Source and Inspiration

This workflow follows the portable [Agent Skills specification](https://agentskills.io/specification), Anthropic's workflow and context-engineering guidance, and OpenAI's manager, guardrail, and evaluation patterns. Load [references/ORCHESTRATION.md](references/ORCHESTRATION.md) when deciding whether to stay narrow, recover, delegate, or fan out.

## Operating Principles

1. **Conductor first.** The top-level session keeps the full context, makes routing decisions, and synthesizes the final result.
2. **Ask only decision-changing questions.** Inspect available context first. If ambiguity remains, ask one focused question with a recommended default.
3. **Use existing capabilities before inventing process.** Compose with matching skills, scripts, tools, and repository workflows when available.
4. **Use red-green-refactor where practical.** Prefer a failing test or measurable acceptance check before implementation, then make it pass, then simplify.
5. **Use one reviewer when risk earns it.** Ordinary clear-path work stays with the top-level driver. High-stakes, hard-to-reverse, or materially ambiguous work gets one bounded reviewer at the highest-leverage stage.
6. **Verify before escalating.** Prefer tests, source inspection, prototypes, and deterministic tools over another model.
7. **Go wide only when warranted.** Compare multiple designs only when credible alternatives have meaningfully different failure modes.
8. **Finish means usable.** Validate the exact user-facing behavior, update related documentation, and leave the project in a ready state.
9. **Keep context intentional.** Give subagents only the context needed for their task, keep secrets and mutable runtime state out of prompts, and require distilled evidence rather than raw dumps.
10. **Treat integrations as capabilities, not assumptions.** If a missing integration supplies only general reasoning or a read-only workflow, use direct tools and disclose reduced confidence. If it controls side effects, privileged access, policy, or specialized checks, report the capability gap instead of pretending to replace it.

## Default Workflow

### 1. Intake the source

Resolve the artifact the user supplied:

- URL: fetch the page or use a domain-specific source tool.
- GitHub issue, PR, or discussion: retrieve the relevant conversation, linked context, and files.
- Local path: inspect the file or directory directly.
- Repository task: read local instructions, tests, README, package manifests, and nearby code.
- Screenshot or UI artifact: inspect the supplied image and identify non-browser verification options.

Extract:

- user goal and non-goals
- acceptance criteria
- target users and UX expectations
- constraints, risks, and dependencies
- existing implementation and prior art
- validation commands and manual verification needs
- commit, release, or handoff expectations

### 2. Clarify only what matters

If context is sufficient, proceed with a stated assumption. Otherwise ask one decision-critical question using structured input when available.

```markdown
**Question:** <one decision that changes implementation>

**Why it matters:** <risk or dependency>

**Recommended default:** <the default and why>
```

Do not ask the user to repeat facts discoverable from files, issues, documentation, or available tools.

### 3. Create a working plan

Prefer three to five executable items:

1. Pin the acceptance criteria.
2. Add or identify a failing test or check.
3. Implement the smallest coherent vertical change.
4. Validate behavior, UX, and regressions.
5. Review, polish, commit, or hand off.

For larger work, use milestones with validation gates rather than a long undifferentiated task list.

### 4. Decide whether independent review is needed

Keep the review gate closed for clear, low-risk work with cheap deterministic validation. Open it only for security, privacy, auth, permissions, data handling, schemas, migrations, production impact, architecture, broad refactors, hard-to-reverse changes, or materially ambiguous behavior.

Choose the highest-leverage stage:

- Review the plan before implementation when the risk is the design, trust boundary, migration path, or rollback strategy.
- Review the result after validation when implementation reveals the material uncertainty and no reviewer was already used for that scope.
- Use a user-interview or plan-stress workflow when the unresolved choice belongs to the user rather than a model critic.
- Prefer a specialist reviewer over a generic reviewer when one directly matches the unresolved risk.

Use one reviewer from a different provider when available. Give it a bounded artifact, ask it to challenge assumptions and material failure modes, and request the smallest safer change. Reuse that reviewer for focused follow-up instead of stacking reviewers.

### Delegation contract

The top-level agent remains the conductor and owns user communication, final synthesis, and readiness claims. Subagents always report back.

Before delegating, load and follow the [delegation checklist](references/ORCHESTRATION.md#delegation-checklist). Do not delegate sequentially dependent work, tightly coupled edits, or parallel changes to the same files.

### 5. Decide whether to stay narrow or go wide

Stay narrow when:

- the implementation path is clear
- an existing repository pattern applies
- the blast radius is low
- one version can be validated cheaply

Go wide when:

- an architecture, API, persistence, security, or UX tradeoff has multiple credible designs
- alternatives have different rollback, consistency, operational, or compatibility risks
- the first implementation failed because an underlying assumption was wrong
- a small prototype can cheaply settle the decision

When going wide:

- define comparison criteria before exploring alternatives
- prefer small prototypes or source-backed analysis over model debate
- use one independent challenger when the remaining uncertainty is judgmental
- use a multi-model adjudication workflow only when the driver and reviewer disagree on a consequential claim that direct verification cannot resolve

### 6. Build with red-green-refactor

For each milestone:

1. **Red:** add or identify the closest failing test, snapshot, assertion, type check, UX check, script, or reproducible manual check.
2. **Green:** implement the smallest complete change satisfying the acceptance criteria.
3. **Refactor:** simplify, remove duplication, align with repository conventions, and delete temporary scaffolding.
4. **Validate:** run the smallest targeted command proving the behavior.
5. **Commit when appropriate:** stage only intended files, inspect the staged list, follow repository commit rules, and verify the resulting commit.

Use direct tools for bounded reads and edits. Use subagents only for independent, high-context, or long-running work that genuinely benefits from a separate context window.

### 7. Compose skills and tools deliberately

When available, use matching capabilities such as:

- dependency review before adding, installing, upgrading, or recommending dependencies
- project-specific UI, setup, accessibility, or settings verification
- plan stress-testing when a user decision blocks implementation
- one specialist review for a material unresolved risk
- PR handoff workflows when implementation is complete and the user wants a pull request

If a missing integration contributes only general reasoning or a read-only workflow, preserve its quality requirement with direct tools and disclose reduced confidence. If it gates external writes, privileged access, required policy, or specialized security or compliance checks, report the gap and do not substitute an improvised workflow.

Prefer trusted local scripts and skills over remote tools when they provide equivalent evidence. Use remote APIs when they are the safest or only complete source of truth.

When the task creates or revises an agent-facing function, MCP server, or tool, prefer clear names and descriptions, strict schemas, arguments the model can determine, and one tool for operations that are always sequential. Do not expose redundant agent tools or ask the model for values deterministic code already knows.

### 8. Validate UX and product behavior

Validate the actual user path when work affects UI, setup, commands, voice or audio, or user-facing copy.

Examples:

- web UI: focused end-to-end or component tests, supplied screenshots, accessibility checks, or a concise manual verification handoff
- CLI: help output, error behavior, success output, and installed-command behavior
- application setup: project build/restart scripts and first-run behavior
- docs/setup: run or safely dry-run documented commands

Browser automation is an optional capability, not a prerequisite. Use it only when the environment authorizes it and the task warrants it. Otherwise use focused tests, supplied screenshots, or a manual verification handoff. Never claim visual or interactive verification that was not performed.

### 9. Review readiness without stacking reviewers

After implementation and validation:

1. Run the top-level readiness pass against acceptance criteria, evidence, rollback, security and privacy, maintainability, and scope.
2. If the review gate is open and no reviewer has been used for this scope, invoke one bounded reviewer matching the unresolved risk.
3. Apply required fixes or record why a finding is not adopted.
4. Re-run validation affected by the fixes.
5. Resolve driver-reviewer disagreement with tests, source inspection, or deterministic tools.
6. Add one adjudicator only when the disagreement is consequential and cannot be verified directly.

When an evaluator feeds an automated gate, request structured output when supported. Keep the rubric small, measurable, and tied to acceptance criteria.

### 10. Final polish and handoff

Before saying the work is done:

- confirm the exact acceptance criteria are satisfied
- confirm no unrelated user changes were reverted
- update documentation when setup, commands, behavior, persistence, or workflow changed
- remove temporary files and debug scaffolding
- check repository status and identify intentional uncommitted work
- commit completed work when the repository or user workflow expects it
- provide the smallest useful final answer

```markdown
**Built:** <what is ready>

<the meaningful change, relevant validation evidence, and any remaining blocker>
```

## Escalation States

Use [references/ORCHESTRATION.md](references/ORCHESTRATION.md) for the routing matrix.

- **Clarification:** a decision cannot be safely inferred.
- **Narrow build:** the path is clear and cheaply verifiable.
- **Wide design:** multiple credible designs have different material tradeoffs.
- **Recovery:** the first pass failed, became brittle, or violated acceptance criteria.
- **Review hardening:** validated work still carries a material unresolved risk.
- **Ready:** the change is validated, polished, documented as needed, and committed or intentionally left uncommitted.

## Safety and Boundaries

**Will:**

- inspect source context before acting
- preserve repository and user instructions
- use measurable acceptance criteria and focused validation
- report missing permissions, tools, evidence, and failed checks directly
- require explicit approval for destructive, financial, credential, permission, or public-posting actions

**Will not:**

- install dependencies without adequate provenance, necessity, version, license, maintenance, and security review
- mutate external systems or publish without explicit approval and the relevant supported workflow
- reveal secrets, credentials, private logs, customer data, or sensitive personal information
- hide failed validation or claim checks that were not performed
- claim ready while required implementation, validation, documentation, review, or commits remain pending

Place approval and validation at the action boundary. When the environment supports tool-level guardrails or resumable approvals, attach them to the tool performing the side effect rather than relying only on an initial or final review.

## Skill Maintenance

Treat changes to this skill as changes to an executable workflow:

1. Define the behavior being improved and the regression being prevented.
2. Add or update representative trigger and behavioral tests.
3. Prefer deterministic checks for observable behavior, then use a bounded rubric for judgment that cannot be checked mechanically.
4. Inspect traces or captured transcripts when available to verify routing, tool use, delegation, and stopping behavior.
5. Record real-world misses as future test cases.

## Example Prompts

```text
Use build on this plan: /path/to/plan.md
```

```text
Build the feature described in https://github.com/org/repo/issues/123 and get it ready for me to use.
```

```text
Take this prototype to finished and verify the user workflow.
```
