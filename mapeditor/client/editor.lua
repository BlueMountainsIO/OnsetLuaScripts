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

local ShowMapEditor = true
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
	SetWebVisibility(EditorGui, WEB_VISIBLE)

	SelectedLoc.x = 0.0
	SelectedLoc.y = 0.0
	SelectedLoc.z = 0.0
	SelectedLoc.distance = 0.0
	SelectedLoc.isValid = false

	--ShowHealthHUD(false)
	--ShowWeaponHUD(false)

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

function ToggleMapEditorUI()
	if GetWebVisibility(EditorGui) == WEB_HIDDEN then
		AddPlayerChat("Showing map editor")
		SetWebVisibility(EditorGui, WEB_VISIBLE)
		ShowMapEditor = true
	else
		AddPlayerChat("Hiding map editor")
		DisableEditor()
		SetWebVisibility(EditorGui, WEB_HIDDEN)
		ShowMapEditor = false
	end
end
AddRemoteEvent("ToggleMapEditorUI", ToggleMapEditorUI)

function OnKeyPress(key)
	--AddPlayerChat(key)

	if key == "Z" then
		if IsCtrlPressed() then
			--AddPlayerChat("Undo action")
		end
	end
	
	if key == "Y" then
		if IsCtrlPressed() then
			--AddPlayerChat("Redo action")
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
		if ShowMapEditor then
			ToggleEditor()
		end
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

AddEvent("OnRenderHUD", function()
	if IsEditMode then
		local x, y, z = GetPlayerLocation()
		local ScreenX, ScreenY = GetScreenSize()
	
		SetDrawColor(RGB(255, 255, 255))
		DrawText(2, ScreenY - 40, tostring("Player location: "..x..", "..y..", "..z))
		DrawText(2, ScreenY - 55, tostring("Mouse selected location: "..SelectedLoc.x..", "..SelectedLoc.y..", "..SelectedLoc.z))

		if SelectedLoc.isValid then
			SetDrawColor(RGB(0, 255, 0))
			DrawPoint3D(SelectedLoc.x, SelectedLoc.y, SelectedLoc.z + 5.0, 10.0)

			DrawCircle3D(SelectedLoc.x, SelectedLoc.y, SelectedLoc.z + 5.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 10.0)

			if SelectedObject == 0 then
				SetDrawColor(RGB(0, 255, 0))
				DrawLine3D(SelectedLoc.x, SelectedLoc.y, SelectedLoc.z + 5.0, SelectedLoc.x, SelectedLoc.y + 100.0, SelectedLoc.z + 5.0, 1.0)

				SetDrawColor(RGB(255, 0, 0))
				DrawLine3D(SelectedLoc.x, SelectedLoc.y, SelectedLoc.z + 5.0, SelectedLoc.x + 100.0, SelectedLoc.y, SelectedLoc.z + 5.0, 1.0)

				SetDrawColor(RGB(0, 0, 255))
				DrawLine3D(SelectedLoc.x, SelectedLoc.y, SelectedLoc.z + 5.0, SelectedLoc.x, SelectedLoc.y, SelectedLoc.z + 105.0, 1.0)
			end
		end

		if SelectedObject ~= 0 and IsValidObject(SelectedObject) then
			local bIsPartOfMapEditor = GetObjectPropertyValue(SelectedObject, "isPartOfMapEditor")
			local MinX, MinY, MinZ, MaxX, MaxY, MaxZ = GetObjectBoundingBox(SelectedObject)
			local ModelId = GetObjectModel(SelectedObject)
			local ModelGroup = GetObjectModelGroup(ModelId)
			local sX, sY, sZ = GetObjectSize(SelectedObject)
			local oX, oY, oZ = GetObjectLocation(SelectedObject)
			local rX, rY, rZ = GetObjectRotation(SelectedObject)
			local scX, scY, scZ = GetObjectScale(SelectedObject)
			local PlayerName = GetObjectPropertyValue(SelectedObject, "createdPlayerName")
			local CreationTime = GetObjectPropertyValue(SelectedObject, "createdTimeFormat")

			if not bIsPartOfMapEditor then
				SetDrawColor(RGB(255, 165, 0))
				DrawText(2, ScreenY - 190, "Object is not part of any map editor")
			end

			SetDrawColor(RGB(255, 255, 255))
			DrawText(2, ScreenY - 70, tostring("ObjectBounding: "..MinX..", "..MinY..", "..MinZ..", "..MaxX..", "..MaxY..", "..MaxZ))
			DrawText(2, ScreenY - 85, tostring("ObjectSize: "..sY..", "..sY..", "..sZ))
			DrawText(2, ScreenY - 175, tostring("Created by: "..tostring(PlayerName)))
			DrawText(2, ScreenY - 160, tostring("Created at: "..tostring(CreationTime)))
			DrawText(2, ScreenY - 145, tostring("Object Id: "..SelectedObject..", Model Id: "..ModelId..", Group: "..ModelGroup))
			DrawText(2, ScreenY - 130, tostring("ObjectLoc: "..oX..", "..oY..", "..oZ))
			DrawText(2, ScreenY - 115, tostring("ObjectRot: Pitch "..rX..", Yaw "..rY..", Roll "..rZ))
			DrawText(2, ScreenY - 100, tostring("ObjectScale: "..scX..", "..scY..", "..scZ))

			DrawText(2, ScreenY - 25, "GizmoMode: "..GetGizmoModeStr())
		end
	else
		if ShowMapEditor == true then
			local ScreenX, ScreenY = GetScreenSize()
			SetDrawColor(RGB(255, 165, 0))
			DrawText(2, ScreenY - 40, "Press the 'M' key to enable the map editor!")
			DrawText(2, ScreenY - 60, "Type /objects to hide the map editor window!")
		end
	end
end)

function GetGizmoModeStr()
	if UserWantsEditMode == EDIT_LOCATION then
		return "Translate"
	elseif UserWantsEditMode == EDIT_ROTATION then
		return "Rotate"
	elseif UserWantsEditMode == EDIT_SCALE then
		return "Scale"
	end
	return ""		
end

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
	--AddPlayerChat("SelectEditorObject: "..object)
	if IsValidObject(object) then
		--AddPlayerChat("SelectEditorObject2: "..object)
		WasObjectEdited = false
		SetObjectEditable(object, UserWantsEditMode)
		SetObjectOutline(object, true)
		SelectedObject = object

		UpdateObjectInfoUI(object)
	end
end

function OnPlayerBeginEditObject(object)
	--AddPlayerChat('<span style="italic" size="11">Now editing object</>')

	if object == SelectedObject then
		WasObjectEdited = true
	end
end
AddEvent("OnPlayerBeginEditObject", OnPlayerBeginEditObject)

function OnPlayerEndEditObject(object)
	--AddPlayerChat('<span style="italic" size="11">End editing</>')

	UpdateObjectInfoUI(object)
end
AddEvent("OnPlayerEndEditObject", OnPlayerEndEditObject)

function UpdateObjectInfoUI(object)
	if IsValidObject(object) then
		local x, y, z = GetObjectLocation(object)
		local rx, ry, rz = GetObjectRotation(object)

		ExecuteWebJS(EditorGui, "SetObjectInfo("..x..", "..y..", "..z..", "..rx..", "..ry..", "..rz..");")
	end
end

function UpdateObjectToServer(object)
	if IsValidObject(object) then
		local x, y, z = GetObjectLocation(object)
		local rx, ry, rz = GetObjectRotation(object)
		local sx, sy, sz = GetObjectScale(object)

		if sx == 1.0 and sy == 1.0 and sz == 1.0 then
			sx = nil
			sy = nil
			sz = nil
		end

		CallRemoteEvent("Server_EditorUpdateObject", object, x, y, z, rx, ry, rz, sx, sy, sz)
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

		CreateSound("client/ui_interact1.mp3")
	end
end
AddEvent("OnObjectListSelect", OnObjectListSelect)

function OnObjectExport(MapName)
	DisableEditor()

	CallRemoteEvent("Server_EditorExport", MapName)
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
