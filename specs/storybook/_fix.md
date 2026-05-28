# _fix — address reviewer findings

**Status:** REUSABLE | **Input:** `TARGET_SPEC` (path), findings file (arg)

You are the **implementer** again. The reviewer returned `CHANGES_REQUESTED` for
`TARGET_SPEC`. Read the findings file (arg) and fix every numbered finding.

## Rules
- Address each finding directly; do not expand scope beyond `TARGET_SPEC`.
- Stay inside the spec's `## In scope`; never touch its `## Out of scope`.
- Re-run the spec's `## Acceptance` commands and confirm they pass before finishing.
- If a finding is wrong or impossible within scope, leave a one-line rebuttal comment
  in the implement log rather than silently ignoring it — the reviewer will re-judge.

## Output
Print a short summary: which findings were fixed and the acceptance result. The runner
re-invokes the reviewer after this pass.
