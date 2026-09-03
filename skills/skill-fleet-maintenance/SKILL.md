---
name: skill-fleet-maintenance
description: Use this skill when auditing, validating, evaluating, or maintaining a fleet of agent skills. Covers structural validation, trigger tests, with-skill versus without-skill output comparisons, upstream freshness snapshots, and evidence reports. Do not use for ordinary single-skill tasks unless fleet health or eval quality is in scope.
compatibility: Requires Ruby and read access to the skill directories being evaluated. Optional dynamic evaluations also require the GitHub Copilot CLI.
license: ISC
metadata:
  owner: "@jonmagic"
  source: "https://github.com/jonmagic/skills"
---

# Skill Fleet Maintenance

Maintain a fleet of Agent Skills with deterministic validation, and reach for
model-driven evaluation only when activation or workflow behavior is actually in
question.

All commands below run from the installed skill directory. Set `SKILL_DIR` to
that directory once, then reuse it:

```sh
SKILL_DIR=~/.copilot/skills/skill-fleet-maintenance
```

Adjust the value if the skill is installed at a project or plugin scope instead.

## Workflow

1. Run static validation before changing names, paths, references, or evals.
   This is the default check for ordinary maintenance:

   ```sh
   "$SKILL_DIR/scripts/skill-fleet" validate
   ```

2. Fix one logical skill package at a time and rerun validation against that
   root before moving on:

   ```sh
   "$SKILL_DIR/scripts/skill-fleet" validate --root path/to/skills/my-skill
   ```

3. Capture installed tool versions and overdue metadata review dates:

   ```sh
   "$SKILL_DIR/scripts/skill-fleet" upstream
   ```

4. Report findings with the file and line evidence that produced them. Static
   validation is sufficient for renames, reference fixes, metadata updates, and
   eval schema changes.

Static validation and the upstream snapshot are the maintenance defaults. They
are deterministic, run offline, and consume no model credits.

## Optional Model Evaluations

Formal model evals are optional. Run them when activation or workflow behavior is
disputed or changed, not as routine maintenance:

- Trigger evals when a description, name, or scope boundary changes and you need
  evidence that the skill activates on the right requests:

  ```sh
  "$SKILL_DIR/scripts/skill-fleet" run SKILL_NAME --trigger-only
  ```

- Output comparisons when instructions or the workflow change and you need
  evidence that the skill improves the response:

  ```sh
  "$SKILL_DIR/scripts/skill-fleet" run SKILL_NAME --output-only
  ```

Skip both when the change is a typo fix, a formatting pass, or an edit that
static validation already covers. Dynamic runs consume model credits and are
non-deterministic, so treat a single run as weak evidence.

Evidence is written under `~/.copilot/skill-fleet/runs/` by default. It must not
contain credentials or raw private source material.

## Anchored Evaluation Contract

### Deterministic prefix

- Discover skill packages from `copilot skill list --json`, or from explicit
  `--root` paths when the CLI is unavailable.
- Resolve symlinks and deduplicate canonical paths.
- Parse frontmatter, local references, eval JSON, metadata dates, and line
  counts without model judgment.
- Isolate dynamic runs in a temporary `COPILOT_HOME`.

### AI decision

Use the model only for:

- deciding whether a trigger query invokes the target skill
- producing the with-skill and without-skill responses
- judging those responses against explicit assertions

The actual skill invocation is measured from `tool.execution_start` events,
not from the model's self-report.

### Validation

- Parse every JSONL event and judge response.
- Validate judge output against the schema in
  `references/EVALUATION-CONTRACT.md`.
- Fail closed on malformed output, missing evidence, unexpected skill
  availability, command failure, or assertion failures.
- Never enable tools beyond `skill` during default eval runs.

### Deterministic suffix

Write JSON and Markdown evidence only after validation. Dynamic runs do not
edit skills, call remote MCP servers, or perform external writes.

## Safety

- Never pass secrets, customer content, private messages, or raw internal
  documents into eval prompts.
- Do not use `--allow-all`, browser automation, or MCP servers.
- Keep output evals advisory unless a human explicitly supplies a narrow tool
  profile for a separate test harness.
- Treat generated scoring as evidence to review, not an automatic permission to
  publish, delete, rename, or install anything.
- Stop if a skill cannot be isolated or the baseline unexpectedly contains it.

## Output

`validate` returns structural errors and warnings; errors exit non-zero and
`--strict` also fails on warnings. `run` records the prompt, isolated skill
inventory, invocation events, model responses, judge result, usage events, and
command status. `upstream` records local tool versions and flags overdue
`review-by` metadata.

See `references/EVALUATION-CONTRACT.md` for schemas and interpretation, and
`references/upstreams.yml` for the tool checks the upstream snapshot runs.

## Examples

Should trigger:

- "Run the skill fleet validator."
- "Which skill evals are generic or missing?"
- "Recheck upstream freshness metadata for all skills."
- "Compare this skill with and without its instructions."

Should not trigger:

- "Use the Slack skill to find a message."
- "Create a D2 diagram."
- "Fix one typo in this SKILL.md."
