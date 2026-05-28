# 022 — NightCTO runtime story

**Status:** PROPOSED | **Target repo:** nightcto | **Depends on:** 010, 011 | **Repo:** nightcto

## Goal
Make NightCTO emit a **runtime** code-story when it handles a high-urgency incident — the
incident, the implicated code flow, and any proposed hotfix — closing the loop from
planning (Sage) → review (MSD) → runtime (NightCTO) on one subject.

## Context
Builds on the NightCTO persona migration: the watch handler (`031`) triages incidents, and
`032` may propose a hotfix. This spec adds a story emission in the incident path, linking
back to the feature/PR that shipped the implicated code (via the feature log, migration 033).

## In scope
- Add `@code-story` as a nightcto dependency.
- In the watch handler's high-urgency incident path, build a `runtime` story:
  - `narrative`: the incident summary + triage rationale + (if any) the hotfix proposal
  - `code` sections for the implicated `file:line` (from the incident `culprit`/stack)
  - `diff` section if `032` proposed a hotfix PR
  - `metrics`: leave for 041 to overlay
  - `links`: the Sentry/PostHog/etc source, the hotfix PR, and the shipping feature's PR/review story (from feature log, 033)
- `.write(ctx)`; include the story link in the Slack alert (migration 012).
- Test: a fixture incident produces a schema-valid runtime story; with a correlated recent feature, it links the upstream review story.

## Out of scope
- Changing triage/hotfix logic (migration owns it). Rendering (030). Narration polish (040).

## Acceptance
- NightCTO's runtime-story test passes; the story validates against `@code-story/schema`.
- A correlated incident links the upstream feature/review story.

## Review
Reviewer confirms the story reuses the migration's existing incident/triage/feature-log
output (no re-derivation), links upstream when correlation exists, and emission is
best-effort (never blocks the alert). PASS on green tests.

## Handoff
All three layers now emit stories on one subject; 030 renders them as a continuous storybook.
