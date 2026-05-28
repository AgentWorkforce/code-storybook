# 020 — Story-builder watcher (core)

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 010, 011

## Goal
A single proactive persona that watches relayfile for the artifacts products already produce
and routes each to the right per-layer synthesizer (021/022/023), which build a `CodeStory`
via the writer (010). This is the heart of the self-contained design — no product edits.

## Context
`definePersona` handler with `watch` rules on the relevant relayfile paths. The watcher only
*dispatches*; the actual planning/review/runtime mapping lives in 021/022/023 so each is
independently testable. Idempotent: re-seeing the same source artifact must not duplicate a story.

## In scope
- `personas/story-builder/persona.ts` (`definePersona`, `onEvent`), `watch` on the source paths:
  - planning → Sage's outputs (e.g. `/notion/**`, `/linear/**` issues Sage authored, or a `/sage/**` namespace)
  - review → `/github/repos/**/pulls/**/reviews/**`
  - runtime → `/nightcto/signals/**`
- `personas/story-builder/agent.ts`: classify the event by source path → call `synthesize{Planning,Review,Runtime}(ctx, event)` (021/022/023) → if non-null, write via the `@code-story` writer (010).
- A dedupe key (source artifact id → story id) so redelivery updates rather than duplicates.
- `story-builder.test.ts`: a fixture event on each source path routes to the correct synthesizer; an unrelated path is ignored; redelivery is idempotent.

## Out of scope
- The per-layer mapping logic (021/022/023). Narration/metrics (040/041). Any product-repo change.

## Acceptance
- `npm test -- story-builder` passes: correct routing per source path, unrelated paths ignored, idempotent redelivery.
- The handler only routes (no synthesis logic inline).

## Review
Reviewer confirms the watcher is pure routing, dedupe prevents duplicate stories on
redelivery, watch paths match real relayfile source locations, and nothing reaches into a
product repo. PASS on green tests.

## Handoff
021/022/023 implement the three synthesizers the watcher dispatches to.
