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

AtmObjectsCached = { }
AtmTable = { }

AddEvent("database:connected", function()
	mariadb_async_query(sql, "SELECT * FROM atm;", OnAtmLoaded)
end)

function OnAtmLoaded()
	for i=1,mariadb_get_row_count() do
		local result = mariadb_get_assoc(i)

		local id = math.tointeger(result["id"])
		local modelid = math.tointeger(result["modelid"])
		local x = tonumber(result["x"])
		local y = tonumber(result["y"])
		local z = tonumber(result["z"])
		local rx = tonumber(result["rx"])
		local ry = tonumber(result["ry"])
		local rz = tonumber(result["rz"])

		CreateAtm(id, modelid, x, y, z, rx, ry, rz)
	end

	print("Loaded "..#AtmTable.." ATMs")
end

AddEvent("OnPlayerLoggedIn", function(player)
	CallRemoteEvent(player, "banking:atmsetup", AtmObjectsCached)
end)

function CreateAtm(id, modelid, x, y, z, rx, ry, rz)
	AtmTable[id] = { }
	AtmTable[id].object = CreateObject(modelid, x, y, z, rx, ry, rz)		
	AtmTable[id].text3d = CreateText3D("ATM\nPress E", 18, x, y, z + 200, 0, 0, 0)

	table.insert(AtmObjectsCached, AtmTable[id].object)
end

AddRemoteEvent("banking:atminteract", function(player, atmobject)
	local atm = GetAtmByObject(atmobject)
	if atm then
		local x, y, z = GetObjectLocation(atm.object)
		local x2, y2, z2 = GetPlayerLocation(player)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 200 then
			webgui.ShowInputBox(player, "Balance: "..FormatMoney(PlayerData[player].bank_balance).."<br><br>Withdraw money", "Withdraw", "OnBankingWithdrawMoney")
		end
	end
end)

function GetAtmByObject(atmobject)
	for _,v in pairs(AtmTable) do
		if v.object == atmobject then
			return v
		end
	end
	return nil
end

AddRemoteEvent("banking:withdraw", function(player, amount)
	if amount == nil then return end

	amount = math.tointeger(amount)

	if amount < CONFIG_ATM_WITHDRAW_MIN or amount > CONFIG_ATM_WITHDRAW_MAX then
		return AddPlayerChat(player, "Invalid withdraw amount")
	end

	if amount > PlayerData[player].bank_balance then
		return AddPlayerChat(player, "Withdraw amount exceeds balance")
	end

	PlayerData[player].bank_balance = PlayerData[player].bank_balance - amount
	AddPlayerCash(player, -amount)

	AddPlayerChat(player, "Amount withdrawn: "..FormatMoney(amount))
	AddPlayerChat(player, "New balance: "..FormatMoney(PlayerData[player].bank_balance))
	AddPlayerChat(player, "Thank you for using this ATM")
end)

function cmd_addatm(player)
	if (PlayerData[player].admin < 5) then
		return AddPlayerChat(player, "Insufficient permission")
	end

	local x, y, z = GetPlayerLocation(player)
	local h = GetPlayerHeading(player)
	local modelid = 494

	local query = mariadb_prepare(sql, "INSERT INTO atm VALUES(NULL, ?, ?, ?, ?, 0.0, ?, 0.0);",
		modelid,
		x, y, z, h)

	mariadb_query(sql, query, OnAtmAdded, player, modelid, x, y, z, h)
end
AddCommand("addatm", cmd_addatm)

function OnAtmAdded(player, modelid, x, y, z, h)
	local id = mariadb_get_insert_id()

	if id ~= false then
		AddPlayerChat(player, "ATM created "..id)

		CreateAtm(id, modelid, x, y, z, 0.0, h, 0.0)

		-- Tell clients
		for _, v in pairs(GetAllPlayers()) do
			CallRemoteEvent(v, "banking:atmsetup", AtmObjectsCached)
		end
	else
		AddPlayerChat(player, "Failed to create ATM")
	end
end
