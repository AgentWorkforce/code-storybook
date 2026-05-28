# Code Storybook

A read-only, AI-narrated **storybook of the codebase** that keeps humans close to the code
across three moments — **Planning** (Sage), **Code Review** (MSD), and **Runtime issues**
(NightCTO) — with ASCII/architecture diagrams, syntax-highlighted code flows, and code-health
metrics (churn, hotspots, coverage). Agents do the writing; humans read and stay aware.

This repo holds the **spec program** and the **runbook**. It is built spec-by-spec by Ricky
(the workflow agent) via an overnight runner — not hand-written all at once.

## How it works

```
Sage / MSD / NightCTO workflows
   │  (call the shared story-writer skill as a side-effect of their work)
   ▼
@code-story/skill  ──writes──▶  relayfile  /stories/<type>/<id>.json   (the artifact)
                                    ▲   ▲
              code-narrator persona ┘   └ code-health persona (churn/hotspots/coverage)
                                    │
                    @code-story/react  (one shared, artifact-driven, read-only renderer,
                       ▲ extracted from MSD's renderer + PRStory)
        ┌──────────────┼───────────────┐
   MSD webapp      Pear `story`     web guided tour (stepped)
   (primary web)   view mode        hosted by MSD webapp + Pear
```

- **relayfile** is the artifact substrate — stories are JSON files; "the filesystem is the protocol."
- The **renderer is extracted from MSD** (custom tokenizer highlighting, `diffUtils`, and the
  `PRStory` slide-deck), generalized into one backend-free `@code-story/react` package that MSD's
  webapp, Pear, and the web tour all consume — so no surface reimplements code rendering.
- Two helper **personas** (narrator, health) enrich stories; the three product agents emit them.

See [`specs/storybook/PROGRAM.md`](specs/storybook/PROGRAM.md) for the full architecture and
[`docs/storybook-boundary.md`] (produced by spec `000`) for the frozen scope.

## Why its own repo

Storybook spans repos — Sage, MSD, Pear, and a shared `@code-story` package all participate.
It does not belong inside any one of them, so the spec program + orchestration live here.

## Spec program (14 specs, 5 waves)

| Wave | Specs | Target |
|---|---|---|
| 0 — Contract | `000` boundary · `001` `CodeStory` schema | shared `@code-story` |
| 1 — Writer | `010` story-writer skill · `011` index + ACL | shared `@code-story` |
| 2 — Emit | `020` Sage planning · `021` MSD review · `022` NightCTO runtime | sage · My-Senior-Dev/app · nightcto |
| 3 — Renderer | `030` extract `@code-story/react` from MSD · `031` Pear mount · `032` MSD webapp surface · `033` web tour | My-Senior-Dev/app → shared · pear |
| 4 — Narrate/health/proof | `040` narrator persona · `041` health persona · `042` e2e proof | shared (cross-repo e2e) |

Each spec is bounded (`Goal / Context / In scope / Out of scope / Acceptance / Review / Handoff`)
and ends with a reviewer-checkable PASS gate.

## Runbook

Specs are implemented one at a time by Ricky, in dependency order, with an
**implement → review → fix** cycle per spec (the reviewer is a *different* persona; see
`specs/storybook/_review.md` / `_fix.md`).

```bash
# inspect the plan (no side effects)
./scripts/run-overnight.sh storybook --dry-run

# run it: implement → review → fix each spec, commit, open a draft PR per wave
./scripts/run-overnight.sh storybook
```

Flags / env:
- `--from <spec-id>` — resume from a spec (e.g. `--from 030`)
- `--no-pr` — skip per-wave draft PRs
- `MAX_REVIEW_ITERS` (default 3) — review/fix loop cap
- `REVIEW_CMD` / `FIX_CMD` — override the reviewer/fixer invocation (default: Ricky local with `_review.md` / `_fix.md`)

### Cross-repo execution (important)

The runner commits in whichever repo it is invoked from. Because storybook is cross-repo:

- Build the **shared pieces first** (`@code-story/schema`, `@code-story/skill`, `@code-story/react`)
  from waves 0–1 and the extract in `030`, publish the package, **then** run the per-product
  emit/mount specs (waves 2–3) from each target repo — or via Ricky cloud with that repo materialized.
- The target repo for each spec is in its header and in `PROGRAM.md`'s cross-repo plan.

Treat each wave (or each target repo's slice of a wave) as a separate Ricky handoff; let the
review cycle gate each before moving on.

## Related

- `AgentWorkforce/nightcto` → `specs/persona-migration/` — the reference persona migration this
  storybook program assumes (NightCTO emits runtime stories from its migrated watch handler).
- `AgentWorkforce/nightcto` → `specs/INVENTORY.md` — front door indexing both programs.
