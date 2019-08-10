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

WebGuiId = 0

function OnPackageStart()
	WebGuiId = CreateWebUI(0.0, 0.0, 0.0, 0.0, 4, 32)
	LoadWebFile(WebGuiId, "http://asset/"..GetPackageName().."/gui/gui.html")
	SetWebAlignment(WebGuiId, 0.0, 0.0)
	SetWebAnchors(WebGuiId, 0.0, 0.0, 1.0, 1.0)
	SetWebVisibility(WebGuiId, WEB_HITINVISIBLE)
end
AddEvent("OnPackageStart", OnPackageStart)

function OnPackageStop()
	DestroyWebUI(WebGuiId)
end
AddEvent("OnPackageStop", OnPackageStop)

function OnWebLoadComplete(webid)
	if WebGuiId == webid then
		CallEvent("OnClientWebGuiLoaded")
		CallRemoteEvent("OnClientWebGuiLoaded")
	end
end
AddEvent("OnWebLoadComplete", OnWebLoadComplete)

function SetVisibility(visible)
	if visible then
		SetWebVisibility(WebGuiId, WEB_HITINVISIBLE)
	else
		SetWebVisibility(WebGuiId, WEB_HIDDEN)
	end
end
AddFunctionExport("SetVisibility", SetVisibility)
