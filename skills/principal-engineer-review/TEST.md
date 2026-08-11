# Principal Engineer Review Skill Tests

Use these scenarios as lightweight manual checks when changing the skill.

## Test: PR review request

**Prompt:**
```
Use principal-engineer-review on https://github.com/OWNER/REPO/pull/123
```

**Expected Behavior:**

- Reads the PR body and diff before deciding.
- Inspects relevant surrounding code instead of reviewing the diff alone.
- Returns a decision plus only material findings.
- Starts with a compact explanation of the purpose, before/after behavior, relevant system path, and important invariant when the user has not demonstrated that context.
- Does not post comments unless explicitly asked.

## Test: Reviewer without repository context

**Prompt:**
```
Help me understand this PR well enough to review it. I am new to this part of the system.
```

**Expected Behavior:**

- Treats the user as technically capable but unfamiliar with the system.
- Explains the business purpose and before/after behavior before using repository-specific terminology.
- Defines only the terms needed for the material findings.
- Keeps the first response compact and makes deeper paths obvious.
- Does not draft review comments or ask for a GitHub disposition.

## Test: Experienced reviewer skips the introduction

**Prompt:**
```
I understand the request path and the cache invalidation contract. Review whether the new fallback preserves tenant isolation.
```

**Expected Behavior:**

- Recognizes the user's demonstrated context.
- Does not repeat the request-path or cache basics.
- Leads with the decision, relevant evidence, and unresolved tenant-isolation questions.
- Offers deeper explanation only for concepts that remain material and unestablished.

## Test: Pair-partner deep dive

**Prompt:**
```
Trace the execution path behind the first blocking finding and explain why the focused test does not prove it.
```

**Expected Behavior:**

- Deepens only the requested finding.
- Walks the relevant call path in order and ties each step to evidence.
- Distinguishes the test proxy from the production integration path.
- States exactly what evidence is unavailable rather than guessing.

## Test: Reviewer challenges a finding

**Prompt:**
```
I think that finding is wrong because the flag is disabled by default. Re-check it.
```

**Expected Behavior:**

- Re-checks flag defaults, rollout notes, tests, and reachability.
- Updates or withdraws the finding when the evidence changes its classification.
- Distinguishes safe to merge from safe to enable.
- Does not defend the original verdict on authority.

## Test: Next pending review request

**Prompt:**
```
/principal-engineer-review next
```

**Expected Behavior:**

- Resolves the authenticated GitHub login instead of asking for a PR URL.
- Searches open, non-draft direct requests from non-archived repositories, ordered by most recent update.
- Searches the broader direct-or-team queue only when no direct request qualifies.
- Rejects PRs already reviewed by the authenticated user.
- Selects the newest eligible direct request before considering the newest eligible team request.
- Runs the full principal-engineer review on the selected PR.
- Returns the selected PR, selection reason, decision, findings, evidence, and uncertainty.
- Stops before drafting or posting the GitHub response.

## Test: Direct request beats newer team request

**Scenario:**

- An eligible team request was updated today.
- An eligible direct request was updated yesterday.

**Expected Behavior:**

- Selects the direct request despite the newer team request.
- Uses recency only within the direct or team class, not across both classes.

## Test: No eligible pending review request

**Scenario:**

- Use mocked candidate metadata where every candidate is a draft, authored by the authenticated user, or already has a submitted review from the authenticated user.

**Expected Behavior:**

- Reports that no eligible pending review request exists.
- Does not substitute a mention, assignment, authored PR, archived PR, draft, or previously reviewed PR.
- Does not mutate GitHub.

## Test: Local diff scope review

**Prompt:**
```
Review this branch from a principal engineer standpoint and tell me where we're overbuilding.
```

**Expected Behavior:**

- Resolves the correct base branch.
- Checks for existing helpers and patterns before accepting new abstractions.
- Separates blocking scope concerns from follow-up suggestions.

## Test: Draft review comments

**Prompt:**
```
Draft humble review comments for the blocking issues.
```

**Expected Behavior:**

- Drafts from the established review package without repeating the full PR explanation.
- Produces pasteable comments with path/line references when available.
- Uses uncertainty only where evidence is incomplete.
- Does not submit the review without explicit approval of the exact target, text, and disposition.

## Test: Architecture/API boundary review

**Prompt:**
```
Review this API boundary change from a principal engineer standpoint and tell me where the design may age poorly.
```

**Expected Behavior:**

- Uses `references/design-lens.md` only if named principles materially sharpen the review.
- Applies at most 1-3 principles as concrete risks, questions, or adjustments.
- Does not turn a normal PR review into a law catalog.

## Test: Routine change stays bounded

**Prompt:**
```
Review a localized copy change with direct unit coverage and no production behavior, persistence, API, structural runtime, or operational telemetry impact.
```

**Expected Behavior:**

- Classifies the review as routine.
- Inspects direct callers, callees, and tests without demanding a repository-wide trace.
- Does not add a closure-evidence section or return `Not enough context` merely because every transitive consumer was not inspected.

## Test: Incident fix leaves an equivalent downstream hazard

**Prompt:**
```
Review Fixture A in examples/closure-review-fixtures.md. Decide whether the production incident fix is ready to merge.
```

**Expected Behavior:**

- Classifies the review as high-risk because it remediates a production scale incident.
- Names unbounded argument expansion as the changed limit or invariant.
- Traces the incident-sized collection into the downstream helper and cites that consumer.
- Treats the downstream `splice` spread as a concrete blocking hazard.
- Rejects the helper-only test as insufficient proof for the integration path.
- Returns `Needs changes before merge`, not `Looks ready`.

## Test: Structural composition breaks an operational contract

**Prompt:**
```
Review Fixture B in examples/closure-review-fixtures.md. Decide whether the selective cache change is safe to deploy behind its disabled flag.
```

**Expected Behavior:**

- Classifies the structural runtime change and rollout telemetry as high-risk.
- Names ancestry order as the changed implicit contract.
- Searches for and inspects consumers of ancestry, class identity, and telemetry type derivation.
- Compares the emitted `consumer_type` with the dashboard filter.
- Returns `Needs changes before merge` when the prepended module changes the tag.

## Test: Novel implicit-contract consumer

**Prompt:**
```
Review Fixture C in examples/closure-review-fixtures.md. Decide whether the retry-logging refactor preserves existing behavior.
```

**Expected Behavior:**

- Applies the general changed-invariant rule rather than relying only on spread or ancestry examples.
- Inspects the serializer as a consumer of identity metadata.
- Requires checkable `path:line` and search evidence before claiming no compatibility issue remains.
- Keeps the trace bounded to consumers of the changed identity contract.

## Test: Dormant flag does not become a merge blocker

**Prompt:**
```
Review Fixture D in examples/closure-review-fixtures.md. Decide whether the additive shadow worker is ready to merge.
```

**Expected Behavior:**

- Reads the rollout notes and tests as evidence that the dual path and live
  action are deliberate.
- Identifies duplicate replacement scans as activation-time behavior because
  the live-action flag remains off during the current rollout.
- Asks whether duplicate replacement scans are intentional if that answer
  would change the review, rather than asserting they are a proven bug.
- Distinguishes safe to merge from safe to enable.
- Returns `Looks ready` or `Comment-only`, not `Needs changes before merge`,
  unless additional evidence makes the live-action path reachable now.
