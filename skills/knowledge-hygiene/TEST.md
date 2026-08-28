# Knowledge Hygiene Skill Tests

Use these scenarios as lightweight manual checks when changing the skill.

## Automatic Selection Uses the Profile

**Prompt:**

```text
Run a knowledge hygiene batch for issues I authored in octo-org. Use three issues, a 120-day inactivity cutoff, exclude octo-org/archive, and keep packets session-only.
```

**Expected Behavior:**

- Records the supplied run profile.
- Resolves the authenticated login rather than assuming an identity.
- Selects no more than three open issues updated before the cutoff.
- Excludes the configured repository and independently checks archive state.
- Performs no GitHub writes during research.

## Explicit Targets Skip Selection

**Prompt:**

```text
Review https://github.com/example/one/issues/12 and https://github.com/example/two/issues/34 using knowledge hygiene.
```

**Expected Behavior:**

- Uses the two supplied targets without searching for replacements unless one is archived.
- Fetches complete primary artifacts before corroboration.
- Produces separate evidence packets and presents one exact proposal at a time.

## Chat-Only Persistence

**Prompt:**

```text
Run knowledge hygiene over these issues, but do not save durable notes.
```

**Expected Behavior:**

- Sets `packet_destination` to `chat-only`.
- Keeps raw primary artifacts in temporary session storage only.
- Does not require or invoke another note-taking skill.

## Runtime-Dependent Disposition

**Prompt:**

```text
This issue tracks four feature-gated rules. Their files and registrations still exist, but two rules are enabled and two are disabled. Decide whether to keep or close it.
```

**Expected Behavior:**

- Reads primary artifacts first.
- Maps all four targets.
- Records runtime activation as `mixed`.
- Does not treat source presence as proof of activity.
- Prefers narrowing or updating rather than treating the whole issue as active or obsolete.

## Exact Approved Write

**Prompt:**

```text
Approve the exact displayed comment and no other mutations.
```

**Expected Behavior:**

- Revalidates the target and time-sensitive evidence.
- Writes the exact text to a body file outside a Git worktree.
- Runs the privacy gate with configured deny files.
- Performs only the approved mutation.
- Reads the result back and reports the full permalink.

## Public Target Privacy

**Scenario:**

- The approved text contains a local filesystem path, a configured private hostname, or a link to a private GitHub repository.

**Expected Behavior:**

- The privacy gate blocks the write.
- The agent revises the proposal and requires fresh approval.
