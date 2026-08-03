# Changelog

## Unreleased

### New Features

- feat: add the `extensions.cascade.shift` option, declaring the `shift-heading-level-by` applied to the document.
  Quarto treats `shift-heading-level-by` as a Pandoc option, applies it after filters run, and passes it to no filter, wherever it is written; the filter has to be told.
  A value that is not a whole number, or that moves the slide level outside the range 1 to 6, is reported and ignored.

### Bug Fixes

- fix: drop the AST scan that guessed the slide level, which raised it on any slide whose heading was directly followed by a deeper heading.
  The slide heading was then read as a section parent and dropped from the chain, and the `---` produced no continuation slide at all.
  The slide level now comes from the RevealJS `slide-level` and the `shift` option alone, so it no longer depends on the shape of the document.

> [!WARNING]
> A document that sets `shift-heading-level-by`, at the top level or under a format, now has to mirror the value as `extensions.cascade.shift`.
> Without it the chain is read one level off and each `---` produces a duplicate section slide.

## 1.0.2 (2026-08-03)

### Bug Fixes

- fix: repeat a leading heading inside every reopened div when `---` splits it, with its identifier removed.
  A callout whose title is written as a heading kept that title on the first slide only and fell back to the generic name of its type on continuation slides.

## 1.0.1 (2026-08-01)

### Documentation

- docs: Add a documentation website under `docs/`, built on the `atelier` project type and published to <https://m.canouil.dev/quarto-revealjs-cascade/>, including a Reveal.js deck built by the site so every behaviour can be stepped through.
- docs: Trim `README.md` to a landing page pointing at the website, and `example.qmd` to a short starting point to copy.
- docs: Add the Pages workflow, which renders `docs/` on pull requests and deploys it from the release tag.
- docs: Add the Quarto Extensions Updates workflow, scanning `docs` for the website's own dependencies.

## 1.0.0 (2026-05-31)

### New Features

- feat: warn when the cloned heading chain skips a level on a continuation slide (for example, a `##` followed by a `####` with no `###` between them).
  The output is still produced; the warning surfaces a source structure that is likely accidental.
- feat: add the per-heading `cascade-depth` attribute, which overrides the document-level `extensions.cascade.depth` for the chain that starts at that heading.
- feat: reuse the canonical shared `logging.lua` module from `_modules/` for warning output, in line with the other extensions in the monorepo.

### Documentation

- docs: document behaviour of `---` inside code blocks and Markdown tables (passed through unchanged).
- docs: document that orphaned parent headings can produce empty slides and how to avoid them.

## 0.5.0 (2026-05-24)

### New Features

- feat: add the `.no-cascade` heading class to opt a heading out of cascade repetition.
  A heading marked `.no-cascade` stays on its own slide but is never repeated on continuation slides nor carried in the parent chain for subsequent `---` slides.
- feat: add the `extensions.cascade.depth` option to limit how many heading levels of the chain are repeated on continuation slides.
  When set to `N`, only the top `N` levels relative to the slide level are repeated; when unset, the full chain is repeated.

## 0.4.1 (2026-05-14)

### Bug Fixes

- fix: strip `---` nested inside Divs when `keep-hrule: false` for non-reveal.js formats.
  Previously only top-level horizontal rules were removed, so rules inside callouts, `column-margin`, and other Divs leaked into the output.

## 0.4.0 (2026-05-14)

### New Features

- feat: split slides on `---` nested inside a Div (reveal.js only).
  The enclosing Div is closed, the heading chain is repeated, and an identical Div is reopened around the content that follows.
  Works for every Div except `.panel-tabset` and cross-reference targets (a Div whose identifier looks like `tbl-…`, `fig-…`, `thm-…`, …). The filter now runs at the `pre-ast` entry point.

## 0.3.2 (2026-04-27)

### Bug Fixes

- fix: cascade chain on `---` slides when `shift-heading-level-by` is set under a format-scoped option (e.g. `format.revealjs.shift-heading-level-by`).
  Quarto strips format-scoped options from `doc.meta` before user filters run, so the 0.3.1 fix silently fell back to `shift = 0` and incorrectly cloned section-level headings on `---` slides.
  Slide level detection now combines the metadata path with an AST scan that escalates the slide level when the source structure indicates a deeper effective level.

## 0.3.1 (2026-04-18)

### Bug Fixes

- fix: cascade heading chain on `---` slides when the source has no level 1 heading (e.g. starts at `## h2`).
  Previously the filter bumped its internal slide level past the writer's, so the cloned headings never created slide breaks and everything collapsed into a single slide.
  The filter now derives the slide level from `PANDOC_WRITER_OPTIONS.slide_level` and `shift-heading-level-by` directly.

## 0.3.0 (2026-04-09)

### Bug Fixes

- fix: exclude section-level headings (topmost heading level) from cascade repetition on `---` slides.
  Works correctly with `shift-heading-level-by`.

## 0.2.0 (2026-04-08)

### Bug Fixes

- fix: repeat heading chain on `---` slides when no level 1 heading exists in the source.

## 0.1.1 (2026-04-08)

### Chores

- chore: tweak `example.qmd`.

## 0.1.0 (2026-04-08)

### New Features

- feat: Initial release.
