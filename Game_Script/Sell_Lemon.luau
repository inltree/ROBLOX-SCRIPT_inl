--[[
    Modified by DeepSeek × inltree｜Lin
    Source Code: https://pastebin.com/raw/3HbFHSH3
]]--

--// 清理旧实例
if game:GetService("CoreGui"):FindFirstChild("TycoonAutoUI") then
    game:GetService("CoreGui").TycoonAutoUI:Destroy()
end

--// 加载库
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/inltree/ROBLOX-SCRIPT_inl/main/Script_UI_Library/Tora_Library/Tora_Library.luau", true))()

--// 创建主窗口
local MainWindow = Library:CreateWindow("Sell Lemon")

--// 准备工作：获取玩家 Tycoon
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// 等待角色
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local UserTycoon = nil
repeat
    for _, V in pairs(workspace:GetChildren()) do
        if V:IsA("Folder") and V.Name:match("Tycoon%d") then
            if V:FindFirstChild("Owner") and V.Owner.Value == LocalPlayer then
                UserTycoon = V
                break
            end
        end
    end
    if not UserTycoon then task.wait(1) end
until UserTycoon
print("✅ Tycoon found:", UserTycoon.Name)

--// 显示 tycoon 名称
MainWindow:AddLabel({ text = "🏠 Tycoon: " .. UserTycoon.Name, type = "label" })

--// 功能 1：自动购买
if _G.AutoBuy == nil then _G.AutoBuy = false end

local Buying = false
local function GetButtons()
    local Buttons = {}
    for _, Obj in ipairs(UserTycoon.Purchases:GetDescendants()) do
        if Obj:IsA("Model") then
            local Shown = Obj:GetAttribute("Shown")
            local Purchased = Obj:GetAttribute("Purchased")
            if Shown == true and Purchased ~= true then
                local ButtonPart = Obj:FindFirstChild("Button")
                if ButtonPart and ButtonPart:IsA("BasePart") then
                    table.insert(Buttons, {
                        Name = Obj.Name,
                        Button = ButtonPart,
                    })
                end
            end
        end
    end
    return Buttons
end

local function BuyButton(ButtonData)
    if Buying then return end
    Buying = true
    local Character = LocalPlayer.Character
    if not Character then Buying = false return end
    local Hrp = Character:FindFirstChild("HumanoidRootPart")
    if not Hrp then Buying = false return end
    pcall(function()
        firetouchinterest(Hrp, ButtonData.Button, 0)
        firetouchinterest(Hrp, ButtonData.Button, 1)
    end)
    Buying = false
end

function AutoBuyLoop()
    _G.AutoBuy = true
    task.spawn(function()
        while _G.AutoBuy do
            task.wait()
            pcall(function()
                local Buttons = GetButtons()
                for _, Btn in ipairs(Buttons) do
                    BuyButton(Btn)
                end
            end)
        end
    end)
end

MainWindow:AddToggle({
    text = "🟢 自动购买",
    flag = "auto_buy",
    state = _G.AutoBuy,
    callback = function(V)
        _G.AutoBuy = V
        print("自动购买:", V)
        if V then AutoBuyLoop() end
    end
})

--// 功能 2：自动升级
if _G.AutoUpgrade == nil then _G.AutoUpgrade = false end

local function UpgradeMachines()
    for _, Obj in ipairs(UserTycoon.Purchases:GetDescendants()) do
        if Obj:IsA("RemoteFunction") and Obj.Name == "Upgrade" then
            pcall(function()
                for Level = 1, 100 do
                    Obj:InvokeServer(Level)
                end
            end)
        end
    end
end

function AutoUpgradeLoop()
    _G.AutoUpgrade = true
    task.spawn(function()
        while _G.AutoUpgrade do
            task.wait()
            pcall(UpgradeMachines)
        end
    end)
end

MainWindow:AddToggle({
    text = "⬆️ 自动升级",
    flag = "auto_upgrade",
    state = _G.AutoUpgrade,
    callback = function(V)
        _G.AutoUpgrade = V
        print("自动升级:", V)
        if V then AutoUpgradeLoop() end
    end
})

--// 功能 3：自动水果
if _G.AutoFruit == nil then _G.AutoFruit = false end

local Trees = {}
local function AddTree(Obj)
    if Obj:IsA("Model") and Obj.Name == "LemonTree" then
        if not table.find(Trees, Obj) then
            table.insert(Trees, Obj)
        end
    end
end
local function RemoveTree(Obj)
    local Index = table.find(Trees, Obj)
    if Index then
        table.remove(Trees, Index)
    end
end

for _, V in ipairs(workspace:GetDescendants()) do AddTree(V) end
workspace.DescendantAdded:Connect(AddTree)
workspace.DescendantRemoving:Connect(RemoveTree)

local function NoCollisionTree(Tree)
    for _, Obj in ipairs(Tree:GetDescendants()) do
        if Obj:IsA("BasePart") then
            Obj.CanCollide = false
        end
    end
end

local function TeleportToTree(Tree)
    local Character = LocalPlayer.Character
    if not Character then return false end
    local Hrp = Character:FindFirstChild("HumanoidRootPart")
    if not Hrp then return false end
    Hrp.CFrame = Tree:GetPivot() + Vector3.new(0, 5, 0)
    return true
end

local function CollectFruit(Tree)
    if not Tree or not Tree.Parent then return end
    NoCollisionTree(Tree)
    if not TeleportToTree(Tree) then return end
    for _, Obj in ipairs(Tree:GetDescendants()) do
        if Obj:IsA("BasePart") and Obj.Name == "Fruit" then
            Obj.CanCollide = false
            local ClickPart = Obj:FindFirstChild("ClickPart")
            if ClickPart then
                local Detector = ClickPart:FindFirstChildOfClass("ClickDetector")
                if Detector then
                    task.wait(0.45)
                    pcall(function() fireclickdetector(Detector) end)
                end
            end
        end
    end
end

function AutoFruitLoop()
    _G.AutoFruit = true
    task.spawn(function()
        while _G.AutoFruit do
            task.wait()
            pcall(function()
                for _, Tree in ipairs(Trees) do
                    if not _G.AutoFruit then break end
                    if Tree and Tree.Parent then
                        CollectFruit(Tree)
                    end
                end
            end)
        end
    end)
end

MainWindow:AddToggle({
    text = "🍋 自动水果",
    flag = "auto_fruit",
    state = _G.AutoFruit,
    callback = function(V)
        _G.AutoFruit = V
        print("自动收水果:", V)
        if V then AutoFruitLoop() end
    end
})

--// 功能 4：自动点击
if _G.AutoClick == nil then _G.AutoClick = false end

local function WakeAllStreams()
    local TycoonName = UserTycoon.Name
    local Success, Streams = pcall(function()
        return workspace[TycoonName].Values.Income.Streams
    end)
    if not Success or not Streams then return end
    local Remote = workspace[TycoonName].Remotes.WakeIncomeStream
    for _, StreamObj in ipairs(Streams:GetChildren()) do
        local StreamName = StreamObj.Name
        task.spawn(function()
            pcall(function() Remote:InvokeServer(StreamName) end)
        end)
    end
end

function AutoClickLoop()
    _G.AutoClick = true
    task.spawn(function()
        while _G.AutoClick do
            task.wait()
            pcall(WakeAllStreams)
        end
    end)
end

MainWindow:AddToggle({
    text = "💸 自动点击",
    flag = "auto_click",
    state = _G.AutoClick,
    callback = function(V)
        _G.AutoClick = V
        print("自动点击:", V)
        if V then AutoClickLoop() end
    end
})

--// 最终初始化
Library:Init()

--// 可选清理
pcall(function()
    game:GetService("SoundService"):FindFirstChild("Error"):Destroy()
end)

print("🚀 Sell Lemon Script Loaded.")
