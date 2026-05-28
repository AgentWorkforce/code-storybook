# 010 — Sage planning emit (richer)

**Status:** DEFERRED | **Phase:** 2 | **Repo:** sage | **Depends on:** Phase 1 (`@code-story` published)

## Goal
Make Sage emit a planning `CodeStory` directly from its issue pipeline, carrying its **internal**
S/M/L rationale and reuse/conflict analysis as first-class data — richer than what Phase 1's
watcher can synthesize by observing Sage's relayfile outputs.

## Context
Phase 1 (`specs/storybook/021`) already produces a planning story by reading Sage's spec/Linear/
Notion artifacts. This spec upgrades that for Sage specifically: Sage calls the `@code-story`
writer at proposal time with data it has in-process but doesn't fully persist (sizing rationale,
candidate reuse targets). When Sage emits, the watcher defers to the emitted story (dedupe by subject).

## In scope
- Add `@code-story` (skill) as a sage dependency.
- After Sage synthesizes a proposal, build + `.write()` a planning story with: narrative (proposal + S/M/L rationale), ascii arch diagram, code refs for reuse candidates, links (Slack/Linear/Notion).
- Mark the story so the Phase 1 watcher skips synthesizing a duplicate for that subject.
- Test: a fixture Sage proposal emits a schema-valid planning story richer than the observed-synthesis baseline.

## Out of scope
- Changing Sage's planning logic. Rendering. Other layers.

## Acceptance
- Sage's planning-emit test passes; story validates against `@code-story/schema`.
- The watcher does not also synthesize a duplicate planning story for the same subject.

## Review
Reviewer confirms emission is best-effort (never breaks the proposal), the dedupe prevents
double stories, and the emitted story is genuinely richer than the Phase 1 baseline. PASS on green tests.

## Handoff
Supersedes Phase 1 `021` for Sage-originated planning stories.
