# 010 — Story-writer skill

**Status:** PROPOSED | **Target repo:** shared `@code-story` package | **Depends on:** 001

## Goal
A single callable skill all three agents use to assemble and persist a `CodeStory` to
relayfile — so emitting a story is one call, not bespoke per agent.

## Context
The skill is the only writer of `/stories/**`. It validates against `@code-story/schema`
(001) before writing. Reuse `@relayfile/sdk` `writeFile`. Keep assembly helpers so agents
build sections ergonomically (add a code ref by `file:line`, add an ascii diagram, etc.).

## In scope
- `packages/code-story/src/writer.ts`:
  - `createStory({ type, title, subject, createdBy }): StoryBuilder`
  - builder methods: `.narrative(md)`, `.ascii(body)`, `.flow(nodes,edges)`, `.code(file,start,end,lang,snippet,note?)`, `.diff(file,patch)`, `.metrics(m)`, `.links(l)`
  - `.write(ctx): Promise<{ path, id }>` — validates, then `writeFile` to `/stories/<type>/<id>.json`; idempotent on `id`.
- `writer.test.ts` — build each section type, write to a fake relayfile, read back, assert schema-valid; re-write same `id` does not duplicate.

## Out of scope
- Deciding *what* goes in a story (per-agent emit, 020–022). Narration generation (040). The index/ACL (011).

## Acceptance
- `npm test -- writer` passes including the idempotency case.
- A written artifact validates against `@code-story/schema`.

## Review
Reviewer confirms the writer is the sole `/stories` write path, always validates before
writing, is idempotent on `id`, and the builder covers every schema section. PASS on green tests.

## Handoff
020–022 import the builder; 030 reads what it writes.
