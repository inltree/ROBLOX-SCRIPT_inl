-- inltree_Lin_UniversalUILib.luau - inltree｜Lin×DeepSeek 通用UI库
-- 版本: 1.1.0
-- 提供简洁实用的Roblox UI组件

local inltree_Lin_UniversalUILib = {}

-- 私有属性
local _private = {
    Players = game:GetService("Players"),
    MarketplaceService = game:GetService("MarketplaceService"),
    StarterGui = game:GetService("StarterGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    UserInputService = game:GetService("UserInputService"),
    player = nil,
    playerGui = nil,
    screenGui = nil,
    buttons = {},
    buttonStates = {},
    isHidden = false,
    dragging = false,
    dragInput = nil,
    dragStart = nil,
    startPositions = {},
    gameName = "",
    activeFunctions = {}, -- 存储活跃功能的回调函数
    onToggleChangeCallbacks = {}, -- 存储状态改变回调
    mainUIButton = nil, -- 面板按钮
    subMenus = {}, -- 存储子面板
    subMenuStates = {}, -- 存储子面板状态
    savedPositions = {}, -- 存储所有UI元素的位置
    savedSizes = {}, -- 存储所有UI元素的大小
    longPressThreshold = 0.5, -- 长按阈值（秒）
    longPressTimers = {} -- 长按计时器
}

-- 初始化库
function inltree_Lin_UniversalUILib.init()
    _private.player = _private.Players.LocalPlayer
    _private.playerGui = _private.player:WaitForChild("PlayerGui")
    _private.gameName = _private.MarketplaceService:GetProductInfo(game.PlaceId).Name
    
    -- 创建主ScreenGui
    if not _private.screenGui then
        _private.screenGui = Instance.new("ScreenGui")
        _private.screenGui.Name = "inltree_Lin_UniversalUI"
        _private.screenGui.ResetOnSpawn = false
        _private.screenGui.Parent = _private.playerGui
    end
    
    -- 显示加载通知
    _private.StarterGui:SetCore("SendNotification", {
        Title = _private.gameName,
        Text = "inltree｜".._private.gameName.." Script Loading...｜加载中...",
        Duration = 3
    })
    
    return inltree_Lin_UniversalUILib
end

-- 按钮样式配置
function inltree_Lin_UniversalUILib.getButtonStyle()
    return {
        Size = UDim2.new(0, 120, 0, 30),
        BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
        BackgroundTransparency = 0.5,
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        BorderSizePixel = 1,
        BorderColor3 = Color3.new(0.8, 0.8, 0.8)
    }
end

-- 保存UI元素位置
local function saveUIPosition(uiElement, name)
    if uiElement and name then
        _private.savedPositions[name] = uiElement.Position
        if uiElement:IsA("Frame") then
            _private.savedSizes[name] = uiElement.Size
        end
    end
end

-- 恢复UI元素位置
local function restoreUIPosition(uiElement, name)
    if uiElement and name and _private.savedPositions[name] then
        uiElement.Position = _private.savedPositions[name]
        if uiElement:IsA("Frame") and _private.savedSizes[name] then
            uiElement.Size = _private.savedSizes[name]
        end
    end
end

-- 注册功能回调
function inltree_Lin_UniversalUILib.registerFunction(buttonName, enableCallback, disableCallback)
    _private.activeFunctions[buttonName] = {
        enable = enableCallback,
        disable = disableCallback
    }
    
    -- 如果按钮已经存在且状态为true，立即执行启用回调
    if _private.buttonStates[buttonName] == true and enableCallback then
        enableCallback()
    end
end

-- 添加状态改变回调
function inltree_Lin_UniversalUILib.onToggleChange(callback)
    table.insert(_private.onToggleChangeCallbacks, callback)
end

-- 触发所有状态改变回调
local function triggerToggleCallbacks(buttonName, state)
    for _, callback in ipairs(_private.onToggleChangeCallbacks) do
        pcall(callback, buttonName, state)
    end
end

-- 关闭所有活跃功能
function inltree_Lin_UniversalUILib.disableAllFunctions()
    print("🟡 正在关闭功能...")
    
    for buttonName, state in pairs(_private.buttonStates) do
        if state == true then
            -- 设置按钮状态为false
            _private.buttonStates[buttonName] = false
            if _private.buttons[buttonName] then
                _private.buttons[buttonName].Text = buttonName..": "..tostring(false)
                local defaultColor = Color3.new(0.8, 0.5, 1) -- 默认颜色，可以根据需要调整
                _private.buttons[buttonName].TextColor3 = defaultColor
            end
            
            -- 执行禁用回调
            if _private.activeFunctions[buttonName] and _private.activeFunctions[buttonName].disable then
                pcall(_private.activeFunctions[buttonName].disable)
                print("🔴 已关闭功能: "..buttonName)
            else
                print("🔴 已设置状态: "..buttonName)
            end
            
            -- 触发状态改变回调
            triggerToggleCallbacks(buttonName, false)
        end
    end
    
    print("🟢 功能已关闭")
end

-- 创建按钮
function inltree_Lin_UniversalUILib.createButton(name, position, color, callback)
    local buttonStyle = inltree_Lin_UniversalUILib.getButtonStyle()
    
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = buttonStyle.Size
    button.Position = position
    button.Text = name
    button.TextColor3 = color
    button.BackgroundColor3 = buttonStyle.BackgroundColor3
    button.BackgroundTransparency = buttonStyle.BackgroundTransparency
    button.Font = buttonStyle.Font
    button.TextSize = buttonStyle.TextSize
    button.BorderSizePixel = buttonStyle.BorderSizePixel
    button.BorderColor3 = buttonStyle.BorderColor3
    button.Parent = _private.screenGui
    
    if callback then
        button.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end
    
    -- 存储按钮引用
    _private.buttons[name] = button
    _private.startPositions[button] = position
    
    -- 保存位置
    saveUIPosition(button, name)
    
    return button
end

-- 创建模板按钮
function inltree_Lin_UniversalUILib.createToggleButton(name, position, defaultColor, initialState)
    local button = inltree_Lin_UniversalUILib.createButton(name..": "..tostring(initialState 或 false), position, defaultColor)
    
    _private.buttonStates[name] = initialState 或 false
    
    button.MouseButton1Click:Connect(function()
        _private.buttonStates[name] = not _private.buttonStates[name]
        button.Text = name..": "..tostring(_private.buttonStates[name])
        button.TextColor3 = _private.buttonStates[name] 和 Color3.new(0, 1, 0) or defaultColor
        
        print("🟢 "..name..": "..tostring(_private.buttonStates[name]))
        
        -- 触发状态改变回调
        triggerToggleCallbacks(name, _private.buttonStates[name])
        
        -- 执行注册的功能回调
        if _private.activeFunctions[name] then
            if _private.buttonStates[name] and _private.activeFunctions[name].enable then
                pcall(_private.activeFunctions[name].enable)
            elseif not _private.buttonStates[name] and _private.activeFunctions[name].disable then
                pcall(_private.activeFunctions[name].disable)
            end
        end
    end)
    
    return button
end

-- 设置按钮状态
function inltree_Lin_UniversalUILib.setButtonState(name, state)
    if _private.buttons[name] and _private.buttonStates[name] ~= nil then
        _private.buttonStates[name] = state
        _private.buttons[name].Text = name..": "..tostring(state)
        _private.buttons[name].TextColor3 = state and Color3.new(0, 1, 0) or inltree_Lin_UniversalUILib.getButtonStyle().TextColor3
        
        -- 触发状态改变回调
        triggerToggleCallbacks(name, state)
        
        -- 执行注册的功能回调
        if _private.activeFunctions[name] then
            if state and _private.activeFunctions[name].enable then
                pcall(_private.activeFunctions[name].enable)
            elseif not state and _private.activeFunctions[name].disable then
                pcall(_private.activeFunctions[name].disable)
            end
        end
    end
end

-- 获取按钮状态
function inltree_Lin_UniversalUILib.getButtonState(name)
    return _private.buttonStates[name]
end

-- 隐藏/显示UI
function inltree_Lin_UniversalUILib.toggleUI()
    -- 保存当前所有子面板的状态
    local savedSubMenuStates = {}
    for title, menu in pairs(_private.subMenus) do
        savedSubMenuStates[title] = {
            visible = menu.Visible,
            position = menu.Position,
            size = menu.Size
        }
    end
    
    _private.isHidden = not _private.isHidden
    
    for name, button in pairs(_private.buttons) do
        if name ~= "隐藏UI" then
            button.Visible = not _private.isHidden
        end
    end
    
    -- 同时隐藏/显示面板按钮
    if _private.mainUIButton then
        _private.mainUIButton.Visible = not _private.isHidden
    end
    
    -- 同时隐藏/显示所有子面板，并恢复之前的状态
    for title, menu in pairs(_private.subMenus) do
        if not _private.isHidden then
            -- 显示时恢复之前的状态
            menu.Visible = savedSubMenuStates[title] and savedSubMenuStates[title].visible or false
            if savedSubMenuStates[title] then
                menu.Position = savedSubMenuStates[title].position
                menu.Size = savedSubMenuStates[title].size
            end
        else
            -- 隐藏时保存当前状态
            menu.Visible = false
        end
    end
    
    _private.buttons["隐藏UI"].Text = _private.isHidden and "显示UI" or "隐藏UI"
    print("🟢 isHidden: "..tostring(_private.isHidden))
end

-- 关闭UI
function inltree_Lin_UniversalUILib.closeUI()
    -- 先关闭所有功能
    inltree_Lin_UniversalUILib.disableAllFunctions()
    
    -- 等待一下确保所有功能都已关闭
    task.wait(0.1)
    
    -- 然后关闭UI面板
    if _private.screenGui then
        _private.screenGui:Destroy()
        _private.screenGui = nil
    end
    print("🔴 ".._private.gameName.." - screenGui: "..tostring(_private.screenGui == nil))
end

-- 打开控制台
function inltree_Lin_UniversalUILib.openConsole()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F9, false, game)
    print("🟢 Console opened: true")
end

-- 通用拖动函数（修复版）
local function setupDrag(uiElement, elementName)
    local dragInput, dragStart, startPos
    local isDragging = false
    
    local function updatePos(input)
        if not dragStart or not isDragging then return end
        
        local delta = input.Position - dragStart
        uiElement.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        -- 保存位置
        saveUIPosition(uiElement, elementName)
    end
    
    -- 鼠标按下事件
    uiElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- 启动长按检测
            local pressStartTime = tick()
            _private.longPressTimers[elementName] = task.delay(_private.longPressThreshold, function()
                isDragging = true
                dragStart = input.Position
                startPos = uiElement.Position
                
                -- 改变鼠标光标为移动图标
                _private.UserInputService.MouseIcon = "rbxassetid://47624217"
            end)
        end
    end)
    
    -- 鼠标释放事件
    uiElement.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- 取消长按计时器
            if _private.longPressTimers[elementName] then
                task.cancel(_private.longPressTimers[elementName])
                _private.longPressTimers[elementName] = nil
            end
            
            if isDragging then
                isDragging = false
                dragInput = nil
                -- 恢复默认鼠标光标
                _private.UserInputService.MouseIcon = ""
            end
        end
    end)
    
    -- 鼠标移动事件
    uiElement.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if isDragging then
                dragInput = input
            end
        end
    end)
    
    -- 全局鼠标移动监听
    local connection
    connection = _private.UserInputService.InputChanged:Connect(function(input)
        if isDragging and dragInput and input == dragInput then
            updatePos(input)
        end
    end)
    
    -- 清理连接
    uiElement.AncestryChanged:Connect(function()
        if not uiElement:IsDescendantOf(game) then
            connection:Disconnect()
        end
    end)
end

-- 创建面板按钮（可自定义名称）
function inltree_Lin_UniversalUILib.createMainUIButton(buttonName, position)
    if _private.mainUIButton then
        _private.mainUIButton:Destroy()
    end
    
    buttonName = buttonName or "主面板"
    position = position or UDim2.new(0, 140, 0, 10)
    
    _private.mainUIButton = Instance.new("TextButton")
    _private.mainUIButton.Name = "MainUI"
    _private.mainUIButton.Size = UDim2.new(0, 80, 0, 30)
    _private.mainUIButton.Position = position
    _private.mainUIButton.Text = buttonName
    _private.mainUIButton.TextColor3 = Color3.new(1, 0.8, 0.2)
    _private.mainUIButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    _private.mainUIButton.BackgroundTransparency = 0.3
    _private.mainUIButton.Font = Enum.Font.SourceSansBold
    _private.mainUIButton.TextSize = 14
    _private.mainUIButton.BorderSizePixel = 1
    _private.mainUIButton.BorderColor3 = Color3.new(0.8, 0.8, 0.8)
    _private.mainUIButton.Parent = _private.screenGui
    
    -- 设置拖动功能
    setupDrag(_private.mainUIButton, "MainUI")
    
    -- 保存位置
    saveUIPosition(_private.mainUIButton, "MainUI")
    
    return _private.mainUIButton
end

-- 创建悬浮子面板（修复拖动功能）
function inltree_Lin_UniversalUILib.createSubMenu(title, options)
    -- 如果子面板已存在，则切换显示状态
    if _private.subMenus[title] then
        local menu = _private.subMenus[title]
        menu.Visible = not menu.Visible
        _private.subMenuStates[title] = menu.Visible
        return menu
    end
    
    -- 创建子面板容器
    local menuFrame = Instance.new("Frame")
    menuFrame.Name = title .. "SubMenu"
    menuFrame.Size = UDim2.new(0, 150, 0, 30)
    menuFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
    menuFrame.BackgroundTransparency = 0.1
    menuFrame.BorderSizePixel = 1
    menuFrame.BorderColor3 = Color3.new(0.8, 0.8, 0.8)
    menuFrame.ClipsDescendants = true
    menuFrame.ZIndex = 5
    menuFrame.Visible = false
    menuFrame.Parent = _private.screenGui
    
    -- 设置拖动功能（整个面板）
    setupDrag(menuFrame, title .. "SubMenu")
    
    -- 标题栏
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.Text = title
    header.TextColor3 = Color3.new(1, 1, 1)
    header.TextSize = 14
    header.Font = Enum.Font.SourceSansBold
    header.Parent = menuFrame
    
    -- 设置拖动功能（标题栏）
    setupDrag(header, title .. "Header")
    
    -- 内容容器
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = menuFrame
    
    local optionButtons = {}
    local isExpanded = false
    
    -- 创建面板选项按钮
    for i, option in ipairs(options) do
        local button = Instance.new("TextButton")
        button.Name = option.Name
        button.Size = UDim2.new(1, 0, 0, 28)
        button.Position = UDim2.new(0, 0, 0, (i-1)*28)
        button.BackgroundColor3 = Color3.new(0.25, 0.25, 0.35)
        button.BackgroundTransparency = 0.3
        button.BorderSizePixel = 1
        button.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
        button.Text = option.Name
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 12
        button.Font = Enum.Font.SourceSans
        button.TextXAlignment = Enum.TextXAlignment.Center
        button.ZIndex = 6
        button.Parent = contentFrame
        
        -- 按钮鼠标事件
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.45)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.new(0.25, 0.25, 0.35)
        end)
        
        -- 按钮点击事件
        button.MouseButton1Click:Connect(function()
            if option.Callback then
                pcall(option.Callback)
            end
        end)
        
        table.insert(optionButtons, button)
    end
    
    -- 展开/收起面板函数
    local function toggleMenu()
        isExpanded = not isExpanded
        
        if isExpanded then
            menuFrame.Size = UDim2.new(0, 150, 0, 30 + #options * 28)
            contentFrame.Size = UDim2.new(1, 0, 0, #options * 28)
        else
            menuFrame.Size = UDim2.new(0, 150, 0, 30)
            contentFrame.Size = UDim2.new(1, 0, 0, 0)
        end
        -- 保存大小
        saveUIPosition(menuFrame, title .. "SubMenu")
    end
    
    -- 标题栏点击事件
    header.MouseButton1Click:Connect(toggleMenu)
    
    -- 设置初始位置在面板按钮旁边
    if _private.mainUIButton then
        local mainPos = _private.mainUIButton.AbsolutePosition
        local mainSize = _private.mainUIButton.AbsoluteSize
        menuFrame.Position = UDim2.new(0, mainPos.X + mainSize.X + 5, 0, mainPos.Y)
    else
        menuFrame.Position = UDim2.new(0, 230, 0, 10)
    end
    
    -- 保存位置
    saveUIPosition(menuFrame, title .. "SubMenu")
    
    _private.subMenus[title] = menuFrame
    _private.subMenuStates[title] = false
    
    return menuFrame
end

-- 创建基础UI功能
function inltree_Lin_UniversalUILib.createBaseUI()
    inltree_Lin_UniversalUILib.createButton("隐藏UI", UDim2.new(0, 10, 0, 10), Color3.new(1, 0.5, 0), function()
        inltree_Lin_UniversalUILib.toggleUI()
    end)
    
    inltree_Lin_UniversalUILib.createButton("关闭UI", UDim2.new(0, 10, 0, 45), Color3.new(1, 0, 0), function()
        inltree_Lin_UniversalUILib.closeUI()
    end)
    
    inltree_Lin_UniversalUILib.createButton("控制台", UDim2.new(0, 10, 0, 80), Color3.new(1, 1, 0.5), function()
        inltree_Lin_UniversalUILib.openConsole()
    end)
    
    -- 显示加载完成通知
    task.wait(0.5)
    _private.StarterGui:SetCore("SendNotification", {
        Title = _private.gameName,
        Text = _private.gameName.."｜基础功能加载完成",
        Duration = 3
    })
    
    warn("\n"..(("="):rep(40).."\n- 脚本名称: ".._private.gameName.."\n- 描述: 基础UI面板\n- 版本: 1.0.0\n- 作者: inltree｜Lin×DeepSeek\n"..("="):rep(40)))
end

-- 重置库状态
function inltree_Lin_UniversalUILib.reset()
    -- 先关闭所有功能
    inltree_Lin_UniversalUILib.disableAllFunctions()
    
    -- 清理所有UI元素
    if _private.screenGui then
        _private.screenGui:Destroy()
        _private.screenGui = nil
    end
    
    -- 重置所有状态
    _private.buttons = {}
    _private.buttonStates = {}
    _private.activeFunctions = {}
    _private.onToggleChangeCallbacks = {}
    _private.isHidden = false
    _private.dragging = false
    _private.dragInput = nil
    _private.dragStart = nil
    _private.startPositions = {}
    _private.mainUIButton = nil
    _private.subMenus = {}
    _private.subMenuStates = {}
    _private.savedPositions = {}
    _private.savedSizes = {}
    _private.longPressTimers = {}
    
    -- 重新初始化
    return inltree_Lin_UniversalUILib.init()
end

-- 获取当前状态
function inltree_Lin_UniversalUILib.getState()
    return {
        buttonStates = _private.buttonStates,
        isHidden = _private.isHidden,
        gameName = _private.gameName,
        subMenuStates = _private.subMenuStates,
        savedPositions = _private.savedPositions,
        savedSizes = _private.savedSizes
    }
end

-- 获取主面板
function inltree_Lin_UniversalUILib.getMainUIButton()
    return _private.mainUIButton
end

-- 导出库
return inltree_Lin_UniversalUILib
