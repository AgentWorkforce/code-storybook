# 021 — Planning-story synthesis (observed)

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 010, 020

## Goal
Synthesize a **planning** `CodeStory` from Sage's artifacts as they appear in relayfile — with
**no change to Sage**. Phase 2 (deferred) lets Sage emit a richer version with its internal
S/M/L rationale; here we build the best story from what Sage already writes.

## Context
Sage already publishes specs/proposals to Notion, creates linked Linear issues, and references
Slack threads — all visible through relayfile. The synthesizer reads those and assembles the
story. Where the rationale isn't explicit in the artifact, summarize what's there (don't invent).

## In scope
- `packages/code-story/src/synthesize/planning.ts`: `synthesizePlanning(ctx, sourceEvent): CodeStory | null`
  - reads the proposal/spec doc + linked Linear issue + Slack thread refs from relayfile,
  - builds a `planning` story: `narrative` (proposal summary + sizing if present), `diagram` (ascii arch sketch if the doc has one), `code` refs the doc cites, `links` (Slack/Linear/Notion),
  - returns `null` for artifacts that aren't actually plans.
- `planning.test.ts`: a fixture Sage proposal (as relayfile files) → schema-valid planning story with links; a non-plan artifact → `null`.

## Out of scope
- Editing Sage (Phase 2 emit hook, `specs/storybook-phase2/`). Narration polish (040). Rendering.

## Acceptance
- `npm test -- planning` passes; output validates against `@code-story/schema`.
- Synthesis reads only relayfile (no Sage import, no Sage API).

## Review
Reviewer confirms it builds purely from observed relayfile artifacts (no Sage coupling), never
fabricates rationale beyond what the source contains, and returns `null` on non-plans. PASS on green tests.

## Handoff
020 dispatches planning events here; 040 narrator can enrich; Phase 2 may supersede with a richer Sage emit.
