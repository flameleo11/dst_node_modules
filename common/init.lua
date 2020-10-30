local push = table.insert
local tjoin = table.concat

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

function strsplit(str, delimiter)
  local pattern = ("[^%s]+"):format(delimiter)
  local arr = {}
  for seg in str:gmatch(pattern) do
    push(arr, seg)
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
function base64_encode(data)
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
function base64_decode(data)
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


return _M