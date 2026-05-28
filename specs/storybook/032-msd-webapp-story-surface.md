# 032 — MSD webapp story surface

**Status:** PROPOSED | **Target repo:** My-Senior-Dev/app | **Depends on:** 011, 030 | **Repo:** my-senior-dev

## Goal
Mount the shared `@code-story/react` renderer in MSD's webapp as the primary **web** surface
for code-stories — MSD already has the richest web UI and static prerendering, so it's the
natural home for the browser experience (Pear is the desktop one).

## Context
The renderer (030) was extracted *from* MSD, so re-consuming it as a package keeps MSD's
review UI and the storybook DRY. MSD webapp: React 18 + Vite + `vite-react-ssg` + Tailwind 4.
Stories load from relayfile (read scope, 011), not MSD's backend — so this surface works for
planning/runtime stories too, not just MSD's own review stories.

## In scope
- Add `@code-story/react` + `@relayfile/sdk` to the webapp.
- A `/stories` route: `StoryListPane` (via `listStories`) + a story page mounting `<StoryView>`.
- `onOpenRef` opens the file read-only using MSD's existing file viewer in read-only mode (reuse, don't rebuild).
- Optional: where an MSD PR already has a review story, link to its storybook page from the existing PR view (continuity, not duplication).
- Test: the `/stories` route renders a fixture story of each type via the shared renderer.

## Out of scope
- Refactoring MSD's `FileDetailModal`/backend. Auth changes beyond the existing relayfile read scope. The stepped tour (033).

## Acceptance
- MSD webapp builds with `@code-story/react`; `/stories` renders one story of each type.
- The route reads stories from relayfile (not the MSD backend API).

## Review
Reviewer confirms the webapp consumes the shared package (no second renderer), stories load
via relayfile (decoupled from MSD's PR backend), and read-only holds. PASS on green build + test.

## Handoff
033 turns this surface into a stepped guided tour; 042 renders here in the proof.
