# 040 — Pear story view embed

**Status:** DEFERRED | **Phase:** 2 | **Repo:** pear | **Depends on:** Phase 1 (`@code-story/react` published)

## Goal
Mount `@code-story/react` as a Pear `story` ViewMode so stories render in the **desktop**
coordinating layer alongside terminal/chat/graph — inline, not just the standalone web viewer.

## Context
Pear already has `ViewMode`, `@relayfile/sdk`, and the account mount; it's React 19. With the
shared renderer doing the work, Pear only lists + hosts `<StoryView>`/`<StoryTour>` and wires
`file:line` to its read-only file open. Verify the React 19 peer range on `@code-story/react`.

## In scope
- Extend `ViewMode` with `'story'` (`src/renderer/src/stores/ui-store.ts`).
- `StoryListPane` (via `listStories`) + `StoryPane` mounting `<StoryView>` / `<StoryTour>`.
- `onOpenRef` opens `file:line` read-only in Pear (no edit affordance).
- Component test: the `story` tab lists fixtures and renders one of each type.

## Out of scope
- Building any section renderer (Phase 1 `030`). The standalone viewer (Phase 1 `031`). Narration/metric generation.

## Acceptance
- Pear builds with `@code-story/react`; the `story` tab renders a fixture story of each type.
- No section-rendering logic duplicated in Pear (it only mounts the shared components).

## Review
Reviewer confirms Pear reuses `@code-story/react` (no parallel renderer), the React 19 peer range
is satisfied, and the surface is read-only. PASS on green build + component test.

## Handoff
Pear becomes a desktop storybook surface; the standalone viewer + MSD embed cover web.
