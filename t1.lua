
function sign(v)
  return (v >= 0 and 1) or -1
end

function round(v, bracket)
  bracket = bracket or 1
  return math.floor(v/bracket + sign(v) * 0.5) * bracket
end
local x = 	-704.11450195312	

print(round(x, 0.01))