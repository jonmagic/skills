# Design Lens for Principal Engineer Review

Use this optional lens only when a review hinges on architecture, API compatibility, platform abstraction, service boundaries, team boundaries, or an explicit request for named design principles.

Do not turn ordinary PR reviews into law-catalog writeups. Pick at most 1-3 principles that materially change the review, then convert them into concrete risks, questions, or adjustments.

Source: adapted as review prompts from [Laws of Software Engineering](https://lawsofsoftwareengineering.com/) by Dr. Milan Milanovic. The source framework includes a larger catalog of principles; this reference intentionally selects the ones most likely to change a principal-engineer review. Link to the specific law page when a named law helps the reviewer understand the concern.

## Architecture, APIs, and boundaries

| Principle | Use when | Review question |
| --- | --- | --- |
| [Hyrum's Law](https://lawsofsoftwareengineering.com/laws/hyrums-law/) | Changing public APIs, response shapes, events, logs, headers, configs, or behavior with unknown consumers. | What undocumented behavior might callers already depend on, and does this change preserve, migrate, or intentionally break it? |
| [Conway's Law](https://lawsofsoftwareengineering.com/laws/conways-law/) | Moving boundaries between services, teams, packages, or ownership areas. | Does the technical boundary match the team that will own, operate, and evolve it? |
| [Gall's Law](https://lawsofsoftwareengineering.com/laws/galls-law/) | Replacing a working path with a broad new system or framework. | Is there a smaller working version that can evolve safely instead of introducing the whole system at once? |
| [Second-System Effect](https://lawsofsoftwareengineering.com/laws/second-system-effect/) | A rewrite or cleanup starts adding features, knobs, or architecture not needed by the original problem. | Is the redesign carrying lessons from the old system, or is it bundling unrelated ambition into the replacement? |
| [The Law of Leaky Abstractions](https://lawsofsoftwareengineering.com/laws/law-of-leaky-abstractions/) | Hiding infrastructure, persistence, auth, latency, tenancy, or failure behavior behind a helper or platform layer. | What lower-level behavior will leak during incidents or edge cases, and does the abstraction make that obvious enough to debug? |
| [CAP Theorem](https://lawsofsoftwareengineering.com/laws/cap-theorem/) | Reviewing distributed data paths, consistency choices, availability promises, or partition behavior. | Which guarantee is intentionally weaker under failure, and is that tradeoff visible to callers and operators? |
| [Fallacies of Distributed Computing](https://lawsofsoftwareengineering.com/laws/fallacies-of-distributed-computing/) | Adding cross-service calls, network dependencies, retries, caches, or remote coordination. | Which network, latency, reliability, topology, or ownership assumption can fail in production? |
| [Law of Unintended Consequences](https://lawsofsoftwareengineering.com/laws/law-of-unintended-consequences/) | Changing incentives, enforcement, automation, defaults, or shared platform behavior. | What second-order behavior might this encourage, and how would we detect or reverse it? |
| [Postel's Law](https://lawsofsoftwareengineering.com/laws/postels-law/) | Defining API validation, parsers, compatibility behavior, or integration boundaries. | Should this boundary be strict to prevent ambiguous data, or tolerant to preserve compatibility, and is that choice explicit? |

## Simplicity, maintainability, and quality

| Principle | Use when | Review question |
| --- | --- | --- |
| [YAGNI](https://lawsofsoftwareengineering.com/laws/yagni/) | Adding abstractions, extension points, options, generic helpers, or dependencies for imagined future needs. | What can be removed until the current business problem proves the extra shape is needed? |
| [KISS](https://lawsofsoftwareengineering.com/laws/kiss-principle/) | A change is hard to explain, test, operate, or debug relative to the problem it solves. | What simpler implementation would preserve the important behavior? |
| [Occam's Razor](https://lawsofsoftwareengineering.com/laws/occams-razor/) | Multiple explanations or designs fit the evidence. | Which solution makes the fewest new assumptions while still solving the concrete problem? |
| [Law of Demeter](https://lawsofsoftwareengineering.com/laws/law-of-demeter/) | New code reaches through several objects, services, clients, or response layers. | Is this depending on another component's internals instead of a stable boundary? |
| [Principle of Least Astonishment](https://lawsofsoftwareengineering.com/laws/principle-of-least-astonishment/) | Behavior, naming, errors, or defaults could surprise users, operators, or future maintainers. | Will the next person correctly predict what this does from the API, UI, or call site? |
| [Premature Optimization](https://lawsofsoftwareengineering.com/laws/premature-optimization/) | Adding caching, batching, async work, indexes, denormalization, or complexity for performance. | Is there evidence this path is the bottleneck, and can the optimization be delayed or isolated? |
| [Technical Debt](https://lawsofsoftwareengineering.com/laws/technical-debt/) | Accepting a shortcut, compatibility shim, duplicated primitive, or temporary path. | Is the debt intentional, bounded, owned, and cheap enough relative to the value of shipping now? |
| [Testing Pyramid](https://lawsofsoftwareengineering.com/laws/testing-pyramid/) | Validation relies on only one test layer or misses the changed behavior. | Is the behavior proven at the cheapest useful level, with higher-level coverage only where integration risk matters? |

## Planning, metrics, and incentives

| Principle | Use when | Review question |
| --- | --- | --- |
| [Goodhart's Law](https://lawsofsoftwareengineering.com/laws/goodharts-law/) | Adding metrics, thresholds, scorecards, automated enforcement, quotas, or success criteria. | If this metric becomes a target, what useful behavior could it distort? |

## Output guidance

When a principle applies, keep it grounded in the diff:

```markdown
`path/file.ext:123` - This changes a response field that external callers may already treat as stable even though it is not documented. Hyrum's Law applies here: can we preserve the old field during migration or show why no consumers rely on it?
```

If the principle does not change the review finding, omit it.
