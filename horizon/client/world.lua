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

local SkydiveText = 0
local CashText = 0
local DrunkOn = false
local LastSoundPlayed = 0
local UIVisible = true

function OnPackageStart()
	CashText = CreateTextBox(-15, 180, 'CASH', "right")
	SetTextBoxAnchors(CashText, 1.0, 0.0, 1.0, 0.0)
	SetTextBoxAlignment(CashText, 1.0, 0.0)
end
AddEvent("OnPackageStart", OnPackageStart)

function OnPackageStop()
	DestroyTextBox(CashText)
end
AddEvent("OnPackageStop", OnPackageStop)

function ToggleUI()
	UIVisible = not UIVisible

	ShowHealthHUD(UIVisible)
	ShowWeaponHUD(UIVisible)
	ShowChat(UIVisible)
	webgui.SetVisibility(UIVisible)
end

local bFirstPerson = false

function OnKeyPress(key)
	if key == "Right Ctrl" then
		ToggleUI()
	end

	if key == "P" then
		bFirstPerson = not bFirstPerson
		EnableFirstPersonCamera(bFirstPerson)
	end

	if key == "V" then
		local distance = GetCameraViewDistance()

		distance = distance * 1.1

		if IsPlayerInVehicle() then
			if distance > 1000 then
				distance = 450
			end
		else
			if distance > 450 then
				distance = 250
			end
		end
		SetCameraViewDistance(distance)
	end
end
AddEvent("OnKeyPress", OnKeyPress)

function OnObjectStreamIn(object)
	local _texture = GetObjectPropertyValue(object, "_texture")

	if _texture ~= nil then
		local _textureFile = GetObjectPropertyValue(object, "_textureFile")

		if _texture == "animated" then
			local _textureRowColumns = GetObjectPropertyValue(object, "_textureRowColumns")
			SetObjectAnimatedTexture(object, _textureFile, _textureRowColumns[1], _textureRowColumns[2])
		elseif _texture == "static" then
			SetObjectTexture(object, _textureFile)
		end
	end
end
AddEvent("OnObjectStreamIn", OnObjectStreamIn)

function OnNPCStreamIn(npc)
	local _modelPreset = GetNPCPropertyValue(npc, "_modelPreset")
	if _modelPreset ~= nil then
		SetNPCClothingPreset(npc, _modelPreset)
	end
end
AddEvent("OnNPCStreamIn", OnNPCStreamIn)

function OnPlayerStreamIn(player)
	local _modelPreset = GetPlayerPropertyValue(npc, "_modelPreset")
	if _modelPreset ~= nil then
		SetPlayerClothingPreset(player, _modelPreset)
	end
end
AddEvent("OnPlayerStreamIn", OnPlayerStreamIn)

function OnPlayerNetworkUpdatePropertyValue(player, PropertyName, PropertyValue)
	if PropertyName == "_modelPreset" then
		SetPlayerClothingPreset(player, PropertyValue)
	end
end
AddEvent("OnPlayerNetworkUpdatePropertyValue", OnPlayerNetworkUpdatePropertyValue)

function ClientSetTime(time)
	SetTime(time)
end
AddRemoteEvent("ClientSetTime", ClientSetTime)

function ClientSetFog(level)
	SetFogDensity(level)
end
AddRemoteEvent("ClientSetFog", ClientSetFog)

function ClientSetWeather(weather)
	SetWeather(weather)
end
AddRemoteEvent("ClientSetWeather", ClientSetWeather)

function PlayAudioFile(file)
	DestroySound(LastSoundPlayed)

	LastSoundPlayed = CreateSound("client/files/"..file)
	SetSoundVolume(LastSoundPlayed, 1.1)
end
AddRemoteEvent("PlayAudioFile", PlayAudioFile)

function OnSoundFinished(sound)
	--AddPlayerChat("SoundID("..sound..") finished playing!")
end
AddEvent("OnSoundFinished", OnSoundFinished)

function ClientSetCash(cash)
	SetTextBoxText(CashText, '<span size="22" color="#e8e8e8">'..cash..'</>')
end
AddRemoteEvent("ClientSetCash", ClientSetCash)

function OnClientWebGuiLoaded()
	SkydiveText = webgui.CreateText("<span style=\"color: white;\">SKYDIVE<br></span>", 20, 86, 2)
	webgui.SetTextVisible(SkydiveText, false)
end
AddEvent("OnClientWebGuiLoaded", OnClientWebGuiLoaded)

function OnPlayerSkydive()
	AddPlayerChat("OnPlayerSkydive")

	webgui.SetTextVisible(SkydiveText, true)
end
AddEvent("OnPlayerSkydive", OnPlayerSkydive)

function OnPlayerCancelSkydive()
	AddPlayerChat("OnPlayerCancelSkydive")

	webgui.SetTextVisible(SkydiveText, false)
end
AddEvent("OnPlayerCancelSkydive", OnPlayerCancelSkydive)

function OnPlayerParachuteOpen()
	AddPlayerChat("OnPlayerParachuteOpen")
end
AddEvent("OnPlayerParachuteOpen", OnPlayerParachuteOpen)

function OnPlayerParachuteClose()
	AddPlayerChat("OnPlayerParachuteClose")
end
AddEvent("OnPlayerParachuteClose", OnPlayerParachuteClose)

function OnPlayerParachuteLand()
	AddPlayerChat("OnPlayerParachuteLand")
end
AddEvent("OnPlayerParachuteLand", OnPlayerParachuteLand)

function OnPlayerSkydiveCrash()
	AddPlayerChat("OnPlayerSkydiveCrash")
end
AddEvent("OnPlayerSkydiveCrash", OnPlayerSkydiveCrash)

function ToggleDrunkEffect()
	if (not DrunkOn) then
		DrunkOn = true
		SetPostEffect("ImageEffects", "VignetteIntensity", 1.0)
		SetPostEffect("Chromatic", "Intensity", 5.0)
		SetPostEffect("Chromatic", "StartOffset", 0.1)
		SetPostEffect("MotionBlur", "Amount", 0.05)
		SetPostEffect("MotionWhiteBalanceBlur", "Temp", 7000)
		SetCameraShakeRotation(0.0, 0.0, 1.0, 10.0, 0.0, 0.0)
		SetCameraShakeFOV(5.0, 5.0)
		PlayCameraShake(100000.0, 2.0, 1.0, 1.1)
	else
		DrunkOn = false
		SetPostEffect("ImageEffects", "VignetteIntensity", 0.25)
		SetPostEffect("Chromatic", "Intensity", 0.0)
		SetPostEffect("Chromatic", "StartOffset", 0.0)
		SetPostEffect("MotionBlur", "Amount", 0.0)
		SetPostEffect("MotionWhiteBalanceBlur", "Temp", 6500)
		StopCameraShake(false)
	end
end
AddRemoteEvent("ToggleDrunkEffect", ToggleDrunkEffect)
