---
name: brain-commit
description: Analyze changes in the Brain repo and create semantic commits. Use when the user wants to commit their brain changes with meaningful, organized commit messages. Analyzes staged/unstaged changes, groups related files, creates appropriate commits, and pushes without user interaction.
---

# Brain Commit

Intelligently commit changes to the Brain repository (`~/Brain`) with semantic commit messages, then push to the remote. This skill is non-interactive: it should do its best without asking for confirmation.

## Workflow

1. **Navigate to Brain**: `cd ~/Brain`

2. **Sync from remote (non-interactive, prefer remote changes)**:
   - `git pull --rebase --autostash -X theirs`
   - If rebase fails, fallback to merge without prompts: `git rebase --abort` then `git pull --no-rebase -X theirs --no-edit`

3. **Check status**: Run `git status` to see what's changed

3. **Analyze changes**: Group files by type/purpose:
   - `Weekly Notes/` → `docs(weekly): ...`
   - `Daily Projects/` → `docs(daily): ...`
   - `Meeting Notes/` → `docs(meetings): ...`
   - `Snippets/` → `docs(snippets): ...`
   - `Executive Summaries/` → `docs(summaries): ...`
   - `Transcripts/` → `docs(transcripts): ...`
   - `Projects/` → `docs(projects): ...`
   - `Archive/` → `chore(archive): ...`
   - Skills/config files → `chore: ...`
   - Multiple directories in one logical session → can combine if related

4. **Create commits**: For each logical group:
   - Stage the related files: `git add <files>`
   - Commit with semantic message: `git commit -m "type(scope): description"`

6. **Push**: `git push` after all commits are created

7. **Report**: Show what was committed and pushed

## Semantic Commit Format

```
type(scope): short description

- Optional bullet points for details
```

### Types for Brain
- `docs` - Most content (notes, projects, snippets)
- `chore` - Maintenance (archiving, config changes)
- `feat` - New templates or structural additions

### Scopes
- `weekly` - Weekly Notes
- `daily` - Daily Projects
- `meetings` - Meeting Notes
- `snippets` - Snippets
- `summaries` - Executive Summaries
- `transcripts` - Transcripts
- `projects` - Projects folder
- `archive` - Archive folder

## Examples

### Single directory changed
```
docs(daily): add queue outcomes migration plan

- Researched spamurai-next and hamzo codebases
- Documented migration approach for 14 outcomes
- Created implementation checklist
```

### Multiple related changes
```
docs(weekly): update week of 2026-01-11

- Added TODO items
- Logged Monday activities
```

### Mixed changes (multiple commits)
First commit:
```
docs(daily): add auto-archive queue entries plan
```

Second commit:
```
docs(meetings): add notes from team sync
```

## Edge Cases

- **No changes**: Report "Nothing to commit, working tree clean"
- **Only untracked files**: Add them to the most sensible group and proceed
- **Large number of files**: Group by directory, don't create too many commits
- **Single file change**: One simple commit is fine
- **Non-fast-forward push**: Re-run the sync step once, then retry push

## Safety

- Always show what will be committed before committing, but do not pause for confirmation
- Conflict resolution strategy: always prefer remote changes by using `-X theirs` during rebase/merge to avoid interactive conflict prompts
- Never force push
- Never amend commits unless explicitly asked
