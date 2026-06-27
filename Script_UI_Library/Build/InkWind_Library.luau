--[[
    Ink Wind GUI Library - MD3 Edition
    Author: Ink Wind
    License: MIT License
    
    采用 Material Design 3 (Material You) 设计规范:
    - 大圆角 (12dp / 16dp / 28dp)
    - 状态层 (State Layer) - 悬停/按下状态
    - Material You 动态颜色方案
    - 简洁的层级与阴影
    - 克制的动画效果
]]

local Library = {}
local ConfigName = "InkWind/settings.json"

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- MD3 主题系统 - Material Design 3 Color Scheme
-- ============================================================
-- 每个主题包含: 主色(Primary)、容器色(Container)、表面色(Surface)、警示色(Error)
-- MD3 设计规范: 颜色使用 Token 命名, 强调色用于交互元素

local DefaultConfig = {
    ShowHUD = true,
    ShowNotifs = true,
    NotifDuration = 3,
    UIScale = 1.0,
    WindowWidth = 260,
    WindowMaxHeight = 420,
    ItemHeight = 44,
    Theme = "Violet",
    UIVisible = true,
    UseCorners = true,
    CompactMode = false,
    DarkMode = true
}

Library.Config = {}
for k, v in pairs(DefaultConfig) do Library.Config[k] = v end

Library.Globals = {
    Windows = {},
    Elements = {},
    ThemeObjects = {},
    StyleObjects = {},
    ActiveNotifs = {},
    BoundKeys = {},
    IslandPosition = Vector2.new(0, 0),
    IslandObject = nil,
    TopZIndex = 100,
    ActivePicker = nil,
    SubWindows = {}
}

-- ============================================================
-- MD3 配色方案 - 遵循 Material Design 3 颜色规范
-- ============================================================
-- 颜色体系说明:
-- Primary: 主要操作按钮、活动状态
-- OnPrimary: 放在 Primary 上的内容颜色
-- Surface: 表面背景
-- SurfaceContainer: 组件容器背景(分层)
-- Outline: 边框分隔线
-- OnSurfaceVariant: 次要文本颜色

Library.Themes = {
    ["Violet"] = {
        Name = "紫罗兰 (Violet)",
        Primary = Color3.fromRGB(103, 80, 164),
        OnPrimary = Color3.fromRGB(255, 255, 255),
        PrimaryContainer = Color3.fromRGB(234, 221, 255),
        OnPrimaryContainer = Color3.fromRGB(33, 0, 93),
        Secondary = Color3.fromRGB(98, 91, 113),
        SecondaryContainer = Color3.fromRGB(232, 222, 248),
        Tertiary = Color3.fromRGB(125, 82, 96),
        TertiaryContainer = Color3.fromRGB(255, 217, 229),
        Surface = Color3.fromRGB(17, 17, 22),
        SurfaceDim = Color3.fromRGB(17, 17, 22),
        SurfaceBright = Color3.fromRGB(54, 53, 59),
        SurfaceContainerLowest = Color3.fromRGB(12, 12, 16),
        SurfaceContainerLow = Color3.fromRGB(23, 23, 28),
        SurfaceContainer = Color3.fromRGB(27, 27, 32),
        SurfaceContainerHigh = Color3.fromRGB(33, 33, 38),
        SurfaceContainerHighest = Color3.fromRGB(40, 40, 46),
        OnSurface = Color3.fromRGB(230, 225, 238),
        OnSurfaceVariant = Color3.fromRGB(202, 196, 220),
        Outline = Color3.fromRGB(147, 143, 163),
        OutlineVariant = Color3.fromRGB(73, 69, 86),
        Error = Color3.fromRGB(220, 54, 46),
        ErrorContainer = Color3.fromRGB(89, 0, 8),
        OnErrorContainer = Color3.fromRGB(255, 218, 214)
    },
    ["Ocean"] = {
        Name = "深海蓝 (Ocean)",
        Primary = Color3.fromRGB(0, 103, 179),
        OnPrimary = Color3.fromRGB(255, 255, 255),
        PrimaryContainer = Color3.fromRGB(216, 228, 255),
        OnPrimaryContainer = Color3.fromRGB(0, 30, 58),
        Secondary = Color3.fromRGB(84, 95, 114),
        SecondaryContainer = Color3.fromRGB(216, 227, 248),
        Tertiary = Color3.fromRGB(108, 88, 123),
        TertiaryContainer = Color3.fromRGB(244, 219, 255),
        Surface = Color3.fromRGB(16, 20, 24),
        SurfaceDim = Color3.fromRGB(16, 20, 24),
        SurfaceBright = Color3.fromRGB(53, 57, 61),
        SurfaceContainerLowest = Color3.fromRGB(11, 14, 18),
        SurfaceContainerLow = Color3.fromRGB(22, 26, 30),
        SurfaceContainer = Color3.fromRGB(26, 30, 34),
        SurfaceContainerHigh = Color3.fromRGB(32, 36, 40),
        SurfaceContainerHighest = Color3.fromRGB(39, 43, 48),
        OnSurface = Color3.fromRGB(227, 226, 235),
        OnSurfaceVariant = Color3.fromRGB(198, 198, 210),
        Outline = Color3.fromRGB(143, 144, 160),
        OutlineVariant = Color3.fromRGB(71, 72, 87),
        Error = Color3.fromRGB(220, 54, 46),
        ErrorContainer = Color3.fromRGB(89, 0, 8),
        OnErrorContainer = Color3.fromRGB(255, 218, 214)
    },
    ["Forest"] = {
        Name = "森林绿 (Forest)",
        Primary = Color3.fromRGB(53, 114, 83),
        OnPrimary = Color3.fromRGB(255, 255, 255),
        PrimaryContainer = Color3.fromRGB(189, 247, 212),
        OnPrimaryContainer = Color3.fromRGB(0, 33, 18),
        Secondary = Color3.fromRGB(79, 99, 85),
        SecondaryContainer = Color3.fromRGB(211, 232, 213),
        Tertiary = Color3.fromRGB(63, 98, 116),
        TertiaryContainer = Color3.fromRGB(195, 230, 255),
        Surface = Color3.fromRGB(16, 20, 17),
        SurfaceDim = Color3.fromRGB(16, 20, 17),
        SurfaceBright = Color3.fromRGB(52, 57, 53),
        SurfaceContainerLowest = Color3.fromRGB(11, 14, 12),
        SurfaceContainerLow = Color3.fromRGB(22, 26, 23),
        SurfaceContainer = Color3.fromRGB(26, 30, 27),
        SurfaceContainerHigh = Color3.fromRGB(32, 36, 33),
        SurfaceContainerHighest = Color3.fromRGB(39, 44, 40),
        OnSurface = Color3.fromRGB(226, 227, 222),
        OnSurfaceVariant = Color3.fromRGB(198, 200, 190),
        Outline = Color3.fromRGB(143, 146, 137),
        OutlineVariant = Color3.fromRGB(70, 74, 66),
        Error = Color3.fromRGB(220, 54, 46),
        ErrorContainer = Color3.fromRGB(89, 0, 8),
        OnErrorContainer = Color3.fromRGB(255, 218, 214)
    },
    ["Sunset"] = {
        Name = "日落橙 (Sunset)",
        Primary = Color3.fromRGB(183, 90, 0),
        OnPrimary = Color3.fromRGB(255, 255, 255),
        PrimaryContainer = Color3.fromRGB(255, 220, 190),
        OnPrimaryContainer = Color3.fromRGB(58, 23, 0),
        Secondary = Color3.fromRGB(113, 88, 65),
        SecondaryContainer = Color3.fromRGB(250, 222, 194),
        Tertiary = Color3.fromRGB(95, 101, 59),
        TertiaryContainer = Color3.fromRGB(229, 235, 179),
        Surface = Color3.fromRGB(20, 18, 16),
        SurfaceDim = Color3.fromRGB(20, 18, 16),
        SurfaceBright = Color3.fromRGB(55, 53, 50),
        SurfaceContainerLowest = Color3.fromRGB(14, 12, 11),
        SurfaceContainerLow = Color3.fromRGB(25, 23, 21),
        SurfaceContainer = Color3.fromRGB(29, 27, 25),
        SurfaceContainerHigh = Color3.fromRGB(35, 33, 31),
        SurfaceContainerHighest = Color3.fromRGB(43, 41, 39),
        OnSurface = Color3.fromRGB(237, 225, 215),
        OnSurfaceVariant = Color3.fromRGB(209, 195, 182),
        Outline = Color3.fromRGB(156, 141, 128),
        OutlineVariant = Color3.fromRGB(77, 69, 61),
        Error = Color3.fromRGB(220, 54, 46),
        ErrorContainer = Color3.fromRGB(89, 0, 8),
        OnErrorContainer = Color3.fromRGB(255, 218, 214)
    },
    ["Crimson"] = {
        Name = "赤红玫 (Crimson)",
        Primary = Color3.fromRGB(183, 28, 74),
        OnPrimary = Color3.fromRGB(255, 255, 255),
        PrimaryContainer = Color3.fromRGB(255, 217, 224),
        OnPrimaryContainer = Color3.fromRGB(62, 0, 18),
        Secondary = Color3.fromRGB(113, 82, 87),
        SecondaryContainer = Color3.fromRGB(255, 217, 224),
        Tertiary = Color3.fromRGB(108, 86, 52),
        TertiaryContainer = Color3.fromRGB(249, 222, 179),
        Surface = Color3.fromRGB(20, 16, 17),
        SurfaceDim = Color3.fromRGB(20, 16, 17),
        SurfaceBright = Color3.fromRGB(55, 51, 52),
        SurfaceContainerLowest = Color3.fromRGB(14, 11, 12),
        SurfaceContainerLow = Color3.fromRGB(25, 21, 22),
        SurfaceContainer = Color3.fromRGB(29, 25, 26),
        SurfaceContainerHigh = Color3.fromRGB(35, 31, 32),
        SurfaceContainerHighest = Color3.fromRGB(43, 39, 40),
        OnSurface = Color3.fromRGB(237, 224, 224),
        OnSurfaceVariant = Color3.fromRGB(209, 192, 192),
        Outline = Color3.fromRGB(156, 138, 139),
        OutlineVariant = Color3.fromRGB(79, 66, 66),
        Error = Color3.fromRGB(220, 54, 46),
        ErrorContainer = Color3.fromRGB(89, 0, 8),
        OnErrorContainer = Color3.fromRGB(255, 218, 214)
    },
    ["Slate"] = {
        Name = "青灰岩 (Slate)",
        Primary = Color3.fromRGB(70, 93, 115),
        OnPrimary = Color3.fromRGB(255, 255, 255),
        PrimaryContainer = Color3.fromRGB(204, 226, 255),
        OnPrimaryContainer = Color3.fromRGB(0, 26, 46),
        Secondary = Color3.fromRGB(82, 95, 110),
        SecondaryContainer = Color3.fromRGB(214, 227, 245),
        Tertiary = Color3.fromRGB(98, 86, 118),
        TertiaryContainer = Color3.fromRGB(233, 217, 255),
        Surface = Color3.fromRGB(19, 19, 21),
        SurfaceDim = Color3.fromRGB(19, 19, 21),
        SurfaceBright = Color3.fromRGB(55, 55, 58),
        SurfaceContainerLowest = Color3.fromRGB(13, 13, 15),
        SurfaceContainerLow = Color3.fromRGB(24, 24, 27),
        SurfaceContainer = Color3.fromRGB(28, 28, 31),
        SurfaceContainerHigh = Color3.fromRGB(34, 34, 37),
        SurfaceContainerHighest = Color3.fromRGB(42, 42, 46),
        OnSurface = Color3.fromRGB(232, 226, 226),
        OnSurfaceVariant = Color3.fromRGB(204, 200, 200),
        Outline = Color3.fromRGB(152, 144, 144),
        OutlineVariant = Color3.fromRGB(72, 68, 70),
        Error = Color3.fromRGB(220, 54, 46),
        ErrorContainer = Color3.fromRGB(89, 0, 8),
        OnErrorContainer = Color3.fromRGB(255, 218, 214)
    },
    ["Monochrome"] = {
        Name = "黑白影 (Monochrome)",
        Primary = Color3.fromRGB(0, 0, 0),
        OnPrimary = Color3.fromRGB(255, 255, 255),
        PrimaryContainer = Color3.fromRGB(230, 230, 230),
        OnPrimaryContainer = Color3.fromRGB(0, 0, 0),
        Secondary = Color3.fromRGB(90, 90, 90),
        SecondaryContainer = Color3.fromRGB(220, 220, 220),
        Tertiary = Color3.fromRGB(120, 120, 120),
        TertiaryContainer = Color3.fromRGB(210, 210, 210),
        Surface = Color3.fromRGB(18, 18, 18),
        SurfaceDim = Color3.fromRGB(18, 18, 18),
        SurfaceBright = Color3.fromRGB(50, 50, 50),
        SurfaceContainerLowest = Color3.fromRGB(12, 12, 12),
        SurfaceContainerLow = Color3.fromRGB(22, 22, 22),
        SurfaceContainer = Color3.fromRGB(26, 26, 26),
        SurfaceContainerHigh = Color3.fromRGB(32, 32, 32),
        SurfaceContainerHighest = Color3.fromRGB(40, 40, 40),
        OnSurface = Color3.fromRGB(230, 230, 230),
        OnSurfaceVariant = Color3.fromRGB(195, 195, 195),
        Outline = Color3.fromRGB(140, 140, 140),
        OutlineVariant = Color3.fromRGB(68, 68, 68),
        Error = Color3.fromRGB(180, 40, 40),
        ErrorContainer = Color3.fromRGB(89, 0, 8),
        OnErrorContainer = Color3.fromRGB(255, 218, 214)
    }
}

local CurrentThemeData = Library.Themes["Violet"]

-- ============================================================
-- 辅助函数
-- ============================================================
local function GetFirstChar(str)
    for _, code in utf8.codes(str) do
        return utf8.char(code)
    end
    return string.sub(str, 1, 1)
end

local function Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function ColorLerp(c1, c2, t)
    return Color3.new(
        Lerp(c1.R, c2.R, t),
        Lerp(c1.G, c2.G, t),
        Lerp(c1.B, c2.B, t)
    )
end

-- MD3 悬停/按下状态层透明度
local STATE_HOVER = 0.08
local STATE_PRESSED = 0.12
local STATE_FOCUS = 0.10

-- ============================================================
-- 配置保存/加载
-- ============================================================
local function CheckFolder()
    if not isfolder("InkWind") then
        pcall(function() makefolder("InkWind") end)
    end
end

local function SaveConfig()
    CheckFolder()
    pcall(function()
        writefile(ConfigName, HttpService:JSONEncode(Library.Config))
    end)
end

local CurrentThemeData = Library.Themes["Violet"]

local function LoadConfig()
    CheckFolder()
    if isfile(ConfigName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigName))
        end)
        if success and data then
            for k, v in pairs(data) do
                if DefaultConfig[k] ~= nil then
                    Library.Config[k] = v
                end
            end
            CurrentThemeData = Library.Themes[Library.Config.Theme] or Library.Themes["Violet"]
        end
    end
end
LoadConfig()

-- ============================================================
-- ScreenGui 初始化
-- ============================================================
if game.CoreGui:FindFirstChild("InkWind_GUI") then
    game.CoreGui.InkWind_GUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InkWind_GUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Enabled = false
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- 全屏遮罩 - 防止点击穿透到游戏世界
local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Parent = ScreenGui
Backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
Backdrop.BackgroundTransparency = 1
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.ZIndex = 0
Backdrop.Visible = false
Backdrop.Active = true

-- ============================================================
-- 对象注册系统 (主题/样式统一管理)
-- ============================================================
function RegisterObject(obj, type)
    table.insert(Library.Globals.ThemeObjects, { Object = obj, Type = type })
    local theme = CurrentThemeData

    if type == "Window" then
        obj.BackgroundColor3 = theme.SurfaceContainerHigh
    elseif type == "Header" then
        obj.BackgroundColor3 = theme.SurfaceContainerHighest
    elseif type == "Button" then
        obj.BackgroundColor3 = theme.SurfaceContainerLow
    elseif type == "ButtonActive" then
        obj.BackgroundColor3 = theme.PrimaryContainer
    elseif type == "Text" then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = theme.OnSurface
        end
    elseif type == "TextVariant" then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = theme.OnSurfaceVariant
        end
    elseif type == "TextPrimary" then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = theme.Primary
        end
    elseif type == "OnPrimary" then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = theme.Primary
        end
    elseif type == "OnPrimaryContainer" then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = theme.Primary
        end
    elseif type == "Container" then
        obj.BackgroundColor3 = theme.SurfaceContainer
    elseif type == "ContainerLow" then
        obj.BackgroundColor3 = theme.SurfaceContainerLow
    elseif type == "ContainerHighest" then
        obj.BackgroundColor3 = theme.SurfaceContainerHighest
    elseif type == "Primary" then
        obj.BackgroundColor3 = theme.Primary
    elseif type == "PrimaryContainer" then
        obj.BackgroundColor3 = theme.PrimaryContainer
    elseif type == "SecondaryContainer" then
        obj.BackgroundColor3 = theme.SecondaryContainer
    elseif type == "TertiaryContainer" then
        obj.BackgroundColor3 = theme.TertiaryContainer
    elseif type == "Outline" then
        if obj:IsA("UIStroke") then
            obj.Color = theme.Outline
        else
            obj.BackgroundColor3 = theme.Outline
        end
    elseif type == "OutlineVariant" then
        if obj:IsA("UIStroke") then
            obj.Color = theme.OutlineVariant
        else
            obj.BackgroundColor3 = theme.OutlineVariant
        end
    elseif type == "Stroke" then
        if obj:IsA("UIStroke") then
            obj.Color = theme.OutlineVariant
        end
    elseif type == "PickerBg" then
        obj.BackgroundColor3 = theme.SurfaceContainerHigh
    elseif type == "Scroll" then
        obj.ScrollBarImageColor3 = theme.Outline
    elseif type == "Error" then
        obj.BackgroundColor3 = theme.Error
    elseif type == "NotifGradient" then
        if obj:IsA("UIGradient") then
            obj.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.Primary),
                ColorSequenceKeypoint.new(0.5, theme.PrimaryContainer),
                ColorSequenceKeypoint.new(1, theme.Primary)
            })
        end
    end
end

function Library:RefreshTheme()
    local theme = CurrentThemeData
    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, data in ipairs(Library.Globals.ThemeObjects) do
        local obj = data.Object
        if not obj or not obj.Parent then
            continue
        end

        local targetColor

        if data.Type == "Window" then targetColor = theme.SurfaceContainerHigh
        elseif data.Type == "Header" then targetColor = theme.SurfaceContainerHighest
        elseif data.Type == "Button" then targetColor = theme.SurfaceContainerLow
        elseif data.Type == "ButtonActive" then targetColor = theme.PrimaryContainer
        elseif data.Type == "Container" then targetColor = theme.SurfaceContainer
        elseif data.Type == "ContainerLow" then targetColor = theme.SurfaceContainerLow
        elseif data.Type == "ContainerHighest" then targetColor = theme.SurfaceContainerHighest
        elseif data.Type == "Primary" then targetColor = theme.Primary
        elseif data.Type == "PrimaryContainer" then targetColor = theme.PrimaryContainer
        elseif data.Type == "SecondaryContainer" then targetColor = theme.SecondaryContainer
        elseif data.Type == "TertiaryContainer" then targetColor = theme.TertiaryContainer
        elseif data.Type == "PickerBg" then targetColor = theme.SurfaceContainerHigh
        elseif data.Type == "Error" then targetColor = theme.Error
        else
            targetColor = nil
        end

        if targetColor then
            if obj:IsA("UIStroke") then
                TweenService:Create(obj, tweenInfo, { Color = targetColor }):Play()
            else
                TweenService:Create(obj, tweenInfo, { BackgroundColor3 = targetColor }):Play()
            end
        elseif data.Type == "Text" then
            TweenService:Create(obj, tweenInfo, { TextColor3 = theme.OnSurface }):Play()
        elseif data.Type == "TextVariant" then
            TweenService:Create(obj, tweenInfo, { TextColor3 = theme.OnSurfaceVariant }):Play()
        elseif data.Type == "TextPrimary" then
            TweenService:Create(obj, tweenInfo, { TextColor3 = theme.Primary }):Play()
        elseif data.Type == "OnPrimary" then
            TweenService:Create(obj, tweenInfo, { TextColor3 = theme.OnPrimary }):Play()
        elseif data.Type == "OnPrimaryContainer" then
            TweenService:Create(obj, tweenInfo, { TextColor3 = theme.OnPrimaryContainer }):Play()
        elseif data.Type == "Outline" or data.Type == "OutlineVariant" or data.Type == "Stroke" then
            if obj:IsA("UIStroke") then
                TweenService:Create(obj, tweenInfo, { Color = theme.OutlineVariant }):Play()
            end
        elseif data.Type == "Scroll" then
            TweenService:Create(obj, tweenInfo, { ScrollBarImageColor3 = theme.Outline }):Play()
        elseif data.Type == "NotifGradient" then
            if obj:IsA("UIGradient") then
                obj.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, theme.Primary),
                    ColorSequenceKeypoint.new(0.5, theme.PrimaryContainer),
                    ColorSequenceKeypoint.new(1, theme.Primary)
                })
            end
        end
    end

    self:RefreshStyle()
end

-- ============================================================
-- 样式系统 (圆角/描边)
-- ============================================================
function RegisterStyle(obj, hasStroke, cornerRadius)
    table.insert(Library.Globals.StyleObjects, { Object = obj, HasStroke = hasStroke, Radius = cornerRadius })

    local Corner = obj:FindFirstChild("UICorner") or Instance.new("UICorner")
    Corner.Parent = obj
    Corner.CornerRadius = UDim.new(0, Library.Config.UseCorners and cornerRadius or 0)

    if hasStroke then
        local Stroke = obj:FindFirstChild("UIStroke") or Instance.new("UIStroke")
        Stroke.Parent = obj
        Stroke.Thickness = 1
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        RegisterObject(Stroke, "Stroke")
        Stroke.Color = CurrentThemeData.OutlineVariant
    end
end

function Library:RefreshStyle()
    local useCorners = Library.Config.UseCorners
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, data in ipairs(Library.Globals.StyleObjects) do
        local obj = data.Object
        if obj and obj.Parent then
            local Corner = obj:FindFirstChild("UICorner")
            if Corner then
                TweenService:Create(Corner, tweenInfo, {
                    CornerRadius = UDim.new(0, useCorners and data.Radius or 0)
                }):Play()
            end
        end
    end
end

-- ============================================================
-- 尺寸刷新
-- ============================================================
function Library:RefreshDimensions()
    local conf = Library.Config
    for _, win in ipairs(Library.Globals.Windows) do
        local scale = win.Main:FindFirstChild("UIScale")
        if scale then
            TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Scale = conf.UIScale }):Play()
        end
        if win.RefreshHeight then
            win.RefreshHeight()
        end
        local headerH = conf.ItemHeight + 8
        if win.Header then
            TweenService:Create(win.Header, TweenInfo.new(0.3), { Size = UDim2.new(1, 0, 0, headerH) }):Play()
        end
    end
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    task.wait()
    Library:RefreshDimensions()
end)

-- ============================================================
-- MD3 状态层 (State Layer) - 简洁的悬停/按下效果
-- ============================================================
local function CreateStateLayer(parent, zOffset)
    local StateLayer = Instance.new("Frame")
    StateLayer.Name = "StateLayer"
    StateLayer.Parent = parent
    StateLayer.BackgroundTransparency = 1
    StateLayer.Size = UDim2.new(1, 0, 1, 0)
    StateLayer.BorderSizePixel = 0
    StateLayer.ZIndex = (zOffset or 0) + parent.ZIndex
    StateLayer.Active = false
    StateLayer.Selectable = false

    local Corner = Instance.new("UICorner")
    Corner.Parent = StateLayer

    local parentCorner = parent:FindFirstChild("UICorner")
    if parentCorner then
        Corner.CornerRadius = parentCorner.CornerRadius
    end

    return StateLayer
end

local function ApplyStateHover(stateLayer, color)
    if not stateLayer then return end
    TweenService:Create(stateLayer, TweenInfo.new(0.15), {
        BackgroundColor3 = color or CurrentThemeData.OnSurface,
        BackgroundTransparency = 1 - STATE_HOVER
    }):Play()
end

local function ApplyStatePress(stateLayer, color)
    if not stateLayer then return end
    TweenService:Create(stateLayer, TweenInfo.new(0.1), {
        BackgroundColor3 = color or CurrentThemeData.OnSurface,
        BackgroundTransparency = 1 - STATE_PRESSED
    }):Play()
end

local function ApplyStateDefault(stateLayer)
    if not stateLayer then return end
    TweenService:Create(stateLayer, TweenInfo.new(0.15), {
        BackgroundTransparency = 1
    }):Play()
end

-- ============================================================
-- 灵动岛 (FAB - Floating Action Button 风格)
-- ============================================================
local function ToggleInterface(visible)
    Library.Config.UIVisible = visible
    Backdrop.Visible = visible

    local backdropTween = TweenService:Create(Backdrop, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
        BackgroundTransparency = visible and 0.5 or 1
    })
    backdropTween:Play()

    if not visible and Library.Globals.ActivePicker then
        Library.Globals.ActivePicker:Destroy()
        Library.Globals.ActivePicker = nil
    end

    if Library.Globals.IslandObject then
        local Island = Library.Globals.IslandObject
        if visible then
            TweenService:Create(Island, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
        else
            TweenService:Create(Island, TweenInfo.new(0.3), { BackgroundTransparency = 0.3 }):Play()
        end
    end

    if visible then
        for _, winData in ipairs(Library.Globals.Windows) do
            if winData.IsOpen and not winData.IsSub then
                winData.Main.Visible = true
                TweenService:Create(winData.Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0
                }):Play()
            elseif winData.IsSub then
                -- 子窗口保持原来的显隐状态
            end
        end
    else
        for _, winData in ipairs(Library.Globals.Windows) do
            if winData.Main.Visible then
                TweenService:Create(winData.Main, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1
                }):Play()
            end
        end
        task.delay(0.2, function()
            if not Library.Config.UIVisible then
                for _, w in ipairs(Library.Globals.Windows) do
                    if not w.IsSub then
                        w.Main.Visible = false
                    end
                end
                Backdrop.Visible = false
            end
        end)
    end
end

local function CreateDynamicIsland()
    local Island = Instance.new("TextButton")
    Island.Name = "DynamicIsland"
    Island.Parent = ScreenGui
    Island.Size = UDim2.new(0, 140, 0, 36)
    Island.Position = UDim2.new(0.5, 0, 0, 12)
    Island.AnchorPoint = Vector2.new(0.5, 0)
    Island.BackgroundColor3 = CurrentThemeData.PrimaryContainer
    Island.BackgroundTransparency = Library.Config.UIVisible and 0 or 0.3
    Island.Text = ""
    Island.Font = Enum.Font.GothamBold
    Island.TextSize = 14
    Island.AutoButtonColor = false
    Island.ZIndex = 100
    Island.ClipsDescendants = false

    RegisterObject(Island, "PrimaryContainer")
    RegisterStyle(Island, false, 18)

    local IslandText = Instance.new("TextLabel")
    IslandText.Parent = Island
    IslandText.Text = "Ink Wind"
    IslandText.Font = Enum.Font.GothamSemibold
    IslandText.Size = UDim2.new(1, -16, 1, 0)
    IslandText.Position = UDim2.new(0, 16, 0, 0)
    IslandText.BackgroundTransparency = 1
    IslandText.TextXAlignment = Enum.TextXAlignment.Left
    IslandText.ZIndex = Island.ZIndex + 1
    RegisterObject(IslandText, "OnPrimaryContainer")

    local Icon = Instance.new("TextLabel")
    Icon.Parent = Island
    Icon.Text = "✦"
    Icon.Font = Enum.Font.GothamBlack
    Icon.TextSize = 14
    Icon.Size = UDim2.new(0, 16, 1, 0)
    Icon.Position = UDim2.new(0, 0, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.TextXAlignment = Enum.TextXAlignment.Center
    Icon.ZIndex = Island.ZIndex + 1
    RegisterObject(Icon, "OnPrimaryContainer")

    local IslandState = CreateStateLayer(Island, 1)
    IslandState.Name = "IslandState"

    Library.Globals.IslandObject = Island

    local function UpdatePos()
        Library.Globals.IslandPosition = Island.AbsolutePosition + Vector2.new(Island.AbsoluteSize.X / 2, Island.AbsoluteSize.Y / 2)
    end
    Island:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)
    task.defer(UpdatePos)

    Island.MouseEnter:Connect(function()
        ApplyStateHover(IslandState, CurrentThemeData.OnPrimaryContainer)
        TweenService:Create(Island, TweenInfo.new(0.2), { Size = UDim2.new(0, 150, 0, 40) }):Play()
    end)

    Island.MouseLeave:Connect(function()
        ApplyStateDefault(IslandState)
        TweenService:Create(Island, TweenInfo.new(0.2), { Size = UDim2.new(0, 140, 0, 36) }):Play()
    end)

    Island.MouseButton1Down:Connect(function()
        ApplyStatePress(IslandState, CurrentThemeData.OnPrimaryContainer)
    end)

    Island.MouseButton1Up:Connect(function()
        ApplyStateHover(IslandState, CurrentThemeData.OnPrimaryContainer)
    end)

    Island.MouseButton1Click:Connect(function()
        ToggleInterface(not Library.Config.UIVisible)
    end)
end
CreateDynamicIsland()

-- ============================================================
-- HUD 系统
-- ============================================================
local HUDItems = {}

local HUDFrame = Instance.new("Frame")
HUDFrame.Name = "HUD"
HUDFrame.Parent = ScreenGui
HUDFrame.Position = UDim2.new(1, -12, 0, 12)
HUDFrame.AnchorPoint = Vector2.new(1, 0)
HUDFrame.Size = UDim2.new(0, 0, 1, -24)
HUDFrame.BackgroundTransparency = 1
HUDFrame.Visible = Library.Config.ShowHUD
HUDFrame.AutomaticSize = Enum.AutomaticSize.X

local HUDList = Instance.new("UIListLayout")
HUDList.Parent = HUDFrame
HUDList.HorizontalAlignment = Enum.HorizontalAlignment.Right
HUDList.VerticalAlignment = Enum.VerticalAlignment.Top
HUDList.SortOrder = Enum.SortOrder.LayoutOrder
HUDList.Padding = UDim.new(0, 6)
HUDList.FillDirection = Enum.FillDirection.Vertical

local function UpdateHUD(name, enabled)
    if not Library.Config.ShowHUD then return end

    if enabled then
        if HUDItems[name] then return end

        local Item = Instance.new("Frame")
        Item.Name = "HUD_" .. name
        Item.Parent = HUDFrame
        Item.Size = UDim2.new(0, 0, 0, 28)
        Item.AutomaticSize = Enum.AutomaticSize.X
        Item.BackgroundColor3 = CurrentThemeData.SurfaceContainerLow
        Item.BackgroundTransparency = 0
        Item.BorderSizePixel = 0
        RegisterObject(Item, "ContainerLow")
        RegisterStyle(Item, false, 14)

        local Bar = Instance.new("Frame")
        Bar.Parent = Item
        Bar.Size = UDim2.new(0, 3, 1, 0)
        Bar.Position = UDim2.new(0, 0, 0, 0)
        Bar.BackgroundColor3 = CurrentThemeData.Primary
        Bar.BorderSizePixel = 0
        RegisterObject(Bar, "Primary")
        RegisterStyle(Bar, false, 2)

        local Label = Instance.new("TextLabel")
        Label.Parent = Item
        Label.Text = name
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 13
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, -16, 1, 0)
        Label.Position = UDim2.new(0, 14, 0, 0)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        RegisterObject(Label, "Text")

        HUDItems[name] = Item

        -- 入场动画
        Item.BackgroundTransparency = 1
        Item.Position = UDim2.new(0, 30, 0, Item.Position.Y.Offset)
        TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 0, 0, Item.Position.Y.Offset)
        }):Play()
    else
        local item = HUDItems[name]
        if item then
            HUDItems[name] = nil
            local tweenOut = TweenService:Create(item, TweenInfo.new(0.25), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 40, 0, item.Position.Y.Offset)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                if item and item.Parent then
                    item:Destroy()
                end
            end)
        end
    end
end

function Library:SetHUDVisible(visible)
    Library.Config.ShowHUD = visible
    HUDFrame.Visible = visible
    SaveConfig()
end

-- ============================================================
-- 通知系统 (MD3 Snackbar 风格)
-- ============================================================
function Library:SetNotifsVisible(visible)
    Library.Config.ShowNotifs = visible
    SaveConfig()
end

function Library:Notify(title, status)
    if not Library.Config.ShowNotifs then return end

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = CurrentThemeData.SurfaceContainerHighest
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(0, 220, 0, 48)
    Frame.Position = UDim2.new(1, 30, 1, -12)
    Frame.AnchorPoint = Vector2.new(0, 1)
    Frame.ClipsDescendants = true
    RegisterObject(Frame, "ContainerHighest")
    RegisterStyle(Frame, false, 12)

    local Icon = Instance.new("TextLabel")
    Icon.Parent = Frame
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 8, 0.5, 0)
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.BackgroundColor3 = status and CurrentThemeData.Primary or CurrentThemeData.Error
    Icon.Text = status and "✓" or "✕"
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 14
    Icon.TextColor3 = status and CurrentThemeData.OnPrimary or CurrentThemeData.OnPrimaryContainer
    Icon.TextXAlignment = Enum.TextXAlignment.Center
    Icon.TextYAlignment = Enum.TextYAlignment.Center
    RegisterObject(Icon, status and "Primary" or "Error")
    RegisterStyle(Icon, false, 12)

    local TitleLab = Instance.new("TextLabel")
    TitleLab.Parent = Frame
    TitleLab.Text = title
    TitleLab.Font = Enum.Font.GothamSemibold
    TitleLab.TextSize = 13
    TitleLab.BackgroundTransparency = 1
    TitleLab.Size = UDim2.new(1, -44, 0, 18)
    TitleLab.Position = UDim2.new(0, 40, 0, 8)
    TitleLab.TextXAlignment = Enum.TextXAlignment.Left
    RegisterObject(TitleLab, "Text")

    local StateLab = Instance.new("TextLabel")
    StateLab.Parent = Frame
    StateLab.Text = status and "已启用" or "已关闭"
    StateLab.Font = Enum.Font.Gotham
    StateLab.TextSize = 11
    StateLab.BackgroundTransparency = 1
    StateLab.Size = UDim2.new(1, -44, 0, 16)
    StateLab.Position = UDim2.new(0, 40, 1, -10)
    StateLab.TextXAlignment = Enum.TextXAlignment.Left
    StateLab.TextColor3 = status and CurrentThemeData.OnSurfaceVariant or CurrentThemeData.OnSurfaceVariant
    RegisterObject(StateLab, "TextVariant")

    -- 堆叠定位
    local offset = 0
    for i = #Library.Globals.ActiveNotifs, 1, -1 do
        local n = Library.Globals.ActiveNotifs[i]
        if n and n.Parent then
            offset = offset + 56
        end
    end

    table.insert(Library.Globals.ActiveNotifs, Frame)

    -- 入场动画
    local targetPos = UDim2.new(1, -12, 1, -12 - offset)
    Frame.Position = UDim2.new(1, 40, Frame.Position.Y.Scale, Frame.Position.Y.Offset)
    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = targetPos
    }):Play()

    -- 倒计时
    local duration = Library.Config.NotifDuration
    task.delay(duration, function()
        for i, v in ipairs(Library.Globals.ActiveNotifs) do
            if v == Frame then
                table.remove(Library.Globals.ActiveNotifs, i)
                break
            end
        end

        local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.25), {
            Position = Frame.Position + UDim2.new(0, 260, 0, 0)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            if Frame and Frame.Parent then
                Frame:Destroy()
            end
        end)
    end)
end

-- ============================================================
-- 主题切换
-- ============================================================
function Library:SetTheme(themeName)
    if Library.Themes[themeName] then
        CurrentThemeData = Library.Themes[themeName]
        Library.Config.Theme = themeName
        self:RefreshTheme()
        SaveConfig()
    end
end

-- ============================================================
-- 按键绑定
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Library.Globals.BoundKeys[input.KeyCode] then
        Library.Globals.BoundKeys[input.KeyCode](true)
    end
end)

-- ============================================================
-- 窗口系统
-- ============================================================
local function ClampWindowPosition(mainFrame)
    local screenSize = Camera.ViewportSize
    local frameSize = mainFrame.AbsoluteSize
    local x = math.clamp(mainFrame.Position.X.Offset, 0, screenSize.X - frameSize.X)
    local y = math.clamp(mainFrame.Position.Y.Offset, 0, screenSize.Y - frameSize.Y)
    mainFrame.Position = UDim2.new(0, x, 0, y)
end

function Library:CreateWindow(title, pos, isMain, isSub)
    local Window = {}
    local isFolded = false
    local isOpen = not isSub
    if isSub and not Library.Config.UIVisible then isOpen = false end

    local HeaderH = Library.Config.ItemHeight + 8
    local winWidth = Library.Config.WindowWidth

    local Main = Instance.new("Frame")
    Main.Name = "Window_" .. title
    Main.Parent = ScreenGui
    Main.Position = pos or UDim2.new(0, 20, 0, 60)
    Main.Size = UDim2.new(0, winWidth, 0, HeaderH)
    Main.BorderSizePixel = 0
    Main.Visible = isOpen
    Main.ZIndex = 10
    Main.ClipsDescendants = true
    RegisterObject(Main, "Window")
    RegisterStyle(Main, false, 16)

    ClampWindowPosition(Main)

    local Scale = Instance.new("UIScale")
    Scale.Parent = Main
    Scale.Scale = Library.Config.UIScale

    -- 顶部 Header (MD3 Top App Bar 风格)
    local Header = Instance.new("Frame")
    Header.Parent = Main
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1, 0, 0, HeaderH)
    Header.Active = true

    -- Header 状态层
    local HeaderState = CreateStateLayer(Header, 1)

    -- 标题
    local TitleContainer = Instance.new("Frame")
    TitleContainer.Parent = Header
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Size = UDim2.new(1, -20, 1, 0)
    TitleContainer.Position = UDim2.new(0, 16, 0, 0)

    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleContainer
    TitleText.Text = title
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = math.clamp(HeaderH * 0.4, 13, 16)
    TitleText.Size = UDim2.new(1, 0, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.TextYAlignment = Enum.TextYAlignment.Center
    TitleText.ZIndex = Header.ZIndex + 2
    RegisterObject(TitleText, "Text")

    local TitleSub = Instance.new("TextLabel")
    TitleSub.Parent = TitleContainer
    TitleSub.Text = "• Ink Wind"
    TitleSub.Font = Enum.Font.Gotham
    TitleSub.TextSize = 10
    TitleSub.Size = UDim2.new(1, 0, 0, 14)
    TitleSub.Position = UDim2.new(0, 0, 0.5, 8)
    TitleSub.BackgroundTransparency = 1
    TitleSub.TextXAlignment = Enum.TextXAlignment.Left
    TitleSub.ZIndex = Header.ZIndex + 2
    RegisterObject(TitleSub, "TextPrimary")

    -- 折叠指示器 (右侧)
    local FoldIndicator = Instance.new("TextLabel")
    FoldIndicator.Parent = Header
    FoldIndicator.Text = "▾"
    FoldIndicator.Font = Enum.Font.Gotham
    FoldIndicator.TextSize = 14
    FoldIndicator.Size = UDim2.new(0, 24, 0, 24)
    FoldIndicator.Position = UDim2.new(1, -8, 0.5, 0)
    FoldIndicator.AnchorPoint = Vector2.new(1, 0.5)
    FoldIndicator.BackgroundTransparency = 1
    FoldIndicator.TextXAlignment = Enum.TextXAlignment.Center
    FoldIndicator.TextYAlignment = Enum.TextYAlignment.Center
    FoldIndicator.ZIndex = Header.ZIndex + 2
    RegisterObject(FoldIndicator, "TextPrimary")

    -- 分隔线
    local Divider = Instance.new("Frame")
    Divider.Parent = Main
    Divider.Size = UDim2.new(1, -24, 0, 1)
    Divider.Position = UDim2.new(0, 12, 0, HeaderH)
    Divider.BackgroundColor3 = CurrentThemeData.OutlineVariant
    Divider.BackgroundTransparency = 0.5
    Divider.BorderSizePixel = 0
    RegisterObject(Divider, "OutlineVariant")

    -- 内容滚动区域
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0, 0, 0, HeaderH + 4)
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.ScrollBarThickness = 3
    Container.ScrollBarImageTransparency = 0.5
    RegisterObject(Container, "Scroll")
    RegisterStyle(Container, false, 0)

    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.Parent = Container
    ContentPadding.PaddingTop = UDim.new(0, 8)
    ContentPadding.PaddingBottom = UDim.new(0, 8)
    ContentPadding.PaddingLeft = UDim.new(0, 8)
    ContentPadding.PaddingRight = UDim.new(0, 8)

    local List = Instance.new("UIListLayout")
    List.Parent = Container
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0, 4)

    local winData = {
        Main = Main,
        Header = Header,
        Title = TitleText,
        Container = Container,
        List = List,
        IsOpen = isOpen,
        IsSub = isSub or false,
        RefreshHeight = nil
    }
    table.insert(Library.Globals.Windows, winData)
    if isSub then
        Library.Globals.SubWindows[title] = winData
    end

    -- 高度自适应
    local function RefreshHeight()
        local contentH = List.AbsoluteContentSize.Y + 16
        local screenHeight = Camera.ViewportSize.Y / (Library.Config.UIScale > 0 and Library.Config.UIScale or 1)
        local maxPerScreen = screenHeight - 120
        if maxPerScreen < 120 then maxPerScreen = 120 end
        local actualMax = math.min(Library.Config.WindowMaxHeight, maxPerScreen)
        local curHeadH = Library.Config.ItemHeight + 8

        if isFolded then
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, Library.Config.WindowWidth, 0, curHeadH)
            }):Play()
            Container.Visible = false
        else
            Container.Visible = true
            local finalH = math.min(contentH, actualMax)
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, Library.Config.WindowWidth, 0, curHeadH + 4 + finalH)
            }):Play()
            Container.Size = UDim2.new(1, 0, 0, finalH)
            Container.CanvasSize = UDim2.new(0, 0, 0, contentH)
            Container.ScrollingEnabled = contentH > actualMax
        end
    end
    winData.RefreshHeight = RefreshHeight

    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshHeight)
    task.defer(RefreshHeight)

    -- 拖拽逻辑
    local isDragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()
    local dragTime = 0
    local dragStartPos = Vector2.new()

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Library.Globals.TopZIndex = Library.Globals.TopZIndex + 1
            Main.ZIndex = Library.Globals.TopZIndex

            isDragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Main.Position
            dragTime = tick()
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)

            ApplyStateHover(HeaderState, CurrentThemeData.OnSurface)

            if Library.Globals.ActivePicker then
                Library.Globals.ActivePicker:Destroy()
                Library.Globals.ActivePicker = nil
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            
            local screenSize = Camera.ViewportSize
            local frameSize = Main.AbsoluteSize
            newX = math.clamp(newX, 0, screenSize.X - frameSize.X)
            newY = math.clamp(newY, 0, screenSize.Y - frameSize.Y)
            
            Main.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ApplyStateDefault(HeaderState)

            local endPos = Vector2.new(input.Position.X, input.Position.Y)
            local moved = (endPos - dragStartPos).Magnitude
            local elapsed = tick() - dragTime

            if moved < 5 and elapsed < 0.3 then
                isFolded = not isFolded
                TweenService:Create(FoldIndicator, TweenInfo.new(0.2), {
                    Rotation = isFolded and -90 or 0
                }):Play()
                RefreshHeight()
            end

            isDragging = false
        end
    end)

    -- 窗口元素注册表
    local function RegElem(inst)
        table.insert(Library.Globals.Elements, { Instance = inst })
    end

    -- ============================================================
    -- MD3 Filled Button
    -- ============================================================
    function Window:CreateButton(name, callback)
        local H = Library.Config.ItemHeight

        local Btn = Instance.new("TextButton")
        Btn.Parent = Container
        Btn.BackgroundColor3 = CurrentThemeData.PrimaryContainer
        Btn.BackgroundTransparency = 0
        Btn.Size = UDim2.new(1, -16, 0, H)
        Btn.Position = UDim2.new(0, 8, 0, 0)
        Btn.Text = ""
        Btn.BorderSizePixel = 0
        Btn.AutoButtonColor = false
        Btn.LayoutOrder = #Library.Globals.Elements
        RegisterObject(Btn, "PrimaryContainer")
        RegisterStyle(Btn, false, 10)

        local State = CreateStateLayer(Btn, 1)

        local Icon = Instance.new("TextLabel")
        Icon.Parent = Btn
        Icon.Text = "→"
        Icon.Font = Enum.Font.GothamBold
        Icon.TextSize = 14
        Icon.Size = UDim2.new(0, 24, 0, 24)
        Icon.Position = UDim2.new(0, 12, 0.5, 0)
        Icon.AnchorPoint = Vector2.new(0, 0.5)
        Icon.BackgroundTransparency = 1
        Icon.TextXAlignment = Enum.TextXAlignment.Center
        Icon.TextYAlignment = Enum.TextYAlignment.Center
        Icon.ZIndex = Btn.ZIndex + 2
        RegisterObject(Icon, "OnPrimaryContainer")

        local Label = Instance.new("TextLabel")
        Label.Parent = Btn
        Label.Text = name
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = math.clamp(H * 0.35, 11, 14)
        Label.Size = UDim2.new(1, -44, 1, 0)
        Label.Position = UDim2.new(0, 38, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.ZIndex = Btn.ZIndex + 2
        RegisterObject(Label, "OnPrimaryContainer")

        Btn.MouseEnter:Connect(function()
            ApplyStateHover(State, CurrentThemeData.OnPrimaryContainer)
        end)
        Btn.MouseLeave:Connect(function()
            ApplyStateDefault(State)
        end)
        Btn.MouseButton1Down:Connect(function()
            ApplyStatePress(State, CurrentThemeData.OnPrimaryContainer)
        end)
        Btn.MouseButton1Up:Connect(function()
            ApplyStateHover(State, CurrentThemeData.OnPrimaryContainer)
        end)
        Btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)

        RegElem(Btn)
        task.defer(RefreshHeight)
        return Btn
    end

    -- ============================================================
    -- MD3 Text Button (次要操作)
    -- ============================================================
    function Window:CreateTextButton(name, callback)
        local H = Library.Config.ItemHeight - 4

        local Btn = Instance.new("TextButton")
        Btn.Parent = Container
        Btn.BackgroundTransparency = 1
        Btn.Size = UDim2.new(1, -16, 0, H)
        Btn.Position = UDim2.new(0, 8, 0, 0)
        Btn.Text = ""
        Btn.BorderSizePixel = 0
        Btn.AutoButtonColor = false
        Btn.LayoutOrder = #Library.Globals.Elements
        RegisterStyle(Btn, false, 10)

        local State = CreateStateLayer(Btn, 1)

        local Label = Instance.new("TextLabel")
        Label.Parent = Btn
        Label.Text = name
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = math.clamp(H * 0.4, 11, 13)
        Label.Size = UDim2.new(1, -16, 1, 0)
        Label.Position = UDim2.new(0, 16, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.ZIndex = Btn.ZIndex + 2
        RegisterObject(Label, "TextPrimary")

        Btn.MouseEnter:Connect(function()
            ApplyStateHover(State, CurrentThemeData.Primary)
        end)
        Btn.MouseLeave:Connect(function()
            ApplyStateDefault(State)
        end)
        Btn.MouseButton1Down:Connect(function()
            ApplyStatePress(State, CurrentThemeData.Primary)
        end)
        Btn.MouseButton1Up:Connect(function()
            ApplyStateHover(State, CurrentThemeData.Primary)
        end)
        Btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)

        RegElem(Btn)
        task.defer(RefreshHeight)
        return Btn
    end

    -- ============================================================
    -- 子窗口绑定
    -- ============================================================
    function Window:BindWindow(subWindowName, defaultState)
        local Mod = self:CreateModule(subWindowName, function(bool)
            local target = Library.Globals.SubWindows[subWindowName]
            if target then
                target.IsOpen = bool
                target.Main.Visible = bool

                if bool then
                    if target.Main.Position.X.Offset == 0 and target.Main.Position.Y.Offset == 0 then
                        target.Main.Position = UDim2.new(0.5, -Library.Config.WindowWidth / 2, 0.5, -100)
                    end
                    TweenService:Create(target.Main, TweenInfo.new(0.25), {
                        BackgroundTransparency = 0
                    }):Play()
                end
            else
                Library:Notify("未找到: " .. subWindowName, false)
            end
        end, false)
        if defaultState then Mod:Set(true) end
    end

    -- ============================================================
    -- MD3 模块开关 (Switch Row + Settings Panel)
    -- ============================================================
    function Window:CreateModule(name, callback, allowBind)
        if allowBind == nil then allowBind = true end

        local Mod = {}
        local enabled = false
        local isSetOpen = false
        local bindKey = nil
        local H = Library.Config.ItemHeight

        -- 主按钮行 (MD3 List Item)
        local Btn = Instance.new("TextButton")
        Btn.Parent = Container
        Btn.BackgroundTransparency = 1
        Btn.Size = UDim2.new(1, 0, 0, H)
        Btn.Text = ""
        Btn.BorderSizePixel = 0
        Btn.AutoButtonColor = false
        Btn.ClipsDescendants = true
        Btn.LayoutOrder = #Library.Globals.Elements
        RegisterStyle(Btn, false, 10)

        local State = CreateStateLayer(Btn, 1)

        -- 左侧图标 (小圆形)
        local IconContainer = Instance.new("Frame")
        IconContainer.Parent = Btn
        IconContainer.Size = UDim2.new(0, 20, 0, 20)
        IconContainer.Position = UDim2.new(0, 12, 0.5, 0)
        IconContainer.AnchorPoint = Vector2.new(0, 0.5)
        IconContainer.BackgroundColor3 = CurrentThemeData.SecondaryContainer
        IconContainer.BorderSizePixel = 0
        RegisterObject(IconContainer, "SecondaryContainer")
        RegisterStyle(IconContainer, false, 10)

        local IconText = Instance.new("TextLabel")
        IconText.Parent = IconContainer
        IconText.Text = "●"
        IconText.Font = Enum.Font.GothamBold
        IconText.TextSize = 10
        IconText.Size = UDim2.new(1, 0, 1, 0)
        IconText.BackgroundTransparency = 1
        IconText.TextXAlignment = Enum.TextXAlignment.Center
        IconText.TextYAlignment = Enum.TextYAlignment.Center
        IconText.ZIndex = IconContainer.ZIndex + 1
        RegisterObject(IconText, "OnPrimaryContainer")

        -- 标题文本
        local Label = Instance.new("TextLabel")
        Label.Parent = Btn
        Label.Text = name
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = math.clamp(H * 0.35, 11, 14)
        Label.Size = UDim2.new(1, -100, 1, 0)
        Label.Position = UDim2.new(0, 40, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.ZIndex = Btn.ZIndex + 2
        RegisterObject(Label, "TextVariant")

        -- MD3 Switch (开关轨道)
        local SwitchTrack = Instance.new("Frame")
        SwitchTrack.Parent = Btn
        SwitchTrack.Size = UDim2.new(0, 44, 0, 24)
        SwitchTrack.Position = UDim2.new(1, -12, 0.5, 0)
        SwitchTrack.AnchorPoint = Vector2.new(1, 0.5)
        SwitchTrack.BackgroundColor3 = CurrentThemeData.SurfaceContainerHighest
        SwitchTrack.BorderSizePixel = 0
        SwitchTrack.ZIndex = Btn.ZIndex + 3
        RegisterObject(SwitchTrack, "ContainerHighest")
        RegisterStyle(SwitchTrack, false, 12)

        local SwitchStroke = Instance.new("UIStroke")
        SwitchStroke.Parent = SwitchTrack
        SwitchStroke.Thickness = 2
        SwitchStroke.Color = CurrentThemeData.Outline
        SwitchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        RegisterObject(SwitchStroke, "Outline")

        -- 开关拇指
        local SwitchThumb = Instance.new("Frame")
        SwitchThumb.Parent = SwitchTrack
        SwitchThumb.Size = UDim2.new(0, 16, 0, 16)
        SwitchThumb.Position = UDim2.new(0, 4, 0.5, 0)
        SwitchThumb.AnchorPoint = Vector2.new(0, 0.5)
        SwitchThumb.BackgroundColor3 = CurrentThemeData.Outline
        SwitchThumb.BorderSizePixel = 0
        SwitchThumb.ZIndex = SwitchTrack.ZIndex + 1
        RegisterObject(SwitchThumb, "Outline")
        RegisterStyle(SwitchThumb, false, 8)

        -- 设置展开按钮
        local ExpandBtn = Instance.new("TextButton")
        ExpandBtn.Parent = Btn
        ExpandBtn.Visible = allowBind
        ExpandBtn.Size = UDim2.new(0, 28, 0, 28)
        ExpandBtn.Position = UDim2.new(1, -60, 0.5, 0)
        ExpandBtn.AnchorPoint = Vector2.new(1, 0.5)
        ExpandBtn.BackgroundTransparency = 1
        ExpandBtn.Text = ""
        ExpandBtn.AutoButtonColor = false
        ExpandBtn.ZIndex = Btn.ZIndex + 3

        local ExpandState = CreateStateLayer(ExpandBtn, 1)
        RegisterStyle(ExpandBtn, false, 8)

        local ExpandIcon = Instance.new("TextLabel")
        ExpandIcon.Parent = ExpandBtn
        ExpandIcon.Text = "▾"
        ExpandIcon.Font = Enum.Font.GothamBold
        ExpandIcon.TextSize = 12
        ExpandIcon.Size = UDim2.new(1, 0, 1, 0)
        ExpandIcon.BackgroundTransparency = 1
        ExpandIcon.TextXAlignment = Enum.TextXAlignment.Center
        ExpandIcon.TextYAlignment = Enum.TextYAlignment.Center
        ExpandIcon.ZIndex = ExpandBtn.ZIndex + 2
        ExpandIcon.Rotation = 0
        RegisterObject(ExpandIcon, "TextPrimary")

        RegElem(Btn)

        -- 子设置面板
        local SetFrame = Instance.new("Frame")
        SetFrame.Parent = Container
        SetFrame.BackgroundColor3 = CurrentThemeData.SurfaceContainer
        SetFrame.BackgroundTransparency = 0
        SetFrame.Size = UDim2.new(1, 0, 0, 0)
        SetFrame.ClipsDescendants = true
        SetFrame.Visible = false
        SetFrame.BorderSizePixel = 0
        SetFrame.LayoutOrder = #Library.Globals.Elements + 1
        RegisterObject(SetFrame, "Container")
        RegisterStyle(SetFrame, false, 10)

        local SetPadding = Instance.new("UIPadding")
        SetPadding.Parent = SetFrame
        SetPadding.PaddingTop = UDim.new(0, 8)
        SetPadding.PaddingBottom = UDim.new(0, 8)
        SetPadding.PaddingLeft = UDim.new(0, 8)
        SetPadding.PaddingRight = UDim.new(0, 8)

        local SetList = Instance.new("UIListLayout")
        SetList.Parent = SetFrame
        SetList.SortOrder = Enum.SortOrder.LayoutOrder
        SetList.Padding = UDim.new(0, 6)

        -- 切换开关状态
        local function Toggle()
            enabled = not enabled

            -- 更新轨道
            TweenService:Create(SwitchTrack, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and CurrentThemeData.Primary or CurrentThemeData.SurfaceContainerHighest
            }):Play()
            SwitchStroke.Enabled = not enabled
            TweenService:Create(SwitchStroke, TweenInfo.new(0.2), {
                Transparency = enabled and 1 or 0
            }):Play()

            -- 更新拇指位置和颜色
            TweenService:Create(SwitchThumb, TweenInfo.new(0.2), {
                Position = enabled and UDim2.new(1, -4, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
                Size = enabled and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = enabled and CurrentThemeData.OnPrimary or CurrentThemeData.Outline
            }):Play()

            -- 更新图标容器
            TweenService:Create(IconContainer, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and CurrentThemeData.Primary or CurrentThemeData.SecondaryContainer
            }):Play()

            -- 更新文字
            RegisterObject(Label, enabled and "Text" or "TextVariant")
            Label.TextColor3 = enabled and CurrentThemeData.OnSurface or CurrentThemeData.OnSurfaceVariant

            UpdateHUD(name, enabled)
            Library:Notify(name, enabled)
            pcall(callback, enabled)
        end

        function Mod:Set(bool)
            if bool ~= nil and bool ~= enabled then
                Toggle()
            end
        end

        -- 交互事件
        Btn.MouseEnter:Connect(function()
            ApplyStateHover(State, CurrentThemeData.OnSurface)
        end)
        Btn.MouseLeave:Connect(function()
            ApplyStateDefault(State)
        end)
        Btn.MouseButton1Down:Connect(function()
            ApplyStatePress(State, CurrentThemeData.OnSurface)
        end)
        Btn.MouseButton1Up:Connect(function()
            ApplyStateHover(State, CurrentThemeData.OnSurface)
        end)

        if allowBind then
            local pressTime = 0
            local pressPos = Vector2.new()
            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    pressTime = tick()
                    pressPos = Vector2.new(input.Position.X, input.Position.Y)
                end
            end)
            Btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local endPos = Vector2.new(input.Position.X, input.Position.Y)
                    local moved = (endPos - pressPos).Magnitude
                    local elapsed = tick() - pressTime
                    if moved < 10 then
                        if elapsed >= 0.6 then
                            CreateMobileWidget(name, Toggle, function() return enabled end)
                            Library:Notify("悬浮窗已创建", true)
                        else
                            Toggle()
                        end
                    end
                end
            end)
        else
            Btn.MouseButton1Click:Connect(Toggle)
        end

        -- 展开设置面板
        ExpandBtn.MouseEnter:Connect(function()
            ApplyStateHover(ExpandState, CurrentThemeData.Primary)
        end)
        ExpandBtn.MouseLeave:Connect(function()
            ApplyStateDefault(ExpandState)
        end)
        ExpandBtn.MouseButton1Click:Connect(function()
            isSetOpen = not isSetOpen
            SetFrame.Visible = true
            local targetHeight = isSetOpen and (SetList.AbsoluteContentSize.Y + 16) or 0

            TweenService:Create(SetFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            }):Play()
            TweenService:Create(ExpandIcon, TweenInfo.new(0.2), {
                Rotation = isSetOpen and 180 or 0
            }):Play()

            if not isSetOpen then
                task.delay(0.25, function()
                    if not isSetOpen and SetFrame then SetFrame.Visible = false end
                end)
            end
            task.defer(RefreshHeight)
        end)

        -- === 模块: Slider ===
        function Mod:CreateSlider(txt, min, max, def, call)
            if not ExpandBtn.Visible then ExpandBtn.Visible = true end
            local v = def or min

            local Row = Instance.new("Frame")
            Row.Parent = SetFrame
            Row.BackgroundTransparency = 1
            Row.Size = UDim2.new(1, 0, 0, 44)
            Row.LayoutOrder = #Row.Parent:GetChildren()
            RegisterStyle(Row, false, 0)

            local LabelRow = Instance.new("TextLabel")
            LabelRow.Parent = Row
            LabelRow.Text = txt
            LabelRow.Font = Enum.Font.GothamSemibold
            LabelRow.TextSize = 12
            LabelRow.BackgroundTransparency = 1
            LabelRow.Size = UDim2.new(0.5, 0, 0, 18)
            LabelRow.Position = UDim2.new(0, 4, 0, 4)
            LabelRow.TextXAlignment = Enum.TextXAlignment.Left
            RegisterObject(LabelRow, "Text")

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = Row
            ValueLabel.Text = tostring(v)
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 12
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Size = UDim2.new(0.5, -4, 0, 18)
            ValueLabel.Position = UDim2.new(0.5, 0, 0, 4)
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            RegisterObject(ValueLabel, "TextPrimary")

            local TrackBg = Instance.new("Frame")
            TrackBg.Parent = Row
            TrackBg.Size = UDim2.new(1, -8, 0, 4)
            TrackBg.Position = UDim2.new(0, 4, 1, -12)
            TrackBg.BackgroundColor3 = CurrentThemeData.SurfaceContainerHighest
            TrackBg.BorderSizePixel = 0
            RegisterObject(TrackBg, "ContainerHighest")
            RegisterStyle(TrackBg, false, 2)

            local TrackFill = Instance.new("Frame")
            TrackFill.Parent = TrackBg
            TrackFill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
            TrackFill.BackgroundColor3 = CurrentThemeData.Primary
            TrackFill.BorderSizePixel = 0
            RegisterObject(TrackFill, "Primary")
            RegisterStyle(TrackFill, false, 2)

            local Thumb = Instance.new("Frame")
            Thumb.Parent = TrackBg
            Thumb.Size = UDim2.new(0, 10, 0, 10)
            Thumb.Position = UDim2.new((v - min) / (max - min), 0, 0.5, 0)
            Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
            Thumb.BackgroundColor3 = CurrentThemeData.Primary
            Thumb.BorderSizePixel = 0
            RegisterObject(Thumb, "Primary")
            RegisterStyle(Thumb, false, 5)

            local Hitbox = Instance.new("TextButton")
            Hitbox.Parent = Row
            Hitbox.Size = UDim2.new(1, 0, 1, -20)
            Hitbox.Position = UDim2.new(0, 0, 0, 20)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""
            Hitbox.AutoButtonColor = false
            Hitbox.ZIndex = Row.ZIndex + 5

            local dragging = false
            local function UpdateValue(newV)
                v = math.floor(Clamp(newV, min, max) + 0.5)
                local p = (v - min) / (max - min)
                TrackFill.Size = UDim2.new(p, 0, 1, 0)
                Thumb.Position = UDim2.new(p, 0, 0.5, 0)
                ValueLabel.Text = tostring(v)
                pcall(call, v)
            end

            Hitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local p = Clamp((input.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                    UpdateValue(min + (max - min) * p)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local p = Clamp((input.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                    UpdateValue(min + (max - min) * p)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            task.defer(RefreshHeight)
            return Mod
        end

        -- === 模块: Switch ===
        function Mod:CreateSwitch(txt, call, defaultState)
            if not ExpandBtn.Visible then ExpandBtn.Visible = true end
            local on = defaultState or false

            local Row = Instance.new("Frame")
            Row.Parent = SetFrame
            Row.BackgroundTransparency = 1
            Row.Size = UDim2.new(1, 0, 0, 36)
            Row.LayoutOrder = #Row.Parent:GetChildren()

            local LabelSw = Instance.new("TextLabel")
            LabelSw.Parent = Row
            LabelSw.Text = txt
            LabelSw.Font = Enum.Font.Gotham
            LabelSw.TextSize = 12
            LabelSw.BackgroundTransparency = 1
            LabelSw.Size = UDim2.new(1, -60, 1, 0)
            LabelSw.Position = UDim2.new(0, 4, 0, 0)
            LabelSw.TextXAlignment = Enum.TextXAlignment.Left
            LabelSw.TextYAlignment = Enum.TextYAlignment.Center
            RegisterObject(LabelSw, "Text")

            local Track2 = Instance.new("Frame")
            Track2.Parent = Row
            Track2.Size = UDim2.new(0, 36, 0, 20)
            Track2.Position = UDim2.new(1, -4, 0.5, 0)
            Track2.AnchorPoint = Vector2.new(1, 0.5)
            Track2.BackgroundColor3 = on and CurrentThemeData.Primary or CurrentThemeData.SurfaceContainerHighest
            Track2.BorderSizePixel = 0
            RegisterObject(Track2, on and "Primary" or "ContainerHighest")
            RegisterStyle(Track2, false, 10)

            local TrackStroke = Instance.new("UIStroke")
            TrackStroke.Parent = Track2
            TrackStroke.Thickness = 1.5
            TrackStroke.Color = CurrentThemeData.Outline
            TrackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            TrackStroke.Transparency = on and 1 or 0

            local Thumb2 = Instance.new("Frame")
            Thumb2.Parent = Track2
            Thumb2.Size = on and UDim2.new(0, 16, 0, 16) or UDim2.new(0, 12, 0, 12)
            Thumb2.Position = on and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
            Thumb2.AnchorPoint = Vector2.new(on and 1 or 0, 0.5)
            Thumb2.BackgroundColor3 = on and CurrentThemeData.OnPrimary or CurrentThemeData.Outline
            Thumb2.BorderSizePixel = 0
            RegisterObject(Thumb2, on and "OnPrimary" or "Outline")
            RegisterStyle(Thumb2, false, 8)

            local HitboxSw = Instance.new("TextButton")
            HitboxSw.Parent = Row
            HitboxSw.Size = UDim2.new(0, 60, 1, 0)
            HitboxSw.Position = UDim2.new(1, 0, 0, 0)
            HitboxSw.AnchorPoint = Vector2.new(1, 0)
            HitboxSw.BackgroundTransparency = 1
            HitboxSw.Text = ""
            HitboxSw.AutoButtonColor = false
            HitboxSw.ZIndex = Row.ZIndex + 5

            HitboxSw.MouseButton1Click:Connect(function()
                on = not on
                TweenService:Create(Track2, TweenInfo.new(0.2), {
                    BackgroundColor3 = on and CurrentThemeData.Primary or CurrentThemeData.SurfaceContainerHighest
                }):Play()
                TweenService:Create(TrackStroke, TweenInfo.new(0.2), {
                    Transparency = on and 1 or 0
                }):Play()
                TweenService:Create(Thumb2, TweenInfo.new(0.2), {
                    Size = on and UDim2.new(0, 16, 0, 16) or UDim2.new(0, 12, 0, 12),
                    Position = on and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
                    AnchorPoint = Vector2.new(on and 1 or 0, 0.5),
                    BackgroundColor3 = on and CurrentThemeData.OnPrimary or CurrentThemeData.Outline
                }):Play()
                pcall(call, on)
            end)

            if on then pcall(call, on) end
            return Mod
        end

        -- === 模块: Dropdown ===
        function Mod:CreateDropdown(txt, opts, call)
            if not ExpandBtn.Visible then ExpandBtn.Visible = true end
            local isOpen = false
            local H = 36

            local Base = Instance.new("Frame")
            Base.Parent = SetFrame
            Base.BackgroundTransparency = 1
            Base.Size = UDim2.new(1, 0, 0, H)
            Base.ClipsDescendants = true
            Base.LayoutOrder = #Base.Parent:GetChildren()

            local MainBtn = Instance.new("TextButton")
            MainBtn.Parent = Base
            MainBtn.BackgroundColor3 = CurrentThemeData.SurfaceContainerLow
            MainBtn.Size = UDim2.new(1, 0, 0, H)
            MainBtn.Text = ""
            MainBtn.AutoButtonColor = false
            MainBtn.BorderSizePixel = 0
            RegisterObject(MainBtn, "ContainerLow")
            RegisterStyle(MainBtn, false, 8)

            local MainState = CreateStateLayer(MainBtn, 1)

            local MainLabel = Instance.new("TextLabel")
            MainLabel.Parent = MainBtn
            MainLabel.Text = txt
            MainLabel.Font = Enum.Font.Gotham
            MainLabel.TextSize = 12
            MainLabel.BackgroundTransparency = 1
            MainLabel.Size = UDim2.new(1, -28, 1, 0)
            MainLabel.Position = UDim2.new(0, 12, 0, 0)
            MainLabel.TextXAlignment = Enum.TextXAlignment.Left
            MainLabel.TextYAlignment = Enum.TextYAlignment.Center
            MainLabel.ZIndex = MainBtn.ZIndex + 2
            RegisterObject(MainLabel, "Text")

            local Arrow = Instance.new("TextLabel")
            Arrow.Parent = MainBtn
            Arrow.Text = "▾"
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 10
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Position = UDim2.new(1, -6, 0.5, 0)
            Arrow.AnchorPoint = Vector2.new(1, 0.5)
            Arrow.BackgroundTransparency = 1
            Arrow.TextXAlignment = Enum.TextXAlignment.Center
            Arrow.TextYAlignment = Enum.TextYAlignment.Center
            Arrow.ZIndex = MainBtn.ZIndex + 2
            RegisterObject(Arrow, "TextPrimary")

            local OptionsFrame = Instance.new("ScrollingFrame")
            OptionsFrame.Parent = Base
            OptionsFrame.Position = UDim2.new(0, 0, 0, H + 2)
            OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
            OptionsFrame.BackgroundTransparency = 1
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.ScrollBarThickness = 2
            OptionsFrame.ScrollBarImageTransparency = 0.5
            OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            OptionsFrame.ScrollingEnabled = false

            local OptList = Instance.new("UIListLayout")
            OptList.Parent = OptionsFrame
            OptList.Padding = UDim.new(0, 2)
            OptList.SortOrder = Enum.SortOrder.LayoutOrder

            for i, opt in ipairs(opts) do
                local Ob = Instance.new("TextButton")
                Ob.Parent = OptionsFrame
                Ob.Size = UDim2.new(1, 0, 0, 28)
                Ob.BackgroundColor3 = CurrentThemeData.SurfaceContainerLow
                Ob.BackgroundTransparency = 0.2
                Ob.Text = opt
                Ob.Font = Enum.Font.Gotham
                Ob.TextSize = 11
                Ob.TextColor3 = CurrentThemeData.OnSurfaceVariant
                Ob.AutoButtonColor = false
                Ob.BorderSizePixel = 0
                Ob.TextXAlignment = Enum.TextXAlignment.Left
                Ob.TextYAlignment = Enum.TextYAlignment.Center
                RegisterObject(Ob, "ContainerLow")
                RegisterStyle(Ob, false, 6)

                local ObPad = Instance.new("UIPadding")
                ObPad.Parent = Ob
                ObPad.PaddingLeft = UDim.new(0, 12)

                Ob.MouseEnter:Connect(function()
                    TweenService:Create(Ob, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0,
                        BackgroundColor3 = CurrentThemeData.PrimaryContainer
                    }):Play()
                    Ob.TextColor3 = CurrentThemeData.OnPrimaryContainer
                end)
                Ob.MouseLeave:Connect(function()
                    TweenService:Create(Ob, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.2,
                        BackgroundColor3 = CurrentThemeData.SurfaceContainerLow
                    }):Play()
                    Ob.TextColor3 = CurrentThemeData.OnSurfaceVariant
                end)
                Ob.MouseButton1Click:Connect(function()
                    MainLabel.Text = txt .. ": " .. opt
                    isOpen = false
                    local newH = H
                    TweenService:Create(Base, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, newH)
                    }):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {
                        Rotation = 0
                    }):Play()
                    task.defer(RefreshHeight)
                    pcall(call, opt)
                end)
            end

            MainBtn.MouseEnter:Connect(function()
                ApplyStateHover(MainState, CurrentThemeData.Primary)
            end)
            MainBtn.MouseLeave:Connect(function()
                ApplyStateDefault(MainState)
            end)
            MainBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local optionHeight = #opts * 30 + 4
                local maxDropdownHeight = 150
                local actualOptionHeight = math.min(optionHeight, maxDropdownHeight)
                local newH = isOpen and (H + actualOptionHeight) or H
                TweenService:Create(Base, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, newH)
                }):Play()
                TweenService:Create(OptionsFrame, TweenInfo.new(0.25), {
                    Size = UDim2.new(1, 0, 0, isOpen and actualOptionHeight or 0)
                }):Play()
                OptionsFrame.ScrollingEnabled = isOpen and (optionHeight > maxDropdownHeight)
                TweenService:Create(Arrow, TweenInfo.new(0.2), {
                    Rotation = isOpen and 180 or 0
                }):Play()
                task.defer(RefreshHeight)
            end)

            return Mod
        end

        -- === 模块: Input ===
        function Mod:CreateInput(text, placeholder, callback)
            if not ExpandBtn.Visible then ExpandBtn.Visible = true end

            local Row = Instance.new("Frame")
            Row.Parent = SetFrame
            Row.BackgroundTransparency = 1
            Row.Size = UDim2.new(1, 0, 0, 42)
            Row.LayoutOrder = #Row.Parent:GetChildren()

            local LabelIn = Instance.new("TextLabel")
            LabelIn.Parent = Row
            LabelIn.Text = text
            LabelIn.Font = Enum.Font.Gotham
            LabelIn.TextSize = 11
            LabelIn.BackgroundTransparency = 1
            LabelIn.Size = UDim2.new(0, 54, 0, 20)
            LabelIn.Position = UDim2.new(0, 4, 0.5, 0)
            LabelIn.AnchorPoint = Vector2.new(0, 0.5)
            LabelIn.TextXAlignment = Enum.TextXAlignment.Left
            RegisterObject(LabelIn, "TextVariant")

            local InputBg = Instance.new("Frame")
            InputBg.Parent = Row
            InputBg.BackgroundColor3 = CurrentThemeData.SurfaceContainerHighest
            InputBg.Size = UDim2.new(1, -60, 0, 32)
            InputBg.Position = UDim2.new(0, 58, 0.5, 0)
            InputBg.AnchorPoint = Vector2.new(0, 0.5)
            InputBg.BorderSizePixel = 0
            RegisterObject(InputBg, "ContainerHighest")
            RegisterStyle(InputBg, false, 8)

            local InputStroke = Instance.new("UIStroke")
            InputStroke.Parent = InputBg
            InputStroke.Thickness = 1
            InputStroke.Color = CurrentThemeData.OutlineVariant
            InputStroke.Transparency = 0.5
            InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = InputBg
            TextBox.BackgroundTransparency = 1
            TextBox.Size = UDim2.new(1, -16, 1, 0)
            TextBox.Position = UDim2.new(0, 8, 0, 0)
            TextBox.Font = Enum.Font.Gotham
            TextBox.Text = ""
            TextBox.TextSize = 12
            TextBox.TextColor3 = CurrentThemeData.OnSurface
            TextBox.PlaceholderText = placeholder or "输入..."
            TextBox.PlaceholderColor3 = CurrentThemeData.OnSurfaceVariant
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.TextYAlignment = Enum.TextYAlignment.Center
            TextBox.ClearTextOnFocus = false
            TextBox.TextWrapped = false

            TextBox.Focused:Connect(function()
                TweenService:Create(InputStroke, TweenInfo.new(0.15), {
                    Transparency = 0,
                    Color = CurrentThemeData.Primary
                }):Play()
            end)
            TextBox.FocusLost:Connect(function(enter)
                TweenService:Create(InputStroke, TweenInfo.new(0.15), {
                    Transparency = 0.5,
                    Color = CurrentThemeData.OutlineVariant
                }):Play()
                if enter then
                    pcall(callback, TextBox.Text)
                    Library:Notify("输入已应用", true)
                end
            end)

            return Mod
        end

        -- === 模块: ColorPicker ===
        function Mod:CreateColorPicker(text, defaultColor, callback)
            if not ExpandBtn.Visible then ExpandBtn.Visible = true end
            local curColor = defaultColor or Color3.new(1, 1, 1)

            local Row = Instance.new("Frame")
            Row.Parent = SetFrame
            Row.BackgroundTransparency = 1
            Row.Size = UDim2.new(1, 0, 0, 36)
            Row.LayoutOrder = #Row.Parent:GetChildren()

            local LabelCp = Instance.new("TextLabel")
            LabelCp.Parent = Row
            LabelCp.Text = text
            LabelCp.Font = Enum.Font.Gotham
            LabelCp.TextSize = 12
            LabelCp.BackgroundTransparency = 1
            LabelCp.Size = UDim2.new(1, -60, 1, 0)
            LabelCp.Position = UDim2.new(0, 4, 0, 0)
            LabelCp.TextXAlignment = Enum.TextXAlignment.Left
            LabelCp.TextYAlignment = Enum.TextYAlignment.Center
            RegisterObject(LabelCp, "Text")

            local Preview = Instance.new("Frame")
            Preview.Parent = Row
            Preview.Size = UDim2.new(0, 40, 0, 22)
            Preview.Position = UDim2.new(1, -4, 0.5, 0)
            Preview.AnchorPoint = Vector2.new(1, 0.5)
            Preview.BackgroundColor3 = curColor
            Preview.BorderSizePixel = 0
            RegisterStyle(Preview, false, 6)

            local PreviewStroke = Instance.new("UIStroke")
            PreviewStroke.Parent = Preview
            PreviewStroke.Thickness = 1
            PreviewStroke.Color = CurrentThemeData.OutlineVariant
            PreviewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local Hitbox = Instance.new("TextButton")
            Hitbox.Parent = Row
            Hitbox.Size = UDim2.new(0, 48, 1, 0)
            Hitbox.Position = UDim2.new(1, 0, 0, 0)
            Hitbox.AnchorPoint = Vector2.new(1, 0)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""
            Hitbox.AutoButtonColor = false
            Hitbox.ZIndex = Row.ZIndex + 5

            Hitbox.MouseButton1Click:Connect(function()
                if Library.Globals.ActivePicker then
                    Library.Globals.ActivePicker:Destroy()
                    Library.Globals.ActivePicker = nil
                    return
                end

                local PickerFrame = Instance.new("Frame")
                PickerFrame.Name = "ColorPicker_PopOut"
                PickerFrame.Parent = ScreenGui
                PickerFrame.Size = UDim2.new(0, 0, 0, 0)
                PickerFrame.Position = UDim2.new(0, Row.AbsolutePosition.X + Row.AbsoluteSize.X - 200, 0, math.min(Row.AbsolutePosition.Y - 100, Camera.ViewportSize.Y - 260))
                PickerFrame.BackgroundColor3 = CurrentThemeData.SurfaceContainerHigh
                PickerFrame.ClipsDescendants = true
                PickerFrame.ZIndex = Library.Globals.TopZIndex + 100
                PickerFrame.BorderSizePixel = 0
                RegisterObject(PickerFrame, "Window")
                RegisterStyle(PickerFrame, false, 12)

                Library.Globals.ActivePicker = PickerFrame

                TweenService:Create(PickerFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 200, 0, 220)
                }):Play()

                local Padding = Instance.new("UIPadding")
                Padding.Parent = PickerFrame
                Padding.PaddingTop = UDim.new(0, 10)
                Padding.PaddingBottom = UDim.new(0, 10)
                Padding.PaddingLeft = UDim.new(0, 10)
                Padding.PaddingRight = UDim.new(0, 10)

                -- Title
                local Title = Instance.new("TextLabel")
                Title.Parent = PickerFrame
                Title.Text = text
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 12
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(1, 0, 0, 16)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                RegisterObject(Title, "Text")

                -- HSV 选择器
                local SVBox = Instance.new("Frame")
                SVBox.Parent = PickerFrame
                SVBox.Size = UDim2.new(1, -30, 0, 120)
                SVBox.Position = UDim2.new(0, 0, 0, 22)
                SVBox.BackgroundColor3 = Color3.new(1, 1, 1)
                SVBox.BorderSizePixel = 0
                RegisterStyle(SVBox, false, 6)

                local SVGrad = Instance.new("UIGradient")
                SVGrad.Parent = SVBox
                SVGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                })

                local SVOverlay = Instance.new("Frame")
                SVOverlay.Parent = SVBox
                SVOverlay.Size = UDim2.new(1, 0, 1, 0)
                SVOverlay.BackgroundTransparency = 0
                SVOverlay.BorderSizePixel = 0
                local SVOverlayGrad = Instance.new("UIGradient")
                SVOverlayGrad.Parent = SVOverlay
                SVOverlayGrad.Rotation = 90
                SVOverlayGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                })
                SVOverlayGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })

                -- Hue slider
                local HueBox = Instance.new("Frame")
                HueBox.Parent = PickerFrame
                HueBox.Size = UDim2.new(0, 20, 0, 120)
                HueBox.Position = UDim2.new(1, -20, 0, 22)
                HueBox.BackgroundColor3 = Color3.new(1, 1, 1)
                HueBox.BorderSizePixel = 0
                RegisterStyle(HueBox, false, 4)

                local HueGrad = Instance.new("UIGradient")
                HueGrad.Parent = HueBox
                HueGrad.Rotation = 90
                HueGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.new(1, 1, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.67, Color3.new(0, 0, 1)),
                    ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                })

                -- 选点指针
                local SVPoint = Instance.new("Frame")
                SVPoint.Parent = SVBox
                SVPoint.Size = UDim2.new(0, 10, 0, 10)
                SVPoint.Position = UDim2.new(1, 0, 0, 0)
                SVPoint.AnchorPoint = Vector2.new(0.5, 0.5)
                SVPoint.BackgroundColor3 = Color3.new(1, 1, 1)
                SVPoint.BorderSizePixel = 0
                SVPoint.ZIndex = SVBox.ZIndex + 3
                RegisterStyle(SVPoint, false, 5)
                local SVPS = Instance.new("UIStroke")
                SVPS.Parent = SVPoint
                SVPS.Thickness = 1.5
                SVPS.Color = Color3.new(0, 0, 0)

                local HuePoint = Instance.new("Frame")
                HuePoint.Parent = HueBox
                HuePoint.Size = UDim2.new(1, 4, 0, 4)
                HuePoint.Position = UDim2.new(0, -2, 0, 0)
                HuePoint.BackgroundColor3 = Color3.new(1, 1, 1)
                HuePoint.BorderSizePixel = 0
                HuePoint.ZIndex = HueBox.ZIndex + 3
                local HPS = Instance.new("UIStroke")
                HPS.Parent = HuePoint
                HPS.Thickness = 1.5
                HPS.Color = Color3.new(0, 0, 0)

                -- 当前色相
                local curH, curS, curV = Color3.toHSV(curColor)

                local function UpdateColor()
                    curColor = Color3.fromHSV(curH, curS, curV)
                    Preview.BackgroundColor3 = curColor
                    SVGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(curH, 1, 1))
                    })
                    SVPoint.Position = UDim2.new(curS, 0, 1 - curV, 0)
                    HuePoint.Position = UDim2.new(0, -2, curH, 0)
                    pcall(callback, curColor)
                end

                -- RGB 输入框
                local RGBRow = Instance.new("Frame")
                RGBRow.Parent = PickerFrame
                RGBRow.BackgroundTransparency = 1
                RGBRow.Size = UDim2.new(1, 0, 0, 24)
                RGBRow.Position = UDim2.new(0, 0, 0, 148)

                local RBox = Instance.new("TextBox")
                RBox.Parent = RGBRow
                RBox.Size = UDim2.new(0.3, -4, 1, 0)
                RBox.Position = UDim2.new(0, 0, 0, 0)
                RBox.BackgroundColor3 = CurrentThemeData.SurfaceContainerHighest
                RBox.Text = tostring(math.floor(curColor.R * 255))
                RBox.TextColor3 = CurrentThemeData.OnSurface
                RBox.Font = Enum.Font.Gotham
                RBox.TextSize = 11
                RBox.TextXAlignment = Enum.TextXAlignment.Center
                RBox.TextYAlignment = Enum.TextYAlignment.Center
                RBox.ClearTextOnFocus = true
                RegisterStyle(RBox, false, 4)

                local GBox = RBox:Clone()
                GBox.Parent = RGBRow
                GBox.Position = UDim2.new(0.33, 0, 0, 0)
                GBox.Text = tostring(math.floor(curColor.G * 255))

                local BBox = RBox:Clone()
                BBox.Parent = RGBRow
                BBox.Position = UDim2.new(0.66, 0, 0, 0)
                BBox.Text = tostring(math.floor(curColor.B * 255))

                local function UpdateFromRGB()
                    local r, g, b = tonumber(RBox.Text) or 0, tonumber(GBox.Text) or 0, tonumber(BBox.Text) or 0
                    r, g, b = Clamp(r, 0, 255), Clamp(g, 0, 255), Clamp(b, 0, 255)
                    curColor = Color3.fromRGB(r, g, b)
                    curH, curS, curV = Color3.toHSV(curColor)
                    UpdateColor()
                end

                RBox.FocusLost:Connect(UpdateFromRGB)
                GBox.FocusLost:Connect(UpdateFromRGB)
                BBox.FocusLost:Connect(UpdateFromRGB)

                -- Confirm button
                local ConfirmBtn = Instance.new("TextButton")
                ConfirmBtn.Parent = PickerFrame
                ConfirmBtn.Size = UDim2.new(1, 0, 0, 28)
                ConfirmBtn.Position = UDim2.new(0, 0, 1, -30)
                ConfirmBtn.BackgroundColor3 = CurrentThemeData.Primary
                ConfirmBtn.Text = "确认"
                ConfirmBtn.Font = Enum.Font.GothamBold
                ConfirmBtn.TextSize = 12
                ConfirmBtn.TextColor3 = CurrentThemeData.OnPrimary
                ConfirmBtn.TextXAlignment = Enum.TextXAlignment.Center
                ConfirmBtn.TextYAlignment = Enum.TextYAlignment.Center
                ConfirmBtn.AutoButtonColor = false
                ConfirmBtn.BorderSizePixel = 0
                RegisterObject(ConfirmBtn, "Primary")
                RegisterStyle(ConfirmBtn, false, 8)

                local ConfirmState = CreateStateLayer(ConfirmBtn, 1)
                ConfirmBtn.MouseEnter:Connect(function()
                    ApplyStateHover(ConfirmState, CurrentThemeData.OnPrimary)
                end)
                ConfirmBtn.MouseLeave:Connect(function()
                    ApplyStateDefault(ConfirmState)
                end)
                ConfirmBtn.MouseButton1Click:Connect(function()
                    PickerFrame:Destroy()
                    Library.Globals.ActivePicker = nil
                end)

                -- 拖动逻辑
                local dragSV, dragH = false, false

                local SVHitbox = Instance.new("TextButton")
                SVHitbox.Parent = SVBox
                SVHitbox.Size = UDim2.new(1, 0, 1, 0)
                SVHitbox.BackgroundTransparency = 1
                SVHitbox.Text = ""
                SVHitbox.AutoButtonColor = false
                SVHitbox.ZIndex = SVBox.ZIndex + 5

                local HueHitbox = Instance.new("TextButton")
                HueHitbox.Parent = HueBox
                HueHitbox.Size = UDim2.new(1, 0, 1, 0)
                HueHitbox.BackgroundTransparency = 1
                HueHitbox.Text = ""
                HueHitbox.AutoButtonColor = false
                HueHitbox.ZIndex = HueBox.ZIndex + 5

                SVHitbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragSV = true
                        curS = Clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                        curV = 1 - Clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor()
                    end
                end)

                HueHitbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragH = true
                        curH = Clamp((input.Position.Y - HueBox.AbsolutePosition.Y) / HueBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor()
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        curS = Clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                        curV = 1 - Clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor()
                    elseif dragH and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        curH = Clamp((input.Position.Y - HueBox.AbsolutePosition.Y) / HueBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragSV = false
                        dragH = false
                    end
                end)

                UpdateColor()
            end)

            return Mod
        end

        -- === 模块: KeyBind ===
        if allowBind then
            local KB = Instance.new("TextButton")
            KB.Parent = SetFrame
            KB.Size = UDim2.new(1, 0, 0, 36)
            KB.BackgroundColor3 = CurrentThemeData.SurfaceContainerLow
            KB.Text = ""
            KB.AutoButtonColor = false
            KB.BorderSizePixel = 0
            KB.LayoutOrder = #SetFrame:GetChildren()
            RegisterObject(KB, "ContainerLow")
            RegisterStyle(KB, false, 8)

            local KBState = CreateStateLayer(KB, 1)

            local KBLabel = Instance.new("TextLabel")
            KBLabel.Parent = KB
            KBLabel.Text = "按键绑定: 无"
            KBLabel.Font = Enum.Font.Gotham
            KBLabel.TextSize = 12
            KBLabel.BackgroundTransparency = 1
            KBLabel.Size = UDim2.new(1, -16, 1, 0)
            KBLabel.Position = UDim2.new(0, 12, 0, 0)
            KBLabel.TextXAlignment = Enum.TextXAlignment.Left
            KBLabel.TextYAlignment = Enum.TextYAlignment.Center
            KBLabel.ZIndex = KB.ZIndex + 2
            RegisterObject(KBLabel, "Text")

            local listening = false
            KB.MouseEnter:Connect(function()
                ApplyStateHover(KBState, CurrentThemeData.Primary)
            end)
            KB.MouseLeave:Connect(function()
                ApplyStateDefault(KBState)
            end)
            KB.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                KBLabel.Text = "按下任意按键..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        conn:Disconnect()
                        if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
                            if bindKey then
                                Library.Globals.BoundKeys[bindKey] = nil
                            end
                            bindKey = nil
                            KBLabel.Text = "按键绑定: 无"
                        else
                            if bindKey then
                                Library.Globals.BoundKeys[bindKey] = nil
                            end
                            bindKey = input.KeyCode
                            Library.Globals.BoundKeys[bindKey] = Toggle
                            KBLabel.Text = "按键绑定: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                        end
                    end
                end)
            end)
        end

        task.defer(RefreshHeight)
        return Mod
    end

    return Window
end

-- ============================================================
-- Mobile Widget (悬浮窗)
-- ============================================================
function CreateMobileWidget(name, toggleFunc, getEnabledState)
    if ScreenGui:FindFirstChild("MobileWidget_" .. name) then return end

    local Widget = Instance.new("Frame")
    Widget.Name = "MobileWidget_" .. name
    Widget.Parent = ScreenGui
    Widget.Size = UDim2.new(0, 56, 0, 56)
    Widget.Position = UDim2.new(0.5, 0, 0.5, 0)
    Widget.BackgroundColor3 = CurrentThemeData.SurfaceContainerHigh
    Widget.ZIndex = 50
    Widget.ClipsDescendants = true
    Widget.BorderSizePixel = 0
    RegisterObject(Widget, "Window")
    RegisterStyle(Widget, false, 28)

    local WidgetStroke = Instance.new("UIStroke")
    WidgetStroke.Parent = Widget
    WidgetStroke.Thickness = 2
    WidgetStroke.Color = CurrentThemeData.Primary
    WidgetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local WidgetLabel = Instance.new("TextLabel")
    WidgetLabel.Parent = Widget
    WidgetLabel.Text = GetFirstChar(name)
    WidgetLabel.Font = Enum.Font.GothamBold
    WidgetLabel.TextSize = 20
    WidgetLabel.BackgroundTransparency = 1
    WidgetLabel.Size = UDim2.new(1, 0, 1, -12)
    WidgetLabel.TextXAlignment = Enum.TextXAlignment.Center
    WidgetLabel.TextYAlignment = Enum.TextYAlignment.Center
    WidgetLabel.ZIndex = Widget.ZIndex + 1
    RegisterObject(WidgetLabel, "Text")

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Widget
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -4, 0, -4)
    CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseBtn.BackgroundColor3 = CurrentThemeData.Error
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = Widget.ZIndex + 2
    RegisterStyle(CloseBtn, false, 10)

    CloseBtn.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(Widget, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            if Widget and Widget.Parent then
                Widget:Destroy()
            end
        end)
    end)

    local HitboxBtn = Instance.new("TextButton")
    HitboxBtn.Parent = Widget
    HitboxBtn.Size = UDim2.new(1, 0, 1, -16)
    HitboxBtn.Position = UDim2.new(0, 0, 0, 0)
    HitboxBtn.BackgroundTransparency = 1
    HitboxBtn.Text = ""
    HitboxBtn.AutoButtonColor = false
    HitboxBtn.ZIndex = Widget.ZIndex + 3

    HitboxBtn.MouseButton1Click:Connect(function()
        toggleFunc(true)
    end)

    -- 拖动
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    HitboxBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Widget.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            Widget.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- 状态更新
    local updateConn
    updateConn = RunService.Heartbeat:Connect(function()
        if not Widget or not Widget.Parent then
            updateConn:Disconnect()
            return
        end
        local enabled = getEnabledState()
        TweenService:Create(WidgetStroke, TweenInfo.new(0.3), {
            Color = enabled and CurrentThemeData.Primary or CurrentThemeData.OutlineVariant
        }):Play()
    end)
end
 
-- ============================================================
-- 内置设置窗口
-- ============================================================
function Library:SetupSettings()
    local Settings = self:CreateWindow("InkWind 设置", UDim2.new(0, 20, 0, 60))
 
    local ThemeMod = Settings:CreateModule("外观主题", function() end, false)
    ThemeMod:CreateDropdown("颜色方案", {
        "Violet", "Ocean", "Forest", "Sunset", "Crimson", "Slate", "Monochrome"
    }, function(val)
        Library:SetTheme(val)
        Library:Notify("主题已切换", true)
    end)
 
    ThemeMod:CreateSlider("窗口宽度", 160, 360, Library.Config.WindowWidth, function(v)
        Library.Config.WindowWidth = v
        Library:RefreshDimensions()
    end)
 
    ThemeMod:CreateSlider("高度调整(%)", 50, 150, math.floor(Library.Config.UIScale * 100), function(v)
        Library.Config.UIScale = v / 100
        Library:RefreshDimensions()
    end)
 
    local UIMod = Settings:CreateModule("界面功能", function() end, false)
    UIMod:CreateSwitch("显示 HUD", function(v)
        Library.Config.ShowHUD = v
        HUDFrame.Visible = v
        SaveConfig()
    end, Library.Config.ShowHUD)
 
    UIMod:CreateSwitch("显示通知", function(v)
        Library.Config.ShowNotifs = v
        SaveConfig()
    end, Library.Config.ShowNotifs)
 
    UIMod:CreateSwitch("圆角样式", function(v)
        Library.Config.UseCorners = v
        Library:RefreshStyle()
        SaveConfig()
    end, Library.Config.UseCorners)
 
    Settings:CreateButton("保存配置", function()
        SaveConfig()
        Library:Notify("配置已保存", true)
    end)
 
    return Settings
end
 
-- ============================================================
-- 快捷创建
-- ============================================================
function Library:CreateMainControl(title)
    return self:CreateWindow(title or "主菜单", UDim2.new(0, 20, 0, 60), true, false)
end
 
function Library:CreateChildWindow(title)
    return self:CreateWindow(title or "子窗口", UDim2.new(0.5, -Library.Config.WindowWidth / 2, 0.5, -100), false, true)
end
 
-- ============================================================
-- 加载器 (Loader)
-- ============================================================
task.spawn(function()
    ScreenGui.Enabled = true
end)
 
return Library