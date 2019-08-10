
ltime = 0
function TimeLapse()
	CreateTimer(function()
		if ltime >= 24 then
			ltime = 0
		end
		ltime = ltime + 0.01
		SetTime(ltime)
	end, 10)
end
AddRemoteEvent("TimeLapse", TimeLapse)