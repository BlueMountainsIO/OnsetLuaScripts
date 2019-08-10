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

function ShowMessageBox(text)
	ExecuteWebJS(WebGuiId, "ShowMessageBox('"..Base64Encode(text).."');")
	SetWebVisibility(WebGuiId, WEB_VISIBLE)
	ShowMouseCursor(true)
	SetInputMode(INPUT_UI)
end
AddRemoteEvent("ShowMessageBox", ShowMessageBox)

function HideMessageBox()
	ExecuteWebJS(WebGuiId, "HideMessageBox();")
	SetWebVisibility(WebGuiId, WEB_HITINVISIBLE)
	ShowMouseCursor(false)
	SetInputMode(INPUT_GAME)
end
AddRemoteEvent("HideMessageBox", HideMessageBox)

function ShowInputBox(message, button, event)
	event = event or ""
	ExecuteWebJS(WebGuiId, "ShowInputBox('"..Base64Encode(message).."', '"..Base64Encode(button).."', '"..Base64Encode(event).."');")
	SetWebVisibility(WebGuiId, WEB_VISIBLE)
	ShowMouseCursor(true)
	SetInputMode(INPUT_UI)
end
AddRemoteEvent("ShowInputBox", ShowInputBox)

--[[
	To be called from javascript when user dismisses dialog
]]--
function OnHideMessageBox()
	SetWebVisibility(WebGuiId, WEB_HITINVISIBLE)
	ShowMouseCursor(false)
	SetInputMode(INPUT_GAME)
end
AddEvent("OnHideMessageBox", OnHideMessageBox)
