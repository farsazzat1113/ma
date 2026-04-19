local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ====================== EGG COLLECTOR SETTINGS ======================
local collecting = false
local collectedCount = 0
local EGG_KEYWORDS = {"egg", "بيض", "easter", "collectible", "hunt", "token", "orb", "item"}

-- ====================== SPEED & JUMP SETTINGS ======================
local DEFAULT_SPEED = 50
local DESIRED_SPEED = 150
local isEnabled = false -- speed/jump toggle

-- ====================== GUI SETUP ======================
local gui = Instance.new("ScreenGui")
gui.Name = "MarvinUtilityV2"
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- ---------------------- Egg Collector Frame ----------------------
local eggFrame = Instance.new("Frame")
eggFrame.Size = UDim2.fromOffset(230, 70)
eggFrame.Position = UDim2.fromOffset(20, 20)
eggFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
eggFrame.BorderSizePixel = 0
eggFrame.Draggable = true
eggFrame.Parent = gui
Instance.new("UICorner", eggFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(40, 40, 40)
stroke.Thickness = 2
stroke.Parent = eggFrame

local eggBtn = Instance.new("TextButton")
eggBtn.Size = UDim2.fromOffset(220, 50)
eggBtn.Position = UDim2.fromOffset(5, 5)
eggBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
eggBtn.Text = "🥚 START COLLECTING"
eggBtn.TextColor3 = Color3.new(1, 1, 1)
eggBtn.TextScaled = true
eggBtn.Font = Enum.Font.GothamBold
eggBtn.AutoButtonColor = true
eggBtn.Parent = eggFrame
Instance.new("UICorner", eggBtn).CornerRadius = UDim.new(0, 8)

local counter = Instance.new("TextLabel")
counter.Size = UDim2.fromScale(1, 0.25)
counter.Position = UDim2.fromScale(0, 1)
counter.BackgroundTransparency = 1
counter.Text = "Collected: 0"
counter.TextColor3 = Color3.new(0.85, 0.85, 0.85)
counter.TextScaled = true
counter.Font = Enum.Font.GothamMedium
counter.Parent = gui

-- ---------------------- Speed/Jump Frame ----------------------
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.fromOffset(200, 55)
speedFrame.Position = UDim2.fromOffset(20, 110)
speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
speedFrame.BorderSizePixel = 0
speedFrame.Draggable = true
speedFrame.Parent = gui
Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(0, 8)
local speedStroke = Instance.new("UIStroke")
speedStroke.Color = Color3.fromRGB(60, 60, 60)
speedStroke.Thickness = 2
speedStroke.Parent = speedFrame

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.fromOffset(190, 45)
speedBtn.Position = UDim2.fromOffset(5, 5)
speedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBtn.Text = "OFF [Space]"
speedBtn.TextColor3 = Color3.new(1, 1, 1)
speedBtn.TextScaled = true
speedBtn.Font = Enum.Font.GothamSemibold
speedBtn.AutoButtonColor = true
speedBtn.Parent = speedFrame
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 6)

-- ====================== FUNCTIONS ======================
-- Egg Collector
local function isEgg(obj)
    if not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    for _, k in ipairs(EGG_KEYWORDS) do
        if n:find(k) then return true end
    end
    return false
end

local function autoCollect()
    task.spawn(function()
        while collecting do
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not root then task.wait(0.3) continue end

            local eggs = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isEgg(obj) and obj.Transparency < 0.85 then
                    table.insert(eggs, obj)
                end
            end

            if #eggs == 0 then task.wait(0.5) continue end

            table.sort(eggs, function(a, b)
                return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
            end)

            local target = eggs[1]
            pcall(function()
                root.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
            end)
            
            collectedCount += 1
            counter.Text = "Collected: " .. collectedCount
            task.wait(0.05)
        end
    end)
end

-- Speed/Jump
local function updateSpeedGUI()
    if isEnabled then
        speedBtn.Text = "ON [Space] ⚡"
        speedBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        speedStroke.Color = Color3.fromRGB(0, 180, 0)
    else
        speedBtn.Text = "OFF [Space]"
        speedBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
        speedStroke.Color = Color3.fromRGB(180, 0, 0)
    end
end

local speedLoop
local function applySpeed(humanoid)
    if humanoid then humanoid.WalkSpeed = isEnabled and DESIRED_SPEED or DEFAULT_SPEED end
end

local function startSpeedLoop(character)
    if speedLoop then speedLoop:Disconnect() end
    local humanoid = character:WaitForChild("Humanoid")
    applySpeed(humanoid)
    speedLoop = RunService.Heartbeat:Connect(function()
        if humanoid and humanoid.Parent then
            local target = isEnabled and DESIRED_SPEED or DEFAULT_SPEED
            if humanoid.WalkSpeed ~= target then applySpeed(humanoid) end
        else
            speedLoop:Disconnect()
            speedLoop = nil
        end
    end)
end

local function doInfiniteJump()
    if not isEnabled then return end
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ====================== EVENTS ======================
-- Egg Collector Toggle
eggBtn.MouseButton1Click:Connect(function()
    collecting = not collecting
    if collecting then
        eggBtn.Text = "⏹ STOP COLLECTING"
        eggBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 0)
        autoCollect()
    else
        eggBtn.Text = "🥚 START COLLECTING"
        eggBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

-- Speed/Jump Toggle
speedBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    updateSpeedGUI()
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        applySpeed(hum)
    end
end)

-- Space for Jump
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then doInfiniteJump() end
end)

-- Character Added
player.CharacterAdded:Connect(function(char)
    if collecting then autoCollect() end
    startSpeedLoop(char)
end)

-- ====================== INIT ======================
updateSpeedGUI()
if player.Character then startSpeedLoop(player.Character) end
