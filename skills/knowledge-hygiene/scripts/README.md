# Scripts

## `fetch-primary-artifacts`

Captures authenticated issue evidence and an exact command audit outside every Git worktree.

```sh
scripts/fetch-primary-artifacts --output DIR OWNER/REPO#NUMBER [...]
```

Exit codes:

- `0`: Every candidate was active and captured.
- `2`: Archived repositories were recorded as exclusions; replace them and rerun into a fresh output directory.
- `1`: Hard failure; stop the batch.

The output directory must be empty. The script rejects pull requests, repositories without issues, malformed JSON, unreadable primary artifacts, and output paths inside Git worktrees.

## `privacy-gate`

Checks the exact outgoing body before a GitHub write.

```sh
scripts/privacy-gate \
  --body FILE \
  --target OWNER/REPO \
  [--deny-file FILE ...]
```

It blocks local filesystem and note references. For public targets, it also blocks GitHub, raw-content, and `OWNER/REPO#NUMBER` references to private repositories. Optional deny files add case-insensitive environment-specific literal markers without embedding private details in the public skill.

## Tests

```sh
ruby test/fetch_primary_artifacts_test.rb
ruby test/privacy_gate_test.rb
```
