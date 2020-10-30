local push = table.insert
local tjoin = table.concat

local logger = import("log");
local common = import("common")
local strsplit = common.strsplit;

local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout

local Class = import("common/class")
local EventEmitter = import('common/EventEmitter')


function log(...)
  logger.log(_M._path, ...)
end


------------------------------------------------------------
-- func
------------------------------------------------------------


local delimiter = '\n'
local fn = function (...)
  return ...
end

function truncate_file(name)
  local f = io.open(name, "w")
  assert(f, "[error] FilePipe open failed"..name)
  f:close();
end

function open_file(name)
  local f = io.open(name, "r")
  return f
end

-- can not create not exits file by dst lua env
function touch_file(name)
  -- "w+"
  -- All existing data is removed if file exists
  -- or new file is created with read write permissions.
  -- most like descriptor w then r
  truncate_file(name)
  return open_file(name)
end

------------------------------------------------------------
-- class
------------------------------------------------------------

FilePipe = FilePipe or Class()

FilePipe.new = function (this, options)
  this.em = EventEmitter()

  this.encoder   = options.encoder or fn;
  this.decoder   = options.decoder or fn;
  this.delimiter = options.delimiter or delimiter;


  this.send_path   = nil;
  this.send_fs     = nil;
  this.listen_path = nil;
  this.listen_fs   = nil;

  this.em.on("*", function (event, data)
    if not (event == "*") then
      this.em.emit(event, data)  
    end
  end)
end

------------------------------------------------------------
-- methods
------------------------------------------------------------

FilePipe.on = function (this, ...)
  this.em.on(...)
end

FilePipe.connect = function (this, path)
  this.open(path);
end

FilePipe.open = function (this, path)
  this.send_path = path;
  -- also truncate file by open w
  -- truncate_file(name)
  local f = io.open(path, "w")
  assert(f, "[error] FilePipe send_fs open failed")

  this.send_fs = f
end

FilePipe.send = function (this, data)
  local f = this.send_fs
  assert(f, "[error] FilePipe send_fs is nil @send")

  -- todo pack failed send err info
  local str = this.encoder(data);
  f:write(str..this.delimiter)
  f:write("")
  -- [warning] test where cache buffer sometimes
  -- f:flush() -- crash in dst
end

FilePipe.write = function (this, str)
  this.send_fs:write(str)
end

FilePipe._dispatch = function (this, str)
  local arr = strsplit(str, '\n')
  for i, line in ipairs(arr) do
    -- xpcall(function ()
      local data = this.decoder(line)
      this.em.emit("*", "data", data)
    -- end, print)
  end
end

FilePipe.refresh_data = function (this, path)

-- log(">>>>>>>>   refresh_data   >>>>>>>", "444")
  local f = this.listen_fs
  if not f then
    print("[error] FilePipe listen_fs is nil @refresh_data", f)
    return 
  end

  local str = f:read("*a")
-- log(">>>>>>>>   refresh_data   >>>>>>>", "555", str) 
  if (str and #str > 0) then
-- log(">>>>>>>>   refresh_data   >>>>>>>", "666", str) 
    this._dispatch(str)
  end
end

FilePipe.listen = function (this, path)
  this.listen_path = path;

  truncate_file(path)
  this.listen_fs = open_file(path)

-- log(">>>>>>>>   refresh_data   >>>>>>>", "111")
  this.refresh_data()
-- log(">>>>>>>>   refresh_data   >>>>>>>", "222")  
  local period = (FRAMES or 0.03) * 10
  removeTimer(this.tm_update_recv)
  this.tm_update_recv = setInterval(function ()
-- log(">>>>>>>>   refresh_data   >>>>>>>", "333")
    this.refresh_data()
  end, period)
end

return FilePipe