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

local EditorGui = 0
local IsEditMode = false
local SelectedLoc = { }
local SelectedObject = 0
local WasObjectEdited = false
local UserWantsEditMode = EDIT_LOCATION

function OnPackageStart()
	--[[EditorGui = CreateWebUI(-420.0, 16.0, 400.0, 730.0, 1, 40)
	SetWebAlignment(EditorGui, 0.0, 0.0)
	SetWebAnchors(EditorGui, 1.0, 0.0, 1.0, 0.0) --anchor top right corner]]--
	EditorGui = CreateWebUI(0.0, 0.0, 410.0, 0.0, 1, 60)
	SetWebAlignment(EditorGui, 1.0, 0.0)
	SetWebAnchors(EditorGui, 1.0, 0.0, 1.0, 1.0) -- anchor left top corner to left bottom corner
	LoadWebFile(EditorGui, "http://asset/"..GetPackageName().."/client/gui/editor.html")

	SelectedLoc.x = 0.0
	SelectedLoc.y = 0.0
	SelectedLoc.z = 0.0
	SelectedLoc.distance = 0.0
	SelectedLoc.isValid = false

	ShowHealthHUD(false)
	ShowWeaponHUD(false)

	SetObjectEditorSpeed(9.0)
end
AddEvent("OnPackageStart", OnPackageStart)

function OnPackageStop()
	DestroyWebUI(EditorGui)
end
AddEvent("OnPackageStop", OnPackageStop)

function OnWebLoadComplete(webid)
	if (EditorGui == webid) then
		local num_objects = GetObjectModelCount()
		--Delay this a little to make sure jquery wont fail on non ready document
		Delay(1000, function(webid, num_objects)
			ExecuteWebJS(webid, "BuildSelectableObjects("..num_objects..");")
		end, EditorGui, num_objects)
	end
end
AddEvent("OnWebLoadComplete", OnWebLoadComplete)

function OnKeyPress(key)
	--AddPlayerChat(key)

	if key == "Z" then
		if IsCtrlPressed() then
			AddPlayerChat("Undo action")
		end
	end
	
	if key == "Y" then
		if IsCtrlPressed() then
			AddPlayerChat("Redo action")
		end
	end

	if key == "W" then
		if IsCtrlPressed() then
			if SelectedObject ~= 0 then
				DuplicateEditorObject(SelectedObject)
			end
		end
	end

	if key == "M" then
		ToggleEditor()
	end

	if key == "Left Mouse Button" then
		if IsEditMode then
			local x, y, z, distance = GetMouseHitLocation()
			--AddPlayerChat("Hit: "..x..", "..y..", "..z..", "..distance)

			-- if selected location is not valid (i.e. clicking sky) 0.0 is returned. we set it to something high so the check is triggered later on.
			if distance == 0.0 then
				distance = 999999.9
			end

			SelectedLoc.x = x
			SelectedLoc.y = y
			SelectedLoc.z = z
			SelectedLoc.distance = distance
			SelectedLoc.isValid = true

			local EntityType, EntityId = GetMouseHitEntity()
			if (EntityType == HIT_OBJECT) then
				if (EntityId ~= 0 and SelectedObject ~= EntityId) then
					SelectEditorObject(EntityId)
				end
			end
		end
	end

	if key == "Delete" then
		DeleteSelectedEditorObject()
	end

	if key == "Left Alt" then
		if IsEditMode then
			if SelectedObject ~= 0 then
				if UserWantsEditMode == EDIT_LOCATION then
					UserWantsEditMode = EDIT_ROTATION
				elseif UserWantsEditMode == EDIT_ROTATION then
					UserWantsEditMode = EDIT_SCALE
				elseif UserWantsEditMode == EDIT_SCALE then
					UserWantsEditMode = EDIT_LOCATION
				end
				SetObjectEditable(SelectedObject, UserWantsEditMode)
			end
		end
	end
end
AddEvent("OnKeyPress", OnKeyPress)

function ToggleEditor()
	if not IsEditMode then
		ShowMouseCursor(true)
		SetInputMode(INPUT_GAMEANDUI)
	else
		ShowMouseCursor(false)
		SetInputMode(INPUT_GAME)
		SelectEditorObject(0)
	end
	IsEditMode = not IsEditMode
end

function DisableEditor()
	if IsEditMode then
		ToggleEditor()
	end
end

function SelectEditorObject(object)
	if (SelectedObject ~= 0) then
		SetObjectOutline(SelectedObject, false)
		SetObjectEditable(SelectedObject, EDIT_NONE)

		if WasObjectEdited then
			UpdateObjectToServer(SelectedObject)
		end

		SelectedObject = 0
	end
	AddPlayerChat("SelectEditorObject: "..object)
	if IsValidObject(object) then
		AddPlayerChat("SelectEditorObject2: "..object)
		WasObjectEdited = false
		SetObjectEditable(object, UserWantsEditMode)
		SetObjectOutline(object, true)
		SelectedObject = object

		local x, y, z = GetObjectLocation(object)
		local rx, ry, rz = GetObjectRotation(object)

		ExecuteWebJS(EditorGui, "SetObjectInfo("..x..", "..y..", "..z..", "..rx..", "..ry..", "..rz..");")
	end
end

function OnPlayerBeginEditObject(object)
	AddPlayerChat("Now editing object")

	if object == SelectedObject then
		WasObjectEdited = true
	end
end
AddEvent("OnPlayerBeginEditObject", OnPlayerBeginEditObject)

function OnPlayerEndEditObject(object)
	AddPlayerChat("End editing.")
end
AddEvent("OnPlayerEndEditObject", OnPlayerEndEditObject)

function UpdateObjectToServer(object)
	if IsValidObject(object) then
		local x, y, z = GetObjectLocation(object)
		local rx, ry, rz = GetObjectRotation(object)

		CallRemoteEvent("Server_EditorUpdateObject", object, x, y, z, rx, ry, rz)
	end
end

function DeleteSelectedEditorObject()
	if (SelectedObject ~= 0) then
		CallRemoteEvent("Server_EditorDeleteObject", SelectedObject)

		-- Make sure object is not updated in SelectEditorObject
		WasObjectEdited = false
		SelectEditorObject(0)
	end
end

function DuplicateEditorObject(object)
	if not IsValidObject(object) then
		return
	end

	local ModelId = GetObjectModel(object)
	local x, y, z = GetObjectLocation(object)
	local rx, ry, rz = GetObjectRotation(object)

	CallRemoteEvent("Server_EditorSpawnObject", ModelId, x + 35.0, y, z, rx, ry, rz)
end

--[[
	To be called from javascript
]]--
function OnObjectListSelect(ModelId)
	--AddPlayerChat(ModelId)

	if not SelectedLoc.isValid then
		return AddPlayerChat('<span color="#f4f142ff" style="bold">Select a location in the world first by clicking your left mouse button</>')
	end

	if SelectedLoc.distance > 10000.0 then
		return AddPlayerChat('<span color="#ff0000dd" style="bold">Selected location is too far away, select a closer spot</>')
	end

	if IsEditMode and SelectedLoc.isValid then
		CallRemoteEvent("Server_EditorSpawnObject", ModelId, SelectedLoc.x, SelectedLoc.y, SelectedLoc.z)
	end
end
AddEvent("OnObjectListSelect", OnObjectListSelect)

function OnObjectExport()
	DisableEditor()

	CallRemoteEvent("Server_EditorExport")
end
AddEvent("OnObjectExport", OnObjectExport)

function OnEditorChangeSpeed(Speed)
	Speed = tonumber(Speed)
	
	if Speed ~= nil then
		if Speed >= 1.0 and Speed <= 100.0 then
			AddPlayerChat("Editor speed set to "..Speed)
			return SetObjectEditorSpeed(Speed)
		end
	end

	AddPlayerChat('<span color="#ff0000dd" style="bold">Editor speed range: 1-100</>')
end
AddEvent("OnEditorChangeSpeed", OnEditorChangeSpeed)

--[[
	If a script error occurs display it in the chat.
	This only works if the game was started with "-dev" switch
]]--
function OnScriptError(message)
	AddPlayerChat('<span color="#ff0000bb" style="bold" size="10">'..message..'</>')
end
AddEvent("OnScriptError", OnScriptError)
