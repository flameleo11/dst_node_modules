local easing = require("easing")
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"

local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout

local sformat = import("common").sformat

local DST_ROLES = DST_CHARACTERLIST
local MOD_ROLES = MODCHARACTERLIST
------------------------------------------------------------
-- this
------------------------------------------------------------

local do_nothing = function () end

this = this or {}
this.last_action = this.last_action or do_nothing

this.key_inited = this.key_inited or {}
this.key_down_count = this.key_down_count or {}


this.selected_ents = this.selected_ents or {}
this.color = {x = 1, y = 1, z = 1}

local b_debug = true
local UPDATE_MS_INTERVAL = 1
local DEFAULT_FADE_TIME = 10






------------------------------------------------------------
-- tools
------------------------------------------------------------

function sformat(str, dict)
  str = string.gsub(str, "(%$%b{})", function (str)
    local key = string.sub(str, 3, -2)
    return tostring(dict[key] or str)
  end)
  return str
end

function split_by_space(s)
  local arr = {}
  for w in s:gmatch("%S+") do
    arr[#arr+1] = w
  end
  return arr
end

function shuffle(arr)
  local len = #arr
  for i=1, len-1 do
    local x = math.random(i, len)
    arr[i], arr[x] = arr[x], arr[i]
  end
  return arr
end

function random_color(x)
  local arr = this.arr_color
  if not (arr) then
    arr = {}
    for name, color in pairs(PLAYERCOLOURS) do
      push(arr, color)
    end
    this.arr_color = arr
  end

  local len = #arr
  local x = x or math.random(1, len)
  local t_color = {
    [1] = 0.5843137254902;
    [2] = 0.74901960784314;
    [3] = 0.94901960784314;
    [4] = 1;
  }
  if (t_color) then
    return t_color
  end
  return this.arr_color[x]
end

function sign(v)
  return (v >= 0 and 1) or -1
end

function round(v, bracket)
  bracket = bracket or 1
  return math.floor(v/bracket + sign(v) * 0.5) * bracket
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function enc(data)
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

------------------------------------------------------------
-- show msg
------------------------------------------------------------

function show_msg_api(msg, onlyClear)
  if not (TheFrontEnd and TheFrontEnd.overlayroot) then
    return
  end

  local inst = this.label
  -- if (inst) then
  --   inst:Hide()
  -- end
  if (this.update_msg_task) then
    this.update_msg_task:Cancel()
    this.update_msg_task = nil
  end

  if (b_debug and inst) then
    TheFrontEnd.overlayroot:RemoveChild(inst)
    inst:Hide()
    inst:Kill()
    this.label = nil
  end

  if (onlyClear) then
    return
  end


  if not (this.label) then
    inst = Text(TALKINGFONT, 32)
    inst:Hide()
    -- ANCHOR_BOTTOM ANCHOR_TOP
    -- ANCHOR_LEFT ANCHOR_RIGHT

    -- -- right corner status pos
    inst:SetPosition(-400, 170, 0)
    inst:SetHAnchor(ANCHOR_RIGHT)
    inst:SetVAnchor(ANCHOR_BOTTOM)
    inst:SetHAlign(ANCHOR_LEFT)
    inst:SetVAlign(ANCHOR_TOP)

    -- -- chat input pos
    -- inst:SetPosition(335, 170, 0)
    -- inst:SetHAnchor(ANCHOR_LEFT)
    -- inst:SetVAnchor(ANCHOR_BOTTOM)
    -- inst:SetHAlign(ANCHOR_LEFT)
    -- inst:SetVAlign(ANCHOR_TOP)

    this.label = inst
    TheFrontEnd.overlayroot:AddChild(inst)
  end

  inst:SetString(msg)
  inst:Show()

  local ontimeover = _f(function (inst)
    inst:Hide()
    this.update_msg_task:Cancel()
    this.update_msg_task = nil
  end)

  local fade_time = this.fade_time or DEFAULT_FADE_TIME
  if (fade_time > 0) then
    this.update_msg_task = TheWorld:DoTaskInTime(
      fade_time,
      function()
        ontimeover(inst)
      end,
      0
    )
  end
end

function show_msg(...)
  local arr = {}
  for i,v in ipairs({...}) do
    arr[i] = tostring(v)
  end
  local msg = tjoin(arr, "\n")
  show_msg_api(msg)
  -- print(msg)
end

function std_fade_time(s)
  local n = tonumber(s)
  if not (n) then return end;
  return math.min(math.max(n, -1), 60)
end

------------------------------------------------------------
-- AddUserCommand
------------------------------------------------------------

function AddChatCommand(cmd, fn, options)
  local onCommand = _f(function (params, caller)
    local args = {}
    if (params and params.rest and #params.rest > 0) then
      args = split_by_space(params.rest)
    end
    fn(params, unpack(args))
  end)

  -- todo check whether if cmd already reg
  -- overwrites options
  -- todo params, caller) to cmd & args
  AddUserCommand(cmd, {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = false,
    usermenu = false,
    servermenu = false,
    params = {},
    vote = false,
    localfn = onCommand,
  })
end


function AddChatCommandRepeat(cmd, fn, options)

  local onCommand = _f(function (params, caller)
    local args = {}
    if (params and params.rest and #params.rest > 0) then
      args = split_by_space(params.rest)
    end
    this.last_action = function ()
      fn(params, unpack(args))
    end
    this.last_action();
  end)

  -- todo check whether if cmd already reg
  -- overwrites options
  -- todo params, caller) to cmd & args
  AddUserCommand(cmd, {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = false,
    usermenu = false,
    servermenu = false,
    params = {},
    vote = false,
    localfn = onCommand,
  })

  if (this.last_action == do_nothing) then
    local repeat_fn = _f(function ()
      this.last_action();
    end)

    AddUserCommand("s", {
      prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.PRETTYNAME
      desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.DESC
      permission = COMMAND_PERMISSION.USER,
      slash = false,
      usermenu = false,
      servermenu = false,
      params = {},
      vote = false,
      localfn = repeat_fn,
    })
  end

end



function debug()
  local cache = this.ls_client_cache or {}
  for i, client in ipairs(cache) do
    print(i, client.name, enc(client.name))
  end
end




function on_ls_player(guid)
  local arr_client = TheNet:GetClientTable() or {}
  local cache = {}
  local arr = {}
  for i, client in ipairs(arr_client) do
    cache[i-1] = client;



    local sz_fmt = ("${index}\t${pfx}\t${prefab}\t${name}\t${userid}\t${admin_sfx}\t${friend_sfx} \n")
    local line = sformat(sz_fmt, {
        index      = i-1;
        userid     = client.userid;
        name       = client.name;
        prefab     = client.prefab;
        pfx  = client.admin and "[ # ]" or (client.friend and "[ * ]" or "[    ]");
        admin_pfx  = client.admin and "#" or " ";
        friend_pfx = client.friend and "*" or " ";
        admin_sfx  = client.admin and "admin" or "";
        friend_sfx = client.friend and "friend" or "";
      })

    -- local ln = ("%d %s %s %s %s \n"):format(i-1, client.userid, client.name, 
    --   client.admin and "admin" or "", 
    --   client.friend and "friend" or "")
    push(arr, line)
    -- t_ls(client)

    -- print(i-1, client.userid, client.name, client.admin, client.friend)
  end
  local text = tjoin(arr)
  show_msg(text)

  this.ls_client_cache = cache;
  return cache;
end

-- player_index = i-1
function choose_player_by_index(player_index)
  if not (type(player_index) == "number") then
    return 
  end
  local cache = this.ls_client_cache
  if not (cache) then
    cache = on_ls_player()
  end

  return cache[player_index]
end

function locomotor_go(inst, point)
  local locomotor = inst.components.locomotor
  if (locomotor) then
    locomotor:GoToPoint(point, nil, true)
  end  
end

function go_point(point)
  local inst = ThePlayer
  if not (inst.components.locomotor) then
    local delay = 0.07
    inst:EnableMovementPrediction(true)

    removeTimer(this.tm_enable_prediction_over)
    this.tm_enable_prediction_over = setTimeout(function ()
      locomotor_go(inst, point)
    end, delay)
    return 
  end

  locomotor_go(inst, point)
end

function stop_moving()
  local locomotor = ThePlayer.components.locomotor
  if (locomotor) then
    locomotor:Stop()
  end
  ThePlayer:EnableMovementPrediction(false) 
end

function pause_moving()
  local locomotor = ThePlayer.components.locomotor
  if (locomotor) then
    locomotor:Stop()
  end
end

function find_by_tag(inst, range, callback, musthavetags, canthavetags, musthaveoneoftags)
  local x, y, z = inst.Transform:GetWorldPosition();
  local ents = TheSim:FindEntities(x, y, z, range, musthavetags or {}, canthavetags, musthaveoneoftags)
  for i, v in ipairs(ents) do
    callback(v, i)
  end
end

function enum_ents(callback)
  for k, v in pairs(_G.Ents) do
    callback(v, k)
  end
end

-- test
function RunUserCommand(cmd, rest)
  local UserCommands = require "usercommands"
  UserCommands.RunUserCommand(cmd, { rest = rest }, ThePlayer)
end


function get_player_item(player, item_prefab)
  local invitems = player.replica.inventory:GetItems()
  for k, v in pairs(invitems or {}) do
    if v.prefab == item_prefab then
      return v
    end
  end

  local backpack = player.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
  if not (backpack and backpack.replica.container) then
    return
  end
  local packitems = backpack.replica.container:GetItems() or {}
  for k, v in pairs(packitems) do
    if v.prefab == item_prefab then
      return v
    end
  end
  return
end

function player_enum_items(player, fn)
  fn = fn or function () end
  local frompack = false
  local invitems = player.replica.inventory:GetItems()
  for k, v in pairs(invitems or {}) do
    fn(v, frompack, k)
  end

  local backpack = player.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
  if not (backpack and backpack.replica.container) then
    return
  end
  frompack = true
  local packitems = backpack.replica.container:GetItems() or {}
  for k, v in pairs(packitems) do
    fn(v, frompack, k)
  end
end

-- local UserCommands = require "usercommands";UserCommands.RunUserCommand("ob", { rest = "pigman" }, ThePlayer)

return _M;