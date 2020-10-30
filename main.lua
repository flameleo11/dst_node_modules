
import("db")

local b_server = TheNet:IsDedicated()


local eventmgr = import("events")()
local AddPrefabPostInit = import("events")("AddPrefabPostInit")
local AddPlayerPostInit = import("events")("AddPlayerPostInit")
local AddPrefabPostInitAny = import("events")("AddPrefabPostInitAny")
local AddComponentPostInit = import("events")("AddComponentPostInit")


local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout



-- todo
local AddClassPostConstruct
local AddUserCommand

local logger = import("log");

local DataNetwork = import("common/DataNetwork")


------------------------------------------------------------
-- this
------------------------------------------------------------
this = this or {}

function log(...)
  logger.log(_M._path, ...)
end


log("main.import")


------------------------------------------------------------
-- config
------------------------------------------------------------


-- todo move to net.lua
local delimiter = '\n'
local dst_data_path = "./data/"
local demo_reader_path = "./data/client.in"
local demo_writer_path = "./data/client.out"

function net_toggle(key) 
  local dst_in  = dst_data_path .. key .. ".in"
  local dst_out = dst_data_path .. key .. ".out"

  local dnet = DataNetwork({
    input_path  = dst_in,
    output_path = dst_out,
  })
  print(1, "read",  dst_in)
  print(2, "write", dst_out)

  return dnet;
end


------------------------------------------------------------
-- trigger
------------------------------------------------------------

eventmgr.on('AddComponent', function (name, self, inst)
	eventmgr.emit('AddComponentPostInit', name, self, inst)
	AddComponentPostInit.emit(name, self, inst)
end)

eventmgr.on('SpawnPrefabFromSim', function (inst, prefab)
	eventmgr.emit('AddPrefabPostInit', inst, prefab)
	eventmgr.emit('AddPrefabPostInitAny', inst, prefab)
	AddPrefabPostInit.emit(prefab, inst);
	AddPrefabPostInitAny.emit('', inst);

	if inst and inst:HasTag("player") then
		eventmgr.emit('AddPlayerPostInit', inst, prefab)
		AddPlayerPostInit.emit('', inst);
	end
end)

local regtime= os.time()
AddPrefabPostInit.on('world', function (inst)
  tm.init(inst)
  
	eventmgr.emit('TheWorld', inst, inst.GUID, regtime)
	logger.log(_M._path, "main emit TheWorld end", regtime)

	-- only trigger in client side
  inst:ListenForEvent("playeractivated", _f(function (world, player)
  	eventmgr.emit('playeractivated', player, world)
  	logger.log(_M._path, "playeractivated", player)
  end))
  inst:ListenForEvent("playerdeactivated", _f(function (world, player)
  	eventmgr.emit('playerdeactivated', player, world)
  end))

  -- TheWorld:PushEvent("ms_playerspawn", inst)
  inst:ListenForEvent("ms_playerspawn", _f(function (player)
  	eventmgr.emit('ms_playerspawn', player, inst)
  	logger.log(_M._path, "ms_playerspawn", player)
  end))


  logger.log(_M._path, "AddPrefabPostInit.on->world end")
end)

removeTimer(this.timer_second)
this.timer_second = setInterval(function (elapse_sec)
  eventmgr.emit('timer_second', elapse_sec)
end, 1)


-- todo combine server and client
eventmgr.on('TheWorld', function (inst, guid, regtime)

  if (TheNet:IsDedicated()) then
    return
  end


  setTimeout(function ()
    -- log(999, "client 222", inst.worldprefab)

    this.dnet = net_toggle("client") 



    -- local options = {
    --   event = "test";
    --   data = {1,2,3};
    -- }

    -- this.dnet.request(options, function (...)
    --   print(999, ...)
    -- end)

    -- this.dnet.listen("me_chat", function (data)
    --   local msg = data.msg
    --   TheNet:Say(msg)
    -- end)

    eventmgr.emit('dnet_init', this.dnet)
  end, 0)

  -- removeTimer(this.tm_world_wait2)
  -- this.tm_world_wait2 = setTimeout(function ()  
  --   log(333, "logger.debug()")
  --   logger.debug()
  -- end, 5)
-- import("log").debug()
end)



------------------------------------------------------------
-- file load
------------------------------------------------------------

import("fixmod"); 
if (TheNet:IsDedicated()) then
  -- import("server_mods"); 
  import("server"); 

  
end




log("main.end")



--[[
import("log").debug()
]]