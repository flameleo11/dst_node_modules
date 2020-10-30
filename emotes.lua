------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat
local print = trace;

------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}

local arr_emotes = {
	"facepalm", "joy", "sad", 
	"annoyed", "rude", "carol", 
	"toast", "squat", "sit", 
	"angry", "happy", "bonesaw", 
	"kiss", "pose", "dance", "wave",
}

local klei_emotes = {}
for i, name in ipairs(arr_emotes) do
	klei_emotes[name] = {}
end


------------------------------------------------------------
-- api
------------------------------------------------------------

function send(name)
	if (klei_emotes[name]) then
  	TheNet:SendSlashCmdToServer(name, true) 
	end
end

function random()
	local name = arr_emotes[math.random(#arr_emotes)]
	send(name)
end

return _M
