# Code Storybook — Phase 2 (deferred, cross-repo)

**Status: DEFERRED.** Do not run until Phase 1 (`specs/storybook/`) is shipped and you want
either (a) **richer** stories than the watcher can synthesize from observed artifacts, or
(b) stories rendered **inline** inside Pear / MSD rather than only the standalone viewer.

Phase 1 is self-contained (one repo): a watcher synthesizes stories from relayfile, a
standalone viewer renders them — zero changes to other repos. Phase 2 trades that
self-containment for richness/inline-surfaces by editing the product repos. It is **cross-repo**,
so these specs carry a `**Repo:**` slug and run via the runner's **dispatch mode**:

```bash
./scripts/run-overnight.sh storybook-phase2 --dry-run   # confirm per-repo routing
./scripts/run-overnight.sh storybook-phase2             # one PR per touched repo
```

## What Phase 2 adds (and why it's optional)

| Spec | Repo | Adds | Why deferred |
|---|---|---|---|
| `010-sage-planning-emit` | sage | Sage emits a planning story with its **internal** S/M/L rationale + reuse analysis as first-class data | Phase 1's `021` already synthesizes a planning story from what Sage writes to relayfile; this is richer, not required |
| `020-msd-review-emit` | my-senior-dev | MSD emits a review story with its own findings/merge-readiness model | Phase 1's `022` synthesizes from `/github/**/reviews/**`; richer, not required |
| `021-msd-webapp-embed` | my-senior-dev | Mount `@code-story/react` inside MSD's webapp (`/stories` route) | Standalone viewer (Phase 1 `031`) already serves the web experience |
| `030-nightcto-runtime-emit` | nightcto | NightCTO emits a runtime story with triage internals at incident time | Phase 1's `023` synthesizes from `/nightcto/signals/**`; richer, not required |
| `040-pear-embed` | pear | Mount `@code-story/react` as a Pear `story` ViewMode | Pear is the desktop coordinating layer; inline embed is polish over the standalone viewer |

## Dependencies

All Phase 2 specs depend on Phase 1 being merged (the `@code-story` packages published and the
artifact schema stable). Each emit spec supersedes its Phase 1 synthesizer for that layer — when
a product emits a richer story, the watcher should defer to the emitted one (dedupe by subject).

## Conventions

Same bounded format + review cycle as Phase 1 (`Goal / In scope / Out of scope / Acceptance /
Review / Handoff`, reviewer is a different persona; reuse `_review.md` / `_fix.md`). Each spec
declares `**Repo:** <slug>` so the runner dispatches it to the right repo.
