# Behavior and Contract Closure

Load this reference when a review changes behavior beyond a local implementation
detail or when a small mistake could have a large blast radius.

The governing rule is:

> Name the invariant, limit, or implicit contract changed by the implementation,
> then enumerate and inspect the consumers of that property before closing the
> review.

This is not a request to trace an entire application. Follow only the value or
contract that changed, and stop when its relevant consumers and sinks are
accounted for.

## Choose the review depth

Round up when a change fits more than one tier.

### Routine

Use for localized changes with bounded behavior and low blast radius.

- Inspect direct callers, callees, and tests.
- Do not require repository-wide searches or a complete execution trace.

### Behavior-sensitive

Use for bug fixes and user-visible or operational behavior changes.

- Trace the changed value or contract through the complete affected behavior.
- Inspect the direct and transitive consumers that can alter the outcome.
- Verify the test exercises the behavior at the layer where it can fail.

### High-risk

Use when any of these signals is present:

- production incident or regression remediation
- authorization, permissions, privacy, or sensitive data handling
- persistence, schemas, or migrations
- scale, resource limits, performance cliffs, or cost
- public APIs or cross-service boundaries
- structural runtime changes such as inheritance, mixins, `include`, `prepend`,
  decorators, proxies, monkey patches, or middleware
- rollout or rollback that depends on telemetry, alerts, logs, or dashboards

High-risk reviews require the closure evidence below. If classification is
uncertain, use this tier.

## Closure workflow

### 1. Name the changed property

State the concrete property that can affect behavior:

- a value may exceed a runtime argument or memory limit
- ancestry or method lookup order changes
- a serialized field, event, metric, log field, or tag changes
- authorization moves relative to a lookup
- retry, transaction, or idempotency behavior changes

Do not use broad labels such as "performance" or "refactor" when a more precise
property can be named.

### 2. Enumerate consumers with checkable evidence

Inspect the call sites, downstream functions, reflection users, serializers,
queries, dashboards, or external consumers that depend on the changed property.

Evidence must be independently checkable:

- cite each important hop or consumer as `path:line`
- record the concrete search terms or patterns used
- inspect the resulting hits rather than trusting a zero-result summary
- for compatibility contracts, compare the old and new names, fields, tags, or
  query filters directly

A claim such as "no other hazards remain" is incomplete without this evidence.
The same rule applies to claims from subagents and built-in review tools.

### 3. Search the semantic hazard family

Search for operations that share the failure mechanism, not only the exact
syntax changed in the diff.

Examples:

- argument expansion limits: spread into `push`, `splice`, constructors, or
  other function calls
- structural composition: consumers of ancestry, class identity, method owner,
  reflection, serialization, routing, or telemetry type derivation
- compatibility: consumers of response fields, event shapes, metric names,
  tags, log fields, dashboard filters, or alert queries

Examples are prompts, not an exhaustive catalog. Derive the search family from
the changed property.

### 4. Validate at the failure layer

Validation must exercise the layer where the risk can occur.

- A helper-only test does not prove an integration-level failure is fixed.
- A unit test for metric emission does not prove an existing dashboard query
  still matches its tags.
- A successful changed-file test does not prove a transitive consumer remains
  compatible.

Prefer the cheapest representative entry-point test. For scale or limit bugs,
use a realistic input size. If required evidence is unavailable, name the exact
missing validation and residual risk.

## Operational contract check

When the PR names rollout or rollback signals, verify the exact contract:

- metric and event names
- tags and dimensions
- log message or field names
- dashboard and alert filters
- queries and runbook assumptions

Treat these as compatibility surfaces even when they are not formal APIs.

## Review evidence contract

For high-risk reviews, surface a concise evidence block in the review package:

```markdown
**Closure evidence**
- Changed invariant or contract: ...
- Consumers and sinks inspected: `path:line`, ...
- Semantic searches performed: `<pattern or term>` -> <relevant hits>
- Representative validation: ...
- Residual uncertainty: none | ...
```

Do not mark closure as proven unless the cited files and search results were
actually inspected. A status word without checkable evidence is incomplete.

## Decision gates

- A concrete, reachable, unguarded hazard is `Needs changes before merge`.
- If required high-risk evidence cannot be obtained in the review environment,
  use `Not enough context` and name the specific validation or artifact needed.
- Do not use `Not enough context` as a substitute for searches or reads the
  reviewer can perform.
- Do not return `Looks ready` when validation proves only a proxy for the layer
  where the material risk occurs.
- Routine reviews remain bounded; do not add exhaustive tracing when no
  behavior-sensitive or high-risk signal is present.
