# 033 — Story web tour (stepped mode)

**Status:** PROPOSED | **Target repo:** shared `@code-story/react` (hosted by MSD webapp + Pear) | **Depends on:** 030, 032 | **Repo:** code-storybook

## Goal
A guided, storybook-style walkthrough of a code-story — the dream's "walks me through it
via a guided tour on the web in a storybook type of way" — built as a **stepped mode of the
shared renderer**, generalizing MSD's existing `PRStory` slide-deck so it works for any
`CodeStory`, not just PRs.

## Context
MSD's `packages/webapp/src/components/PRStory/` already does Overview → Narrative → Files →
Summary slides — but PR-specific. Generalize that pattern into `@code-story/react` so the
same stepped UX renders planning/review/runtime stories from the artifact. Hosted by the MSD
webapp surface (032) and Pear (031); no separate app.

## In scope
- `@code-story/react`: a `<StoryTour story={CodeStory} step onStep />` mode that pages the
  story's `sections` as ordered steps — narration foregrounded, the section's visual
  (code/diff/diagram) as the step focus. Lift the slide/transition pattern from `PRStory`
  (framer-motion is already a webapp dep); drop PR-specific assumptions.
- Deep-linkable step state (`?step=N`) surfaced by the host route (032 web; Pear local).
- **Three-layer mode**: when a subject has planning+review+runtime stories (cross-linked via
  `links`), offer a combined tour ordered plan → review → runtime; degrade to single-layer when not.
- Test: a fixture story renders as N ordered steps; deep-link to a step works; the combined
  tour orders the three layers; falls back cleanly to one layer.

## Out of scope
- Authoring/editing. Real-time collab. A standalone web app (reuse 032's host + Pear).

## Acceptance
- `<StoryTour>` renders a fixture as ordered steps with prev/next + deep-link, in both hosts.
- The combined three-layer tour orders plan → review → runtime and degrades gracefully.

## Review
Reviewer confirms the stepped UX reuses MSD's `PRStory` pattern (generalized, not rebuilt),
steps derive from the artifact (no hand-authored script), deep-links are stable, and the
combined-tour ordering/fallback is correct. PASS on green tests.

## Handoff
042's proof includes a combined three-layer tour render.
