local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ====================== [ الإعدادات ] ======================
local autoAttack = true -- مفعل تلقائياً من البداية
local killAura = false
local collecting = false
local speedOn = false
local DESIRED_SPEED = 100

-- ====================== [ الواجهة المتطورة ] ======================
local gui = Instance.new("ScreenGui")
gui.Name = "Bull_Battles_Mod"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 450)
main.Position = UDim2.fromOffset(50, 50)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})
gradient.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "🐂 BULL BATTLES MOD"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.BackgroundTransparency = 1
title.Parent = main

local list = Instance.new("UIListLayout", main)
list.Padding = UDim.new(0, 8)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder

local function createBtn(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(260, 45)
    btn.BackgroundColor3 = Color3.new(0, 0, 0)
    btn.BackgroundTransparency = 0.6
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.LayoutOrder = order
    btn.Parent = main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(255, 100, 0)
    return btn
end

local autoAttackBtn = createBtn("⚙️ AUTO ATTACK", 1)
local killBtn = createBtn("🐂 CHARGE AURA", 2)
local chargeBtn = createBtn("⚡ POWER BOOST", 3)
local speedBtn = createBtn("💨 SPEED", 4)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 40)
statusLabel.Position = UDim2.fromOffset(10, 400)
statusLabel.Text = "Status: AUTO ATTACK ON"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = main

-- تعيين الألوان الأولية
autoAttackBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

-- ====================== [ الهجوم التلقائي المستمر - بدون الحاجة للضغط على أي زر ] ======================

task.spawn(function()
    while task.wait(0.05) do -- ضرب سريع جداً كل 0.05 ثانية
        if autoAttack then
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end

                local target = nil
                local closestDist = 150

                -- البحث عن أقرب لاعب عدو
                for _, v in ipairs(Players:GetPlayers()) do
                    if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                        local d = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                        if d < closestDist then
                            closestDist = d
                            target = v
                        end
                    end
                end

                if target and target.Character then
                    -- الاقتراب من العدو والضرب السريع
                    local targetPos = target.Character.HumanoidRootPart.Position
                    local myPos = player.Character.HumanoidRootPart.Position
                    local distance = (targetPos - myPos).Magnitude

                    if distance > 5 then
                        -- اقترب من العدو
                        local direction = (targetPos - myPos).Unit
                        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + direction * 2
                    else
                        -- أنت قريب جداً - ابدأ الضرب
                        local tool = player.Character:FindFirstChildOfClass("Tool")
                        if not tool then
                            local btool = player.Backpack:FindFirstChildOfClass("Tool")
                            if btool then
                                btool.Parent = player.Character
                                task.wait(0.05)
                                tool = player.Character:FindFirstChildOfClass("Tool")
                            end
                        end
                        
                        if tool then
                            pcall(function()
                                tool:Activate()
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================== [ منطق CHARGE AURA الإضافي ] ======================

task.spawn(function()
    while task.wait() do
        if killAura then
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end

                local target = nil
                local closestDist = 150

                for _, v in ipairs(Players:GetPlayers()) do
                    if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                        local d = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                        if d < closestDist then
                            closestDist = d
                            target = v
                        end
                    end
                end

                if target and target.Character then
                    -- الاقتراب من العدو
                    local targetCFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    player.Character.HumanoidRootPart.CFrame = targetCFrame
                    
                    -- محاولة الضرب/الهجوم
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:MoveTo(target.Character.HumanoidRootPart.Position)
                    end
                    
                    -- تفعيل أي أداة (مثل القرون في Bull Battles)
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if not tool then
                        local btool = player.Backpack:FindFirstChildOfClass("Tool")
                        if btool then
                            btool.Parent = player.Character
                            task.wait(0.05)
                            tool = player.Character:FindFirstChildOfClass("Tool")
                        end
                    end
                    
                    if tool then
                        pcall(function()
                            tool:Activate()
                            task.wait(0.02)
                            tool:Deactivate()
                        end)
                    end
                end
            end)
        end
    end
end)

-- ====================== [ جمع الموارد/المكافآت ] ======================

task.spawn(function()
    while task.wait(0.2) do
        if collecting then
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end

                local closest = nil
                local closestDist = math.huge

                for _, o in ipairs(Workspace:GetDescendants()) do
                    if o:IsA("BasePart") then
                        local name = o.Name:lower()
                        -- ابحث عن الموارد/المكافآت
                        if name:find("coin") or name:find("reward") or name:find("item") or name:find("pickup") or name:find("gem") then
                            if o.Parent then
                                local dist = (player.Character.HumanoidRootPart.Position - o.Position).Magnitude
                                if dist < closestDist and dist < 200 then
                                    closestDist = dist
                                    closest = o
                                end
                            end
                        end
                    end
                end

                if closest then
                    player.Character.HumanoidRootPart.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.1)
                end
            end)
        end
    end
end)

-- ====================== [ التحكم بالأزرار ] ======================

-- زر تفعيل/تعطيل الهجوم التلقائي
autoAttackBtn.MouseButton1Click:Connect(function()
    autoAttack = not autoAttack
    if autoAttack then
        autoAttackBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        autoAttackBtn.Text = "⚙️ AUTO ATTACK: ON"
        statusLabel.Text = "Status: AUTO ATTACK ON"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        autoAttackBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        autoAttackBtn.Text = "⚙️ AUTO ATTACK: OFF"
        statusLabel.Text = "Status: AUTO ATTACK OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
    end
end)

killBtn.MouseButton1Click:Connect(function()
    killAura = not killAura
    if killAura then
        killBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        killBtn.Text = "🐂 CHARGING: ACTIVE"
        statusLabel.Text = "Status: CHARGING ACTIVE!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        killBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        killBtn.Text = "🐂 CHARGE AURA"
        statusLabel.Text = "Status: AUTO ATTACK ON"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end)

chargeBtn.MouseButton1Click:Connect(function()
    collecting = not collecting
    if collecting then
        chargeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        chargeBtn.Text = "⚡ POWER BOOST: ON"
        statusLabel.Text = "Status: COLLECTING ITEMS"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    else
        chargeBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        chargeBtn.Text = "⚡ POWER BOOST"
        statusLabel.Text = "Status: AUTO ATTACK ON"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if speedOn then
            speedBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            speedBtn.Text = "💨 SPEED: TURBO"
            player.Character.Humanoid.WalkSpeed = DESIRED_SPEED
            statusLabel.Text = "Status: TURBO SPEED ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        else
            speedBtn.BackgroundColor3 = Color3.new(0, 0, 0)
            speedBtn.Text = "💨 SPEED"
            player.Character.Humanoid.WalkSpeed = 16
            statusLabel.Text = "Status: AUTO ATTACK ON"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        end
    end
end)

-- ✅ الحفاظ على السرعة عند تغيير الشخصية
player.CharacterAdded:Connect(function(character)
    task.wait(0.3)
    if speedOn and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = DESIRED_SPEED
    end
end)
