# 021 — MSD webapp inline embed

**Status:** DEFERRED | **Phase:** 2 | **Repo:** my-senior-dev | **Depends on:** Phase 1 (`@code-story/react` published)

## Goal
Mount `@code-story/react` inside MSD's webapp so stories render **inline** in MSD's product UI,
not only in the standalone viewer — and link a PR's review story from MSD's existing PR view.

## Context
The renderer was vendored *from* MSD in Phase 1 (`specs/storybook/030`), so MSD re-consuming it
as a package keeps its review UI and the storybook DRY. MSD webapp: React 18 + Vite + `vite-react-ssg`
+ Tailwind 4. Stories load from relayfile (read scope), so planning/runtime stories render too.

## In scope
- Add `@code-story/react` + `@relayfile/sdk` to the webapp.
- A `/stories` route: list (via `listStories`) + a story page mounting `<StoryView>` / `<StoryTour>`.
- `onOpenRef` opens the file read-only via MSD's existing file viewer (reuse, don't rebuild).
- Link the review story from the existing PR view when one exists.
- Test: `/stories` renders a fixture story of each type via the shared renderer.

## Out of scope
- Refactoring MSD's `FileDetailModal`/backend. The standalone viewer (Phase 1 `031`). Auth beyond the relayfile read scope.

## Acceptance
- MSD webapp builds with `@code-story/react`; `/stories` renders one story of each type.
- Stories load from relayfile, not the MSD backend API.

## Review
Reviewer confirms the webapp consumes the shared package (no second renderer), stories load via
relayfile (decoupled from MSD's PR backend), and read-only holds. PASS on green build + test.

## Handoff
MSD users get inline storybooks; the standalone viewer remains the cross-product surface.
