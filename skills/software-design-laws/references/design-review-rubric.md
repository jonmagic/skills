# Design Review Rubric

This rubric is an original prompting structure for applying the local law catalog. It does not reproduce the source site's descriptions, examples, takeaways, or book content. Use it to shortlist law slugs, then validate each citation against `references/laws-catalog.json`.

## How to Use

1. Identify the design context.
2. Select only the categories that materially apply.
3. Choose 3-7 law slugs total for a normal review.
4. For each selected law, explain the design implication in the user's context.
5. Include the catalog URL for every cited law.

## Team and System Boundaries

Candidate slugs: `conways-law`, `brooks-law`, `dunbars-number`, `bus-factor`, `ringelmann-effect`, `prices-law`.

Questions:

- Does the proposed architecture match the communication paths and ownership model that will build and operate it?
- Are service boundaries aligned to teams that can own outcomes end to end?
- Does adding more people create onboarding and coordination load instead of reducing risk?
- Is there a key-person dependency that should change the design, documentation, or rollout plan?

## APIs, Contracts, and Compatibility

Candidate slugs: `hyrums-law`, `postels-law`, `law-of-leaky-abstractions`, `principle-of-least-astonishment`, `law-of-demeter`, `teslers-law`.

Questions:

- What observable behavior might users depend on even if it is undocumented?
- Which outputs, errors, timings, orderings, side effects, or retries become part of the real contract?
- Where does the abstraction leak, and how will users diagnose the underlying system when it does?
- Does the design put complexity in the right place: caller, platform, operator, or product surface?

## Scope, Simplicity, and Evolution

Candidate slugs: `yagni`, `kiss-principle`, `galls-law`, `second-system-effect`, `zawinskis-law`, `teslers-law`, `occams-razor`.

Questions:

- What is the smallest working version that can evolve safely?
- Which generalized features are speculative rather than required?
- Is this a second system trying to include everything the first system lacked?
- Which complexity is inherent, and which complexity is accidental?

## Distributed Systems and Reliability

Candidate slugs: `cap-theorem`, `fallacies-of-distributed-computing`, `murphys-law`, `law-of-unintended-consequences`, `testing-pyramid`, `pesticide-paradox`.

Questions:

- What happens under network delay, partition, partial failure, stale reads, duplicate delivery, and retries?
- Which consistency, availability, and partition-tolerance tradeoff is actually being chosen?
- What failure mode turns the intended mitigation into a new incident?
- Which tests will keep finding new classes of failure instead of repeatedly checking the same happy path?

## Scale, Performance, and Optimization

Candidate slugs: `premature-optimization`, `amdahls-law`, `gustafsons-law`, `pareto-principle`, `metcalfes-law`, `kernighans-law`.

Questions:

- Has the design measured the bottleneck, or is it optimizing a guessed hotspot?
- Which serial step caps the benefit of scaling out?
- Does bigger input or network size change the shape of the solution?
- Is the optimized path still understandable enough to debug?

## Quality, Maintenance, and Technical Debt

Candidate slugs: `boy-scout-rule`, `technical-debt`, `broken-windows-theory`, `lehmans-laws`, `testing-pyramid`, `pesticide-paradox`, `dry-principle`, `solid-principles`.

Questions:

- Does the change leave the touched area easier to understand, test, and operate?
- Is the debt intentional, named, and paired with a repayment trigger?
- Are small quality declines being normalized?
- Will the system keep evolving under real use without regular maintenance investment?

## Planning and Metrics

Candidate slugs: `hofstadters-law`, `ninety-ninety-rule`, `parkinsons-law`, `goodharts-law`, `gilbs-law`, `pareto-principle`.

Questions:

- Where is hidden work likely to appear after the apparent last 10 percent?
- Are metrics becoming targets in a way that distorts product, safety, or engineering judgment?
- Can value be delivered in smaller increments with explicit feedback loops?
- What scope expands merely because the container exists?

## Decision Hygiene

Candidate slugs: `confirmation-bias`, `sunk-cost-fallacy`, `map-is-not-the-territory`, `first-principles-thinking`, `inversion`, `hanlons-razor`, `hype-cycle-amaras-law`, `lindy-effect`, `dunning-kruger-effect`.

Questions:

- What evidence would change the decision?
- Are we defending sunk cost rather than future value?
- Does the model, diagram, metric, or plan hide reality that operators or users will experience?
- What failure would we predict if we inverted the goal and tried to make the design fail?

## Suggested Output Shape

For most reviews, use this compact shape:

```markdown
**Relevant laws**
- [Law title](law URL) (`slug`): why it applies here.

**Design pressure points**
- Concrete risk or design tension.

**Adjustments**
- Specific changes, simplifications, gates, or follow-up questions.
```

For high-stakes designs, add a final **Decision gates** section only when the user asks for gates.
