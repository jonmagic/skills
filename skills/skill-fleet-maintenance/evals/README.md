# Skill Fleet Maintenance Evals

Run the deterministic tests from the skill directory:

```sh
ruby test/skill_fleet_test.rb
```

Validate this skill's own package:

```sh
scripts/skill-fleet validate --root .
```

Optional: run the skill's own trigger suite when its description or scope changes:

```sh
scripts/skill-fleet run skill-fleet-maintenance --trigger-only
```

Dynamic runs consume model credits and require the GitHub Copilot CLI. The static
test suite uses a fake Copilot binary and performs no network calls.

## Files

- `trigger-queries.json` — positive and negative activation cases.
- `evals.json` — output comparison cases with explicit, falsifiable assertions.
