---
name: principal-engineer-review
description: Reviews PRs, local diffs, and code-adjacent design changes from a principal engineer standpoint. Use for high-signal review, MVP scope control, maintainability, security-aware review, reuse of existing primitives, avoiding premature optimization, and deciding what must change before merge. When a review turns into architecture/API/platform design and named laws would sharpen the critique, compose with software-design-laws as an optional lens.
---

# Principal Engineer Review

Review a pull request or local code changes through a principal engineer lens: solve the business problem with the smallest responsible change, preserve long-term maintainability, avoid security regressions, reuse existing primitives, and do not optimize or abstract before the pattern earns it.

This skill is context infrastructure, not just a checklist. When a review finds repeated misses, invisible context, missing validation, or vague "use good judgment" expectations, treat that as a signal to make the relevant knowledge durable through tests, docs, instructions, examples, scripts, or skills.

Treat visible reasoning as part of the work, especially for agent-assisted changes. A diff can look complete before the author has shown why the change exists, why this approach is safe, what alternatives were rejected, what validation is trusted, what remains uncertain, and what future reviewers should not have to rediscover.

## When to Use

Use this skill when the user asks for a PR review, asks whether a change is the right shape, wants a principal engineer perspective, or asks for critique before shipping.

Also use it when a change touches production behavior, auth, permissions, data handling, persistence, APIs, schemas, migrations, cost, reliability, or cross-service boundaries.

Do not use this for PR body writing or review-comment follow-up unless that is part of the request; use `pr-handoff` for PR preparation and review-response workflow.

## Compose With Existing Review Tools

Leverage existing review capabilities instead of duplicating them:

1. Use the built-in code review path (`/review` in Copilot CLI, or the equivalent code-review agent when operating through tools) to get the baseline diff review.
2. Use the built-in security review path (`/security-review` in Copilot CLI, or the equivalent security-review agent when operating through tools) for security-sensitive changes or when the user asks for security review.
3. Use `pr-handoff` when preparing a branch for PR, writing or updating the PR body, handling review comments, or deciding whether the branch is ready for review.
4. Use a voice/style skill when drafting GitHub, chat, or email text in the user's voice, including review comments that need to sound like them.
5. Use an opposite-provider rubber-duck review for high-stakes, ambiguous, security-sensitive, architecture-heavy, or broad-blast-radius changes before treating the conclusion as settled.
6. Use `software-design-laws` only as an optional lens when a review hinges on architecture, API compatibility, platform abstraction, service/team boundaries, or the user asks for named laws such as Hyrum's Law, Conway's Law, YAGNI, or Gall's Law. Do not turn ordinary PR reviews into law-catalog writeups.

This skill owns the synthesis layer: decide what matters, filter noise, reconcile tool findings, and explain the business, maintainability, security, and judgment tradeoffs.

## Relationship to Software Design Laws

`principal-engineer-review` remains the primary skill for code review, PR readiness, MVP scope, maintainability, and material risk triage. `software-design-laws` is a narrower citation-backed design lens.

Use the law lens when it changes the review:

1. The change exposes or changes a public API, service boundary, compatibility contract, platform abstraction, or team ownership boundary.
2. The user's question mentions a named law or asks for architecture/design principles.
3. A law would produce a concrete review question, risk, or adjustment, not just a clever label.

Keep the final review grounded in the diff and business problem. If a law applies, use one short sentence or question in the review finding unless the user asked for a full laws-based critique.

## Review Posture

Be direct, specific, evidence-based, and context-dependent. Optimize for the smallest set of comments that would materially improve the change. Do not comment on style, formatting, naming, or theoretical improvements unless they affect correctness, security, maintainability, or the business outcome.

Push back on unnecessary scope with concrete questions:

1. What business problem does this solve now?
2. What is the smallest safe version?
3. What can be follow-up once the pattern proves itself?
4. What existing primitive already solves this?

Prefer plain, concrete, question-led feedback when appropriate. Avoid memo-shaped abstractions, overclaiming, and turning a concern into a broad thesis when a direct comment would do.

## Review Workflow

1. Understand the business problem and intended user impact before judging the implementation.
2. Inspect the diff and relevant surrounding code, including tests, existing helpers, feature flags, configs, migrations, and call sites.
3. Look for existing helpers, policies, schemas, jobs, patterns, and owners before accepting new helpers, services, dependencies, queues, storage, or abstractions.
4. After reading the diff and surrounding code, check whether the PR or handoff makes enough reasoning visible to review: why this change, why this approach, what alternatives were rejected, what validation is trusted, what is still uncertain, and what the next person should not have to rediscover. Do not require transcript dumps or polished essays; require enough reasoning to let reviewers challenge the right thing.
5. Check whether the implementation is the minimum viable code that solves the problem safely.
6. Evaluate long-term maintenance: future readability, clear ownership, obvious rollback, testable boundaries, hidden coupling, and whether future teams will have to support abstractions created prematurely.
7. Evaluate security and privacy: authorization before data access, tenant boundaries, customer data exposure, unsafe logging, secret handling, injection paths, dependency risk, and success-shaped fallbacks.
8. Evaluate reliability and operations: idempotency, retries, timeouts, resource usage, migrations, partial failure, deploy order, monitoring, and rollback.
9. Evaluate whether the change is over-optimized: premature generalization, speculative extension points, caching without evidence, batching without need, complex config, or abstractions built for imagined future cases.
10. Decide whether each concern is blocking, should be fixed before merge, can be documented as a follow-up, or should be ignored.
11. If a miss reveals invisible context, identify the durable artifact that would prevent the same miss next time.

## Comment Quality Bar

Only raise comments that meet at least one of these bars:

1. The change can ship the wrong behavior, break an important path, or make rollback difficult.
2. The change introduces a credible security, privacy, compliance, or data-integrity risk.
3. The change duplicates or bypasses an existing primitive in a way that will create drift.
4. The change adds scope, abstraction, dependency, or optimization that is not needed for the business problem.
5. The change makes future maintenance materially harder without a clear tradeoff.
6. The tests miss a meaningful edge case tied to the changed behavior.

Blocking comments should generally be limited to correctness, security/privacy, auth, data integrity, operational risk, or scope that materially increases maintenance without solving the business problem.

Do not leave "consider..." comments unless the consideration has a concrete consequence. If the issue is real, say what can fail and what simpler or safer shape would address it.

## Visible Reasoning Bar

Use this bar when PRs or local changes appear finished but the reasoning is thin. Missing reasoning is not automatically blocking; it becomes blocking when reviewers cannot evaluate correctness, safety, rollback, or scope without reconstructing the author's thought process from the diff.

Ask for the smallest useful explanation:

1. Why does this change exist now?
2. Why this approach instead of the obvious alternatives?
3. What validation is trusted, and what did it prove?
4. What is least certain or intentionally left as follow-up?
5. What should the next person not have to rediscover?

Good review feedback should make the hidden thinking visible without creating process theater. Prefer "I cannot tell whether this handles popup blocking because the PR only says tests pass; please add the browser behavior you validated or a focused test" over "add more context."

## Output Format

Lead with the review decision:

```markdown
**Decision:** Needs changes before merge.

**Blocking**
1. `path/file.ext:123` - The authorization check happens after the lookup, which means a user can distinguish private resource IDs by response shape. Move the permission check before returning not-found vs forbidden, or reuse `ExistingPolicy.check` which already preserves that boundary.

**Non-blocking**
1. `path/other.ext:45` - This helper duplicates `normalizeAccountId`. Reusing the existing helper would reduce drift, but this can be follow-up if the current behavior is intentionally different.

**What looks right**
The change keeps the data model unchanged and avoids introducing a worker for a synchronous path, which seems like the right MVP scope.
```

Use these headings only when they help. For small reviews, a short paragraph with one or two findings is better than a padded template.

When composing findings from `/review`, `/security-review`, or subagents, do not forward raw tool output. Re-rank findings by principal-engineer impact, drop low-signal items, and call out disagreements or uncertainty plainly.

## Principal Engineer Checklist

Ask these questions while reviewing:

1. Does this solve the business problem, or did it solve a larger imagined problem?
2. What is the smallest safe version of this change?
3. What existing primitive, pattern, or owner should this reuse?
4. What behavior becomes harder to change six months from now?
5. What failure mode would surprise on-call?
6. What could expose customer data, bypass auth, leak secrets, or create tenant confusion?
7. What assumption should be proven by a test instead of a comment?
8. What is optimized without evidence that it is the bottleneck?
9. What should be a follow-up instead of part of this PR?
10. If this shipped today, what would make us regret it?
11. What reasoning is missing that would make this review depend on guessing instead of evidence?

## Durable Context Loop

When a review surfaces repeated misses or hidden organizational knowledge, recommend the smallest durable improvement:

1. A focused test for behavior the agent or author missed.
2. A short instruction in the relevant `AGENTS.md`, `.github/copilot-instructions.md`, or skill.
3. A reusable helper or existing primitive adoption when duplication caused the miss.
4. A short decision note when the tradeoff is likely to be revisited.
5. A script or validation check only when the failure is mechanical and likely to repeat.
6. A PR-description or handoff prompt that captures why, approach, validation, uncertainty, and rediscovery notes when agent-assisted work repeatedly arrives with finished-looking output but incomplete thinking.

Do not turn every review finding into process. Only propose durable context when the same miss is likely to recur or when the missing context is important enough that future humans and agents should not have to rediscover it.

## Skill Design Notes

Keep this skill lean and composable. The frontmatter description should remain discovery-focused, and detailed repository-specific review rules should live in local instructions or narrower skills. Prefer invoking existing skills and tools over copying their behavior here.

## Example Prompts

- "Use principal-engineer-review on this PR."
- "Review this branch from a principal engineer standpoint."
- "Look at this diff and tell me where we're overbuilding."
- "Does this PR reuse the right primitives, or are we inventing too much?"
- "Review this for MVP scope, maintainability, and security risk."

## Source Expertise

This skill is grounded in its existing workflow instructions and common principal-engineer review practices. It captures the reusable workflow for principal-engineer code review focused on correctness, security, data integrity, operational risk, and MVP scope.

No extra reference file is required by default; load source files only when the task needs that context.

## Anchored Workflow

### Deterministic prefix

1. Confirm the user's request matches this skill's scope: principal-engineer code review focused on correctness, security, data integrity, operational risk, and MVP scope.
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
- Do not expose private notes, chat, email, GitHub, telemetry, or customer-sensitive data beyond what the user asked to use.
- Do not silently skip failed tool calls, missing permissions, ambiguous identifiers, or empty result sets.
- No bundled script is required by default.

## Gotchas

- Do not create noise with style nits; block only on meaningful correctness, safety, or scope issues.
- Do not broaden this skill into adjacent workflows just because the topic sounds related.
- Preserve the user's communication and git hygiene preferences when drafting, committing, posting, or saving artifacts.

## Examples

Should trigger:

- "review these changes like a principal engineer and only flag material issues"

Should not trigger:

- "format this file and fix trivial style nits"

## Evaluation Plan

Use `evals/evals.json` for task-quality checks and `evals/trigger-queries.json` for activation checks. Compare outputs with and without this skill; the skill should improve trigger precision, context loading, output structure, validation, and safety boundaries for principal-engineer code review focused on correctness, security, data integrity, operational risk, and MVP scope.
