# Reveal.js Cascade

A Quarto extension that automatically repeats the heading chain when you use `---` to create new slides in reveal.js presentations.
Follow the DRY (Don't Repeat Yourself) principle: write each heading once and let the filter handle the rest.

## Installation

```bash
quarto add mcanouil/quarto-revealjs-cascade@0.4.1
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

The `.no-cascade` class is set per heading rather than through these options.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

Rendered output:

- [Reveal.js](https://m.canouil.dev/quarto-revealjs-cascade/).
