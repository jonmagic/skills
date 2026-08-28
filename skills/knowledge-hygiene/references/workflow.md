# Knowledge Hygiene Workflow

## 1. Prepare

1. Resolve and state the run profile from [configuration.md](configuration.md).
2. Run `gh auth status`. Stop on failure.
3. Resolve a session or operating-system temporary artifact directory outside every Git worktree.
4. Load prior packets only when the user supplies or configures them. Treat them as unverified context.

## 2. Select Candidates

If the profile supplies `issues`, validate those exact targets. Otherwise select up to `batch_size` open issues authored by `author` and updated before the `inactive_days` cutoff.

Apply the repository scope and exclusion list. Search only active repositories, then independently verify every repository:

```sh
gh repo view OWNER/REPO --json isArchived,nameWithOwner,url
```

Replace archived candidates. Do not recommend mutations in archived repositories.

Do not select an issue merely because it is old. Prefer candidates where a disposition could reconnect useful work, clarify reality, or remove a misleading commitment.

## 3. Capture Primary Artifacts

Run:

```sh
<skill-dir>/scripts/fetch-primary-artifacts \
  --output <artifact-directory> \
  OWNER/REPO#NUMBER [...]
```

The script:

- Checks GitHub authentication.
- Refuses to store raw artifacts in a Git worktree.
- Verifies repository archive state and issue support, and captures visibility and viewer permission.
- Rejects pull requests supplied as issue candidates.
- Retrieves issue body, comments, state reason, project and hierarchy metadata, labels, assignments, and URL.
- Retrieves the complete timeline with pagination.
- Writes an exact command audit and raw JSON.
- Fails closed on unreadable primary artifacts.

Show the command audit and whether each command succeeded. If any body, comments, or timeline cannot be read, stop the batch.

Exit codes:

- `0`: Every candidate was active and captured.
- `2`: One or more repositories were archived. Select replacements and rerun the complete batch into a fresh output directory.
- `1`: Authentication, validation, lookup, retrieval, or parsing failed. Stop the batch.

Every run requires a new or empty output directory.

## 4. Read Before Corroborating

For each active candidate:

1. Read the full issue body.
2. Read every comment.
3. Read the complete timeline.
4. Explain labels, assignments, reopen events, project changes, and explicit human decisions.
5. Only then inspect the minimum current evidence needed to test the issue's premise.

Project placement is evidence to explain, not proof that an old issue remains actionable.

## 5. Corroborate Minimally

Prefer this order:

1. Linked GitHub issues, pull requests, commits, releases, and discussions.
2. Repository-scoped code, configuration, documentation, ownership, and current state.
3. Current epics, incidents, or projects revealed by timelines or exact searches.
4. Configured optional sources only when they are authoritative for a remaining question.

Ask four separate questions:

1. Does current evidence show that the original premise still exists?
2. If the issue states a diagnosis or root cause, did the final incident record or merged fix confirm or disprove it?
3. Does a newer canonical artifact show that the old issue is no longer the correct tracker?
4. Even if the premise remains true, is this still a focused, actionable tracker worth carrying?

### Supersession Check

Record one status: `none`, `partial`, `full`, or `unknown`.

- Search for the requested outcome, not only matching terminology.
- Distinguish a newer tracker from shipped implementation.
- For `full`, identify evidence covering the complete original need.
- For `partial`, list completed and remaining scope.
- If implementation evidence cannot be read, record `unknown`.

### Runtime Activation Check

Record one status: `active`, `inactive`, `mixed`, `not applicable`, or `unknown`.

- Use this check when source can exist while execution is disabled and the disposition depends on current execution.
- Map each named target to current source and registration or consumer wiring.
- Identify and query the authoritative runtime control for each target.
- Source presence and consumer wiring do not prove current execution.
- A disabled control proves inactivity at the observation time, not permanent obsolescence.
- For multiple targets, record each state. Use `mixed` when states differ.
- Include the runtime source and observation time.
- Use `unknown` only after an attempted query fails, access is denied, or no authoritative control can be identified.
- If `not applicable` is selected, explain why runtime state cannot affect the disposition.

### Disposition Gates

- Do not recommend closure because related code exists or the issue is old.
- Do not recommend `Keep` solely because target files or checklist items still exist.
- Do not use close reason `completed` on supersession grounds unless supersession is `full`.
- With `partial` supersession, prefer narrowing, `Update`, `Connect`, or another non-closure disposition unless independent evidence accounts for all remaining scope.
- A runtime-dependent disposition requires a status other than `unknown`, unless the recommendation is explicitly to investigate or escalate the missing state.
- When evidence conflicts, describe the conflict and lower confidence.

## 6. Produce Evidence Packets

Use [../assets/evidence-packet-template.md](../assets/evidence-packet-template.md).

Each packet must include:

1. Full issue URL and repository archive status.
2. Original need in plain language.
3. Primary evidence from body, comments, and timeline.
4. What happened afterward.
5. Supersession status and canonical evidence.
6. Runtime activation status, target by target when applicable.
7. Current truth and knowledge problem.
8. Connections to current work.
9. One recommended disposition and calibrated confidence.
10. Remaining uncertainty.
11. Comparison with any prior packet.
12. Ownership evidence and any assignment recommendation, separate from disposition.

Use repository permission evidence when proposing actions. If issues are disabled, stop. With read-only permission, do not propose mutations.

## 7. Persist the Decision Material

Follow `packet_destination`:

- `session-only`: write the batch packet beside the raw artifacts.
- `chat-only`: keep the structured packet in the conversation.
- Approved directory: write one batch packet there, after confirming it is outside a Git worktree.

Include the run profile, access audit, exclusions, evidence packets, recommended order, exact proposal for item one, and an execution log.

## 8. Run the Conversational Approval Loop

In ordinary chat:

1. Give a concise summary of all batch items.
2. Immediately present item one.
3. State decisive evidence, supersession status, runtime activation status with source and observation time, exact mutations, and complete outgoing text.
4. For closure, state `completed`, `not planned`, or `duplicate`.
5. State assignment, labels, milestone, and project changes separately.
6. Ask for approval, edits, or skip.

After approval:

1. Re-read the target issue and time-sensitive evidence.
2. Stop for fresh approval if anything material changed.
3. Save the exact approved text to a body file outside every Git worktree.
4. Build the privacy command with every configured deny file:

```sh
<skill-dir>/scripts/privacy-gate \
  --body <body-file> \
  --target OWNER/REPO \
  --deny-file <optional-deny-file>
```

5. Perform only the approved mutations, and pass the gated file directly to the write command. For a comment, use `gh issue comment --body-file <body-file>` rather than reconstructing the text.
6. Read the issue back and verify exact comment body, issue state, `stateReason`, labels, assignments, and permalink.
7. Report the full permalink and immediately present the next item.

## 9. Complete and Learn

Report exclusions, outcomes, full permalinks, skipped proposals, evidence gaps, and failed commands. Update the configured execution log, then load [self-improvement.md](self-improvement.md).
