# Principal Engineer Review

Understand and review PRs, branch diffs, and code-adjacent designs with a principal engineer as your pair partner.

Use this skill when you need enough system context to participate in a review, followed by high-signal feedback on correctness, security/privacy, reliability, MVP scope, maintainability, reuse of existing primitives, and whether the review handoff contains enough reasoning for others to trust the change.

## When to Use This Skill

- Selecting and reviewing your next pending GitHub review request with `/principal-engineer-review next`
- Reviewing a pull request before approving or requesting changes
- Building enough context to review an unfamiliar pull request
- Asking follow-up questions about terminology, execution paths, tests, alternatives, and risk
- Reviewing local diffs before opening a PR
- Checking whether a change is overbuilt, under-tested, or missing important context
- Asking for a principal engineer perspective on a code-adjacent design or implementation plan
- Turning established review findings into concise draft comments when requested

## Installation

```bash
apm install -g jonmagic/skills --skill principal-engineer-review
```

Or install with GitHub CLI:

```bash
gh skill install jonmagic/skills principal-engineer-review --scope user
```

## Quick Start

```text
/principal-engineer-review next
```

`next` selects the most recently updated, non-draft PR you have not reviewed yet. It prioritizes direct review requests, then falls back to team review requests. The skill returns its analysis for your review before drafting or posting a GitHub response.

## What It Does

- Finds the next eligible review request without asking for a PR URL
- Reads the intended business problem before judging the implementation
- Builds a compact mental model of the behavior before and after the change
- Adapts explanation depth to what the reviewer already understands
- Uses progressive disclosure instead of dumping a repository tour
- Supports conversational deep dives into paths, terms, tests, alternatives, and findings
- Matches review depth to behavior and blast radius instead of the changed-file list
- Reviews stacked and dependent PRs through layer, cumulative, and intermediate-state views
- Distinguishes merge readiness from program activation and assigns findings to the layer that owns the fix
- Traces high-risk changes through consumers of the changed invariant or implicit contract
- Verifies rollout-critical metric names, tags, logs, dashboards, and alerts as compatibility surfaces
- Prioritizes material findings over style or formatting nits
- Checks for existing primitives before accepting new helpers, dependencies, queues, storage, or abstractions
- Separates blocking review feedback from non-blocking follow-up
- Calls out missing reasoning when reviewers cannot evaluate safety, rollback, validation, or scope from the PR alone
- Uses an optional design lens for architecture, API, platform, and service-boundary reviews without turning ordinary PR review into a law catalog
- Produces a structured evidence handoff that preserves finding identity, ownership, reachability, and review freshness
- Keeps private review deliberation out of recipient-facing comments unless the visible thread establishes that context
- Drafts concise review comments on request and requires exact approval before posting
- Stops after the review package in `next` mode so you can inspect the findings before working on the response

See `SKILL.md` for the full workflow.
