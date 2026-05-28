# 021 — MSD review story

**Status:** PROPOSED | **Target repo:** My-Senior-Dev/app | **Depends on:** 010, 011

## Goal
Make MSD emit a **review** code-story when it reviews a PR — the diff, the surfaced
findings, and a narrated walkthrough — so the human reviews a storybook, not a comment flood.

## Context
MSD already produces review findings + merge-readiness (see MSD `packages/backend/src/
services/*review*`). MSD also has a partial code-narration notion; this unifies it on the
shared `@code-story` artifact. Link the story back to the originating Sage planning story
(020) when present, for cross-layer continuity.

## In scope
- Add `@code-story` as an MSD dependency.
- After a review completes, build a `review` story:
  - `diff` sections for the changed files (reuse MSD's existing diff data)
  - `narrative`: the prioritized findings (signal-over-noise) + merge-readiness verdict
  - `code` sections for the most important findings (`file:line`)
  - `links`: the PR, and the upstream planning story id if the PR traces to a Sage spec
- `.write(ctx)`; reference the story in MSD's existing Slack "ready for review" ping.
- Test: a fixture review produces a schema-valid review story with diff + narrative + links.

## Out of scope
- Changing MSD's review/autofix logic. The webapp's own rendering (Pear renderer is 030). Narration polish (040).

## Acceptance
- MSD's review-story test passes; the story validates against `@code-story/schema`.
- When the PR traces to a Sage planning story, the review story links it.

## Review
Reviewer confirms the story reuses MSD's existing findings/diff (no re-review), prioritizes
(doesn't dump every weak comment), links upstream planning when available, and emission is
best-effort. PASS on green tests.

## Handoff
030 renders review stories; 022 (runtime) can link back to the review that shipped the change.
