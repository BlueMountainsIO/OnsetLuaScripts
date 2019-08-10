--[[
Copyright (C) 2019 Blue Mountains GmbH

This program is free software: you can redistribute it and/or modify it under the terms of the Onset
Open Source License as published by Blue Mountains GmbH.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the Onset Open Source License for more details.

You should have received a copy of the Onset Open Source License along with this program. If not,
see https://bluemountains.io/Onset_OpenSourceSoftware_License.txt
]]--

AddRemoteEvent("scoreboard:update", function(player)
	local PlayerTable = { }
	
	for _, v in ipairs(GetAllPlayers()) do
		if PlayerData[v] ~= nil then
			PlayerTable[v] = {
				GetPlayerName(v),
				PlayerData[v].kills,
				PlayerData[v].deaths,
				PlayerData[v].bounty,
				GetPlayerPing(v)
			}
		end
	end

	--[[for i=1,20 do
		PlayerTable[i] = {
			"testttt ttest very long name 1291029102910",
			1377,
			802,
			10000,
			21
		}
	end]]--
	
	CallRemoteEvent(player, "scoreboard:update", GetServerName(), GetPlayerCount(), GetMaxPlayers(), PlayerTable)
end)
