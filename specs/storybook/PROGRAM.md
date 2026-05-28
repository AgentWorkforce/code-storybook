# Code Storybook — Spec Program

**Goal:** A read-only, AI-narrated "storybook" of the codebase that keeps humans close to
the code across three moments — **Planning** (Sage), **Code Review** (MSD), and **Runtime
issues** (NightCTO) — with ASCII/architecture diagrams, syntax-highlighted code flows, and
code-health metrics (churn, hotspots, coverage). Humans read and stay aware; agents do the
writing. This is the dream's "guided tour on the web in a storybook type of way" + "keeps
the human in control and aware of the codebase health."

Built the same way as the NightCTO migration: many small bounded specs, implemented by
Ricky via `scripts/run-overnight.sh storybook`, each gated by the implement→review→fix cycle.

## Architecture (grounded in what already exists)

```
Sage / MSD / NightCTO workflows
   │  (call the shared story-writer skill as a side-effect of their work)
   ▼
@code-story/skill  ──writes──▶  relayfile  /stories/<type>/<id>.json   (the artifact)
                                    ▲   ▲
              code-narrator persona ┘   └ code-health persona (churn/hotspots/coverage)
                                    │
                    @code-story/react  (one shared, artifact-driven, read-only renderer)
                       ▲ extracted from MSD's renderer + PRStory
        ┌──────────────┼───────────────┐
   MSD webapp      Pear `story`     web guided tour (stepped)
   (primary web)   view mode        hosted by MSD webapp + Pear
```

Reuses what's already in the tree — crucially, **MSD already has the best renderer in the org**:
- **MSD's webapp renderer** (`packages/webapp/src/components/FileDetailModal.tsx` +
  `lib/diffUtils.ts`, `diffSymbolExtractor.ts`): custom tokenizer syntax highlighting,
  split/unified diff parsing, symbol extraction — the backend-free parts are extracted into
  `@code-story/react` (030) rather than reimplemented.
- **MSD's `PRStory`** slide-deck (`packages/webapp/src/components/PRStory/`): already a
  narrative walkthrough; generalized into the stepped tour (033).
- **relayfile** as the artifact substrate (`@relayfile/sdk`, "the filesystem is the protocol").
- **Pear**'s `ViewMode`/mount points + `@xyflow/react` for flow diagrams — Pear *mounts* the
  shared renderer (031), it does not build its own.
- **persona** model for the two helper agents (narrator, health).
- The renderer is decoupled from MSD's backend (`PRInfo`/`api.*`), so the same component
  renders planning/review/runtime stories on every surface.

## Cross-repo note (important)

Unlike the NightCTO migration (one repo), storybook spans repos. Each spec's header names
its **target repo**. Implement options:
- run a spec's Ricky handoff *from its target repo*, or
- use Ricky cloud with that repo materialized (relayfile), or
- the shared pieces (`@code-story/schema`, `@code-story/skill`) live in **one** shared
  package consumed by all three agents — build those first (Wave 0/1), publish, then the
  per-agent emit specs (Wave 2) depend on the published package.

The `scripts/run-overnight.sh storybook` runner walks these in order; for cross-repo specs
it commits in whichever repo it is invoked from. Treat waves 2–3 as per-repo handoffs.

## Waves

### Wave 0 — Contract (shared)  ·  target: shared `@code-story` package
- `000-storybook-program-and-boundary.md` — scope, three layers, artifact location, cross-repo plan
- `001-code-story-artifact-schema.md` — the versioned relayfile artifact schema

### Wave 1 — Story-writer skill (shared)  ·  target: `@code-story` package
- `010-story-writer-skill.md` — callable skill: build + write a story to relayfile
- `011-story-index-and-acl.md` — `/stories` index + relayfile ACL (humans/Pear read, agents write)

### Wave 2 — Emit steps (per agent)
- `020-sage-planning-story.md`     · target: sage      — planning story from the issue pipeline
- `021-msd-review-story.md`        · target: My-Senior-Dev/app — review story from a PR review
- `022-nightcto-runtime-story.md`  · target: nightcto   — runtime story from an incident

### Wave 3 — Renderer (shared, multi-surface)
- `030-shared-renderer-package.md`  · target: My-Senior-Dev/app → shared — extract MSD's renderer + PRStory into `@code-story/react`
- `031-pear-story-view-mode.md`     · target: pear — Pear mounts the shared renderer
- `032-msd-webapp-story-surface.md` · target: My-Senior-Dev/app — MSD webapp mounts it (primary web surface)
- `033-story-web-tour.md`           · target: shared (hosted by MSD webapp + Pear) — stepped tour (generalized `PRStory`)

### Wave 4 — Narration, health & proof
- `040-code-narrator-persona.md` — persona that writes the AI narration track into a story
- `041-code-health-persona.md` — periodic persona: churn/hotspots/coverage → relayfile overlay
- `042-storybook-acceptance-proof.md` — e2e: one story per layer renders with narration + metrics

## Review cycle & conventions

Identical to `specs/persona-migration/PROGRAM.md`: every spec ends with `## Acceptance` +
`## Review`; the runner does implement → review (a *different* persona) → fix, looping to
PASS. Reuse `_review.md` / `_fix.md` (point `TARGET_SPEC` at these specs). Keep each spec to
one reviewable unit.
