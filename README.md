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

### Cross-repo dispatch (automatic)

Storybook is cross-repo, so each spec declares a machine-readable **`**Repo:**` slug** in its
header. The runner auto-detects these and switches to **dispatch mode**: each spec is
implemented in its **target repo** on a `results/storybook` branch, and a draft PR is opened
**per touched repo** — no manual repo-hopping.

Slugs resolve to local repo paths (sibling clones assumed):

| slug | resolves to | holds |
|---|---|---|
| `code-storybook` | this repo | the shared `@code-story` package (schema, skill, `react` renderer, helper personas) |
| `sage` | `$PROJECTS_ROOT/sage` | `020` planning story |
| `my-senior-dev` | `$PROJECTS_ROOT/../My-Senior-Dev/app` | `021` review story, `030` extract, `032` webapp surface |
| `nightcto` | `$PROJECTS_ROOT/nightcto` | `022` runtime story |
| `pear` | `$PROJECTS_ROOT/pear` | `031` story view |

`PROJECTS_ROOT` defaults to this repo's parent; override any path with `REPO_<slug>` env
(e.g. `REPO_my_senior_dev=/path/to/app`). Inspect routing first with `--dry-run`:

```bash
./scripts/run-overnight.sh storybook --dry-run   # prints START <spec> -> <slug> (<repo>)
```

Because of dependencies, the shared pieces (waves 0–1 + the `030` extract) build first in
`code-storybook`; publish `@code-story`, then the per-product specs consume it. The runner
walks them in order and the review cycle gates each before moving on.

## Spec format & CI

Every numbered spec must carry the sections the runner + reviewer rely on
(`Goal / In scope / Out of scope / Acceptance / Review / Handoff`) and a valid `**Repo:**`
slug. `scripts/lint-specs.sh` enforces this and runs in CI (`.github/workflows/lint-specs.yml`)
on every push/PR touching `specs/`:

```bash
./scripts/lint-specs.sh        # OK — N specs, all have required sections + a valid **Repo:** header
```

## Related

- `AgentWorkforce/nightcto` → `specs/persona-migration/` — the reference persona migration this
  storybook program assumes (NightCTO emits runtime stories from its migrated watch handler).
- `AgentWorkforce/nightcto` → `specs/INVENTORY.md` — front door indexing both programs.
