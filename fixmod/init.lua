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

local do_nothing = function () end
------------------------------------------------------------
-- events
------------------------------------------------------------
local count = 0
eventmgr.on('TheWorld', function (inst, guid, regtime)

  removeTimer(this.tm_world_wait)
  this.tm_world_wait = setTimeout(function ()

    if (SimpleHealthBar.PushBanner) then
      SimpleHealthBar.PushBanner = do_nothing 
    end
    log(999, SimpleHealthBar.PushBanner, do_nothing)

  end, 0)

end)


log("fixmod init ok ver 0.1")

return _M
