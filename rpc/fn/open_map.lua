return (function (cmd, sz_day)
	local code = [[
local m = p and p.userid and p.player_classified and p.player_classified.MapExplorer
local w, h = TheWorld.Map:GetSize()
for x = -w * 2, w * 2, 10 do
    for z = -h * 2, h * 2, 10 do
        if TheWorld.Map:IsValidTileAtPoint(x, 0, z) and m then
            m:RevealArea(x, 0, z)
        end
    end
end


]]
  return "c_save()"
end)
