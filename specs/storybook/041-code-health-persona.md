# 041 — Code-health persona

**Status:** PROPOSED | **Phase:** 1 | **Depends on:** 001, 011

## Goal
A periodic persona that computes code-health metrics — churn, hotspots, test coverage —
and overlays them onto stories and a per-repo health summary, so the human stays aware of
codebase health (the dream's "metrics on code churn, hotspots and test coverage").

## Context
Metrics come from git history (churn/hotspots) + a coverage report (coverage). A scheduled
`definePersona` handler computes them per watched repo, writes a `/stories/_health/<repo>.json`
summary, and fills the `metrics` section of stories whose `subject.repo` matches.

## In scope
- `personas/code-health/persona.ts` (`definePersona`, `schedules: [{cron}]`, `onEvent`).
- `packages/code-story/src/health.ts`:
  - `computeChurn(repo, sinceDays)` (commits/lines per file), `computeHotspots()` (churn × complexity or churn × bug-touches), `readCoverage(report)`.
  - all pure given inputs (git log + coverage file passed in), so they are testable offline.
- `agent.ts`: compute → write `/stories/_health/<repo>.json` → patch `metrics` on matching stories via the `@code-story` writer.
- Test: fixtures (git log + coverage) → expected churn/hotspot/coverage; metrics land on a matching story.

## Out of scope
- Narration (040). Rendering the panel (030 renders whatever `metrics` holds). Enforcing thresholds/gates.

## Acceptance
- `npm test -- code-health` passes; metric functions are pure (proven by direct calls).
- A matching story receives a `metrics` section.

## Review
Reviewer confirms metric computations are pure/deterministic (inputs injected, no live git
shell in the unit path), only the `metrics` section is patched on stories, and the health
summary path is stable. PASS on green tests.

## Handoff
030's metrics panel and 031's tour show real health data; 042 asserts metrics present.
