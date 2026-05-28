# 023 — Runtime-story synthesis (observed)

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 010, 020

## Goal
Synthesize a **runtime** `CodeStory` from NightCTO's incident signals in relayfile — with **no
change to NightCTO**. This closes the plan → review → runtime loop on one subject, purely by
observation.

## Context
NightCTO's persona migration writes incident signals + verdicts to `/nightcto/signals/<date>/<id>.json`
and a feature log to `/nightcto/features/**`. The synthesizer reads a high-urgency signal,
the implicated `file:line` (from its `culprit`), any linked hotfix PR, and correlates to the
shipping feature/review via the feature log.

## In scope
- `packages/code-story/src/synthesize/runtime.ts`: `synthesizeRuntime(ctx, sourceEvent): CodeStory | null`
  - reads the incident signal + (if present) hotfix PR diff + the correlated feature entry,
  - builds a `runtime` story: `narrative` (incident + triage rationale + hotfix if any), `code` refs for the implicated lines, `diff` if a hotfix PR exists, `links` (source alert, hotfix PR, upstream review/feature),
  - returns `null` for low-urgency/non-incident signals.
- `runtime.test.ts`: a fixture high-urgency signal (relayfile files) → schema-valid runtime story; with a correlated feature, it links the upstream review story; low-urgency → `null`.

## Out of scope
- Editing NightCTO (its migration already writes the signals/feature-log this reads). Narration (040). Rendering.

## Acceptance
- `npm test -- runtime` passes; output validates against `@code-story/schema`.
- Synthesis reads only relayfile (no nightcto import/API).

## Review
Reviewer confirms it builds from observed `/nightcto/signals/**` + feature log (no nightcto
coupling), links upstream when correlation exists, and returns `null` on low-urgency signals.
PASS on green tests.

## Handoff
020 dispatches runtime events here; with 021–023 done, all three layers synthesize from relayfile alone.
