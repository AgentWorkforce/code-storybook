# Code Storybook — Spec Program (Phase 1, self-contained)

**Goal:** A read-only, AI-narrated "storybook" of the codebase that keeps humans close to
the code across three moments — **Planning** (Sage), **Code Review** (MSD), and **Runtime
issues** (NightCTO) — with ASCII/architecture diagrams, syntax-highlighted code flows, and
code-health metrics (churn, hotspots, coverage). Humans read and stay aware; agents do the
writing.

**Phase 1 is self-contained: it lives entirely in this repo and touches no other.** A watcher
synthesizes stories from artifacts products *already* write to relayfile (pull, not push), and a
standalone web viewer renders them. Per-product emit hooks and Pear/MSD inline embeds are
**deferred to Phase 2** (`specs/storybook-phase2/`).

Built like the NightCTO migration: small bounded specs, implemented by Ricky via
`scripts/run-overnight.sh storybook`, each gated by the implement→review→fix cycle. No
`**Repo:**` headers here → the runner stays in single-repo per-wave mode.

## Architecture

```
products already write to relayfile (no storybook code in them):
   Sage → /notion,/linear specs   MSD → /github/**/reviews   NightCTO → /nightcto/signals
                         │ (the watcher OBSERVES these)
                         ▼
   personas/story-builder  ──synthesize via──▶  @code-story/skill  ──writes──▶  /stories/<type>/<id>.json
                                                     ▲   ▲
                               code-narrator persona ┘   └ code-health persona (churn/hotspots/coverage)
                                                     │
                                          @code-story/react  (read-only renderer, vendored from MSD)
                                                     │
                                          web/ standalone viewer + guided tour   ◀── the Phase 1 surface
```

Reuses what's already in the tree:
- **relayfile** is the substrate *and* the integration mechanism — the watcher reads the files
  products already produce, so Phase 1 needs zero changes in sage/MSD/nightcto/pear.
- **MSD's renderer** (`FileDetailModal` tokenizer, `lib/diffUtils.ts`, `PRStory` slide-deck) — the
  backend-free parts are **vendored** into `@code-story/react` (030), not reimplemented and not imported.
- **persona** model for the three helper agents (story-builder, narrator, health).

## Waves (all in this repo)

### Wave 0 — Contract
- `000-storybook-program-and-boundary.md` — scope, three layers + their relayfile source paths, pull principle, Phase 2 deferral
- `001-code-story-artifact-schema.md` — the versioned `CodeStory` artifact

### Wave 1 — Library
- `010-story-writer-skill.md` — `@code-story/skill`: build + write a story to relayfile
- `011-story-index-and-acl.md` — `/stories` index + relayfile ACL

### Wave 2 — Story-builder watcher (pull, no product edits)
- `020-story-builder-watcher.md` — persona that watches relayfile + routes to synthesizers
- `021-planning-story-synthesis.md` — synthesize planning stories from Sage's observed artifacts
- `022-review-story-synthesis.md` — synthesize review stories from `/github/**/reviews/**`
- `023-runtime-story-synthesis.md` — synthesize runtime stories from `/nightcto/signals/**`

### Wave 3 — Renderer + standalone viewer
- `030-shared-renderer-package.md` — `@code-story/react`, vendored from MSD's render primitives
- `031-standalone-web-viewer.md` — self-hosted web app: list + render stories (the Phase 1 surface)
- `032-guided-tour.md` — stepped guided-tour mode (generalized `PRStory`) in the viewer

### Wave 4 — Narration, health & proof
- `040-code-narrator-persona.md` — persona that writes the AI narration track into a story
- `041-code-health-persona.md` — periodic persona: churn/hotspots/coverage → relayfile overlay
- `042-storybook-acceptance-proof.md` — e2e: synthesize 3 layers from fixtures → narrate → health → render + tour

## Phase 2 (deferred, cross-repo)

When you want richer stories (products emit with internal context) or inline surfaces inside
Pear/MSD, see `specs/storybook-phase2/` — those specs carry `**Repo:**` slugs and run via the
runner's dispatch mode (`./scripts/run-overnight.sh storybook-phase2`). Phase 2 is optional and
supersedes the relevant Phase 1 synthesizer per layer (dedupe by subject).

## Review cycle & conventions

Same as `persona-migration`: every spec ends with `## Acceptance` + `## Review`; the runner does
implement → review (a *different* persona) → fix, looping to PASS. Reuse `_review.md` / `_fix.md`.
Keep each spec to one reviewable unit. `scripts/lint-specs.sh` (CI) enforces the section structure.
