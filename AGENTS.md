# Skills Agent Guide

These instructions apply to the whole repository unless a deeper `AGENTS.md` overrides them.

## Mission

Maintain @jonmagic's portable Agent Skills as small, inspectable, publicly installable packages.

## Start Here

1. Read `README.md`, this file, and the target skill's `SKILL.md` before editing.
2. Check `git status --short` and preserve unrelated user changes.
3. Treat every skill as public content: do not include credentials, private local paths, internal-only URLs, personal notes, customer data, or confidential procedures.

## Git Workflow

1. Work directly on `main`.
2. Do not create branches, worktrees, or pull requests unless @jonmagic explicitly requests one.
3. Fast-forward `main` before editing: `git fetch --prune origin && git pull --ff-only`.
4. Make focused commits and push them directly with `git push origin main`.
5. Never force-push or rewrite published history.

## Skill Workflow

1. Keep each skill under `skills/<name>/` with `name` matching the directory.
2. Prefer `SKILL.md`, `README.md`, `TEST.md`, and optional `references/`, `examples/`, `scripts/`, or `assets/`.
3. Keep skills self-contained and avoid required cross-skill dependencies.
4. Use progressive disclosure: keep core instructions focused and move optional depth into references.
5. Update behavioral tests and the generated README skill list when descriptions or skill inventory change.
6. Validate the repository with `gh skill publish . --dry-run`.

## Quality and Safety

1. Do not estimate timelines unless explicitly asked.
2. Use direct verification before model escalation.
3. Add one independent reviewer only for high-stakes, ambiguous, security-sensitive, privacy-sensitive, or broad workflow changes.
4. Before every commit, inspect the staged file list and scan the staged diff for credentials, private paths, internal URLs, and unintended files.
5. When an agent miss reveals a durable gap, improve the smallest useful instruction, test, script, or guardrail.

## Task Exit Criteria

1. Only intended files are committed.
2. Skill validation passes or the exact pre-existing blocker is documented.
3. Public installation instructions remain accurate.
4. The commit is pushed to `origin/main`.
