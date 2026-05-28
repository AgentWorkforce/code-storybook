# 030 — NightCTO runtime emit (richer)

**Status:** DEFERRED | **Phase:** 2 | **Repo:** nightcto | **Depends on:** Phase 1 (`@code-story` published)

## Goal
Make NightCTO emit a runtime `CodeStory` from its incident handler at incident time, carrying
triage internals (rationale, urgency, hotfix reasoning) — richer than Phase 1's watcher synthesis
from `/nightcto/signals/**`.

## Context
Phase 1 (`specs/storybook/023`) synthesizes a runtime story by observing the signals/feature-log
NightCTO already writes (per the persona-migration). This spec emits a richer story inline in the
watch handler, with data it has at triage time. When NightCTO emits, the watcher defers (dedupe by incident).

## In scope
- Add `@code-story` (skill) as a nightcto dependency (its `personas/watch` handler).
- In the high-urgency incident path, build + `.write()` a runtime story: incident + triage rationale narrative, implicated code refs, hotfix diff if any, links (source alert, hotfix PR, upstream review/feature).
- Mark the story so the Phase 1 watcher skips the observed-synthesis duplicate.
- Test: a fixture incident emits a schema-valid runtime story richer than the baseline; correlated incident links the upstream review.

## Out of scope
- Changing triage/hotfix logic (the persona-migration owns it). Rendering. Other layers.

## Acceptance
- NightCTO's runtime-emit test passes; story validates against `@code-story/schema`.
- No duplicate observed-synthesis story for the same incident.

## Review
Reviewer confirms emission reuses the migration's incident/triage output (no re-derivation), is
best-effort (never blocks the alert), dedupe holds, and the emitted story is richer than the
Phase 1 baseline. PASS on green tests.

## Handoff
Supersedes Phase 1 `023` for NightCTO-originated runtime stories; closes the richest plan→review→runtime loop.
