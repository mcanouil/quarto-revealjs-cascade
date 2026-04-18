# Changelog

## Unreleased

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
