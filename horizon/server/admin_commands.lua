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

function cmd_setadmin(player, otherplayer, level)
	if (PlayerData[player].admin < 5) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil or level == nil) then
		return AddPlayerChat(player, "Usage: /setadmin <player> <level>")
	end

	otherplayer = math.tointeger(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (PlayerData[otherplayer].admin > 4) then
		AddPlayerChat(player, "Cannot set admin on high level admin")
		return AddPlayerChat(otherplayer, GetPlayerName(player).." tried to change your admin level to "..level)
	end

	level = math.tointeger(level)

	if (level == nil or level < 0 or level > 5) then
		return AddPlayerChat(player, "Parameter \"level\" invalid length 0-5")
	end

	if (PlayerData[otherplayer].admin == level) then
		return AddPlayerChat(player, "Selected player already is level "..PlayerData[otherplayer].admin)
	end

	PlayerData[otherplayer].admin = level

	AddPlayerChat(otherplayer, "Admin "..GetPlayerName(player).." has set your admin level to "..PlayerData[otherplayer].admin)
	AddPlayerChat(player, "You have made "..GetPlayerName(otherplayer).."("..otherplayer..") admin level "..PlayerData[otherplayer].admin)

	SavePlayerAccount(otherplayer)
end
AddCommand("setadmin", cmd_setadmin)

function cmd_kick(player, otherplayer, ...)
	if (PlayerData[player].admin < 2) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	local reason = table.concat({...}, " ") 
	
	if (otherplayer == nil or #{...} == 0) then
		return AddPlayerChat(player, "Usage: /kick <player> <reason>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (#reason < 5 or #reason > 128) then
		return AddPlayerChat(player, "Parameter \"reason\" invalid length 5-128")
	end
	
	if (PlayerData[otherplayer].admin > 4) then
		AddPlayerChat(player, "Cannot kick high level admin")
		return AddPlayerChat(otherplayer, GetPlayerName(player).." tried to kick you")
	end
	
	local query = mariadb_prepare(sql, "INSERT INTO kicks VALUES (?, ?, UNIX_TIMESTAMP(), '?')",
		PlayerData[otherplayer].accountid,
		PlayerData[player].accountid,
		reason)

	mariadb_async_query(sql, query)

	KickPlayer(otherplayer, "You have been kicked from the server by "..GetPlayerName(player))

	AddPlayerChatAll('Player '..GetPlayerName(otherplayer)..' has been kicked by '..GetPlayerName(player)..'. Reason: '..reason..'')
end
AddCommand("kick", cmd_kick)

function cmd_ban(player, otherplayer, ...)
	if (PlayerData[player].admin < 3) then
		return AddPlayerChat(player, "Insufficient permission")
	end
	
	local reason = table.concat({...}, " ") 

	if (otherplayer == nil or #{...} == 0) then
		return AddPlayerChat(player, "Usage: /ban <player> <reason>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (#reason < 5 or #reason > 128) then
		return AddPlayerChat(player, "Parameter \"reason\" invalid length 5-128")
	end
	
	if (PlayerData[otherplayer].admin > 4) then
		AddPlayerChat(player, "Cannot ban high level admin")
		return AddPlayerChat(otherplayer, GetPlayerName(player).." tried to ban you")
	end

	BanAccount(otherplayer, player, reason)
	BanIP(GetPlayerIP(otherplayer), otherplayer, player)

	KickPlayer(otherplayer, "🚨 You have been banned from the server:\n\nAdmin: "..GetPlayerName(player).."\nReason: "..reason)

	AddPlayerChatAll('Player '..GetPlayerName(otherplayer)..' has been banned by '..GetPlayerName(player)..'. Reason: '..reason..'')
end
AddCommand("ban", cmd_ban)

function cmd_getip(player, otherplayer)
	if (PlayerData[player].admin < 4) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /getip <player>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (PlayerData[otherplayer].admin > 4) then
		AddPlayerChat(player, "Cannot get ip of high level admin")
		return AddPlayerChat(otherplayer, GetPlayerName(player).." tried to get your IP")
	end

	AddPlayerChat(player, "IP: "..GetPlayerIP(otherplayer))
end
AddCommand("getip", cmd_getip)

function cmd_kicklog(player, otherplayer)
	if (PlayerData[player].admin < 1) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	local query = ""

	if (otherplayer == nil) then
		query = "SELECT a1.steam_name, a2.steam_name, FROM_UNIXTIME(kicks.time, '%a %H:%i'), kicks.reason FROM kicks INNER JOIN accounts a1 ON kicks.id = a1.id INNER JOIN accounts a2 ON kicks.admin_id = a2.id ORDER BY kicks.time DESC LIMIT 10;"
	else
		otherplayer = math.tointeger(otherplayer)

		if (not IsValidPlayer(otherplayer)) then
			return AddPlayerChat(player, "Selected player does not exist")
		end

		query = mariadb_prepare(sql, "SELECT a1.steam_name, a2.steam_name, FROM_UNIXTIME(kicks.time, '%a %H:%i'), kicks.reason FROM kicks INNER JOIN accounts a1 ON kicks.id = a1.id INNER JOIN accounts a2 ON kicks.admin_id = a2.id WHERE a1.id = ? ORDER BY kicks.time DESC LIMIT 10;",
			PlayerData[otherplayer].accountid)
	end

	mariadb_async_query(sql, query, OnKickLogLoaded, player)
end
AddCommand("kicklog", cmd_kicklog)

function OnKickLogLoaded(player)
	if mariadb_get_row_count() == 0 then
		return AddPlayerChat(player, "No kicks logged")
	end

	local messages = ""

	for i=1,mariadb_get_row_count() do
		local player_name = mariadb_get_value_index(i, 1)
		local admin_name = mariadb_get_value_index(i, 2)
		local time = mariadb_get_value_index(i, 3)
		local reason = mariadb_get_value_index(i, 4)

		messages = messages.."("..time..") "..admin_name.." kicked "..player_name.." for "..reason.."<br>"
	end

	webgui.ShowMessageBox(player, messages)
end

function cmd_loginlog(player, otherplayer)
	if (otherplayer == nil) then
		otherplayer = player
	else
		if (PlayerData[player].admin < 2) then
			return AddPlayerChat(player, "Insufficient permission")
		end
	end

	otherplayer = math.tointeger(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	local query = mariadb_prepare(sql, "SELECT FROM_UNIXTIME(time), ip FROM log_login WHERE id = ? AND service = 'SERVICE_SERVER' ORDER BY time DESC LIMIT 20;",
		PlayerData[otherplayer].accountid)

	mariadb_async_query(sql, query, OnLoginLogLoaded, player, otherplayer)
end
AddCommand("loginlog", cmd_loginlog)

function OnLoginLogLoaded(player, otherplayer)
	if mariadb_get_row_count() == 0 then
		return AddPlayerChat(player, "No login logs for player "..otherplayer)
	end

	local messages = ""

	for i=1, mariadb_get_row_count() do
		local time = mariadb_get_value_index(i, 1)
		local ip = mariadb_get_value_index(i, 2)

		messages = messages.."("..time..") login "..ip.."<br>"
	end

	webgui.ShowMessageBox(player, messages)
end

function cmd_wslog(player, otherplayer)
	if (PlayerData[player].admin < 2) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /wslog <player>")
	end

	otherplayer = math.tointeger(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	-- Select player weaponshots 
	local query = mariadb_prepare(sql, "SELECT FROM_UNIXTIME(log_weaponshot.time, '%a %H:%i'), log_weaponshot.weapon, accounts.steam_name FROM log_weaponshot INNER JOIN accounts ON log_weaponshot.hitplayer = accounts.id WHERE log_weaponshot.hittype = 2 AND log_weaponshot.id = ? ORDER BY log_weaponshot.time DESC LIMIT 20;",
		PlayerData[otherplayer].accountid)

	mariadb_async_query(sql, query, OnWeaponShotLogLoaded, player, otherplayer)
end
AddCommand("wslog", cmd_wslog)
AddCommand("weaponshotlog", cmd_wslog)
AddCommand("hitlog", cmd_wslog)

function OnWeaponShotLogLoaded(player, otherplayer)
	if mariadb_get_row_count() == 0 then
		return AddPlayerChat(player, "No chat logs for player "..otherplayer)
	end

	local messages = ""

	for i=1, mariadb_get_row_count() do
		local time = mariadb_get_value_index(i, 1)
		local weapon = mariadb_get_value_index_int(i, 2)
		local playername = mariadb_get_value_index(i, 3)

		messages = messages.."("..time..") shot at "..playername.." using weapon id "..weapon.."<br>"
	end

	webgui.ShowMessageBox(player, messages)
end

function cmd_chatlog(player, otherplayer)
	if (PlayerData[player].admin < 2) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /chatlog <player>")
	end

	otherplayer = math.tointeger(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	local query = mariadb_prepare(sql, "SELECT FROM_UNIXTIME(time, '%a %H:%i'), text FROM log_chat WHERE id = ? ORDER BY time DESC LIMIT 10;",
		PlayerData[otherplayer].accountid)

	mariadb_async_query(sql, query, OnChatLogLoaded, player, otherplayer)
end
AddCommand("chatlog", cmd_chatlog)

function OnChatLogLoaded(player, otherplayer)
	if mariadb_get_row_count() == 0 then
		return AddPlayerChat(player, "No chat logs for player "..otherplayer)
	end

	local messages = ""

	for i=1, mariadb_get_row_count() do
		local time = mariadb_get_value_index(i, 1)
		local text = mariadb_get_value_index(i, 2)

		messages = messages.."("..time..") "..text.."<br>"
	end

	webgui.ShowMessageBox(player, messages)
end

function cmd_mute(player, otherplayer, seconds, reason)
	if (PlayerData[player].admin < 1) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil or seconds == nil or reason == nil) then
		return AddPlayerChat(player, "Usage: /mute <player> <seconds> <reason>")
	end

	otherplayer = tonumber(otherplayer)
	seconds = tonumber(seconds)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (seconds < 0 or seconds > 10000) then
		return AddPlayerChat(player, "Parameter \"seconds\" 0-10000")
	end

	if (#reason < 4 or #reason > 128) then
		return AddPlayerChat(player, "Parameter \"reason\" invalid length 4-128")
	end

	if (PlayerData[otherplayer].admin > 3) then
		AddPlayerChat(player, "Cannot mute high level admin")
		return AddPlayerChat(otherplayer, GetPlayerName(player).." tried to mute you")
	end

	PlayerData[otherplayer].mute = GetTimeSeconds() + seconds

	AddPlayerChatAll(GetPlayerName(otherplayer).."("..otherplayer..") has been muted by Admin "..GetPlayerName(player).."("..player..") for "..seconds.." seconds (Reason: "..reason..")")
end
AddCommand("mute", cmd_mute)

function cmd_unmute(player, otherplayer)
	if (PlayerData[player].admin < 1) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /unmute <player>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (PlayerData[otherplayer].mute == 0) then
		return AddPlayerChat(otherplayer, "Selected player is not muted")
	else
		if (CheckForUnmute(otherplayer)) then
			return AddPlayerChat(otherplayer, "Selected player is not muted")
		end
	end

	PlayerData[otherplayer].mute = 0

	AddPlayerChat(otherplayer, "You have been unmuted by an Admin")
	AddPlayerChat(player, "Player has been umuted")
end
AddCommand("unmute", cmd_unmute)

function cmd_get(player, otherplayer)
	if (PlayerData[player].admin < 1) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /get <player>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	local x, y, z = GetPlayerLocation(player)
	SetPlayerLocation(otherplayer, x, y + 50.0, z + 10.0)
	AddPlayerChat(otherplayer, "You have been teleported to "..GetPlayerName(player))
end
AddCommand("get", cmd_get)

function cmd_go(player, otherplayer)
	if (PlayerData[player].admin < 1) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /go <player>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	local x, y, z = GetPlayerLocation(otherplayer)
	SetPlayerLocation(player, x, y, z + 50.0 + 10.0)	
	AddPlayerChat(player, "You have teleported to "..GetPlayerName(player))
end
AddCommand("go", cmd_go)

function cmd_vhealth(player, health)
	if (PlayerData[player].admin < 3) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (health == nil) then
		return AddPlayerChat(player, "Usage: /vhealth <health>")
	end

	health = tonumber(health)

	if (health == nil or health < 0.0 or health > 5000.0) then
		return AddPlayerChat(player, "Parameter \"health\" 0.0-5000.0")
	end

	local vehicle = GetPlayerVehicle(player)

	if (vehicle == 0) then
		return AddPlayerChat(player, "You must be in a vehicle")
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end

	local oldhealth = GetVehicleHealth(vehicle)
	SetVehicleHealth(vehicle, health)
	AddPlayerChat(player, "Old health: "..oldhealth..", new health: "..GetVehicleHealth(vehicle))
end
AddCommand("vhealth", cmd_vhealth)

function cmd_eject(player, otherplayer)
	if (PlayerData[player].admin < 2) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /eject <player>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (GetPlayerVehicle(otherplayer) == 0) then
		return AddPlayerChat(player, "Selected player is not in a vehicle")
	end

	local x, y, z = GetPlayerLocation(otherplayer)
	SetPlayerLocation(otherplayer, x, y, z + 300)

	AddPlayerChat(player, "You have ejected "..GetPlayerName(otherplayer).."("..otherplayer..") from their vehicle")
end
AddCommand("eject", cmd_eject)

function cmd_getin(player, otherplayer)
	if (PlayerData[player].admin < 1) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /getin <player>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	local vehicle = GetPlayerVehicle(otherplayer)
	if (vehicle == 0) then
		return AddPlayerChat(player, "Selected player is not in a vehicle")
	end

	for seat=1, GetVehicleNumberOfSeats(vehicle) do
		local passenger = GetVehiclePassenger(vehicle, seat)
		if (passenger == 0) then
			SetPlayerInVehicle(player, vehicle, seat)
			AddPlayerChat(player, "Warping you into their vehicle on seat "..seat)
			return
		end
	end

	AddPlayerChat(player, "There is not free seat in this players vehicle")
end
AddCommand("getin", cmd_getin)

function cmd_burn(player, otherplayer)
	if (PlayerData[player].admin < 2) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil) then
		return AddPlayerChat(player, "Usage: /burn <player>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	local x, y, z = GetPlayerLocation(otherplayer)
	CreateExplosion(9, x + 200.0, y + 8.0, z + 3.0, true, 1500.0, 1000000.0)

	AddPlayerChat(player, "You have burnt "..GetPlayerName(otherplayer).."("..otherplayer..")")
end
AddCommand("burn", cmd_burn)

function cmd_reports(player)
	if (PlayerData[player].admin < 2) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if #Reports == 0 then
		AddPlayerChat(player, "No reports so far!")
	end

	for _, v in ipairs(Reports) do
		AddPlayerChat(player, v)
	end

	--pprint(Reports)
end
AddCommand("reports", cmd_reports)

function cmd_sethealth(player, otherplayer, health)
	if (PlayerData[player].admin < 3) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil or health == nil) then
		return AddPlayerChat(player, "Usage: /sethealth <player> <health>")
	end

	otherplayer = tonumber(otherplayer)
	health = tonumber(health)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (health > 100000 or health < 0) then
		return AddPlayerChat(player, "Parameter \"health\" 0-100000") 
	end

	SetPlayerHealth(otherplayer, health)

	AddPlayerChat(player, "Player "..GetPlayerName(otherplayer).." health set to "..health)
	AddPlayerChat(otherplayer, "Admin "..GetPlayerName(player).." set your health to "..health)
end
AddCommand("sethealth", cmd_sethealth)

function cmd_healall(player)
	if (PlayerData[player].admin < 4) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	for _, v in pairs(GetAllPlayers()) do
		SetPlayerHealth(v, 100.0)
	end

	AddPlayerChatAll("Admin "..GetPlayerName(player).." has healed all players!")
end
AddCommand("healall", cmd_healall)

function cmd_armorall(player)
	if (PlayerData[player].admin < 4) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	for _, v in pairs(GetAllPlayers()) do
		SetPlayerArmor(v, 100.0)
	end

	AddPlayerChatAll("Admin "..GetPlayerName(player).." has given armor to all players!")
end
AddCommand("armorall", cmd_armorall)

function cmd_cashfall(player, cash)
	if (PlayerData[player].admin < 5) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (cash == nil) then
		return AddPlayerChat(player, "Usage: /cashfall <cash>")
	end

	cash = math.tointeger(cash)

	if (cash == nil or cash < 1 or cash > 10000) then
		return AddPlayerChat(player, "Parameter \"cash\" 1-10000")
	end

	local snoop = Random(0, 1)

	for _, v in pairs(GetAllPlayers()) do
		AddPlayerCash(v, cash)
		if (snoop == 0) then
			PlayAudioFile(v, "cashfallclub.mp3")
			webgui.CreateTextDuration(v, 15, 30, 4500, '<div style="text-align: center;"><div style="color: orange; font-weight: bold;">CASHFALL</div><div style="color: green; font-weight: bold;"> $'..cash..'</div><img height="50%" width="50%" src="http://asset/horizon/client/files/cashfall.gif"></div>')
		else
			PlayAudioFile(v, "cashfall2.mp3")
			webgui.CreateTextDuration(v, 15, 30, 4500, '<div style="text-align: center;"><div style="color: orange; font-weight: bold;">CASHFALL</div><div style="color: green; font-weight: bold;"> $'..cash..'</div><img height="50%" width="50%" src="http://asset/horizon/client/files/snoop.gif"></div>')
		end
	end

	AddPlayerChatAll("Admin "..GetPlayerName(player).." has given all players $"..cash)
end
AddCommand("cashfall", cmd_cashfall)

function cmd_setcash(player, otherplayer, cash)
	if (PlayerData[player].admin < 5) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (otherplayer == nil or cash == nil) then
		return AddPlayerChat(player, "Usage: /setcash <player> <cash>")
	end

	otherplayer = tonumber(otherplayer)
	cash = math.tointeger(cash)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	SetPlayerCash(otherplayer, cash)

	AddPlayerChat(player, "You have set "..GetPlayerName(otherplayer).."'s cash to "..cash)
	AddPlayerChat(otherplayer, "Admin "..GetPlayerName(player).." has set your cash to "..cash)
end
AddCommand("setcash", cmd_setcash)

function cmd_clearchat(player)
	if (PlayerData[player].admin < 4) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	for _, v in pairs(GetAllPlayers()) do
		for i=1,10 do 
			AddPlayerChat(v, " ")
		end
	end
	AddPlayerChatAll("Chat cleared by "..GetPlayerName(player))
end
AddCommand("clearchat", cmd_clearchat)

function cmd_vclean(player)
	if (PlayerData[player].admin < 5) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	for _, v in pairs(GetAllVehicles()) do
		DestroyVehicle(v)
	end
	AddPlayerChatAll("All vehicles destroyed by Admin "..GetPlayerName(player))
end
AddCommand("vclean", cmd_vclean)

function cmd_iplookup(player, ip)
	if (PlayerData[player].admin < 4) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	if (ip == nil) then
		return AddPlayerChat(player, "Usage: /iplookup <ip>")
	end

	if (#ip < 7 or #ip > 15) then
		return AddPlayerChat(player, "Parameter \"ip\" invalid length 7-15")
	end

	local query = mariadb_prepare(sql, "SELECT DISTINCT(id) FROM log_login WHERE ip = '?';",
		ip)

	mariadb_query(sql, query, OnIpLookup, player, ip)
end
AddCommand("iplookup", cmd_iplookup)

function OnIpLookup(player, ip)
	local rows = mariadb_get_row_count()

	if (rows == 0) then
		AddPlayerChat(player, "No account found for that IP")
	else
		for i=1, rows do
			local id = mariadb_get_value_index_int(i, 1)

			AddPlayerChat(player, "Account ID: "..id)
		end
	end
end

function cmd_announce(player, ...)
	if (PlayerData[player].admin < 4) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	local message = table.concat({...}, " ") 

	if (#{...} == 0) then
		return AddPlayerChat(player, "Usage: /announce <message>")
	end

	if (#message < 1 or #message > 128) then
		return AddPlayerChat(player, "Parameter \"message\" invalid length 1-128")
	end

	AddPlayerChatAll('<span color="#ee0000ee" style="bold" size="16">ADMIN: '..message..'</>')
end
AddCommand("announce", cmd_announce)
AddCommand("ann", cmd_announce)

function cmd_esp(player)
	if (PlayerData[player].admin < 3) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	PlayerData[player].esp_enabled = not PlayerData[player].esp_enabled

	local enable = 0
	if (PlayerData[player].esp_enabled) then
		enable = 1
	end
	CallRemoteEvent(player, "SetEnableESP", enable)

	AddPlayerChat(player, "ESP: "..tostring(PlayerData[player].esp_enabled))
end
AddCommand("esp", cmd_esp)

function cmd_mydimension(player)
	if (PlayerData[player].admin < 2) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	AddPlayerChat(player, "Your dimension: "..GetPlayerDimension(player))
end
AddCommand("mydimension", cmd_mydimension)

function cmd_clear(player)
	if (PlayerData[player].admin < 2) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	-- Send empty messages to clear the chat
	for i=1,15 do
		AddPlayerChatAll("")
	end
end
AddCommand("clear", cmd_clear)

--tban, nstats, unban, oban, setcash, setbcash
