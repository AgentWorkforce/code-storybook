#!/usr/bin/env bash
set -uo pipefail
# NightCTO overnight spec runner
# Feeds bounded specs to Ricky one at a time, in dependency order.
# Usage: ./scripts/run-overnight.sh <program> [--from <spec-id>] [--dry-run] [--no-pr]
# Example: ./scripts/run-overnight.sh persona-migration
#          ./scripts/run-overnight.sh persona-migration --from 030
#
# Each spec is implemented by:  ricky local --spec-file <spec> --run
# A draft PR is opened per wave (specs sharing the NNx hundreds digit).

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROGRAM="${1:?Usage: run-overnight.sh <program> [--from <spec-id>] [--dry-run] [--no-pr]}"; shift || true
SPEC_DIR="$ROOT/specs/$PROGRAM"
[ -d "$SPEC_DIR" ] || { echo "No spec dir: $SPEC_DIR"; exit 1; }

FROM=""; DRY_RUN=0; OPEN_PR=1
while [ $# -gt 0 ]; do
  case "$1" in
    --from) FROM="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --no-pr) OPEN_PR=0; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# Review cycle config. The reviewer is a DIFFERENT persona from the implementer.
# REVIEW_CMD receives the spec path as $1 and the diff range as $2; exits 0 on PASS,
# non-zero with findings on stdout otherwise. FIX_CMD receives the spec path as $1
# and the reviewer findings file as $2. Both are overridable for local/cloud/BYOH.
MAX_REVIEW_ITERS="${MAX_REVIEW_ITERS:-3}"
# Each program carries its own _review.md / _fix.md (parameterized by TARGET_SPEC).
REVIEW_CMD="${REVIEW_CMD:-ricky local --spec-file specs/${PROGRAM}/_review.md --run --input TARGET_SPEC=}"
FIX_CMD="${FIX_CMD:-ricky local --spec-file specs/${PROGRAM}/_fix.md --run --input TARGET_SPEC=}"

STATE_FILE="/tmp/nightcto-${PROGRAM}-state.env"
RUN_LOG="/tmp/nightcto-${PROGRAM}.log"
SPEC_LOG_DIR="/tmp/nightcto-${PROGRAM}-logs"
BRANCH="results/${PROGRAM}"
mkdir -p "$SPEC_LOG_DIR"; touch "$RUN_LOG"

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$RUN_LOG"; }
save_state() { printf 'LAST_SPEC=%s\nLAST_STATUS=%s\nBRANCH=%s\nUPDATED_AT=%s\n' \
  "$1" "$2" "$BRANCH" "$(date +%s)" > "$STATE_FILE"; }

wave_of() { basename "$1" | sed -E 's/^([0-9])[0-9]{2}-.*/\1/'; }

open_wave_pr() {
  local wave="$1" specs_md="$2"
  [ "$OPEN_PR" -eq 1 ] || return 0
  git push origin "$BRANCH" 2>/dev/null || git push origin "$BRANCH" --force-with-lease 2>/dev/null || true
  local existing; existing=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")
  if [ -n "$existing" ] && [ "$existing" != "null" ]; then
    log "PR #$existing exists for $BRANCH — updated via push"; return 0
  fi
  gh pr create --base main --head "$BRANCH" --draft \
    --title "feat(${PROGRAM}): wave ${wave}" \
    --body "## ${PROGRAM} — wave ${wave}

### Specs implemented this wave
${specs_md}

### Verify
\`\`\`bash
tail -40 ${RUN_LOG}
npm run build && npm test
\`\`\`

*Auto-opened by \`scripts/run-overnight.sh ${PROGRAM}\`*" 2>&1 | tee -a "$RUN_LOG" || true
}

# Review → fix loop for one spec. Returns 0 only when the reviewer reaches PASS.
review_cycle() {
  local spec="$1" id="$2" verdict="$SPEC_LOG_DIR/$id.review.log"
  local before; before="$(git rev-parse HEAD)"
  local i
  for ((i=1; i<=MAX_REVIEW_ITERS; i++)); do
    log "REVIEW $id (iter $i/$MAX_REVIEW_ITERS)"
    if [ "$DRY_RUN" -eq 1 ]; then log "DRY-RUN would run REVIEW_CMD for $id"; return 0; fi
    if eval "${REVIEW_CMD}${spec}" "$before..HEAD" 2>&1 | tee "$verdict" >> "$RUN_LOG"; then
      log "REVIEW PASS $id (iter $i)"; return 0
    fi
    log "REVIEW found issues on $id — running fix pass (iter $i)"
    eval "${FIX_CMD}${spec}" "$verdict" 2>&1 | tee -a "$SPEC_LOG_DIR/$id.log" >> "$RUN_LOG" || true
    git add -A && git commit -m "fix(${PROGRAM}): ${id} review iter $i" 2>/dev/null || true
  done
  log "REVIEW FAILED $id after $MAX_REVIEW_ITERS iters — stopping; resume with --from $id"
  return 1
}

run_spec() {
  local spec="$1" id; id="$(basename "$spec" .md)"
  local spec_log="$SPEC_LOG_DIR/$id.log"
  log "START $id"
  if [ "$DRY_RUN" -eq 1 ]; then log "DRY-RUN would run: ricky local --spec-file $spec --run"; return 0; fi
  if ! ricky local --spec-file "$spec" --run 2>&1 | tee "$spec_log" >> "$RUN_LOG"; then
    log "IMPLEMENT FAILED $id (see $spec_log) — stopping; resume with --from $id"
    save_state "$id" impl-failed; return 1
  fi
  git add -A && git commit -m "feat(${PROGRAM}): ${id}" 2>/dev/null || true
  # implement → review → fix until the reviewer reaches PASS
  if ! review_cycle "$spec" "$id"; then save_state "$id" review-failed; return 1; fi
  log "DONE $id (implemented + reviewed PASS)"; save_state "$id" success
  return 0
}

# ── branch setup ─────────────────────────────────────────────────────────────
cd "$ROOT"
if [ "$DRY_RUN" -eq 1 ]; then
  log "DRY-RUN — not creating/switching branches"
elif git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  git checkout "$BRANCH"; log "Resuming branch $BRANCH"
else
  git checkout -b "$BRANCH" main; log "Created branch $BRANCH from main"
fi

# ── walk specs in order ──────────────────────────────────────────────────────
mapfile -t SPECS < <(find "$SPEC_DIR" -maxdepth 1 -name '[0-9][0-9][0-9]-*.md' | sort)
[ "${#SPECS[@]}" -gt 0 ] || { log "No numbered specs in $SPEC_DIR"; exit 1; }

started=0; [ -z "$FROM" ] && started=1
current_wave=""; wave_specs_md=""
for spec in "${SPECS[@]}"; do
  id="$(basename "$spec" .md)"
  if [ "$started" -eq 0 ]; then
    [[ "$id" == ${FROM}* ]] && started=1 || { log "SKIP $id (before --from $FROM)"; continue; }
  fi
  w="$(wave_of "$spec")"
  if [ -n "$current_wave" ] && [ "$w" != "$current_wave" ]; then
    open_wave_pr "$current_wave" "$wave_specs_md"; wave_specs_md=""
  fi
  current_wave="$w"; wave_specs_md="${wave_specs_md}- \`${id}\`
"
  run_spec "$spec" || exit 1
done
[ -n "$current_wave" ] && open_wave_pr "$current_wave" "$wave_specs_md"

log "ALL_DONE ${PROGRAM}"
log "Branch: $BRANCH — review at https://github.com/AgentWorkforce/nightcto/pulls"
