-- gfm-to-latex.lua
-- Bridges GitHub-Flavored Markdown features to LaTeX for PDF generation.
--
-- IMPORTANT: build.sh must use --from gfm-alerts (not --from gfm) so that
-- Pandoc does NOT natively parse GFM alerts. This keeps them as BlockQuotes,
-- allowing this filter to convert them into our custom LaTeX environments.
--
-- Handles:
--   1. GFM admonitions (> [!WARNING], > [!TIP], etc.) → LaTeX mdframed environments
--   2. Images — centered, width-constrained, and height-constrained to fit the page
--   3. Page breaks before level-1 and level-2 headings

-- ---------------------------------------------------------------------------
-- 1. GFM Admonitions → LaTeX callout environments
-- ---------------------------------------------------------------------------
-- Supported types (case-insensitive matching, mapped to lowercase env names):

local admonition_map = {
  WARNING   = "warning",
  NOTE      = "note",
  TIP       = "tip",
  IMPORTANT = "important",
  CAUTION   = "caution",
  SUMMARY   = "summary",
  EXAMPLE   = "example",
}

function BlockQuote(el)
  if #el.content == 0 then return el end

  local first_block = el.content[1]
  if first_block.t ~= "Para" then return el end

  -- Stringify the first paragraph and look for [!TYPE]
  local first_text = pandoc.utils.stringify(first_block)
  local admonition_type = first_text:match("^%[!(%u+)%]")

  if not admonition_type then return el end

  local env_name = admonition_map[admonition_type]
  if not env_name then return el end

  -- Extract optional custom title (any text after [!TYPE] on the marker line)
  local custom_title = first_text:match("^%[!%u+%]%s+(.+)$")

  -- Body content always starts from the second block onward;
  -- the first paragraph is consumed entirely (marker + optional title)
  local new_content = pandoc.List()
  for i = 2, #el.content do
    new_content:insert(el.content[i])
  end

  -- Wrap in LaTeX environment, with optional custom title
  local result = pandoc.List()
  if custom_title and custom_title ~= "" then
    result:insert(pandoc.RawBlock("latex", "\\begin{" .. env_name .. "}[" .. custom_title .. "]"))
  else
    result:insert(pandoc.RawBlock("latex", "\\begin{" .. env_name .. "}"))
  end
  result:extend(new_content)
  result:insert(pandoc.RawBlock("latex", "\\end{" .. env_name .. "}"))

  return result
end

-- ---------------------------------------------------------------------------
-- 2. Images — centered, width- and height-constrained
-- ---------------------------------------------------------------------------
-- Converts percentage widths to \linewidth fractions (LaTeX can't handle
-- bare % in \includegraphics arguments). Also applies a height cap of
-- 0.82\textheight so tall portrait images never overflow the page regardless
-- of the width setting. LaTeX's keepaspectratio will honour whichever
-- constraint is the binding limit.

local function make_includegraphics(src, width_str)
  local pct = width_str:match("^(%d+)%%$")
  local latex_width = pct
    and string.format("%.2f\\linewidth", tonumber(pct) / 100)
    or width_str
  return "\\includegraphics[width=" .. latex_width
    .. ",height=0.82\\textheight,keepaspectratio]{" .. src .. "}"
end

-- Pandoc 3.x: standalone images become Figure blocks
function Figure(el)
  local img = el.content[1]
  if img and img.t == "Plain" then
    local inner = img.content[1]
    if inner and inner.t == "Image" then
      local width = inner.attributes.width or "80%"
      return {
        pandoc.RawBlock("latex", "\\begin{center}"),
        pandoc.RawBlock("latex", make_includegraphics(inner.src, width)),
        pandoc.RawBlock("latex", "\\end{center}"),
      }
    end
  end
end

-- Pandoc 2.x fallback: standalone images in Para blocks
function Para(el)
  if #el.content == 1 and el.content[1].t == "Image" then
    local img = el.content[1]
    local width = img.attributes.width or "80%"
    return {
      pandoc.RawBlock("latex", "\\begin{center}"),
      pandoc.RawBlock("latex", make_includegraphics(img.src, width)),
      pandoc.RawBlock("latex", "\\end{center}"),
    }
  end
end

-- Sets a default width on inline Image nodes so the Figure/Para handlers
-- above always have a value to work with.
function Image(el)
  if not el.attributes.width and not el.attributes.height then
    el.attributes.width = "80%"
  end
  return el
end

-- ---------------------------------------------------------------------------
-- 3. Page breaks before headings
-- ---------------------------------------------------------------------------
-- \newpage before H1 — each major section starts on a fresh page.
-- \clearpage before H2 — each card / subsection starts on a fresh page,
--   preventing blank pages caused by tall portrait images being pushed off
--   the bottom of whatever page the previous card ended on.

function Header(el)
  if el.level == 1 then
    return {
      pandoc.RawBlock("latex", "\\newpage"),
      el,
    }
  end
  return el
end
