---
name: dependency-safety
description: Prevents unnecessary dependency installation and audits unavoidable packages. Use before adding, installing, upgrading, or recommending dependencies, packages, libraries, gems, npm modules, pip packages, crates, GitHub Actions, CLIs, or package-manager commands.
---

# Dependency Safety

## Overview

Use this skill whenever a task may add, install, upgrade, replace, or recommend a third-party dependency. The default stance is **do not add dependencies**. A dependency is acceptable only when the agent can explain why local implementation is worse, audit the package and its transitive dependency tree, and preserve secure, reproducible project defaults.

This skill applies to runtime dependencies, development dependencies, package-manager plugins, generated SDKs, CLIs, GitHub Actions, Docker base images, vendored code, language extensions, and framework add-ons.

## Trigger Immediately

Invoke this skill before running or suggesting commands like:

- `npm install`, `yarn add`, `pnpm add`, `bun add`
- `pip install`, `uv add`, `poetry add`
- `bundle add`, `gem install`
- `go get`, `cargo add`
- adding GitHub Actions, Docker images, Homebrew packages, or installer scripts
- editing package manifests, lockfiles, requirements files, Gemfiles, Cargo.toml, go.mod, or action references

Do not install first and review later.

## Default Decision Gate

Before adding a dependency, answer this question:

> Can we implement the needed function ourselves in fewer than 1000 lines of clear, maintainable, tested code?

If yes, do not add the dependency. Implement the focused local code instead.

The 1000-line threshold is an upper bound, not a target. Prefer much smaller local implementations when the need is narrow, stable, and easy to test.

## Dependency Necessity Criteria

Only consider a new dependency when at least one of these is true:

1. The functionality is security-sensitive and safer to rely on a widely reviewed implementation, such as cryptography, authentication protocols, parsers for hostile inputs, TLS, or password hashing.
2. The dependency implements a complex external standard where partial compatibility would create risk.
3. The dependency provides platform integration that would be fragile or impractical to maintain locally.
4. The dependency materially reduces security risk compared with local code and has evidence to support that claim.
5. The user explicitly approves the dependency after seeing the tradeoff.

Do not add dependencies for trivial helpers, formatting, small data transformations, single API wrappers, convenience abstractions, type aliases, or functionality that the language standard library already covers.

## Mandatory Audit Before Adding

If a dependency still appears necessary, audit it before installation or manifest changes:

1. **Fit and scope**: Confirm the package does only what is needed. Prefer small, focused packages over broad frameworks.
2. **Transitive dependency tree**: Inspect direct and transitive dependencies. Avoid packages with large, surprising, duplicated, abandoned, or risky dependency trees.
3. **Maintenance health**: Check recent releases, issue activity, maintainer responsiveness, bus factor, and whether ownership recently changed.
4. **Security history**: Check known advisories, vulnerability databases available through ecosystem tooling, and past incident patterns.
5. **Install-time behavior**: Avoid packages with postinstall scripts, binary downloads, telemetry, network calls, code generation hooks, or native builds unless clearly justified.
6. **Runtime behavior**: Identify file system, network, shell, environment-variable, credential, subprocess, dynamic import, or plugin-loading behavior.
7. **License**: Confirm the license is acceptable for the project.
8. **Versioning**: Pin or lock the exact resolved version using the project’s existing package-manager convention. Avoid floating refs and unpinned GitHub Actions.
9. **Provenance**: Prefer packages with signed releases, provenance attestations, checksums, or ecosystem-native integrity metadata when available.
10. **Alternatives**: Compare at least one lower-risk alternative, including local implementation.

If the audit cannot be completed, stop and ask for approval before adding the dependency.

## Secure Defaults When a Dependency Is Approved

When adding an approved dependency:

- Add the narrowest dependency type possible: development-only, optional, or peer dependency when appropriate.
- Keep dependency scope minimal. Do not add companion packages unless each passes this skill independently.
- Commit manifest and lockfile changes together.
- Prefer exact or locked versions according to repository convention.
- Run the ecosystem’s existing audit, test, build, and type-check commands when available.
- Document why the dependency exists when the reason is not obvious from code.
- Remove unused dependencies discovered during the work instead of adding more around them.

## Package Manager Hygiene

Use the package manager already used by the project. Do not introduce a new package manager unless the user explicitly asks.

Prefer commands that avoid unrelated churn:

- npm: respect existing `package-lock.json`; avoid lockfile rewrites unrelated to the package.
- pnpm/yarn/bun: preserve the existing lockfile and workspace conventions.
- Python: respect the existing tool, such as `uv`, `poetry`, `pip-tools`, or requirements files.
- Go: inspect `go mod tidy` output carefully and do not accept unrelated module churn.
- Ruby: preserve `Gemfile.lock` and grouping conventions.
- Rust: prefer minimal feature flags and inspect `Cargo.lock` changes.

## Red Flags

Treat these as reasons to reject or escalate:

- package is deprecated, unmaintained, newly published, or has very low adoption for its risk level
- maintainer or ownership changed recently without clear continuity
- obfuscated, minified, generated, or unusually large package contents
- postinstall scripts, binary blobs, shell execution, or network access during install
- broad permission requirements
- typosquatting or brand confusion risk
- dependency tree is much larger than the feature justifies
- existing standard-library or first-party project helper already covers the need
- license is missing, custom, unclear, or incompatible

## Agent Output Requirements

When this skill triggers, report the dependency decision briefly:

- **Avoided**: name the local implementation path and why it is under the 1000-line threshold.
- **Approved**: name the package, version constraint, why local implementation is worse, audit result, and follow-up validation.
- **Blocked**: name what could not be audited and ask for user approval before proceeding.

Keep the report concise. Do not bury the dependency decision in general implementation details.

## Example Prompts

- "Install a date formatting package."
- "Add a package for parsing this file."
- "Can we use a GitHub Action for this?"
- "Add the SDK for this API."
- "This project needs dependencies installed."
- "Run npm install."

## Source Expertise

This skill is grounded in its existing workflow instructions and conventions. It captures the reusable workflow for dependency addition, installation, upgrade, package-manager, and supply-chain safety checks.

No extra reference file is required by default; load source files only when the task needs that context.

## Anchored Workflow

### Deterministic prefix

1. Confirm the user's request matches this skill's scope: dependency addition, installation, upgrade, package-manager, and supply-chain safety checks.
2. Load only the needed local instructions, references, scripts, assets, and source files.
3. Resolve required identifiers, paths, dates, accounts, repositories, or output destinations before drafting or acting.

### AI decision step

Use AI judgment for bounded interpretation: selecting relevant context, classifying the request, drafting the response or artifact, and identifying risks, gaps, or follow-up questions.

### Validation step

Before side effects or completion claims, validate that the output follows this skill's contract, required inputs are present, citations or evidence are attached when needed, and any repo/tool-specific checks have passed or are explicitly reported as unavailable.

### Deterministic suffix

Only after validation, write files, run scripts, call APIs, post messages, create commits, or return the final artifact. Keep side effects scoped to the confirmed task.

## Output Contract

Return the smallest useful artifact for the request. It must include:

1. The concrete result or draft requested by the user.
2. Source paths, links, commands, or evidence when the work depends on retrieved context.
3. Any blocking gaps, assumptions, or validation that could not be completed.
4. A saved file path, commit SHA, rendered artifact, or posted destination when a side effect was explicitly requested and completed.

## Validation Gates

- The frontmatter description must remain scoped to this skill and not trigger on near-miss tasks.
- Required inputs must be explicit before running tools or writing files.
- Generated files or final outputs must match the conventions that apply to the target repository, service, document, or artifact type.
- Evals in `evals/evals.json` and `evals/trigger-queries.json` should be updated when new edge cases appear.
- If validation cannot run, say so directly and do not claim the side effect is complete.

## Tool and Action Safety

- Do not perform destructive, externally visible, or hard-to-reverse actions without explicit approval.
- Do not expose private or sensitive data beyond what the user asked to use.
- Do not silently skip failed tool calls, missing permissions, ambiguous identifiers, or empty result sets.
- No bundled script is required by default.

## Gotchas

- This skill should bias toward avoiding new dependencies, not just approving the requested install.
- Do not broaden this skill into adjacent workflows just because the topic sounds related.
- Preserve the user's communication and git hygiene preferences when drafting, committing, posting, or saving artifacts.

## Examples

Should trigger:

- "before installing this npm package, check whether we really need it"

Should not trigger:

- "run the existing test suite with no dependency changes"

## Evaluation Plan

Use `evals/evals.json` for task-quality checks and `evals/trigger-queries.json` for activation checks. Compare outputs with and without this skill; the skill should improve trigger precision, context loading, output structure, validation, and safety boundaries for dependency addition, installation, upgrade, package-manager, and supply-chain safety checks.
