# 042 — Storybook acceptance proof (Phase 1)

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** all prior

## Goal
One end-to-end proof, entirely within this repo: from relayfile fixture artifacts, the watcher
synthesizes a planning + review + runtime story for one subject; narrator + health enrich them;
and the combined three-layer tour renders read-only in the standalone viewer — plus a written
verdict closing Phase 1.

## Context
The capstone `*-review-verdict`. Exercises watch/synthesize (020–023) → narrator (040) →
health (041) → renderer (030) → standalone viewer + tour (031/032), against a fake/in-memory
relayfile seeded with one subject's artifacts. **No other repo is touched** — that's the point
of Phase 1.

## In scope
- An e2e test that seeds a fake relayfile with one subject's source artifacts (a Sage proposal,
  a PR-with-reviews, a NightCTO incident signal), runs the watcher + synthesizers, and asserts:
  - three stories exist for the subject, cross-linked (plan → review → runtime),
  - each has a narration track (040) and a metrics section (041),
  - `listStories` returns them and the combined tour orders them correctly.
- A standalone-viewer render check (component/e2e): the combined three-layer tour renders read-only via `@code-story/react`.
- `docs/storybook-review-verdict.md`: checklist of all Phase 1 specs PASS/▢; one rendered-tour snippet; an explicit "Phase 2 deferred" list (per-product emit hooks for richer stories, Pear/MSD inline embeds) pointing at `specs/storybook-phase2/`.

## Out of scope
- Any product-repo change. Productionizing the viewer. Real provider data (fixtures suffice). Metric threshold gating.

## Acceptance
- The e2e passes (three linked, narrated, metric'd stories synthesized from fixtures + correct tour order).
- The standalone viewer renders the combined tour read-only.
- Verdict doc lists every Phase 1 spec and the deferred Phase 2 list.

## Review
Reviewer confirms the chain is synthesized purely from relayfile fixtures (no product coupling,
nothing mocked away to trivially pass), three-layer continuity holds on one subject, and the
verdict honestly reflects any ▢ and the Phase 2 deferral. PASS when green + faithful verdict.

## Handoff
Phase 1 is proven self-contained. Phase 2 (`specs/storybook-phase2/`) can then add richer
per-product emit and Pear/MSD inline embeds where they pay off.
