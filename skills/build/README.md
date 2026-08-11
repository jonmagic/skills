# Build

`build` orchestrates an implementation request from source context through acceptance criteria, red-green-refactor, focused validation, risk-gated review, recovery, and final handoff.

## Install

Install globally with APM:

```bash
apm install -g jonmagic/skills --skill build
```

Install into a project:

```bash
apm install jonmagic/skills --skill build
```

Or install with GitHub CLI:

```bash
gh skill install jonmagic/skills build --scope user
```

## Use

```text
Build the feature described in this issue and get it ready for me to use.
```

The skill intentionally treats other skills, specialist agents, browser automation, and remote tools as optional capabilities. It remains usable with ordinary repository read, edit, shell, and test tools.
