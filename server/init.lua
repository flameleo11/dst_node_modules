------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat

-- import("log").debug()
local logger = import("log");
local common = import("common")
local eventmgr = import("events")()

local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout

require "tprint"


local DataNetwork = import("common/DataNetwork")



------------------------------------------------------------
-- this
------------------------------------------------------------
this = this or {}

function log(...)
  logger.log(_M._path, ...)
end


------------------------------------------------------------
-- config
------------------------------------------------------------

local delimiter = '\n'
local dst_data_path = "./data/"
local demo_reader_path = "./data/server_xxx.in"
local demo_writer_path = "./data/server_xxx.out"

------------------------------------------------------------
-- func
------------------------------------------------------------

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


OnWorldRegen = _f(function ()
	local new_world_flag = 1
  local options = {
    event = "set_new_world_flag";
    data = new_world_flag;
  }
  this.dnet.request(options)
end)

function on_recv_bili_chat_msg(msg)
  TheNet:SystemMessage(msg)
end


------------------------------------------------------------
-- events
------------------------------------------------------------
local count = 0
eventmgr.on('TheWorld', function (inst, guid, regtime)
  -- inst.worldprefab not exsits
  log(111, "init", inst.worldprefab)

  removeTimer(this.tm_world_wait)
  this.tm_world_wait = setTimeout(function ()
    local key = inst.worldprefab and "server_"..inst.worldprefab or "server"
    this.dnet = net_toggle(key) 

    TheWorld:ListenForEvent("ms_worldreset", function ()
    	OnWorldRegen()
    end, TheWorld)

    this.init_world_time = os.time()

    -- TheWorld.worldprefab == "forest"
    -- nodejs only reply master world forest , no response for cave
    this.dnet.request("get_new_world_flag", function (new_world_flag)
log(os.time(), "111..........get_new_world_flag", new_world_flag)      
    	local elpase_time = os.time() - this.init_world_time
log(os.time(), "222..........elpase_time", elpase_time)            
    	if (new_world_flag == 1 and elpase_time < 300) then
    		c_reset() 
log(os.time(), "333..........c_reset", new_world_flag, elpase_time)     
      else 
        import("server/cmd")
log(os.time(), "444..........not reset", new_world_flag, elpase_time)     
    	end
    end)

    this.dnet.remove_event("bili_chat")
    this.dnet.listen("bili_chat", function (data)
      local msg = data.msg
      on_recv_bili_chat_msg(msg)
    end)


  end, 0)

  -- removeTimer(this.tm_world_wait2)
  -- this.tm_world_wait2 = setTimeout(function ()  
  --   log(333, "logger.debug()")
  --   logger.debug()
  -- end, 5)
-- import("log").debug()
end)


log("server.init ok ver 0.9")

return _M
