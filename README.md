# Reveal.js Cascade

A Quarto extension that automatically repeats the heading chain when you use `---` to create new slides in reveal.js presentations.
Follow the DRY (Don't Repeat Yourself) principle: write each heading once and let the filter handle the rest.

## Installation

```bash
quarto add mcanouil/quarto-revealjs-cascade@0.1.1
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

### Non-reveal.js Formats

By default, `---` is removed from non-reveal.js output.
To keep horizontal rules, set `keep-hrule` to `true`:

```yaml
extensions:
  cascade:
    keep-hrule: true
```

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

Rendered output:

- [Reveal.js](https://m.canouil.dev/quarto-revealjs-cascade/).
