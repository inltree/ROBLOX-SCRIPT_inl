local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local targetParent = CoreGui:FindFirstChild("RobloxGui") or localPlayer:WaitForChild("PlayerGui")

-- 清理历史残留
if targetParent:FindFirstChild("QuantumPersonalHub") then targetParent.QuantumPersonalHub:Destroy() end
for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "MyPersonal3DHUD" or v.Name:sub(1, 8) == "SlotHUD_" then v:Destroy() end
end
local Config = {
        WindowSize = UDim2.new(0, 480, 0, 280),      
        IslandSize = UDim2.new(0, 150, 0, 30),

        BgColor = Color3.fromRGB(255, 255, 255),    
        BgTransparency = 0.15,          

        CardColor = Color3.fromRGB(255, 255, 255),   
        CardTransparency = 0.7,                     

        StrokeColor = Color3.fromRGB(255, 255, 255), 
        ActiveColor = Color3.fromRGB(25, 25, 30),    
        TextMain = Color3.fromRGB(30, 30, 35),       
        TextSub = Color3.fromRGB(115, 120, 130),     
        AccentColor = Color3.fromRGB(0, 122, 255),   

        --  个人/普通卡片样式
        MyCardBg = Color3.fromRGB(10, 10, 18),        
        MyCardStroke = Color3.fromRGB(180, 220, 255),  
        MySnowCount = 20,                             

        --  专属开发者白名单配置
        DevUsername = "NayuemiA",
        DevCardBg = Color3.fromRGB(25, 10, 15),       
        DevCardStroke = Color3.fromRGB(255, 100, 150),

        -- 距离动态配置
        MaxHUDs = 4,                                 
        MaxDistance = 90,       
        HysteresisBuffer = 10,  

        LinearSmooth = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        ShoulderSwitch = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        ButtonBounce = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}
local FeatureStates = {
        ShowSelfHUD = true,       -- 控制自己卡片
        ShowOthersHUD = true,     -- 控制他人卡片
        ShowSelfHighlight = true, -- 高亮边缘
        EnableBackgroundBlur = true -- 全局模糊
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuantumPersonalHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetParent

local modalModal = Instance.new("TextButton") 
modalModal.Name = "ModalBackdrop"
modalModal.Size = UDim2.new(1, 0, 1, 0)
modalModal.BackgroundTransparency = 1 
modalModal.Text = ""
modalModal.Active = true 
modalModal.Parent = screenGui

local function getAbsoluteAvatar(userId)
        return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId or 0) .. "&w=150&h=150"
end

local function isDeveloper(username)
        return string.lower(username) == string.lower(Config.DevUsername)
end
local function applySelfHighlight(character)
        if not character then return end
        local oldHighlight = character:FindFirstChild("SelfTacticalOutline")
        if oldHighlight then oldHighlight:Destroy() end

        if not FeatureStates.ShowSelfHighlight then return end -- 如果被关闭则不创建

        local highlight = Instance.new("Highlight")
        highlight.Name = "SelfTacticalOutline"
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 1.0            
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
        highlight.OutlineTransparency = 0.15          
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
        highlight.Parent = character
end

localPlayer.CharacterAdded:Connect(applySelfHighlight)
if localPlayer.Character then applySelfHighlight(localPlayer.Character) end
local canvas = Instance.new("CanvasGroup")
canvas.Name = "MainCanvas"
canvas.Size = Config.WindowSize 
canvas.Position = UDim2.new(0.5, -240, 0.4, -140)
canvas.BackgroundColor3 = Config.BgColor
canvas.BackgroundTransparency = Config.BgTransparency
canvas.GroupTransparency = 1 
canvas.BorderSizePixel = 0
canvas.Parent = screenGui 
Instance.new("UICorner", canvas).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", canvas)
mainStroke.Thickness = 1.2
mainStroke.Color = Config.StrokeColor
mainStroke.Transparency = 0.25

local topBar = Instance.new("Frame")
topBar.Name = "TopBarHandle"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1 
topBar.Active = true 
topBar.Parent = canvas

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TACTICAL INTERFACE"
title.TextColor3 = Config.TextMain
title.TextSize = 11
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local topSep = Instance.new("Frame", topBar)
topSep.Size = UDim2.new(1, -32, 0, 1)
topSep.Position = UDim2.new(0, 16, 1, -1)
topSep.BackgroundColor3 = Config.TextMain
topSep.BackgroundTransparency = 0.92

local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(0, 20, 0, 20)
miniButton.Position = UDim2.new(1, -30, 0, 10)
miniButton.BackgroundColor3 = Config.TextMain
miniButton.BackgroundTransparency = 0.93
miniButton.Text = "✕"
miniButton.TextColor3 = Config.TextMain
miniButton.TextSize = 10
miniButton.Font = Enum.Font.GothamBold
miniButton.Parent = topBar
Instance.new("UICorner", miniButton).CornerRadius = UDim.new(1, 0)

local islandBar = Instance.new("TextButton")
islandBar.Name = "DynamicIsland"
islandBar.Size = Config.IslandSize
islandBar.Position = UDim2.new(0.5, -75, 0, -40) 
islandBar.BackgroundColor3 = Config.BgColor
islandBar.BackgroundTransparency = 0.1
islandBar.Text = "⚡ TACTICAL HUB" 
islandBar.TextColor3 = Config.TextMain
islandBar.TextSize = 10
islandBar.Font = Enum.Font.GothamBold
islandBar.Visible = false
islandBar.Parent = screenGui
Instance.new("UICorner", islandBar).CornerRadius = UDim.new(1, 0)
local islandStroke = Instance.new("UIStroke", islandBar)
islandStroke.Color = Config.StrokeColor

local mainBody = Instance.new("Frame")
mainBody.Name = "MainBody"
mainBody.Size = UDim2.new(1, -32, 1, -56)
mainBody.Position = UDim2.new(0, 16, 0, 48)
mainBody.BackgroundTransparency = 1
mainBody.Parent = canvas

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 100, 1, 0)
sidebar.BackgroundTransparency = 1
sidebar.Parent = mainBody

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -112, 1, 0)
contentArea.Position = UDim2.new(0, 112, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainBody

local tabs = {}
local tabButtons = {}
local currentTab = nil

local function createTab(id, name)
        local panel = Instance.new("Frame")
        panel.Name = id .. "Panel"
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.BackgroundTransparency = 1
        panel.Visible = false
        panel.Parent = contentArea

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 1 
        btn.Text = " " .. name
        btn.TextColor3 = Config.TextSub
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Config.StrokeColor
        btnStroke.Thickness = 1
        btnStroke.Transparency = 1

        btn.MouseButton1Click:Connect(function()
                if currentTab and tabs[currentTab] then
                        tabs[currentTab].Visible = false
                        TweenService:Create(tabButtons[currentTab], Config.ButtonBounce, {BackgroundTransparency = 1, TextColor3 = Config.TextSub}):Play()
                        TweenService:Create(tabButtons[currentTab]:FindFirstChildOfClass("UIStroke"), Config.ButtonBounce, {Transparency = 1}):Play()
                end
                currentTab = id
                panel.Visible = true

                TweenService:Create(btn, Config.ButtonBounce, {BackgroundTransparency = 0.5, BackgroundColor3 = Config.CardColor, TextColor3 = Config.AccentColor}):Play()
                TweenService:Create(btnStroke, Config.ButtonBounce, {Transparency = 0.5}):Play()
        end)

        tabs[id] = panel
        tabButtons[id] = btn
        return panel
end
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
local Slots = {} 
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
        inventoryLabel.Size = UDim2.new(0.76, -24, 0.32, 0) 
        inventoryLabel.Position = UDim2.new(0.24, 6, 0.58, 0)
        inventoryLabel.BackgroundTransparency = 1
        inventoryLabel.TextScaled = false 
        inventoryLabel.TextSize = 10
        inventoryLabel.Font = Enum.Font.Gotham
        inventoryLabel.TextXAlignment = Enum.TextXAlignment.Left
        inventoryLabel.Parent = frame

       
        local expandBtn = Instance.new("TextButton")
        expandBtn.Name = "ExpandBtn"
        expandBtn.Size = UDim2.new(0, 14, 0, 14)
        expandBtn.Position = UDim2.new(1, -18, 1, -18)
        expandBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        expandBtn.BackgroundTransparency = 0.3
        expandBtn.Text = "＋"
        expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        expandBtn.TextSize = 9
        expandBtn.Font = Enum.Font.GothamBold
        expandBtn.Visible = false 
        expandBtn.Parent = frame
        Instance.new("UICorner", expandBtn).CornerRadius = UDim.new(1, 0)

        local isExpanded = false
        expandBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
                if isExpanded then
                        expandBtn.Text = "－"
                        inventoryLabel.TextWrapped = true 
                        inventoryLabel.Size = UDim2.new(0.76, -24, 0.55, 0) 
                        TweenService:Create(bGui, Config.ButtonBounce, {Size = UDim2.new(3.2, 0, 1.6, 0)}):Play() 
                else
                        expandBtn.Text = "＋"
                        inventoryLabel.TextWrapped = false
                        inventoryLabel.Size = UDim2.new(0.76, -24, 0.32, 0)
                        TweenService:Create(bGui, Config.ButtonBounce, {Size = UDim2.new(3.2, 0, 1.2, 0)}):Play()
                end
        end)

        Slots[i] = {
                Gui = bGui, 
                Frame = frame, 
                Stroke = slotStroke, 
                PaStroke = paStroke, 
                CurrentSide = nil, 
                LastTarget = nil,
                ExpandBtn = expandBtn,
                InventoryLabel = inventoryLabel,
                GetExpanded = function() return isExpanded end,
                ResetExpand = function() 
                        isExpanded = false
                        expandBtn.Text = "＋"
                        inventoryLabel.TextWrapped = false
                        inventoryLabel.Size = UDim2.new(0.76, -24, 0.32, 0)
                        bGui.Size = UDim2.new(3.2, 0, 1.2, 0)
                end
        }
end
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
task.spawn(function()
        local myCurrentSide = nil

        while task.wait(0.05) do
                local camera = Workspace.CurrentCamera
                local myChar = localPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHum = myChar and myChar:FindFirstChild("Humanoid")

                if camera and myRoot and myHum then
                        local camPosition = camera.CFrame.Position

                        
                        local _, myInViewport = camera:WorldToScreenPoint(myRoot.Position)
                        local myValid = FeatureStates.ShowSelfHUD and myInViewport and (camPosition - myRoot.Position).Magnitude <= (Config.MaxDistance + Config.HysteresisBuffer) and not isObstructedFromCamera(camera, myRoot)

                        if myValid then
                                my3DHUD.Adornee = myRoot;
                                my3DHUD.Enabled = true
                                myStatusLabel.Text = "❤️ HEALTH: " .. tostring(math.clamp(math.floor((myHum.Health / myHum.MaxHealth) * 100), 0, 100)) .. "%"

                                local targetOffset, side = getOptimalShoulderOffset(myChar, camera)
                                if myCurrentSide ~= side then myCurrentSide = side;
                                TweenService:Create(my3DHUD, Config.ShoulderSwitch, {StudsOffsetWorldSpace = targetOffset}):Play() end
                        else
                                my3DHUD.Enabled = false
                        end

                      
                        local validTargets = {}
                        local currentMappedSlots = {}
                        for i = 1, Config.MaxHUDs do if Slots[i].LastTarget then currentMappedSlots[Slots[i].LastTarget] = i end end

                        if FeatureStates.ShowOthersHUD then
                                for _, player in pairs(Players:GetPlayers()) do
                                        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                                                local tChar = player.Character;
                                                local tRoot = tChar.HumanoidRootPart; local hum = tChar.Humanoid
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

                        for i = 1, Config.MaxHUDs do
                                local slot = Slots[i]; local gui = slot.Gui; local frame = slot.Frame;
                                local data = nextSlotAllocations[i]
                                if data and FeatureStates.ShowOthersHUD then
                                        gui.Adornee = data.root;
                                        gui.Enabled = true
                                        local targetOffset, side = getOptimalShoulderOffset(data.char, camera)
                                        if slot.CurrentSide ~= side then slot.CurrentSide = side;
                                        TweenService:Create(gui, Config.ShoulderSwitch, {StudsOffsetWorldSpace = targetOffset}):Play() end

                                        
                                        local tool = data.char:FindFirstChildOfClass("Tool")
                                        local toolName = tool and tool.Name or "UNARMED"

                                     
                                        if string.len(toolName) > 10 then
                                                slot.ExpandBtn.Visible = true 
                                                if not slot.GetExpanded() then
                                                        slot.InventoryLabel.TextSize = 8
                                                else
                                                        slot.InventoryLabel.TextSize = 10
                                                end
                                        else
                                                slot.ExpandBtn.Visible = false 
                                                slot.InventoryLabel.TextSize = 10
                                                if not slot.GetExpanded() then slot.ResetExpand() end
                                        end

                                        if isDeveloper(data.player.Name) then
                                                frame.BackgroundColor3 = Config.DevCardBg; frame.BackgroundTransparency = 0.15
                                                slot.Stroke.Color = Config.DevCardStroke; slot.PaStroke.Color = Config.DevCardStroke
                                                frame.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255); frame.NameLabel.Text = "🛠️ " .. data.player.DisplayName
                                                frame.HealthBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                                                frame.HealthBg.Bar.BackgroundColor3 = Config.DevCardStroke
                                                slot.InventoryLabel.Text = "⚡ [ CORE DEVELOPER ]"; slot.InventoryLabel.TextColor3 = Color3.fromRGB(255, 180, 200)
                                        else
                                                frame.BackgroundColor3 = Config.BgColor; frame.BackgroundTransparency = Config.BgTransparency
                                                slot.Stroke.Color = Config.StrokeColor; slot.PaStroke.Color = Config.StrokeColor
                                                frame.NameLabel.TextColor3 = Config.TextMain; frame.NameLabel.Text = data.player.DisplayName
                                                frame.HealthBg.BackgroundColor3 = Config.ActiveColor;
                                                frame.HealthBg.Bar.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                                                slot.InventoryLabel.Text = tool and ("⚡ " .. toolName) or "[ UNARMED ]";
                                                slot.InventoryLabel.TextColor3 = Config.TextSub
                                        end

                                        if slot.LastTarget ~= data.player then
                                                slot.LastTarget = data.player; frame.PlayerAvatar.Image = getAbsoluteAvatar(data.player.UserId)
                                        end
                                        frame.HealthBg.Bar.Size = UDim2.new(math.clamp(data.hum.Health / data.hum.MaxHealth, 0, 1), 0, 1, 0)
                                else
                                        gui.Enabled = false;
                                        gui.Adornee = nil; slot.CurrentSide = nil; slot.LastTarget = nil
                                        slot.ResetExpand()
                                end
                        end
                end
        end
end)
local panelOverview = createTab("overview", "HUD PANEL")
local panelSettings = createTab("settings", "VISUAL CONFIG")

local function createGridCard(parent, titleText, size, position)
        local card = Instance.new("Frame", parent)
        card.Size = size;
        card.Position = position; card.BackgroundColor3 = Config.CardColor; card.BackgroundTransparency = Config.CardTransparency
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local cardStroke = Instance.new("UIStroke", card)
        cardStroke.Color = Config.StrokeColor;
        cardStroke.Thickness = 1; cardStroke.Transparency = 0.55

        local cardTitle = Instance.new("TextLabel", card)
        cardTitle.Size = UDim2.new(1, -16, 0, 20);
        cardTitle.Position = UDim2.new(0, 10, 0, 4); cardTitle.BackgroundTransparency = 1
        cardTitle.Text = titleText; cardTitle.TextColor3 = Config.AccentColor; cardTitle.TextSize = 9; cardTitle.Font = Enum.Font.GothamBold;
        cardTitle.TextXAlignment = Enum.TextXAlignment.Left

        local container = Instance.new("Frame", card)
        container.Size = UDim2.new(1, -20, 1, -26); container.Position = UDim2.new(0, 10, 0, 22);
        container.BackgroundTransparency = 1
        return container
end

local cCore = createGridCard(panelOverview, "CORE RESOLVER", UDim2.new(0.5, -4, 0.45, 0), UDim2.new(0, 0, 0, 0))
local coreList = Instance.new("UIListLayout", cCore);
coreList.Padding = UDim.new(0, 2)
local function addStatusRow(parent, label, value)
        local row = Instance.new("TextLabel", parent)
        row.Size = UDim2.new(1, 0, 0, 14); row.BackgroundTransparency = 1;
        row.Text = "• " .. label .. ": " .. value
        row.TextColor3 = Config.TextMain; row.TextSize = 10; row.Font = Enum.Font.Code;
        row.TextXAlignment = Enum.TextXAlignment.Left
end
addStatusRow(cCore, "STYLE", "ACRYLIC PURE v2")
addStatusRow(cCore, "BYPASS", "ACTIVE")
addStatusRow(cCore, "OWN USER", localPlayer.Name)

local cTactical = createGridCard(panelOverview, "IDENTITY CLEARENCE", UDim2.new(0.5, -4, 0.45, 0), UDim2.new(0.5, 4, 0, 0))
local tacList = Instance.new("UIListLayout", cTactical);
tacList.Padding = UDim.new(0, 2)
addStatusRow(cTactical, "DEV_TARGET", Config.DevUsername)
addStatusRow(cTactical, "SELF_IS_DEV", isDeveloper(localPlayer.Name) and "YES (ACTIVE)" or "NO (USER)")
addStatusRow(cTactical, "PRIVILEGE", "STABLE MASKING")

local cNetwork = createGridCard(panelOverview, "TELEMETRY CONSOLE", UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0.5, 0))
local netText = Instance.new("TextLabel", cNetwork)
netText.Size = UDim2.new(1, 0, 1, 0);
netText.BackgroundTransparency = 1
netText.Text = ">> [OK] Matrix clean setup complete without layout flashes.\n>> [OK] Identity listener attached to target: " .. Config.DevUsername .. "\n>> [SYSTEM] Config Page attached to main body."
netText.TextColor3 = Config.TextSub; netText.TextSize = 10; netText.Font = Enum.Font.Code; netText.TextXAlignment = Enum.TextXAlignment.Left;
netText.TextYAlignment = Enum.TextYAlignment.Top

local cSwitches = createGridCard(panelSettings, "FEATURE INTERFACE PREFERENCE", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
local switchList = Instance.new("UIListLayout", cSwitches)
switchList.Padding = UDim.new(0, 8)

local function createToggleRow(label, key, callback)
        local rowFrame = Instance.new("Frame", cSwitches)
        rowFrame.Size = UDim2.new(1, 0, 0, 32)
        rowFrame.BackgroundTransparency = 1

        local text = Instance.new("TextLabel", rowFrame)
        text.Size = UDim2.new(0.7, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "⚙️ " .. label
        text.TextColor3 = Config.TextMain
        text.TextSize = 11
        text.Font = Enum.Font.GothamBold
        text.TextXAlignment = Enum.TextXAlignment.Left

        local toggleBtn = Instance.new("TextButton", rowFrame)
        toggleBtn.Size = UDim2.new(0, 48, 0, 22)
        toggleBtn.Position = UDim2.new(1, -48, 0.5, -11)
        toggleBtn.BackgroundColor3 = FeatureStates[key] and Config.AccentColor or Color3.fromRGB(200, 202, 205)
        toggleBtn.Text = ""
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

        local pill = Instance.new("Frame", toggleBtn)
        pill.Size = UDim2.new(0, 16, 0, 16)
        pill.Position = FeatureStates[key] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        pill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        toggleBtn.MouseButton1Click:Connect(function()
                FeatureStates[key] = not FeatureStates[key]
                local targetColor = FeatureStates[key] and Config.AccentColor or Color3.fromRGB(200, 202, 205)
                local targetPillPos = FeatureStates[key] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

                TweenService:Create(toggleBtn, Config.ButtonBounce, {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(pill, Config.ButtonBounce, {Position = targetPillPos}):Play()

                if callback then callback(FeatureStates[key]) end
        end)
end

createToggleRow("显示自己肩膀信息卡片 (Show My HUD)", "ShowSelfHUD")
createToggleRow("显示他人肩膀信息卡片 (Show Others HUD)", "ShowOthersHUD")
createToggleRow("开启自身纯白战术高亮 (Tactical Outline)", "ShowSelfHighlight", function(v)
        applySelfHighlight(localPlayer.Character)
end)
createToggleRow("允许展开面板游戏背景模糊 (Blur Engine)", "EnableBackgroundBlur", function(v)
        local existingBlur = Lighting:FindFirstChild("AcrylicGlobalBlur")
        if existingBlur then existingBlur.Size = v and 22 or 0 end
end)

tabButtons["overview"].BackgroundTransparency = 0.5;
tabButtons["overview"].BackgroundColor3 = Config.CardColor; tabButtons["overview"].TextColor3 = Config.AccentColor
tabButtons["overview"]:FindFirstChildOfClass("UIStroke").Transparency = 0.5; tabs["overview"].Visible = true;
currentTab = "overview"
local function updateGlobalBlur(enable)
        local existingBlur = Lighting:FindFirstChild("AcrylicGlobalBlur")
        if enable and FeatureStates.EnableBackgroundBlur then 
                if not existingBlur then 
                        local b = Instance.new("BlurEffect")
                        b.Name = "AcrylicGlobalBlur"
                        b.Size = 22
                        b.Parent = Lighting 
                end
        else 
                if existingBlur then existingBlur:Destroy() end 
        end
end

local function minimize()
        topBar.Visible = false
        mainBody.Visible = false
        updateGlobalBlur(false)
        modalModal.Visible = false 
        local t1 = TweenService:Create(canvas, Config.LinearSmooth, {GroupTransparency = 1})
        t1:Play()
        t1.Completed:Connect(function() 
                canvas.Visible = false
                islandBar.Visible = true
                islandBar.Position = UDim2.new(0.5, -75, 0, -40)
                TweenService:Create(islandBar, Config.LinearSmooth, {Position = UDim2.new(0.5, -75, 0, 15)}):Play() 
        end)
end

local function expand()
        modalModal.Visible = true
        updateGlobalBlur(true) 
        local tIsland = TweenService:Create(islandBar, Config.LinearSmooth, {Position = UDim2.new(0.5, -75, 0, -50)})
        tIsland:Play()
        tIsland.Completed:Connect(function()
                islandBar.Visible = false
                canvas.Visible = true
                canvas.Size = Config.WindowSize
                canvas.Position = UDim2.new(0.5, -240, 0.4, -140)

                local t2 = TweenService:Create(canvas, Config.LinearSmooth, {GroupTransparency = 0})
                t2:Play()
                t2.Completed:Connect(function() 
                        topBar.Visible = true
                        mainBody.Visible = true 
                end)
        end)
end

miniButton.MouseButton1Click:Connect(minimize)
islandBar.MouseButton1Click:Connect(expand)

local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = canvas.Position 
                input.Changed:Connect(function() 
                        if input.UserInputState == Enum.UserInputState.End then 
                                dragging = false 
                        end 
                end)
        end
end)

topBar.InputChanged:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
                dragInput = input 
        end 
end)

UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
                local delta = input.Position - dragStart
                TweenService:Create(canvas, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                }):Play()
        end
end)

expand()