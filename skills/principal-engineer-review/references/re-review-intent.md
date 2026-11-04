# Re-review Intent Contract

Use this contract for an explicitly targeted PR or local artifact previously reviewed in chat or on the platform, or when current-head behavior conflicts with earlier intent evidence.

## Re-review delta

1. Select the most recent actual review across platform submissions and established chat reviews, and record the revision it covered. A later chat review can supersede an older submitted baseline. If the baseline cannot be recovered, say so; do not invent a SHA or claim the delta was inspected.
2. Read the associated review discussion, threads, and author replies; retain relevant earlier concerns and accepted tradeoffs across both channels.
3. Inspect the commits and diff from the previously reviewed SHA to the current head.
4. Classify each prior concern as `addressed`, `intentionally superseded`, `reintroduced`, or `unresolved`.
5. Carry forward accepted intent and tradeoffs. Record the previous reviewed SHA, current head, exact comparison basis, current intent evidence, and stale intent evidence in `reviewContext`.

Start with this delta and the prior concerns, not a fresh wish list. Once concerns are addressed or intentionally superseded, close them unless current evidence disproves the resolution. Do not turn optional improvements into new acceptance demands after fixes. If no material blocker or essential safety gap remains, recommend approval even with optional feedback.

## Intent chronology

Order conflicting intent evidence by revision and timestamp. Current-head code and tests plus later commits establish the behavior currently intended by the change. Earlier replies, intermediate commits, and unchanged PR text can be stale. Current policy, API, safety, and acceptance contracts may still prove that deliberate behavior wrong.

Do not call behavior a regression merely because it differs from an earlier reply or intermediate fix. If a later commit and current tests deliberately encode the new behavior, classify the intermediate fix as intentionally superseded and evaluate the current behavior against current contracts.

## Blocker gate

Before assigning `blocking: true` with `confidence: high`, require either a current authoritative contract that the deliberate behavior violates or a concrete consequence that remains harmful regardless of intent. Otherwise classify the concern as an open question, stale-documentation mismatch, or non-blocking feedback. Never use an older author reply by itself to set `uncertainty: null` against contrary current-head evidence.

For any new blocker, connect verified fact -> reachable trigger -> affected contract -> actual harm. Explain why it belongs now: the delta introduced it, newly established evidence reveals a consequential interaction or contract, or the earlier review missed it. Own an earlier miss directly instead of implying the author failed a newly invented requirement. Serious newly discovered regressions still block; convergence does not mean ignoring them.
