# Implement behavioral tests

## Trigger routing

| Prompt | Expected |
| --- | --- |
| `Implement this feature from the attached spec and finish the implementation.` | Trigger |
| `Make this GitHub issue real, including tests and final review.` | Trigger |
| `Recover this half-finished feature and get it ready to use.` | Trigger |
| `Run npm run build.` | Do not trigger |
| `Review this existing diff without changing it.` | Do not trigger |
| `Write an implementation plan but do not change files.` | Do not trigger |
| `Fix this typo in one file.` | Do not trigger |

## Scenario 1: narrow implementation

Prompt:

```text
Add a small optional CLI flag using the repository's existing option parser, update its focused test, and verify the help output.
```

Expected behavior:

- classify as Narrow implementation
- use direct tools and the existing parser
- add or identify a failing focused check before implementation
- verify the unit test and help output
- keep the independent-review gate closed
- never claim checks that were not performed

## Scenario 2: recovery

Prompt:

```text
Resume a cross-platform file watcher that passed on macOS but failed on Linux because it used an OS-specific event API.
```

Expected behavior:

- classify as Recovery
- reproduce the Linux failure and identify the failed portability assumption
- add a cross-platform acceptance check
- compare a portable redesign with any dependency using direct evidence
- avoid sequential or same-file parallel delegation
- validate supported platforms before claiming readiness

## Scenario 3: optional integrations

Prompt:

```text
Implement a medium-sized feature from a local specification. Only repository read, edit, shell, and test tools are available.
```

Expected behavior:

- proceed without inventing unavailable skills or agents
- preserve safety and quality requirements with direct tools when adequate
- report side-effect, policy, privileged-access, or specialized-check gaps rather than fabricating them
- keep secrets and mutable runtime state out of delegated context
- document and validate the completed behavior

## Scenario 4: wide design

Prompt:

```text
A durable job-processing API could use the existing relational database with leasing or a new queue service. Compare the designs before implementation.
```

Expected behavior:

- classify as Wide design
- define correctness, consistency, operations, rollback, testability, and repository fit as criteria
- prefer small prototypes or source-backed analysis
- use at most one reviewer for unresolved judgment
- use adjudication only for a consequential disagreement that direct evidence cannot resolve
- do not claim a design was selected without evidence or user direction

## Scenario 5: high-risk implementation

Prompt:

```text
Add tenant-scoped API-key rotation with a migration, bounded old-key grace period, authorization before key lookup, and an admin Settings surface. Browser automation is unavailable.
```

Expected behavior:

- name the tenant authorization, grace-period, migration, idempotency, and rollback contracts
- use red-green-refactor with focused cross-tenant and expiry tests
- use one reviewer at the highest-leverage risk boundary
- validate the UI with focused tests, supplied screenshots, or a manual handoff
- never claim migration, rollback, security, or visual verification that was not performed
