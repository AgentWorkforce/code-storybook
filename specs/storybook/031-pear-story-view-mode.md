# 031 — Pear `story` view mode

**Status:** PROPOSED | **Target repo:** pear | **Depends on:** 011, 030 | **Repo:** pear

## Goal
Add a read-only `story` view to Pear that lists code-stories and renders them by mounting
the shared `@code-story/react` renderer (030) — no bespoke Pear rendering.

## Context
Pear already has `ViewMode`, `@relayfile/sdk`, and the account mount. With the shared
renderer doing the heavy lifting, Pear's job is just: list stories + host `<StoryView>` +
wire `file:line` clicks to Pear's read-only file open. Pear is React 19; `@code-story/react`
must work there (verify peer-dep range in 030).

## In scope
- Extend `ViewMode` with `'story'` (`src/renderer/src/stores/ui-store.ts`).
- `StoryListPane` — `listStories` (011) via relayfile; filter by type/repo.
- `StoryPane` — `loadStory` (030) → `<StoryView story={...} onOpenRef={openFileReadOnly} />`.
- `onOpenRef` opens the referenced `file:line` in Pear read-only (no edit affordance).
- Component test: the `story` tab lists fixtures and renders one of each type via the shared renderer.

## Out of scope
- Building any section renderer (that's 030). The web tour (033). Narration/metric generation.

## Acceptance
- Pear builds with `@code-story/react`; the `story` tab renders a fixture story of each type.
- No section-rendering logic duplicated in Pear (it only mounts `<StoryView>`).

## Review
Reviewer confirms Pear reuses `@code-story/react` (no parallel renderer), the React 19 peer
range is satisfied, and the surface is read-only. PASS on green build + component test.

## Handoff
042 includes a Pear render in the proof; 033 reuses the same renderer in stepped mode.
