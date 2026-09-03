# Stacked and Dependent Change Programs

Use this contract when a target PR is part of a native stack, a traditional dependent-branch chain, or a loosely linked multi-PR program.

## Deterministic Discovery Prefix

1. Record the repository default branch, target PR base and head branches, reviewed head SHA, and current base SHA.
2. Inspect platform-provided stack metadata when available. Otherwise follow traditional base/head branch chains, linked PRs and issues, and named cross-repository prerequisites.
3. Classify the relationship using only `native-stack`, `dependent-branch-chain`, or `linked-change-program`; never invent a more descriptive label. Use `dependent-branch-chain` when PR branches directly target preceding PR branches, even when the program also has linked or cross-repository prerequisites. Use `linked-change-program` when related PRs do not form a direct branch chain. Do not assume trunk validation, cascading restacks, contiguous merge behavior, or atomicity unless platform metadata proves those guarantees apply.
4. Build a compact dependency graph naming each layer's URL, purpose, direct parent, current head SHA, current parent SHA, merge order, and deployment or activation prerequisites.
5. Stop with `Not enough context` when an inaccessible layer or prerequisite prevents a responsible readiness decision. Do not silently treat the visible PR as the complete delivery.

## Three Review Views

Review and report these views separately:

1. **Layer delta:** Does this PR correctly implement the responsibility owned by this layer?
2. **Cumulative result:** Does the complete known program deliver the promised end-to-end invariant?
3. **Intermediate states:** Is every intended merge, deploy, migration, rollback, and activation state safe, including a foundation merged without its dependents?

Keep focused PRs separate when their boundaries improve review, deployment, rollback, or ownership. Evaluate whether each layer includes the tests for its own responsibility and leaves the system safe in the state where that layer can exist without later layers.

## Activation and Finding Ownership

Name the exact PR, flag, migration, UI, configuration, or deployment step that makes dormant behavior reachable. Lower layers may be safe to merge while program activation remains blocked.

Assign every finding to one status and owning target:

- `request_changes_here`: the owning layer is incorrect or unsafe in an intended reachable state.
- `block_program_activation`: the layer can merge safely, but the complete capability must not be enabled yet.
- `resolved_upstack`: a dependent layer demonstrably fixes the concern; retain the evidence without repeating the comment on the lower PR.
- `cross_repository_prerequisite`: another repository or service must change before activation.
- `follow_up_here`: a non-blocking improvement belongs to the current layer.

Place a program-wide finding on the umbrella issue, design artifact, or activation PR when possible instead of duplicating it across every layer.

## Freshness and Restacking

A review is current only when both the reviewed head SHA and parent SHA match the analyzed patch series. After a restack, parent update, or substantive head change:

1. Refresh the dependency graph.
2. Compare the old and new patch series with `git range-diff` or an equivalent patch-series comparison.
3. Revalidate affected layer, cumulative, and intermediate-state conclusions.
4. Withdraw findings that are resolved upstack and reassign findings whose owning layer changed.

## Required Structured Evidence

Populate `changeProgram` in `references/structured-review-handoff.md` with the proven relationship, layer position, parent URL and SHA, diff basis, activation owner, and cross-repository prerequisites. Each finding must record `owningTarget`, `reachability`, and `resolvedUpstack`.
