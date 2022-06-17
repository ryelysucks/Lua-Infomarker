--[[

ryely

trying my hardest to not cause memory leaks here but it still probably does
...oh well!

--]]


local markerFolder = game.Workspace.Infomarkers

--debounces
local loopBreak = false
local touchedStarted = false
local touchDebounce = false

--need to initialize this so we can call :Disconnect() on it later
local touchConnection


--this is the function that makes the markers spin.
--Possibly might be laggy. I dunno. Maybe remake this as a tween or something.
local function spinny()
	local children = markerFolder:GetChildren()
	while wait(0.01) do
		if loopBreak == false then
			for i, child in ipairs(children) do
				child.CFrame = child.CFrame * CFrame.fromEulerAnglesXYZ(0,0.05,0)
			end
		else
			break
		end
	end
end

--create touched connections and show text when walking over a marker
--possibly edit so you can read multiple markers at the same time?
local function show()
	for i,v in pairs(markerFolder:GetChildren()) do
		print("started a new touched connection")
		touchConnection = v.Touched:Connect(function()
			if touchDebounce == false then
				touchDebounce = true
				print("touched me")
				v.billboardPart.billboard.Enabled = true
				wait(3)
				v.billboardPart.billboard.Enabled = false
				touchDebounce = false
			end
		end)
	end
end


--child was removed, we should remove all old .touched connections and stop all markers from spinning to avoid a memory leak, then restart both for all remaining markers
markerFolder.ChildRemoved:Connect(function(child)
	loopBreak = true
	if markerFolder:FindFirstChild("infomarker") then
		touchConnection:Disconnect()
		print("removing old touched connections")
		wait(0.1)
		loopBreak = false
		show()
		spinny()
	else
		touchConnection:Disconnect()
		print("ending connection")
	end
end)

--child was added, so we do the same as before.
-- also check that there actually IS a touched connection in the first place..
markerFolder.ChildAdded:Connect(function(child)
	loopBreak = true
	if touchedStarted == true then
		touchConnection:Disconnect()
		print("disconnected touch events")
	end
	wait(0.1)
	loopBreak = false
	show()
	spinny()
	touchedStarted = true
end)
