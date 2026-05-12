--- Reveal.js Cascade - Filter
--- @module cascade
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @description Repeat top-level headings on slides created with horizontal
---   rules (`---`).
---   In reveal.js presentations, a `---` separator creates a new slide without
---   a heading.
---   This filter replaces each `HorizontalRule` with clones of the heading
---   chain from the most recent slide.
---
---   When `---` is followed by a heading, only parent headings above that
---   level are repeated.
---   When followed by non-heading content, the entire heading chain is
---   repeated.
---
---   A `---` nested inside a Div is hoisted to the slide level: the
---   enclosing Div is closed, the heading chain is repeated, and an
---   identical Div is reopened around the content that follows. This works
---   for every Div except `.panel-tabset` and cross-reference targets
---   (a Div whose identifier looks like `tbl-…`, `fig-…`, `thm-…`, …),
---   and for reveal.js output only.
---   The full heading chain is always repeated in this case; the
---   heading-after-`---` shortening only applies at the top level.
---
---   For non-reveal.js formats, behaviour depends on the `keep-hrule` option
---   (default: `true`).
---   When `false`, horizontal rules are removed from the output.
---
---   The filter runs at the `pre-ast` entry point, before Quarto normalises
---   the AST, so every Div is still a plain Div when the filter sees it.
---
---   Headings below the slide level create section wrappers in reveal.js
---   output, so they are skipped when cloning the chain on `---` slides.
---   Accounts for `shift-heading-level-by` (applied after filters run) by
---   combining the metadata value with an AST scan: the metadata shift is
---   authoritative when present, and the AST scan recovers the correct
---   slide level when shift is set under a format-scoped option (e.g.
---   `format.revealjs.shift-heading-level-by`) that is not yet flattened
---   onto `doc.meta` when the filter runs.

--- Read the `keep-hrule` extension option from document metadata.
--- @param meta pandoc.Meta The document metadata.
--- @return boolean Whether to keep horizontal rules in non-reveal.js formats.
local function get_keep_hrule(meta)
  local extensions = meta['extensions']
  if not extensions then
    return false
  end
  local cascade = extensions['cascade']
  if not cascade then
    return false
  end
  local keep = cascade['keep-hrule']
  if keep == nil then
    return false
  end
  return pandoc.utils.stringify(keep) ~= 'false'
end

--- Detect the effective slide level in AST coordinates.
--- `PANDOC_WRITER_OPTIONS.slide_level` is the writer's (post-shift) slide
--- level. The AST still has pre-shift heading levels, so the AST slide
--- level is `slide_level - shift`.
--- The shift is read from metadata when available; otherwise, the AST is
--- scanned for the smallest heading level whose `Header` is directly
--- followed by non-`Header` content (mirrors pandoc's auto slide-level
--- algorithm) and used to escalate the slide level when it indicates a
--- deeper effective level than the metadata path.
--- @param blocks pandoc.Blocks The document blocks.
--- @param meta pandoc.Meta The document metadata.
--- @return integer The slide level in AST coordinates.
local function detect_slide_level(blocks, meta)
  local slide_level = 2
  if PANDOC_WRITER_OPTIONS and PANDOC_WRITER_OPTIONS.slide_level then
    slide_level = PANDOC_WRITER_OPTIONS.slide_level
  end
  local shift_meta = meta['shift-heading-level-by']
  local shift = 0
  if shift_meta then
    shift = tonumber(pandoc.utils.stringify(shift_meta)) or 0
  end
  local ast_slide_level = slide_level - shift
  if shift == 0 then
    local from_ast = nil
    for i, block in ipairs(blocks) do
      if block.t == 'Header' then
        local next_block = blocks[i + 1]
        if next_block and next_block.t ~= 'Header' then
          if not from_ast or block.level < from_ast then
            from_ast = block.level
          end
        end
      end
    end
    if from_ast and from_ast > ast_slide_level then
      ast_slide_level = from_ast
    end
  end
  return ast_slide_level
end

--- Split a list of blocks into pieces wherever a `HorizontalRule` occurs.
--- @param blocks pandoc.List The blocks to split.
--- @return table A list of block lists (one more than the number of rules).
--- @return boolean Whether at least one `HorizontalRule` was found.
local function split_blocks_at_horizontal_rule(blocks)
  local pieces = {}
  local current = {}
  local found = false
  for _, block in ipairs(blocks) do
    if block.t == 'HorizontalRule' then
      found = true
      table.insert(pieces, current)
      current = {}
    else
      table.insert(current, block)
    end
  end
  table.insert(pieces, current)
  return pieces, found
end

--- Hoist `---` out of a Div: when the Div directly contains one or more
--- `HorizontalRule`s, replace it with a sequence of clones of the Div, one
--- per non-empty fragment, separated by `HorizontalRule`s at the slide
--- level. The identifier is cleared on every clone after the first to avoid
--- duplicate IDs. Only applies to reveal.js output; `.panel-tabset` Divs and
--- cross-reference targets (identifier of the form `<type>-<label>`, e.g.
--- `tbl-results`, `fig-plot`, `thm-main`) are left untouched.
--- Parameter and return types are provided by the Quarto Lua plugin.
function Div(div)
  if not quarto.doc.is_format('revealjs') then
    return nil
  end
  if div.classes:includes('panel-tabset') then
    return nil
  end
  if div.identifier ~= '' and div.identifier:match('^%a+%-') then
    return nil
  end
  local pieces, found = split_blocks_at_horizontal_rule(div.content)
  if not found then
    return nil
  end
  local blocks = pandoc.Blocks({})
  for index, piece in ipairs(pieces) do
    local not_first = index > 1
    if not_first then
      blocks:insert(pandoc.HorizontalRule())
    end
    if #piece > 0 then
      local attr = div.attr:clone()
      if not_first then
        attr.identifier = ''
      end
      blocks:insert(pandoc.Div(pandoc.Blocks(piece), attr))
    end
  end
  return blocks
end

--- Process the full document: detect the effective slide level, then
--- replace each `HorizontalRule` with clones of the heading chain
--- from the most recent slide.
--- For non-reveal.js formats, either keep or remove horizontal rules
--- based on the `keep-hrule` option.
--- Parameter and return types are provided by the Quarto Lua plugin.
function Pandoc(doc)
  if not quarto.doc.is_format('revealjs') then
    local keep_hrule = get_keep_hrule(doc.meta)
    if keep_hrule then
      return doc
    end
    doc.blocks = pandoc.Blocks(doc.blocks:filter(function(block)
      return block.t ~= 'HorizontalRule'
    end))
    return doc
  end

  local slide_level = detect_slide_level(doc.blocks, doc.meta)
  local parents = {}
  local chain = {}
  local at_slide_start = false
  local new_blocks = pandoc.Blocks({})

  for i, block in ipairs(doc.blocks) do
    if block.t == 'Header' and block.level < slide_level then
      local new_parents = {}
      for _, p in ipairs(parents) do
        if p.level < block.level then
          table.insert(new_parents, p)
        end
      end
      table.insert(new_parents, block)
      parents = new_parents
      chain = {}
      at_slide_start = false
      new_blocks:insert(block)
    elseif block.t == 'Header' and block.level == slide_level then
      chain = {}
      for _, p in ipairs(parents) do
        table.insert(chain, p)
      end
      table.insert(chain, block)
      at_slide_start = true
      new_blocks:insert(block)
    elseif at_slide_start and block.t == 'Header' then
      table.insert(chain, block)
      new_blocks:insert(block)
    elseif block.t == 'HorizontalRule' and #chain > 0 then
      local next_block = doc.blocks[i + 1]
      local next_is_header = next_block and next_block.t == 'Header'
      local new_chain = {}
      for _, h in ipairs(chain) do
        if h.level >= slide_level and (not next_is_header or h.level < next_block.level) then
          local clone = h:clone()
          clone.identifier = ''
          new_blocks:insert(clone)
          table.insert(new_chain, clone)
        end
      end
      chain = new_chain
      at_slide_start = true
    else
      at_slide_start = false
      new_blocks:insert(block)
    end
  end

  doc.blocks = new_blocks
  return doc
end
