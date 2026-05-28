# 000 — Storybook program & boundary

**Status:** PROPOSED | **Target repo:** shared `@code-story` package | **Depends on:** —

## Goal
Freeze the storybook scope as a checked-in document: the three layers, the artifact
location, the cross-repo build plan, and what is explicitly out.

## Context
Storybook is a read-only, AI-narrated view of the code across Planning (Sage), Review
(MSD), and Runtime (NightCTO). Artifacts are relayfile files; rendering reuses Pear's
existing Shiki/`@xyflow/react`/`react-diff-view`. See `PROGRAM.md`.

## In scope
- Create `docs/storybook-boundary.md` (in the shared package's repo) containing:
  - the three layers and which agent emits each,
  - the artifact path convention `/stories/<type>/<id>.json` (`type ∈ planning|review|runtime`),
  - the cross-repo plan (shared schema/skill first, then per-agent emit, then Pear renderer),
  - the principle: **agents write, humans read** — the storybook is never an editing surface,
  - the "stay close to the code" goals: surface duplicated logic, smells, churn/hotspots/coverage.
- A one-paragraph "why not just a PR diff" rationale (narration + cross-layer continuity + health metrics).

## Out of scope
- Any schema/code (001+). Choosing the renderer's exact components (030).

## Acceptance
- `docs/storybook-boundary.md` exists with the three layers, path convention, and cross-repo plan.

## Review
Reviewer confirms the three layers map 1:1 to Sage/MSD/NightCTO, the path convention is
unambiguous, and "read-only for humans" is stated as a hard rule. PASS when the doc is the
faithful authority for later specs.

## Handoff
001 defines the artifact schema against this boundary.
