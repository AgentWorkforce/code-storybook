# 001 — Code-story artifact schema

**Status:** PROPOSED | **Target repo:** shared `@code-story` package | **Depends on:** 000

## Goal
Define the versioned `CodeStory` artifact: the single structured document every layer
writes and the renderer reads. This is the contract the whole program hangs on.

## Context
Stored as relayfile JSON at `/stories/<type>/<id>.json`. Must carry enough for a rich,
read-only narrated view without the reader needing repo access beyond what relayfile mounts.

## In scope
- `packages/code-story/src/schema.ts` exporting a `CodeStory` type + a runtime validator:
  - `version`, `id`, `type: 'planning'|'review'|'runtime'`, `title`, `createdBy` (agent), `createdAt`
  - `subject`: `{ repo, ref?, prNumber?, issueUrl?, incidentId? }`
  - `sections: Section[]` where a `Section` is one of:
    - `narrative` — markdown prose (the AI narration track lives here, 040)
    - `diagram` — `{ kind:'ascii'|'mermaid'|'flow', body }` (flow → `@xyflow/react` nodes/edges)
    - `code` — `{ file, startLine, endLine, lang, snippet, note? }` (renders with Shiki + clickable `file:line`)
    - `diff` — `{ file, patch }` (renders with `react-diff-view`)
    - `metrics` — `{ churn?, hotspots?, coverage? }` (filled by 041)
  - `links`: `{ slackThread?, linearUrl?, notionUrl?, prUrl? }` (the dream's "traceable path")
- `schema.test.ts` — valid stories of each type round-trip; an invalid section is rejected; unknown `version` is rejected.
- A short `README.md` with one example story per type.

## Out of scope
- Writing stories (010). Rendering (030). Narration/metric *generation* (040/041).

## Acceptance
- `npm test -- schema` passes (per-type valid + invalid + version cases).
- The type is exported and importable as `@code-story/schema`.

## Review
Reviewer confirms every section kind needed by the three layers is representable, `links`
covers the traceable path (Slack/Linear/Notion/PR), and the validator actually rejects
malformed/unknown-version artifacts (not just types-only). PASS on green tests.

## Handoff
010 (writer) and 030 (renderer) both program against `@code-story/schema`.
