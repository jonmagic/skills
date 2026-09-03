# Structured Review Handoff

Every completed review package with findings must include this compact structured handoff after the human-readable analysis. It is the source of truth for downstream drafting workflows and prevents them from recreating analysis, weakening blockers, or collapsing path-specific findings.

Use this shape:

```json
{
  "target": {
    "url": "https://github.com/OWNER/REPO/pull/123",
    "headSha": "reviewed-head-sha"
  },
  "changeProgram": {
    "relationship": "standalone",
    "layerPosition": null,
    "parentUrl": null,
    "parentSha": null,
    "diffBasis": "default-branch...reviewed-head-sha",
    "activationOwner": null,
    "crossRepositoryPrerequisites": []
  },
  "decision": "Needs changes before merge",
  "suggestedDisposition": "request_changes",
  "findings": [
    {
      "findingId": "F1",
      "blocking": true,
      "confidence": "high",
      "programStatus": "request_changes_here",
      "owningTarget": "https://github.com/OWNER/REPO/pull/123",
      "reachability": "merge-time",
      "resolvedUpstack": false,
      "path": "app/example.rb",
      "line": 123,
      "verifiedFact": "What repository evidence directly establishes",
      "interpretation": "What the reviewer infers from that fact",
      "uncertainty": "What remains unknown, or null",
      "consequence": "Concrete reachable impact",
      "recommendedNextStep": "Smallest useful fix or validation",
      "feedbackPlacement": "inline"
    }
  ],
  "validation": {
    "checks": [
      {
        "name": "focused test command",
        "result": "passed"
      }
    ],
    "missing": []
  }
}
```

Contract:

1. `decision` is one of the four allowed review decisions.
2. `suggestedDisposition` is `approve`, `comment`, or `request_changes`, derived from the analysis but never authorization to post.
3. `changeProgram` is required. `relationship` is exactly `standalone`, `native-stack`, `dependent-branch-chain`, or `linked-change-program`; never invent another value. Use `standalone` and null or empty values when no larger program is present. `layerPosition` is a short string or null. `parentUrl` and `parentSha` identify the reviewed parent revision or are null. `diffBasis` is the exact comparison used. `activationOwner` is a repository-qualified URL, named activation step, or null. `crossRepositoryPrerequisites` is an array of objects with `description`, `targetUrl` (nullable when no artifact exists), and `status`.
4. Every finding gets a stable `findingId`; downstream workflows must preserve it.
5. `blocking`, `confidence`, `programStatus`, `owningTarget`, `reachability`, `resolvedUpstack`, `verifiedFact`, `interpretation`, and `consequence` are required. `confidence` is `high`, `medium`, or `low`. `programStatus` is `request_changes_here`, `block_program_activation`, `resolved_upstack`, `cross_repository_prerequisite`, or `follow_up_here`. `reachability` is `merge-time`, `activation-time`, or `follow-up`.
6. `owningTarget` is a repository-qualified URL, or null only for `cross_repository_prerequisite` when no target artifact exists; in that case `changeProgram.crossRepositoryPrerequisites` must describe the missing target. Include `path` and `line` only when verified against the reviewed revision; use `null` rather than guessing.
7. Make uncertainty explicit; it may be `null` for a proven issue.
8. Use `feedbackPlacement: inline` for a localized stable anchor, `summary` for a cross-cutting concern that belongs on the current target, and `evidence-only` when `resolvedUpstack` is true or the finding belongs on another or not-yet-created target. Downstream drafting must skip `evidence-only` findings.
9. The handoff contains no polished comment prose and performs no external write.
10. `validation.checks` contains objects with `name` and `result`, where `result` is `passed`, `failed`, or `inconclusive`. If no checks ran, `validation.missing` must say what was not validated; never leave both arrays empty.
11. For non-GitHub artifacts, replace `target.url` with the explicit local artifact identity and keep `headSha` null.
12. The handoff is internal coordination data. Never paste, quote, or copy it verbatim into a GitHub review, comment, or other external artifact; downstream workflows must draft recipient-facing text and run their own privacy and recipient-knowledge gates.

Disposition guidance:

- `Looks ready` -> `approve`
- `Comment-only` -> `comment`
- `Needs changes before merge` -> `request_changes`
- `Not enough context` -> `comment`

This mapping preserves review intent for downstream drafting but does not replace the separate human approval gate.
