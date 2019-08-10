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

local textId = 0

function CreateText(text, x, y, fontsize)

	textId = textId + 1

	ExecuteWebJS(WebGuiId, "CreateText("..textId..", "..x..", "..y..",  "..fontsize..", '"..text.."');")

	return textId
end
AddRemoteEvent("CreateText", CreateText)
AddFunctionExport("CreateText", CreateText)

function CreateTextDuration(text, x, y, duration)
	local id = CreateText(text, x, y, 3)

	Delay(duration, function(id)
		DestroyText(id)
	end, id)
	return id
end
AddRemoteEvent("CreateTextDuration", CreateTextDuration)
AddFunctionExport("CreateTextDuration", CreateTextDuration)

function SetText(id, text)
	ExecuteWebJS(WebGuiId, "SetText("..id..", '"..text.."');")
end
AddFunctionExport("SetText", SetText)

function DestroyText(id)
	ExecuteWebJS(WebGuiId, "DestroyText("..id..");")
end
AddFunctionExport("DestroyText", DestroyText)

function SetTextVisible(id, visible)
	if visible then
		ExecuteWebJS(WebGuiId, "ShowText("..id..");")
	else
		ExecuteWebJS(WebGuiId, "HideText("..id..");")
	end
end
AddFunctionExport("SetTextVisible", SetTextVisible)
