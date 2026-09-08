# Re-review Intent Contract

Use this contract when the authenticated reviewer already has a submitted review on an explicitly targeted PR, or when current-head behavior conflicts with earlier intent evidence.

## Re-review delta

1. Find the latest submitted review by the authenticated reviewer and record its `commit_id`.
2. Read the review threads and author replies associated with that review.
3. Inspect the commits and diff from the previously reviewed SHA to the current head.
4. Classify each prior concern as `addressed`, `intentionally superseded`, `reintroduced`, or `unresolved`.
5. Record the previous reviewed SHA, current head, exact comparison basis, current intent evidence, and stale intent evidence in `reviewContext`.

## Intent chronology

Order conflicting intent evidence by revision and timestamp. Current-head code and tests plus later commits establish the behavior currently intended by the change. Earlier replies, intermediate commits, and unchanged PR text can be stale. Current policy, API, safety, and acceptance contracts may still prove that deliberate behavior wrong.

Do not call behavior a regression merely because it differs from an earlier reply or intermediate fix. If a later commit and current tests deliberately encode the new behavior, classify the intermediate fix as intentionally superseded and evaluate the current behavior against current contracts.

## Blocker gate

Before assigning `blocking: true` with `confidence: high`, require either a current authoritative contract that the deliberate behavior violates or a concrete consequence that remains harmful regardless of intent. Otherwise classify the concern as an open question, stale-documentation mismatch, or non-blocking feedback. Never use an older author reply by itself to set `uncertainty: null` against contrary current-head evidence.
