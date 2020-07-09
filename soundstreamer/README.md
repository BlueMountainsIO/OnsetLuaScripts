## Sound Streamer

Serverside streamed 3D sounds.

This package allows you to add an unlimited amount of sounds in the game world.
The client can only play 8 sounds at the same time via CreateSound.
We get around this limit by taking advantage of the server side streaming algorithm via CreateObject.

#### Example Usage 
```Lua
sr = ImportPackage("soundstreamer")

function OnPackageStart()
	local sound = sr.CreateSound3D("http://us4.internet-radio.com:8258/listen.pls&t=.pls", 125773.000000, 80246.000000, 1645.000000, 650.0)
end
AddEvent("OnPackageStart", OnPackageStart)

function cmd_radio(player)
	local v = GetPlayerVehicle(player)
	if v == false then
		AddPlayerChat(player, "You must be in a vehicle")
		return
	end

	sr.AttachSound3D(ATTACH_VEHICLE, v, "http://us4.internet-radio.com:8258/listen.pls&t=.pls")
	AddPlayerChat(player, "Radio playing, /dradio to stop")
end
AddCommand("radio", cmd_radio)
```

### Exported functions
```Lua
CreateSound3D(sound_file, x, y, z, radius, volume, pitch)
DestroySound3D(soundid)
IsValidSound3D(soundid)
SetSound3DVolume(soundid, volume)
SetSound3DPitch(soundid, pitch)
SetSound3DDimension(soundid, dimension)
GetSound3DDimension(soundid)
SetSound3DLocation(soundid, x, y, z)
GetSound3DLocation(soundid)

-- 3D attached sounds, currently supporting vehicles
-- attach: ATTACH_VEHICLE
-- id: vehicle entity id
-- sound_file: network stream or audio file
-- radius: default 2500.0
-- volume: default 1.0
-- pitch: default 1.0
AttachSound3D(attach, id, sound_file, radius, volume, pitch)
DetachSound3D(attach, id)
IsSoundAttached(attach, id)
```
