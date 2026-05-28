# 011 — Story index & ACL

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 010

## Goal
Make stories discoverable (an index the renderer lists) and access-correct (agents write,
humans/Pear read) on the shared relayfile mount.

## Context
The renderer needs to list stories without scanning; multiple agents write concurrently.
Relayfile ACLs (`.relayfile.acl`) + a maintained index file fit both needs.

## In scope
- `writer.ts`: on `.write`, upsert an entry into `/stories/_index.json` (`{ id, type, title, subject, createdBy, createdAt, path }`), append-or-replace by `id`.
- `packages/code-story/src/index-reader.ts`: `listStories(ctx, { type?, repo?, limit? }): StoryIndexEntry[]`.
- `.relayfile.acl` for `/stories/**`:
  - write: agents `sage`, `my-senior-dev`, `nightcto`, `code-narrator`, `code-health`
  - read: human/Pear scope + all the above
  - deny others by default
- `index.test.ts` — concurrent writes from two fake agents both land in the index; `listStories` filters by type/repo.

## Out of scope
- Rendering (030). Generating story content. Token issuance (relayauth).

## Acceptance
- `npm test -- index` passes including the concurrent-write case (no lost entry).
- ACL parses; a write from an unlisted agent is denied in a local relayfile test.

## Review
Reviewer confirms default-deny, the writer agents match the three products + two helper
personas exactly, and the index upsert is race-safe (concurrent writes don't clobber).
PASS when index tests + the negative ACL check pass.

## Handoff
030's renderer lists via `listStories`; 040/041 write within this ACL.
