# Changelog

## Unreleased

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
