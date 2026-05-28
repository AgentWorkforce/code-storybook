# 032 — Guided tour (stepped mode)

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 030, 031

## Goal
A guided, storybook-style walkthrough — the dream's "walks me through it via a guided tour on
the web in a storybook type of way" — as a stepped mode of `@code-story/react`, served by the
standalone viewer (031). Generalizes MSD's `PRStory` slide pattern to any `CodeStory`.

## Context
The vendored MSD `PRStory` (030) already does Overview → Narrative → Files → Summary slides,
PR-specific. Generalize it so the same stepped UX renders planning/review/runtime stories from
the artifact, hosted by the standalone viewer. (Pear hosting is Phase 2.)

## In scope
- `@code-story/react`: a `<StoryTour story={CodeStory} step onStep />` mode that pages the story's
  `sections` as ordered steps — narration foregrounded, the section's visual (code/diff/diagram)
  as the step focus. Lift the slide/transition pattern from the vendored `PRStory`.
- `web/` (031): a `/story/<id>?step=N` route hosting `<StoryTour>`; deep-linkable; read-only.
- **Three-layer mode**: when a subject has planning+review+runtime stories cross-linked via `links`, offer a combined tour ordered plan → review → runtime; degrade to single-layer otherwise.
- Test: a fixture renders as N ordered steps; deep-link to a step works; the combined tour orders the three layers; falls back cleanly.

## Out of scope
- Pear hosting (Phase 2). Authoring/editing. Real-time collaboration.

## Acceptance
- `<StoryTour>` renders a fixture as ordered steps with prev/next + deep-link in the standalone viewer.
- The combined three-layer tour orders plan → review → runtime and degrades gracefully.

## Review
Reviewer confirms the stepped UX reuses the vendored `PRStory` pattern (generalized, not
rebuilt), steps derive from the artifact (no hand-authored script), deep-links are stable, and
combined-tour ordering/fallback is correct. PASS on green tests.

## Handoff
042 includes a combined three-layer tour render in the standalone viewer.
