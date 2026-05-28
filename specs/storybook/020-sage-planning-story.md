# 020 — Sage planning story

**Status:** PROPOSED | **Target repo:** sage | **Depends on:** 010, 011

## Goal
Make Sage emit a **planning** code-story as a side-effect of its issue pipeline, so the
proposal/spec a human reviews is a narrated storybook (ascii architecture + reuse analysis
+ traceable links), not just a Slack message.

## Context
Sage already researches, sizes (S/M/L), and proposes (see sage `src/swarm/` planner/
synthesizer). This spec adds a step that calls `@code-story` (010) to persist a planning
story containing what Sage already produces.

## In scope
- Add `@code-story` as a sage dependency.
- In Sage's issue/proposal flow, after the proposal is synthesized, build a `planning` story:
  - `narrative`: the proposal + the S/M/L rationale + reuse/conflict findings
  - `diagram` (ascii): the proposed architecture sketch
  - `code` sections: the existing logic/packages Sage identified as reusable (`file:line`)
  - `links`: the Slack thread, the created Linear issue, the Notion page
- `.write(ctx)` it; post the story link in the same Slack proposal message.
- Test: a fixture proposal produces a schema-valid planning story with all four section kinds + links.

## Out of scope
- Changing Sage's planning logic. Narration polish (040 can enrich later). Rendering (030).

## Acceptance
- Sage's planning-story test passes; the emitted story validates against `@code-story/schema`.
- The Slack proposal message includes the story link.

## Review
Reviewer confirms the story reuses Sage's existing proposal output (no parallel re-analysis),
includes the traceable links (Slack/Linear/Notion), and emission failures don't break the
proposal (best-effort, logged). PASS on green tests.

## Handoff
030 renders planning stories; 040 narrator can enrich; the Sage→Ricky→MSD chain now carries a story id.
