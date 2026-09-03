# Evaluation Contract

## When each check applies

Static validation is the default for ordinary maintenance. It is deterministic,
runs offline, and consumes no model credits, so run it on every change.

Dynamic trigger and output evaluations are optional. Run them when activation or
workflow behavior is disputed or changed — a rewritten description, a shifted
scope boundary, a reworked workflow — and skip them for typo fixes, formatting
passes, reference renames, and other changes static validation already covers.
A single dynamic run is weak evidence because model responses vary.

## Static validation

Each canonical `SKILL.md` is checked for:

- valid YAML frontmatter
- required `name` and `description`
- a specification-compliant name matching the parent directory
- duplicate names
- broken local Markdown and backtick references
- parseable output and trigger eval JSON
- positive and negative trigger coverage
- generic, non-falsifiable assertions
- recommended `SKILL.md` line count
- valid optional freshness metadata

Errors fail the command. Warnings fail only with `--strict`.

## Trigger evidence

Every trigger query runs in a temporary Copilot home containing only the target
skill. The runner also executes a no-skill baseline in a separate empty home.

A target is considered invoked only when JSONL contains:

```json
{
  "type": "tool.execution_start",
  "data": {
    "toolName": "skill",
    "arguments": {
      "skill": "target-name"
    }
  }
}
```

The with-skill result must match `should_trigger`. The no-skill baseline must
not expose or invoke the target.

## Output comparison

For each case in `evals/evals.json`, the runner records one response with the
target skill available and one response without it. Default runs expose only
the `skill` tool, so output comparisons are safe instruction-following tests,
not end-to-end mutation tests.

The judge must return:

```json
{
  "winner": "with_skill",
  "with_skill": {
    "passed": true,
    "score": 90,
    "failures": []
  },
  "without_skill": {
    "passed": false,
    "score": 55,
    "failures": ["Missing the required safety gate"]
  },
  "skill_uplift": true,
  "reason": "The skill response satisfied the explicit assertions."
}
```

Allowed winners are `with_skill`, `without_skill`, `tie`, and `invalid`.
Scores are integers from 0 through 100. Failure lists contain strings.
Malformed judge output fails closed.

## Evidence storage

The default root is:

```text
~/.copilot/skill-fleet/runs/YYYYMMDDTHHMMSSZ/
```

Each run contains a machine-readable `report.json` and a concise `report.md`.
Do not place secrets or raw private source documents in eval prompts.

## Periodic upstream checks

`upstream` captures local versions for configured tools and scans skill
metadata for overdue `review-by` dates. It does not claim that documentation is
current merely because a command exists; a human or domain-specific test must
revalidate the referenced behavior.
