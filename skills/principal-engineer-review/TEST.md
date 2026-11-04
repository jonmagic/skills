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
- Distinguishes current reachability from enabled-path safety; default-off does not excuse a proven harmful enabled path.
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

## Test: Bounded diagnostic versus unsafe enabled flag

**Prompt:**
```
Review both variants of Fixture D in examples/closure-review-fixtures.md. Decide whether each is ready to merge.
```

**Expected Behavior:**

- Returns `Looks ready` and recommends approval for D1: the actual enabled diagnostic is bounded, read-only, and supported by capacity evidence.
- Returns `Needs changes before merge` for D2: enabling both flags creates two billed scans in violation of the one-replacement contract.
- Calls the D2 trigger activation-time without using default-off or future ownership promises to excuse it.
- Does not invent a rollout duration, capacity threshold, manual approval ritual, or missing control.

## Test: Inert foundation in a dependent PR program

**Prompt:**
```
Review this supplied change program without repository lookup. PR A targets the default branch and adds an inert state model. PR B targets A and adds partial enforcement. PR C targets B and activates the behavior. A required public-serving change has no linked PR in its repository. PR D targets C even though it only depends on A. The current target is PR A. Explain merge readiness, activation readiness, sequencing, and the stack evidence that must be recorded. Do not post anything.
```

**Expected Behavior:**

- Classifies the relationship as a dependent branch chain or linked change program without assuming native stack guarantees.
- Reviews the current layer, cumulative program, and intermediate merge and deployment states separately.
- Allows PR A to merge when its own inert contract is sound while blocking activation at PR C.
- Assigns the missing serving behavior to a cross-repository prerequisite instead of treating it as a defect in PR A.
- Recommends restacking PR D directly on PR A.
- Records current head and parent SHAs, explicit diff bases, activation ownership, finding ownership, and resolved-upstack status.
- Distinguishes a sound inert data model from an already implemented harmful enabled path.
- Uses patch-series comparison after restacking and avoids duplicating one program-wide finding across every PR.

## Test: Recipient did not share the private review conversation

**Prompt:**
```
We spent an hour tracing the retry path and corrected our first theory. The PR author has only seen the PR and its tests. Draft the blocking review comment.
```

**Expected Behavior:**

- Uses the private investigation to improve accuracy without narrating it to the recipient.
- States the necessary execution-path setup directly.
- Does not say "as we discussed," "after digging further," or otherwise imply the author shared the private conversation.
- Avoids dangling references and false-inclusive "we."
- Preserves the concrete consequence and recommended next step.

## Test: Approval with optional feedback versus a genuine blocker

**Scenario:** A complete retry review finds no consequential defect and suggests reusing an equivalent helper. In the paired variant, cleanup deletes jobs using a counter that combines ordinary polls with real failures; the current contract permits deletion only after actual failures.

**Expected Behavior:**

- Recommends `Looks ready` / `approve` in the first case, even if the helper suggestion is retained.
- Blocks the second case with the fact, reachable cleanup trigger, failure-only contract, and deletion of healthy work.
- Does not block on preferred abstractions or add an optional laundry list; explains the mechanism without praise or lectures.

## Test: Resolved concerns versus a new serious regression

**Scenario:** An older platform review is followed by a later chat review of a known revision. The author fixes every remaining concern; the delta preserves accepted tradeoffs. In the paired variant, that delta also removes the tenant predicate from an authorization query.

**Expected Behavior:**

- Closes the old concerns and recommends approval in the first case without adding new optional acceptance demands.
- Uses the later actual chat review as the baseline instead of falling back to the older platform submission; retains relevant earlier concerns.
- Blocks the new cross-tenant exposure in the second case and ties it to the delta.
- If the same flaw was already present and missed by the earlier review, owns that earlier miss rather than claiming the author introduced it; distinguishes an unrelated existing limitation from a material defect in the reviewed path.

## Test: Deliberate changed intent versus accidental regression

**Scenario:** A later commit and current tests deliberately record retry attempts instead of successes; the text is accurate and no current contract requires success-only records. In the paired variant, the current replay contract requires success-only records and a failed attempt is incorrectly marked successful.

**Expected Behavior:**

- Marks the old success-only concern intentionally superseded in the first case, recommends approval, and treats stale PR wording as optional feedback.
- Blocks the second case on the current contract and corrupted replay state, not just an old reply.
- Preserves revision chronology and asks a narrow chat question only if the premise is genuinely uncertain.

## Test: Verified replay versus harmful duplicate effects

**Scenario:** Repeated deliveries use the same event ID; an inspected unique constraint and transaction ensure one balance update, and replay coverage confirms later deliveries are no-ops. In the paired variant, each delivery gets a new ID and both increment the balance despite the exactly-once effect contract.

**Expected Behavior:**

- Approves verified harmless replay rather than demanding another deduplication system.
- Blocks repeated balance effects in the second case with the actual trigger and harm.
- Does not assume duplication is either safe or harmful without inspecting the relevant semantics.

## Test: Optional evidence versus essential safety gap

**Scenario:** The request path and representative integration coverage establish tenant isolation; an extra stress test is suggested. In the paired variant, the changed adapter's tenant filtering cannot be inspected or exercised, and the visible caller supplies no tenant predicate.

**Expected Behavior:**

- Approves the first case without demanding the extra test.
- Returns `Not enough context` for the second case, naming the unavailable adapter behavior and the cross-tenant exposure it must rule out.
- Does not assert a proven leak, invent probabilities, or approve from silence.

## Test: Readiness survives drafting and action handoff

**Prompt:**
```
The completed review is Looks ready / approve with one optional helper suggestion. Draft that suggestion and prepare the action handoff. Do not post.
```

**Expected Behavior:**

- Preserves `Looks ready`, `approve`, and non-blocking status through the draft and handoff.
- Does not select `comment` just because comments exist or make the optional suggestion an approval condition.
- Uses concise standalone wording without internal finding IDs, private preparation details, or perfunctory praise.
- Uses ordinary chat and preserves explicit human approval of exact text, target, disposition, and reviewed revision before any posting.
