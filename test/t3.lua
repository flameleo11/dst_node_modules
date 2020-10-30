

function test(i)
  local env = getfenv(i)
  print(i, env, x)
end

test()
for i=0,3 do
	test(i)
end

return test