# 020 — MSD review emit (richer)

**Status:** DEFERRED | **Phase:** 2 | **Repo:** my-senior-dev | **Depends on:** Phase 1 (`@code-story` published)

## Goal
Make MSD emit a review `CodeStory` from its review flow, carrying its own prioritized findings,
merge-readiness verdict, and blocker explanations — richer than Phase 1's watcher synthesis from
`/github/**/reviews/**`.

## Context
Phase 1 (`specs/storybook/022`) synthesizes a review story by observing PR reviews in relayfile.
MSD has more in-process (finding priority, merge-readiness, autofix eligibility); this spec emits
that directly. When MSD emits, the watcher defers (dedupe by PR subject).

## In scope
- Add `@code-story` (skill) as an MSD dependency.
- After a review completes, build + `.write()` a review story: diff sections, prioritized findings narrative, merge-readiness verdict, code refs, links (PR + upstream planning story if traced).
- Mark the story so the Phase 1 watcher skips the observed-synthesis duplicate.
- Test: a fixture review emits a schema-valid review story richer than the baseline.

## Out of scope
- Changing MSD's review/autofix logic. The webapp embed (`021`). Other layers.

## Acceptance
- MSD's review-emit test passes; story validates against `@code-story/schema`.
- No duplicate observed-synthesis story for the same PR.

## Review
Reviewer confirms emission reuses MSD's existing findings (no re-review), is best-effort, dedupe
holds, and the emitted story is richer than the Phase 1 baseline. PASS on green tests.

## Handoff
Supersedes Phase 1 `022` for MSD-originated review stories; `021` can surface them in MSD's webapp.
