# Run Profile Configuration

## Goal

Make each knowledge hygiene run portable without making its evidence, approval, or write-safety rules optional.

## Profile Fields

Resolve these values at the start of a run:

| Field | Default | Meaning |
|---|---|---|
| `issues` | `[]` | Explicit `OWNER/REPO#NUMBER` targets. When present, skip automatic selection. |
| `author` | Authenticated GitHub login | Issue author used for automatic selection. |
| `repository_scope` | All repositories visible to the authenticated user | Optional owner, organization, or explicit repository list used to narrow search. |
| `batch_size` | `5` | Maximum automatically selected candidates. |
| `inactive_days` | `60` | Candidates must have no issue update within this many days. |
| `excluded_repositories` | `[]` | Repositories that must never be selected or mutated. |
| `packet_destination` | `session-only` | `session-only`, `chat-only`, or a user-approved directory outside a Git worktree. |
| `optional_sources` | `[]` | Additional collaboration, incident, deployment, or telemetry systems available for corroboration. |
| `privacy_deny_files` | `[]` | Files containing additional literal markers that outgoing text must not contain. |

Resolve the authenticated login with:

```sh
gh api user --jq .login
```

Do not guess an organization, repository owner, persistence system, or optional evidence provider.

## Example Profile

```yaml
issues: []
author: octocat
repository_scope:
  owner: octo-org
batch_size: 5
inactive_days: 90
excluded_repositories:
  - octo-org/task-tracker
packet_destination: session-only
optional_sources:
  - deployment-status
privacy_deny_files:
  - /path/outside/a/git-worktree/private-markers.txt
```

This YAML is a conversational contract, not a required file format. The agent may resolve the same values directly from the user's request and state the resulting profile before research.

## Automatic Selection

Calculate the cutoff date from `inactive_days`. Search for open issues authored by `author`, updated before the cutoff, and within `repository_scope` when supplied.

Prefer `gh search issues` with explicit qualifiers. Use a useful mix of:

- Old, low-activity work where a decision could remove confusion.
- Work resurfaced by a newer issue, pull request, discussion, release, incident, or implementation.
- At least one candidate likely to exercise `Update` or `Connect`, not only closure.

For an owner-scoped run, use a query shaped like:

```sh
gh search issues \
  --owner OWNER \
  --author AUTHOR \
  --state open \
  --updated "<CUTOFF_DATE" \
  --archived=false \
  --limit BATCH_SIZE
```

When `repository_scope` is an explicit repository list, search each repository separately and combine the results before applying the batch limit.

Apply `excluded_repositories` before research. Independently verify every remaining repository:

```sh
gh repo view OWNER/REPO --json isArchived,nameWithOwner,url
```

An archived repository is excluded and replaced. It is not automatically a closure candidate.

## Persistence

`session-only` stores raw artifacts and evidence packets in the current agent session's artifact directory. If no session directory exists, use a newly created operating-system temporary directory.

`chat-only` does not create durable packets. It still requires enough structured evidence in the conversation to support each decision.

A configured directory must:

- Be explicitly approved by the user.
- Exist outside every Git worktree.
- Contain no secrets in its path or generated filenames.

Never assume another skill or personal note system is installed. A user may compose one separately after the public workflow completes.

## Optional Sources

GitHub primary artifacts and repository evidence are the baseline. Consult an optional source only when:

- The profile says it is available.
- A specific question cannot be answered from primary and repository evidence.
- The source is authoritative for that question.

Record failed and unauthorized queries. Do not convert unavailable evidence into a positive or negative claim.

## Privacy Extensions

The built-in privacy gate blocks local filesystem references and, for public targets, links to private GitHub repositories.

Organizations may add private literals through `privacy_deny_files`, one marker per line. Matching is case-insensitive. Empty lines and lines beginning with `#` are ignored. Use these files for internal hostnames, note-system syntax, local directory names, or other environment-specific markers that must never leave the organization.

Do not publish private deny files with the skill.
