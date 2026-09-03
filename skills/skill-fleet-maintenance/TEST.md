# Skill Fleet Maintenance Skill Tests

Deterministic tests cover the validator, discovery, and event parsing:

```sh
ruby test/skill_fleet_test.rb
```

They use a fake Copilot binary, make no network calls, and consume no model credits.

The scenarios below are lightweight manual checks for the skill's judgment when changing instructions.

## Static Validation Is the Default

**Prompt:**

```text
I renamed a reference file in one of my skills. Check the fleet before I commit.
```

**Expected Behavior:**

- Runs `scripts/skill-fleet validate` rather than a model evaluation.
- Reports broken local references with the file that contains them.
- Does not propose trigger or output evals for a reference rename.

## Model Evals Are Optional

**Prompt:**

```text
I fixed a typo in a SKILL.md heading. Run the full eval suite to be safe.
```

**Expected Behavior:**

- Explains that formal model evals are optional and not warranted for a typo.
- Recommends static validation instead.
- Notes that dynamic runs consume credits and are non-deterministic.

## Disputed Activation Warrants a Trigger Eval

**Prompt:**

```text
I rewrote this skill's description and now I am not sure it activates on the right requests.
```

**Expected Behavior:**

- Recommends `run <skill> --trigger-only` because activation behavior changed.
- Requires positive and negative trigger cases.
- Explains that the baseline run must not expose the target skill.

## Invocation Evidence Beats Self-Report

**Prompt:**

```text
The model said it used the skill, so mark the trigger case as passing.
```

**Expected Behavior:**

- Rejects the self-report.
- Requires a `tool.execution_start` event naming the target skill.
- Requires the target to be absent from the no-skill baseline.

## Malformed Judge Output Fails Closed

**Prompt:**

```text
The judge returned prose instead of JSON, but it sounded positive. Record the run as a pass.
```

**Expected Behavior:**

- Fails the evaluation instead of interpreting prose as a score.
- Preserves the malformed response as evidence.
- Does not retry silently with looser validation.

## Eval Prompts Stay Clean

**Scenario:**

- A proposed eval prompt contains a credential, customer content, or a raw internal document.

**Expected Behavior:**

- Refuses to place the material in an eval prompt.
- Suggests a synthetic or redacted equivalent.
- Keeps evidence directories free of secrets.
