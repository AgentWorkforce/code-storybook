# 000 — Storybook program & boundary

**Status:** PROPOSED | **Phase:** 1 (self-contained) | **Depends on:** —

## Goal
Freeze the storybook scope: a **self-contained** Phase 1 that lives entirely in this repo —
library packages + a relayfile **watcher** that synthesizes stories from artifacts products
*already* produce + a **standalone web viewer** — with per-product emit hooks and in-app
(Pear/MSD) embeds explicitly **deferred to Phase 2**.

## Context
Storybook is a read-only, AI-narrated view of the code across Planning (Sage), Review (MSD),
and Runtime (NightCTO). The key design choice: **pull, not push.** Everything already flows
through relayfile (MSD writes PR reviews to `/github/.../reviews/`, Sage's specs/Linear/Notion
land as files, NightCTO writes `/nightcto/signals/`). So a watcher in *this* repo can build
the three story types by observing those paths — **no code changes in sage/MSD/nightcto/pear.**
That keeps Phase 1 one repo, one deploy, one set of PRs.

## In scope
- `docs/storybook-boundary.md` containing:
  - the three layers (planning/review/runtime) and the relayfile **source paths** each is synthesized from,
  - the artifact path convention `/stories/<type>/<id>.json`,
  - the **pull/watch** principle (no product edits in Phase 1) and the **agents-write/humans-read** rule,
  - the Phase 1 surface = a **standalone web viewer** (not embedded in Pear/MSD yet),
  - a "Phase 2 (deferred)" section pointing at `specs/storybook-phase2/`: per-product emit hooks for richer stories + Pear/MSD inline embeds,
  - the "stay close to the code" goals: surface duplication, smells, churn/hotspots/coverage.
- A short rationale: why watch-and-synthesize beats push-emit for v1 (zero cross-repo coupling).

## Out of scope
- Any schema/code (001+). Any edit to sage/MSD/nightcto/pear (that's Phase 2). Choosing renderer internals (030).

## Acceptance
- `docs/storybook-boundary.md` exists with the three layers, their relayfile source paths, the pull principle, and the Phase 2 deferral.

## Review
Reviewer confirms Phase 1 requires **zero** changes to other repos, each layer names a real
relayfile source path, and Phase 2 (emit/embed) is clearly marked deferred. PASS when the doc
is the faithful authority for later specs.

## Handoff
001 defines the artifact; 020–023 are the watcher that fills it from relayfile.
