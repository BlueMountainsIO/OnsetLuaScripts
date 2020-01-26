--[[
Copyright (C) 2020 Blue Mountains GmbH

This program is free software: you can redistribute it and/or modify it under the terms of the Onset
Open Source License as published by Blue Mountains GmbH.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the Onset Open Source License for more details.

You should have received a copy of the Onset Open Source License along with this program. If not,
see https://bluemountains.io/Onset_OpenSourceSoftware_License.txt
]]--

local StreamedUIs = { }

AddEvent("OnObjectStreamIn", function(object)
	
	local _webUIRemote = GetObjectPropertyValue(object, "_webUIRemote")

	if _webUIRemote ~= nil then
		local x, y, z = GetObjectLocation(object)
		local rx, ry, rz = GetObjectRotation(object)
		local _webUIWidth = GetObjectPropertyValue(object, "_webUIWidth")
		local _webUIHeight = GetObjectPropertyValue(object, "_webUIHeight")
		local _webUIFPS = GetObjectPropertyValue(object, "_webUIFPS")

		StreamedUIs[object] = { }

		local ObjectActor = GetObjectActor(object)

		-- Set the scale to 0 and make it hidden
		ObjectActor:SetActorScale3D(FVector(0.0, 0.0, 0.0))
		ObjectActor:SetActorHiddenInGame(true)

		-- Alos disable its collision
		ObjectActor:SetActorEnableCollision(false)

		-- Create the actual WebUI
		if _webUIRemote == true then
			StreamedUIs[object].webui = CreateRemoteWebUI3D(x, y, z, rx, ry, rz, _webUIWidth, _webUIHeight, _webUIFPS)
		else
			StreamedUIs[object].webui = CreateWebUI3D(x, y, z, rx, ry, rz, _webUIWidth, _webUIHeight, _webUIFPS)
		end

		StreamedUIs[object].is_remote = _webUIRemote

		if StreamedUIs[object].webui == false then
			if IsGameDevMode() then
				AddPlayerChat('<span color="#ff0000bb" style="bold" size="10">You have reached the maximum amount of WebUI3D in this area. Remove some uis or reduce their radius.</>')
			end
		else
			local url = GetObjectPropertyValue(object, "_webUIURL")
			if url ~= nil then
				local res = false
				if StreamedUIs[object].is_remote == true then
					res = SetWebURL(StreamedUIs[object].webui, url)
				else
					res = LoadWebFile(StreamedUIs[object].webui, url)
				end

				--[[if IsGameDevMode() then
					AddPlayerChat("For WebUI "..StreamedUIs[object].webui..", "..tostring(StreamedUIs[object].is_remote)..": Loaded "..url..", res: "..tostring(res))
				end]]--
			end
		end

		--SetWebLocation(StreamedUIs[object].webui, x, y, z + 1.0)

		if IsGameDevMode() then
			AddPlayerChat("STREAMIN: Server WebUI3D "..object)
		end
	end

end)

AddEvent("OnObjectStreamOut", function(object)

	-- When the dummy object is streamed out make sure to destroy the sound
	if StreamedUIs[object] ~= nil then
		DestroyWebUI(StreamedUIs[object].webui)

		if IsGameDevMode() then
			AddPlayerChat("STREAMOUT: Server WebUI3D "..object)
		end

		StreamedUIs[object] = nil
	end

end)

AddEvent("OnObjectNetworkUpdatePropertyValue", function (object, PropertyName, PropertyValue)

	if StreamedUIs[object] == nil then
		return
	end

	if PropertyName == "_webUIURL" then
		if StreamedUIs[object].is_remote == true then
			SetWebURL(StreamedUIs[object].webui, PropertyValue)
		else
			LoadWebFile(StreamedUIs[object].webui, PropertyValue)
		end
	end

end)

AddRemoteEvent("SetStreamedWebUI3DLocation", function (object, x, y, z)
	if StreamedUIs[object] == nil then
		return
	end
	SetWebLocation(StreamedUIs[object].webui, x, y, z)
end)
