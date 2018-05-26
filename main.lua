

local _G   = getfenv(0)
local uLib = assert(uLib, 'uLib not found')

local aUF = uLib:newaddon('aUF')
_G['aUF'] = aUF


-- UFs
aUF.units = setmetatable({}, {
  __call = function(units) return next, units end
})

do
  local function uf_OnClick(button)
    local self = this  -- magic
    if button == 'LeftButton' then
      if SpellIsTargeting() then
        SpellTargetUnit(self.unit)
      elseif CursorHasItem() then
        if self.unit == 'player' then
          AutoEquipCursorItem()
        else
          DropItemOnUnit(self.unit)
        end
      else
        TargetUnit(self.unit)
      end
    elseif button == 'RightButton' then
      if SpellIsTargeting() then
        StopSpellTargeting()
      else
        -- show menu
      end
    end
  end
  
  function aUF:uf(unit)
    local frame = self.units[unit]
    if frame then return frame end
    
    frame = CreateFrame('Button', 'aUF_' .. unit, UIParent)
    frame:EnableMouse(true)
    frame:RegisterForClicks('AnyDown')
    frame:SetScript('OnClick', uf_OnClick)
    frame:SetScript('OnEnter', UnitFrame_OnEnter)  -- FrameXML/UnitFrame.lua#47
    frame:SetScript('OnLeave', UnitFrame_OnLeave)  -- FrameXML/UnitFrame.lua#79
    frame.unit = unit
    self.units[unit] = frame
    
    if self:iswhackyunit(unit) then self:pollforwhackyunit(unit) end
    
    return frame
  end
end


-- Tag updaes
function aUF:updatetag(tag, unit, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
  for unit, frame in self:units() do
    -- throw to all :connect()'d functions
  end
end


-- Unit logic
aUF.WHACKY_HZ = 10

do
  local holistic_units = { player = true, target = true, pet = true }
  
  for i = 1,(MAX_PARTY_MEMBERS or 4) do
    holistic_units[string.format('party%d', i)] = true
    holistic_units[string.format('party%dpet', i)] = true
  end
  
  for i = 1,(MAX_RAID_MEMBERS or 40) do
    holistic_units[string.format('raid%d', i)] = true
    holistic_units[string.format('raid%dpet', i)] = true
  end
  
  function aUF:iswhackyunit(unit)
    return not holistic_units[unit]
  end
end

local resolution_callbacks = {}

function aUF:onunitresolved(callback)
  self.assertat(2, type(callback) == 'function', 'bad argument #1')
  table.insert(resolution_callbacks, callback)
end

local function resolved(unit)
  for i = 1, #resolution_callbacks do
    local succ, err = pcall(resolution_callbacks[i], unit)
    if not succ then aUF.softerror(err) end
  end
  -- if `unit` has a set in derivative_unit, then scan that set and set up
  -- (exists) or destroy (doesn't exist) polling.
end

aUF:eventreg('PLAYER_TARGET_CHANGED', function() resolved('target') end)
aUF:eventreg('PLAYER_ENTERING_WORLD', function()
  for unit in aUF:units() do
    resolved(unit)
  end
end)
aUF:eventreg('UNIT_PET', function(unit) resolved(unit .. 'pet') end)
aUF:eventreg('RAID_ROSTER_UPDATE', function()
  for i = 1, (MAX_RAID_MEMBERS or 40) do resolved('raid' .. i) end
end)
aUF:eventreg('PARTY_MEMBERS_CHANGED', function()
  for i = 1, (MAX_PARTY_MEMBERS or 4) do resolved('party' .. i) end
end)

aUF:eventreg('UPDATE_MOUSEOVER_UNIT', function()
  -- Mouseover only receives this event, so it's actually whacky
  resolved('mouseover')
end)

aUF:onunitresolved(function(unit)
  local frame = aUF.units[unit]
  if not frame then return end
  if UnitExists(unit) then
    frame:Show()
  else
    frame:Hide()
  end
end)

do
  local whacky_units = {}
  local whacky_status = {}
  local whacky_callbacks = {}
  
  function aUF:pollforwhackyunit(unit)
    whacky_units[unit] = true
  end
  
  function aUF:onwhackypoll(callback)
    self.assertat(2, type(callback) == 'function', 'bad argument #1')
    table.insert(whacky_callbacks, callback)
  end
  
  aUF:timerreg(aUF.WHACKY_HZ, true, function()
    for unit in pairs(whacky_units) do
      local oldstatus = whacky_status[unit]
      local exists = UnitExists(unit)
      if exists ~= oldstatus then
        whacky_status[unit] = exists
        resolved(unit)
      end
      if exists then
        for i = 1,#whacky_callbacks do
          local succ, err = pcall(whacky_callbacks[i], unit)
          if not succ then aUF.softerror(err) end
        end
      end
    end
  end)
end
