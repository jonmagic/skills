# Knowledge Hygiene

Knowledge Hygiene is an evidence-first Agent Skill for deciding what to do with old or confusing GitHub issues without treating age as proof that work should be closed.

It reads complete primary issue artifacts, checks current implementation and runtime evidence, produces a defensible disposition, and requires exact conversational approval before any GitHub write.

## Install

With APM:

```sh
apm install -g jonmagic/skills --skill knowledge-hygiene
```

With GitHub CLI:

```sh
gh skill install jonmagic/skills knowledge-hygiene --scope user
```

## Portable Configuration

Each run resolves a profile for issue targets or selection scope, author, batch size, inactivity cutoff, repository exclusions, packet persistence, optional evidence sources, and private deny markers.

The profile can narrow scope and add safeguards. It cannot disable primary-artifact retrieval, research/write separation, exact approval, revalidation, privacy gating, or result verification.

See [references/configuration.md](references/configuration.md) for the complete profile.
