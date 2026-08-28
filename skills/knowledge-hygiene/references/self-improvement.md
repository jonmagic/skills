# Self-Improvement

## Goal

Improve the smallest durable workflow surface after each run without allowing one unusual batch to destabilize the skill.

## Review After Every Run

Record:

- What produced a better decision.
- What wasted time or produced noisy evidence.
- Failed commands and corrected forms.
- Surprising evidence patterns.
- Interaction misses and direct user corrections.
- Cases where source presence, consumer wiring, or issue shape was mistaken for shipped completion or runtime activation.
- Any safety gate that prevented a bad action.
- Repeated manual steps that may deserve deterministic automation.

## Classify the Learning

Use these tests:

1. **Durable:** Would this improve a future batch in another repository or environment?
2. **Repeated:** Has it happened more than once, or is the failure costly enough to guard immediately?
3. **Actionable:** Can a precise instruction, reference, script, test, or template prevent the miss?
4. **Scoped:** Is knowledge hygiene the correct owner?

Do not encode one-off repository facts, private environment details, or temporary issue state in the skill.

## Choose the Smallest Surface

- Update `SKILL.md` only for routing, global invariants, the anchored workflow, dispositions, or completion criteria.
- Update `references/configuration.md` for portable run-profile behavior.
- Update `references/workflow.md` for detailed research and execution behavior.
- Update this file for the learning loop.
- Update `assets/` for packet or action templates.
- Update `scripts/` and tests for deterministic validation or side effects.

## Approval Boundary

At the end of a run:

1. State the observed learning.
2. Explain why it appears durable.
3. Show the exact proposed skill change or concise diff.
4. Wait for explicit approval.
5. Apply and validate only the approved change.

Never silently rewrite the skill.

## Validation

After an approved improvement:

- Validate `SKILL.md` frontmatter and name.
- Keep `SKILL.md` focused and under 500 lines.
- Confirm every linked reference and asset exists.
- Run script tests and syntax checks.
- Confirm no private paths, internal-only URLs, credentials, or private deny markers appear in the package.
