--[[
  Auto Interact v1.4 - 精简版 (无深层检索，纯缓存扫描，移除无效 MaxThreads)
  By inltree｜Lin × ChatGPT (GPT-5) × DeepSeek
  🚀 缓存更新 · 分片扫描 · 零卡顿 · 单对象交互
]]

local Config = {
    AutoClick = false,
    AutoTrigger = false,
    Radius = 0,
    ScanDelay = 0,
    Running = false,
    Minimized = false
}

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game.CoreGui
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CompletelyStopped = false

-- 缓存所有需监控的检测器
local InteractObjects = {}

local Character, RootPart
local function WaitForCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart")
    return Character, RootPart
end

WaitForCharacter()
Player.CharacterAdded:Connect(function(Char)
    if CompletelyStopped then return end
    Character, RootPart = Char, Char:WaitForChild("HumanoidRootPart")
end)

-- 交互核心
local function DoInteract(Object)
    if CompletelyStopped then return end
    if Object:IsA("ClickDetector") and Config.AutoClick then
        fireclickdetector(Object)
    elseif Object:IsA("ProximityPrompt") and Config.AutoTrigger then
        fireproximityprompt(Object)
    end
end

local function GetPos(Target)
    if not Target then return nil end
    if Target:IsA("BasePart") then
        return Target.Position
    elseif Target:IsA("Attachment") and Target.Parent:IsA("BasePart") then
        return Target.Parent.Position
    elseif Target:IsA("Model") and Target.PrimaryPart then
        return Target.PrimaryPart.Position
    end
    return nil
end

-- 动态缓存管理
local function AddObject(obj)
    if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then
        if not table.find(InteractObjects, obj) then
            table.insert(InteractObjects, obj)
        end
    end
end

local function RemoveObject(obj)
    if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then
        local idx = table.find(InteractObjects, obj)
        if idx then
            table.remove(InteractObjects, idx)
        end
    end
end

-- 初始化填充缓存
for _, obj in ipairs(Workspace:GetDescendants()) do
    AddObject(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    if CompletelyStopped then return end
    AddObject(obj)
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if CompletelyStopped then return end
    RemoveObject(obj)
end)

local ScanThread
local function StartScan()
    if ScanThread then
        Config.Running = false
        task.wait(0.1)
    end

    Config.Running = true
    ScanThread = task.spawn(function()
        while not CompletelyStopped and Config.Running do
            if not RootPart or not RootPart.Parent then
                task.wait(1)
                continue
            end

            local objects = table.clone(InteractObjects)
            local BATCH_SIZE = 100
            local index = 1
            local total = #objects

            while index <= total do
                if CompletelyStopped or not Config.Running then break end
                local batchEnd = math.min(index + BATCH_SIZE - 1, total)

                for i = index, batchEnd do
                    local obj = objects[i]
                    if obj and obj.Parent then
                        local pos = GetPos(obj.Parent)
                        if pos and (Config.Radius == 0 or (pos - RootPart.Position).Magnitude <= Config.Radius) then
                            DoInteract(obj)
                        end
                    end
                end

                index = batchEnd + 1
                task.wait()
            end

            if Config.ScanDelay == 0 then
                task.wait()
            else
                task.wait(Config.ScanDelay)
            end
        end
        Config.Running = false
        ScanThread = nil
    end)
end

local function StopScan()
    Config.Running = false
end

-- 自动运行监控
local ControlThread = task.spawn(function()
    while not CompletelyStopped do
        task.wait()
        if CompletelyStopped then break end

        local shouldRun = Config.AutoClick or Config.AutoTrigger
        if shouldRun and not Config.Running then
            StartScan()
        elseif not shouldRun and Config.Running then
            StopScan()
        end
    end
end)

-- GUI
if CoreGui:FindFirstChild("InltreeAutoInteractUI") then
    CoreGui.InltreeAutoInteractUI:Destroy()
end

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "InltreeAutoInteractUI"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false

local Width, Height = 220, 230
local MainFrame = Instance.new("Frame", Gui)
MainFrame.Size = UDim2.new(0, Width, 0, Height)
MainFrame.Position = UDim2.new(0.5, -Width / 2, 0.5, -Height / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 90)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "自动交互控制 v1.4"

local MinimizeButton = Instance.new("TextButton", TitleLabel)
MinimizeButton.Size = UDim2.new(0, 35, 1, 0)
MinimizeButton.Position = UDim2.new(1, -75, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Text = Config.Minimized and "➕" or "➖"
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20

local CloseButton = Instance.new("TextButton", TitleLabel)
CloseButton.Size = UDim2.new(0, 35, 1, 0)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "✖️"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20

local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, 0, 1, -35)
ScrollFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local function CreateToggle(Label, FieldName, Y)
    local Button = Instance.new("TextButton", ScrollFrame)
    Button.Size = UDim2.new(0.9, 0, 0, 28)
    Button.Position = UDim2.new(0.05, 0, 0, Y)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 15
    Button.TextColor3 = Color3.new(1, 1, 1)

    local function UpdateVisual()
        local val = Config[FieldName]
        Button.BackgroundColor3 = val and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(120, 60, 60)
        Button.Text = Label .. "：" .. (val and "ON" or "OFF")
    end
    UpdateVisual()

    Button.MouseButton1Click:Connect(function()
        if CompletelyStopped then return end
        Config[FieldName] = not Config[FieldName]
        UpdateVisual()
    end)
end

local function CreateInput(Label, FieldName, Y, ClampFunc)
    local LabelGui = Instance.new("TextLabel", ScrollFrame)
    LabelGui.Size = UDim2.new(0.9, 0, 0, 20)
    LabelGui.Position = UDim2.new(0.05, 0, 0, Y)
    LabelGui.BackgroundTransparency = 1
    LabelGui.Text = Label
    LabelGui.TextColor3 = Color3.new(1, 1, 1)
    LabelGui.Font = Enum.Font.SourceSansBold
    LabelGui.TextSize = 15
    LabelGui.TextXAlignment = Enum.TextXAlignment.Left

    local TextBox = Instance.new("TextBox", ScrollFrame)
    TextBox.Size = UDim2.new(0.9, 0, 0, 25)
    TextBox.Position = UDim2.new(0.05, 0, 0, Y + 20)
    TextBox.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    TextBox.BorderColor3 = Color3.fromRGB(100, 100, 110)
    TextBox.Text = tostring(Config[FieldName])
    TextBox.TextColor3 = Color3.new(1, 1, 1)
    TextBox.Font = Enum.Font.SourceSans
    TextBox.TextSize = 15
    TextBox.ClearTextOnFocus = false

    TextBox.FocusLost:Connect(function()
        if CompletelyStopped then return end
        local num = tonumber(TextBox.Text)
        if num then
            num = ClampFunc(num)
            Config[FieldName] = num
            TextBox.Text = tostring(num)
        else
            TextBox.Text = tostring(Config[FieldName])
        end
    end)
end

-- 界面布局
CreateToggle("自动点击", "AutoClick", 15)
CreateToggle("自动触发", "AutoTrigger", 50)

CreateInput("范围扫描(0 = inf)", "Radius", 85,
    function(v) return math.clamp(v, 0, 999999999) end)
CreateInput("扫描延迟(s)", "ScanDelay", 135,
    function(v) return math.clamp(v, 0, 999999999) end)

-- 最小化/关闭/快捷键
local function ToggleMinimize()
    if CompletelyStopped then return end
    Config.Minimized = not Config.Minimized
    MinimizeButton.Text = Config.Minimized and "➕" or "➖"
    local newSize = Config.Minimized and UDim2.new(0, Width, 0, 35) or UDim2.new(0, Width, 0, Height)
    TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = newSize}):Play()
    ScrollFrame.Visible = not Config.Minimized
end
MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)

CloseButton.MouseButton1Click:Connect(function()
    CompletelyStopped = true
    Config.AutoClick = false
    Config.AutoTrigger = false
    Config.Running = false

    if ControlThread then
        task.cancel(ControlThread)
    end
    if Gui and Gui.Parent then
        Gui:Destroy()
    end
end)

local Hidden = false
UserInputService.InputBegan:Connect(function(Key, Processed)
    if CompletelyStopped then return end
    if Processed then return end
    if Key.KeyCode == Enum.KeyCode.RightShift then
        Hidden = not Hidden
        MainFrame.Visible = not Hidden
    end
end)
