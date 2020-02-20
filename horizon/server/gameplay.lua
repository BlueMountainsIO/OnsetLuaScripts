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

function OnPlayerDeath(player, instigator)
	PlayerData[player].deaths = PlayerData[player].deaths + 1

	-- If it's not suicide give them money
	if (player ~= instigator) then
		PlayerData[instigator].kills = PlayerData[instigator].kills + 1
		
		local CashAmount = CONFIG_CASH_PER_KILL

		if PlayerData[player].bounty ~= 0 then

			AddPlayerChatAll(GetPlayerName(instigator).." got "..FormatMoney(PlayerData[player].bounty).." bounty for killing "..GetPlayerName(player))

			CashAmount = CashAmount + PlayerData[player].bounty
			PlayerData[player].bounty = 0
		end

		AddPlayerCash(instigator, CashAmount)
	end
end
AddEvent("OnPlayerDeath", OnPlayerDeath)

function OnPlayerDamage(player, damagetype, amount)
	local DamageName = {
		"Weapon",
		"Explosion",
		"Fire",
		"Fall",
		"Vehicle Collision"
	}

	print(GetPlayerName(player).."("..player..") took "..amount.." damage of type "..DamageName[damagetype])
end
AddEvent("OnPlayerDamage", OnPlayerDamage)

function OnPlayerWeaponShot(player, weapon, hittype, hitid, hitx, hity, hitz, startx, starty, startz, normalx, normaly, normalz)
	local action = {
		"in the air",
		"at player",
		"at vehicle",
		"an NPC",
		"at object",
		"on ground",
		"in water"
	}
	
	print(GetPlayerName(player).."("..player..") shot "..action[hittype].." (ID "..hitid..") using weapon ("..weapon..")")
	
	if (hittype == HIT_NPC) then
		AddPlayerChat(player, "Ok, you shot an NPC!")
	end

	if hittype ~= HIT_AIR then
		-- Save this weapon shot in the database

		local hitplayer = 0
		if hittype == HIT_PLAYER then
			hitplayer = PlayerData[hitid].accountid
		end

		local query = mariadb_prepare(sql, "INSERT INTO log_weaponshot VALUES (?, UNIX_TIMESTAMP(), ?, ?, ?, ?, ?, ?, ?, ?, ?);",
			PlayerData[player].accountid,
			hittype,
			hitplayer,
			hitx,
			hity,
			hitz,
			startx,
			starty,
			startz,
			weapon)

		mariadb_async_query(sql, query)
	end
end
AddEvent("OnPlayerWeaponShot", OnPlayerWeaponShot)

function OnVehicleRespawn(vehicle)
	--print("OnVehicleRespawn "..vehicle)
end
AddEvent("OnVehicleRespawn", OnVehicleRespawn)
