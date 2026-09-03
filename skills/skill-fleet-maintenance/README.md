# Skill Fleet Maintenance

Skill Fleet Maintenance keeps a collection of Agent Skills healthy with deterministic checks first and model-driven evaluation only when it is warranted.

Static validation finds the failures that actually break skills: invalid frontmatter, names that do not match their directory, duplicate names, broken local references, malformed eval JSON, missing trigger coverage, non-falsifiable assertions, and overdue freshness metadata. None of it requires a model.

Optional dynamic evaluations add evidence when activation or workflow behavior is disputed or changed. They run each skill in an isolated temporary Copilot home, measure invocation from `tool.execution_start` events instead of the model's self-report, and fail closed on malformed judge output.

## Install

With APM:

```sh
apm install -g jonmagic/skills --skill skill-fleet-maintenance
```

With GitHub CLI:

```sh
gh skill install jonmagic/skills skill-fleet-maintenance --scope user
```

## Usage

Point `SKILL_DIR` at the installed skill, then run the validator:

```sh
SKILL_DIR=~/.copilot/skills/skill-fleet-maintenance
"$SKILL_DIR/scripts/skill-fleet" validate
```

Validate a single skill package while iterating on it:

```sh
"$SKILL_DIR/scripts/skill-fleet" validate --root path/to/skills/my-skill --format json
```

Capture installed tool versions and overdue `review-by` metadata:

```sh
"$SKILL_DIR/scripts/skill-fleet" upstream
```

`validate` exits non-zero when there are errors, and with `--strict` it also fails on warnings, so it works as a pre-commit or CI gate.

## Optional Model Evaluations

Model evals are not part of ordinary maintenance. Run them when a description, scope boundary, or workflow changes and you need evidence about real behavior:

```sh
"$SKILL_DIR/scripts/skill-fleet" run my-skill --trigger-only
"$SKILL_DIR/scripts/skill-fleet" run my-skill --output-only
```

These runs require the GitHub Copilot CLI, consume model credits, and are non-deterministic. Evidence lands in `~/.copilot/skill-fleet/runs/` as a machine-readable `report.json` and a short `report.md`.

## Eval Files

Each skill under evaluation may provide `evals/trigger-queries.json` and `evals/evals.json`. The validator checks their schema, positive and negative trigger coverage, and assertion specificity even when no dynamic run happens.

See [references/EVALUATION-CONTRACT.md](references/EVALUATION-CONTRACT.md) for the full schemas and interpretation rules, and [evals/README.md](evals/README.md) for this skill's own suites.

## Tests

```sh
ruby test/skill_fleet_test.rb
```

The test suite uses a fake Copilot binary, makes no network calls, and consumes no credits. See [TEST.md](TEST.md) for behavioral scenarios.
