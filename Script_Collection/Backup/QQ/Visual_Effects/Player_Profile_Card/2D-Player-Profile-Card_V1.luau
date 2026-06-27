local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer


-- 核心配置
local Config = {
    MaxHUDs = 4,                                 -- 最大同时显示他人卡片数
    MaxDistance = 90,                            -- 探测最大距离
    HysteresisBuffer = 10,                       -- 缓冲距离防止卡片闪烁
    MySnowCount = 20,                            -- 自己卡片的雪花数量
    DevUsername = "此处填写你的名字",                    -- 开发者白名单名字
    
    -- 颜色与样式配置
    BgColor = Color3.fromRGB(255, 255, 255),
    BgTransparency = 0.15,
    TextMain = Color3.fromRGB(30, 30, 35),       
    TextSub = Color3.fromRGB(115, 120, 130),     
    ActiveColor = Color3.fromRGB(25, 25, 30),
    StrokeColor = Color3.fromRGB(255, 255, 255),
    
    MyCardBg = Color3.fromRGB(10, 10, 18),        
    MyCardStroke = Color3.fromRGB(180, 220, 255),  
    DevCardBg = Color3.fromRGB(25, 10, 15),       
    DevCardStroke = Color3.fromRGB(255, 100, 150),
    
    -- 动画平滑度
    ShoulderSwitch = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
}

-- 实时控制开关（需要自行对接你的UI开关）
_G.HUDFeatureStates = {
    ShowSelfHUD = true,       -- 是否显示自己的卡片
    ShowOthersHUD = true      -- 是否显示他人的卡片
}

local Slots = {}

--基础工具函数

local function getAbsoluteAvatar(userId)
    return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId or 0) .. "&w=150&h=150"
end

local function isDeveloper(username)
    return string.lower(username) == string.lower(Config.DevUsername)
end


 视线探测算法
local function getOptimalShoulderOffset(character, camera)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.new(2.8, 1.2, -0.6), "Right" end
    local rightVec = hrp.CFrame.RightVector
    local leftPos = hrp.Position - (rightVec * 2.2)
    local rightPos = hrp.Position + (rightVec * 2.2)
    local camPos = camera.CFrame.Position
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {character, localPlayer.Character}
    
    local rayLeft = Workspace:Raycast(leftPos, camPos - leftPos, rayParams)
    local rayRight = Workspace:Raycast(rightPos, camPos - rightPos, rayParams)
    
    if rayRight and not rayLeft then return Vector3.new(-2.8, 1.2, -0.6), "Left"
    elseif rayLeft and not rayRight then return Vector3.new(2.8, 1.2, -0.6), "Right"
    else return Vector3.new(2.8, 1.2, -0.6), "Right" end
end

local function isObstructedFromCamera(camera, targetRoot)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local allCharacters = {}
    for _, p in pairs(Players:GetPlayers()) do if p.Character then table.insert(allCharacters, p.Character) end end
    rayParams.FilterDescendantsInstances = allCharacters
    
    local hitResult = Workspace:Raycast(camera.CFrame.Position, targetRoot.Position - camera.CFrame.Position, rayParams)
    if hitResult and hitResult.Instance and (hitResult.Instance.CanCollide or hitResult.Instance:IsA("Terrain")) then return true end
    return false
end

-- 个人信息配置
local function createPersonal3DHUD()
    local my3DHUD = Instance.new("BillboardGui")
    my3DHUD.Name = "MyPersonal3DHUD"
    my3DHUD.Size = UDim2.new(3.5, 0, 1.4, 0)             
    my3DHUD.AlwaysOnTop = true 
    my3DHUD.ResetOnSpawn = false
    my3DHUD.Enabled = false
    my3DHUD.Parent = CoreGui

    local myFrame = Instance.new("CanvasGroup")
    myFrame.Name = "HUDFrame"
    myFrame.Size = UDim2.new(1, 0, 1, 0) 
    myFrame.BorderSizePixel = 0
    myFrame.Parent = my3DHUD
    Instance.new("UICorner", myFrame).CornerRadius = UDim.new(0, 8)

    local myStroke = Instance.new("UIStroke", myFrame)
    myStroke.Thickness = 1.2
    myStroke.Transparency = 0.3

    if isDeveloper(localPlayer.Name) then
        myFrame.BackgroundColor3 = Config.DevCardBg
        myStroke.Color = Config.DevCardStroke
    else
        myFrame.BackgroundColor3 = Config.MyCardBg
        myStroke.Color = Config.MyCardStroke
    end

    -- 雪花背景
    local mySnowContainer = Instance.new("Frame")
    mySnowContainer.Size = UDim2.new(1, 0, 1, 0)
    mySnowContainer.BackgroundTransparency = 1
    mySnowContainer.ClipsDescendants = true
    mySnowContainer.Parent = myFrame

    for i = 1, Config.MySnowCount do
        local flake = Instance.new("Frame")
        flake.Size = UDim2.new(0, 4, 0, 4)
        flake.Position = UDim2.new(math.random(), 0, math.random(), 0)
        flake.BackgroundColor3 = Color3.fromRGB(240, 250, 255)
        flake.BackgroundTransparency = math.random(3, 7) * 0.1
        flake.Parent = mySnowContainer
        Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)
        
        local speed = math.random(5, 10) * 0.003
        task.spawn(function()
            while flake and flake.Parent do
                flake.Position = UDim2.new(flake.Position.X.Scale, 0, flake.Position.Y.Scale + speed, 0)
                if flake.Position.Y.Scale > 1 then flake.Position = UDim2.new(math.random(), 0, -0.05, 0) end
                task.wait(0.03)
            end
        end)
    end

    local myAvatarImage = Instance.new("ImageLabel")
    myAvatarImage.Name = "AvatarImage"
    myAvatarImage.Size = UDim2.new(0.22, 0, 0.65, 0)
    myAvatarImage.Position = UDim2.new(0, 8, 0.175, 0)
    myAvatarImage.BackgroundTransparency = 1
    myAvatarImage.Image = getAbsoluteAvatar(localPlayer.UserId) 
    myAvatarImage.Parent = myFrame
    Instance.new("UICorner", myAvatarImage).CornerRadius = UDim.new(1, 0)

    local myAvStroke = Instance.new("UIStroke", myAvatarImage)
    myAvStroke.Thickness = 1
    myAvStroke.Color = isDeveloper(localPlayer.Name) and Config.DevCardStroke or Config.MyCardStroke
    myAvStroke.Transparency = 0.4

    local myNameLabel = Instance.new("TextLabel")
    myNameLabel.Size = UDim2.new(0.72, -12, 0.26, 0)
    myNameLabel.Position = UDim2.new(0.26, 6, 0.12, 0)
    myNameLabel.BackgroundTransparency = 1
    myNameLabel.Text = (isDeveloper(localPlayer.Name) and "🛠️ " or "👑 ") .. localPlayer.DisplayName
    myNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    myNameLabel.TextScaled = true
    myNameLabel.Font = Enum.Font.GothamBold
    myNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    myNameLabel.Parent = myFrame

    local myTagLabel = Instance.new("TextLabel")
    myTagLabel.Size = UDim2.new(0.72, -12, 0.18, 0)
    myTagLabel.Position = UDim2.new(0.26, 6, 0.45, 0)
    myTagLabel.BackgroundTransparency = 1
    myTagLabel.Text = isDeveloper(localPlayer.Name) and "🔥 FOUNDER / DEVELOPER" or "✨ TACTICAL LIGHTING"
    myTagLabel.TextColor3 = isDeveloper(localPlayer.Name) and Color3.fromRGB(255, 120, 150) or Color3.fromRGB(160, 210, 255)
    myTagLabel.TextScaled = true
    myTagLabel.Font = Enum.Font.GothamBold
    myTagLabel.TextXAlignment = Enum.TextXAlignment.Left
    myTagLabel.Parent = myFrame

    local myStatusLabel = Instance.new("TextLabel")
    myStatusLabel.Size = UDim2.new(0.72, -12, 0.16, 0)
    myStatusLabel.Position = UDim2.new(0.26, 6, 0.72, 0)
    myStatusLabel.BackgroundTransparency = 1
    myStatusLabel.Text = "❤️ HEALTH: --%"
    myStatusLabel.TextColor3 = Color3.fromRGB(255, 110, 110)
    myStatusLabel.TextScaled = true
    myStatusLabel.Font = Enum.Font.Code
    myStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    myStatusLabel.Parent = myFrame

    return my3DHUD, myStatusLabel
end
--普通卡片对象池
local function buildOthersHUDInstancePool()
    for i = 1, Config.MaxHUDs do
        local bGui = Instance.new("BillboardGui")
        bGui.Name = "SlotHUD_" .. i
        bGui.Size = UDim2.new(3.2, 0, 1.2, 0) 
        bGui.AlwaysOnTop = true 
        bGui.MaxDistance = Config.MaxDistance + Config.HysteresisBuffer 
        bGui.Enabled = false 
        bGui.Parent = CoreGui
        
        local frame = Instance.new("CanvasGroup")
        frame.Name = "HUDFrame"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BorderSizePixel = 0
        frame.Parent = bGui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        
        local slotStroke = Instance.new("UIStroke", frame)
        slotStroke.Thickness = 1
        
        local playerAvatar = Instance.new("ImageLabel")
        playerAvatar.Name = "PlayerAvatar"
        playerAvatar.Size = UDim2.new(0.2, 0, 0.6, 0)
        playerAvatar.Position = UDim2.new(0, 6, 0.2, 0)
        playerAvatar.BackgroundTransparency = 1
        playerAvatar.Parent = frame
        Instance.new("UICorner", playerAvatar).CornerRadius = UDim.new(1, 0)
        local paStroke = Instance.new("UIStroke", playerAvatar)
        paStroke.Thickness = 1
        paStroke.Transparency = 0.4
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.76, -10, 0.24, 0)
        nameLabel.Position = UDim2.new(0.24, 6, 0.1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = frame
        
        local healthBg = Instance.new("Frame")
        healthBg.Name = "HealthBg"
        healthBg.Size = UDim2.new(0.76, -10, 0.06, 0)
        healthBg.Position = UDim2.new(0.24, 6, 0.42, 0)
        healthBg.BackgroundTransparency = 0.88
        healthBg.Parent = frame
        
        local healthBar = Instance.new("Frame")
        healthBar.Name = "Bar"
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthBg
        
        local inventoryLabel = Instance.new("TextLabel")
        inventoryLabel.Name = "InventoryLabel"
        inventoryLabel.Size = UDim2.new(0.76, -10, 0.32, 0)
        inventoryLabel.Position = UDim2.new(0.24, 6, 0.58, 0)
        inventoryLabel.BackgroundTransparency = 1
        inventoryLabel.TextScaled = true
        inventoryLabel.Font = Enum.Font.Gotham
        inventoryLabel.TextXAlignment = Enum.TextXAlignment.Left
        inventoryLabel.Parent = frame
        
        Slots[i] = {Gui = bGui, Frame = frame, Stroke = slotStroke, PaStroke = paStroke, CurrentSide = nil, LastTarget = nil}
    end
end
local function startHUDHeartbeat(my3DHUD, myStatusLabel)
    task.spawn(function()
        local myCurrentSide = nil
        
        while task.wait(0.05) do
            local camera = Workspace.CurrentCamera
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar and myChar:FindFirstChild("Humanoid")
            
            if camera and myRoot and myHum then
                local camPosition = camera.CFrame.Position
                
                -- 渲染 --
                local _, myInViewport = camera:WorldToScreenPoint(myRoot.Position)
                local myValid = _G.HUDFeatureStates.ShowSelfHUD and myInViewport and (camPosition - myRoot.Position).Magnitude <= (Config.MaxDistance + Config.HysteresisBuffer) and not isObstructedFromCamera(camera, myRoot)
                
                if myValid then
                    my3DHUD.Adornee = myRoot
                    my3DHUD.Enabled = true
                    myStatusLabel.Text = "❤️ HEALTH: " .. tostring(math.clamp(math.floor((myHum.Health / myHum.MaxHealth) * 100), 0, 100)) .. "%"
                    
                    local targetOffset, side = getOptimalShoulderOffset(myChar, camera)
                    if myCurrentSide ~= side then 
                        myCurrentSide = side
                        TweenService:Create(my3DHUD, Config.ShoulderSwitch, {StudsOffsetWorldSpace = targetOffset}):Play() 
                    end
                else
                    my3DHUD.Enabled = false
                end
                
                -- ---- 其他玩家同步与动态插槽分配 ----
                local validTargets = {}
                local currentMappedSlots = {}
                for i = 1, Config.MaxHUDs do if Slots[i].LastTarget then currentMappedSlots[Slots[i].LastTarget] = i end end
                
                if _G.HUDFeatureStates.ShowOthersHUD then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                            local tChar = player.Character; local tRoot = tChar.HumanoidRootPart; local hum = tChar.Humanoid
                            if hum.Health > 0 then
                                local _, inViewport = camera:WorldToScreenPoint(tRoot.Position)
                                if inViewport and (camPosition - tRoot.Position).Magnitude <= (currentMappedSlots[player] and (Config.MaxDistance + Config.HysteresisBuffer) or Config.MaxDistance) and not isObstructedFromCamera(camera, tRoot) then
                                    table.insert(validTargets, {player = player, char = tChar, root = tRoot, hum = hum, dist = (camPosition - tRoot.Position).Magnitude})
                                end
                            end
                        end
                    end
                end
                
                local nextSlotAllocations = {}
                local remainingTargets = {}
                for _, targetData in ipairs(validTargets) do
                    local oldSlotIndex = currentMappedSlots[targetData.player]
                    if oldSlotIndex and not nextSlotAllocations[oldSlotIndex] then nextSlotAllocations[oldSlotIndex] = targetData else table.insert(remainingTargets, targetData) end
                end
                table.sort(remainingTargets, function(a, b) return a.dist < b.dist end)
                for i = 1, Config.MaxHUDs do if not nextSlotAllocations[i] and #remainingTargets > 0 then nextSlotAllocations[i] = table.remove(remainingTargets, 1) end end
                
                -- 分配插槽刷新
                for i = 1, Config.MaxHUDs do
                    local slot = Slots[i]; local gui = slot.Gui; local frame = slot.Frame; local data = nextSlotAllocations[i]
                    if data and _G.HUDFeatureStates.ShowOthersHUD then
                        gui.Adornee = data.root
                        gui.Enabled = true
                        local targetOffset, side = getOptimalShoulderOffset(data.char, camera)
                        if slot.CurrentSide ~= side then 
                            slot.CurrentSide = side
                            TweenService:Create(gui, Config.ShoulderSwitch, {StudsOffsetWorldSpace = targetOffset}):Play() 
                        end
                        
                        if isDeveloper(data.player.Name) then
                            frame.BackgroundColor3 = Config.DevCardBg; frame.BackgroundTransparency = 0.15
                            slot.Stroke.Color = Config.DevCardStroke; slot.PaStroke.Color = Config.DevCardStroke
                            frame.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255); frame.NameLabel.Text = "🛠️ " .. data.player.DisplayName
                            frame.HealthBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255); frame.HealthBg.Bar.BackgroundColor3 = Config.DevCardStroke
                            frame.InventoryLabel.Text = "⚡ [ CORE DEVELOPER ]"; frame.InventoryLabel.TextColor3 = Color3.fromRGB(255, 180, 200)
                        else
                            frame.BackgroundColor3 = Config.BgColor; frame.BackgroundTransparency = Config.BgTransparency
                            slot.Stroke.Color = Config.StrokeColor; slot.PaStroke.Color = Config.StrokeColor
                            frame.NameLabel.TextColor3 = Config.TextMain; frame.NameLabel.Text = data.player.DisplayName
                            frame.HealthBg.BackgroundColor3 = Config.ActiveColor; frame.HealthBg.Bar.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                            local tool = data.char:FindFirstChildOfClass("Tool")
                            frame.InventoryLabel.Text = tool and ("⚡ " .. tool.Name) or "[ UNARMED ]"; frame.InventoryLabel.TextColor3 = Config.TextSub
                        end
                        
                        if slot.LastTarget ~= data.player then
                            slot.LastTarget = data.player; frame.PlayerAvatar.Image = getAbsoluteAvatar(data.player.UserId)
                        end
                        frame.HealthBg.Bar.Size = UDim2.new(math.clamp(data.hum.Health / data.hum.MaxHealth, 0, 1), 0, 1, 0)
                    else
                        gui.Enabled = false; gui.Adornee = nil; slot.CurrentSide = nil; slot.LastTarget = nil
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 初始化
-- ==========================================
local function InitializeHUDSystem()
    -- 历史残留
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "MyPersonal3DHUD" or v.Name:sub(1, 8) == "SlotHUD_" then v:Destroy() end
    end
    
    -- UI与对象
    local my3DHUD, myStatusLabel = createPersonal3DHUD()
    buildOthersHUDInstancePool()
    

    startHUDHeartbeat(my3DHUD, myStatusLabel)
end

InitializeHUDSystem()