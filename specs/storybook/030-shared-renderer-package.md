# 030 — Renderer package (`@code-story/react`)

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 001

## Goal
An artifact-driven React renderer that takes a `CodeStory` (001) and renders it read-only,
with **no backend coupling** — built by **vendoring** MSD's proven render primitives into this
repo (a one-time read of MSD; output lives only here). Consumed by the standalone viewer (031);
Pear/MSD inline embedding is Phase 2.

## Context
MSD has the best renderer in the org but it's welded to its backend
(`packages/webapp/src/components/FileDetailModal.tsx` + `lib/diffUtils.ts`,
`diffSymbolExtractor.ts`, and the `PRStory` slide-deck). The **backend-free** parts — the
tokenizer/colormap, `diffUtils` parsing, symbol extraction, and the slide pattern — are copied
**into this package** and re-wrapped around the `CodeStory` artifact. We do not import MSD or
edit it; we vendor the pure utilities once (note provenance for later upstreaming).

## In scope
- `packages/code-story-react/` exporting prop-driven, read-only section renderers (no `PRInfo`/`api.*`/fetch):
  - `<StoryView story={CodeStory} onOpenRef={fn} />` — renders sections in order.
  - `Narrative` (react-markdown), `Diagram` (ascii / `@xyflow/react` flow / mermaid), `Code` (vendored tokenizer + clickable `file:line` via `onOpenRef`), `Diff` (vendored `diffUtils`, split/unified), `Metrics` (churn/hotspot/coverage panel).
  - vendor the MSD utilities into `packages/code-story-react/src/vendor/` with a header noting source + commit.
- A thin `loadStory(client, id)` reading a `CodeStory` from relayfile (`@relayfile/sdk`); injectable for tests.
- `StoryView.test.tsx`: renders a fixture story of each type; import graph has **no** MSD-backend dependency; clicking a `code` ref calls `onOpenRef`.

## Out of scope
- The standalone viewer (031) and tour (032). Editing/annotations (read-only). Importing from or editing MSD's repo. Pear/MSD inline embed (Phase 2).

## Acceptance
- `npm test -- StoryView` passes; package has zero dependency on MSD's backend (proven by import graph).
- Renders all five section kinds from a fixture `CodeStory`.

## Review
Reviewer confirms the tokenizer/diff logic is the vendored MSD code (provenance noted), no
`PRInfo`/`api.*`/fetch leaked in, it's read-only, and it renders purely from a `CodeStory` prop.
PASS on green tests + clean import graph.

## Handoff
031 mounts `<StoryView>` in the standalone viewer; Phase 2 can mount the same package in Pear/MSD.
