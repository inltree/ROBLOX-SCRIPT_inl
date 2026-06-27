if getgenv().QuantumHUD_Running then
    pcall(function()
        game:GetService("RunService"):UnbindFromRenderStep("Quantum_Stationary_Engine")
        local legacy = game:GetService("Workspace"):FindFirstChild("QUANTUM_STATIONARY_STORAGE")
        if legacy then legacy:Destroy() end
    end)
end
getgenv().QuantumHUD_Running = true

getgenv().LaunchQuantumGraphicsPipeline = function(customConfig)
    customConfig = customConfig or {}
    
    local QuantumHUD = {}
    QuantumHUD.__index = QuantumHUD

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting") 

    -- 默认参数
    function QuantumHUD.new()
        local self = setmetatable({}, QuantumHUD)
        
        self.Config = {
            MaxHUDs = customConfig.MaxHUDs or 5,                                       
            MaxDistance = customConfig.MaxDistance or 110,                                 
            StorageName = "QUANTUM_STATIONARY_STORAGE",
            
            BodyReflectance = customConfig.BodyReflectance or 0.15,   
            HeadReflectance = customConfig.HeadReflectance or 0.01,   
            LightBrightness = customConfig.LightBrightness or 0.45,   
            LightRange = customConfig.LightRange or 11.0,             
            OutlineTransparency = customConfig.OutlineTransparency or 0.05, 
            
            PinkGlassBg = Color3.fromRGB(255, 230, 238),      
            PinkGlassStroke = Color3.fromRGB(255, 230, 238), 
            MyCardBg = Color3.fromRGB(45, 15, 22),             
            MyCardStroke = Color3.fromRGB(45, 15, 22),       
            
            HealthBarProgressColor = Color3.fromRGB(255, 120, 160), 
            HealthBarContainerColor = Color3.fromRGB(255, 255, 255), 
            
            TextHDMain = Color3.fromRGB(255, 255, 255),        
            TextHDSub = Color3.fromRGB(255, 190, 210),         
            ShadowColor = Color3.fromRGB(20, 5, 10),           
            
            CardSize = Vector3.new(4.6, 1.75, 0.05),            
            ShoulderHeight = 1.6,                             
            EyeSeparation = 4.3,                               
            ViewAngleThreshold = 0.12,
            
            BaseStiffness = 18.5,     
            FluidDragCoeff = 0.25,    
            ParallaxIntensity = 0.35, 
            MicroVibeFreq = 8.5       
        }

        self.LocalPlayer = Players.LocalPlayer
        self.Slots = {}
        self.IsRunning = false
        self.StorageFolder = nil
        
        self.MyFluidState = { Position = Vector3.new(), Velocity = Vector3.new(), Rotation = Vector3.new() }
        self.SlotFluidStates = {}
        self.GlobalCurrentAlpha = 1.0                          
        return self
    end

    -- 物理引擎 
    function QuantumHUD:_updateFluidEngine(state, targetPos, dt)
        local displacement = state.Position - targetPos
        local distance = displacement.Magnitude
        local dynamicDamping = 0.45 + math.clamp(1 / (distance + 0.1), 0, 1.8)
        
        local springForce = -self.Config.BaseStiffness * displacement
        local baseDampingForce = -dynamicDamping * state.Velocity
        local fluidDragForce = -state.Velocity.Unit * (state.Velocity.Magnitude ^ 2) * self.Config.FluidDragCoeff
        
        if state.Velocity.Magnitude == 0 then fluidDragForce = Vector3.new() end
        local acceleration = springForce + baseDampingForce + fluidDragForce
        
        state.Velocity = state.Velocity + acceleration * dt
        state.Position = state.Position + state.Velocity * dt
        return state.Position
    end
    
    -- 视线检测 
    function QuantumHUD:_isTargetVisibleThroughCover(camera, myChar, targetChar, targetRoot)
        if not myChar or not targetChar then return false end
        
        local raycastParams = RaycastParams.new()
        local ignoreList = {myChar, targetChar}
        if self.StorageFolder then table.insert(ignoreList, self.StorageFolder) end
        raycastParams.FilterDescendantsInstances = ignoreList
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local camPos = camera.CFrame.Position
        local checkPoints = { targetRoot.Position }
        
        local head = targetChar:FindFirstChild("Head")
        if head then table.insert(checkPoints, head.Position) end
        
        local leftLeg = targetChar:FindFirstChild("Left Leg") or targetChar:FindFirstChild("LeftLowerLeg")
        if leftLeg then table.insert(checkPoints, leftLeg.Position) end
        
        local rightLeg = targetChar:FindFirstChild("Right Leg") or targetChar:FindFirstChild("RightLowerLeg")
        if rightLeg then table.insert(checkPoints, rightLeg.Position) end
        
        for _, point in ipairs(checkPoints) do
            local direction = point - camPos
            local result = Workspace:Raycast(camPos, direction, raycastParams)
            if not result then return true end
        end
        return false
    end

    -- 清理残留
    function QuantumHUD:PurgeLegacyPipelines()
        pcall(function() RunService:UnbindFromRenderStep("Quantum_Stationary_Engine") end)
        local legacy = Workspace:FindFirstChild(self.Config.StorageName)
        if legacy then pcall(function() legacy:Destroy() end) task.wait(0.02) end
    end

    -- 玻璃容器
    function QuantumHUD:_buildGlassContainer(name)
        if not self.StorageFolder then
            self.StorageFolder = Workspace:FindFirstChild(self.Config.StorageName) or Instance.new("Folder")
            self.StorageFolder.Name = self.Config.StorageName
            self.StorageFolder.Parent = Workspace
        end

        local masterPart = Instance.new("Part")
        masterPart.Name = "ST_Master_" .. name
        masterPart.Size = self.Config.CardSize
        masterPart.Transparency = 1
        masterPart.CanCollide = false; masterPart.CanTouch = false; masterPart.CanQuery = false
        masterPart.Anchored = true
        masterPart.Parent = self.StorageFolder

        local blurFilter = Instance.new("Part")
        blurFilter.Name = "GlassBlurFilter"
        blurFilter.Size = Vector3.new(self.Config.CardSize.X - 0.02, self.Config.CardSize.Y - 0.02, 0.01)
        blurFilter.Material = Enum.Material.Glass
        blurFilter.Transparency = 1 
        blurFilter.Color = self.Config.PinkGlassBg
        blurFilter.CanCollide = false; blurFilter.CanTouch = false; blurFilter.CanQuery = false
        blurFilter.Anchored = true
        blurFilter.Parent = masterPart

        return masterPart
    end

    -- 画布渲染引擎 
    function QuantumHUD:_attachUltraHDCanvas(parentPart, isLocal)
        local sGui = Instance.new("SurfaceGui")
        sGui.Name = "CanvasEngine"
        sGui.Face = Enum.NormalId.Front
        sGui.CanvasSize = Vector2.new(1380, 525)           
        sGui.PixelsPerStud = 300                             
        sGui.AlwaysOnTop = true
        sGui.LightInfluence = 0.0                          
        sGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sGui.Enabled = false 
        sGui.Parent = parentPart

        local canvas = Instance.new("CanvasGroup")
        canvas.Name = "AlphaGroup"
        canvas.Size = UDim2.new(1, 0, 1, 0)
        canvas.BackgroundColor3 = isLocal and self.Config.MyCardBg or self.Config.PinkGlassBg
        canvas.GroupTransparency = 1                       
        canvas.BorderSizePixel = 0
        canvas.Parent = sGui
        Instance.new("UICorner", canvas).CornerRadius = UDim.new(0, 42) 

        local stroke = Instance.new("UIStroke", canvas)
        stroke.Thickness = 6.5                                         
        stroke.Color = isLocal and self.Config.MyCardStroke or self.Config.PinkGlassStroke

        local avatar = Instance.new("ImageLabel")
        avatar.Name = "UserAvatar"
        avatar.Size = UDim2.new(0, 130, 0, 130)
        avatar.Position = UDim2.new(0, 45, 0.5, -65)
        avatar.BackgroundTransparency = 1
        avatar.Parent = canvas
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
        
        local avStroke = Instance.new("UIStroke", avatar)
        avStroke.Thickness = 4
        avStroke.Color = stroke.Color

        local function CreateHDText(name, size, pos, color, font)
            local label = Instance.new("TextLabel")
            label.Name = name
            label.Size = UDim2.new(0.75, 0, 0.22, 0)
            label.Position = pos
            label.BackgroundTransparency = 1
            label.TextColor3 = color
            label.TextSize = size
            label.Font = font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextStrokeTransparency = 1
            
            local shadow = Instance.new("UIStroke", label)
            shadow.Color = self.Config.ShadowColor
            shadow.Thickness = 3.5
            shadow.LineJoinMode = Enum.LineJoinMode.Round
            label.Parent = canvas
            return label
        end

        CreateHDText("TitleLabel", 46, UDim2.new(0, 210, 0.16, 0), self.Config.TextHDMain, Enum.Font.GothamBold)
        CreateHDText("SubTagLabel", 32, UDim2.new(0, 210, 0.46, 0), self.Config.TextHDSub, Enum.Font.GothamBold)
        CreateHDText("StatusLabel", 34, UDim2.new(0, 210, 0.72, 0), self.Config.TextHDMain, Enum.Font.Code)

        if isLocal then
            local coordLabel = CreateHDText("CoordLabel", 28, UDim2.new(0, 210, 0.73, 0), self.Config.TextHDSub, Enum.Font.Code)
            coordLabel.Size = UDim2.new(0.75, 0, 0.18, 0)
            canvas.StatusLabel.Position = UDim2.new(0, 210, 0.56, 0)
            canvas.StatusLabel.TextSize = 30
            
            local hpContainer = Instance.new("Frame")
            hpContainer.Name = "HPContainer"
            hpContainer.Size = UDim2.new(0, 1120, 0, 14)
            hpContainer.Position = UDim2.new(0, 210, 0.43, 0)
            hpContainer.BackgroundColor3 = self.Config.HealthBarContainerColor
            hpContainer.BorderSizePixel = 0
            hpContainer.Parent = canvas
            Instance.new("UICorner", hpContainer).CornerRadius = UDim.new(0, 7)
            
            local hpProgress = Instance.new("Frame")
            hpProgress.Name = "HPProgress"
            hpProgress.Size = UDim2.new(1, 0, 1, 0) 
            hpProgress.BackgroundColor3 = self.Config.HealthBarProgressColor
            hpProgress.BorderSizePixel = 0
            hpProgress.Parent = hpContainer
            Instance.new("UICorner", hpProgress).CornerRadius = UDim.new(0, 7)
        end

        return canvas
    end

    -- 矩阵运算 
    function QuantumHUD:_calculateCinematicTransform(targetRoot, camera, state, gameTime, deltaTime)
        local camCF = camera.CFrame
        local baseShoulderPos = targetRoot.Position + Vector3.new(0, self.Config.ShoulderHeight, 0)
        local targetWorldPos = baseShoulderPos + (camCF.RightVector * self.Config.EyeSeparation)
        
        local slowLayer = math.sin(gameTime * 0.95) * math.cos(gameTime * 0.3) * 0.09
        local fastLayer = math.sin(gameTime * self.Config.MicroVibeFreq) * 0.006 
        local finalBobY = slowLayer + fastLayer
        local finalBobX = math.cos(gameTime * 1.1) * math.sin(gameTime * 0.4) * 0.06
        
        targetWorldPos = targetWorldPos + Vector3.new(finalBobX, finalBobY, finalBobX * 0.3)
        
        local dt = math.min(deltaTime, 0.03)
        local currentPhysicsPos = self:_updateFluidEngine(state, targetWorldPos, dt)
        
        local lookAtCF = CFrame.lookAt(currentPhysicsPos, camCF.Position, Vector3.new(0, 1, 0))
        local localTargetVec = camCF:ToObjectSpace(lookAtCF).Position.Unit
        
        local targetTiltX = -localTargetVec.Y * self.Config.ParallaxIntensity
        local targetTiltY = localTargetVec.X * self.Config.ParallaxIntensity
        state.Rotation = state.Rotation + (Vector3.new(targetTiltX, targetTiltY, 0) - state.Rotation) * 0.15
        
        return lookAtCF * CFrame.Angles(state.Rotation.X, state.Rotation.Y, math.sin(gameTime * 0.5) * 0.005)
    end

    --  视线方向计算 
    function QuantumHUD:_evaluateGlobalState(myRoot, myHum, camera)
        if myHum.MoveDirection.Magnitude > 0.01 then return 1.0 end
        local cameraToMeDirection = (camera.CFrame.Position - myRoot.Position).Unit
        local lookDirectionDot = myRoot.CFrame.LookVector:Dot(cameraToMeDirection)
        if lookDirectionDot > self.Config.ViewAngleThreshold then return 0.0 else return 1.0 end
    end

    --  主渲染管线驱动 
    function QuantumHUD:_launchPipelineLoop()
        RunService:BindToRenderStep("Quantum_Stationary_Engine", Enum.RenderPriority.Camera.Value + 1, function(dt)
            if not self.IsRunning then return end
            
            local camera = Workspace.CurrentCamera
            local myChar = self.LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar and myChar:FindFirstChild("Humanoid")
            local currentTime = os.clock()
            
            if not (camera and myRoot and myHum) then return end
            
            local targetGlobalAlpha = self:_evaluateGlobalState(myRoot, myHum, camera)
            local wasHidden = (self.GlobalCurrentAlpha > 0.95)
            
            local alphaSpeed = targetGlobalAlpha == 0 and 0.09 or 0.25
            self.GlobalCurrentAlpha = self.GlobalCurrentAlpha + (targetGlobalAlpha - self.GlobalCurrentAlpha) * alphaSpeed
            
            local isGlobalVisible = self.GlobalCurrentAlpha < 0.95
            local computedBlurTransparency = 0.45 + (self.GlobalCurrentAlpha * 0.55)
            
            -- 本地驱动
            if self.My3DInstance then
                if isGlobalVisible then
                    self.My3DInstance.CanvasEngine.Enabled = true
                    local alphaGroup = self.My3DInstance.CanvasEngine.AlphaGroup
                    alphaGroup.GroupTransparency = self.GlobalCurrentAlpha
                    self.My3DInstance.GlassBlurFilter.Transparency = computedBlurTransparency
                    
                    local hpRatio = math.clamp(myHum.Health / myHum.MaxHealth, 0, 1)
                    alphaGroup.StatusLabel.Text = "💖 状态: " .. tostring(math.floor(hpRatio * 100)) .. "%"
                    alphaGroup.HPContainer.HPProgress.Size = UDim2.new(hpRatio, 0, 1, 0)
                    
                    local pos = myRoot.Position
                    alphaGroup.CoordLabel.Text = string.format("坐标: X:%.1f / Y:%.1f / Z:%.1f", pos.X, pos.Y, pos.Z)
                    
                    if wasHidden then 
                        local basePos = myRoot.Position + (camera.CFrame.RightVector * self.Config.EyeSeparation)
                        self.MyFluidState.Position = basePos
                        self.MyFluidState.Velocity = Vector3.new()
                        self.MyFluidState.Rotation = Vector3.new()
                    end
                    
                    local finalCF = self:_calculateCinematicTransform(myRoot, camera, self.MyFluidState, currentTime, dt)
                    self.My3DInstance.CFrame = finalCF
                    self.My3DInstance.GlassBlurFilter.CFrame = finalCF * CFrame.new(0, 0, -0.01)
                else
                    self.My3DInstance.CanvasEngine.Enabled = false
                    self.My3DInstance.GlassBlurFilter.Transparency = 1
                end
            end
            
            -- 目标驱动
            local targetPool = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= self.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local tChar = player.Character; local tRoot = tChar.HumanoidRootPart; local tHum = tChar.Humanoid
                    if tHum.Health > 0 then
                        local _, inViewport = camera:WorldToScreenPoint(tRoot.Position)
                        local distance = (myRoot.Position - tRoot.Position).Magnitude
                        if inViewport and distance <= self.Config.MaxDistance then
                            local isVisible = self:_isTargetVisibleThroughCover(camera, myChar, tChar, tRoot)
                            if isVisible then
                                table.insert(targetPool, {player = player, root = tRoot, hum = tHum, dist = distance, char = tChar})
                            end
                        end
                    end
                end
            end
            table.sort(targetPool, function(a, b) return a.dist < b.dist end)
            
            for i = 1, self.Config.MaxHUDs do
                local slot = self.Slots[i]
                local data = targetPool[i]
                
                if data and isGlobalVisible then
                    slot.Part.CanvasEngine.Enabled = true
                    local alphaGroup = slot.Part.CanvasEngine.AlphaGroup
                    alphaGroup.GroupTransparency = self.GlobalCurrentAlpha
                    slot.Part.GlassBlurFilter.Transparency = computedBlurTransparency
                    
                    if wasHidden or not self.SlotFluidStates[i] or slot.LastTarget ~= data.player then
                        local basePos = data.root.Position + (camera.CFrame.RightVector * self.Config.EyeSeparation)
                        self.SlotFluidStates[i] = { Position = basePos, Velocity = Vector3.new(), Rotation = Vector3.new() }
                    end
                    
                    local finalCF = self:_calculateCinematicTransform(data.root, camera, self.SlotFluidStates[i], currentTime, dt)
                    slot.Part.CFrame = finalCF
                    slot.Part.GlassBlurFilter.CFrame = finalCF * CFrame.new(0, 0, -0.01)
                    
                    if slot.LastTarget ~= data.player then
                        slot.LastTarget = data.player
                        alphaGroup.TitleLabel.Text = data.player.DisplayName
                        
                        local avatarUrl = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(data.player.UserId) .. "&w=150&h=150"
                        if alphaGroup.UserAvatar.Image ~= avatarUrl then
                            alphaGroup.UserAvatar.Image = avatarUrl
                        end
                        
                        local tool = data.char:FindFirstChildOfClass("Tool")
                        alphaGroup.SubTagLabel.Text = tool and ("🌸 " .. tool.Name) or "[ UNARMED ]"
                    end
                    alphaGroup.StatusLabel.Text = "💢 HP: " .. tostring(math.floor(data.hum.Health)) .. " / " .. tostring(data.hum.MaxHealth)
                else
                    if slot.Part then
                        slot.Part.CanvasEngine.Enabled = false
                        slot.Part.GlassBlurFilter.Transparency = 1
                    end
                    if not data then
                        slot.LastTarget = nil
                        self.SlotFluidStates[i] = nil
                    end
                end
            end
        end)
    end

    -- 角色材质与高光
    function QuantumHUD:_applyVisualEnhancements(character)
        if not character then return end
        
        for _, item in ipairs(character:GetDescendants()) do
            if item.Name == "Quantum_Self_Highlight" or item.Name == "Quantum_Self_PointLight" then
                item:Destroy()
            end
        end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("BasePart") then
                if part:IsA("MeshPart") then
                    part.RenderFidelity = Enum.RenderFidelity.Precise
                end
                part.CastShadow = true
                
                pcall(function()
                    if part.Material == Enum.Material.Plastic then
                        part.Material = Enum.Material.SmoothPlastic
                    end
                    
                    if part.Name == "Head" or part.Name == "Face" or part.Name:find("Face") then
                        part.Reflectance = self.Config.HeadReflectance
                    else
                        part.Reflectance = self.Config.BodyReflectance
                    end
                end)
            end
        end

        local lowerTorso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
        if lowerTorso then
            local light = Instance.new("PointLight")
            light.Name = "Quantum_Self_PointLight"
            light.Color = Color3.fromRGB(255, 245, 250) 
            light.Brightness = self.Config.LightBrightness                      
            light.Range = self.Config.LightRange                           
            light.Shadows = true                        
            light.Parent = lowerTorso
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "Quantum_Self_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 1.0            
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
        highlight.OutlineTransparency = self.Config.OutlineTransparency         
        highlight.Adornee = character
        highlight.Parent = character
    end

    -- 画质
    function QuantumHUD:_maximizeMobileGraphicsPipeline()
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
            Lighting.Technology = Enum.Technology.Future
            Lighting.ShadowMapEnabled = true
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 1.0  
            Lighting.EnvironmentSpecularScale = 1.0 
            Lighting.Ambient = Color3.fromRGB(35, 32, 38)
            Lighting.OutdoorAmbient = Color3.fromRGB(45, 42, 50)
        end)

        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx.Name:find("QuantumFX_") then fx:Destroy() end
        end

        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "QuantumFX_ColorMax"
        colorCorrection.Brightness = 0.02
        colorCorrection.Contrast = 0.20       
        colorCorrection.Saturation = 0.16     
        colorCorrection.TintColor = Color3.fromRGB(255, 252, 248) 
        colorCorrection.Parent = Lighting

        local bloom = Instance.new("BloomEffect")
        bloom.Name = "QuantumFX_BloomMax"
        bloom.Intensity = 0.95                
        bloom.Size = 32                       
        bloom.Threshold = 0.80                
        bloom.Parent = Lighting

        local sunRays = Instance.new("SunRaysEffect")
        sunRays.Name = "QuantumFX_SunRaysMax"
        sunRays.Intensity = 0.40
        sunRays.Spread = 0.92
        sunRays.Parent = Lighting

        local blur = Instance.new("BlurEffect")
        blur.Name = "QuantumFX_MotionBlurMax"
        blur.Size = 2.6
        blur.Parent = Lighting

        task.spawn(function()
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("BasePart") and not desc:IsDescendantOf(Players.LocalPlayer.Character) then
                    pcall(function()
                        if desc.Material == Enum.Material.Plastic then
                            desc.Material = Enum.Material.SmoothPlastic
                        end
                        if desc.Reflectance < 0.05 then
                            desc.Reflectance = 0.06
                        end
                    end)
                end
            end
        end)
    end

    -- 启动
    function QuantumHUD:Start()
        self:PurgeLegacyPipelines()
        self.IsRunning = true
        
        self:_maximizeMobileGraphicsPipeline()
        
        self.My3DInstance = self:_buildGlassContainer("LocalPlayer")
        local myCanvas = self:_attachUltraHDCanvas(self.My3DInstance, true)
        myCanvas.TitleLabel.Text = "👑 " .. self.LocalPlayer.DisplayName
        myCanvas.SubTagLabel.Text = "🌸如果没人爱着你，还有开发者爱着你(=^▽^=)"
        myCanvas.UserAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(self.LocalPlayer.UserId) .. "&w=150&h=150"
        
        if self.LocalPlayer.Character then
            self:_applyVisualEnhancements(self.LocalPlayer.Character)
        end

        self.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
            self:_applyVisualEnhancements(newCharacter)
        end)
        
        for i = 1, self.Config.MaxHUDs do
            local part = self:_buildGlassContainer("Slot_" .. i)
            local canvas = self:_attachUltraHDCanvas(part, false)
            self.Slots[i] = {Part = part, Canvas = canvas, LastTarget = nil}
        end
        
        self:_launchPipelineLoop()
    end

    local RunInstance = QuantumHUD.new()
    RunInstance:Start()
end

-- 一些配置数值
LaunchQuantumGraphicsPipeline({
    MaxHUDs = 5,              
    MaxDistance = 110,         
    
    BodyReflectance = 0.15,    
    HeadReflectance = 0.01,    
    LightBrightness = 0.45,    
    LightRange = 11.0,         
    OutlineTransparency = 0.05 
})