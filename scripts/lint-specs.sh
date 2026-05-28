#!/usr/bin/env bash
set -uo pipefail
# Lint every numbered spec for the structure the overnight runner + reviewer rely on.
# Fails (exit 1) if any spec is missing a required section or the **Repo:** dispatch header.
# Usage: ./scripts/lint-specs.sh [specs-glob-root]   (default: ./specs)

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPECS_ROOT="${1:-$ROOT/specs}"

REQUIRED_SECTIONS=("## Goal" "## In scope" "## Out of scope" "## Acceptance" "## Review" "## Handoff")
REQUIRED_HEADERS=("**Repo:**")   # machine-readable dispatch target

fail=0
count=0
# numbered specs only; skip _review.md/_fix.md/PROGRAM.md
while IFS= read -r f; do
  count=$((count+1))
  missing=""
  for s in "${REQUIRED_SECTIONS[@]}"; do
    grep -qF "$s" "$f" || missing="${missing}\n    missing section: ${s}"
  done
  for h in "${REQUIRED_HEADERS[@]}"; do
    grep -qF "$h" "$f" || missing="${missing}\n    missing header: ${h}"
  done
  # the Repo header must resolve to a known slug
  if grep -qF "**Repo:**" "$f"; then
    slug="$(grep -m1 -oE '\*\*Repo:\*\* [A-Za-z0-9_-]+' "$f" | awk '{print $2}')"
    case "$slug" in
      code-storybook|sage|nightcto|pear|my-senior-dev) : ;;
      *) missing="${missing}\n    unknown **Repo:** slug: '${slug}' (allowed: code-storybook|sage|nightcto|pear|my-senior-dev)" ;;
    esac
  fi
  if [ -n "$missing" ]; then
    fail=1
    printf 'FAIL %s%b\n' "${f#"$ROOT"/}" "$missing"
  fi
done < <(find "$SPECS_ROOT" -type f -name '[0-9][0-9][0-9]-*.md' | sort)

if [ "$count" -eq 0 ]; then echo "No numbered specs found under $SPECS_ROOT"; exit 1; fi
if [ "$fail" -eq 0 ]; then
  echo "OK — $count specs, all have required sections + a valid **Repo:** header."
else
  echo
  echo "Spec lint failed. Each numbered spec needs: ${REQUIRED_SECTIONS[*]} and a **Repo:** <slug> header."
fi
exit "$fail"
