--[[
	ryely
	(if else if else simulator)
]]

local textService = game:GetService("TextService")
local markerFolder = game.Workspace:FindFirstChild("Infomarkers")


--calls to roblox's filtering service to clean the text
--you need this or you get banned
local function filterText(player, text)
	return game:GetService("Chat"):FilterStringForBroadcast(text, player)	
end

--handler error/success GUI
-- THE if else simulator
local function infoUIHandler(player, value, extra)
	local infomarkerUI = player.PlayerGui:FindFirstChild("infomarkerUI")
	if not infomarkerUI then return false end
	if value == "Format" then
		infomarkerUI.ErrorHandler.Text = "Incorrect format, please try again."
		infomarkerUI.Enabled = true
		wait(2)
		infomarkerUI.Enabled = false	
	elseif value == "Filtered" then
		infomarkerUI.ErrorHandler.Text = "Sorry! Text was filtered. Please try again."
		infomarkerUI.Enabled = true
		wait(2)
		infomarkerUI.Enabled = false
	elseif value == "Success" then
		task.spawn(function()
			infomarkerUI.ErrorHandler.Text = "Success! Infomarker created."
			infomarkerUI.Enabled = true
			wait(0.8)
			infomarkerUI.Enabled = false
		end)
	elseif value == "Exists" then
		infomarkerUI.ErrorHandler.Text = "You already have a marker placed! Remove it with /e deleteinfomarker"
		infomarkerUI.Enabled = true
		wait(2)
		infomarkerUI.Enabled = false
	elseif value == "Length" then
		infomarkerUI.ErrorHandler.Text = "Sorry! The maximum time is 7200 seconds. (2 Hours)"
		infomarkerUI.Enabled = true
		wait(2)
		infomarkerUI.Enabled = false
	elseif value == "DoesntExist" then
		infomarkerUI.ErrorHandler.Text = "You don't have an infomarker set!"
		infomarkerUI.Enabled = true
		wait(2)
		infomarkerUI.Enabled = false
	elseif value == "Deleted" then
		infomarkerUI.ErrorHandler.Text = "Successfully deleted infomarker!"
		infomarkerUI.Enabled = true
		wait(2)
		infomarkerUI.Enabled = false
	elseif value == "Check" then
		infomarkerUI.ErrorHandler.Text = "Infomarker owned by: " .. extra
		infomarkerUI.Enabled = true
		wait(2)
		infomarkerUI.Enabled = false
	end		
end

-- clean up and destroy an infomarker after the time has passed
--made in a coroutine so that you can continue to run other commands
local function cleanupMarker(marker, timer)
	task.spawn(function()
		wait(timer)
		marker:Destroy()
	end)
end

--check that the player doesnt already have an infomarker
--returns true if they do, false if there isnt
local function checkChildren(player)
	local children = markerFolder:GetChildren()
	for i, child in ipairs(children) do
		if child.Username.Value == tostring(player) then
			return true
		else
			return false
		end
	end
end

--clear a specified infomarker
--edit: why dont I use the checkchildren function I defined literally right above this?
--i could change checkchildren to return the child if true or nil if false and then change this func
--i,e if checkchildren() then destroy:checkchildren or whatever
local function clearChild(player)
	local children = markerFolder:GetChildren()
	for i, child in ipairs(children) do
		if child.Username.Value == tostring(player) then
			child:Destroy()
			return true
		else
			return false
		end
	end
end

--main function for creating a marker
local function createMarker(player, timer, filtered, original)
	if timer > 7200 then infoUIHandler(player, "Length") return end
	if filtered ~= original then infoUIHandler(player, "Filtered") return end
	if checkChildren(player) == true then infoUIHandler(player, "Exists") return end
	
	infoUIHandler(player, "Success")
	local infomarker = game.ReplicatedStorage:WaitForChild("infomarker"):Clone()
	infomarker.Position = player.Character.HumanoidRootPart.Position
	infomarker.billboardPart.Position = player.Character.HumanoidRootPart.Position
	infomarker.billboardPart.billboard.GUIText.Text = "*" .. filtered .. "*"
	infomarker.Username.Value = player.Name
	infomarker.Parent = markerFolder
	cleanupMarker(infomarker, timer)
end

--the command handler for creating an infomarker
local function createMarkerCmd(player, msg)
	local str = string.split(msg, " ")
	local strTime = str[3]
	local strText = str[4]
	if strTime and strText ~= "" and tonumber(strTime) then
		local length = string.len(strTime) + 22
		createMarker(player, tonumber(strTime), filterText(player, string.sub(msg, length)), string.sub(msg, length))
	else
		infoUIHandler(player, "Format")
		print("You messed up the SYNTAX BRO WHY?!")
	end
end

--the command handler for deleting an infomarker
local function delMarkerCmd(player, msg)
	if checkChildren(player) ~= true then infoUIHandler(player, "DoesntExist") return end
	if clearChild(player) == true then infoUIHandler(player, "Deleted") return end
end

--the command handler for checking a players infomarker
local function checkMarkerCmd(player)
	local children = markerFolder:GetChildren()
	for i, child in ipairs(children) do
		local magnitude = (child.Position - player.Character.HumanoidRootPart.Position).Magnitude
		if magnitude < 10 then
			infoUIHandler(player, "Check", child.Username.Value)
		end
	end
end

--initialize script
game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		if string.sub(msg, 0, 19) == "/e createinfomarker" then	
			createMarkerCmd(player, msg)
		elseif string.sub(msg, 0, 19) == "/e deleteinfomarker" then	
			delMarkerCmd(player, msg)
		elseif string.sub(msg, 0, 18) == "/e checkinfomarker" then
			checkMarkerCmd(player)
		end
	end)
end)
