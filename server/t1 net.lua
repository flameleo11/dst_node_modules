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
-- config
------------------------------------------------------------

local delimiter = '\n'
local dst_data_path = "./data/"
local demo_reader_path = "./data/server_xxx.in"
local demo_writer_path = "./data/server_xxx.out"


this = this or {}

function log(...)
  logger.log(_M._path, ...)
end

------------------------------------------------------------
-- func
------------------------------------------------------------

function toggle(key) 
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

function init_net(key)
  local dnet = net_toggle(key) 
  this.dnet = dnet;
  return dnet
end

function test(key)
  local dnet = net_toggle(key) 
  local options = {
    event = "test";
    data = {1,2,3};
    name = "sadf"
  }
  log(333, "request", options)
  dnet.request(options, function (res)
    log(444, "return", res)
    print(444, "return", res)
  end)

  dnet.on("test", function (res)
    log(999, "recv test", res)
    t_ls(res)
    print(999, "recv test", res)

    return 1, 2, 3
  end)

  this.dnet = dnet;

end

function t_send(data)
  local dnet = this.dnet
  local options = {
    event = "test";
    data = data;
    time = os.time();
  }
  dnet.request(options, function (res)
    print(555, "return", res)
  end)

end

function send_world_init(data)
  local dnet = this.dnet
  local options = {
    event = "TheWorld";
    data = data;
    time = os.time();
  }
  dnet.request(options, function (res)
    print(111, "return", res)
  end)

end

------------------------------------------------------------
-- events
------------------------------------------------------------
-- local count = 0
-- eventmgr.on('TheWorld', function (inst, guid, regtime)
--   log(111, "init", inst.worldprefab)
--   removeTimer(this.tm_world_wait)
--   this.tm_world_wait = setTimeout(function ()
--     local key = inst.worldprefab and "server_"..inst.worldprefab or "server"
--     init_net(key)

--     log(222, "init", inst.worldprefab)
--   end, 0)

--   removeTimer(this.tm_world_wait2)
--   this.tm_world_wait2 = setTimeout(function ()  
--     log(333, "logger.debug()")
--     logger.debug()
--   end, 5)
-- -- import("log").debug()
-- end)

------------------------------------------------------------
-- test
------------------------------------------------------------

log("net ok")

return _M
