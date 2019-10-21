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

pprint = require('packages/'..GetPackageName()..'/server/vendor/pprint')

PlayerData = {}


function OnPlayerServerAuth(player)
	print("OnPlayerServerAuth("..player..")")
end
AddEvent("OnPlayerServerAuth", OnPlayerServerAuth)

function OnPlayerSteamAuth(player)
	print("OnPlayerServerAuth("..player..") has SteamId "..GetPlayerSteamId(player))

	CreatePlayerData(player)

	AddPlayerChatAll('<span color="#eeeeeeaa">'..GetPlayerName(player)..' from '..PlayerData[player].locale..' joined the server</>')
	AddPlayerChatAll('<span color="#eeeeeeaa">There are '..GetPlayerCount()..' players on the server</>')

	-- First check if there is an account for this player
	local query = mariadb_prepare(sql, "SELECT id FROM accounts WHERE steamid = '?' LIMIT 1;",
		tostring(GetPlayerSteamId(player)))

	mariadb_async_query(sql, query, OnAccountLoadId, player)

end
AddEvent("OnPlayerSteamAuth", OnPlayerSteamAuth)


function OnPlayerJoin(player)
	print("OnPlayerJoin("..player..")")

	local x, y, z, h = GetSpawnLocation()
	SetPlayerSpawnLocation(player, x, y, z, h)

	Delay(2000, function(player)
		AddPlayerChat(player, '<span color="#8800eeff" style="bold" size="16">Welcome to Talos\' test server!</>')
		AddPlayerChat(player, '<span color="#8800eeff" size="14">Popular teleports: /gas  /prison  /town</>')
	end, player)
end
AddEvent("OnPlayerJoin", OnPlayerJoin)


function OnPlayerQuit(player)
	SavePlayerAccount(player)

	AddPlayerChatAll(GetPlayerName(player).." left the server.")

	DestroyPlayerData(player)
end
AddEvent("OnPlayerQuit", OnPlayerQuit)


function OnAccountLoadId(player)
	if (mariadb_get_row_count() == 0) then
		--There is no account for this player, continue by checking if their IP was banned		
		CheckForIPBan(player)
	else
		--There is an account for this player, continue by checking if it's banned
		PlayerData[player].accountid = mariadb_get_value_index(1, 1)

		local query = mariadb_prepare(sql, "SELECT FROM_UNIXTIME(bans.ban_time), bans.expire_time, FROM_UNIXTIME(bans.expire_time), bans.reason, accounts.steam_name FROM bans LEFT JOIN accounts ON bans.admin_id = accounts.id WHERE bans.id = ?;",
			PlayerData[player].accountid)

		mariadb_async_query(sql, query, OnAccountCheckBan, player)
	end
end


function OnAccountCheckBan(player)
	if (mariadb_get_row_count() == 0) then
		--No ban found for this account
		CheckForIPBan(player)
	else
		--There is a ban in the database for this account
		local result = mariadb_get_assoc(1)

		local expire_time = result['expire_time']
		
		print("Kicking "..GetPlayerName(player).." because their account was banned")

		if (result['steam_name'] == nil) then
			KickPlayer(player, "🚨 You have been banned from the server:\n\nReason: "..result['reason'].."\nTime: "..result['FROM_UNIXTIME(bans.ban_time)'])
		else
			KickPlayer(player, "🚨 You have been banned from the server:\n\nAdmin: "..result['steam_name'].."\nReason: "..result['reason'].."\nTime: "..result['FROM_UNIXTIME(bans.ban_time)'])
		end
	end
end


function CheckForIPBan(player)
	local query = mariadb_prepare(sql, "SELECT ipbans.reason, accounts.steam_name FROM ipbans LEFT JOIN accounts ON ipbans.admin_id = accounts.id WHERE ipbans.ip = '?' LIMIT 1;",
		GetPlayerIP(player))

	mariadb_async_query(sql, query, OnAccountCheckIpBan, player)
end


function OnAccountCheckIpBan(player)
	if (mariadb_get_row_count() == 0) then
		--No IP ban found for this account
		if (PlayerData[player].accountid == 0) then
			CreatePlayerAccount(player)
		else
			LoadPlayerAccount(player)
		end
	else
		print("Kicking "..GetPlayerName(player).." because their IP was banned")

		local result = mariadb_get_assoc(1)

		if (result['steam_name'] == nil) then
			KickPlayer(player, "🚨 You have been banned from the server.")
		else
			KickPlayer(player, "🚨 You have been banned from the server by "..result['steam_name']..".")
		end
	end
end


function CreatePlayerAccount(player)
	local query = mariadb_prepare(sql, "INSERT INTO accounts (id, steamid, steam_name, game_version, locale, registration_time, registration_ip) VALUES (NULL, '?', '?', ?, '?', UNIX_TIMESTAMP(), '?');",
		tostring(GetPlayerSteamId(player)),
		GetPlayerName(player),
		GetPlayerGameVersion(player),
		GetPlayerLocale(player),
		GetPlayerIP(player))

	mariadb_query(sql, query, OnAccountCreated, player)
end


function OnAccountCreated(player)
	PlayerData[player].accountid = mariadb_get_insert_id()

	SetPlayerLoggedIn(player)

	print("Account ID "..PlayerData[player].accountid.." created for "..player)

	AddPlayerChat(player, '<span color="#ffff00aa" style="bold italic" size="15">SERVER: Welcome to the community, '..GetPlayerName(player)..', have fun and play fair!</>')
	AddPlayerChatAll('<span color="00ee00ff">We now have'..PlayerData[player].accountid..' accounts registered</>')
end


function LoadPlayerAccount(player)
	local query = mariadb_prepare(sql, "SELECT * FROM accounts WHERE id = ?;",
		PlayerData[player].accountid)

	mariadb_async_query(sql, query, OnAccountLoaded, player)
end


function OnAccountLoaded(player)
	if (mariadb_get_row_count() == 0) then
		--This case should not happen but still handle it
		KickPlayer(player, "An error occured while loading your account 😨")
	else
		local result = mariadb_get_assoc(1)

		PlayerData[player].email = result['email']
		PlayerData[player].time = math.tointeger(result['time'])
		PlayerData[player].admin = math.tointeger(result['admin'])
		PlayerData[player].cash = math.tointeger(result['cash'])
		PlayerData[player].bank_balance = math.tointeger(result['bank_balance'])
		PlayerData[player].kills = math.tointeger(result['kills'])
		PlayerData[player].deaths = math.tointeger(result['deaths'])
		PlayerData[player].bounty = math.tointeger(result['bounty'])
		PlayerData[player].registration_time = math.tointeger(result['registration_time'])
		PlayerData[player].registration_ip = result['registration_ip']
		PlayerData[player].count_login = math.tointeger(result['count_login'] + 1)
		PlayerData[player].count_kick = math.tointeger(result['count_kick'])
		PlayerData[player].last_login_time = math.tointeger(result['last_login_time'])

		if CONFIG_SAVE_HEALTH then
			SetPlayerHealth(player, tonumber(result['health']))
			SetPlayerArmor(player, tonumber(result['armor']))
		end

		SetPlayerLoggedIn(player)

		AddPlayerChat(player, '<span color="#ffff00aa" style="bold italic" size="17">SERVER: Welcome back '..GetPlayerName(player)..', have fun!</>')

		print("Account ID "..PlayerData[player].accountid.." loaded for "..GetPlayerIP(player))

		SetPlayerCash(player, PlayerData[player].cash)

		-- Update some values for this player now
		local query = mariadb_prepare(sql, "UPDATE accounts SET count_login = count_login + 1, last_login_time = UNIX_TIMESTAMP(), game_version = ?, locale = '?', steam_name = '?' WHERE id = ?;",
			GetPlayerGameVersion(player),
			GetPlayerLocale(player),
			GetPlayerName(player),
			PlayerData[player].accountid)

		mariadb_async_query(sql, query)

		-- Create new log entry
		query = mariadb_prepare(sql, "INSERT INTO log_login VALUES (?, '?', UNIX_TIMESTAMP(), 'ACTION_LOGIN', 'SERVICE_SERVER');",
			PlayerData[player].accountid,
			GetPlayerIP(player))

		mariadb_async_query(sql, query)
	end
end


function CreatePlayerData(player)
	PlayerData[player] = {}

	--Account stuff
	PlayerData[player].accountid = 0
	PlayerData[player].locale = GetPlayerLocale(player)
	PlayerData[player].email = ""
	PlayerData[player].time = 0
	PlayerData[player].admin = 0
	PlayerData[player].cash = 0
	PlayerData[player].bank_balance = 0
	PlayerData[player].kills = 0
	PlayerData[player].deaths = 0
	PlayerData[player].bounty = 0
	PlayerData[player].registration_time = 0
	PlayerData[player].registration_ip = 0
	PlayerData[player].count_login = 0
	PlayerData[player].count_kick = 0
	PlayerData[player].last_login_time = 0

	--Gameplay stuff
	PlayerData[player].logged_in = false
	PlayerData[player].play_time = GetTimeSeconds()
	PlayerData[player].mute = 0
	PlayerData[player].vehicle = 0
	PlayerData[player].hat = 0
	PlayerData[player].chat_cooldown = 0
	PlayerData[player].cmd_cooldown = 0
	PlayerData[player].report_cooldown = 0
	PlayerData[player].esp_enabled = false
	PlayerData[player].color = RGB(255, 255, 255)
end


function DestroyPlayerData(player)
	if (PlayerData[player] ~= nil) then
		return
	end

	if (PlayerData[player].vehicle ~= 0) then
		DestroyVehicle(PlayerData[player].vehicle)
		PlayerData[player].vehicle = 0
	end

	if (PlayerData[player].hat ~= 0) then
		DestroyObject(PlayerData[player].hat)
		PlayerData[player].hat = 0
	end

	PlayerData[player] = nil
end


function SavePlayerAccount(player)
	if (PlayerData[player] == nil) then
		return
	end

	if (PlayerData[player].accountid == 0 or PlayerData[player].logged_in == false) then
		return
	end

	local query = mariadb_prepare(sql, "UPDATE accounts SET email = '?', time = ?, admin = ?, cash = ?, bank_balance = ?, kills = ?, deaths = ?, bounty = ?, health = ?, armor = ? WHERE id = ? LIMIT 1;",
		PlayerData[player].email,
		GetPlayerTime(player),
		PlayerData[player].admin,
		PlayerData[player].cash,
		PlayerData[player].bank_balance,
		PlayerData[player].kills,
		PlayerData[player].deaths,
		PlayerData[player].bounty,
		GetPlayerHealth(player),
		GetPlayerArmor(player),
		PlayerData[player].accountid)

	mariadb_query(sql, query)
end


function SetPlayerLoggedIn(player)
	PlayerData[player].logged_in = true
	SetPlayerRandomColor(player)

	CallEvent("OnPlayerLoggedIn", player)
end
