-- ===== 配置区域 =====
local AURA_ASSET_ID = "rbxassetid://97658130917593"  -- 天使光环，可替换为其他ID
local TOGGLE_KEY = Enum.KeyCode.Insert              -- 开关按键
local AUTO_ENABLE = true                            -- 脚本启动后自动开启
-- ====================

-- 可用光环ID参考（从原脚本提取）：
-- 星光: rbxassetid://134645216613107
-- 天堂: rbxassetid://139300897520961
-- 缎带: rbxassetid://132069507632161
-- 樱花: rbxassetid://81755778619404
-- 天使: rbxassetid://97658130917593
-- 风:   rbxassetid://80694081850877
-- 流:   rbxassetid://119913533725648
-- 星:   rbxassetid://73754563740680

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Particles = {}          -- 存储所有生成的粒子对象
local AuraModel = nil         -- 加载的光环模型
local IsEnabled = false       -- 光环开关状态
local CurrentConnection = nil -- 渲染连接

-- 身体部位对应表（用于将光环零件附着到正确位置）
local BodyParts = {
    Head = "Head",
    UpperTorso = "UpperTorso",
    LowerTorso = "LowerTorso",
    LeftUpperArm = "LeftUpperArm",
    LeftLowerArm = "LeftLowerArm",
    LeftHand = "LeftHand",
    RightUpperArm = "RightUpperArm",
    RightLowerArm = "RightLowerArm",
    RightHand = "RightHand",
    LeftUpperLeg = "LeftUpperLeg",
    LeftLowerLeg = "LeftLowerLeg",
    LeftFoot = "LeftFoot",
    RightUpperLeg = "RightUpperLeg",
    RightLowerLeg = "RightLowerLeg",
    RightFoot = "RightFoot",
    HumanoidRootPart = "HumanoidRootPart"
}

-- 清除所有已生成的粒子
local function ClearParticles()
    for _, particle in ipairs(Particles) do
        pcall(function() particle:Destroy() end)
    end
    Particles = {}
end

-- 应用光环（将模型中的粒子附着到角色身体对应部位）
local function ApplyAura()
    ClearParticles()
    
    if not AuraModel or not Character then return end
    
    local cloned = AuraModel:Clone()
    local children = cloned:GetChildren()
    
    for _, child in ipairs(children) do
        -- 获取零件名称对应的身体部位
        local targetPart = Character:FindFirstChild(child.Name)
        
        if targetPart then
            -- 将零件内的所有子对象（粒子发射器等）移动到身体部位
            local subChildren = child:GetChildren()
            for _, sub in ipairs(subChildren) do
                sub.Parent = targetPart
                table.insert(Particles, sub)
            end
        end
        child:Destroy()
    end
    
    cloned:Destroy()
end

-- 加载光环模型
local function LoadAura()
    if AuraModel then
        pcall(function() AuraModel:Destroy() end)
        AuraModel = nil
    end
    
    local success, result = pcall(function()
        return game:GetObjects(AURA_ASSET_ID)[1]
    end)
    
    if success and result then
        AuraModel = result
        if IsEnabled then
            ApplyAura()
        end
        return true
    else
        warn("加载光环失败，请检查Asset ID: " .. AURA_ASSET_ID)
        return false
    end
end

-- 光环更新函数（每帧检查角色是否变化）
local function OnRenderStep()
    if not IsEnabled then return end
    
    -- 检查角色是否有效
    local character = LocalPlayer.Character
    if character ~= Character then
        Character = character
        if Character then
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            -- 角色切换时重新应用光环
            ApplyAura()
        end
    end
end

-- 启用光环
local function EnableAura()
    if IsEnabled then return end
    IsEnabled = true
    
    if not AuraModel then
        LoadAura()
    else
        ApplyAura()
    end
    
    if not CurrentConnection then
        CurrentConnection = RunService.RenderStepped:Connect(OnRenderStep)
    end
    
    print("[光环] 已开启")
end

-- 禁用光环
local function DisableAura()
    if not IsEnabled then return end
    IsEnabled = false
    
    ClearParticles()
    
    if CurrentConnection then
        CurrentConnection:Disconnect()
        CurrentConnection = nil
    end
    
    print("[光环] 已关闭")
end

-- 切换光环开关
local function ToggleAura()
    if IsEnabled then
        DisableAura()
    else
        EnableAura()
    end
end

-- 监听按键
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == TOGGLE_KEY then
        ToggleAura()
    end
end)

-- 监听角色重生
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if IsEnabled then
        -- 延迟一点等待角色完全加载
        task.wait(0.5)
        ApplyAura()
    end
end)

-- 启动
LoadAura()
if AUTO_ENABLE then
    EnableAura()
end

print("光环脚本已加载，按 " .. TOGGLE_KEY.Name .. " 切换")