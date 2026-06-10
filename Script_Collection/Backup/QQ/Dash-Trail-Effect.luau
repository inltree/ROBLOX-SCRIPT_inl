local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local CONFIG = {
    GhostDuration = 0.5,       -- 残影存在时间
    GhostColor = Color3.fromRGB(255, 255, 255), --颜色
    BodyTransparency = 0.3,    -- 初始内体透明度
    MinMoveDistance = 1.2,     -- 防抖距离
    
    --残影缩放比例
    GhostScale = 0.9,
    
    -- 瞬移加速倍率
    TpWalkSpeed = 5, 
}

-- 拉丝淡烟雾
local function createLocalSmoke()
    local attachment = Instance.new("Attachment")
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "LocalDissolveSmoke"
    emitter.Texture = "rbxassetid://241901177"
    emitter.Rate = 2

    emitter.Lifetime = NumberRange.new(0.2, CONFIG.GhostDuration)
    emitter.Speed = NumberRange.new(0.1, 0.3)
    emitter.VelocitySpread = 360
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0.9)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1)})
    emitter.Color = ColorSequence.new(CONFIG.GhostColor)
    emitter.Parent = attachment
    return attachment
end

local smokeTemplate = createLocalSmoke()

---单次残影生成函数 ---
local function createSingleGhost(character)
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local ghostModel = Instance.new("Model")
    ghostModel.Name = "MyPerfectGhostInstance"
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "TrueNeonOutline"
    highlight.FillColor = CONFIG.GhostColor
    highlight.FillTransparency = 0.65 

    highlight.OutlineColor = CONFIG.GhostColor 
    highlight.OutlineTransparency = 0.3  
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
    highlight.Parent = ghostModel
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 0.9 then
            
            local clonePart = Instance.new("Part")
            clonePart.Size = part.Size * CONFIG.GhostScale
            clonePart.CFrame = part.CFrame
            clonePart.Anchored = true
            
            clonePart.CanCollide = false
            clonePart.CanTouch = false
            clonePart.CanQuery = false
            
    
            if part:IsA("MeshPart") then
                local specialMesh = Instance.new("SpecialMesh")
                specialMesh.MeshType = Enum.MeshType.FileMesh
                specialMesh.MeshId = part.MeshId
                specialMesh.Scale = Vector3.new(CONFIG.GhostScale, CONFIG.GhostScale, CONFIG.GhostScale)
                specialMesh.Parent = clonePart
            elseif part:FindFirstChildOfClass("SpecialMesh") then
                local meshClone = part:FindFirstChildOfClass("SpecialMesh"):Clone()
                meshClone.Scale = meshClone.Scale * CONFIG.GhostScale
                meshClone.Parent = clonePart
            end
            
            clonePart.Material = Enum.Material.Neon
            clonePart.Color = CONFIG.GhostColor
            clonePart.Transparency = CONFIG.BodyTransparency
            clonePart.Parent = ghostModel
            
            local tween = TweenService:Create(clonePart, TweenInfo.new(CONFIG.GhostDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1})
            tween:Play()
        end
    end
    
    if #ghostModel:GetChildren() > 1 then
        ghostModel.Parent = workspace
        
        local hlTween = TweenService:Create(highlight, TweenInfo.new(CONFIG.GhostDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {OutlineTransparency = 1, FillTransparency = 1})
        hlTween:Play()
        
        local smokeClone = smokeTemplate:Clone()
        smokeClone.Parent = workspace
        smokeClone.Position = rootPart.Position - Vector3.new(0, 1.8, 0)
        
        Debris:AddItem(ghostModel, CONFIG.GhostDuration)
        Debris:AddItem(smokeClone, CONFIG.GhostDuration)
    else
        ghostModel:Destroy()
    end
end

-- 距离和渲染
local lastGhostPosition = Vector3.new(0, 0, 0)

RunService.RenderStepped:Connect(function()
    pcall(function()
        local character = localPlayer.Character
        if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
            local humanoid = character.Humanoid
            local rootPart = character.HumanoidRootPart
            
            if humanoid.MoveDirection.Magnitude > 0 then
                
                character:TranslateBy(humanoid.MoveDirection * CONFIG.TpWalkSpeed / 100)
                
                
                local currentPosition = rootPart.Position
                local distanceMoved = (currentPosition - lastGhostPosition).Magnitude
                
                if distanceMoved >= CONFIG.MinMoveDistance then
                    createSingleGhost(character)
                    lastGhostPosition = currentPosition
                end
            end
        end
    end)
end)