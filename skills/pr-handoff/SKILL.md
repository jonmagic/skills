---
name: pr-handoff
description: Prepare GitHub pull requests for review and follow up on PR review comments. Use before any PR creation or update, including "open a PR", "create a PR", "make a pull request", `gh pr create`, writing/updating a PR body, requesting review, handling Copilot or human review feedback, resolving comments, or asking whether a branch is ready to review. Includes rubber ducking, semantic commits, PR body/review guidance, 5-minute Copilot feedback follow-up scheduling, and work-repo vs personal-project boundaries.
---

# PR Handoff

Prepare code for a low-friction GitHub PR review, then handle review feedback with clear replies and traceability.

## When to Use

Use this skill when the user asks to make a branch into a PR, open/create a PR, run `gh pr create`, request review, get a PR ready, update a PR after implementation, respond to Copilot or human review comments, resolve PR comments, or check whether review handoff needs more context.

This skill must be invoked before any agent opens or updates a GitHub pull request on the user's behalf. Treat the trigger phrases "open a PR", "create a PR", "make a pull request", "push this as a PR", "draft PR", "ready for review", "review comments", and `gh pr create` as direct matches.

This skill mostly applies to work repos that use PR review. Do not force PR-specific steps onto personal projects or repos that do not use PRs. For non-PR projects, still use the quality gates that apply: rubber-duck review when warranted, semantic commits when committing code, and concise handoff notes.

## Related Skills

Invoke related skills when they match the work:

1. Use `semantic-commit` before committing application code when that skill is available. If it is not available in the current environment, still write conventional semantic commit messages directly.
2. Use `github-interaction` when fetching PR comments, reviews, review threads, issue comments, or other GitHub conversation context.
3. Use a voice/style skill when drafting PR comments or replies in the user's voice.

## Readiness Workflow

Before opening or marking a PR ready for review:

1. Confirm the working tree and branch state. Do not overwrite unrelated user changes.
2. Run the project's existing relevant validation. Do not invent new tooling.
3. Rubber-duck high-stakes, ambiguous, or broad changes before treating the branch as ready. This includes security, auth, permissions, data handling, persistence, migrations, schemas, production-impacting behavior, broad refactors, and unclear blast radius.
4. Keep the PR small enough to review well. Split unrelated commits or workstreams into separate PRs when practical; if they must stay together, explain the coupling in the PR body or handoff.
5. Commit complete validated milestones with semantic commits. Keep unrelated changes in separate commits.
6. Push the branch and create or update the PR.

If a PR is not ready, leave it as draft or say exactly what is blocking readiness.

## GitHub Link Safety

Always use full GitHub URLs in PR handoffs, PR bodies, comments, schedules, and
final responses. Do not use shorthand such as `owner/repo#123`, `#123`, or bare
PR/issue numbers, because Markdown may resolve them relative to the current
repository and send the user to the wrong place.

Before posting or returning a PR or issue reference, validate that the visible
link is repository-qualified:

```text
https://github.com/<owner>/<repo>/pull/<number>
https://github.com/<owner>/<repo>/issues/<number>
```

If only a shorthand reference is available, resolve it with `gh pr view`,
`gh issue view`, or the GitHub API and emit the full URL.

## PR Body Guidance

Write a PR body that reduces reviewer and shipper work. Be concise, concrete, and grounded in the diff. Include only sections that are useful for the change; omit sections instead of writing filler or "N/A".

Before drafting, inspect the diff, changed files, commits, validations, feature flags, config, migrations, metrics, logs, dashboards, and docs that are directly relevant. Verify every named file path, flag, metric, secret, log string, dashboard, config key, command, and rollout step against the code, config, PR context, or user-provided evidence. Do not invent identifiers, telemetry, validation, data, risk, or rollout facts.

Use this shape when it applies:

1. Summary: state what changed, why it matters, and the important implementation shape. For non-obvious design choices, include the alternative or tradeoff and the evidence that supports the decision, such as sampled counts, measured behavior, incident context, or constraints. Keep this to one or two tight paragraphs unless the change genuinely needs more.
2. Testing: list exact validation performed, or the clear reason validation was not run. It is okay to fold test coverage into the review guide when that is more useful, but do not hide missing validation.
3. Review guide: include for large, risky, multi-area, or non-obvious PRs. Give reviewers a deliberate reading order, not an alphabetical file list. For each high-signal file or file group, write verifiable "Confirm that ..." assertions that point at the specific invariant, edge case, boundary, or tradeoff to review.
4. Readiness guide: include when merge or deploy readiness depends on preconditions, staged rollout, feature flags, permissions, secrets, migrations, config, indexes, partial readiness, known follow-ups, or cross-service dependencies. Phrase items as things the shipper can verify before moving forward.
5. Deploy guide: include when deployment needs more than the repo's usual process, such as migrations, backfills, config changes, feature flags, manual ordering, conservative ramps, or cross-service coordination. Use ordered steps, named guardrails, and explicit checkpoints. Include "do not" guidance when the safe path excludes a tempting default path.
6. Monitor or observability guide: include when production behavior changes, risk needs watching, or rollback/roll-forward criteria should be explicit. Group signals by concern, name exact dashboards, logs, metrics, alerts, queries, or expected signals when known, and end with the pause, rollback, or roll-forward action plus the expected safe state after taking it.

Readiness is what must already be true before the shipper starts. Deploy is the ordered action plan. Do not repeat an item in both sections; put it where the shipper acts on it.

Prefer practical reviewer instructions over narrative. The best review guide tells the reviewer what to prove true, where to look first, and what feedback would be most valuable.

### PR Body Quality Bar

A strong PR body should answer:

1. What changed, why it matters, and what decision or tradeoff should not be lost?
2. What are the highest-risk files or concepts, in the order reviewers should read them?
3. What invariants should reviewers verify rather than merely skim?
4. What validation was performed, and what important path was not validated?
5. What must be true before merge or deploy?
6. How should the change be shipped, paused, rolled back, or rolled forward?
7. What exact signals should the shipper watch after deploy?

Avoid generic statements like "monitor logs", "check edge cases", "ensure tests pass", or "rollback if issues occur" unless paired with the exact log, edge case, test, metric, threshold, command, or rollback mechanism. If exact operational details are unknown, say only what is known and leave the unknown as a clear question or follow-up.

### Review Guide Example Shape

```markdown
## Review guide

Start with:

1. `app/services/new_worker.rb`
   - Confirm that work is checkpointed before the lease expires.
   - Confirm that the retry path cannot enqueue duplicate jobs for the same key.
2. `config/feature_flags.yml` and `config/deploy/worker.yml`
   - Confirm that `new_worker_rollout` starts disabled.
   - Confirm that the worker deploy target is separate from the default web deploy.
3. `test/services/new_worker_test.rb`
   - Confirm that tests cover lease loss, duplicate input, and resume after checkpoint.
```

## Review Follow-Up Scheduling

After creating or updating a PR for review, create a 5-minute recurring review follow-up schedule when the scheduling tool is available, unless the user explicitly says not to schedule follow-up.

Use this prompt shape, replacing placeholders with the PR URL and branch/repo:

```text
Check <PR_URL> for Copilot or human review feedback. Fetch full PR context, reviews, review comments, and general comments. If Copilot is still reviewing or checks are still pending with no actionable feedback, report that briefly and let the schedule continue. If actionable feedback exists and can be safely handled without product/principal judgment, make the fix, validate it, commit/push it, reply to the relevant review comments, and resolve threads when supported. If feedback needs the user's principal-level analysis, tradeoff decision, approval, or sensitive context, stop the schedule and report the exact decision needed. Stop the schedule once all actionable Copilot feedback is addressed/resolved or once the user is needed.
```

The schedule is a guardrail, not permission to merge, deploy, approve access, or take destructive actions. It may push commits that directly address review feedback on the PR branch when that is within the original PR scope and validation passes. It must not broaden scope, resolve disputed comments, or answer principal-level questions without the user.

Stop the schedule when one of these conditions is true:

1. All actionable Copilot feedback has been addressed, pushed, replied to, and resolved where supported.
2. Copilot has completed review with no actionable feedback and checks are not producing new review items.
3. A reviewer asks for a decision, tradeoff, privacy/security judgment, or product/principal analysis that needs the user.
4. The PR is closed, merged, superseded, or the branch no longer exists.

If scheduling is unavailable, say that plainly in the PR handoff and include the first manual follow-up command or URL to check.

Schedule prompts must use full GitHub URLs, not shorthand references.

## Responding to Review Comments

When following up on review feedback:

1. Fetch the full relevant PR context, including review comments, reviews, and general comments. Use the appropriate GitHub tools instead of web scraping.
2. Address each comment with a code change, explanation, or explicit decision not to change.
3. Reply to the comment with the reason, the commit SHA when a commit addressed it, and a short explanation of what changed.
4. Resolve the thread at the same time when the feedback has been fully addressed and resolving is supported.
5. Do not resolve comments that still need reviewer confirmation, represent unresolved disagreement, or were only partially addressed.

Prefer replies like:

```markdown
Addressed in `abc1234`. I changed the parser to reject empty account IDs before building the request, which keeps the downstream validation path unchanged.
```

or:

```markdown
I left this as-is because the caller already normalizes this value through `normalizeAccountId`, and adding another normalization pass here would make the error path less clear.
```

## Boundaries

Skip PR-specific instructions when the project does not use PRs, especially for personal repos or note/knowledge-base work. In those cases, provide the smallest useful handoff: what changed, validation status, commits made, and any risks.

Do not pad the PR with generic sections. Add review, readiness, deploy, and monitor guides only when they materially help reviewers or operators.

## Example Prompts

- "Get this ready for PR."
- "Open the PR and include a review guide."
- "Follow up on the PR review comments."
- "Is this branch ready for review?"
- "Update the PR body with deploy and monitoring notes."

## Source Expertise

This skill is grounded in its existing workflow instructions and common PR handoff practices. It captures the reusable workflow for preparing PRs for review, writing PR bodies, handling review feedback, and readiness checks.

No extra reference file is required by default; load source files only when the task needs that context.

## Anchored Workflow

### Deterministic prefix

1. Confirm the user's request matches this skill's scope: preparing PRs for review, writing PR bodies, handling review feedback, and readiness checks.
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

- Do not push or post PR comments without the user approval boundaries in this configuration.
- Do not broaden this skill into adjacent workflows just because the topic sounds related.
- Preserve the user's communication and git hygiene preferences when drafting, committing, posting, or saving artifacts.

## Examples

Should trigger:

- "get this branch ready for a PR and write the PR body"

Should not trigger:

- "review someone else's PR without preparing my branch"

## Evaluation Plan

Use `evals/evals.json` for task-quality checks and `evals/trigger-queries.json` for activation checks. Compare outputs with and without this skill; the skill should improve trigger precision, context loading, output structure, validation, and safety boundaries for preparing PRs for review, writing PR bodies, handling review feedback, and readiness checks.
