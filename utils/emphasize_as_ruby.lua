if PANDOC_VERSION and PANDOC_VERSION.must_be_at_least then
    PANDOC_VERSION:must_be_at_least("2.17")
else
    error("pandoc version >=2.17 is required")
end

local run=false


-- only runs with Str inline, not compatible with RawInline
-- thus this must be called before convert_ruby

-- only works in html/epub environment
if FORMAT == 'html5' then run=true
elseif FORMAT == 'html4' then  run=true
elseif FORMAT == 'html' then  run=true
elseif FORMAT == 'epub' then  run=true
elseif FORMAT == 'epub3' then run=true
end

if run==false then return {}
end

local split_utf8 do
  local utf8_x  = lpeg.R"\128\191"
  local utf8_1  = lpeg.R"\000\127"
  local utf8_2  = lpeg.R"\194\223" * utf8_x
  local utf8_3  = lpeg.R"\224\239" * utf8_x * utf8_x
  local utf8_4  = lpeg.R"\240\244" * utf8_x * utf8_x * utf8_x
  local utf8    = utf8_1 + utf8_2 + utf8_3 + utf8_4
  local split   = lpeg.Ct (lpeg.C (utf8)^0) * -1

  split_utf8 = function (str)
    str = str and tostring (str)
    if not str then return end
    return lpeg.match (split, str)
  end
end

function emphasis_in_ruby(basestr,stylestr)
  local result = ""
  local splitchars = split_utf8 (basestr)
  for k , v in pairs(splitchars) do
    result = result .. "<ruby><rb>" .. v .. "</rb><rt>" .. stylestr .. "</rt></ruby>"
  end
  return result
end

function ruby_for_dot(spanelem)
  local utils = require 'pandoc.utils'
  local emphasis_char=""
  local classes = spanelem.classes 
  if classes:includes("sesame_dot") then
        emphasis_char="﹅"
  elseif classes:includes("dotted") then
        emphasis_char="•"
  else  --no need to change
    return spanelem    
  end

  local spanstr = pandoc.utils.stringify(spanelem)
  rubied = emphasis_in_ruby(spanstr,emphasis_char)
  return pandoc.RawInline('html', rubied)
end

return {
  { Span = ruby_for_dot }
}