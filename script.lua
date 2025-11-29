local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Settings
local flySpeed = 50
local flyTransparency = 0.5
local spiritActive = false

-- Create a "spirit" part that will represent the flying ghost
local spirit = Instance.new("Part")
spirit.Size = Vector3.new(2, 2, 2)
spirit.Shape = Enum.PartType.Ball
spirit.Material = Enum.Material.Neon
spirit.Color = Color3.fromRGB(100, 100, 255)
spirit.Transparency = flyTransparency
spirit.CanCollide = false
spirit.Anchored = true
spirit.Parent = workspace

-- Make character transparent for spirit mode
local function setCharacterTransparency(transparency)
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = transparency
		end
	end
end

-- Fly control variables
local velocity = Vector3.new(0, 0, 0)
local flying = false

-- Move spirit with WASD + Space + Shift
local function updateSpiritMovement(dt)
	if not flying then return end

	local moveDir = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		moveDir = moveDir + Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		moveDir = moveDir - Vector3.new(0, 1, 0)
	end

	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
	end

	velocity = moveDir * flySpeed
	spirit.CFrame = spirit.CFrame + velocity * dt
end

-- Pick up items near the spirit and parent them to the character
local function pickUpNearbyItems()
	local radius = 5
	for _, item in pairs(workspace:GetChildren()) do
		if item:IsA("BasePart") and item.Anchored == false then
			local dist = (item.Position - spirit.Position).Magnitude
			if dist <= radius then
				-- Move item to character's HumanoidRootPart
				item.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
				item.Anchored = false
				item.Parent = character
			end
		end
	end
end

-- Toggle spirit fly mode
local function toggleSpirit()
	spiritActive = not spiritActive
	if spiritActive then
		flying = true
		spirit.CFrame = rootPart.CFrame
		setCharacterTransparency(flyTransparency)
		humanoid.PlatformStand = true
	else
		flying = false
		setCharacterTransparency(0)
		humanoid.PlatformStand = false
		spirit.CFrame = CFrame.new(0, -5000, 0) -- hide spirit far away
	end
end

-- Input to toggle spirit mode (F key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F then
		toggleSpirit()
	end
	if input.KeyCode == Enum.KeyCode.E and spiritActive then
		pickUpNearbyItems()
	end
end)

-- Update loop
RunService.Heartbeat:Connect(function(dt)
	if spiritActive then
		updateSpiritMovement(dt)
	end
end)
