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

function cmd_tscene1(player)
	local v1 = CreateVehicle(5, 124205.984375, 80179.3671875, 1481.8326416016, 88.016082763672)
	SetVehicleTrunkRatio(v1, 70.0)
	SetVehicleLicensePlate(v1, "GANJAWAGON")

	local x, y, z = GetVehicleLocation(v1)
	local o1 = CreateObject(61, x, y, z)
	SetObjectScale(o1, 0.6, 0.6, 0.7)
	SetObjectAttached(o1, ATTACH_VEHICLE, v1, -250.0, -60.0, 60.0, -70.0, 80.0, 0.0)

	local v2 = CreateVehicle(3, 124177.4453125, 79022.765625, 1472.4366455078, 88.478591918945)
	SetVehicleLicensePlate(v2, "TRYIT")

	local n1 = CreateNPC(1, 124303.1015625, 78928.8125, 1570.0397949219, 172.49346923828)
	SetNPCAnimation(n1, "HANDSHEAD_STAND", true)

	local n2 = CreateNPC(13, 124294.703125, 78733.8515625, 1569.0129394531, 91.380157470703)
	SetNPCAnimation(n2, "INEAR_COMM", true)

	local n3 = CreateNPC(13, 124125.40625, 79820.5625, 1574.2135009766, 60.628997802734)
end
AddCommand("tscene1", cmd_tscene1)

local n1 = 0
local n2 = 0
local n3 = 0
local n4 = 0

function cmd_tscene2(player)
	SetPlayerLocation(player, 137376.765625, 210144.671875, 1292.1501464844)
	SetPlayerHeading(player, -10.805236816406)

	CallRemoteEvent(player, "ClientSetTime", 15.0)
	CallRemoteEvent(player, "ClientSetWeather", 3)

	n1 = CreateNPC(10, 139803.859375, 209675.890625, 1292.1501464844, 172.86700439453)
	n2 = CreateNPC(19, 139918.890625, 209856.28125, 1292.1501464844, 179.30511474609)
	n3 = CreateNPC(9, 139772.078125, 210041.21875, 1292.1501464844, 178.95355224609)
	n4 = CreateNPC(8, 139628.625, 210221.703125, 1292.1501464844, -178.0746307373)
end
AddCommand("tscene2", cmd_tscene2)

function cmd_tscene2_start(player)
	SetNPCFollowPlayer(n1, player, 400)
	SetNPCFollowPlayer(n2, player, 400)
	SetNPCFollowPlayer(n3, player, 400)
	SetNPCFollowPlayer(n4, player, 400)
end
AddCommand("tscene2_start", cmd_tscene2_start)

function cmd_tscene3(player)
	CallRemoteEvent(player, "TimeLapse")
end
AddCommand("tscene3", cmd_tscene3)

local anims = {
	"DARKSOULS",
	"DABSAREGAY",
	"CRAZYMAN",
	"FLEXX",
	"ITSJUSTRIGHT",
	"IDONTLISTEN",
	"BOW"
}
local acounter = 1

function cmd_tscene4(player)
	SetPlayerLocation(player, 47943.0703125, 137691.171875, 1567.6837158203)

	CallRemoteEvent(player, "ClientSetTime", 12.0)

	SetPlayerModel(player, 11)
	local v1 = CreateVehicle(4, 48399.6796875, 137866.953125, 1469.2335205078, -144.26426696777)
	SetVehicleLicensePlate(v1, "O N S E T")

	local n1 = CreateNPC(2, 47547.23046875, 138174.515625, 1574.7159423828, -53.268035888672)
	SetNPCAnimation(n1, "CLAP", true)
end
AddCommand("tscene4", cmd_tscene4)

function cmd_tscene4_start(player)
	CreateTimer(function(player)
		if acounter + 1 == 10 then
			SetPlayerAnimation(player, "STOP")
			return
		end
		AddPlayerChat(player, anims[acounter])
		SetPlayerAnimation(player, anims[acounter])
		acounter = acounter + 1
	end, 1200, player)
end
AddCommand("cmd_tscene4", cmd_tscene4_start)

local tscene5_n3 = 0
function cmd_tscene5(player)
	CallRemoteEvent(player, "ClientSetTime", 17.0)
	CallRemoteEvent(player, "ClientSetWeather", 2)

	SetPlayerLocation(player, 209539.71875, 180000.75, 1291.8017578125)

	local v1 = CreateVehicle(1, 208083.984375, 183880.453125, 1209.7791748047, 32.360614776611)
	SetVehicleColor(v1, RGB(10, 0, 240))

	local n1 = CreateNPC(15, 203828.0625, 182300.453125, 1312.7413330078, 12.277404785156)
	SetNPCAnimation(n1, "SMOKING", true)

	local v2 = CreateVehicle(2, 204346.296875, 183503.21875, 1209.7946777344, -179.05714416504)

	local v3 = CreateVehicle(5, 208041.65625, 184471.671875, 1211.3552246094, 34.267597198486)

	CreateVehicle(4, 206702.609375, 183195.9375, 1208.6910400391, 90.080360412598)

	CreateVehicle(6, 204382.203125, 182752.359375, 1209.0047607422, -0.3297418653965)

	CreateVehicle(3, 207984.21875, 188138.5625, 1209.7630615234, 0.2442566007375)

	CreateVehicle(8, 207947.765625, 189347.625, 1207.9768066406, 90.453575134277)

	CreateVehicle(9, 205699.25, 186788.390625, 1193.5463867188, 0.93007671833038)

	local v4 = CreateVehicle(7, 206692.15625, 189368.375, 1209.3698730469, -89.886131286621)
	SetVehicleColor(v4, RGB(200, 0, 100))

	local n2 = CreateNPC(8, 206067.703125, 186589.890625, 1292.1313476562, 138.96267700195)
	SetNPCAnimation(n2, "CRAZYMAN", true)

	tscene5_n3 = CreateNPC(16, 208261.921875, 183744.3125, 1307.1501464844, -108.98052978516)
	SetNPCAnimation(tscene5_n3, "CROSSARMS", true)

	tscene5_n4 = CreateNPC(12, 208572.390625, 185873.234375, 1309.6395263672, 179.82147216797)
end
AddCommand("tscene5", cmd_tscene5)

function cmd_tscene5_start(player)
	--SetNPCTargetLocation(tscene5_n3, 208664.921875, 183767.9375, 1309.9039306641, 200.0)

	SetNPCTargetLocation(tscene5_n4, 205091.640625, 185856.15625, 1310.6472167969, 400.0)
end
AddCommand("tscene5_start", cmd_tscene5_start)

function cmd_tscene6(player)
	local v1 = CreateVehicle(3, 117203.640625, 163535.140625, 2940.4997558594, 25.011814117432)
	--SetVehicleHealth(v1, 0.0)

	local v2 = CreateVehicle(5, 117500.84375, 161077.359375, 2932.6459960938, 30.962339401245)
	SetVehicleColor(v2, RGB(90, 1, 100))
	--[[SetVehicleDamage(v2, 1, 1.0)
	SetVehicleDamage(v2, 2, 1.0)
	SetVehicleDamage(v2, 3, 1.0)
	SetVehicleDamage(v2, 4, 1.0)
	SetVehicleDamage(v2, 5, 1.0)
	SetVehicleDamage(v2, 6, 1.0)
	SetVehicleDamage(v2, 7, 1.0)
	SetVehicleDamage(v2, 8, 1.0)]]--
end
AddCommand("tscene6", cmd_tscene6)

function cmd_tscene7(player)
	CreateVehicle(1, 213664.6875, 162447.71875, 1207.7987060547, -91.37117767334)
	CreateVehicle(4, 214380.953125, 161122.28125, 1206.6678466797, 91.073974609375)
	CreateVehicle(7, 212232.625, 163993.734375, 1205.7569580078, 91.098068237305)
	CreateVehicle(1, 214732.359375, 161148.875, 1207.7800292969, 93.96509552002)
	CreateVehicle(5, 215395.84375, 162509.109375, 1209.3524169922, -94.886520385742)
end
AddCommand("tscene7", cmd_tscene7)

function cmd_tscene8(player)
	local n1 = CreateNPC(14, 214491.265625, 190972.515625, 1307.2492675781, 124.21881103516)
	SetNPCAnimation(n1, "COMBINE", true)
end
AddCommand("tscene8", cmd_tscene8)

function cmd_tscene9(player, eid)
	--CreateNPC(1, 128806.359375, 77818.28125, 1577.6500244141, -91.435119628906)
	--CreateNPC(1, 128726.265625, 77596.234375, 1576.4000244141, 72.011016845703)
	--SetPlayerLocation(player, 211538.875, 190173.734375, 1306.9666748047, -177.48133850098)

	Delay(1500, function(eid)
		CreateExplosion(eid, 212845.0, 190982.0, 1691.0, true, 0.0, 0.0)

		CreateExplosion(15, 212841.34375, 189344.8125, 1306.9792480469, true, 0.0, 0.0)
		CreateExplosion(15, 212410.140625, 190745.828125, 1307.23181, true, 0.0, 0.0)
	end, eid)
end
AddCommand("tscene9", cmd_tscene9)

function cmd_tscene10(player)
	--CreateNPC(1, 128806.359375, 77818.28125, 1577.6500244141, -91.435119628906)
	--CreateNPC(1, 128726.265625, 77596.234375, 1576.4000244141, 72.011016845703)
	--SetPlayerLocation(player, 211538.875, 190173.734375, 1306.9666748047, -177.48133850098)

	Delay(1500, function()
		--CreateExplosion(eid, 212845.0, 190982.0, 1691.0, true, 0.0, 0.0)

		CreateExplosion(15, 170054.125, 194855.484375, 1396.9477539062, true, 0.0, 0.0)
		CreateExplosion(15, 171638.46875, 195502.71875, 1312.7413330078, true, 0.0, 0.0)
	end)
end
AddCommand("tscene10", cmd_tscene10)

function cmd_tscene11(player)
	SetPlayerAnimation(player, "FACEPALM", true)

	SetPlayerAnimation(2, "ITSJUSTRIGHT", true)
end
AddCommand("tscene11", cmd_tscene11)

local ts12 = 0
function cmd_tscene12(player)
	ts12 = CreateTimer(IncreaseHeadSize, 10, player)
end
AddCommand("tscene12", cmd_tscene12)

function IncreaseHeadSize(player)
	local size = GetPlayerHeadSize(player) + 0.1
	SetPlayerHeadSize(player, size)
	if (size > 3.0) then
		DestroyTimer(ts12)
	end
end
