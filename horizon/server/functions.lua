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

webgui = ImportPackage("webgui")

function IsPlayerLoggedIn(player)
	if (not IsValidPlayer(player)) then
		return false
	end

	if (PlayerData[player].accountid == 0) then
		return false
	end

	if (PlayerData[player].logged_in == false) then
		return false
	end

	return true
end

function BanAccount(player, admin, reason)
	local netstats = GetPlayerNetworkStats(player)
	local x, y, z = GetPlayerLocation(player)
	local weapon, ammo = GetPlayerWeapon(player)

	local query = mariadb_prepare(sql, "INSERT INTO bans VALUES (?, ?, UNIX_TIMESTAMP(), 0, '?', ?, ?, ?, ?, ?, ?, ?, ?, ?)",
		PlayerData[player].accountid,
		PlayerData[admin].accountid,
		reason,
		GetPlayerPing(player),
		netstats['packetlossTotal'],
		x,
		y,
		z,
		GetPlayerHealth(player),
		GetPlayerArmor(player),
		weapon,
		ammo)

	mariadb_async_query(sql, query)
end

function BanIP(ip, player, admin, reason)
	reason = reason or ""

	local query = mariadb_prepare(sql, "INSERT INTO ipbans VALUES ('?', ?, ?, UNIX_TIMESTAMP(), '?');",
		ip,
		player,
		admin,
		reason)

	mariadb_async_query(sql, query)
end

function GetUnixTime()
	return os.time(os.date("!*t"))
end

function GetTimeFormat()
	return os.date("%X")
end

function FormatUnixTime(ts)
	return os.date('%Y-%m-%d %H:%M:%S', ts)
end

function FormatPlayTime(seconds)
	local seconds = tonumber(seconds)
  
	if seconds <= 0 then
		return "00:00:00"
	else
		hours = string.format("%02.f", math.floor(seconds / 3600));
		mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
		secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
		return hours..":"..mins..":"..secs
	end
end

function AddAdminChat(message)
	for _, v in pairs(GetAllPlayers()) do
		if (PlayerData[v].admin > 0) then
			AddPlayerChat(v, '<span color="#ff0000">[ADMIN CHAT] '..message..'</>')
		end
	end
end

function AddPlayerCash(player, cash)
	PlayerData[player].cash = PlayerData[player].cash + cash
	CallRemoteEvent(player, "ClientSetCash", FormatMoney(PlayerData[player].cash))
end

function SetPlayerCash(player, cash)
	PlayerData[player].cash = cash
	CallRemoteEvent(player, "ClientSetCash", FormatMoney(PlayerData[player].cash))
end

function GetPlayerCash(player)
	return PlayerData[player].cash
end

function GetPlayerCashFormat(player)
	return FormatMoney(GetPlayerCash(player))
end

function GetPlayerTime(player)
	PlayerData[player].time = math.floor(PlayerData[player].time + (GetTimeSeconds() - PlayerData[player].play_time))
	PlayerData[player].play_time = GetTimeSeconds()
	return PlayerData[player].time
end

function GetPlayerKD(player)
	local deaths = PlayerData[player].deaths
	if deaths == 0 then
		deaths = 1.0
	end

	return string.format("%.2f", PlayerData[player].kills / deaths)
end

function PlayAudioFile(player, file)
	CallRemoteEvent(player, "PlayAudioFile", file)
end

NiceColors = { 0xFF0000, 0xFF0066, 0xEF00FF, 0x8000FF, 0x1100FF, 0x004DFF, 0x00B3FF, 0x00FFD5, 0x00FF77, 0x00FF1A, 0x55FF00, 0xEFFF00, 0xFFBC00, 0xFFA200, 0x915425 }
	
rgb2hex = function (rgb)
	local hexadecimal = '#'

	for key = 1, #rgb do
	    local value = rgb[key] 
		local hex = ''

		while (value > 0) do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end

		if (string.len(hex) == 0) then
			hex = '00'
		elseif (string.len(hex) == 1) then
			hex = '0' .. hex
		end
		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end

function GetPlayerColorHEX(player)
	local r, g, b = HexToRGBA(PlayerData[player].color)

	rgba = {}
	rgba[1] = r
	rgba[2] = g
	rgba[3] = b

	return rgb2hex(rgba)
end

function SetPlayerRandomColor(player)
	PlayerData[player].color = NiceColors[ math.random( #NiceColors ) ]
end

function SetPlayerColor(color)
	PlayerData[player].color = color
end

function GetPlayerColor(player)
	return PlayerData[player].color
end

function FormatMoney(money)
	return format_num(money, 0, "$")
end

function GetNearestVehicle(player)
	local vehicles = GetStreamedVehiclesForPlayer(player)
	local found = 0
	local nearest_dist = 999999.9
	local x, y, z = GetPlayerLocation(player)

	for _,v in pairs(vehicles) do
		local x2, y2, z2 = GetVehicleLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)
		if dist < nearest_dist then
			nearest_dist = dist
			found = v
		end
	end
	return found, nearest_dist
end
