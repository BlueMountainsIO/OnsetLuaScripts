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

local EnableESP = 0

function SetEnableESP(enable)
	EnableESP = enable
end
AddRemoteEvent("SetEnableESP", SetEnableESP)

function OnRenderHUD()
	if EnableESP ~= 1 then
		return
	end

	--local lX, lY, lZ = GetCameraLocation()
	local x, y, z
	local ScreenX, ScreenY = GetScreenSize()
	local t = { 1 }
	--local bones = GetPlayerBoneNames()
	for k, v in pairs(GetStreamedPlayers()) do
		local x, y, z = GetPlayerLocation(v)
		local sX, sY, sZ = WorldToScreen(x, y, z)
		if sZ ~= 0.0 then
			--local length = GetDistance3D(x, y, z, lX, lY, lZ)
			
			--DrawPoint3D(x, y, z)
			--DrawRect(sX, sY, 10.0, 40.0)
			DrawLine(ScreenX / 2, ScreenY, sX, sY)
			DrawBox(sX - 50, sY - 100, 100, 200)
			
			--[[for k2, v2 in pairs(bones) do
				local bX, bY, bZ = GetPlayerBoneLocation(v, v2)
				DrawPoint3D(bX, bY, bZ, 3.0)
			end]]--
		end
	end
end
AddEvent("OnRenderHUD", OnRenderHUD)