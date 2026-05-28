# 031 — Standalone web viewer

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 011, 030

## Goal
A small self-hosted web app, in this repo, that lists code-stories and renders them with
`@code-story/react` (030) — the Phase 1 surface. No dependency on Pear or MSD; those inline
embeds are Phase 2.

## Context
Read-only browser surface. Lists via `listStories` (011), renders via `<StoryView>` (030),
reads everything from relayfile. Keep it minimal (Vite + React) so it's trivial to host/share.

## In scope
- `web/` — a Vite + React app:
  - `StoryList` route — `listStories` (011) with type/repo filters.
  - `StoryPage` route — `loadStory` (030) → `<StoryView story={...} onOpenRef={openRefReadOnly} />`.
  - `onOpenRef` opens the referenced `file:line` read-only (a simple in-app code panel; no edit).
  - reads relayfile via `@relayfile/sdk` with a read-scoped token.
- `web/README.md` — how to run/host it locally.
- Test: the list route renders fixtures; a story page renders one of each type via `<StoryView>`.

## Out of scope
- Embedding in Pear (`specs/storybook-phase2/`) or MSD webapp (Phase 2). The stepped tour (032). Auth beyond a read-scoped relayfile token.

## Acceptance
- `web` builds; the list + story routes render a fixture story of each type via the shared renderer.
- No section-rendering logic duplicated in `web/` (it only mounts `<StoryView>`).

## Review
Reviewer confirms the viewer reuses `@code-story/react` (no parallel renderer), is read-only,
reads from relayfile (not a product backend), and has no Pear/MSD dependency. PASS on green build + test.

## Handoff
032 adds the stepped guided-tour mode to this viewer; Phase 2 may also mount `<StoryView>` inside Pear/MSD.
