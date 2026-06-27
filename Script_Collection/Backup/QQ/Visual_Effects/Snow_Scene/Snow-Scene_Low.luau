-- pe端对画质进行了删除，来换取尽可能的稳定，但对于低性能及仍然不建议尝试
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local EnvironmentEngine = {
    ActivePreset = {
        SkyboxID = "rbxassetid://13540026264",
        DayColor = Color3.fromRGB(140, 160, 195),
        DecayColor = Color3.fromRGB(12, 16, 30),
        ClockTime = 0.0,
        Brightness = 0.1
    },
    BlizzardConfig = {
        MaxSnowflakes = 1800,
        SpawnInterval = 0.01,
        SnowRadius = 75,
        WindX = -45,
        WindZ = 20
    },
    SnowflakePool = {},
    PoolIndex = 1,
    peFolder = nil,
    SeaPlane = nil
}

function EnvironmentEngine:ClearPreviousSession()
    pcall(function()
        if Workspace:FindFirstChild("Quantum_PESnowLayer") then 
            Workspace.Quantum_PESnowLayer:Destroy() 
        end
        if Workspace:FindFirstChild("Atmosphere_Forced_Sea") then
            Workspace.Atmosphere_Forced_Sea:Destroy()
        end
    end)
end

function EnvironmentEngine:InitializeSkybox()
    local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
    sky.SkyboxBk = self.ActivePreset.SkyboxID
    sky.SkyboxDn = self.ActivePreset.SkyboxID
    sky.SkyboxFt = self.ActivePreset.SkyboxID
    sky.SkyboxLf = self.ActivePreset.SkyboxID
    sky.SkyboxRt = self.ActivePreset.SkyboxID
    sky.SkyboxUp = self.ActivePreset.SkyboxID
    sky.CelestialBodiesShown = false
end

function EnvironmentEngine:ApplyLightingBaking()
    Lighting.ClockTime = self.ActivePreset.ClockTime
    Lighting.Brightness = self.ActivePreset.Brightness
    Lighting.Ambient = self.ActivePreset.DecayColor
    Lighting.OutdoorAmbient = self.ActivePreset.DayColor
    
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
    atmosphere.Density = 0.42
    atmosphere.Haze = 3.6
    atmosphere.Color = self.ActivePreset.DayColor
    atmosphere.Decay = self.ActivePreset.DecayColor
    atmosphere.Glare = 0.6
end

function EnvironmentEngine:BuildCustomSea()
    local seaContainer = Instance.new("Folder")
    seaContainer.Name = "Atmosphere_Forced_Sea"
    seaContainer.Parent = Workspace

    local seaPlane = Instance.new("Part")
    seaPlane.Name = "ReflectiveSea"
    seaPlane.Size = Vector3.new(12000, 1, 12000)
    seaPlane.Position = Vector3.new(0, -3, 0)
    seaPlane.Anchored = true
    seaPlane.CanCollide = false
    seaPlane.CastShadow = false
    seaPlane.Material = Enum.Material.Glass
    seaPlane.Color = Color3.fromRGB(15, 20, 32)
    seaPlane.Transparency = 0.15
    seaPlane.Parent = seaContainer

    local function createWave(textureId, speed, trans, scale)
        local tex = Instance.new("Texture")
        tex.Texture = textureId
        tex.Face = Enum.NormalId.Top
        tex.Transparency = trans
        tex.StudsPerTileU = scale
        tex.StudsPerTileV = scale
        tex.Color3 = self.ActivePreset.DayColor
        tex.Parent = seaPlane

        task.spawn(function()
            local u, v = 0, 0
            while seaPlane.Parent do
                u = (u + speed.X) % 1
                v = (v + speed.Y) % 1
                tex.OffsetStudsU = u * scale
                tex.OffsetStudsV = v * scale
                task.wait(0.03)
            end
        end)
    end

    createWave("rbxassetid://6687848609", Vector2.new(0.002, 0.003), 0.4, 180)
    createWave("rbxassetid://6687848609", Vector2.new(-0.0015, 0.0025), 0.5, 140)
    
    self.SeaPlane = seaPlane
end

function EnvironmentEngine:StartAtmosphereBreathing()
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then return end
    
    task.spawn(function()
        local isHigh = false
        while atmosphere.Parent do
            isHigh = not isHigh
            local targetHaze = isHigh and 4.3 or 3.2
            local targetGlare = isHigh and 0.8 or 0.4
            
            TweenService:Create(atmosphere, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Haze = targetHaze,
                Glare = targetGlare
            }):Play()
            
            task.wait(4)
        end
    end)
end

function EnvironmentEngine:InitializeSnowPool()
    self.peFolder = Instance.new("Folder")
    self.peFolder.Name = "Quantum_PESnowLayer"
    self.peFolder.Parent = Workspace

    for i = 1, self.BlizzardConfig.MaxSnowflakes do
        local snowball = Instance.new("Part")
        snowball.Shape = Enum.PartType.Ball
        local microSize = math.random(6, 16) / 100 
        snowball.Size = Vector3.new(microSize, microSize, microSize)
        snowball.Color = self.ActivePreset.DayColor 
        snowball.Material = Enum.Material.Neon
        snowball.CanCollide = false; snowball.CanTouch = false; snowball.CanQuery = false
        snowball.Anchored = true; snowball.CastShadow = false
        snowball.Transparency = 1 
        snowball.Position = Vector3.new(0, 9999, 0)
        snowball.Parent = self.peFolder
        
        self.SnowflakePool[i] = {
            Part = snowball,
            Tween1 = nil,
            Tween2 = nil
        }
    end
end

function EnvironmentEngine:EmitBlizzard(playerRoot)
    if not playerRoot then return end
    
    local slot = self.SnowflakePool[self.PoolIndex]
    self.PoolIndex = (self.PoolIndex % self.BlizzardConfig.MaxSnowflakes) + 1
    
    if slot.Tween1 then slot.Tween1:Cancel() end
    if slot.Tween2 then slot.Tween2:Cancel() end
    
    local snowball = slot.Part
    local localRadius = self.BlizzardConfig.SnowRadius
    
    local startPos = playerRoot.Position + Vector3.new(
        math.random(-localRadius * 10, localRadius * 10) / 10 - (self.BlizzardConfig.WindX * 0.5),
        math.random(400, 1100) / 10, 
        math.random(-localRadius * 10, localRadius * 10) / 10 - (self.BlizzardConfig.WindZ * 0.5)
    )
    
    local fallDuration = math.random(11, 20) / 10
    local endPos = startPos + Vector3.new(
        self.BlizzardConfig.WindX + math.random(-80, 80)/10, 
        -125, 
        self.BlizzardConfig.WindZ + math.random(-80, 80)/10
    )

    snowball.Position = startPos
    snowball.Transparency = 1
    
    slot.Tween1 = TweenService:Create(snowball, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {Transparency = 0.08})
    slot.Tween2 = TweenService:Create(snowball, TweenInfo.new(fallDuration, Enum.EasingStyle.Linear), {Position = endPos})
    
    slot.Tween1:Play()
    slot.Tween2:Play()

    task.delay(fallDuration - 0.25, function()
        if snowball.Position.Y ~= 9999 then
            TweenService:Create(snowball, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Transparency = 1}):Play()
        end
    end)
    
    task.delay(fallDuration, function()
        if snowball.Position.Y ~= 9999 then
            snowball.Transparency = 1
            snowball.Position = Vector3.new(0, 9999, 0)
        end
    end)
end

function EnvironmentEngine:ConnectTrackingLoop()
    local camera = Workspace.CurrentCamera
    
    RunService.RenderStepped:Connect(function()
        if camera and self.SeaPlane and self.SeaPlane.Parent then
            -- 仅保留核心的海平面无缝随动
            self.SeaPlane.Position = Vector3.new(camera.CFrame.Position.X, self.SeaPlane.Position.Y, camera.CFrame.Position.Z)
        end
    end)
end

function EnvironmentEngine:StartBlizzardLoop()
    task.spawn(function()
        while true do
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myRoot then
                for _ = 1, 18 do 
                    self:EmitBlizzard(myRoot) 
                end
            end
            task.wait(self.BlizzardConfig.SpawnInterval)
        end
    end)
end

function EnvironmentEngine:Run()
    self:ClearPreviousSession()
    self:InitializeSkybox()
    self:ApplyLightingBaking()
    self:BuildCustomSea()
    self:StartAtmosphereBreathing()
    self:InitializeSnowPool()
    self:ConnectTrackingLoop()
    self:StartBlizzardLoop()
end

EnvironmentEngine:Run()
