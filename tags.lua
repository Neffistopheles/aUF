

local _G   = getfenv(0)
local uLib = assert(uLub, 'uLib not found')
local aUF  = assert(aUF, 'aUF not found')


-- Health
local function health_update(unit)
  if not aUF:hasunit(unit) then return end
  
  local current = UnitHealth(unit)
  local total   = UnitHealthMax(unit)
  
  aUF:updatetag('health', unit, current, total)
end

uLib:eventreg('UNIT_HEALTH', health_update)
uLib:eventreg('UNIT_MAXHEALTH', health_update)
aUF:onunitresolved(health_update)


-- Power
local function power_update(unit)
  if not aUF:hasunit(unit) then return end
  
  local current = UnitMana(unit)
  local total   = UnitManaMax(unit)
  
  aUF:updatetag('power', unit, current, total)
end

uLib:eventreg('UNIT_DISPLAYPOWER', power_update)
uLib:eventreg('UNIT_ENERGY', power_update)
uLib:eventreg('UNIT_MAXENERGY', power_update)
uLib:eventreg('UNIT_FOCUS', power_update)
uLib:eventreg('UNIT_MAXFOCUS', power_update)
uLib:eventreg('UNIT_MANA', power_update)
uLib:eventreg('UNIT_MAXMANA', power_update)
uLib:eventreg('UNIT_RAGE', power_update)
uLib:eventreg('UNIT_MAXRAGE', power_update)
aUF:onunitresolved(power_update)
