# 030 — Shared renderer package (`@code-story/react`)

**Status:** PROPOSED | **Target repo:** My-Senior-Dev/app (extract) → shared `@code-story` | **Depends on:** 001

## Goal
Extract MSD's existing code-rendering strengths into a shared, **artifact-driven** React
renderer that takes a `CodeStory` (001) and renders it with no backend coupling — so MSD's
webapp, Pear, and the web tour all render from the same package instead of reimplementing.

## Context
MSD already has the best renderer in the org, but it's trapped behind its backend:
- `packages/webapp/src/components/FileDetailModal.tsx` — custom tokenizer syntax highlighting (JS/TS/Python/SQL), split/unified diff, line UI.
- `packages/webapp/src/lib/diffUtils.ts`, `diffSymbolExtractor.ts`, `codeDocumentation.ts` — diff parsing + symbol/doc extraction, **already backend-free**.
- `packages/webapp/src/components/PRStory/` — a narrative slide-deck (Overview → Narrative → Files → Summary): the proto-storybook.

These assume `PRInfo` + `api.*` (annotations, chat, GitHub sync). We lift the *pure* pieces
and re-wrap them around the `CodeStory` artifact. Stack is compatible: MSD webapp is React
18 + Tailwind 4 + framer-motion + react-markdown; Pear is React 19 + Tailwind 4.

## In scope
- New package `@code-story/react` exporting section renderers driven purely by props (no `PRInfo`, no `api.*`, no fetch):
  - `<StoryView story={CodeStory} onOpenRef={fn} />` — renders sections in order (read-only).
  - section renderers: `Narrative` (react-markdown), `Diagram` (ascii block / `@xyflow/react` flow / mermaid), `Code` (the extracted tokenizer highlighter + clickable `file:line` via `onOpenRef`), `Diff` (the extracted `diffUtils` parser + split/unified), `Metrics` (churn/hotspot/coverage panel).
  - reuse, do NOT rewrite: lift the tokenizer + color map out of `FileDetailModal.tsx`, `diffUtils.ts`, `diffSymbolExtractor.ts` into the package; drop all annotation/chat/GitHub-sync code paths.
- A thin `loadStory(client, id)` that reads a `CodeStory` from relayfile (`@relayfile/sdk`) — the only I/O, injectable for tests.
- `StoryView.test.tsx` — render a fixture story of each type; assert no network/`api.*` import remains; clicking a `code` ref calls `onOpenRef`.

## Out of scope
- The MSD webapp mount (032), Pear mount (031), the tour (033). Editing/annotations (storybook is read-only). The 3,485-line `FileDetailModal` itself — extract from it, don't move it.

## Acceptance
- `npm test -- StoryView` passes; the package has **zero** dependency on MSD's backend types/API (proven by import graph).
- Renders all five section kinds from a fixture `CodeStory`.

## Review
Reviewer confirms the tokenizer/diff logic is genuinely the extracted MSD code (not a fresh
reimplementation), no `PRInfo`/`api.*`/fetch leaked into the package, it's read-only, and it
renders purely from a `CodeStory` prop. PASS on green tests + a clean import graph.

## Handoff
031 (Pear) and 032 (MSD webapp) both mount `<StoryView>`; 033 adds stepped mode.
