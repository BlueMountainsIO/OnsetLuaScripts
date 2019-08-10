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

local StreamedAtmIds = { }
local AtmIds = { }

AddRemoteEvent("banking:atmsetup", function(AtmObjects)
	AtmIds = AtmObjects

	-- Reset the table
	StreamedAtmIds = { }

	for _,v in pairs(AtmIds) do
		-- IsValidObject returns true on the client if this object is streamed in
		if IsValidObject(v) then
			table.insert(StreamedAtmIds, v)
		end
	end
end)

AddEvent("OnObjectStreamIn", function(object)
	for _,v in pairs(AtmIds) do
		if object == v then
			table.insert(StreamedAtmIds, v)
			break
		end
	end
end)

AddEvent("OnObjectStreamOut", function(object)
	for _,v in pairs(AtmIds) do
		if object == v then
			table.remove(StreamedAtmIds, tablefind(StreamedAtmIds, v))
			break
		end
	end
end)

local function OnKeyPress(key)
	if key == "E" then
		local NearestATM = GetNearestATM()
		if NearestATM ~= 0 then
			CallRemoteEvent("banking:atminteract", NearestATM)
		end
	end
end
AddEvent("OnKeyPress", OnKeyPress)

function OnBankingWithdrawMoney(value)
	CallRemoteEvent("banking:withdraw", math.tointeger(value))
end
AddEvent("OnBankingWithdrawMoney", OnBankingWithdrawMoney)

function GetNearestATM()
	local x, y, z = GetPlayerLocation()

	for _,v in pairs(StreamedAtmIds) do
		local x2, y2, z2 = GetObjectLocation(v)

		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 160.0 then
			return v
		end
	end

	return 0
end

function tablefind(tab, el)
	for index, value in pairs(tab) do
		if value == el then
			return index
		end
	end
end
