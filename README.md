# Code Storybook

A read-only, AI-narrated **storybook of the codebase** that keeps humans close to the code
across three moments — **Planning** (Sage), **Code Review** (MSD), and **Runtime issues**
(NightCTO) — with ASCII/architecture diagrams, syntax-highlighted code flows, and code-health
metrics (churn, hotspots, coverage). Agents do the writing; humans read and stay aware.

This repo holds the **spec program** and the **runbook**. It is built spec-by-spec by Ricky
(the workflow agent) via an overnight runner — not hand-written all at once.

## Two phases

- **Phase 1 — self-contained (default).** Everything lives in this repo. A **watcher** persona
  synthesizes stories from artifacts products *already* write to relayfile (pull, not push), and
  a **standalone web viewer** renders them. **Zero changes to sage/MSD/nightcto/pear.** One repo,
  one deploy, per-wave PRs. → `specs/storybook/`
- **Phase 2 — deferred, cross-repo (optional).** When you want *richer* stories (products emit
  with their internal context) or stories rendered *inline* inside Pear/MSD, edit those repos.
  Cross-repo, so it runs via dispatch mode. → `specs/storybook-phase2/`

Start with Phase 1; reach for Phase 2 only where the extra richness/inline-surface pays off.

## How Phase 1 works

```
products already write to relayfile (no storybook code in them):
   Sage → /notion,/linear   MSD → /github/**/reviews   NightCTO → /nightcto/signals
                       │ (the watcher OBSERVES these)
                       ▼
   personas/story-builder ─synthesize→ @code-story/skill ─writes→ /stories/<type>/<id>.json
                                            ▲   ▲
                      code-narrator persona ┘   └ code-health persona (churn/hotspots/coverage)
                                            │
                                 @code-story/react (read-only renderer, vendored from MSD)
                                            │
                                 web/ standalone viewer + guided tour   ◀── the Phase 1 surface
```

- **relayfile** is the substrate *and* the integration: the watcher reads files products already
  produce, so Phase 1 touches no other repo. "The filesystem is the protocol."
- The renderer is **vendored from MSD** (its tokenizer highlighting, `diffUtils`, and the `PRStory`
  slide-deck) into one backend-free `@code-story/react` — a one-time copy, no MSD import/edit.

See [`specs/storybook/PROGRAM.md`](specs/storybook/PROGRAM.md) for the architecture and
`docs/storybook-boundary.md` (produced by spec `000`) for the frozen scope.

## Phase 1 spec program (14 specs, 5 waves — all in this repo)

| Wave | Specs |
|---|---|
| 0 — Contract | `000` boundary · `001` `CodeStory` schema |
| 1 — Library | `010` story-writer skill · `011` index + ACL |
| 2 — Watcher | `020` story-builder · `021` planning synthesis · `022` review synthesis · `023` runtime synthesis |
| 3 — Renderer + viewer | `030` `@code-story/react` (vendored) · `031` standalone viewer · `032` guided tour |
| 4 — Narrate/health/proof | `040` narrator persona · `041` health persona · `042` e2e proof |

Each spec is bounded (`Goal / Context / In scope / Out of scope / Acceptance / Review / Handoff`)
and ends with a reviewer-checkable PASS gate.

## Runbook

Specs are implemented one at a time by Ricky, in dependency order, with an
**implement → review → fix** cycle per spec (the reviewer is a *different* persona; see
`specs/storybook/_review.md` / `_fix.md`).

```bash
# Phase 1 (self-contained, single repo, per-wave PRs)
./scripts/run-overnight.sh storybook --dry-run    # inspect the plan (no side effects)
./scripts/run-overnight.sh storybook              # implement → review → fix, commit, PR per wave
```

Flags / env:
- `--from <spec-id>` — resume from a spec (e.g. `--from 030`)
- `--no-pr` — skip per-wave draft PRs
- `MAX_REVIEW_ITERS` (default 3) — review/fix loop cap
- `REVIEW_CMD` / `FIX_CMD` — override the reviewer/fixer invocation

### Phase 2 (deferred, cross-repo dispatch)

Phase 2 specs declare a machine-readable `**Repo:**` slug; the runner auto-detects these and
switches to **dispatch mode** — each spec is implemented in its target repo on a
`results/storybook-phase2` branch, one draft PR **per touched repo**.

```bash
./scripts/run-overnight.sh storybook-phase2 --dry-run   # prints START <spec> -> <slug> (<repo>)
./scripts/run-overnight.sh storybook-phase2
```

Slugs resolve to local repo paths (sibling clones assumed): `sage`, `nightcto`, `pear` →
`$PROJECTS_ROOT/<slug>`; `my-senior-dev` → `$PROJECTS_ROOT/../My-Senior-Dev/app`. `PROJECTS_ROOT`
defaults to this repo's parent; override any path with `REPO_<slug>` (e.g. `REPO_my_senior_dev=…`).
Phase 2 depends on Phase 1 being merged and `@code-story` published.

## Spec format & CI

Every numbered spec must carry the sections the runner + reviewer rely on
(`Goal / In scope / Out of scope / Acceptance / Review / Handoff`). A `**Repo:**` slug is
**optional** (Phase 1 omits it; Phase 2 requires it for dispatch) and, when present, must be a
valid slug. `scripts/lint-specs.sh` enforces this in CI (`.github/workflows/lint-specs.yml`) on
every push/PR touching `specs/`:

```bash
./scripts/lint-specs.sh        # OK — N specs, all have required sections (and any **Repo:** slug is valid)
```

## Related

- `AgentWorkforce/nightcto` → `specs/persona-migration/` — the reference persona migration this
  program assumes (NightCTO writes the `/nightcto/signals/**` the runtime synthesizer reads).
- `AgentWorkforce/nightcto` → `specs/INVENTORY.md` — front door indexing both programs.
