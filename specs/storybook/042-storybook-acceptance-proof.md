# 042 — Storybook acceptance proof

**Status:** PROPOSED | **Target repo:** shared (cross-repo e2e) | **Depends on:** all prior | **Repo:** code-storybook

## Goal
One end-to-end proof: a single subject produces a planning + review + runtime story, each
gets narration and metrics, and the combined three-layer tour renders read-only in Pear —
plus a written verdict closing the program.

## Context
The capstone `*-review-verdict` for storybook. Exercises emit (020–022) → narrator (040) →
health (041) → shared renderer (030) on both surfaces (Pear 031, MSD webapp 032) and the
stepped tour (033), on one subject id, on a shared fixture relayfile mount.

## In scope
- A cross-repo e2e (a `code-story` integration test driving fixtures for all three emitters, the narrator, and the health persona against one in-memory/fake relayfile):
  - assert three stories exist for one subject, cross-linked (plan→review→runtime),
  - each has a narration track (040) and a metrics section (041),
  - `listStories` returns them and the combined tour orders them correctly.
- A render check on **both** surfaces (Pear `story` view + MSD webapp `/stories`) that the
  combined three-layer tour shows all three layers read-only via the shared `@code-story/react`.
- `docs/storybook-review-verdict.md`: checklist of all specs PASS/▢, screenshots/snippets of one rendered tour, and the "what's intentionally deferred" list (e.g. mermaid vs flow, mobile).

## Out of scope
- Productionizing the web tour. Real provider data (fixtures are fine). Threshold gating on metrics.

## Acceptance
- The cross-repo e2e passes (three linked, narrated, metric'd stories + correct tour order).
- Verdict doc lists every spec and shows one rendered tour.

## Review
Reviewer (ideally Sage for completeness + MSD for the renderer code) confirms the e2e
exercises emit→narrate→health→render without mocking away the linkage, the three-layer
continuity actually holds on one subject, and the verdict is honest about deferrals. PASS
when the chain is green and the verdict is faithful.

## Handoff
Storybook is proven end-to-end; the artifact + skill + renderer are the reusable base for
future surfaces (e.g. mobile, exec digests).
