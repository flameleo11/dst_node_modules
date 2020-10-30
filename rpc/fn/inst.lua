return (function (cmd, snippet)

local code = [[
local p = player
local t = p.components.talker
local arr = TheWorld.arr_lookat or {}
local inst = arr[#arr]
local i = inst
local com = inst and inst.components
print("[rpc] inst is ", inst, #arr)
if not (inst) then
  t:Say("Show me a target.")
  return 
end
%s
t:Say("Ready to work.")
]]

	return (code):format(snippet)
end)



