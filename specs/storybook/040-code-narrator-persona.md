# 040 — Code-narrator persona

**Status:** PROPOSED | **Target repo:** shared (`@code-story` package + a persona) | **Depends on:** 010, 011 | **Repo:** code-storybook

## Goal
A small proactive persona that watches for new/updated stories and enriches them with an
AI **narration track** — turning raw sections into a guided, human-readable walkthrough.

## Context
The emit specs (020–022) write factual stories; narration is a separable concern, so a
dedicated persona keeps each agent's emit cheap and lets narration improve independently.
It is a `definePersona` handler triggered by a relayfile watch on `/stories/**`.

## In scope
- `personas/code-narrator/persona.ts` (`definePersona`, `onEvent`), `watch` on `/stories/**` (new/updated, where `narrative` is thin or flagged `needsNarration`).
- `agent.ts`: read the story, read the referenced `code`/`diff`/`diagram` sections, generate a concise narration (what changed, why it matters, what to look at, smells/duplication to watch), and write it back into the story's `narrative` via the `@code-story` writer (idempotent update, not a new story).
- Guardrails: never alters non-narrative sections; marks the story `narratedAt`.
- Test: a thinly-narrated fixture story gets a narration track; re-running is idempotent (no duplicate narration).

## Out of scope
- Generating code/diff/metrics. Rendering. Editing the underlying repo.

## Acceptance
- `npm test -- code-narrator` passes including idempotency.
- Narration only touches `narrative` sections + `narratedAt` (asserted).

## Review
Reviewer confirms the narrator only enriches narration (no other section mutated), is
idempotent, and degrades (leaves the story usable) if generation fails. PASS on green tests.

## Handoff
030/031 render the enriched narration; 042 asserts a narrated story.
