local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ====================== [ الإعدادات ] ======================
local collecting = false
local killAura = false
local speedOn = false

local EGG_KEYWORDS = {"egg", "بيض", "item", "collect", "drop", "gift"}
local DESIRED_SPEED = 150

-- ====================== [ واجهة المستخدم - ألوان متداخلة ] ======================
local gui = Instance.new("ScreenGui")
gui.Name = "Fares_Savage_V5"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(280, 350)
main.Position = UDim2.fromOffset(100, 100)
main.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

-- تدرج ألوان ناري (أزرق وبنفسجي محمر)
local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 100))
})
mainGradient.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "FARES SAVAGE V5"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BackgroundTransparency = 1
title.Parent = main

local list = Instance.new("UIListLayout", main)
list.Padding = UDim.new(0, 12)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder

local function createButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(230, 50)
    btn.BackgroundColor3 = Color3.new(1, 1, 1)
    btn.BackgroundTransparency = 0.85
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.LayoutOrder = order
    btn.Parent = main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

local killBtn = createButton("⚔️ KILL AURA: OFF", 1)
local eggBtn = createButton("🥚 AUTO EGG: OFF", 2)
local speedBtn = createButton("⚡ SPEED: OFF", 3)

-- ====================== [ منطق الضرب التلقائي القوي ] ======================

task.spawn(function()
    while task.wait() do -- أسرع تكرار ممكن
        if killAura then
            pcall(function()
                local targetPlayer = nil
                local shortestDistance = math.huge
                
                -- البحث عن الهدف
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local distance = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            targetPlayer = p
                        end
                    end
                end
                
                if targetPlayer then
                    -- 1. الانتقال وراء الهدف مباشرة
                    player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2.5)
                    
                    -- 2. إمساك السلاح تلقائياً (من الـ Backpack)
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if not tool then
                        local backpackTool = player.Backpack:FindFirstChildOfClass("Tool")
                        if backpackTool then
                            backpackTool.Parent = player.Character
                        end
                    end
                    
                    -- 3. الضرب التلقائي (Force Activate)
                    tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate() -- يضرب
                    end
                end
            end)
        end
    end
end)

-- ====================== [ تجميع البيض ] ======================
task.spawn(function()
    while task.wait(0.2) do
        if collecting then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        for _, key in ipairs(EGG_KEYWORDS) do
                            if obj.Name:lower():find(key) and obj.Transparency < 1 then
                                player.Character.HumanoidRootPart.CFrame = obj.CFrame
                                task.wait(0.1)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================== [ التحكم ] ======================

killBtn.MouseButton1Click:Connect(function()
    killAura = not killAura
    killBtn.Text = killAura and "⚔️ KILL AURA: ACTIVE" or "⚔️ KILL AURA: OFF"
    killBtn.BackgroundColor3 = killAura and Color3.fromRGB(255, 50, 50) or Color3.new(1,1,1)
end)

eggBtn.MouseButton1Click:Connect(function()
    collecting = not collecting
    eggBtn.Text = collecting and "🥚 EGG: ACTIVE" or "🥚 EGG: OFF"
    eggBtn.BackgroundColor3 = collecting and Color3.fromRGB(50, 200, 50) or Color3.new(1,1,1)
end)

speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    speedBtn.Text = speedOn and "⚡ SPEED: ON" or "⚡ SPEED: OFF"
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speedOn and DESIRED_SPEED or 16
    end
end)
