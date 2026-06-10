-- @ doom.dtw | 1.7 by https://github.com/alohabeach/Main/tree/master/UI Library
-- @ This UI uses SafeLoad V1. Will bypass most CoreGui checks. (ex: Peroxide, Da Hood)

-- $ VARIABLES
cloneref = cloneref or nil -- > defer warnings
local Clone_Service = cloneref or function(...) return ... end
local Services = setmetatable({}, {__index = function(self, name)
    local New_Service = Clone_Service(game:GetService(name))
    self[name] = New_Service
    return New_Service
end})

-- $ SERVICES
local RunService = Services.RunService
local InputService = Services.UserInputService
local TweenService = Services.TweenService
local Players = Services.Players

-- $ EASING DATA
local Tween_Info = TweenInfo
local Easing_Style = Enum.EasingStyle
local Easing_Direction = Enum.EasingDirection

-- $ FUNCTIONS
function AddInstance(ClassName : string, Properties : {})
    pcall(function() setthreadidentity(8) end)

    local NewInstance

    local MadeInstance, ErrorMessage = pcall(function()
        NewInstance = Instance.new(ClassName)
    end)

    if not MadeInstance then
        return error(ErrorMessage, 99)
    end

    for Property, Value in Properties do
        local _, Error = pcall(function()
            NewInstance[Property] = Value
        end)

        if Error then
            return warn(`[{NewInstance}] Problem adding instance: {Error}`)
        end
    end

    return NewInstance or nil
end

function TableOverwrite(To_Overwrite : {}, OverwriteWith : {})
    for Key, Value in pairs(OverwriteWith) do
        if type(Value) == 'table' then
            To_Overwrite[Key] = TableOverwrite(To_Overwrite[Key] or {}, Value)
        else
            To_Overwrite[Key] = Value
        end
    end

    return To_Overwrite or nil
end

function EncryptedString()
    -- > local Characters = "azxcvnmiopqyu1234567890"
    local Characters = [[救效须介首助职例热毕节害击乱态嗯宝倒注]]
    local Str = ''
    for i = 1, 99 do
        Str = Str .. Characters:sub(
            math.random(1, #Characters),
            math.random(1, #Characters)
        )
    end

    return Str
end

function SafeLoad(Instance : Instance, Encrypt_Names : boolean)
    if Encrypt_Names then
        for _, Descendant in ipairs(Instance:GetDescendants()) do
            Descendant.Name = EncryptedString()
        end
    end

    local ElevationAllowed = pcall(function() local a = cloneref(game:GetService("CoreGui")):GetFullName() end)
    Instance.Parent = ElevationAllowed and Services.CoreGui or Services.Players.LocalPlayer.PlayerGui
end

-- $ LIBRARY
local Vigil = { LIBRARY_INSTANCE = nil }

-- $ LIBRARY FUNCTIONS
function Vigil.init()
    if Vigil.LIBRARY_INSTANCE then
        SafeLoad(Vigil.LIBRARY_INSTANCE, true)
    end
end

function Vigil:toggle(Value)
    if not Vigil.LIBRARY_INSTANCE then return warn('No VIGIL instance detected.') end

    if Value then
        Vigil.LIBRARY_INSTANCE.Enabled = Value
    else
        Vigil.LIBRARY_INSTANCE.Enabled = Vigil.LIBRARY_INSTANCE.Enabled
    end
end

function Vigil.new(Name, ...)
    -- $$ Metadata
    local UI_Dragging = false;
    local UI_DragPos = nil;
    local UI_FramePos = nil;
    local UI_DeltaPos = nil;
    local Window, Meta = {
        ToggleKey = nil;
        Hidden = false;
        Pages = {};
    }, {
        Anchor = Vector2.new(.5, .5);
        Size = UDim2.new(0, 600, 0, 526);
        Pos = UDim2.new(0.809, 0, 0.75, 0);
    }

    Meta = TableOverwrite(Meta, ... or {})

    -- $$ Instances
    local WindowFrame = AddInstance("ImageLabel", { Parent = nil, Name = [[WindowFrame]], AnchorPoint = Meta.Anchor, Active = true, Selectable = true, Image = [[rbxassetid://92051109372532]], BorderSizePixel = 0, Size = Meta.Size, ScaleType = Enum.ScaleType.Stretch, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = Meta.Pos, BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
    local TopBarFrame = AddInstance("Frame", { Parent = WindowFrame, Name = [[Banner]], AnchorPoint = Vector2.new(0.5, 0), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0.118902437, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
    local ContentFrame = AddInstance("Frame", { Parent = WindowFrame, Name = [[Content]], AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0.875, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.5, 0, 0.562061369, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
    local SidebarFrame = AddInstance("ImageLabel", { Parent = ContentFrame, Name = [[SidebarFrame]], LayoutOrder = 1, AnchorPoint = Vector2.new(0.5, 0.5), Image = [[rbxassetid://84563213653891]], BorderSizePixel = 0, Size = UDim2.new(0.302439034, 0, 0.959999979, 0), ScaleType = Enum.ScaleType.Stretch, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.0175609756, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
    local TabsFrame = AddInstance("ImageLabel", { Parent = ContentFrame, Name = [[ContentFrame]], LayoutOrder = 2, AnchorPoint = Vector2.new(0, 0.5), Image = [[rbxassetid://91973614665311]], BorderSizePixel = 0, Size = UDim2.new(0.646829247, 0, 0.959999979, 0), ScaleType = Enum.ScaleType.Stretch, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.0175609756, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
    local TitleTextLabel = AddInstance("TextLabel", { Parent = TopBarFrame, Name = [[TitleTextLabel]], TextWrapped = false, BorderSizePixel = 0, TextScaled = true, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 14, Size = UDim2.new(1, 0, 0.632911384, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Name, Font = Enum.Font.Gotham, Position = UDim2.new(0.5, 0, 0.5, 0), TextColor3 = Color3.fromRGB(117, 117, 117), BackgroundTransparency = 1,})
    local SidebarScrollingFrame = AddInstance("ScrollingFrame", { Parent = SidebarFrame, ClipsDescendants = false; ScrollingDirection = Enum.ScrollingDirection.Y, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0.836525023, 0, 1, 0), ScrollBarImageColor3 = Color3.fromRGB(101, 101, 101), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderColor3 = Color3.fromRGB(0, 0, 0), ScrollBarThickness = 6, Position = UDim2.new(0.543262482, 0, 0.5, 0), BackgroundTransparency = 1, Selectable = false,})
    local SelectionLine = AddInstance("Frame", { Parent = nil, Name = [[Line]], AnchorPoint = Vector2.new(0, 0.5), BorderSizePixel = 0, Size = UDim2.new(0, 2, 1, 9), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, -5, 0.5, 0), BackgroundColor3 = Color3.fromRGB(154, 154, 154),})

    -- $$ UI Effects
    AddInstance("Frame", { Parent = SidebarScrollingFrame, Name = [[BottomPadding]], AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Size = UDim2.new(1.04502976, 0, 0, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), LayoutOrder = 99, Position = UDim2.new(0.0450000018, 0, 0.112000003, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
    AddInstance("Frame", { Parent = SidebarScrollingFrame, Name = [[TopPadding]], AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Size = UDim2.new(1.04502976, 0, -0.00529100513, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), LayoutOrder = -99, Position = UDim2.new(0.0450000018, 0, 0.112000003, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
    AddInstance("UIListLayout", { Parent = SidebarScrollingFrame, Padding = UDim.new(0.0599999987, 0), SortOrder = Enum.SortOrder.LayoutOrder,})
    --AddInstance("UIAspectRatioConstraint", { Parent = WindowFrame, AspectRatio = 1.1388888359069824,})
    AddInstance("UIListLayout", { Parent = ContentFrame, VerticalAlignment = Enum.VerticalAlignment.Center, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0.0160000008, 0), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,})

    -- $$ If UI does not exist, create one
    if not Vigil.LIBRARY_INSTANCE then
        Vigil.LIBRARY_INSTANCE = AddInstance('ScreenGui', {
            Name = EncryptedString();
            IgnoreGuiInset = true;
            ResetOnSpawn = false;
        })

        -- $ Loads UI into Vigil Instance
        WindowFrame.Parent = Vigil.LIBRARY_INSTANCE
    end

    -- $$ Functions + Connections
    local function ValidateInputType(InputType)
        if InputType == Enum.UserInputType.MouseButton1 then return true end
        if InputType == Enum.UserInputType.MouseMovement then return true end
        if InputType == Enum.UserInputType.Touch then return true end
    end

    InputService.InputBegan:Connect(function(Input)
        local InputType = Input.UserInputType

        if Input.KeyCode == Window.ToggleKey then
            if not game:GetService('UserInputService'):GetFocusedTextBox() then
                Window.Hidden = not Window.Hidden

                TweenService:Create(
                    WindowFrame,
                    Tween_Info.new(.25, Easing_Style.Quad, Easing_Direction.InOut),
                    { Size = Window.Hidden and UDim2.new(Meta.Size.X.Scale, Meta.Size.X.Offset, 0, 0) or Meta.Size }
                ):Play()

                TweenService:Create(
                    TitleTextLabel,
                    Tween_Info.new(.25, Easing_Style.Quad, Easing_Direction.InOut),
                    { TextTransparency = Window.Hidden and 1 or 0 }
                ):Play()

                ContentFrame.Visible = not Window.Hidden
            end
        end

        if ValidateInputType(InputType) and WindowFrame.GuiState == Enum.GuiState.Press then
            UI_DragPos = Input.Position
            UI_FramePos = WindowFrame.Position
            UI_Dragging = true
        end

        -- >> Input Ended
        Input.Changed:Connect(function(InputType)
            local InputState = Input.UserInputState

            if InputState == Enum.UserInputState.End then
                UI_Dragging = false
            end
        end)
    end)

    InputService.InputChanged:Connect(function(Input)
        local InputType = Input.UserInputType

        if ValidateInputType(InputType) then
            if UI_Dragging then
                UI_DeltaPos = Input.Position - UI_DragPos

                WindowFrame.Position = UDim2.new(
                    UI_FramePos.X.Scale, UI_FramePos.X.Offset + UI_DeltaPos.X,
                    UI_FramePos.Y.Scale, UI_FramePos.Y.Offset + UI_DeltaPos.Y
                )
            end
        end
    end)

    function Window:toggle()
        if not game:GetService('UserInputService'):GetFocusedTextBox() then
            Window.Hidden = not Window.Hidden

            TweenService:Create(
                WindowFrame,
                Tween_Info.new(.25, Easing_Style.Quad, Easing_Direction.InOut),
                { Size = Window.Hidden and UDim2.new(Meta.Size.X.Scale, Meta.Size.X.Offset, 0, 0) or Meta.Size }
            ):Play()

            TweenService:Create(
                TitleTextLabel,
                Tween_Info.new(.25, Easing_Style.Quad, Easing_Direction.InOut),
                { TextTransparency = Window.Hidden and 1 or 0 }
            ):Play()

            ContentFrame.Visible = not Window.Hidden
        end
    end

    function Window:setPosition(NewPosition)
        assert(typeof(NewPosition) == "Udim2", "Invalid argument #1, expected 'Udim2' got " .. typeof(NewPosition))
        WindowFrame.Position = NewPosition
    end

    function Window:getPosition()
        return WindowFrame.Position
    end

    function Window:addPage(Name, ...)
        -- $$$ Metadata
        local Page, Meta = {}, {
            Name = 'Page'
        }

        -- $$$ Instances
        local PageButton = AddInstance("TextButton", { Parent = SidebarScrollingFrame, Name = [[TabButton]], TextWrapped = false, BorderSizePixel = 0, TextScaled = true, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 14, Size = UDim2.new(1.04502976, 0, 0.0449735448, 0), LayoutOrder = 6, TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Name, Font = Enum.Font.GothamMedium, Position = UDim2.new(0.5, 0, 0.5, 0), TextColor3 = Color3.fromRGB(81, 81, 81), BackgroundTransparency = 1, Selectable = false,});
        local PageFrame = AddInstance("ScrollingFrame", { Parent = TabsFrame, Name = [[TabFrame]], ScrollingDirection = Enum.ScrollingDirection.Y, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, 0, 0, 0), ScrollBarImageColor3 = Color3.fromRGB(141, 141, 141), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderColor3 = Color3.fromRGB(0, 0, 0), ScrollBarThickness = 6, Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1,});
        AddInstance("UIListLayout", { Parent = PageFrame, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,})
        AddInstance("UIPadding", { Parent = PageFrame, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

        Window.Pages[Name] = {
            PageButton = PageButton;
            PageFrame = PageFrame;
        }

        function Page:open()
            for _, PageData in Window.Pages do
                PageData.PageFrame.Visible = false
                PageData.PageFrame.Size = UDim2.new(1,0,0,0)

                TweenService:Create(
                    PageData.PageButton,
                    Tween_Info.new(.25, Easing_Style.Quad, Easing_Direction.InOut),
                    { TextColor3 = Color3.fromHSV(0,0,0.317) }
                ):Play()

                TweenService:Create(
                    SelectionLine,
                    Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut),
                    { BackgroundTransparency = 1 }
                ):Play()
            end

            SelectionLine.Parent = PageButton
            PageFrame.Visible = true
            TweenService:Create(
                PageButton,
                Tween_Info.new(.25, Easing_Style.Quad, Easing_Direction.InOut),
                { TextColor3 = Color3.fromHSV(0, 0, 0.592157) }
            ):Play()

            TweenService:Create(
                SelectionLine,
                Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut),
                { BackgroundTransparency = 0 }
            ):Play()

            TweenService:Create(
                PageFrame,
                Tween_Info.new(.25, Easing_Style.Quad, Easing_Direction.InOut),
                { Size = UDim2.new(1,0,1,0) }
            ):Play()
        end

        -- $$$ Functions + Connections
        PageButton.MouseButton1Click:Connect(function()
            Page:open()
        end)

        function Page:addSection(SectionName)
            -- $$$$ Metadata
            local Section, Meta = {}, {}

            local SectionFrame = AddInstance("Frame", { Parent = PageFrame, AutomaticSize = Enum.AutomaticSize.Y; Name = [[Section]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
            local SectionLabel = AddInstance("TextLabel", { Parent = SectionFrame, Name = [[SectionLabel]], TextWrapped = true, BorderSizePixel = 0, TextYAlignment = Enum.TextYAlignment.Top, TextScaled = true, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 14, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = -1, TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = SectionName, FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), Position = UDim2.new(0.500000298, 0, 0.0535870567, 0), TextColor3 = Color3.fromRGB(172, 172, 172), BackgroundTransparency = 1,})
            local UIListLayout = AddInstance("UIListLayout", { Parent = SectionFrame, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,})
            local UIPadding = AddInstance("UIPadding", { Parent = SectionFrame, PaddingRight = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5),})

            -- $$$$ Functions + Connections

            function Section:addCheckpoints(...)
                -- $$$$$ Metadata
                local Checkpoints, Meta = {
                    lastCheckpoint = "";
                    lastLabel = nil;
                    Occurrences = 1;
                }, {
                    xAlignment = Enum.TextXAlignment.Left;
                    maxHeight = 150;
                }

                Meta = TableOverwrite(Meta, ... or {})

                -- $$$$$ Instances
                local CheckpointsFrame = AddInstance("Frame", { Parent = SectionFrame, Name = [[CheckpointsFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, Meta.maxHeight), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(39, 39, 39),})
                local CheckpointsScroll = AddInstance("ScrollingFrame", { Parent = CheckpointsFrame, Name = [[CheckpointsScroll]], ScrollingDirection = Enum.ScrollingDirection.Y, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(1, 0, 1, 0), ScrollBarImageColor3 = Color3.fromRGB(101, 101, 101), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderColor3 = Color3.fromRGB(0, 0, 0), ScrollBarThickness = 6, BackgroundTransparency = 1, Selectable = false,})
                AddInstance("UIListLayout", { Parent = CheckpointsScroll, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,})
                AddInstance("UIPadding", { Parent = CheckpointsScroll, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
                AddInstance("UICorner", { Parent = CheckpointsFrame, CornerRadius = UDim.new(0, 4),})
                AddInstance("UIStroke", { Parent = CheckpointsFrame, Thickness = 2, Color = Color3.fromRGB(68, 68, 68),})

                -- $$$$$ Functions + Connections
                local ColorVariants = {
                    default = Color3.fromRGB(200, 200, 200),
                    success = Color3.fromRGB(100, 220, 120),
                    destructive = Color3.fromRGB(240, 100, 100),
                    warning = Color3.fromRGB(255, 200, 80),
                    info = Color3.fromRGB(100, 180, 255),
                    muted = Color3.fromRGB(140, 140, 140),
                }

                function Checkpoints:add(NewCheckpoint, ColorVariant)
                    pcall(function()
                        ColorVariant = ColorVariant or "default"
                        local TextColor = ColorVariants[ColorVariant] or ColorVariants.default

                        if NewCheckpoint ~= Checkpoints.lastCheckpoint then
                            Checkpoints.Occurrences = 1

                            local CheckpointLabel = AddInstance("TextLabel", {
                                Parent = CheckpointsScroll,
                                Name = [[CheckpointLabel]],
                                TextWrapped = true,
                                BorderSizePixel = 0,
                                TextYAlignment = Enum.TextYAlignment.Top,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                TextSize = 14,
                                Size = UDim2.new(1, 0, 0, 18),
                                AutomaticSize = Enum.AutomaticSize.Y,
                                TextXAlignment = Meta.xAlignment,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                Text = NewCheckpoint,
                                Font = Enum.Font.Gotham,
                                TextColor3 = TextColor,
                                BackgroundTransparency = 1,
                            })

                            Checkpoints.lastLabel = CheckpointLabel
                            Checkpoints.lastCheckpoint = NewCheckpoint

                            CheckpointsScroll.CanvasPosition = Vector2.new(0, CheckpointsScroll.AbsoluteCanvasSize.Y)
                        else
                            Checkpoints.Occurrences += 1

                            if Checkpoints.lastLabel then
                                local OccurrencesMessage = string.format(" (%dx)", Checkpoints.Occurrences)
                                Checkpoints.lastLabel.Text = NewCheckpoint .. OccurrencesMessage

                                CheckpointsScroll.CanvasPosition = Vector2.new(0, CheckpointsScroll.AbsoluteCanvasSize.Y)
                            end
                        end
                    end)
                end

                function Checkpoints:clear()
                    for _, Child in ipairs(CheckpointsScroll:GetChildren()) do
                        if Child:IsA("TextLabel") then
                            Child:Destroy()
                        end
                    end

                    Checkpoints.lastCheckpoint = ""
                    Checkpoints.lastLabel = nil
                    Checkpoints.Occurrences = 1
                end

                return Checkpoints
            end

            function Section:addLabel(...)
                -- $$$$$ Metadata
                local Label, Meta = {}, {
                    title = 'Label';
                    xAlignment = Enum.TextXAlignment.Left,
                }

                Meta = TableOverwrite(Meta, ... or {})

                -- $$$$$ Instances
                local ButtonFrame = AddInstance("TextButton", { Parent = SectionFrame, AutoButtonColor = false, Name = [[ButtonFrame]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(39, 39, 39), TextSize = 14, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), TextTransparency = 1, Font = Enum.Font.SourceSans, TextColor3 = Color3.fromRGB(0, 0, 0),})
                local UICorner = AddInstance("UICorner", { Parent = ButtonFrame, CornerRadius = UDim.new(0, 4),})
                local UIPadding = AddInstance("UIPadding", { Parent = ButtonFrame, PaddingRight = UDim.new(0, 3), PaddingLeft = UDim.new(0, 10),})
                local UIStroke = AddInstance("UIStroke", { Parent = ButtonFrame, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 2, Color = Color3.fromRGB(68, 68, 68),})
                local ButtonLabel = AddInstance("TextBox", { Parent = ButtonFrame, Name = [[ButtonLabel]], RichText = true, TextEditable = false, ClearTextOnFocus = false, TextWrapped = true, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 16, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Meta.xAlignment, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.title, Font = Enum.Font.GothamMedium, Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})

                -- $$$$$ Functions + Connections
                local function ResizeBox(IsFocused)
                    task.wait()
                    local TextHeight = IsFocused and ButtonLabel.TextBounds.X - Label.OriginalXBounds or ButtonLabel.TextBounds.Y
                    ButtonFrame.Size = UDim2.new(1, 0, 0, TextHeight + (IsFocused and 30 or 10))
                    Label.OriginalXBounds = ButtonLabel.TextBounds.X
                end

                ButtonLabel.Focused:Connect(function() ButtonLabel.TextScaled = true end)
                ButtonLabel.FocusLost:Connect(function() ButtonLabel.TextScaled = false end)

                function Label:updateText(NewText)
                    Label.OriginalXBounds = ButtonLabel.TextBounds.X
                    ButtonLabel.Text = NewText
                    ResizeBox()
                end

                task.defer(function()
                    task.wait()
                    Label:updateText(Meta.title)
                end)

                return Label
            end

            function Section:addButton(...)
                -- $$$$$ Metadata
                local Button, Meta = {}, {
                    title = 'Button';
                    callback = function()
                        print('Button does not have a callback binded.')
                    end,
                }

                Meta = TableOverwrite(Meta, ... or {})

                -- $$$$$ Instances
                local ButtonFrame = AddInstance("TextButton", { Parent = SectionFrame, AutoButtonColor = false, Name = [[ButtonFrame]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(39, 39, 39), TextSize = 14, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), TextTransparency = 1, Font = Enum.Font.SourceSans, TextColor3 = Color3.fromRGB(0, 0, 0),})
                local UICorner = AddInstance("UICorner", { Parent = ButtonFrame, CornerRadius = UDim.new(0, 4),})
                local UIPadding = AddInstance("UIPadding", { Parent = ButtonFrame, PaddingRight = UDim.new(0, 3), PaddingLeft = UDim.new(0, 10),})
                local UIStroke = AddInstance("UIStroke", { Parent = ButtonFrame, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 2, Color = Color3.fromRGB(68, 68, 68),})
                local ButtonLabel = AddInstance("TextLabel", { Parent = ButtonFrame, Name = [[ButtonLabel]], TextWrapped = true, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 16, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Center, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.title, Font = Enum.Font.GothamMedium, Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})

                -- $$$$$ Functions + Connections
                ButtonFrame.MouseButton1Down:Connect(function()
                    TweenService:Create(
                        ButtonFrame,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut),
                        { Size = UDim2.new(1, -4, 0, 28), BackgroundColor3 = Color3.fromRGB(49,49,49) }
                    ):Play()
                end)

                ButtonFrame.MouseButton1Up:Connect(function()
                    TweenService:Create(
                        ButtonFrame,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut),
                        { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(39,39,39) }
                    ):Play()
                end)

                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(
                        ButtonFrame,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut),
                        { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(39,39,39) }
                    ):Play()
                end)

                ButtonFrame.MouseButton1Click:Connect(Meta.callback)
            end

            function Section:addKeybind(...)
                -- $$$$$ Metadata
                local Keybind, Meta = { Type = 'Keyboard', Key = nil; Pressed = false; }, {
                    title = 'Keybind';
                    default = nil;
                    mode = 'click';
                    blacklist = {},
                    on_update = function()
                        --print('Keybind does not have the "on_update" connection binded.')
                    end,
                    on_press = function()
                        print('Keybind does not have the "on_press" connection binded.')
                    end,
                    on_release = function()
                        print('Keybind does not have the "on_release" connection binded.')
                    end,
                }

                Meta = TableOverwrite(Meta, ... or {})
                if Meta.default then
                    Keybind.Key = Meta.default
                    if Meta.default.EnumType == Enum.UserInputType then
                        Keybind.Type = "MouseInput"
                    end
                end

                -- $$$$$ Instances
                local KeybindFrame = AddInstance("Frame", { Parent = SectionFrame, Name = [[KeybindFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(39, 39, 39),})
                local KeybindLabel = AddInstance("TextLabel", { Parent = KeybindFrame, Name = [[KeybindLabel]], TextWrapped = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 16, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.title, Font = Enum.Font.GothamMedium, Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
                local KeybindBox = AddInstance("ImageLabel", { Parent = KeybindFrame, Name = [[InputBox]], AnchorPoint = Vector2.new(1, 0.5), Image = [[rbxassetid://114222904430574]], Selectable = true, BorderSizePixel = 0, Size = UDim2.new(0, 24, 0, 24), ScaleType = Enum.ScaleType.Fit, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                --local KeybindButton = AddInstance("TextButton", { Parent = KeybindBox, Name = [[Hitbox]], TextScaled = true; Text = `{Meta.default or '...'}`; BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Size = UDim2.new(1, 0, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
                local KeybindButton = AddInstance("TextButton", { Parent = KeybindFrame, Name = [[KeybindButton]], AutoButtonColor = false; TextWrapped = false, BorderSizePixel = 0, Text = `{Meta.default and Meta.default.Name or '...'}`; TextScaled = false, BackgroundColor3 = Color3.fromRGB(30, 30, 30), AnchorPoint = Vector2.new(1, 0.5), TextSize = 14, Size = UDim2.new(0, 22, 0, 22), BorderColor3 = Color3.fromRGB(0, 0, 0), FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255),})
                local UICorner = AddInstance("UICorner", { Parent = KeybindButton, CornerRadius = UDim.new(0, 4),})
                local UIStroke = AddInstance("UIStroke", { Parent = KeybindButton, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1.7999999523162842, Color = Color3.fromRGB(53, 53, 53),})
                AddInstance("UIPadding", { Parent = KeybindFrame, PaddingRight = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10),})
                AddInstance("UICorner", { Parent = KeybindFrame, CornerRadius = UDim.new(0, 4),})
                AddInstance("UIStroke", { Parent = KeybindFrame, Thickness = 2, Color = Color3.fromRGB(68, 68, 68),})

                -- $$$$$ Functions + Connections
                local function ResizeBox()
                    if KeybindButton.TextBounds.X > 22 then
                        KeybindButton.Size = UDim2.new(0, KeybindButton.TextBounds.X + 7, 0, 22)
                    end

                    if KeybindButton.TextBounds.X < 22 then
                        KeybindButton.Size = UDim2.new(0, 22, 0, 22)
                    end
                end
                task.delay(1, ResizeBox)

                local Blacklist = {
                    Enum.KeyCode.RightSuper,
                    Enum.KeyCode.LeftSuper,
                    Enum.KeyCode.BackSlash,
                    Enum.KeyCode.Backspace,
                    Enum.KeyCode.Unknown,
                    Enum.KeyCode.Return,
                    Enum.KeyCode.Escape,
                }

                for _, Key in pairs(Meta.blacklist) do
                    table.insert(Blacklist, Key)
                end

                KeybindButton.MouseButton1Down:Connect(function()
                    TweenService:Create(
                        KeybindBox,
                        Tween_Info.new(.25, Easing_Style.Quint, Easing_Direction.InOut),
                        { Size = UDim2.new(0,20,0,20) }
                    ):Play()
                end)

                KeybindButton.MouseButton1Up:Connect(function()
                    TweenService:Create(
                        KeybindBox,
                        Tween_Info.new(.25, Easing_Style.Quint, Easing_Direction.InOut),
                        { Size = UDim2.new(0,24,0,24) }
                    ):Play()
                end)

                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Editing = true
                    KeybindButton.Text = '...'
                    KeybindButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                end)

                InputService.InputBegan:Connect(function(Input)
                    if game:GetService('UserInputService'):GetFocusedTextBox() then
                        return
                    end

                    if Keybind.Editing then
                        KeybindButton.TextColor3 = Color3.new(0.784, 0.784, 0.784)

                        if Input.UserInputType == Enum.UserInputType.Keyboard then
                            if table.find(Blacklist, Input.KeyCode) then
                                Keybind.Key = nil
                                KeybindButton.Text = '...'
                                Keybind.Editing = false
                                return
                            end

                            Keybind.Type = 'Keyboard'
                            Keybind.Key = Input.KeyCode
                            KeybindButton.Text = Input.KeyCode.Name
                            Meta.on_update(Keybind.Key)

                            ResizeBox()

                            Keybind.Editing = false
                        elseif Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            if table.find(Blacklist, Input.UserInputType) then
                                Keybind.Key = nil
                                KeybindButton.Text = '...'
                                Keybind.Editing = false
                                return
                            end

                            Keybind.Key = Input.UserInputType
                            Keybind.Type = 'MouseInput'
                            KeybindButton.Text = Input.UserInputType.Name
                            Meta.on_update(Keybind.Key)

                            ResizeBox()

                            Keybind.Editing = false
                        end

                        return
                    end

                    if Keybind.Key == nil then return end

                    if (Keybind.Type == 'Keyboard' and Input.KeyCode == Keybind.Key) or (Keybind.Type == 'MouseInput' and Input.UserInputType == Keybind.Key) then
                        if Meta.mode == 'hold' then
                            Keybind.Pressed = true
                            Meta.on_press(Keybind.Key)
                            --while Keybind.Pressed do task.wait()
                            --end
                        elseif Meta.mode == 'toggle' then
                            Keybind.Pressed = not Keybind.Pressed
                            Meta.on_press(Keybind.Pressed)
                        elseif Meta.mode == 'click' then
                            Meta.on_press(Keybind.Key)
                        end
                    end
                end)

                InputService.InputEnded:Connect(function(Input)
                    if game:GetService('UserInputService'):GetFocusedTextBox() then
                        return
                    end

                    if Keybind.Key == nil then return end

                    if (Keybind.Type == 'Keyboard' and Input.KeyCode == Keybind.Key) or (Keybind.Type == 'MouseInput' and Input.UserInputType == Keybind.Key) then
                        if Meta.mode == 'hold' then
                            Keybind.Pressed = false
                            Meta.on_release(Keybind.Key)
                        end
                    end
                end)

                if Meta.default then
                    task.spawn(Meta.on_update, Meta.default)
                end

                return Keybind
            end

            function Section:addSlider(...)
                -- $$$$$ Metadata
                local Slider, Meta = { Value = 0; }, {
                    title = 'Slider';
                    default = 0;
                    min = 0;
                    max = 100;
                    prefix = '';
                    suffix = '';
                    decimals = false;
                    callback = function()
                        print('Slider does not have a callback binded.')
                    end,
                }

                Meta = TableOverwrite(Meta, ... or {})
                if Meta.default < Meta.min then Meta.default = Meta.min end

                -- $$$$$ Instances
                local SliderFrame = AddInstance("Frame", { Parent = SectionFrame, Name = [[SliderFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(39, 39, 39),})
                local SliderLabel = AddInstance("TextLabel", { Parent = SliderFrame, Name = [[SliderLabel]], TextWrapped = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 16, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.title, Font = Enum.Font.GothamMedium, Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
                local SliderBar = AddInstance("ImageButton", { Parent = SliderFrame, Name = [[SliderBar]], AnchorPoint = Vector2.new(1, 0.5), Image = [[rbxassetid://117462785670806]], BorderSizePixel = 0, Size = UDim2.new(0.5, -20, 0, 24), ScaleType = Enum.ScaleType.Fit, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -3, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                local SliderFill = AddInstance("ImageLabel", { Parent = SliderBar, Name = [[SliderFill]], AnchorPoint = Vector2.new(0, 0.5), Image = [[rbxassetid://81914770912624]], BorderSizePixel = 0, Size = UDim2.new((Meta.default - Meta.min) / (Meta.max - Meta.min), 0, 1, 0), ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(12, 21, 268, 21), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                local SliderValueLabel = AddInstance("TextLabel", { Parent = SliderBar, Name = [[SliderValueLabel]], TextWrapped = false, ZIndex = 2, BorderSizePixel = 0, TextScaled = true, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 14, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = `{Meta.prefix}{Meta.default}{Meta.suffix}`; FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.5, 0), TextColor3 = Color3.fromRGB(170, 170, 170), BackgroundTransparency = 1,})
                AddInstance("UIPadding", { Parent = SliderValueLabel, PaddingTop = UDim.new(0, 6), PaddingRight = UDim.new(0, 9), PaddingLeft = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6),})
                AddInstance("UICorner", { Parent = SliderBar, CornerRadius = UDim.new(0.195121944, 0),})
                AddInstance("UICorner", { Parent = SliderFrame, CornerRadius = UDim.new(0, 4),})
                AddInstance("UIStroke", { Parent = SliderFrame, Thickness = 2, Color = Color3.fromRGB(68, 68, 68),})
                AddInstance("UIPadding", { Parent = SliderFrame, PaddingLeft = UDim.new(0, 10),})

                -- $$$$$ Functions + Connections
                local Player = Services.Players.LocalPlayer
                local Mouse = Player:GetMouse()

                local Min = Meta.min
                local Max = Meta.max
                local Mouse_Down = false
                local Mouse_On = false

                Slider.Value = Meta.default
                SliderFill.Size = UDim2.new((Slider.Value - Min) / (Max - Min), 0, 1, 0)
                --SliderValueLabel.Text = tostring(Slider.Value):sub(1,4)

                local function Update_Value()
                    local Bar_Size_X = SliderBar.AbsoluteSize.X
                    local Mouse_X = math.clamp(Mouse.X - SliderBar.AbsolutePosition.X, 0, Bar_Size_X)

                    local New_Value = ((Mouse_X / Bar_Size_X) * (Max - Min)) + Min

                    if Meta.decimals then
                        Slider.Value = New_Value
                        SliderValueLabel.Text = string.format("%s%.2f%s", Meta.prefix, Slider.Value, Meta.suffix)
                    else
                        Slider.Value = math.floor(New_Value)
                        SliderValueLabel.Text = `{Meta.prefix}{tostring(Slider.Value)}{Meta.suffix}`
                    end

                    local Fill_Fraction = (Slider.Value - Min) / (Max - Min)
                    TweenService:Create(
                        SliderFill,
                        Tween_Info.new(0.1),
                        { Size = UDim2.new(Fill_Fraction, 0, 1, 0) }
                    ):Play()

                    Meta.callback(Slider.Value)
                end

                Mouse.Move:Connect(function() if Mouse_Down then Update_Value() end end)
                SliderBar.MouseButton1Down:Connect(function() Mouse_Down = true Update_Value() end)
                SliderBar.MouseButton1Up:Connect(function() Mouse_Down = false end)
                SliderBar.MouseEnter:Connect(function() Mouse_On = true end)
                SliderBar.MouseLeave:Connect(function() Mouse_On = false end)

                InputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Mouse_Down = false
                    end
                end)

                if Meta.default then
                    task.spawn(Meta.callback, Meta.default)
                end

                return Slider
            end

            function Section:addTextbox(...)
                -- $$$$$ Metadata
                local Textbox, Meta = { Value = nil }, {
                    title = 'Textbox';
                    default = nil;
                    callback = function()
                        print('Textbox does not have a callback binded.')
                    end,
                }

                Meta = TableOverwrite(Meta, ... or {})

                -- $$$$$ Instances
                local TextboxFrame = AddInstance("Frame", { Parent = SectionFrame, Name = [[TextboxFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(39, 39, 39),})
                local TextboxLabel = AddInstance("TextLabel", { Parent = TextboxFrame, Name = [[TextboxLabel]], TextWrapped = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 16, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.title, Font = Enum.Font.GothamMedium, Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
                local InputBox = AddInstance("ImageLabel", { Parent = TextboxFrame, Name = [[InputBox]], AnchorPoint = Vector2.new(1, 0.5), Image = [[rbxassetid://130232878751373]], BorderSizePixel = 0, Size = UDim2.new(0, 80, 0, 24), ScaleType = Enum.ScaleType.Fit, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                local TextInputBox = AddInstance("TextBox", { Parent = InputBox, CursorPosition = -1, PlaceholderColor3 = Color3.fromRGB(125, 125, 125), BorderSizePixel = 0, TextScaled = true, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextWrapped = true, Text = Meta.default or ''; PlaceholderText = [[...]], TextSize = 14, Size = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(178, 178, 178), BorderColor3 = Color3.fromRGB(0, 0, 0), FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1,})
                AddInstance("UIPadding", { Parent = TextboxFrame, PaddingRight = UDim.new(0, 3), PaddingLeft = UDim.new(0, 10),})
                AddInstance("UIPadding", { Parent = TextInputBox, PaddingRight = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5),})
                AddInstance("UICorner", { Parent = TextboxFrame, CornerRadius = UDim.new(0, 4),})
                AddInstance("UIStroke", { Parent = TextboxFrame, Thickness = 2, Color = Color3.fromRGB(68, 68, 68),})

                -- $$$$$ Functions + Connections
                TextInputBox.FocusLost:Connect(function()
                    Textbox.Value = TextInputBox.Text
                    Meta.callback(Textbox.Value)
                end)

                if Meta.default then
                    task.spawn(Meta.callback, Meta.default)
                end

                return Textbox
            end

            function Section:addDropdown(...)
                -- $$$$$ Metadata
                local Dropdown, Meta = { Selection = {}, Buttons = {}; Dropped = false }, {
                    title = 'Dropdown';
                    default = nil;
                    mode = 'single';
                    list = {};
                    callback = function()
                        print('Dropdown does not have a callback binded.')
                    end,
                }

                Meta = TableOverwrite(Meta, ... or {})

                -- $$$$$ Instances
                local DropdownFrame = AddInstance("Frame", { Parent = SectionFrame, AutomaticSize = Enum.AutomaticSize.Y, Name = [[DropdownFrame]], Active = true, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(39, 39, 39),})
                local OptionFrame = AddInstance("Frame", { Parent = DropdownFrame, AutomaticSize = Enum.AutomaticSize.Y, Name = [[OptionFrame]]; BorderSizePixel = 0, ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), LayoutOrder = 1, Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                local TopbarFrame = AddInstance("Frame", { Parent = DropdownFrame, Name = [[TopbarFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                local DropdownButton = AddInstance("ImageButton", { Parent = TopbarFrame, Name = [[DropdownButton]], BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Image = [[rbxassetid://76471184936187]], BorderSizePixel = 0, Size = UDim2.new(0, 8, 0, 8), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0, 11), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                local DropdownLabel = AddInstance("TextBox", { Parent = TopbarFrame, PlaceholderText = Meta.title, PlaceholderColor3 = Color3.fromRGB(255,255,255), ZIndex = 100, Active = true, Selectable = true, Name = [[DropdownLabel]], TextWrapped = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 16, Size = UDim2.new(0.5, 0, 0, 30), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.title, Font = Enum.Font.GothamMedium, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
                local DropdownHitbox = AddInstance("TextButton", { Parent = TopbarFrame, ZIndex = 99, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 14, Size = UDim2.new(1, 0, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), TextTransparency = 1, Font = Enum.Font.SourceSans, Position = UDim2.new(0.5, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1,})
                AddInstance("UIListLayout", { Parent = OptionFrame, Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder,})
                AddInstance("UIListLayout", { Parent = DropdownFrame, SortOrder = Enum.SortOrder.LayoutOrder,})
                AddInstance("UICorner", { Parent = DropdownFrame, CornerRadius = UDim.new(0, 4),})
                AddInstance("UIStroke", { Parent = DropdownFrame, Thickness = 2, Color = Color3.fromRGB(68, 68, 68),})
                AddInstance("UIPadding", { Parent = DropdownFrame, PaddingRight = UDim.new(0, 11), PaddingLeft = UDim.new(0, 10),})

                -- $$$$$ Populate Dropdown
                local function CreateOption(Option)
                    local OptionButton = AddInstance("TextButton", { Parent = OptionFrame, Name = [[OptionButton]], TextYAlignment = Enum.TextYAlignment.Top; TextWrapped = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, TextTransparency = 1, Size = UDim2.new(1, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Option, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(164, 164, 164), BackgroundTransparency = 1,})
                    table.insert(Dropdown.Buttons, OptionButton)

                    if OptionButton.Text == Meta.default then
                        OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                        OptionButton.FontFace = Font.new(
                            'rbxasset://fonts/families/GothamSSm.json',
                            Enum.FontWeight.SemiBold,
                            Enum.FontStyle.Normal
                        )
                    end

                    OptionButton.MouseButton1Click:Connect(function()
                        if Meta.mode == 'single' then
                            for _, Button in OptionFrame:GetChildren() do
                                if Button:IsA('TextButton') then
                                    Button.TextColor3 = Color3.fromRGB(164,164,164)
                                    Button.FontFace = Font.new(
                                        'rbxasset://fonts/families/GothamSSm.json',
                                        Enum.FontWeight.Regular,
                                        Enum.FontStyle.Normal
                                    )
                                end
                            end

                            OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                            OptionButton.FontFace = Font.new(
                                'rbxasset://fonts/families/GothamSSm.json',
                                Enum.FontWeight.SemiBold,
                                Enum.FontStyle.Normal
                            )

                            Meta.callback(Option)
                        elseif Meta.mode == 'multi' then
                            if OptionButton:GetAttribute('Selected') == nil then
                                OptionButton:SetAttribute('Selected', false)
                            end

                            OptionButton:SetAttribute('Selected', not OptionButton:GetAttribute('Selected'))

                            if OptionButton:GetAttribute('Selected') then
                                OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                                OptionButton.FontFace = Font.new(
                                    'rbxasset://fonts/families/GothamSSm.json',
                                    Enum.FontWeight.SemiBold,
                                    Enum.FontStyle.Normal
                                )

                                table.insert(Dropdown.Selection, Option)
                                Meta.callback(Dropdown.Selection)
                            elseif not OptionButton:GetAttribute('Selected') then
                                OptionButton.TextColor3 = Color3.fromRGB(164, 164, 164)
                                OptionButton.FontFace = Font.new(
                                    'rbxasset://fonts/families/GothamSSm.json',
                                    Enum.FontWeight.Regular,
                                    Enum.FontStyle.Normal
                                )

                                for i, __ in Dropdown.Selection do
                                    if __ == Option then
                                        table.remove(Dropdown.Selection, i)
                                        break
                                    end
                                end

                                Meta.callback(Dropdown.Selection)
                            end

                            if #Dropdown.Selection > 0 then
                                DropdownLabel.Text = `{Meta.title} ({#Dropdown.Selection})`
                            elseif #Dropdown.Selection <= 0 then
                                DropdownLabel.Text = Meta.title
                            end
                        end
                    end)
                end

                -- $$$$$ Functions + Connections
                DropdownLabel.FocusLost:Connect(function()
                    --DropdownLabel.Text = Meta.title

                    --task.wait()
                    --for _, Option in OptionFrame:GetChildren() do
                    --    if Option:IsA('TextButton') then
                    --        Option.Visible = true
                    --    end
                    --end
                end)

                local function Animate(InstantAnimation)
                    if InstantAnimation then
                        DropdownButton.Rotation = Dropdown.Dropped and 0 or 90
                        for _, Button in OptionFrame:GetChildren() do
                            if Button:IsA('TextButton') then
                                Button.Size = UDim2.new(1, 0, 0, Dropdown.Dropped and 20 or 0)
                                Button.TextTransparency = Dropdown.Dropped and 0 or 1
                            end
                        end
                    else
                        TweenService:Create(
                            DropdownButton,
                            Tween_Info.new(.2, Easing_Style.Quad, Easing_Direction.InOut),
                            { Rotation = Dropdown.Dropped and 0 or 90 }
                        ):Play()

                        for _, Button in OptionFrame:GetChildren() do
                            if Button:IsA('TextButton') then
                                TweenService:Create(
                                    Button,
                                    Tween_Info.new(.2, Easing_Style.Quad), {
                                        Size = UDim2.new(1, 0, 0, Dropdown.Dropped and 20 or 0),
                                        TextTransparency = Dropdown.Dropped and 0 or 1
                                    }
                                ):Play()
                            end
                        end
                    end
                end

                function Dropdown:updateList(NewList, InstantAnimation)
                    Meta.list = NewList
                    for _, OptionButton in pairs(Dropdown.Buttons) do
                        OptionButton:Destroy()
                    end

                    for _, Option in ipairs(NewList) do
                        CreateOption(Option)
                    end

                    Animate(InstantAnimation)
                end

                Dropdown:updateList(Meta.list)

                DropdownHitbox.MouseButton1Click:Connect(function()
                    Dropdown.Dropped = not Dropdown.Dropped
                    Animate()
                end)

                DropdownLabel.Changed:Connect(function()
                    if DropdownLabel.Text == Meta.Title then return end

                    for _, Option in OptionFrame:GetChildren() do
                        if Option:IsA('TextButton') and DropdownLabel.Text ~= Meta.title and Dropdown.Dropped then
                            Option.Visible = false

                            if Option.Text:lower():match(DropdownLabel.Text:lower()) then
                                Option.Visible = true
                            end
                        end
                    end
                end)

                if Meta.default then
                    task.spawn(function()
                        Meta.callback(Meta.mode == "single" and Meta.default or { Meta.default })
                    end)
                end

                return Dropdown
            end

            function Section:addToggle(...)
                -- $$$$$ Metadata
                local Toggle, Meta = { Value = false }, {
                    title = 'Toggle';
                    toggled = false;
                    callback = function()
                        print('Toggle does not have a callback binded.')
                    end;
                }

                Meta = TableOverwrite(Meta, ... or {})

                -- $$$$$ Instances
                local ToggleFrame = AddInstance("Frame", { Parent = SectionFrame, Name = [[ToggleFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(39, 39, 39),})
                local ToggleLabel = AddInstance("TextLabel", { Parent = ToggleFrame, Name = [[ToggleLabel]], TextWrapped = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 16, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.title, Font = Enum.Font.GothamMedium, Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
                local ToggleButton = AddInstance("ImageButton", { Parent = ToggleFrame, Name = [[ToggleButton]], BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(1, 0.5), Image = [[rbxassetid://123317618042392]], BorderSizePixel = 0, Size = UDim2.new(0, 40, 0, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 5, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                local ToggleHitbox = AddInstance("TextButton", { Parent = ToggleFrame, ZIndex = 99, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 14, Size = UDim2.new(1, 0, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), TextTransparency = 1, Font = Enum.Font.SourceSans, Position = UDim2.new(0.5, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1,})
                local ToggleCircle = AddInstance("ImageLabel", { Parent = ToggleButton, Name = [[On]], AnchorPoint = Vector2.new(0, 0.5), Image = [[rbxassetid://112376976170886]], BorderSizePixel = 0, Size = UDim2.new(0.388059705, 0, 0.81250006, 0), ScaleType = Enum.ScaleType.Fit, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
                AddInstance("UICorner", { Parent = ToggleFrame, CornerRadius = UDim.new(0, 4),})
                AddInstance("UIStroke", { Parent = ToggleFrame, Thickness = 2, Color = Color3.fromRGB(68, 68, 68),})
                AddInstance("UIPadding", { Parent = ToggleButton, PaddingRight = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3),})
                AddInstance("UIPadding", { Parent = ToggleFrame, PaddingRight = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),})

                -- $$$$$ Functions + Connections
                if Meta.toggled then
                    Toggle.Value = true
                    task.spawn(Meta.callback, Toggle.Value)

                    TweenService:Create(
                        ToggleCircle,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut), {
                            Position = Toggle.Value and UDim2.new(1,0,0.5,0) or UDim2.new(0,0,0.5,0);
                            AnchorPoint = Toggle.Value and Vector2.new(1,0.5) or Vector2.new(0,0.5);
                        }
                    ):Play()
                end

                ToggleHitbox.MouseButton1Down:Connect(function()
                    TweenService:Create(
                        ToggleFrame,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut),
                        { Size = UDim2.new(1, -4, 0, 28), BackgroundColor3 = Color3.fromRGB(49,49,49) }
                    ):Play()
                end)

                ToggleHitbox.MouseButton1Up:Connect(function()
                    TweenService:Create(
                        ToggleFrame,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut),
                        { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(39,39,39) }
                    ):Play()
                end)

                ToggleHitbox.MouseLeave:Connect(function()
                    TweenService:Create(
                        ToggleFrame,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut),
                        { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(39,39,39) }
                    ):Play()
                end)

                ToggleHitbox.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value

                    TweenService:Create(
                        ToggleCircle,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut), {
                            Position = Toggle.Value and UDim2.new(1,0,0.5,0) or UDim2.new(0,0,0.5,0);
                            AnchorPoint = Toggle.Value and Vector2.new(1,0.5) or Vector2.new(0,0.5);
                        }
                    ):Play()

                    Meta.callback(Toggle.Value)
                end)

                function Toggle:update(NewMeta)
                    Meta = TableOverwrite(Meta, NewMeta or {})
                    ToggleLabel.Text = Meta.title
                    Toggle.Value = Meta.toggled

                    TweenService:Create(
                        ToggleCircle,
                        Tween_Info.new(.1, Easing_Style.Quad, Easing_Direction.InOut), {
                            Position = Toggle.Value and UDim2.new(1,0,0.5,0) or UDim2.new(0,0,0.5,0);
                            AnchorPoint = Toggle.Value and Vector2.new(1,0.5) or Vector2.new(0,0.5);
                        }
                    ):Play()

                    Meta.callback(Toggle.Value)
                end

                return Toggle
            end

            return Section
        end

        return Page
    end

    return Window
end

return Vigil
