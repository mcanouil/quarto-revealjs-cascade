# Reveal.js Cascade

A Quarto extension that automatically repeats the heading chain when you use `---` to create new slides in reveal.js presentations.
Follow the DRY (Don't Repeat Yourself) principle: write each heading once and let the filter handle the rest.

## Installation

```bash
quarto add mcanouil/quarto-revealjs-cascade@1.0.0
```

This will install the extension under the `_extensions` subdirectory.
If you are using version control, you will want to check in this directory.

## Usage

Add the filter to your document or project YAML:

```yaml
filters:
  - cascade
```

Then use `---` as usual to create new slides.
The filter automatically repeats the heading chain from the current slide:

```markdown
## Results

### Experiment A

Observations for experiment A...

---

More observations (headings repeated automatically).

---

### Experiment B

Observations for experiment B (only parent headings repeated).
```

### Opting Out of a Heading

Add the `.no-cascade` class to any heading you do not want repeated on continuation slides.
The heading stays on its own slide but is never carried into the chain for later `---` slides.

```markdown
## Results {.no-cascade}

### Experiment A

Observations for experiment A...

---

Only `### Experiment A` is repeated; `## Results` is not.
```

### Limiting the Cascade Depth

Set `depth` to limit how many heading levels of the chain are repeated on continuation slides, counted from the slide level.
With no value, the full chain is repeated.

```yaml
extensions:
  cascade:
    depth: 1
```

With `depth: 1`, only the slide-level heading is repeated and deeper headings are dropped.

#### Per-heading override

The `cascade-depth` heading attribute overrides the document-level `depth` for the chain that starts at that heading.

```markdown
## Detailed slide {cascade-depth="1"}

### Sub-section

Content...

---

Only `## Detailed slide` is repeated; `### Sub-section` is dropped because the heading sets `cascade-depth="1"`.
```

The override applies to the chain that originates at the annotated heading.
The document-level `depth` (or no limit when unset) resumes when a new chain starts at the next heading at or above slide level.

### Skipped Heading Levels

When the cloned chain skips a heading level (for example a `##` followed by a `####` with no `###` between them), the filter emits a warning at render time.
The output is still produced; the warning surfaces a source structure that is likely accidental.

### Inside Divs

A `---` nested inside a Div splits the slide there too: the enclosing Div is closed, the heading chain is repeated, and an identical Div is reopened around the content that follows.
This works for every Div except `.panel-tabset` and cross-reference targets (a Div whose identifier looks like `#tbl-…`, `#fig-…`, `#thm-…`, ...).

```markdown
## Results

::: {.column-margin}

A side note, first part.

---

Second part, still in the margin, on a new slide.

:::
```

This produces two `## Results` slides, each with the same `.column-margin` Div wrapping one paragraph.

### Horizontal Rules in Code Blocks and Tables

A `---` inside a fenced code block is treated as content by Pandoc; the filter never sees a `HorizontalRule` element for it.
A `---` row in a Markdown pipe table is a column separator; the filter does not split on it.
Both cases pass through unchanged.

### Non-reveal.js Formats

By default, `---` is removed from non-reveal.js output.
To keep horizontal rules, set `keep-hrule` to `true`:

```yaml
extensions:
  cascade:
    keep-hrule: true
```

## Options

Set options under `extensions.cascade` in the document or project YAML.

| Option       | Type    | Default | Description                                                                                                                                           |
| ------------ | ------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `keep-hrule` | boolean | `false` | Whether to keep horizontal rules (`---`) in non-reveal.js formats.                                                                                    |
| `depth`      | number  | unset   | Maximum number of heading levels of the chain to repeat on continuation slides, counted from the slide level. When unset, the full chain is repeated. |

Per-heading attributes (set in the heading attribute block):

| Attribute       | Type   | Description                                                                                                                                |
| --------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `cascade-depth` | number | Overrides the document-level `depth` for the chain that starts at that heading.                                                            |

The `.no-cascade` class is set per heading rather than through these options.

## Behaviour Notes

- Orphaned parent headings (a parent heading with no slide-level heading or content under it before a `---`) can produce visually empty slides.
  Place at least one slide-level heading or block of content between the parent and the rule to avoid this.
- The filter targets reveal.js output for cascade behaviour; non-reveal.js formats only see the `keep-hrule` option.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

Rendered output:

- [Reveal.js](https://m.canouil.dev/quarto-revealjs-cascade/).
