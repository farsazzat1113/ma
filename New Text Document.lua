local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- إعدادات السرعة
local DEFAULT_SPEED = 16
local DESIRED_SPEED = 100

-- حالة التشغيل (OFF افتراضياً)
local isEnabled = false

-- ======================
-- GUI SETUP (PC Optimized)
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedJumpMaster"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(200, 55)
frame.Position = UDim2.fromOffset(25, 25)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Draggable = true -- قابل للسحب بالماوس
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.Thickness = 2
stroke.Parent = frame

local button = Instance.new("TextButton")
button.Name = "ToggleBtn"
button.Size = UDim2.fromOffset(190, 45)
button.Position = UDim2.fromOffset(5, 5)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.Text = "OFF [Space]"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamSemibold
button.AutoButtonColor = true
button.Parent = frame

Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

-- ======================
-- FUNCTIONS
-- ======================
local function updateGUI()
    if isEnabled then
        button.Text = "ON [Space] ⚡"
        button.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        stroke.Color = Color3.fromRGB(0, 180, 0)
    else
        button.Text = "OFF [Space]"
        button.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
        stroke.Color = Color3.fromRGB(180, 0, 0)
    end
end

-- دالة تغيير السرعة
local function applySpeed(humanoid)
    if not humanoid then return end
    humanoid.WalkSpeed = isEnabled and DESIRED_SPEED or DEFAULT_SPEED
end

-- لوب خفيف للحفاظ على السرعة
local speedLoop = nil
local function startSpeedLoop(character)
    if speedLoop then speedLoop:Disconnect() end
    local humanoid = character:WaitForChild("Humanoid")
    applySpeed(humanoid)

    speedLoop = RunService.Heartbeat:Connect(function()
        if not humanoid or not humanoid.Parent then
            speedLoop:Disconnect()
            speedLoop = nil
            return
        end
        local target = isEnabled and DESIRED_SPEED or DEFAULT_SPEED
        if humanoid.WalkSpeed ~= target then
            applySpeed(humanoid)
        end
    end)
end

-- دالة القفز اللانهائي
local function doInfiniteJump()
    -- الشرط ده هو اللي بيخلي القفز يشتغل بس لما الزرار ON
    if not isEnabled then return end 
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ======================
-- EVENTS
-- ======================
-- 1. تشغيل/إيقاف المميزات بالزرار
button.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    updateGUI()
    
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then applySpeed(hum) end
    end
end)

-- 2. التقاط ضغطة الـ Space للقفز
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- منع التداخل مع الشات
    if input.KeyCode == Enum.KeyCode.Space then
        doInfiniteJump()
    end
end)

-- 3. التعامل مع الـ Respawn عشان السرعة ما تروحش
player.CharacterAdded:Connect(function(char)
    startSpeedLoop(char)
end)

-- ======================
-- INIT
-- ======================
updateGUI()
if player.Character then
    startSpeedLoop(player.Character)
end