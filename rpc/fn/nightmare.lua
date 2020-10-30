
return (function (cmd, userid, num)

local code = [[

local function addSanity(inst, delta)
    if inst and inst.components
      and inst.components.sanity 
    then
      inst.components.sanity:DoDelta(delta)
    end
end

local p = player
local t = p.components.talker

local userid = %q
local inst = p
if (#userid > 0) then
  inst = UserToPlayer(userid) 
end

if not (inst) then
  t:Say("Who you want me change")
  return
end

local x = math.random()
local nightmare = "crawlingnightmare"
if (x < 0.85) then
  nightmare = "nightmarebeak"
end
local ghost = SpawnAt(nightmare, inst)
ghost.components.combat:SetTarget(target)

]]

  return (code):format(userid)
end)


