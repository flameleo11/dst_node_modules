-- local x = 0
x = 1

function test()
	print(x)
end

local t = {x=2}
setmetatable(t, {__index = _G})
setfenv(1, t)

print(x, _G.x)
test()