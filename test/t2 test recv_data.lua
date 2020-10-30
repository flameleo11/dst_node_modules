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

local db = import("db")
------------------------------------------------------------
-- config
------------------------------------------------------------

local delimiter = '\n'
local dst_reader_path = "./data/dstserver_reader.dat"
local dst_writer_path = "./data/dstserver_writer.dat"

local dst_data_path = "./data/"

this = this or {}


------------------------------------------------------------
-- func
------------------------------------------------------------


function test(key)

  local fp = FilePipe({
    encoder   = mp64.encode,
    decoder   = mp64.decode,
    delimiter = delimiter,
  });

  local read_path = dst_data_path..key..".in"
  fp.listen(read_path);
  fp.on("data", function (data)
    print(1111, key, "111 [recv]", data)
logger.debug()

  end)

  local write_path = dst_data_path..key..".out"
  -- init for fp.send
  fp.open(write_path);

  -- fp.send(data2)
  this.fp = fp
  return fp
end


function test_send()
  local fp = this.fp

  local data = {"222", "willow", os.time()}
  local data2 = {"111", "wendy", os.time()}
  fp.send(data)
  fp.send(data2)

end

function test2()
  db.send_event("login", "haha")  
  db.send_event("exit", "player2")  
  -- TheWorld.ismastershard
end


eventmgr.on('TheWorld', function (inst, guid, regtime)

  removeTimer(this.tm_world_wait)
  this.tm_world_wait = setTimeout(function ()
    local key = TheWorld.worldprefab and "server_"..TheWorld.worldprefab or "server"
    test(key)
    test_send()
  end, 0)

-- import("log").debug()
end)


------------------------------------------------------------
-- api
------------------------------------------------------------

logger.log(_M._path, "server.init ok", TheWorld)




return _M
