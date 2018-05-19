

local _G   = getfenv(0)
local uLib = assert(uLib, 'uLib not found')

local aUF = uLib:newaddon('aUF')
_G['aUF'] = aUF


-- UFs
function aUF:spawnuf(unit)
  
end


-- Tag updaes
function aUF:updatetag(tag, unit, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
  for frame in self:frames(unit) do
    -- throw to all :connect()'d functions
  end
end


-- Unit resolution
-- Functions to be called when a unit has been potentially created, changed, or
-- destroyed.
do
  local rreg = {}
  
  function aUF:onunitresolved(callback)
    table.insert(rreg, callback)
  end
  
  local function resolved(unit)
    for i = 1, #rreg do
      local succ, err = pcall(rreg[i], unit)
      if not succ then aUF.softerror(err) end
    end
  end
  
  uLib:eventreg('PLAYER_TARGET_CHANGED', function() resolved('target') end)
  uLib:eventreg('UPDATE_MOUSEOVER_UNIT', function() resolved('mouseover') end)
  uLib:eventreg('PLAYER_ENTERING_WORLD', function()
    for unit in aUF:units() do
      resolved(unit)
    end
  end)
  uLib:eventreg('UNIT_PET', function(unit) resolved(unit .. 'pet') end)
end

