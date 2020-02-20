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

Reports = {}

function cmd_pm(player, otherplayer, ...)
	local message = table.concat({...}, " ") 

	if (otherplayer == nil or #{...} == 0) then
		return AddPlayerChat(player, "Usage: /pm <player> <message>")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Unknown player")
	end
	
	if (player == otherplayer) then
		return AddPlayerChat(player, "Cannot do this command on yourself")
	end
	
	AddPlayerChat(otherplayer, "***[PM] from Player("..player.."): "..message)
	AddPlayerChat(player, ">>>[PM] to Player("..otherplayer.."): "..message)
end
AddCommand("pm", cmd_pm)

function cmd_s(player)
	local vehicle = GetPlayerVehicle(player)
	local x, y, z, h
	
	if (vehicle ~= 0) then
		x, y, z = GetVehicleLocation(vehicle)
		h = GetVehicleHeading(vehicle)
	else
		x, y, z = GetPlayerLocation(player)
		h = GetPlayerHeading(player)
	end

	PlayerData[player].sX = x
	PlayerData[player].sY = y
	PlayerData[player].sZ = z
	PlayerData[player].sH = h
	AddPlayerChat(player, "Location saved, use /l to load it.")
	AddPlayerChat(player, "XYZ: "..x..", "..y..", "..z..", "..h)
	print("XYZ: "..x..", "..y..", "..z..", "..h)
end
AddCommand("s", cmd_s)
AddCommand("spos", cmd_s)

function cmd_l(player)
	if (PlayerData[player].sX == nil) then
		return AddPlayerChat(player, "You must save your location first! (/s)")
	end
	
	local vehicle = GetPlayerVehicle(player)
	if (vehicle ~= 0) then
		SetVehicleLocation(vehicle, PlayerData[player].sX, PlayerData[player].sY, PlayerData[player].sZ)
		SetVehicleHeading(vehicle, PlayerData[player].sH)
	else
		SetPlayerLocation(player, PlayerData[player].sX, PlayerData[player].sY, PlayerData[player].sZ)
		SetPlayerHeading(player, PlayerData[player].sH)
	end
	
	ResetPlayerCamera(player)
	AddPlayerChat(player, "Location loaded!")
end
AddCommand("l", cmd_l)
AddCommand("lpos", cmd_l)

function cmd_loc(player, x, y, z)
	if (x == nil or y == nil or z == nil) then
		return AddPlayerChat(player, "Usage: /loc <x> <y> <z>")
	end
	
	TeleportTo(player, x, y, z)
	--SetPlayerLocation(player, x, y, z)
	AddPlayerChat(player, "Location set!")
end
AddCommand("loc", cmd_loc)

function cmd_getloc(player)
	local x, y, z = GetPlayerLocation(player)
	local h = GetPlayerHeading(player)

	AddPlayerChat(player, "XYZH: "..x..", "..y..", "..z..", "..h)
end
AddCommand("getloc", cmd_getloc)

function cmd_w(player, weapon, slot, ammo)
	if (weapon == nil or slot == nil or ammo == nil) then
		return AddPlayerChat(player, "Usage: /w <weapon> <slot> <ammo>")
	end

	SetPlayerWeapon(player, weapon, ammo, true, slot)
end
AddCommand("w", cmd_w)
AddCommand("weapon", cmd_w)

function cmd_mywep(player)
	for i=1,4 do
		local weapon, ammo = GetPlayerWeapon(player, i)
		AddPlayerChat(player, "Slot "..i..": "..weapon..", "..ammo)
	end
end
AddCommand("mywep", cmd_mywep)

function cmd_model(player, model)
	if (model == nil) then
		return AddPlayerChat(player, "Usage: /model <model number>")
	end

	model = tonumber(model)

	--[[if (model == nil or model < 1 or model > 26) then
		return AddPlayerChat(player, "Invalid model id")
	end]]--

	SetPlayerPropertyValue(player, "_modelPreset", model)

	AddPlayerChat(player, "Model set (ID: "..model..")")
end
AddCommand("model", cmd_model)

function cmd_v(player, model)
	-- If the player did not pass any command parameter tell them how to use this chat command
	if (model == nil) then
		return AddPlayerChat(player, "Usage: /v <model number>")
	end

	model = tonumber(model)

	-- Check for valid vehicle model.
	--[[if (model == nil or model < 1 or model > 23) then
		return AddPlayerChat(player, "Vehicle model "..model.." does not exist.")
	end]]--

	-- Destroy any old vehicle the player has spawned already.
	if (PlayerData[player].vehicle ~= 0) then
		DestroyVehicle(PlayerData[player].vehicle)
		PlayerData[player].vehicle = 0
	end

	-- Get the current player location, used to spawn the vehicle.
	local x, y, z = GetPlayerLocation(player)
	local h = GetPlayerHeading(player)

	-- Spawn the vehicle. 
	local vehicle = CreateVehicle(model, x, y, z, h)
	if (vehicle == false) then
		return AddPlayerChat(player, "Failed to spawn your vehicle")
	end

	-- Save the vehicle identifier in the global player table
	PlayerData[player].vehicle = vehicle

	-- Do not change color of the taxi or police car
	if (model ~= 2 and model ~= 3) then
		local color = RGB(math.random(1, 220), math.random(1, 220), math.random(1, 220))
		SetVehicleColor(vehicle, NiceColors[ math.random( #NiceColors ) ])
	end

	-- Set the vehicle license plate and attach nitro
	SetVehicleLicensePlate(vehicle, "O N S E T")
	AttachVehicleNitro(vehicle, true)

	-- Never respawn player vehicles if it is left unoccupied
	SetVehicleRespawnParams(vehicle, false)

	if (model == 8) then
		-- Ambulance
		SetVehicleColor(vehicle, RGB(0.0, 60.0, 240.0))
		SetVehicleLicensePlate(vehicle, "EMS-02")
	end

	-- Finally set the player on the vehicles driver seat
	SetPlayerInVehicle(player, vehicle)

	AddPlayerChat(player, "Vehicle spawned! (New ID: "..vehicle..")")
end
AddCommand("v", cmd_v)

function cmd_time(player, player_time)
	if (player_time == nil) then
		return AddPlayerChat(player, "Usage: /time <time 0-24>")
	end
	
	player_time = tonumber(player_time)

	if (player_time == nil or player_time < 0 or player_time > 24) then
		return AddPlayerChat(player, "Parameter \"time\" 0-24")
	end

	CallRemoteEvent(player, "ClientSetTime", player_time)
end
AddCommand("time", cmd_time)

function cmd_fog(player, fog)
	fog = tonumber(fog)

	if (fog == nil) then
		return AddPlayerChat(player, "Usage: /fog <level 0-5 (default: 0.4)>")
	end

	CallRemoteEvent(player, "ClientSetFog", fog)
end
AddCommand("fog", cmd_fog)

function cmd_weather(player, player_weather)
	if (player_weather == nil) then
		return AddPlayerChat(player, "Usage: /weather <1-10>")
	end
	
	player_weather = tonumber(player_weather)

	if (player_weather == nil or player_weather < 0 or player_weather > 10) then
		return AddPlayerChat(player, "Parameter \"weather\" 1-10")
	end

	CallRemoteEvent(player, "ClientSetWeather", player_weather)
end
AddCommand("weather", cmd_weather)

function cmd_avgping(player)
	local AvgPing = 0
	local PlayerCount = GetPlayerCount()
	for _, v in pairs(GetAllPlayers()) do
		AvgPing = AvgPing + GetPlayerPing(v)
	end

	AvgPing = AvgPing / PlayerCount

	AddPlayerChat(player, "Average ping of "..PlayerCount.." players: "..AvgPing)
end
AddCommand("avgping", cmd_avgping)

function cmd_report(player, otherplayer, ...)
	if (GetTimeSeconds() - PlayerData[player].report_cooldown < 30.0) then
		return AddPlayerChat(player, "Slow down reporting")
	end

	local reason = table.concat({...}, " ") 

	if (otherplayer == nil or #{...} == 0) then
		return AddPlayerChat(player, "Usage: /report <player> <reason>")
	end

	if (#reason < 6 or #reason > 80) then
		return AddPlayerChat(player, "Parameter \"reason\" invalid length 6-80")
	end

	otherplayer = tonumber(otherplayer)

	if (not IsValidPlayer(otherplayer)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	if (otherplayer == player) then
		return AddPlayerChat(player, "Cannot report yourself")
	end

	PlayerData[player].report_cooldown = GetTimeSeconds()

	if (#Reports >= 10) then
		table.remove(Reports, 1)
	end

	local ReportStr = "Report ("..GetTimeFormat().."): "..GetPlayerName(player).."("..player..") reports "..GetPlayerName(otherplayer).."("..otherplayer..") for "..reason
	table.insert(Reports, ReportStr)

	AddAdminChat("New report by "..GetPlayerName(player))

	local query = mariadb_prepare(sql, "INSERT INTO log_reports VALUES (?, ?, UNIX_TIMESTAMP(), '?');",
		PlayerData[otherplayer].accountid,
		PlayerData[player].accountid,
		reason)

	mariadb_async_query(sql, query)
end
AddCommand("report", cmd_report)

function cmd_headsize(player, size)
	if (size == nil) then
		return AddPlayerChat(player, "Usage: /headsize <size 0.0-6.0>")
	end

	size = tonumber(size)

	if (size == nil or size < 0.0 or size > 6.0) then
		return AddPlayerChat(player, "Parameter \"size\" 0.0-6.0")
	end

	SetPlayerHeadSize(player, size)
end
AddCommand("headsize", cmd_headsize)

function cmd_color(player)
	SetPlayerRandomColor(player)

	AddPlayerChat(player, 'Your new player color: <span color="'..GetPlayerColorHEX(player)..'">'..GetPlayerName(player)..'('..player..')</>')
end
AddCommand("color", cmd_color)

function cmd_richlist(player)
	local arr = {}
	for _, v in pairs(GetAllPlayers()) do
		table.insert(arr, { PlayerData[v].cash, v })
	end

	table.sort(arr, function(a, b)
		return a[1] > b[1]
	end)

	for k, v in pairs(arr) do
		AddPlayerChat(player, '<span color="'..GetPlayerColorHEX(v[2])..'">$'..v[1]..' '..GetPlayerName(v[2])..'('..v[2]..')</>')
	end
end
AddCommand("richlist", cmd_richlist)

function cmd_toptime(player)
	local arr = {}
	for _, v in pairs(GetAllPlayers()) do
		table.insert(arr, { PlayerData[v].time, v })
	end

	table.sort(arr, function(a, b)
		return a[1] > b[1]
	end)

	for k, v in pairs(arr) do
		AddPlayerChat(player, v[1].."sec "..GetPlayerName(v[2]))
	end
end
AddCommand("toptime", cmd_toptime)

function cmd_stats(player, otherplayer)
	local p = otherplayer or player

	p = tonumber(p)

	if (not IsValidPlayer(p)) then
		return AddPlayerChat(player, "Selected player does not exist")
	end

	webgui.ShowMessageBox(player, "<span style=\"color:"..GetPlayerColorHEX(p)..";\">"..GetPlayerName(p).."("..p..")</span><br><br>\
	Cash: "..GetPlayerCashFormat(p).."<br>\
	Bank: "..FormatMoney(PlayerData[p].bank_balance).."<br>\
	Kills: "..PlayerData[p].kills.."<br>\
	Deaths: "..PlayerData[p].deaths.."<br>\
	K/D: "..GetPlayerKD(p).."<br>\
	Bounty: "..FormatMoney(PlayerData[p].bounty).."<br>\
	Login Count: "..PlayerData[p].count_login.."<br>\
	Kick Count: "..PlayerData[p].count_kick.."<br>\
	Last Login: "..FormatUnixTime(PlayerData[p].last_login_time).."<br>\
	Playing Time: "..FormatPlayTime(GetPlayerTime(p)).."<br>\
	Registration: "..FormatUnixTime(PlayerData[p].registration_time).."<br>\
	<img src=\"http://game/objects/1\">")
end
AddCommand("stats", cmd_stats)

function cmd_para(player)
	AttachPlayerParachute(player, true)
	AddPlayerChat(player, "Have fun with your parachute!")
end
AddCommand("para", cmd_para)

function cmd_drunk(player)
	CallRemoteEvent(player, "ToggleDrunkEffect")
end
AddCommand("drunk", cmd_drunk)

function cmd_vcolor(player, r, g, b)
	if (r == nil or g == nil or b == nil) then
		return AddPlayerChat(player, "Usage: /vcolor <r> <g> <b>")
	end

	local vehicle = GetPlayerVehicle(player)

	if (vehicle == 0) then
		return AddPlayerChat(player, "You must be in a vehicle")
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end

	SetVehicleColor(vehicle, RGB(r, g, b))
	AddPlayerChat(player, "New vehicle color set (HEX: "..GetVehicleColor(vehicle)..")")
end
AddCommand("vcolor", cmd_vcolor)

function cmd_repair(player)
	local vehicle = GetPlayerVehicle(player)

	if (vehicle == 0) then
		return AddPlayerChat(player, "You must be in a vehicle")
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end

	for i=1,8 do
		SetVehicleDamage(vehicle, i, 0.0)
	end

	AddPlayerChat(player, "Vehicle repaired")
end
AddCommand("repair", cmd_repair)

function cmd_vcolorfun(player)
	local vehicle = GetPlayerVehicle(player)

	if (vehicle == 0) then
		return AddPlayerChat(player, "You must be in a vehicle")
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end

	CreateTimer(function(vehicle)
		if not IsValidVehicle(vehicle) then
			return
		end
		local r = Random(100, 255)
		local g = Random(100, 255)
		local b = Random(100, 255)
		SetVehicleColor(vehicle, RGB(r, g, b))
	end, 200, vehicle)
end
AddCommand("vcolorfun", cmd_vcolorfun)

function cmd_hood(player, ratio)
	local vehicle = GetPlayerVehicle(player)

	if (vehicle == 0) then
		return AddPlayerChat(player, "You must be in a vehicle")
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end

	if (ratio == nil) then
		if (GetVehicleHoodRatio(vehicle) > 0.0) then
			SetVehicleHoodRatio(vehicle, 0.0)
		else
			SetVehicleHoodRatio(vehicle, 60.0)
		end
	else
		ratio = tonumber(ratio)

		if (ratio > 90.0) then
			ratio = 90.0
		elseif (ratio < 0.0) then
			ratio = 0.0
		end

		SetVehicleHoodRatio(vehicle, ratio)
	end
end
AddCommand("hood", cmd_hood)

function cmd_trunk(player, ratio)
	local vehicle = GetPlayerVehicle(player)

	if (vehicle == 0) then
		return AddPlayerChat(player, "You must be in a vehicle")
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end

	if (ratio == nil) then
		if (GetVehicleTrunkRatio(vehicle) > 0.0) then
			SetVehicleTrunkRatio(vehicle, 0.0)
		else
			SetVehicleTrunkRatio(vehicle, 60.0)
		end
	else
		ratio = tonumber(ratio)

		if (ratio > 90.0) then
			ratio = 90.0
		elseif (ratio < 0.0) then
			ratio = 0.0
		end

		SetVehicleTrunkRatio(vehicle, ratio)
	end
end
AddCommand("trunk", cmd_trunk)

function cmd_lp(player, ...)

	local message = table.concat({...}, " ") 

	if (#{...} == 0) then
		return AddPlayerChat(player, "Usage: /lp <new license plate text>")
	end

	local vehicle = GetPlayerVehicle(player)
	if (vehicle == 0) then
		return AddPlayerChat(player, '<span color="#ff0000ee">You must be in a vehicle!</>')
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end
	
	SetVehicleLicensePlate(vehicle, message)
end
AddCommand("lp", cmd_lp)

function cmd_anim(player, animname)
	if (animname == nil) then
		return AddPlayerChat(player, "Usage: /anim <name of animation>")
	end

	SetPlayerAnimation(player, animname)
end
AddCommand("anim", cmd_anim)

function cmd_spec(player, disable)
	local _disable = false
	if disable ~= nil then
		_disable = true
	end
	_disable = not _disable
	SetPlayerSpectate(player, _disable)
end
AddCommand("spec", cmd_spec)

function cmd_hat(player, hatobject)
	if (PlayerData[player].hat ~= 0) then
		DestroyObject(PlayerData[player].hat)
		PlayerData[player].hat = 0
	end

	local hatModel = 0

	if hatobject == nil then
		local startHats = 398
		local endHats = 477

		hatModel = Random(startHats, endHats)
	else
		hatModel = math.tointeger(hatobject)
	end

	local x, y, z = GetPlayerLocation(player)
	PlayerData[player].hat = CreateObject(hatModel, x, y, z)

	SetObjectAttached(PlayerData[player].hat, ATTACH_PLAYER, player, 14.0, 0.0, 0.0, 0.0, 90.0, -90.0, "head")
	SetObjectAttached(PlayerData[player].hat, ATTACH_PLAYER, player, 14.0, 0.0, 0.0, 0.0, 90.0, -90.0, "head")

	AddPlayerChat(player, "Attached object model id as hat: "..hatModel)
end
AddCommand("hat", cmd_hat)

function cmd_objtest(player)
	local x, y, z = 64151.0234375, 48423.33984375, 4516.530273

	for c=1,50 do
		for r=1,50 do
			CreateObject(592, x + (c * 350.0), y + (r * 350.0), z)
		end
	end
end
AddCommand("objtest", cmd_objtest)

function cmd_findid(player, ...)
	local args = {...}
	if #args == 0 then
		AddPlayerChat(player, "Your player id is "..player)
		return
	end
	local name = args[1]
	for i=2,#args do
		name = name.." "..args[i]
	end
	local players = GetAllPlayers()
	local matching = 0
	for i=1,#players do
		if GetPlayerName(players[i]):match(name) then
			AddPlayerChat(player, "The player id of \""..GetPlayerName(players[i]).."\" is "..players[i])
			matching=matching+1
		end
	end
	if matching == 0 then
		AddPlayerChat(player, "No player found matching that name!")
	end
end
AddCommand("findid", cmd_findid)
