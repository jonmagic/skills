---
name: semantic-commit
description: Generate semantic commit messages from staged changes. Use when committing code to produce consistent, well-structured commit messages following conventional commit format.
---

# Semantic Commit

Generate commit messages following the conventional commit format: `<type>(<scope>): <subject>`

## Format

```
<type>(<scope>): <subject>

<body>
```

- **type**: Required. Category of change.
- **scope**: Optional. Omit if unclear or not valuable.
- **subject**: Present tense, no period, under 72 chars.
- **body**: Optional. Explain what/why, not how. Wrap at 72 chars.

## Types

| Type | Use for |
|------|---------|
| `feat` | New user-facing feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace (no logic change) |
| `refactor` | Code change that doesn't fix or add |
| `test` | Adding or updating tests |
| `chore` | Build, CI, dependencies |

## Rules

1. Subject line under 72 characters
2. Present tense ("add" not "added")
3. No period at end of subject
4. Blank line between subject and body
5. Body explains what/why, wrapped at 72 chars
6. Single-line OK for trivial changes
7. Non-trivial changes should include body

## Examples

**Trivial:**
```
docs: fix typo in readme
```

**Simple with scope:**
```
feat(auth): add password reset flow
```

**With body:**
```
fix(api): handle empty response from upstream

Add null check before parsing response body. Previously, empty
responses from the payments service caused JSON parse errors.
```

## Workflow

1. Review staged changes with `git diff --cached`
2. Identify the primary type and optional scope
3. Write subject summarizing the change
4. Add body for non-trivial changes explaining what/why
5. Commit using HEREDOC format for proper formatting
