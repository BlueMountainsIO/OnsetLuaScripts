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
```
