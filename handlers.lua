

local _G   = getfenv(0)
local uLib = assert(uLub, 'uLib not found')
local aUF  = assert(aUF, 'aUF not found')

aUF.h = {}


-- Bar handlers
aUF.h.bar = {}

function aUF.h.bar.value(self, current, total)
  if total == 0 then current = 0 end
  self:SetMinMaxValues(current, total)
  self:SetValue(current)
end

function aUF.h.bar.rgba(self, r, g, b, a)
  self:SetVertexColor(r, g, b, a or 1)
end

function aUF.h.bar.rgb(self, r, g, b)  -- drop alpha
  self:SetVertexColor(r, g, b)
end

function aUF.h.bar.classcolor(self, class)
  local c = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class or 'WARRIOR']
  self:SetVertexColor(c.r, c.g, c.b)
end


-- Text handlers
aUF.h.text = {}

function aUF.h.text.absshort(self, current, total)
  if total == 0 then current = 0 end
  local suf, fmt, val
  if current > 10 ^ 6 then
    suf = 'M'
    fmt = '%.1f'
    val = current / (10 ^ 6)
  elseif current > 10 ^ 5 then
    suf = 'k'
    fmt = '%d'
    val = current / (10 ^ 3)
  elseif current > 10 ^ 3
    suf = 'k'
    fmt = '%.1f'
    val = current / (10 ^ 3)
  else
    suf = ''
    fmt = '%d'
    val = current
  end
  self:SetText(string.format(fmt, val) .. suf)
end

function aUF.h.text.perc(self, current, total)
  if total == 0 then current = 0 end
  self:SetText(string.format('%d', current / total))
end

function aUF.h.text.perc1(self, current, total)
  if total == 0 then current = 0 end
  self:SetText(string.format('%.1f', current / total))
end

function aUF.h.text.rgba(self, r, g, b, a)
  self:SetTextColor(r, g, b, a or 1)
end

function aUF.h.text.rgb(self, r, g, b)
  self:SetTextColor(r, g, b)
end

function aUF.h.text.classcolor(self, class)
  local c = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class or 'WARRIOR']
  self:SetTextColor(c.r, c.g, c.b)
end
