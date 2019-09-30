
function WTF(x, y, z)
	CreateExplosion(9, x, y, z)
	CreateExplosion(2, x + 200.0, y, z)
	CreateExplosion(2, x - 200.0, y, z)
	CreateExplosion(2, x, y + 200.0, z)
	CreateExplosion(2, x, y - 200.0, z)
end

function OnWTF(player, x, y, z)
	local players = GetPlayersInRange3D(x, y, z, 5000.0)
	for _, v in pairs(players) do
		CallRemoteEvent(v, "MakeWTF", x, y, z)
	end

	AddPlayerChat(player, tostring(GetPlayerDimension(player)))

	Delay(2500, function(x, y, z)
		WTF(x, y, z)
	end, x, y, z)

	Delay(4400, function(x, y, z)
		WTF(x, y, z)
	end, x, y, z)
end
AddRemoteEvent("OnWTF", OnWTF)
