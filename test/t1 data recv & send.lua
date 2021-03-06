------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat

-- import("server/db")

local logger = import("log");
local common = import("common")
local eventmgr = import("events")()

local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout

require "tprint"


local mp64 = import("common/mp64")
local FilePipe = import("common/filepipe")
local DataNetwork = import("common/DataNetwork")




local db = import("db")
------------------------------------------------------------
-- config
------------------------------------------------------------

local delimiter = '\n'
local dst_reader_path = "./data/dstserver_reader.dat"
local dst_writer_path = "./data/dstserver_writer.dat"

local dst_data_path = "./data/"

this = this or {}

-- import("log").debug()
function log(...)
  logger.log(_M._path, ...)
end


------------------------------------------------------------
-- events
------------------------------------------------------------
local count = 0
eventmgr.on('TheWorld', function (inst, guid, regtime)

count= count + 1;
log("....world init......", count)
  removeTimer(this.tm_world_wait)
  this.tm_world_wait = setTimeout(function ()
    local key = TheWorld.worldprefab and "server_"..TheWorld.worldprefab or "server"
    init(key)
count= count + 1;    
log("....world start......", count)    
  end, 0)


-- import("log").debug()
end)



------------------------------------------------------------
-- test
------------------------------------------------------------


function init(key)

  local dst_in  = dst_data_path..key..".in"
  local dst_out = dst_data_path..key..".out"

  local node = DataNetwork({
    input_path  = dst_out,
    output_path = dst_in,
  })
  local dstlua = DataNetwork({
    input_path  = dst_in,
    output_path = dst_out,
  })

  dstlua.on("userinfo", function (options)
    local name = "wendy xxx"
    local id = options.id;
    if (id == "me") then
      name = "willow yyy"
    end
    log(333, "get userinfo", name)
    return name
  end)


  node.request("userinfo", function (name)
    log(111000, "send query userinfo", name)
  end)
  log(111, "send query userinfo")

  local options = {
    event = "userinfo",
    id    = "me",
  }
  node.emit(options, function (name)
    log(222000, "emit query userinfo", name)
  end)
  log(222, "emit query userinfo", options)



end

-- eventmgr.on('timer_second', function (elapse_sec)
-- log("test timer. second .........", elapse_sec)
-- print(444, elapse_sec)
-- end)


log("server.init ok", TheWorld)




return _M
