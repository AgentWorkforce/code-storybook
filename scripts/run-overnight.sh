#!/usr/bin/env bash
set -uo pipefail
# Overnight spec runner — feeds bounded specs to Ricky one at a time, in dependency
# order, with an implement -> review -> fix cycle per spec.
#
# Two auto-detected modes:
#   single-repo : no spec declares a "**Repo:**" header. All work + a draft PR per wave
#                 land in the repo the runner is invoked from. (original behavior)
#   dispatch    : specs declare "**Repo:** <slug>". Each spec is implemented in its
#                 target repo on a results/<program> branch; one draft PR per touched repo.
#
# Usage: ./scripts/run-overnight.sh <program> [--from <spec-id>] [--dry-run] [--no-pr]
#
# Repo slugs resolve to local paths (override any with REPO_<slug> env, e.g. REPO_sage):
#   code-storybook -> the repo this runner lives in (the shared @code-story package develops here)
#   sage / nightcto / pear -> $PROJECTS_ROOT/<slug>   (PROJECTS_ROOT defaults to the repo's parent)
#   my-senior-dev          -> $PROJECTS_ROOT/../My-Senior-Dev/app

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROGRAM="${1:?Usage: run-overnight.sh <program> [--from <spec-id>] [--dry-run] [--no-pr]}"; shift || true
SPEC_DIR="$ROOT/specs/$PROGRAM"
[ -d "$SPEC_DIR" ] || { echo "No spec dir: $SPEC_DIR"; exit 1; }

FROM=""; DRY_RUN=0; OPEN_PR=1
while [ $# -gt 0 ]; do
  case "$1" in
    --from) FROM="${2:?--from needs a spec id}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --no-pr) OPEN_PR=0; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

MAX_REVIEW_ITERS="${MAX_REVIEW_ITERS:-3}"
# _review.md / _fix.md are referenced by ABSOLUTE path so the reviewer works from any repo's cwd.
REVIEW_CMD="${REVIEW_CMD:-ricky local --spec-file ${SPEC_DIR}/_review.md --run --input TARGET_SPEC=}"
FIX_CMD="${FIX_CMD:-ricky local --spec-file ${SPEC_DIR}/_fix.md --run --input TARGET_SPEC=}"

BRANCH="results/${PROGRAM}"
RUN_LOG="/tmp/nightcto-${PROGRAM}.log"
SPEC_LOG_DIR="/tmp/nightcto-${PROGRAM}-logs"
STATE_FILE="/tmp/nightcto-${PROGRAM}-state.env"
mkdir -p "$SPEC_LOG_DIR"; touch "$RUN_LOG"

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$RUN_LOG"; }
save_state() { printf 'LAST_SPEC=%s\nLAST_STATUS=%s\nBRANCH=%s\nUPDATED_AT=%s\n' "$1" "$2" "$BRANCH" "$(date +%s)" > "$STATE_FILE"; }
wave_of() { basename "$1" | sed -E 's/^([0-9])[0-9]{2}-.*/\1/'; }
repo_of() { grep -m1 -oE '\*\*Repo:\*\* [A-Za-z0-9_-]+' "$1" 2>/dev/null | awk '{print $2}'; }

# ── repo dispatch map ────────────────────────────────────────────────────────
PROJECTS_ROOT="${PROJECTS_ROOT:-$(cd "$ROOT/.." && pwd)}"
repo_path_for_slug() {
  case "$1" in
    ""|self|"$(basename "$ROOT")") echo "$ROOT" ;;
    code-storybook) echo "${REPO_code_storybook:-$ROOT}" ;;
    sage)           echo "${REPO_sage:-$PROJECTS_ROOT/sage}" ;;
    nightcto)       echo "${REPO_nightcto:-$PROJECTS_ROOT/nightcto}" ;;
    pear)           echo "${REPO_pear:-$PROJECTS_ROOT/pear}" ;;
    my-senior-dev)  echo "${REPO_my_senior_dev:-$PROJECTS_ROOT/../My-Senior-Dev/app}" ;;
    *) echo "" ;;
  esac
}

DISPATCH=0
if ls "$SPEC_DIR"/[0-9][0-9][0-9]-*.md >/dev/null 2>&1 && grep -lq '\*\*Repo:\*\*' "$SPEC_DIR"/[0-9][0-9][0-9]-*.md 2>/dev/null; then DISPATCH=1; fi

BRANCHED=""   # space-delimited set of repo paths already on $BRANCH
TOUCHED=""    # newline list of repo paths that received commits

ensure_branch() {  # $1 = repo path
  local p="$1"
  case " $BRANCHED " in *" $p "*) return 0 ;; esac
  ( cd "$p" || exit 1
    if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
      git checkout -q "$BRANCH"
    else
      local base=main
      git rev-parse --verify "origin/$base" >/dev/null 2>&1 || base="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
      git checkout -q -b "$BRANCH" "$base"
    fi ) || { log "ERROR: could not set up $BRANCH in $p"; return 1; }
  BRANCHED="$BRANCHED $p"
  log "branch $BRANCH ready in $(basename "$p")"
}

mark_touched() { case "$TOUCHED" in *"$1"*) : ;; *) TOUCHED="${TOUCHED}
$1" ;; esac; }

# review -> fix loop in a given repo. $1 spec, $2 id, $3 repo path. PASS => 0.
review_cycle() {
  local spec="$1" id="$2" p="$3" verdict="$SPEC_LOG_DIR/$id.review.log"
  local before; before="$( cd "$p" && git rev-parse HEAD )"
  local i
  for ((i=1; i<=MAX_REVIEW_ITERS; i++)); do
    log "REVIEW $id (iter $i/$MAX_REVIEW_ITERS) in $(basename "$p")"
    if [ "$DRY_RUN" -eq 1 ]; then log "DRY-RUN would review $id"; return 0; fi
    if ( cd "$p" && eval "${REVIEW_CMD}${spec}" "$before..HEAD" ) 2>&1 | tee "$verdict" >> "$RUN_LOG"; then
      log "REVIEW PASS $id (iter $i)"; return 0
    fi
    log "REVIEW issues on $id — fix pass (iter $i)"
    ( cd "$p" && eval "${FIX_CMD}${spec}" "$verdict" ) 2>&1 | tee -a "$SPEC_LOG_DIR/$id.log" >> "$RUN_LOG" || true
    ( cd "$p" && git add -A && git commit -q -m "fix(${PROGRAM}): ${id} review iter $i" ) 2>/dev/null || true
  done
  log "REVIEW FAILED $id after $MAX_REVIEW_ITERS iters — stop; resume with --from $id"
  return 1
}

# implement + review one spec in its target repo. $1 spec.
run_spec() {
  local spec="$1" id slug p
  id="$(basename "$spec" .md)"
  if [ "$DISPATCH" -eq 1 ]; then slug="$(repo_of "$spec")"; else slug=""; fi
  p="$(repo_path_for_slug "$slug")"
  if [ -z "$p" ] || [ ! -d "$p" ]; then
    log "ERROR $id: target repo '${slug:-self}' not found at '${p:-?}' (set REPO_* env) — stop; resume with --from $id"
    save_state "$id" repo-missing; return 1
  fi
  log "START $id -> ${slug:-self} ($(basename "$p"))"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY-RUN would: (cd $p && ricky local --spec-file $spec --run)"
    review_cycle "$spec" "$id" "$p"; return 0
  fi
  ensure_branch "$p" || { save_state "$id" branch-failed; return 1; }
  if ! ( cd "$p" && ricky local --spec-file "$spec" --run ) 2>&1 | tee "$SPEC_LOG_DIR/$id.log" >> "$RUN_LOG"; then
    log "IMPLEMENT FAILED $id — stop; resume with --from $id"; save_state "$id" impl-failed; return 1
  fi
  ( cd "$p" && git add -A && git commit -q -m "feat(${PROGRAM}): ${id}" ) 2>/dev/null || true
  mark_touched "$p"
  if ! review_cycle "$spec" "$id" "$p"; then save_state "$id" review-failed; return 1; fi
  ( cd "$p" && git push -q origin "$BRANCH" ) 2>/dev/null || true
  log "DONE $id"; save_state "$id" success; return 0
}

# ── PR helper ────────────────────────────────────────────────────────────────
pr_for_branch() {  # $1 repo path, $2 title, $3 body
  [ "$OPEN_PR" -eq 1 ] || return 0
  [ "$DRY_RUN" -eq 1 ] && return 0
  local p="$1" title="$2" body="$3"
  ( cd "$p"
    git push origin "$BRANCH" 2>/dev/null || git push origin "$BRANCH" --force-with-lease 2>/dev/null || true
    local existing; existing=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")
    if [ -n "$existing" ] && [ "$existing" != "null" ]; then
      echo "PR #$existing exists for $BRANCH in $(basename "$p") — updated via push"
    else
      gh pr create --base main --head "$BRANCH" --draft --title "$title" --body "$body"
    fi ) 2>&1 | tee -a "$RUN_LOG" || true
}

# ── branch setup (legacy single-repo: up-front in $ROOT, preserves original behavior) ──
if [ "$DISPATCH" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then ensure_branch "$ROOT"; fi

# ── walk specs ───────────────────────────────────────────────────────────────
mapfile -t SPECS < <(find "$SPEC_DIR" -maxdepth 1 -name '[0-9][0-9][0-9]-*.md' | sort)
[ "${#SPECS[@]}" -gt 0 ] || { log "No numbered specs in $SPEC_DIR"; exit 1; }

log "MODE: $([ "$DISPATCH" -eq 1 ] && echo dispatch || echo single-repo) · program=$PROGRAM · specs=${#SPECS[@]}"

started=0; [ -z "$FROM" ] && started=1
current_wave=""; wave_specs_md=""
for spec in "${SPECS[@]}"; do
  id="$(basename "$spec" .md)"
  if [ "$started" -eq 0 ]; then
    [[ "$id" == ${FROM}* ]] && started=1 || { log "SKIP $id (before --from $FROM)"; continue; }
  fi

  if [ "$DISPATCH" -eq 0 ]; then
    # legacy: a draft PR per wave in $ROOT
    w="$(wave_of "$spec")"
    if [ -n "$current_wave" ] && [ "$w" != "$current_wave" ]; then
      pr_for_branch "$ROOT" "feat(${PROGRAM}): wave ${current_wave}" "## ${PROGRAM} — wave ${current_wave}

### Specs
${wave_specs_md}
### Verify
\`\`\`bash
npm run build && npm test
\`\`\`
*Auto-opened by run-overnight.sh ${PROGRAM}*"
      wave_specs_md=""
    fi
    current_wave="$w"; wave_specs_md="${wave_specs_md}- \`${id}\`
"
  fi

  run_spec "$spec" || exit 1
done

# ── PRs ──────────────────────────────────────────────────────────────────────
if [ "$DISPATCH" -eq 0 ]; then
  [ -n "$current_wave" ] && pr_for_branch "$ROOT" "feat(${PROGRAM}): wave ${current_wave}" "## ${PROGRAM} — wave ${current_wave}

### Specs
${wave_specs_md}
*Auto-opened by run-overnight.sh ${PROGRAM}*"
else
  printf '%s\n' "$TOUCHED" | sed '/^$/d' | sort -u | while read -r p; do
    [ -n "$p" ] || continue
    specs_md="$(for s in "${SPECS[@]}"; do sp="$(repo_path_for_slug "$(repo_of "$s")")"; [ "$sp" = "$p" ] && echo "- \`$(basename "$s" .md)\`"; done)"
    pr_for_branch "$p" "feat(${PROGRAM}): $(basename "$p") specs" "## ${PROGRAM} — specs implemented in \`$(basename "$p")\`

${specs_md}
### Verify
\`\`\`bash
npm run build && npm test
\`\`\`
*Auto-opened by run-overnight.sh ${PROGRAM} (dispatch mode)*"
  done
fi

log "ALL_DONE ${PROGRAM}"
log "Branch in each touched repo: $BRANCH"
