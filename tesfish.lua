if not game:IsLoaded() then game.Loaded:Wait() end

-- Vanis UI (compact + dropdown + overlay toggle)
-- extra credits to twink marie / original author
local library = {}
local request = request or http_request or (identifyexecutor() == "Synapse X" and syn.request) or (http and http.request)
loadstring(request({Url="https://raw.githubusercontent.com/cypherdh/Script-Library/main/InstanceProtect",Method="GET"}).Body)()

local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")

-- ========= global (compact scaling) =========
local DEFAULT_SCALE = 0.82    -- <== diperkecil; ubah via library.SetScale(x)

-- ========= helpers =========
local function tween(o, ti, props) TS:Create(o, ti, props):Play() end
local function rndName()
    local s="" for i=1,math.random(3,20) do s=s..string.char(math.random(97,122)) end
    return s
end

function library:SetScale(s)
    s = math.clamp(tonumber(s) or DEFAULT_SCALE, 0.65, 1.0)
    if self.__uiscale then self.__uiscale.Scale = s end
end

function library:CreateWindow(name, version, icon)
    name    = name or "Name"
    version = version or "Version"
    icon    = icon or 10044538000

    -- roots
    local MyGui   = Instance.new("ScreenGui")
    local Window  = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local TitleBar = Instance.new("Frame")
    local Icon    = Instance.new("ImageLabel")
    local MainTitle = Instance.new("TextLabel")
    local TitleUnderline = Instance.new("Frame")
    local UIGradient = Instance.new("UIGradient")
    local Bar = Instance.new("Frame")
    local Bar_2 = Instance.new("Frame")
    local Close = Instance.new("ImageButton")
    local Minimize = Instance.new("ImageButton")
    local Shadow = Instance.new("ImageLabel")
    local UIScale = Instance.new("UIScale")

    local RandomString = rndName()
    ProtectInstance(MyGui); ProtectInstance(Window)

    MyGui.Name = RandomString
    MyGui.Parent = cloneref(game:GetService("CoreGui"))
    MyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- scale (compact)
    UIScale.Parent = MyGui
    UIScale.Scale  = DEFAULT_SCALE
    library.__uiscale = UIScale

    -- window (lebih kecil)
    Window.Name = "Window"
    Window.Parent = MyGui
    Window.BackgroundColor3 = Color3.fromRGB(49, 49, 59)
    Window.Position = UDim2.new(0.5, -230, 0.56, -160)
    Window.Size = UDim2.new(0, 0, 0, 0)
    Window.ClipsDescendants = true

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Window

    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Window
    TitleBar.BackgroundTransparency = 1
    TitleBar.Size = UDim2.new(1, 0, 0, 28)

    Icon.Name = "Icon"
    Icon.Parent = TitleBar
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 6, 0, 5)
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Image = "rbxassetid://"..icon
    Icon.ImageColor3 = Color3.fromRGB(135, 255, 135)

    MainTitle.Name = "Title"
    MainTitle.Parent = TitleBar
    MainTitle.BackgroundTransparency = 1
    MainTitle.Position = UDim2.new(0, 30, 0, 0)
    MainTitle.Size = UDim2.new(1, -30, 1, 0)
    MainTitle.Font = Enum.Font.Gotham
    MainTitle.Text = name.." | "..version
    MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTitle.TextSize = 11
    MainTitle.TextXAlignment = Enum.TextXAlignment.Left

    TitleUnderline.Parent = TitleBar
    TitleUnderline.BackgroundColor3 = Color3.fromRGB(135, 255, 135)
    TitleUnderline.BorderSizePixel = 0
    TitleUnderline.Position = UDim2.new(0, 0, 1, 0)
    TitleUnderline.Size = UDim2.new(1, 0, 0, 1)
    UIGradient.Parent = TitleUnderline

    Bar.Name = "Bar";   Bar.Parent   = TitleUnderline
    Bar.BackgroundColor3 = Color3.fromRGB(0,0,0); Bar.BackgroundTransparency = 0.75
    Bar.BorderSizePixel = 0; Bar.Position = UDim2.new(0,6,0,0); Bar.Size = UDim2.new(0,18,1,0)

    Bar_2.Name = "Bar"; Bar_2.Parent = TitleUnderline
    Bar_2.BackgroundColor3 = Color3.fromRGB(0,0,0); Bar_2.BackgroundTransparency = 0.75
    Bar_2.BorderSizePixel = 0; Bar_2.Position = UDim2.new(1,-24,0,0); Bar_2.Size = UDim2.new(0,18,1,0)

    Close.Name = "Close"
    Close.Parent = TitleBar
    Close.BackgroundTransparency = 1
    Close.Position = UDim2.new(1, -26, 0, 2)
    Close.Size = UDim2.new(0, 22, 0, 22)
    Close.Image = "rbxassetid://3926305904"
    Close.ImageRectOffset = Vector2.new(284, 4)
    Close.ImageRectSize   = Vector2.new(24, 24)

    Minimize.Name = "Minimize"
    Minimize.Parent = TitleBar
    Minimize.BackgroundTransparency = 1
    Minimize.Position = UDim2.new(1, -50, 0, 2)
    Minimize.Size = UDim2.new(0, 22, 0, 22)
    Minimize.Image = "rbxassetid://6035067836"

    Shadow.Name = "Shadow"
    Shadow.Parent = Window
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Image = "rbxassetid://5761504593"
    Shadow.ImageColor3 = Color3.fromRGB(49, 49, 59)
    Shadow.ImageTransparency = 0.3
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(17,17,283,283)

    -- open tween (lebih kecil: 460x320)
    tween(Window, TweenInfo.new(0.45), {Size = UDim2.new(0, 460, 0, 0)})
    repeat task.wait() until Window.Size.Y.Offset == 0
    tween(Window, TweenInfo.new(0.45), {Size = UDim2.new(0, 460, 0, 320)})

    -- close / minimize
    Close.MouseButton1Click:Connect(function()
        tween(Window, TweenInfo.new(0.35), {Size = UDim2.new(0, 460, 0, 0)})
        task.delay(0.36, function() MyGui:Destroy() end)
    end)

    local MinimizeGui=false
    Minimize.MouseButton1Click:Connect(function()
        MinimizeGui = not MinimizeGui
        if MinimizeGui then
            tween(Window, TweenInfo.new(0.25), {Size = UDim2.new(0,460,0,30)})
            if library.__activePage then library.__activePage.Visible=false end
            if library.__tabs then library.__tabs.Visible=false end
        else
            tween(Window, TweenInfo.new(0.25), {Size = UDim2.new(0,460,0,320)})
            if library.__activePage then library.__activePage.Visible=true end
            if library.__tabs then library.__tabs.Visible=true end
        end
    end)

    -- drag
    local function dragify(Frame)
        local dragging, dragStart, startPos
        local function update(i)
            local d = i.Position - dragStart
            local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            tween(Frame, TweenInfo.new(0.2), {Position = pos})
        end
        Frame.InputBegan:Connect(function(input)
            if (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) and not UIS:GetFocusedTextBox() then
                dragging=true; dragStart=input.Position; startPos=Frame.Position
                input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i) end
        end)
    end
    dragify(Window)

    -- ========= OVERLAY TOGGLE (ikon Vanis, draggable) =========
    local TO = Instance.new("ScreenGui"); ProtectInstance(TO)
    TO.Name="VanisOverlayToggle"; TO.IgnoreGuiInset=true; TO.ResetOnSpawn=false; TO.Parent = MyGui
    local Toggle = Instance.new("ImageButton")
    Toggle.Parent = TO; Toggle.AutoButtonColor=true
    Toggle.Size = UDim2.fromOffset(36,36)
    Toggle.Position = UDim2.new(0, 14, 0.5, -18)
    Toggle.BackgroundColor3 = Color3.fromRGB(30,30,36)
    Toggle.Image = "rbxassetid://"..icon
    Toggle.ImageColor3 = Color3.fromRGB(135,255,135)
    local tCorner = Instance.new("UICorner", Toggle); tCorner.CornerRadius = UDim.new(1,0)
    local tStroke = Instance.new("UIStroke", Toggle); tStroke.Thickness=2; tStroke.Color=Color3.fromRGB(90,180,120); tStroke.Transparency=0.2
    -- drag toggle
    do
        local drag, start, origin
        Toggle.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                drag=true; start=i.Position; origin=Toggle.Position
                i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d=i.Position-start
                Toggle.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
            end
        end)
    end
    local visible = true
    Toggle.MouseButton1Click:Connect(function()
        visible = not visible
        Window.Visible = visible
        if library.__tabs then library.__tabs.Visible = visible end
        if library.__activePage then library.__activePage.Visible = visible end
        -- ubah warna saat hidden
        Toggle.ImageColor3 = visible and Color3.fromRGB(135,255,135) or Color3.fromRGB(180,180,180)
        Toggle.BackgroundColor3 = visible and Color3.fromRGB(30,30,36) or Color3.fromRGB(45,45,52)
    end)

    -- ========= Tabs (kiri) =========
    local tabs = {}

    function tabs:CreateTab(title)
        title = title or "Section"
        local Tabs = Instance.new("Frame")
        local UICorner_2 = Instance.new("UICorner")
        local SectionLabel = Instance.new("TextLabel")
        local UIListLayout = Instance.new("UIListLayout")
        local Indicator = Instance.new("Frame")

        Tabs.Name = "Tabs"
        Tabs.Parent = Window
        Tabs.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        Tabs.Position = UDim2.new(0, 5, 0, 32)
        Tabs.Size = UDim2.new(0, 120, 1, -37)
        UICorner_2.CornerRadius = UDim.new(0, 4); UICorner_2.Parent = Tabs

        SectionLabel.Parent = Tabs
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Position = UDim2.new(0,7,0,0)
        SectionLabel.Size = UDim2.new(1,-7,0,26)
        SectionLabel.Font = Enum.Font.GothamBlack
        SectionLabel.Text = title
        SectionLabel.TextColor3 = Color3.fromRGB(255,255,255)
        SectionLabel.TextSize = 11
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Left

        UIListLayout.Parent = Tabs; UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

        Indicator.Parent = Tabs; Indicator.BackgroundColor3 = Color3.fromRGB(135,255,135)
        Indicator.BorderSizePixel=0; Indicator.BackgroundTransparency=1
        Indicator.Position = UDim2.new(0,-12,0,4); Indicator.Size = UDim2.new(0,2,1,-8); Indicator.Visible=false

        library.__tabs = Tabs

        local mytabbuttons = {}

        function mytabbuttons:CreateFrame(name)
            name = name or "Page 1"
            -- Page
            local Page = Instance.new("ScrollingFrame")
            local UICorner_3 = Instance.new("UICorner")
            local UIListLayout_2 = Instance.new("UIListLayout")
            local UIPadding = Instance.new("UIPadding")
            local SearchBar = Instance.new("Frame")
            local UICorner_4 = Instance.new("UICorner")
            local SearchIcon = Instance.new("ImageLabel")
            local Bar_3 = Instance.new("Frame")
            local SearchBox = Instance.new("TextBox")
            local Section = Instance.new("Frame")
            local UICorner_5 = Instance.new("UICorner")
            local SectionContainer = Instance.new("Frame")
            local Header = Instance.new("Frame")
            local UICorner_23 = Instance.new("UICorner")
            local UIGradient_2 = Instance.new("UIGradient")

            Page.Name = "Page"; Page.Parent = Window; Page.Active=true
            Page.BackgroundColor3 = Color3.fromRGB(40,40,48); Page.BorderSizePixel=0
            Page.Position = UDim2.new(0, 130, 0, 32)
            Page.Size = UDim2.new(1, -135, 1, -37)
            Page.ScrollBarThickness = 5
            Page.ScrollBarImageColor3 = Color3.fromRGB(135,255,135)
            Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Page.Visible=false

            UICorner_3.CornerRadius = UDim.new(0,4); UICorner_3.Parent = Page
            UIListLayout_2.Parent = Page; UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout_2.Padding = UDim.new(0,4)

            UIPadding.Parent = Page
            UIPadding.PaddingBottom = UDim.new(0,4); UIPadding.PaddingLeft = UDim.new(0,4)
            UIPadding.PaddingRight = UDim.new(0,4);  UIPadding.PaddingTop = UDim.new(0,4)

            SearchBar.Parent = Page; SearchBar.BackgroundColor3 = Color3.fromRGB(30,30,36)
            SearchBar.Size = UDim2.new(1,0,0,26)
            UICorner_4.CornerRadius = UDim.new(0,4); UICorner_4.Parent = SearchBar

            SearchIcon.Parent = SearchBar; SearchIcon.BackgroundTransparency=1
            SearchIcon.Position = UDim2.new(0,6,0,4); SearchIcon.Size = UDim2.new(0,18,0,18)
            SearchIcon.Image = "rbxassetid://10045418551"; SearchIcon.ImageColor3 = Color3.fromRGB(135,255,135)

            Bar_3.Parent = SearchBar; Bar_3.BackgroundColor3 = Color3.fromRGB(135,255,135)
            Bar_3.Position = UDim2.new(0,30,0,8); Bar_3.Size = UDim2.new(0,1,1,-16)

            SearchBox.Parent = SearchBar; SearchBox.BackgroundTransparency=1
            SearchBox.Position = UDim2.new(0,40,0,0); SearchBox.Size = UDim2.new(1,-40,1,0)
            SearchBox.Font = Enum.Font.Gotham
            SearchBox.PlaceholderColor3 = Color3.fromRGB(227,225,228)
            SearchBox.PlaceholderText = "Search Here"
            SearchBox.Text = ""; SearchBox.TextColor3 = Color3.fromRGB(227,225,228); SearchBox.TextSize=11
            SearchBox.TextXAlignment = Enum.TextXAlignment.Left

            Section.Parent = Page; Section.BackgroundTransparency=1; Section.Size = UDim2.new(1,0,0,110)
            UICorner_5.CornerRadius = UDim.new(0,4); UICorner_5.Parent = Section

            SectionContainer.Name="SectionContainer"; SectionContainer.Parent=Section
            SectionContainer.BackgroundColor3 = Color3.fromRGB(30,30,36); SectionContainer.BorderSizePixel=0
            SectionContainer.ClipsDescendants=true; SectionContainer.Size = UDim2.new(1,0,1, -1); SectionContainer.ZIndex=2

            Header.Parent = Section; Header.BackgroundColor3 = Color3.fromRGB(135,255,135)
            Header.BorderSizePixel=0; Header.Size = UDim2.new(1,0,0,6)
            UICorner_23.CornerRadius = UDim.new(0,4); UICorner_23.Parent=Header
            UIGradient_2.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0,0.75), NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(1,0.75)
            }
            UIGradient_2.Parent = Header

            local pad = Instance.new("UIPadding", SectionContainer)
            pad.PaddingTop=UDim.new(0,4); pad.PaddingBottom=UDim.new(0,4); pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4)
            local list = Instance.new("UIListLayout", SectionContainer)
            list.SortOrder = Enum.SortOrder.LayoutOrder; list.Padding = UDim.new(0,4)
            Instance.new("UICorner", SectionContainer).CornerRadius = UDim.new(0,4)

            local function UpdateResults()
                local search = string.lower(SearchBox.Text)
                for _,v in pairs(SectionContainer:GetChildren()) do
                    if v:IsA("Frame") and v.Name ~= "DropdownList" then
                        if search ~= "" then
                            local txt = (v:FindFirstChild("Title") and v.Title.Text) or (v:FindFirstChild("LabelContent") and v.LabelContent.Text) or ""
                            v.Visible = string.find(string.lower(txt), search) ~= nil
                        else
                            v.Visible = true
                        end
                    end
                end
            end
            SearchBox.Changed:Connect(UpdateResults)

            -- autosize section
            local size = 0
            SectionContainer.ChildAdded:Connect(function(me)
                if not me:IsA("Frame") then return end
                local add = (me.Name=="Toggle" or me.Name=="Button") and 36
                          or (me.Name=="Label") and 26
                          or (me.Name=="TextBox") and 30
                          or (me.Name=="Keybind") and 28
                          or (me.Name=="Slider") and 40
                          or (me.Name=="ColorPicker") and 40
                          or (me.Name=="Dropdown") and 36
                          or 34
                size = size + add
                Section.Size = UDim2.new(1,0,0,size)
            end)

            -- left list button
            local PageButton = Instance.new("TextButton")
            PageButton.Name = "PageButton"; PageButton.Parent = Tabs
            PageButton.BackgroundTransparency = 1
            PageButton.Size = UDim2.new(1,-14,0,18)
            PageButton.Font = Enum.Font.Gotham; PageButton.Text = name
            PageButton.TextColor3 = Color3.fromRGB(255,255,255); PageButton.TextSize=11; PageButton.TextTransparency=0.5
            PageButton.TextXAlignment = Enum.TextXAlignment.Left

            PageButton.MouseButton1Down:Connect(function()
                if not Indicator.Visible then Indicator.Visible=true end
                tween(Indicator, TweenInfo.new(0.25), {BackgroundTransparency=1})
                task.wait()
                tween(Indicator, TweenInfo.new(0.25), {BackgroundTransparency=0})
                for _,v in next, Tabs:GetChildren() do
                    if v:IsA("TextButton") and v.Name=="PageButton" then tween(v, TweenInfo.new(0.25), {TextTransparency=0.5}) end
                end
                tween(PageButton, TweenInfo.new(0.25), {TextTransparency=0})
                Indicator.Parent = PageButton
                -- hide others
                for _,v in pairs(Window:GetChildren()) do
                    if v:IsA("ScrollingFrame") and v ~= Page then v.Visible=false end
                end
                Page.Visible=true
                library.__activePage = Page
            end)

            -- ======= COMPONENTS =======
            local page = {}

            function page:CreateButton(title, desc, callback)
                title = title or "Button"; desc = desc or "Description"; callback = callback or function() end
                local Button = Instance.new("Frame"); Button.Name="Button"; Button.Parent=SectionContainer
                Button.BackgroundColor3 = Color3.fromRGB(40,40,48); Button.Size = UDim2.new(1,0,0,34)
                Instance.new("UICorner", Button).CornerRadius = UDim.new(0,4)

                local Title = Instance.new("TextLabel", Button)
                Title.Name="Title"; Title.BackgroundTransparency=1; Title.Position=UDim2.new(0,7,0,1)
                Title.Size=UDim2.new(1,-7,0.5,0); Title.Font=Enum.Font.GothamBlack; Title.Text=title
                Title.TextColor3=Color3.fromRGB(255,255,255); Title.TextSize=11; Title.TextXAlignment=Enum.TextXAlignment.Left

                local Description = Instance.new("TextLabel", Button)
                Description.BackgroundTransparency=1; Description.Position=UDim2.new(0,7,0.5,-1)
                Description.Size=UDim2.new(1,-7,0.5,0); Description.Font=Enum.Font.Gotham; Description.Text=desc
                Description.TextColor3=Color3.fromRGB(159,159,159); Description.TextSize=11; Description.TextXAlignment=Enum.TextXAlignment.Left

                local Caller = Instance.new("TextButton", Button)
                Caller.BackgroundTransparency=1; Caller.Size=UDim2.fromScale(1,1); Caller.Text=""
                Caller.MouseButton1Click:Connect(callback)
            end

            function page:CreateLabel(text)
                text = text or "Label"
                local Label = Instance.new("Frame"); Label.Name="Label"; Label.Parent=SectionContainer
                Label.BackgroundColor3=Color3.fromRGB(135,255,135); Label.BackgroundTransparency=0.5
                Label.Size = UDim2.new(1,0,0,22); Instance.new("UICorner", Label).CornerRadius=UDim.new(0,4)
                local Txt = Instance.new("TextLabel", Label); Txt.Name="LabelContent"; Txt.BackgroundTransparency=1
                Txt.Position=UDim2.new(0,7,0,0); Txt.Size=UDim2.new(1,-7,1,0); Txt.Font=Enum.Font.Gotham
                Txt.TextColor3=Color3.fromRGB(255,255,255); Txt.TextSize=11; Txt.TextXAlignment=Enum.TextXAlignment.Left
                Txt.Text = text
                return { UpdateLabel=function(_,t) Txt.Text=t end }
            end

            function page:CreateSlider(title, min, max, callback)
                title=title or "Slider"; min=min or 1; max=max or 100; callback=callback or function() end
                local Slider = Instance.new("Frame"); Slider.Name="Slider"; Slider.Parent=SectionContainer
                Slider.BackgroundColor3=Color3.fromRGB(40,40,48); Slider.Size=UDim2.new(1,0,0,38)
                Instance.new("UICorner", Slider).CornerRadius=UDim.new(0,4)
                local Title = Instance.new("TextLabel", Slider); Title.Name="Title"; Title.BackgroundTransparency=1
                Title.Position=UDim2.new(0,7,0,0); Title.Size=UDim2.new(1,-7,0,28); Title.Font=Enum.Font.GothamBlack
                Title.Text=title; Title.TextColor3=Color3.fromRGB(255,255,255); Title.TextSize=11; Title.TextXAlignment=Enum.TextXAlignment.Left

                local Tracker = Instance.new("Frame", Slider); Tracker.Name="Tracker"; Tracker.BackgroundColor3=Color3.fromRGB(30,30,36)
                Tracker.BorderSizePixel=0; Tracker.Position=UDim2.new(0,7,1,-8); Tracker.Size=UDim2.new(1,-14,0,2)
                local Fill = Instance.new("Frame", Tracker); Fill.Name="Indicator"; Fill.BackgroundColor3=Color3.fromRGB(135,255,135); Fill.Size=UDim2.new(0,0,1,0)
                local Knob = Instance.new("TextButton", Fill); Knob.BackgroundColor3=Color3.fromRGB(135,255,135)
                Knob.Position=UDim2.new(1,-4,0.5,-4); Knob.Size=UDim2.new(0,8,0,8); Knob.Text=""
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(0.5,0)

                local Value = Instance.new("TextLabel", Slider)
                Value.BackgroundTransparency=1; Value.AnchorPoint=Vector2.new(1,0)
                Value.Position=UDim2.new(1,-8,0,4); Value.Size=UDim2.new(0,48,0,18)
                Value.Font=Enum.Font.Gotham; Value.TextColor3=Color3.fromRGB(227,225,228); Value.TextSize=11; Value.Text = tostring(min)

                local dragging=false
                local function setFromInput(x)
                    local ratio = math.clamp((x - Tracker.AbsolutePosition.X) / Tracker.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(ratio,0,1,0)
                    local val = math.floor((min + (max-min)*ratio)*100+0.5)/100
                    Value.Text = tostring(math.floor(val))
                    callback(val)
                end
                Knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        setFromInput(i.Position.X)
                    end
                end)
                Knob.MouseButton1Click:Connect(function() setFromInput(UIS:GetMouseLocation().X) end)
            end

            function page:CreateBox(placeholder, iconId, callback)
                placeholder = placeholder or "Input Text Here..."; iconId = iconId=="Default" and 10045753138 or iconId
                callback = callback or function() end
                local TextBox = Instance.new("Frame"); TextBox.Name="TextBox"; TextBox.Parent=SectionContainer
                TextBox.BackgroundTransparency=1; TextBox.Size=UDim2.new(1,0,0,28)
                local Footer = Instance.new("Frame", TextBox); Footer.Name="Footer"; Footer.BackgroundColor3=Color3.fromRGB(135,255,135)
                Footer.BackgroundTransparency=0.75; Footer.Position=UDim2.new(0,0,1,-8); Footer.Size=UDim2.new(1,0,0,8); Instance.new("UICorner", Footer).CornerRadius=UDim.new(0,4)
                local Container = Instance.new("Frame", TextBox); Container.Name="Container"; Container.BackgroundColor3=Color3.fromRGB(40,40,48)
                Container.BorderSizePixel=0; Container.Size=UDim2.new(1,0,1,-1); Container.ZIndex=2; Instance.new("UICorner", Container).CornerRadius=UDim.new(0,4)
                local TI = Instance.new("TextBox", Container); TI.Name="TextInput"; TI.BackgroundTransparency=1
                TI.Position=UDim2.new(0,30,0,0); TI.Size=UDim2.new(1,-30,1,0); TI.Font=Enum.Font.Gotham; TI.PlaceholderText=placeholder
                TI.PlaceholderColor3=Color3.fromRGB(255,255,255); TI.Text=""; TI.TextColor3=Color3.fromRGB(255,255,255); TI.TextSize=11; TI.TextXAlignment=Enum.TextXAlignment.Left
                local EditIcon = Instance.new("ImageLabel", Container); EditIcon.BackgroundTransparency=1; EditIcon.Position=UDim2.new(0,6,0,5)
                EditIcon.Size=UDim2.new(0,18,0,18); EditIcon.Image="rbxassetid://"..(iconId or 10045753138); EditIcon.ImageColor3=Color3.fromRGB(135,255,135)
                TI.FocusLost:Connect(function() callback(TI.Text) end)
                return { UpdateBox=function(_,t) TI.PlaceholderText=t end }
            end

            function page:CreateBind(title, defaultKey, callback)
                title=title or "Keybind"; defaultKey=defaultKey or "F"; callback=callback or function() end
                local Keybind = Instance.new("Frame"); Keybind.Name="Keybind"; Keybind.Parent=SectionContainer
                Keybind.BackgroundTransparency=1; Keybind.Size=UDim2.new(1,0,0,28)
                local Footer = Instance.new("Frame", Keybind); Footer.BackgroundColor3=Color3.fromRGB(135,255,135); Footer.BackgroundTransparency=0.75
                Footer.Position=UDim2.new(0,0,1,-8); Footer.Size=UDim2.new(1,0,0,8); Instance.new("UICorner", Footer).CornerRadius=UDim.new(0,4)
                local Container = Instance.new("Frame", Keybind); Container.BackgroundColor3=Color3.fromRGB(40,40,48); Container.Size=UDim2.new(1,0,1,-1)
                Container.ZIndex=2; Container.BorderSizePixel=0; Instance.new("UICorner", Container).CornerRadius=UDim.new(0,4)
                local Title = Instance.new("TextLabel", Container); Title.Name="Title"; Title.BackgroundTransparency=1
                Title.Position=UDim2.new(0,8,0,0); Title.Size=UDim2.new(0,70,0,26); Title.Font=Enum.Font.GothamBlack; Title.Text=title
                Title.TextColor3=Color3.fromRGB(255,255,255); Title.TextSize=11; Title.TextXAlignment=Enum.TextXAlignment.Left
                local KButton = Instance.new("TextButton", Container); KButton.BackgroundColor3=Color3.fromRGB(0,0,0)
                KButton.BackgroundTransparency=0.83; KButton.Position=UDim2.new(1,-74,0.1,0); KButton.Size=UDim2.new(0,72,0,20)
                KButton.Font=Enum.Font.Gotham; KButton.Text=defaultKey; KButton.TextColor3=Color3.fromRGB(227,225,228); KButton.TextSize=11
                Instance.new("UICorner", KButton).CornerRadius=UDim.new(0,4)

                local CurrentKey = Enum.KeyCode[defaultKey] or Enum.KeyCode.F
                local capturing=false
                KButton.MouseButton1Click:Connect(function()
                    if capturing then return end; capturing=true; KButton.Text="..."
                    local conn; conn = UIS.InputBegan:Connect(function(Key,gp)
                        if gp then return end
                        if Key.UserInputType==Enum.UserInputType.Keyboard then
                            CurrentKey = Key.KeyCode; KButton.Text = CurrentKey.Name; callback(CurrentKey.Name)
                            capturing=false; conn:Disconnect()
                        end
                    end)
                end)
                UIS.InputBegan:Connect(function(Key,gp)
                    if gp then return end
                    if Key.UserInputType==Enum.UserInputType.Keyboard and Key.KeyCode==CurrentKey then
                        callback("pressed")
                    end
                end)
                return { UpdateBind=function(_,t) Title.Text=t end }
            end

            function page:CreateToggle(title, desc, callback)
                title=title or "Title"; desc=desc or "Description"; callback=callback or function() end
                local Toggle = Instance.new("Frame"); Toggle.Name="Toggle"; Toggle.Parent=SectionContainer
                Toggle.BackgroundColor3=Color3.fromRGB(40,40,48); Toggle.Size=UDim2.new(1,0,0,34)
                Instance.new("UICorner", Toggle).CornerRadius=UDim.new(0,4)
                local Title = Instance.new("TextLabel", Toggle); Title.Name="Title"; Title.BackgroundTransparency=1
                Title.Position=UDim2.new(0,7,0,1); Title.Size=UDim2.new(1,-7,0.5,0); Title.Font=Enum.Font.GothamBlack
                Title.Text=title; Title.TextColor3=Color3.fromRGB(255,255,255); Title.TextSize=11; Title.TextXAlignment=Enum.TextXAlignment.Left
                local Description = Instance.new("TextLabel", Toggle); Description.BackgroundTransparency=1
                Description.Position=UDim2.new(0,7,0.5,-1); Description.Size=UDim2.new(1,-7,0.5,0); Description.Font=Enum.Font.Gotham
                Description.Text=desc; Description.TextColor3=Color3.fromRGB(159,159,159); Description.TextSize=11; Description.TextXAlignment=Enum.TextXAlignment.Left
                local Indicator = Instance.new("Frame", Toggle); Indicator.Position=UDim2.new(1,-27,0,8); Indicator.Size=UDim2.new(0,18,0,18)
                Indicator.BackgroundTransparency=1; local stroke = Instance.new("UIStroke", Indicator); stroke.Thickness=2; stroke.Color=Color3.fromRGB(135,255,135)
                local Dot = Instance.new("Frame", Indicator); Dot.BackgroundColor3=Color3.fromRGB(135,255,135); Dot.BackgroundTransparency=1; Dot.Position=UDim2.new(0,2,0,2); Dot.Size=UDim2.new(1,-4,1,-4)
                Instance.new("UICorner", Dot).CornerRadius=UDim.new(0.5,0); Instance.new("UICorner", Indicator).CornerRadius=UDim.new(0.5,0)
                local Btn = Instance.new("TextButton", Toggle); Btn.BackgroundTransparency=1; Btn.Size=UDim2.new(1,0,1,0); Btn.Text=""
                local on=false
                Btn.MouseButton1Click:Connect(function()
                    on = not on
                    tween(Dot, TweenInfo.new(0.1), {BackgroundTransparency = on and 0 or 1})
                    callback(on)
                end)
                return { UpdateToggle=function(_,t,d) Title.Text=t; Description.Text=d end }
            end

            -- ===== NEW: DROPDOWN =====
            function page:CreateDropdown(title, options, defaultIndex, callback)
                title = title or "Dropdown"; options = options or {}; defaultIndex = defaultIndex or 1; callback = callback or function() end
                local Drop = Instance.new("Frame"); Drop.Name="Dropdown"; Drop.Parent=SectionContainer
                Drop.BackgroundColor3=Color3.fromRGB(40,40,48); Drop.Size=UDim2.new(1,0,0,34)
                Instance.new("UICorner", Drop).CornerRadius=UDim.new(0,4)
                local Title = Instance.new("TextLabel", Drop); Title.Name="Title"; Title.BackgroundTransparency=1
                Title.Position=UDim2.new(0,7,0,1); Title.Size=UDim2.new(1,-90,1,-2); Title.Font=Enum.Font.GothamBlack
                Title.Text=title; Title.TextColor3=Color3.fromRGB(255,255,255); Title.TextSize=11; Title.TextXAlignment=Enum.TextXAlignment.Left

                local Current = Instance.new("TextLabel", Drop)
                Current.BackgroundTransparency=1; Current.AnchorPoint=Vector2.new(1,0)
                Current.Position=UDim2.new(1,-30,0,0); Current.Size=UDim2.new(0,120,1,0)
                Current.Font=Enum.Font.Gotham; Current.TextColor3=Color3.fromRGB(220,220,220); Current.TextSize=11; Current.TextXAlignment=Enum.TextXAlignment.Right
                Current.Text = tostring(options[defaultIndex] or "None")

                local Arrow = Instance.new("TextLabel", Drop)
                Arrow.AnchorPoint=Vector2.new(1,0.5); Arrow.Position=UDim2.new(1,-8,0.5,0); Arrow.Size=UDim2.new(0,12,0,12)
                Arrow.BackgroundTransparency=1; Arrow.Font=Enum.Font.GothamBlack; Arrow.Text="▼"; Arrow.TextSize=12; Arrow.TextColor3=Color3.fromRGB(135,255,135)

                local Btn = Instance.new("TextButton", Drop); Btn.BackgroundTransparency=1; Btn.Size=UDim2.new(1,0,1,0); Btn.Text=""

                local ListFrame = Instance.new("Frame"); ListFrame.Name="DropdownList"; ListFrame.Parent = SectionContainer
                ListFrame.BackgroundColor3=Color3.fromRGB(30,30,36); ListFrame.Visible=false; ListFrame.Size=UDim2.new(1,0,0, (#options*24)+8)
                Instance.new("UICorner", ListFrame).CornerRadius=UDim.new(0,4)
                local pad = Instance.new("UIPadding", ListFrame); pad.PaddingTop=UDim.new(0,4); pad.PaddingBottom=UDim.new(0,4); pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4)
                local lay = Instance.new("UIListLayout", ListFrame); lay.Padding=UDim.new(0,4)

                local function selectOpt(opt)
                    Current.Text = tostring(opt); callback(opt)
                end
                for _,opt in ipairs(options) do
                    local b = Instance.new("TextButton", ListFrame)
                    b.BackgroundColor3=Color3.fromRGB(40,40,48); b.Size=UDim2.new(1,0,0,20)
                    b.Font=Enum.Font.Gotham; b.TextSize=11; b.TextColor3=Color3.fromRGB(240,240,240); b.Text=tostring(opt)
                    Instance.new("UICorner", b).CornerRadius=UDim.new(0,4)
                    b.MouseButton1Click:Connect(function()
                        selectOpt(opt)
                        ListFrame.Visible=false
                        tween(Arrow, TweenInfo.new(0.15), {Rotation = 0})
                    end)
                end
                selectOpt(options[defaultIndex] or options[1])

                Btn.MouseButton1Click:Connect(function()
                    ListFrame.Visible = not ListFrame.Visible
                    tween(Arrow, TweenInfo.new(0.15), {Rotation = ListFrame.Visible and 180 or 0})
                end)

                return {
                    UpdateOptions=function(_,opts)
                        options = opts or options
                        for _,c in ipairs(ListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                        for _,opt in ipairs(options) do
                            local b = Instance.new("TextButton", ListFrame)
                            b.BackgroundColor3=Color3.fromRGB(40,40,48); b.Size=UDim2.new(1,0,0,20)
                            b.Font=Enum.Font.Gotham; b.TextSize=11; b.TextColor3=Color3.fromRGB(240,240,240); b.Text=tostring(opt)
                            Instance.new("UICorner", b).CornerRadius=UDim.new(0,4)
                            b.MouseButton1Click:Connect(function() selectOpt(opt); ListFrame.Visible=false; tween(Arrow, TweenInfo.new(0.15), {Rotation = 0}) end)
                        end
                        ListFrame.Size = UDim2.new(1,0,0,(#options*24)+8)
                    end
                }
            end

            -- expose page buttons
            return page
        end
        return mytabbuttons
    end

    -- expose to outer code
    return tabs
end

return library
