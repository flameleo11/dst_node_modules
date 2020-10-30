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

local mp64 = import("common/mp64")
local FilePipe = import("common/filepipe")

local delimiter = '\n'

------------------------------------------------------------
-- func
------------------------------------------------------------

function obj_set(obj, k, v)
  if not (v == nil) then
    obj[k] = v
  end
end


function do_nothing()
  -- body
end

------------------------------------------------------------
-- class
------------------------------------------------------------

DataNetwork = DataNetwork or Class()

DataNetwork.new = function (this, options)
  local input_path  = options.input_path;
  local output_path = options.output_path;

  this.request_count = 0;
  this.request_fns = {};

  this.cmd_em     = EventEmitter();
  this.request_em = EventEmitter();


  local fp = FilePipe({
    encoder   = mp64.encode,
    decoder   = mp64.decode,
    delimiter = delimiter,
  });
  this.fp = fp

  fp.open(output_path);
  fp.listen(input_path);

  local _this = this;
  fp.on("data", function (data)
    local cmd = data.cmd;
    _this.cmd_em.emit(cmd, data);
  end)


  this.cmd_em.on("[request]", function (data)
    local cmd     = data.cmd;
    local id      = data.id;
    local options = data.options;

    local event = options;
    local params = {}
    if (type(options) == 'table') then
      event  = options.event
      params = options
    end

    if (type(event) == 'string') then
      _this.request_em.emit(event, id, params)
    end
  end)

  this.cmd_em.on("[callback]", function (data)
    local cmd = data.cmd;
    local id  = data.id;
    local res = data.res;
    local err = data.error;

    if (err) then
      print("[error] request remote listen fn :", cmd, err)
      return
    end

    local fn = _this.request_fns[id];
    if (fn) then
      fn(unpack(res))
    end
  end)

end

------------------------------------------------------------
-- methods
------------------------------------------------------------

DataNetwork.listen = function (this, event, fn)
  this.request_em.on(event, function (id, options)
    local res = {}
    local err
xpcall(function ()
  -- todo fill array nil element
    res = { fn(options) };
end, function (err2)
    err = err2
    print("[error] DataNetwork.listen fn execute failed", err2)
end)

    local data = {}
    obj_set(data, "cmd", "[callback]")
    obj_set(data, "id", id)
    obj_set(data, "error", err)
    obj_set(data, "res", res)

    this.fp.send(data);
  end)
end


DataNetwork.off = function (this, event, fn)
  this.request_em.off(event, fn)
end

DataNetwork.remove_event = function (this, event)
  this.request_em.removeAllListeners(event)
end

DataNetwork.request = function (this, options, callback)
  local event = options;
  local params = {}
  if (type(options) == 'table') then
    event  = options.event
    params = options
  end

  if not (type(event) == 'string') then
    t_ls(options)
    error("[error] DataNetwork.request invalid options")
  end


  local id = this.request_count;
  this.request_fns[id] = callback or do_nothing;
  this.request_count = this.request_count + 1;

  local data = {}
  obj_set(data, "cmd", "[request]")
  obj_set(data, "id", id)
  obj_set(data, "options", options)

  this.fp.send(data);
end

DataNetwork.send = function (this, data)
  this.fp.send(data);
end

DataNetwork.on   = DataNetwork._methods.listen;
DataNetwork.emit = DataNetwork._methods.request;
-- DataNetwork.send = DataNetwork._methods.send;

return DataNetwork
