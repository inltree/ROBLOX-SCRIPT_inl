local Utils = {}
local Lexer = {}
local UI = {}

local Config = {
    MaxHistory = 200,
    Colors = {
        Bg = Color3.fromRGB(30, 30, 30),
        Sidebar = Color3.fromRGB(37, 37, 38),
        ContentBg = Color3.fromRGB(30, 30, 30),
        Item = Color3.fromRGB(45, 45, 48),
        Selected = Color3.fromRGB(60, 60, 65),
        Text = Color3.fromRGB(204, 204, 204),
        SubText = Color3.fromRGB(133, 133, 133),
        Border = Color3.fromRGB(55, 55, 55),
        Close = Color3.fromRGB(232, 17, 35),
        Minimize = Color3.fromRGB(60, 60, 60),
        Floating = Color3.fromRGB(0, 122, 204),
        Execute = Color3.fromRGB(0, 122, 204),
        Event = Color3.fromRGB(255, 198, 0),
        Function = Color3.fromRGB(174, 98, 206),
        Unreliable = Color3.fromRGB(209, 109, 0),
        TabActive = Color3.fromRGB(0, 122, 204),
        TabInactive = Color3.fromRGB(45, 45, 48),
        AutoOn = Color3.fromRGB(89, 194, 99),
        AutoOff = Color3.fromRGB(180, 180, 180),
        Syntax = {
            Control = "#C586C0",
            Storage = "#569CD6",
            Global = "#4EC9B0",
            Method = "#DCDCAA",
            Variable = "#9CDCFE",
            String = "#CE9178",
            Number = "#B5CEA8",
            Comment = "#6A9955",
            Operator = "#D4D4D4",
            Punctuation = "#CCCCCC",
            Property = "#9CDCFE",
            Boolean = "#569CD6",
            Nil = "#569CD6",
            Default = "#D4D4D4",
            Brackets = { "#FFD700", "#DA70D6", "#179FFF" },
            Escape = "#D7BA7D"
        }
    },
    Fonts = {
        Main = Enum.Font.GothamBold,
        Normal = Enum.Font.Gotham,
        Code = Enum.Font.Code
    },
    Icons = {
        Eye = "rbxassetid://6031075931",
        EyeOff = "rbxassetid://6031075929",
        Refresh = "rbxassetid://6031097225",
        Logo = "rbxassetid://6031154871"
    }
}

local TokenColorMap = {
    ["args"] = Config.Colors.Syntax.Variable,
    ["true"] = Config.Colors.Syntax.Boolean,
    ["false"] = Config.Colors.Syntax.Boolean,
    ["nil"] = Config.Colors.Syntax.Nil
}

for _, w in ipairs({"if", "else", "elseif", "then", "end", "return", "while", "for", "in", "do", "repeat", "until", "break", "and", "or", "not"}) do
    TokenColorMap[w] = Config.Colors.Syntax.Control
end

for _, w in ipairs({"local", "function"}) do
    TokenColorMap[w] = Config.Colors.Syntax.Storage
end

for _, w in ipairs({"game", "workspace", "script", "math", "string", "table", "Vector3", "Vector2", "CFrame", "Color3", "Instance", "Enum", "task", "print", "warn", "unpack", "getgenv", "require", "debug", "buffer"}) do
    TokenColorMap[w] = Config.Colors.Syntax.Global
end

local TypeSerializers = {
    ["string"] = function(v)
        return Utils.SafeString(v)
    end,
    ["number"] = function(v)
        return (v == math.huge and "math.huge") or (v == -math.huge and "-math.huge") or tostring(v)
    end,
    ["boolean"] = function(v)
        return tostring(v)
    end,
    ["nil"] = function()
        return "nil"
    end,
    ["buffer"] = function(v)
        return "buffer.fromstring(" .. Utils.SafeString(buffer.tostring(v)) .. ")"
    end,
    ["function"] = function(v)
        local n = debug.info(v, "n")
        return string.format("%s --[[ %s ]]", tostring(v), (n and n ~= "") and n or "匿名函数")
    end,
    ["Instance"] = function(v)
        return Utils.GetPath(v)
    end,
    ["Vector2"] = function(v)
        return string.format("Vector2.new(%s, %s)", v.X, v.Y)
    end,
    ["Vector3"] = function(v)
        return string.format("Vector3.new(%s, %s, %s)", v.X, v.Y, v.Z)
    end,
    ["CFrame"] = function(v)
        return string.format("CFrame.new(%s)", tostring(v))
    end,
    ["Color3"] = function(v)
        return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(v.R * 255), math.floor(v.G * 255), math.floor(v.B * 255))
    end,
    ["EnumItem"] = function(v)
        return tostring(v)
    end,
    ["table"] = function(v, indentLevel, visited)
        if visited[v] then
            return "nil --[[ 循环引用 ]]"
        end
        visited[v] = true
        local entries = {}
        local nextIndent = string.rep("    ", indentLevel + 1)
        for key, val in pairs(v) do
            local keyStr = (type(key) == "string") and ("[" .. Utils.SafeString(key) .. "]") or string.format("[%s]", Utils.Serialize(key, indentLevel + 1, visited))
            table.insert(entries, string.format("%s%s = %s", nextIndent, keyStr, Utils.Serialize(val, indentLevel + 1, visited)))
        end
        if #entries == 0 then
            return "{}"
        else
            return "{\n" .. table.concat(entries, ",\n") .. "\n" .. string.rep("    ", indentLevel) .. "}"
        end
    end
}

local StackDetailHandlers = {
    Locals = {
        Title = "快照",
        Get = function(f, frame)
            return Utils.Serialize(frame.Locals)
        end
    },
    Upvalues = {
        Title = "上值",
        Get = function(f)
            local s, v = pcall(debug.getupvalues, f)
            return Utils.Serialize(s and v or {})
        end
    },
    Constants = {
        Title = "常量",
        Get = function(f)
            local s, v = pcall(debug.getconstants, f)
            return Utils.Serialize(s and v or {})
        end
    },
    Decompile = {
        Title = "反编译",
        Get = function(f)
            if decompile then
                local s = rawget(getfenv(f), "script")
                if pcall(decompile, s) then
                    return decompile(s)
                else
                    return "-- 反编译失败"
                end
            else
                return "-- 错误: 你的注入器不支持反编译"
            end
        end
    }
}

local Cache, CurrentRaw, CurrentLogData, CurrentStackDetailRaw = {}, "", nil, ""
local CurrentTab, AutoSort, SortMode, SelectedBtn = "Args", true, "Time", nil
local Screen, Sidebar, SidebarLayout, ContentArea, ArgsPage, StackPage, StackList, StackDetailLabel

local Services = {
    UserInput = game:GetService("UserInputService"),
    Tween = game:GetService("TweenService"),
    Run = game:GetService("RunService"),
    Players = game:GetService("Players"),
    CoreGui = (gethui and gethui()) or game:GetService("CoreGui"),
    Http = game:GetService("HttpService")
}

function Utils.Escape(text)
    return text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

function Utils.Color(text, hex)
    return string.format('<font color="%s">%s</font>', hex, tostring(text))
end

function Utils.CleanName(name)
    return name:gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("\r", "")
end

function Utils.GetCallStack()
    local stack = {}
    local level = 4
    while true do
        if not debug.info(level, "f") then break end
        local s, res = pcall(debug.getstack, level + 1)
        table.insert(stack, {
            Func = debug.info(level, "f"),
            Locals = s and (res or {}) or "你的注入器对getstack进行了限制不能对C闭包使用"
        })
        level = level + 1
    end
    return stack
end

function Utils.SafeString(str)
    if utf8.len(str) then
        return Services.Http:JSONEncode(str)
    end
    local r = {}
    for i = 1, #str do
        local b = string.byte(str, i, i)
        if b >= 32 and b <= 126 and b ~= 34 and b ~= 92 then
            table.insert(r, string.char(b))
        else
            table.insert(r, string.format("\\%03d", b))
        end
    end
    return '"' .. table.concat(r) .. '"'
end

local TokenMap = {
    Operators = { [43]=1, [45]=1, [42]=1, [47]=1, [37]=1, [94]=1, [35]=1, [61]=1, [126]=1, [60]=1, [62]=1 },
    Punctuation = { [44]=1, [46]=1, [59]=1, [58]=1 },
    Brackets = { [123]=1, [125]=1, [91]=1, [93]=1, [40]=1, [41]=1 }
}

function Lexer.Highlight(source)
    local len = #source
    local chunks = {}
    local currentChunk = {}
    local currentChunkSize = 0
    local CHUNK_LIMIT = 10000
    local bufferText = {}
    local lastColor = nil
    local i = 1
    local bracketDepth = 0
    local bracketPalette = Config.Colors.Syntax.Brackets

    local function flush()
        if #bufferText > 0 then
            local rawText = table.concat(bufferText)
            table.clear(bufferText)
            local ptr = 1
            while ptr <= #rawText do
                local slice = rawText:sub(ptr, ptr + CHUNK_LIMIT - 1001)
                local taggedSlice = lastColor and Utils.Color(slice, lastColor) or slice
                if currentChunkSize + #taggedSlice > CHUNK_LIMIT then
                    table.insert(chunks, table.concat(currentChunk))
                    table.clear(currentChunk)
                    currentChunkSize = 0
                end
                table.insert(currentChunk, taggedSlice)
                currentChunkSize = currentChunkSize + #taggedSlice
                ptr = ptr + CHUNK_LIMIT - 1000
            end
        end
    end

    local function add(text, color)
        if color ~= lastColor then
            flush()
            lastColor = color
        end
        table.insert(bufferText, text)
    end

    local function getLongBracketLevel(idx)
        if source:byte(idx) ~= 91 then return nil end
        local l = 0
        local j = idx + 1
        while j <= len and source:byte(j) == 61 do
            l = l + 1
            j = j + 1
        end
        if j <= len and source:byte(j) == 91 then
            return "]" .. string.rep("=", l) .. "]"
        end
        return nil
    end

    while i <= len do
        local b = source:byte(i)
        if b == 32 or b == 9 or b == 10 or b == 13 then
            add(source:sub(i, i), nil)
            i = i + 1
        elseif b == 45 and source:byte(i + 1) == 45 then
            local start = i
            i = i + 2
            local closeTag = getLongBracketLevel(i)
            if closeTag then
                local found = source:find(closeTag, i, true)
                i = found and (found + #closeTag) or (len + 1)
            else
                while i <= len and source:byte(i) ~= 10 do
                    i = i + 1
                end
            end
            add(Utils.Escape(source:sub(start, i - 1)), Config.Colors.Syntax.Comment)
        elseif b == 34 or b == 39 then
            local quote = b
            add(source:sub(i, i), Config.Colors.Syntax.String)
            i = i + 1
            while i <= len do
                local curr = source:byte(i)
                if curr == 92 then
                    if source:byte(i + 1) then
                        add(Utils.Escape(source:sub(i, i + 1)), Config.Colors.Syntax.Escape)
                        i = i + 2
                    else
                        add("\\", Config.Colors.Syntax.String)
                        i = i + 1
                    end
                elseif curr == quote then
                    add(source:sub(i, i), Config.Colors.Syntax.String)
                    i = i + 1
                    break
                else
                    add(Utils.Escape(source:sub(i, i)), Config.Colors.Syntax.String)
                    i = i + 1
                end
            end
        elseif b == 91 and getLongBracketLevel(i) then
            local closeTag = getLongBracketLevel(i)
            local start = i
            local found = source:find(closeTag, i + #closeTag, true)
            i = found and (found + #closeTag) or (len + 1)
            add(Utils.Escape(source:sub(start, i - 1)), Config.Colors.Syntax.String)
        elseif (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or b == 95 then
            local start = i
            while i <= len do
                local c = source:byte(i)
                if (c >= 65 and c <= 90) or (c >= 97 and c <= 122) or c == 95 or (c >= 48 and c <= 57) then
                    i = i + 1
                else
                    break
                end
            end
            local word = source:sub(start, i - 1)
            local color = TokenColorMap[word]
            if not color then
                local p = start - 1
                while p > 0 do
                    local pb = source:byte(p)
                    if pb ~= 32 and pb ~= 9 and pb ~= 10 then break end
                    p = p - 1
                end
                color = Config.Colors.Syntax.Default
                if source:byte(p) == 46 then
                    color = Config.Colors.Syntax.Property
                elseif source:byte(p) == 58 or source:byte(i) == 40 or source:byte(i) == 34 or source:byte(i) == 39 or source:byte(i) == 123 then
                    color = Config.Colors.Syntax.Method
                end
            end
            add(word, color)
        elseif b >= 48 and b <= 57 then
            local start = i
            while i <= len do
                local cb = source:byte(i)
                if (cb >= 48 and cb <= 57) or cb == 46 or cb == 120 or cb == 101 or (cb >= 65 and cb <= 70) then
                    i = i + 1
                else
                    break
                end
            end
            add(source:sub(start, i - 1), Config.Colors.Syntax.Number)
        else
            if TokenMap.Brackets[b] then
                if b == 91 or b == 123 or b == 40 then
                    add(Utils.Escape(source:sub(i, i)), bracketPalette[(bracketDepth % #bracketPalette) + 1])
                    bracketDepth = bracketDepth + 1
                else
                    bracketDepth = math.max(0, bracketDepth - 1)
                    add(Utils.Escape(source:sub(i, i)), bracketPalette[(bracketDepth % #bracketPalette) + 1])
                end
            elseif TokenMap.Operators[b] then
                add(Utils.Escape(source:sub(i, i)), Config.Colors.Syntax.Operator)
            elseif TokenMap.Punctuation[b] then
                add(Utils.Escape(source:sub(i, i)), Config.Colors.Syntax.Punctuation)
            else
                add(Utils.Escape(source:sub(i, i)), Config.Colors.Syntax.Default)
            end
            i = i + 1
        end
    end
    flush()
    if #currentChunk > 0 then
        table.insert(chunks, table.concat(currentChunk))
    end
    return chunks
end

function Utils.GetPath(obj)
    if obj == nil then
        return "nil"
    end
    if typeof(obj) ~= "Instance" then
        return tostring(obj)
    end
    if obj.Parent == nil and obj ~= game then
        return string.format("nil --[[ %s 未连接到game ]]", obj.Name)
    end

    local path = {}
    local current = obj

    while current and current ~= game do
        if current.Parent == game then
            table.insert(path, 1, string.format('game:GetService("%s")', current.Name))
        else
            if current.Name:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
                table.insert(path, 1, "." .. current.Name)
            else
                table.insert(path, 1, "[" .. Utils.SafeString(current.Name) .. "]")
            end
        end
        current = current.Parent
    end

    if current == game then
        return table.concat(path)
    else
        return "nil"
    end
end

function Utils.Serialize(v, indentLevel, visited)
    local handler = TypeSerializers[typeof(v)]
    if handler then
        return handler(v, indentLevel or 0, visited or {})
    else
        return string.format("nil --[[ %s ]]", typeof(v))
    end
end

function Utils.GenCode(remote, args, method)
    local path = Utils.GetPath(remote)
    local code = ""

    if #args == 1 and type(args[1]) == "table" and next(args[1]) == nil then
        code = string.format("%s:%s({})", path, method)
    elseif next(args) == nil then
        code = string.format("%s:%s()", path, method)
    else
        code = string.format("local args = %s\n\n%s:%s(unpack(args))", Utils.Serialize(args), path, method)
        if args[1] == nil then
            code = code:gsub("local args = {", "local args = {\n    [1] = nil,", 1)
        end
    end

    return Lexer.Highlight(code), code
end

function UI.Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

function UI.CreateBtn(parent, props, onClick)
    local btn = UI.Create("TextButton", {
        Size = props.Size or UDim2.new(1, 0, 1, 0),
        Position = props.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = props.Color or Config.Colors.Sidebar,
        BackgroundTransparency = props.Trans or 1,
        Text = props.Text or "",
        TextColor3 = props.TextColor or Config.Colors.Text,
        TextScaled = true,
        RichText = true,
        Font = Config.Fonts.Main,
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder or 0,
        Parent = parent
    })

    UI.Create("UITextSizeConstraint", { MaxTextSize = props.TextSize or 14, Parent = btn })

    if props.Radius then
        UI.Create("UICorner", { CornerRadius = UDim.new(0, props.Radius), Parent = btn })
    end

    if onClick then
        btn.MouseButton1Click:Connect(function()
            onClick(btn)
        end)
    end

    return btn
end

function UI.CreateIconButton(parent, icon, size, pos, onClick)
    local btn = UI.Create("ImageButton", {
        BackgroundTransparency = 1,
        Image = icon,
        ImageColor3 = Config.Colors.Text,
        Size = size,
        Position = pos,
        BorderSizePixel = 0,
        Parent = parent
    })

    if onClick then
        btn.MouseButton1Click:Connect(function()
            onClick(btn)
        end)
    end

    return btn
end

function UI.CreateButtonGroup(parent, layoutCfg, buttons)
    local holder = UI.Create("Frame", {
        Size = layoutCfg.Size or UDim2.new(1, 0, 1, 0),
        Position = layoutCfg.Position or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = parent,
        BorderSizePixel = 0
    })

    UI.Create("UIListLayout", {
        Parent = holder,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, layoutCfg.Pad or 0),
        HorizontalAlignment = layoutCfg.Align or Enum.HorizontalAlignment.Left
    })

    local autoSize = layoutCfg.AutoWidth and UDim2.new(1 / #buttons, -((#buttons - 1) * (layoutCfg.Pad or 0)) / #buttons, 1, 0)

    for _, info in ipairs(buttons) do
        local btn = UI.CreateBtn(holder, {
            Text = info.Text,
            Color = info.Color or Color3.new(0, 0, 0),
            TextColor = info.TextColor,
            Size = autoSize or info.Size or UDim2.new(0, 45, 1, 0),
            Radius = layoutCfg.Radius,
            TextSize = layoutCfg.TextSize or 14,
            Trans = info.Trans or (info.Color and 0 or 1)
        }, info.OnClick)

        if info.HoverColor then
            btn.MouseEnter:Connect(function()
                btn.BackgroundTransparency = 0
                btn.BackgroundColor3 = info.HoverColor
                if info.HoverColor == Config.Colors.Close then
                    btn.TextColor3 = Color3.new(1, 1, 1)
                end
            end)

            btn.MouseLeave:Connect(function()
                btn.BackgroundTransparency = 1
                btn.BackgroundColor3 = info.Color or Config.Colors.Sidebar
                btn.TextColor3 = info.TextColor or Config.Colors.Text
            end)
        end
    end

    return holder
end

function UI.RegisterDrag(trigger, onDrag, onEnd, options)
    options = options or {}
    local dragging, dragStart, startMouse, hasMoved

    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startMouse = input.Position
            hasMoved = false
        end
    end)

    Services.UserInput.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local curr = input.Position
            local delta = curr - dragStart
            if options.ClickThreshold and (curr - startMouse).Magnitude < options.ClickThreshold then
                return
            end
            hasMoved = true
            dragStart = curr
            onDrag(delta)
        end
    end)

    Services.UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                if onEnd then
                    onEnd(not hasMoved)
                end
            end
        end
    end)
end

function UI.MakeDraggable(target, handle)
    UI.RegisterDrag(handle, function(delta)
        target.Position = target.Position + UDim2.new(0, delta.X, 0, delta.Y)
    end)
end

function UI.MakeFloatingDraggable(button, clickCallback)
    UI.RegisterDrag(button, function(delta)
        button.Position = button.Position + UDim2.new(0, delta.X, 0, delta.Y)
    end, function(isClick)
        if isClick then
            clickCallback()
        end
    end, { ClickThreshold = 5 })
end

function UI.MakeResizable(frame)
    local minSize = Vector2.new(50, 50)

    local function CreateHandle(n, s, p)
        local handle = UI.Create("TextButton", {
            Name = n,
            Size = s,
            Position = p,
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 20,
            BorderSizePixel = 0,
            Parent = frame
        })

        UI.RegisterDrag(handle, function(delta)
            local fs, fp = frame.AbsoluteSize, frame.AbsolutePosition
            local newSX, newSY, newPX, newPY = fs.X, fs.Y, fp.X, fp.Y

            if n:find("Right") then
                newSX = math.max(minSize.X, fs.X + delta.X)
            end

            if n:find("Bottom") then
                newSY = math.max(minSize.Y, fs.Y + delta.Y)
            end

            if n:find("Left") then
                local pW = fs.X - delta.X
                if pW > minSize.X then
                    newSX = pW
                    newPX = fp.X + delta.X
                end
            end

            if n:find("Top") then
                local pH = fs.Y - delta.Y
                if pH > minSize.Y then
                    newSY = pH
                    newPY = fp.Y + delta.Y
                end
            end

            frame.Size = UDim2.new(0, newSX, 0, newSY)
            frame.Position = UDim2.new(0, newPX, 0, newPY)
        end)
    end

    local t = 10
    CreateHandle("ResizeTop", UDim2.new(1, -16, 0, t), UDim2.new(0, 8, 0, -t / 2))
    CreateHandle("ResizeBottom", UDim2.new(1, -16, 0, t), UDim2.new(0, 8, 1, -t / 2))
    CreateHandle("ResizeLeft", UDim2.new(0, t, 1, -16), UDim2.new(0, -t / 2, 0, 8))
    CreateHandle("ResizeRight", UDim2.new(0, t, 1, -16), UDim2.new(1, -t / 2, 0, 8))
    CreateHandle("ResizeTopLeft", UDim2.new(0, 16, 0, 16), UDim2.new(0, -8, 0, -8))
    CreateHandle("ResizeTopRight", UDim2.new(0, 16, 0, 16), UDim2.new(1, -8, 0, -8))
    CreateHandle("ResizeBottomLeft", UDim2.new(0, 16, 0, 16), UDim2.new(0, -8, 1, -8))
    CreateHandle("ResizeBottomRight", UDim2.new(0, 16, 0, 16), UDim2.new(1, -8, 1, -8))
end

function UI.RenderLargeText(scrollingFrame, richChunks)
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if type(richChunks) == "string" then
        richChunks = { richChunks }
    end

    for i, chunkText in ipairs(richChunks) do
        UI.Create("TextLabel", {
            Text = chunkText,
            TextColor3 = Config.Colors.Text,
            BackgroundTransparency = 1,
            TextXAlignment = "Left",
            TextYAlignment = "Top",
            Font = Config.Fonts.Code,
            TextSize = 14,
            RichText = true,
            TextWrapped = false,
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Parent = scrollingFrame,
            LayoutOrder = i,
            BorderSizePixel = 0
        })
    end
end

if _G.SpyUI_Refactored then
    _G.SpyUI_Refactored:Destroy()
end

Screen = Instance.new("ScreenGui")
Screen.Name = "RemoteSpy_Refactored"
Screen.ResetOnSpawn = false
Screen.Parent = Services.CoreGui
_G.SpyUI_Refactored = Screen

local FloatingBtn = UI.Create("ImageButton", {
    Name = "FloatingBtn",
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0.1, 0, 0.1, 0),
    BackgroundColor3 = Config.Colors.Floating,
    Visible = false,
    Parent = Screen,
    AutoButtonColor = false,
    BorderSizePixel = 0
})

UI.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = FloatingBtn })

UI.Create("ImageLabel", {
    Size = UDim2.new(0.6, 0, 0.6, 0),
    Position = UDim2.new(0.2, 0, 0.2, 0),
    BackgroundTransparency = 1,
    Image = Config.Icons.Logo,
    Parent = FloatingBtn,
    BorderSizePixel = 0
})

local vp = workspace.CurrentCamera.ViewportSize
local isMobile = (vp.X < 800 or vp.Y < 500)
local startW, startH = isMobile and (vp.X * 0.9) or 900, isMobile and (vp.Y * 0.8) or 550
local sideW = isMobile and 180 or 250

local Main = UI.Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, startW, 0, startH),
    Position = UDim2.new(0.5, -startW / 2, 0.5, -startH / 2),
    BackgroundColor3 = Config.Colors.Bg,
    BorderSizePixel = 1,
    BorderColor3 = Config.Colors.Border,
    Parent = Screen,
    ClipsDescendants = true
})

UI.MakeResizable(Main)

local TopBar = UI.Create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundColor3 = Config.Colors.Sidebar,
    BorderSizePixel = 0,
    Parent = Main
})

UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Config.Colors.Border,
    BorderSizePixel = 0,
    Parent = TopBar
})

UI.Create("TextLabel", {
    Text = string.format("  Remote Spy - %s", isMobile and "移动设备" or "桌面设备"),
    Size = UDim2.new(1, -90, 1, 0),
    BackgroundTransparency = 1,
    TextColor3 = Config.Colors.Text,
    TextXAlignment = "Left",
    Font = Config.Fonts.Main,
    TextSize = 14,
    Parent = TopBar,
    BorderSizePixel = 0
})

local savedSize, savedPos = Main.Size, Main.Position

local function ToggleMinimize()
    if Main.Visible then
        savedSize, savedPos = Main.Size, Main.Position
        Services.Tween:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = FloatingBtn.Position,
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.3, function()
            Main.Visible = false
            Main.Size = savedSize
            Main.Position = savedPos
            FloatingBtn.Visible = true
            Services.Tween:Create(FloatingBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 50)
            }):Play()
        end)
    else
        Services.Tween:Create(FloatingBtn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.delay(0.2, function()
            FloatingBtn.Visible = false
            Main.Visible = true
            Main.Size = UDim2.new(0, 0, 0, 0)
            Main.Position = FloatingBtn.Position
            Main.BackgroundTransparency = 1
            Services.Tween:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = savedSize,
                Position = savedPos,
                BackgroundTransparency = 0
            }):Play()
        end)
    end
end

UI.CreateButtonGroup(TopBar, {
    Align = Enum.HorizontalAlignment.Right,
    Size = UDim2.new(1, 0, 1, 0),
    TextSize = 24
}, {
    {
        Text = "−",
        HoverColor = Config.Colors.Minimize,
        OnClick = ToggleMinimize
    },
    {
        Text = "×",
        HoverColor = Config.Colors.Close,
        OnClick = function()
            Screen:Destroy()
        end
    }
})

UI.MakeDraggable(Main, TopBar)
UI.MakeFloatingDraggable(FloatingBtn, ToggleMinimize)

Main.Size = UDim2.new(0, 0, 0, 0)
Services.Tween:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, startW, 0, startH)
}):Play()

local Container = UI.Create("Frame", {
    Size = UDim2.new(1, 0, 1, -36),
    Position = UDim2.new(0, 0, 0, 36),
    BackgroundTransparency = 1,
    Parent = Main,
    ClipsDescendants = true,
    BorderSizePixel = 0
})

local SidebarContainer = UI.Create("Frame", {
    Size = UDim2.new(0, sideW, 1, 0),
    BackgroundColor3 = Config.Colors.Sidebar,
    BorderSizePixel = 0,
    Parent = Container
})

local ToolBar = UI.Create("Frame", {
    Name = "ToolBar",
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Config.Colors.Border,
    BorderSizePixel = 0,
    Parent = SidebarContainer
})

UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Config.Colors.Border,
    BorderSizePixel = 0,
    Parent = ToolBar,
    ZIndex = 10
})

local ToolBtnsHolder = UI.Create("Frame", {
    Size = UDim2.new(1, 0, 1, -1),
    BackgroundTransparency = 1,
    Parent = ToolBar
})

UI.Create("UIListLayout", {
    Parent = ToolBtnsHolder,
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 1)
})

Sidebar = UI.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -32),
    Position = UDim2.new(0, 0, 0, 32),
    BackgroundColor3 = Config.Colors.Sidebar,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = SidebarContainer
})

SidebarLayout = UI.Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = Sidebar
})

local AutoBtn, ModeBtn, RefreshBtnWrapper

local function ApplySort(group)
    local sv = { Time = -group.LastFire, Count = -group.TotalCalls, Name = 0 }
    group.Wrapper.LayoutOrder = sv[SortMode] or 0
end

local function TriggerRefresh()
    SidebarLayout.SortOrder = (SortMode == "Name") and Enum.SortOrder.Name or Enum.SortOrder.LayoutOrder
    if SortMode ~= "Name" then
        for _, g in pairs(Cache) do
            ApplySort(g)
        end
    end
end

local function UpdateToolBarLayout()
    local s = UDim2.new(1 / (AutoSort and 2 or 3), -1, 1, 0)
    AutoBtn.Size = s
    ModeBtn.Size = s
    RefreshBtnWrapper.Size = s
    RefreshBtnWrapper.Visible = not AutoSort
end

AutoBtn = UI.CreateBtn(ToolBtnsHolder, {
    Text = "自动",
    Size = UDim2.new(0.5, 0, 1, 0),
    TextColor = Config.Colors.AutoOn,
    TextSize = 12,
    Color = Config.Colors.Sidebar,
    Trans = 0
}, function(btn)
    AutoSort = not AutoSort
    btn.Text = AutoSort and "自动" or "手动"
    btn.TextColor3 = AutoSort and Config.Colors.AutoOn or Config.Colors.AutoOff
    if AutoSort then TriggerRefresh() end
    UpdateToolBarLayout()
end)
AutoBtn.LayoutOrder = 1

ModeBtn = UI.CreateBtn(ToolBtnsHolder, {
    Text = "时间",
    Size = UDim2.new(0.5, 0, 1, 0),
    TextSize = 12,
    Color = Config.Colors.Sidebar,
    Trans = 0
}, function(btn)
    local m = { Time = "时间", Name = "名称", Count = "次数" }
    local nm = { Time = "Name", Name = "Count", Count = "Time" }
    SortMode = nm[SortMode]
    btn.Text = m[SortMode]
    TriggerRefresh()
end)
ModeBtn.LayoutOrder = 2

RefreshBtnWrapper = UI.Create("Frame", {
    BackgroundColor3 = Config.Colors.Sidebar,
    Size = UDim2.new(0.33, 0, 1, 0),
    Visible = false,
    LayoutOrder = 3,
    Parent = ToolBtnsHolder,
    BorderSizePixel = 0
})

UI.CreateIconButton(RefreshBtnWrapper, Config.Icons.Refresh, UDim2.new(0, 16, 0, 16), UDim2.new(0.5, -8, 0.5, -8), function(btn)
    TriggerRefresh()
    local c = btn.Rotation
    local t = math.ceil((c + 360) / 360) * 360
    Services.Tween:Create(btn, TweenInfo.new(0.5 * ((t - c) / 360), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = t }):Play()
end)

UpdateToolBarLayout()

UI.Create("Frame", {
    Name = "SepV",
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(0, sideW, 0, 0),
    BackgroundColor3 = Config.Colors.Border,
    BorderSizePixel = 0,
    Parent = Container
})

ContentArea = UI.Create("Frame", {
    Size = UDim2.new(1, -sideW - 1, 1, 0),
    Position = UDim2.new(0, sideW + 1, 0, 0),
    BackgroundColor3 = Config.Colors.ContentBg,
    BorderSizePixel = 0,
    Parent = Container
})

local TabContainer = UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Config.Colors.Sidebar,
    BorderSizePixel = 0,
    Parent = ContentArea
})

UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Config.Colors.Border,
    Parent = TabContainer,
    BorderSizePixel = 0
})

local TabArgsBtn, TabStackBtn

local function SwitchTab(tN)
    CurrentTab = tN
    TabArgsBtn.BackgroundColor3 = (tN == "Args") and Config.Colors.TabActive or Config.Colors.TabInactive
    TabStackBtn.BackgroundColor3 = (tN == "Stack") and Config.Colors.TabActive or Config.Colors.TabInactive
    TabArgsBtn.BackgroundTransparency = (tN == "Args") and 0 or 1
    TabStackBtn.BackgroundTransparency = (tN == "Stack") and 0 or 1
    ArgsPage.Visible = (tN == "Args")
    StackPage.Visible = (tN == "Stack")
end

TabArgsBtn = UI.CreateBtn(TabContainer, {
    Text = "参数",
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Trans = 1
}, function()
    SwitchTab("Args")
end)

TabStackBtn = UI.CreateBtn(TabContainer, {
    Text = "调用栈",
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    Trans = 1
}, function()
    SwitchTab("Stack")
end)

ArgsPage = UI.Create("Frame", {
    Size = UDim2.new(1, 0, 1, -30),
    Position = UDim2.new(0, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = ContentArea,
    Visible = true
})

local CodeScroll = UI.Create("ScrollingFrame", {
    Size = UDim2.new(1, -10, 1, -55),
    Position = UDim2.new(0, 5, 0, 5),
    BackgroundColor3 = Config.Colors.ContentBg,
    BorderSizePixel = 0,
    ScrollBarThickness = 8,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.XY,
    Parent = ArgsPage
})

UI.Create("UIListLayout", { Parent = CodeScroll, SortOrder = Enum.SortOrder.LayoutOrder })
UI.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = CodeScroll })

UI.CreateButtonGroup(ArgsPage, {
    Position = UDim2.new(0, 10, 1, -45),
    Size = UDim2.new(1, -20, 0, 40),
    AutoWidth = true,
    Pad = 8,
    Radius = 4
}, {
    {
        Text = "复 制 代 码",
        Color = Config.Colors.Item,
        TextColor = Color3.new(1, 1, 1),
        OnClick = function(b)
            if setclipboard and CurrentRaw ~= "" then
                setclipboard(CurrentRaw)
                b.Text = "已复制!"
                task.delay(1, function() b.Text = "复 制 代 码" end)
            end
        end
    },
    {
        Text = "发 送",
        Color = Config.Colors.Item,
        TextColor = Color3.new(1, 1, 1),
        OnClick = function(b)
            if CurrentLogData then
                task.spawn(function()
                    local s, e = pcall(function()
                        return CurrentLogData.Remote[CurrentLogData.Method](CurrentLogData.Remote, unpack(CurrentLogData.Args))
                    end)
                    if not s then warn("Execution failed:", e) end
                end)
                b.Text = "已发送"
            else
                b.Text = "未选择"
            end
            task.delay(1, function() b.Text = "发 送" end)
        end
    }
})

StackPage = UI.Create("Frame", {
    Size = UDim2.new(1, 0, 1, -30),
    Position = UDim2.new(0, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = ContentArea,
    Visible = false
})

UI.Create("UIListLayout", { Parent = StackPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
UI.Create("UIPadding", { Parent = StackPage, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) })

StackList = UI.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0.4, 0),
    BackgroundColor3 = Config.Colors.Sidebar,
    BorderSizePixel = 0,
    ScrollBarThickness = 8,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    LayoutOrder = 1,
    Parent = StackPage
})

UI.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = StackList })
UI.Create("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingTop = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), Parent = StackList })

local SelectedStackFrame = nil
local StackDetailScroll = UI.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0.6, -40),
    BackgroundColor3 = Config.Colors.Sidebar,
    BorderSizePixel = 0,
    ScrollBarThickness = 8,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.XY,
    LayoutOrder = 3,
    Parent = StackPage
})

UI.Create("UIListLayout", { Parent = StackDetailScroll, SortOrder = Enum.SortOrder.LayoutOrder })
UI.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = StackDetailScroll })

local function ShowStackDetail(mode)
    if not SelectedStackFrame then
        UI.RenderLargeText(StackDetailScroll, "-- 请先选择栈帧")
        return
    end
    local handler = StackDetailHandlers[mode]
    if not handler then return end
    local headerText = string.format("-- [ %s ]\n", handler.Title)
    local rawContent = handler.Get(SelectedStackFrame.Func, SelectedStackFrame)
    CurrentStackDetailRaw = headerText .. rawContent
    local chunks = Lexer.Highlight(rawContent)
    table.insert(chunks, 1, headerText)
    UI.RenderLargeText(StackDetailScroll, chunks)
end

UI.CreateButtonGroup(StackPage, {
    Size = UDim2.new(1, 0, 0, 30),
    AutoWidth = true,
    Pad = 5,
    Radius = 4,
    TextSize = 12
}, {
    { Text = "快照", Color = Config.Colors.Item, OnClick = function() ShowStackDetail("Locals") end },
    { Text = "上值", Color = Config.Colors.Item, OnClick = function() ShowStackDetail("Upvalues") end },
    { Text = "常量", Color = Config.Colors.Item, OnClick = function() ShowStackDetail("Constants") end },
    { Text = "反编译", Color = Config.Colors.Item, OnClick = function() ShowStackDetail("Decompile") end },
    {
        Text = "复制详情",
        Color = Config.Colors.Item,
        TextColor = Color3.new(1, 1, 1),
        OnClick = function(b)
            if setclipboard and CurrentStackDetailRaw ~= "" then
                setclipboard(CurrentStackDetailRaw)
                b.Text = "已复制"
            else
                b.Text = "无内容"
            end
            task.delay(1, function() b.Text = "复制详情" end)
        end
    }
}).LayoutOrder = 2

UI.RenderLargeText(StackDetailScroll, "-- 选择一个栈帧查看详情")

local function RenderStack(traceback)
    for _, v in pairs(StackList:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
    SelectedStackFrame = nil
    CurrentStackDetailRaw = ""
    UI.RenderLargeText(StackDetailScroll, "-- 选择一个栈帧查看详情")
    for i, frame in ipairs(traceback) do
        local f = frame.Func
        local name = debug.info(f, "n")
        name = (name and name ~= "") and name or "匿名函数"
        local src = debug.info(f, "s") or "nil"
        local btn = UI.CreateBtn(StackList, {
            Text = string.format("%d. <font color='#4EC9B0'>%s</font> <font color='#808080'>(%s:%d)</font>", i, Utils.Escape(name), Utils.Escape(src), debug.info(f, "l") or -1),
            Size = UDim2.new(1, 0, 0, 24),
            Color = Config.Colors.ContentBg,
            Trans = 0,
            TextSize = 13
        }, function(b)
            for _, o in pairs(StackList:GetChildren()) do
                if o:IsA("TextButton") then
                    o.BackgroundColor3 = Config.Colors.ContentBg
                end
            end
            b.BackgroundColor3 = Config.Colors.Selected
            SelectedStackFrame = frame
        end)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        UI.Create("UIPadding", { PaddingLeft = UDim.new(0, 5), Parent = btn })
    end
end

SwitchTab("Args")

local function CreateGroup(remote, method)
    local Wrapper = UI.Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 0,
        Parent = Sidebar,
        Name = remote.Name,
        BorderSizePixel = 0
    })

    UI.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = Wrapper })

    local Header = UI.Create("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Config.Colors.Sidebar,
        AutoButtonColor = false,
        Parent = Wrapper,
        BorderSizePixel = 0
    })

    local TypeColor = (remote.ClassName == "RemoteFunction" and Config.Colors.Function) or (remote.ClassName == "UnreliableRemoteEvent" and Config.Colors.Unreliable) or Config.Colors.Event

    UI.Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = TypeColor,
        Parent = Header,
        BorderSizePixel = 0
    })

    local NameLabel = UI.Create("TextLabel", {
        Text = Utils.CleanName(remote.Name),
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 25, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = "Left",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextTruncate = "AtEnd",
        Parent = Header,
        BorderSizePixel = 0
    })

    local Arrow = UI.Create("TextLabel", {
        Text = "›",
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(0, 15, 0.5, 0),
        BackgroundTransparency = 1,
        TextColor3 = Config.Colors.SubText,
        Font = Config.Fonts.Main,
        TextSize = 18,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = Header,
        BorderSizePixel = 0
    })

    local Group = {
        Wrapper = Wrapper,
        NameLabel = NameLabel,
        Arrow = Arrow,
        History = {},
        TotalCalls = 0,
        LastFire = 0,
        Expanded = false,
        Remote = remote,
        Method = method,
        IsIgnored = false
    }

    UI.CreateIconButton(Header, Config.Icons.Eye, UDim2.new(0, 16, 0, 16), UDim2.new(1, -26, 0, 6), function(btn)
        Group.IsIgnored = not Group.IsIgnored
        btn.Image = Group.IsIgnored and Config.Icons.EyeOff or Config.Icons.Eye
        btn.ImageColor3 = Group.IsIgnored and Color3.fromRGB(200, 50, 50) or Config.Colors.Text
    end).ZIndex = 5

    Group.HistoryFrame = UI.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = Wrapper,
        BorderSizePixel = 0
    })

    Group.Layout = UI.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = Group.HistoryFrame })

    Header.MouseButton1Click:Connect(function()
        Group.Expanded = not Group.Expanded
        Services.Tween:Create(Arrow, TweenInfo.new(0.2), { Rotation = Group.Expanded and 90 or 0 }):Play()
        Group.HistoryFrame.Visible = Group.Expanded
    end)

    return Group
end

local function Log(remote, args, method, trace)
    if not Screen.Parent then return end
    local Group = Cache[remote]
    if not Group then
        Group = CreateGroup(remote, method)
        Cache[remote] = Group
    end

    Group.TotalCalls = Group.TotalCalls + 1
    Group.LastFire = tick()
    Group.NameLabel.Text = string.format("%s (%d)", Utils.CleanName(Group.Remote.Name), Group.TotalCalls)

    if AutoSort then
        ApplySort(Group)
    end
    if Group.IsIgnored then return end

    local LogBtn = UI.CreateBtn(Group.HistoryFrame, {
        Text = string.format("    #%d - %s", Group.TotalCalls, os.date("%H:%M:%S")),
        Size = UDim2.new(1, 0, 0, 24),
        Color = Config.Colors.Item,
        TextColor = Config.Colors.SubText,
        Font = Config.Fonts.Code,
        TextSize = 12,
        Trans = 0
    }, function(btn)
        if SelectedBtn then
            SelectedBtn.BackgroundColor3 = Config.Colors.Item
            SelectedBtn.TextColor3 = Config.Colors.SubText
        end
        btn.BackgroundColor3 = Config.Colors.Selected
        btn.TextColor3 = Config.Colors.Text
        SelectedBtn = btn
        CurrentLogData = { Remote = Group.Remote, Args = args, Method = method, Trace = trace }
        local richChunks, raw = Utils.GenCode(Group.Remote, args, method)
        UI.RenderLargeText(CodeScroll, richChunks)
        CurrentRaw = raw
        RenderStack(trace)
    end)

    LogBtn.LayoutOrder = -Group.TotalCalls
    LogBtn.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(Group.History, 1, LogBtn)

    if #Group.History > Config.MaxHistory then
        local old = table.remove(Group.History)
        if old then
            old:Destroy()
        end
    end
end

local bridge = coroutine.create(function() --roblox清理机制害的
    while true do
        local remote, args, method, trace = coroutine.yield()
        task.spawn(Log, remote, args, method, trace)
    end
end)
coroutine.resume(bridge)

local function hook(self, method, ...)
    if not checkcaller() then
    local args = {...}
    local trace = Utils.GetCallStack()
    task.spawn(function()
        setthreadidentity(8)
        coroutine.resume(bridge, self, args, method, trace)
    end)
end
end

local oldNamecall, oldFireServer, oldInvokeServer

oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        hook(self, method, ...)
    end
    return oldNamecall(self, ...)
end)

oldFireServer = hookfunction(getrawmetatable(game).__index(Instance.new("RemoteEvent"), "FireServer"), newcclosure(function(self, ...)
    hook(self, "FireServer", ...)
    return oldFireServer(self, ...)
end))

oldInvokeServer = hookfunction(getrawmetatable(game).__index(Instance.new("RemoteFunction"), "InvokeServer"), newcclosure(function(self, ...)
    hook(self, "InvokeServer", ...)
    return oldInvokeServer(self, ...)
end))

--[[
只能影响后续的不能影响在此之前已经保存的
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() then
        if key == "FireServer" or key == "InvokeServer" then
            return newcclosure(function(...)
                local args = {...}
                local remoteObj = args[1]
                local validArgs = {select(2, ...)}
                local trace = Utils.GetCallStack()
                task.spawn(function()
                    setthreadidentity(8)
                    coroutine.resume(bridge, remoteObj, validArgs, key, trace)
                end)
                return oldIndex(self, key)(...)
            end)
        end
    end
    return oldIndex(self, key)
end)
]]
