---
name: knowledge-hygiene
description: Runs bounded, evidence-first reviews of old or confusing GitHub issues with complete primary-artifact research, current-state corroboration, conversational approval, exact writes, and verification. Use when deciding whether to keep, update, connect, consolidate, deprecate, close, or escalate lingering issues. Do not use for ordinary sprint triage, creating issues, or bulk stale automation.
compatibility: Requires gh, Ruby, and authenticated access to the relevant GitHub repositories.
license: ISC
metadata:
  version: "1.0"
---

# Knowledge Hygiene

## Overview

Run bounded reviews of old or confusing GitHub issues. Age and inactivity may select candidates, but primary artifacts and current evidence determine each disposition.

This is not stale automation. The goal is to help the user make one defensible decision at a time, execute only explicitly approved actions, and improve the workflow without silently weakening its safeguards.

## When to Use

Use this skill for requests such as:

- "Run a knowledge hygiene batch over my old issues."
- "Find five lingering issues and help me decide what to do with them."
- "Review these old issues for keep, update, connection, consolidation, or closure."
- "Continue the knowledge hygiene approval loop."

Do not use it for:

- Ordinary issue triage or sprint planning.
- Creating a new issue.
- Bulk closing, labeling, assigning, or commenting.
- Repository cleanup that is not centered on issue knowledge quality.

## Run Profile

Before selecting candidates, resolve a run profile using [references/configuration.md](references/configuration.md). Use supplied values and otherwise apply the documented defaults.

The profile controls:

- Candidate author, repository scope, batch size, and inactivity cutoff.
- Explicit issue targets and excluded repositories.
- Where evidence packets are persisted.
- Optional corroboration sources.
- Additional literal privacy markers for outgoing text.

Configuration may narrow scope or add safeguards. It must not disable the required operating rules below.

## Required Operating Rules

1. Authenticate with `gh auth status` before researching. Stop on failure.
2. Search only active repositories. Repository archive state is a selection gate, not a disposition.
3. Read each issue body, every comment, and the complete timeline before repository history, code, collaboration systems, or telemetry.
4. Treat prior packets and user-provided notes as unverified context, never as primary evidence.
5. Before recommending a disposition, explicitly test whether shipped work superseded the issue.
6. When the disposition depends on whether named behavior currently executes, query its authoritative runtime control. Source presence and consumer wiring are not runtime evidence.
7. For issues with multiple targets, evaluate supersession and runtime activation target by target.
8. Surface supersession status, runtime activation status, evidence source, and observation time in the conversational approval material.
9. Do not write to GitHub during research.
10. Use ordinary conversation for approvals. Show the exact target, mutations, and complete outgoing text.
11. Approval applies only to the displayed target, text, and actions. Revisions require fresh approval.
12. Treat disposition, assignment, labels, milestone, and project placement as separate decisions.
13. If revalidation differs from the approved state or evidence, stop, show the drift, revise the proposal, and require fresh approval.
14. Every closure proposal must specify the GitHub state reason: `completed`, `not planned`, or `duplicate`, including the duplicate target when applicable.
15. Before writing, revalidate state and time-sensitive claims, run the deterministic privacy gate, use an exact body file, and read the result back including `stateReason`.
16. Do not create GitHub issues within this workflow. If the user explicitly asks to create a canonical replacement, stop the hygiene loop and handle that as a separate issue-creation task.
17. Propose reusable skill improvements after the run; never silently edit the skill.

## Anchored Workflow

1. Load [references/workflow.md](references/workflow.md).
2. Resolve the run profile.
3. Select or accept a bounded batch, normally five issues.
4. Use `scripts/fetch-primary-artifacts` to verify repository state and capture issue bodies, comments, and timelines outside a Git worktree.
5. Read primary artifacts before corroboration.
6. Produce one evidence packet per actionable issue using [assets/evidence-packet-template.md](assets/evidence-packet-template.md).
7. Persist packets only as configured. Session-only persistence is the default.
8. Summarize the full batch in chat and immediately present item one.
9. After explicit approval, execute and verify only the exact action, report the full permalink, and immediately present the next item.
10. At completion, record outcomes and use [references/self-improvement.md](references/self-improvement.md) to propose the smallest durable workflow improvement.

## Dispositions

- **Keep:** Still accurate and useful.
- **Update:** Still needed, but facts, status, links, ownership, or instructions are incomplete or wrong.
- **Connect:** Link useful evidence to current work.
- **Consolidate:** Move useful content toward a canonical artifact.
- **Deprecate:** Preserve history but add an explicitly approved current-status signal, such as a comment, body notice, or label. The disposition does not imply a fixed mutation.
- **Close or archive:** The need is gone, completed elsewhere, duplicated, superseded, abandoned, or no longer worth carrying.
- **Escalate:** Evidence requires an owner decision.

Archived-repository exclusions are not dispositions.

## Completion Checklist

- The run profile and defaults used are recorded.
- Every selected repository was independently checked for archive state.
- Every automatically selected issue was open and older than the configured inactivity cutoff when selected.
- Every issue body, all comments, and complete timeline were read successfully.
- Every packet records one supersession status: `none`, `partial`, `full`, or `unknown`.
- Every packet records one runtime activation status: `active`, `inactive`, `mixed`, `not applicable`, or `unknown`.
- Multiple named targets were evaluated separately.
- Research and GitHub writes remained separate.
- Every write had explicit conversational approval.
- Every outgoing body passed the privacy gate and was posted exactly.
- Every result was read back and reported with a full GitHub permalink.
- Outcomes, exclusions, evidence gaps, failed commands, and proposed improvements were recorded in the configured destination.
