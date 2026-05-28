# 022 — Review-story synthesis (observed)

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 010, 020

## Goal
Synthesize a **review** `CodeStory` from PR reviews as they land in relayfile — with **no
change to MSD**. Phase 2 (deferred) lets MSD emit a richer version with its own findings/
merge-readiness data; here we build from the PR + reviews + diff already in relayfile.

## Context
PR reviews are written to `/github/repos/<owner>/<repo>/pulls/<n>/reviews/<id>.json` (relayfile
github adapter). The synthesizer reads the PR, its reviews, and the diff, and assembles the
story. When the PR traces to a planning story (021), link it for cross-layer continuity.

## In scope
- `packages/code-story/src/synthesize/review.ts`: `synthesizeReview(ctx, sourceEvent): CodeStory | null`
  - reads the PR + its reviews + changed-file diffs from relayfile,
  - builds a `review` story: `diff` sections, `narrative` (prioritized findings — signal over noise), `code` refs for key findings, `links` (PR + upstream planning story if found),
  - returns `null` for non-review events.
- `review.test.ts`: a fixture PR-with-reviews (relayfile files) → schema-valid review story with diff + links; non-review → `null`.

## Out of scope
- Editing MSD (Phase 2 emit hook). The MSD webapp embed (Phase 2). Narration polish (040).

## Acceptance
- `npm test -- review` passes; output validates against `@code-story/schema`.
- Synthesis reads only relayfile (no MSD backend import/API).

## Review
Reviewer confirms it builds from observed `/github/**/reviews/**` (no MSD coupling), prioritizes
findings rather than dumping every comment, links upstream planning when present, and returns
`null` on non-reviews. PASS on green tests.

## Handoff
020 dispatches review events here; 023 (runtime) can link back to the review that shipped the change.
