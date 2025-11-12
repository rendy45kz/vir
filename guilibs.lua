if not game:IsLoaded() then game.Loaded:Wait() end

-- Vanis UI (Blue Accent, Compact, Auto-Size Fix, Overlay Toggle + Dropdown)
-- Perbaikan:
-- - Window compact 480x320 (ubah konstanta di bawah kalau perlu)
-- - Page auto-size (AutomaticCanvasSize.Y), Section/Container auto-size + no-clip (hindari terpotong)
-- - Overlay tombol gambar (draggable) hide/show, pakai icon yang sama dengan CreateWindow
-- - Komponen Dropdown dengan Search + UpdateDropdown

local WINDOW_W, WINDOW_H = 480, 320
local TITLE_H   = 30
local TABS_W    = 130
local GAP_ALL   = 5

local ACCENT      = Color3.fromRGB(110,175,255)
local ACCENT_SOFT = Color3.fromRGB(110,175,255)
local ACCENT_TEXT = Color3.fromRGB(227,229,255)

local library = {}

-- ==== Safe request / ProtectInstance ====
local identify = (identifyexecutor and identifyexecutor()) or ""
local request = request or http_request or ((identify=="Synapse X") and syn and syn.request) or (http and http.request)
local ProtectInstance = function(_) end
pcall(function()
    if request then
        local resp = request({Url="https://raw.githubusercontent.com/cypherdh/Script-Library/main/InstanceProtect", Method="GET"})
        if resp and resp.Body then
            local ok, fn = pcall(loadstring, resp.Body)
            if ok and fn then
                fn()
                if getfenv and getfenv().ProtectInstance then
                    ProtectInstance = getfenv().ProtectInstance
                end
            end
        end
    end
end)

local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ==== Helpers ====
local function mount_to_coregui(gui)
    ProtectInstance(gui)
    local parent = (cloneref and cloneref(CoreGui)) or CoreGui
    gui.Parent = parent
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 10^6
end

local function dragify(Frame, tweenSpeed)
    local dragging, dragInput, dragStart, startPos
    local function updateInput(input)
        local Delta = input.Position - dragStart
        local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
        TS:Create(Frame, TweenInfo.new(tweenSpeed or 0.12), {Position = Position}):Play()
    end
    Frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
            and UIS:GetFocusedTextBox() == nil then
            dragging = true
            dragStart = input.Position
            startPos  = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then updateInput(input) end
    end)
end

local function ripple(btn, color)
    local ms = game.Players.LocalPlayer:GetMouse()
    local s = Instance.new("ImageLabel")
    s.BackgroundTransparency = 1
    s.Image = "http://www.roblox.com/asset/?id=4560909609"
    s.ImageTransparency = 0.6
    s.ImageColor3 = color or ACCENT
    s.Size = UDim2.fromOffset(0,0)
    s.ZIndex = (btn.ZIndex or 1) + 1
    s.Parent = btn
    s.Position = UDim2.fromOffset(ms.X - btn.AbsolutePosition.X, ms.Y - btn.AbsolutePosition.Y)
    local len = 0.28
    local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.35
    s:TweenSizeAndPosition(UDim2.fromOffset(size,size), UDim2.new(0.5,-size/2,0.5,-size/2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, len, true)
    task.spawn(function()
        for _=1,10 do s.ImageTransparency = s.ImageTransparency + 0.05; task.wait(len/12) end
        s:Destroy()
    end)
end

-- ==== Library ====
function library:CreateWindow(name, version, icon)
    name    = name or "Name"
    version = version or "Version"
    icon    = icon or 0

    -- roots
    local MyGui   = Instance.new("ScreenGui")
    mount_to_coregui(MyGui)
    local OverlaySG = Instance.new("ScreenGui")
    mount_to_coregui(OverlaySG)

    local Window  = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = MyGui
    Window.BackgroundColor3 = Color3.fromRGB(49,49,59)
    Window.Position = UDim2.new(0.5, -math.floor(WINDOW_W/2), 0.5, -math.floor(WINDOW_H/2))
    Window.Size = UDim2.new(0, 0, 0, 0) -- animate in
    Window.ClipsDescendants = false

    ProtectInstance(Window)

    local UICorner = Instance.new("UICorner", Window)
    UICorner.CornerRadius = UDim.new(0,4)

    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Window
    TitleBar.BackgroundTransparency = 1
    TitleBar.Size = UDim2.new(1,0,0,TITLE_H)

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Parent = TitleBar
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0,6,0,6)
    Icon.Size = UDim2.fromOffset(18,18)
    Icon.Image = "rbxassetid://"..tostring(icon)
    Icon.ImageColor3 = ACCENT

    local MainTitle = Instance.new("TextLabel")
    MainTitle.Name = "Title"
    MainTitle.Parent = TitleBar
    MainTitle.BackgroundTransparency = 1
    MainTitle.Position = UDim2.new(0,30,0,1)
    MainTitle.Size = UDim2.new(1,-30,1,0)
    MainTitle.Font = Enum.Font.Gotham
    MainTitle.Text = ("%s | %s"):format(name, version)
    MainTitle.TextColor3 = Color3.fromRGB(255,255,255)
    MainTitle.TextSize = 12
    MainTitle.TextXAlignment = Enum.TextXAlignment.Left

    local TitleUnderline = Instance.new("Frame")
    TitleUnderline.Name = "TitleUnderline"
    TitleUnderline.Parent = TitleBar
    TitleUnderline.BorderSizePixel = 0
    TitleUnderline.BackgroundColor3 = ACCENT
    TitleUnderline.Position = UDim2.new(0,0,1,0)
    TitleUnderline.Size = UDim2.new(1,0,0,1)
    Instance.new("UIGradient", TitleUnderline)

    -- Close / Minimize
    local Close = Instance.new("ImageButton")
    Close.Name = "Close"
    Close.Parent = TitleBar
    Close.BackgroundTransparency = 1
    Close.Size = UDim2.fromOffset(24,24)
    Close.Position = UDim2.new(1,-28,0,3)
    Close.Image = "rbxassetid://3926305904"
    Close.ImageRectOffset = Vector2.new(284,4)
    Close.ImageRectSize   = Vector2.new(24,24)

    local Minimize = Instance.new("ImageButton")
    Minimize.Name = "Minimize"
    Minimize.Parent = TitleBar
    Minimize.BackgroundTransparency = 1
    Minimize.Size = UDim2.fromOffset(24,24)
    Minimize.Position = UDim2.new(1,-56,0,3)
    Minimize.Image = "http://www.roblox.com/asset/?id=6035067836"
    Minimize.ImageColor3 = ACCENT

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = Window
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0,-12,0,-12)
    Shadow.Size = UDim2.new(1,24,1,24)
    Shadow.Image = "http://www.roblox.com/asset/?id=5761504593"
    Shadow.ImageColor3 = Color3.fromRGB(49,49,59)
    Shadow.ImageTransparency = 0.3
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(17,17,283,283)

    -- Overlay (toggle) — same icon, draggable
    local OverlayBtn = Instance.new("ImageButton")
    OverlayBtn.Parent = OverlaySG
    OverlayBtn.Name = "OverlayToggle"
    OverlayBtn.BackgroundColor3 = Color3.fromRGB(32,34,46)
    OverlayBtn.AutoButtonColor = true
    OverlayBtn.Size = UDim2.fromOffset(36,36)
    OverlayBtn.Position = UDim2.new(0, 10, 0.5, -18)
    OverlayBtn.Image = "rbxassetid://"..tostring(icon)
    OverlayBtn.ImageColor3 = ACCENT
    local overlayCorner = Instance.new("UICorner", OverlayBtn); overlayCorner.CornerRadius = UDim.new(1,0)
    local overlayStroke = Instance.new("UIStroke", OverlayBtn); overlayStroke.Thickness=1; overlayStroke.Color=Color3.fromRGB(255,255,255); overlayStroke.Transparency=0.85
    dragify(OverlayBtn, 0.08)

    -- Animate open
    TS:Create(Window, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(WINDOW_W, 0)}):Play()
    task.wait(0.05)
    TS:Create(Window, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(WINDOW_W, WINDOW_H)}):Play()

    -- Toggle hide/show by overlay
    local hidden = false
    OverlayBtn.MouseButton1Click:Connect(function()
        hidden = not hidden
        Window.Visible = not hidden
        TS:Create(OverlayBtn, TweenInfo.new(0.15), {ImageColor3 = hidden and Color3.fromRGB(200,200,200) or ACCENT}):Play()
        ripple(OverlayBtn, ACCENT)
    end)

    -- Close / Minimize logic (using constants)
    Close.MouseButton1Click:Connect(function()
        TS:Create(Window, TweenInfo.new(0.25), {Size = UDim2.fromOffset(WINDOW_W, 0)}):Play()
        task.wait(0.25)
        TS:Create(Window, TweenInfo.new(0.25), {Size = UDim2.fromOffset(0, 0)}):Play()
        task.wait(0.25)
        MyGui:Destroy()
    end)
    local minimized = false
    Minimize.MouseButton1Click:Connect(function()
        if minimized then
            minimized = false
            TS:Create(Window, TweenInfo.new(0.2), {Size = UDim2.fromOffset(WINDOW_W, WINDOW_H)}):Play()
        else
            minimized = true
            TS:Create(Window, TweenInfo.new(0.2), {Size = UDim2.fromOffset(WINDOW_W, TITLE_H + 2)}):Play()
        end
    end)

    dragify(Window, 0.12)

    -- Tabs container (left)
    local Tabs = Instance.new("Frame")
    Tabs.Name = "Tabs"
    Tabs.Parent = Window
    Tabs.BackgroundColor3 = Color3.fromRGB(40,40,48)
    Tabs.Position = UDim2.new(0, GAP_ALL, 0, TITLE_H+GAP_ALL)
    Tabs.Size = UDim2.new(0, TABS_W, 1, -(TITLE_H + GAP_ALL*2))
    local TabsCorner = Instance.new("UICorner", Tabs); TabsCorner.CornerRadius = UDim.new(0,4)

    local TabHeader = Instance.new("TextLabel")
    TabHeader.Parent = Tabs
    TabHeader.BackgroundTransparency = 1
    TabHeader.TextXAlignment = Enum.TextXAlignment.Left
    TabHeader.Font = Enum.Font.GothamBold
    TabHeader.TextSize = 11
    TabHeader.TextColor3 = Color3.new(1,1,1)
    TabHeader.Text = "Sections"
    TabHeader.Size = UDim2.new(1, -10, 0, 18)
    TabHeader.Position = UDim2.new(0, 6, 0, 4)

    local TabsList = Instance.new("UIListLayout", Tabs)
    TabsList.SortOrder = Enum.SortOrder.LayoutOrder
    TabsList.Padding = UDim.new(0, 4)
    TabsList.HorizontalAlignment = Enum.HorizontalAlignment.Right

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.fromOffset(2, 14)
    Indicator.BackgroundColor3 = ACCENT
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Tabs

    -- API objects
    local window_api = {}
    local function hideAllPages()
        for _,v in ipairs(Window:GetChildren()) do
            if v:IsA("ScrollingFrame") and v.Name == "Page" then v.Visible = false end
        end
    end

    function window_api:CreateTab(tabName)
        tabName = tabName or "Tab"
        -- Optional: per-tab header (already have "Sections" global)

        local tab_api = {}

        function tab_api:CreateFrame(pageName)
            pageName = pageName or "Page"

            -- Page (right)
            local Page = Instance.new("ScrollingFrame")
            Page.Name = "Page"
            Page.Parent = Window
            Page.Active = true
            Page.BackgroundColor3 = Color3.fromRGB(40,40,48)
            Page.BorderSizePixel = 0
            Page.Position = UDim2.new(0, TABS_W + GAP_ALL*2, 0, TITLE_H + GAP_ALL)
            Page.Size = UDim2.new(1, -(TABS_W + GAP_ALL*3), 1, -(TITLE_H + GAP_ALL*2))
            Page.ScrollBarThickness = 5
            Page.ScrollBarImageColor3 = ACCENT
            Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Page.CanvasSize = UDim2.new(0,0,0,0)
            Page.Visible = false
            local PageCorner = Instance.new("UICorner", Page); PageCorner.CornerRadius = UDim.new(0,4)

            local PList = Instance.new("UIListLayout", Page)
            PList.SortOrder = Enum.SortOrder.LayoutOrder
            PList.Padding = UDim.new(0,4)
            local PPad  = Instance.new("UIPadding", Page)
            PPad.PaddingTop = UDim.new(0,4); PPad.PaddingBottom = UDim.new(0,4)
            PPad.PaddingLeft = UDim.new(0,4); PPad.PaddingRight = UDim.new(0,4)

            -- Search Bar
            local SearchBar = Instance.new("Frame")
            SearchBar.Name = "SearchBar"
            SearchBar.Parent = Page
            SearchBar.BackgroundColor3 = Color3.fromRGB(30,30,36)
            SearchBar.Size = UDim2.new(1,0,0,28)
            local SBcorner = Instance.new("UICorner", SearchBar); SBcorner.CornerRadius = UDim.new(0,4)

            local SearchIcon = Instance.new("ImageLabel", SearchBar)
            SearchIcon.BackgroundTransparency = 1
            SearchIcon.Image = "rbxassetid://10045418551"
            SearchIcon.ImageColor3 = ACCENT
            SearchIcon.Size = UDim2.fromOffset(16,16)
            SearchIcon.Position = UDim2.new(0,6,0,6)

            local Bar = Instance.new("Frame", SearchBar)
            Bar.BackgroundColor3 = ACCENT
            Bar.BorderSizePixel = 0
            Bar.Position = UDim2.new(0,26,0,8)
            Bar.Size = UDim2.new(0,1,1,-16)

            local SearchBox = Instance.new("TextBox", SearchBar)
            SearchBox.BackgroundTransparency = 1
            SearchBox.Font = Enum.Font.Gotham
            SearchBox.PlaceholderColor3 = ACCENT_TEXT
            SearchBox.PlaceholderText = "Search Here"
            SearchBox.Text = ""
            SearchBox.TextColor3 = ACCENT_TEXT
            SearchBox.TextSize = 11
            SearchBox.TextXAlignment = Enum.TextXAlignment.Left
            SearchBox.Size = UDim2.new(1,-34,1,0)
            SearchBox.Position = UDim2.new(0,32,0,0)

            -- Section auto-size (container)
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.Parent = Page
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.AutomaticSize = Enum.AutomaticSize.Y

            local SectionContainer = Instance.new("Frame")
            SectionContainer.Name = "SectionContainer"
            SectionContainer.Parent = Section
            SectionContainer.BackgroundColor3 = Color3.fromRGB(30,30,36)
            SectionContainer.BorderSizePixel = 0
            SectionContainer.ClipsDescendants = false
            SectionContainer.AutomaticSize = Enum.AutomaticSize.Y
            SectionContainer.Size = UDim2.new(1,0,0,0)
            local SCcorner = Instance.new("UICorner", SectionContainer); SCcorner.CornerRadius = UDim.new(0,4)

            local headerBar = Instance.new("Frame")
            headerBar.Parent = Section
            headerBar.BackgroundColor3 = ACCENT
            headerBar.BorderSizePixel = 0
            headerBar.Size = UDim2.new(1,0,0,6)
            local headerCorner = Instance.new("UICorner", headerBar); headerCorner.CornerRadius = UDim.new(0,4)

            local SCPad = Instance.new("UIPadding", SectionContainer)
            SCPad.PaddingTop = UDim.new(0,4); SCPad.PaddingBottom = UDim.new(0,4)
            SCPad.PaddingLeft = UDim.new(0,4); SCPad.PaddingRight = UDim.new(0,4)
            local SCList = Instance.new("UIListLayout", SectionContainer)
            SCList.SortOrder = Enum.SortOrder.LayoutOrder
            SCList.Padding   = UDim.new(0,4)

            -- Search filtering
            local function UpdateResults()
                local q = string.lower(SearchBox.Text)
                for _, v in ipairs(SectionContainer:GetChildren()) do
                    if v:IsA("Frame") then
                        local key = ""
                        local t = v:FindFirstChild("Title")
                        if t and t:IsA("TextLabel") then key = t.Text
                        elseif v.Name == "Label" then
                            local lc = v:FindFirstChild("LabelContent")
                            key = (lc and lc.Text) or ""
                        elseif v.Name == "TextBox" then
                            local cont = v:FindFirstChild("Container")
                            local tb = cont and cont:FindFirstChild("TextInput")
                            key = (tb and tb.Text) or ""
                        end
                        v.Visible = (q == "") or (string.find(string.lower(key), q, 1, true) ~= nil)
                    end
                end
            end
            SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateResults)

            -- Page button (in tabs)
            local PageButton = Instance.new("TextButton")
            PageButton.Name = "PageButton"
            PageButton.Parent = Tabs
            PageButton.BackgroundTransparency = 1
            PageButton.Size = UDim2.new(1, -10, 0, 18)
            PageButton.Font = Enum.Font.Gotham
            PageButton.Text = pageName
            PageButton.TextColor3 = Color3.fromRGB(255,255,255)
            PageButton.TextSize = 11
            PageButton.TextTransparency = 0.45
            PageButton.TextXAlignment = Enum.TextXAlignment.Left

            PageButton.MouseButton1Click:Connect(function()
                Indicator.Visible = true
                Indicator.Parent = PageButton
                TS:Create(PageButton, TweenInfo.new(0.12), {TextTransparency = 0}):Play()
                for _,v in ipairs(Tabs:GetChildren()) do
                    if v:IsA("TextButton") and v ~= PageButton then
                        TS:Create(v, TweenInfo.new(0.12), {TextTransparency = 0.45}):Play()
                    end
                end
                hideAllPages()
                Page.Visible = true
            end)

            -- Page API (controls)
            local page_api = {}

            function page_api:CreateLabel(text)
                text = text or "Label"
                local Label = Instance.new("Frame")
                Label.Name = "Label"
                Label.Parent = SectionContainer
                Label.BackgroundColor3 = ACCENT
                Label.BackgroundTransparency = 0.5
                Label.Size = UDim2.new(1,0,0,22)
                local c = Instance.new("UICorner", Label); c.CornerRadius = UDim.new(0,4)

                local lc = Instance.new("TextLabel", Label)
                lc.Name = "LabelContent"
                lc.BackgroundTransparency = 1
                lc.Size = UDim2.new(1,-8,1,0)
                lc.Position = UDim2.new(0,6,0,0)
                lc.Font = Enum.Font.Gotham
                lc.TextColor3 = Color3.new(1,1,1)
                lc.TextSize = 11
                lc.TextXAlignment = Enum.TextXAlignment.Left
                lc.Text = text

                return { UpdateLabel = function(_, t) lc.Text = t end }
            end

            function page_api:CreateButton(title, desc, callback)
                title = title or "Button"
                desc  = desc or "Description"
                callback = callback or function() end

                local Button = Instance.new("Frame")
                Button.Name = "Button"
                Button.Parent = SectionContainer
                Button.BackgroundColor3 = Color3.fromRGB(40,40,48)
                Button.Size = UDim2.new(1,0,0,36)
                Instance.new("UICorner", Button).CornerRadius = UDim.new(0,4)

                local Title = Instance.new("TextLabel", Button)
                Title.Name = "Title"
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0,7,0,2)
                Title.Size = UDim2.new(1,-7,0,16)
                Title.Font = Enum.Font.GothamBold
                Title.Text = title
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextSize = 11
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Desc = Instance.new("TextLabel", Button)
                Desc.BackgroundTransparency = 1
                Desc.Position = UDim2.new(0,7,0,18)
                Desc.Size = UDim2.new(1,-7,0,14)
                Desc.Font = Enum.Font.Gotham
                Desc.Text = desc
                Desc.TextColor3 = Color3.fromRGB(180,180,180)
                Desc.TextSize = 10
                Desc.TextXAlignment = Enum.TextXAlignment.Left

                local Caller = Instance.new("TextButton", Button)
                Caller.BackgroundTransparency = 1
                Caller.Size = UDim2.new(1,0,1,0)
                Caller.Text = ""
                Caller.MouseButton1Click:Connect(function()
                    ripple(Caller, ACCENT)
                    task.spawn(callback)
                end)

                return { UpdateButton = function(_, t) Title.Text = t end }
            end

            function page_api:CreateToggle(title, desc, callback)
                title = title or "Toggle"
                desc  = desc or "Description"
                callback = callback or function() end

                local Toggle = Instance.new("Frame")
                Toggle.Name = "Toggle"
                Toggle.Parent = SectionContainer
                Toggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
                Toggle.Size = UDim2.new(1,0,0,36)
                Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,4)

                local Title = Instance.new("TextLabel", Toggle)
                Title.Name = "Title"
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0,7,0,2)
                Title.Size = UDim2.new(1,-40,0,16)
                Title.Font = Enum.Font.GothamBold
                Title.Text = title
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextSize = 11
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Desc = Instance.new("TextLabel", Toggle)
                Desc.BackgroundTransparency = 1
                Desc.Position = UDim2.new(0,7,0,18)
                Desc.Size = UDim2.new(1,-40,0,14)
                Desc.Font = Enum.Font.Gotham
                Desc.Text = desc
                Desc.TextColor3 = Color3.fromRGB(180,180,180)
                Desc.TextSize = 10
                Desc.TextXAlignment = Enum.TextXAlignment.Left

                local circle = Instance.new("Frame", Toggle)
                circle.Size = UDim2.fromOffset(18,18)
                circle.Position = UDim2.new(1,-26,0,9)
                circle.BackgroundColor3 = Color3.fromRGB(40,40,48)
                circle.BorderSizePixel = 0
                Instance.new("UICorner", circle).CornerRadius = UDim.new(0.5,0)
                local stroke = Instance.new("UIStroke", circle)
                stroke.Color = ACCENT; stroke.Thickness = 2

                local dot = Instance.new("Frame", circle)
                dot.Size = UDim2.new(1,-6,1,-6)
                dot.Position = UDim2.new(0,3,0,3)
                dot.BackgroundColor3 = ACCENT
                dot.BackgroundTransparency = 1
                Instance.new("UICorner", dot).CornerRadius = UDim.new(0.5,0)

                local btn = Instance.new("TextButton", Toggle)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Size = UDim2.new(1,0,1,0)

                local on = false
                local function set(v)
                    on = v and true or false
                    TS:Create(dot, TweenInfo.new(0.1), {BackgroundTransparency = on and 0 or 1}):Play()
                    task.spawn(callback, on)
                end
                btn.MouseButton1Click:Connect(function() set(not on) end)

                return {
                    UpdateToggle = function(_, newTitle, newDesc)
                        if newTitle then Title.Text = newTitle end
                        if newDesc then  Desc.Text  = newDesc  end
                    end,
                    Set = set
                }
            end

            function page_api:CreateSlider(name, min, max, callback)
                name = name or "Slider"
                min = tonumber(min) or 0
                max = tonumber(max) or 100
                callback = callback or function() end

                local Slider = Instance.new("Frame")
                Slider.Name = "Slider"
                Slider.Parent = SectionContainer
                Slider.BackgroundColor3 = Color3.fromRGB(40,40,48)
                Slider.Size = UDim2.new(1,0,0,40)
                Instance.new("UICorner", Slider).CornerRadius = UDim.new(0,4)

                local Title = Instance.new("TextLabel", Slider)
                Title.Name = "Title"
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0,7,0,2)
                Title.Size = UDim2.new(1,-7,0,16)
                Title.Font = Enum.Font.GothamBold
                Title.Text = name
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextSize = 11
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local track = Instance.new("Frame", Slider)
                track.BorderSizePixel = 0
                track.BackgroundColor3 = Color3.fromRGB(30,30,36)
                track.Size = UDim2.new(1,-14,0,2)
                track.Position = UDim2.new(0,7,1,-10)

                local fill = Instance.new("Frame", track)
                fill.BorderSizePixel = 0
                fill.BackgroundColor3 = ACCENT
                fill.Size = UDim2.new(0,0,1,0)

                local knob = Instance.new("TextButton", fill)
                knob.Text = ""
                knob.AutoButtonColor = false
                knob.Size = UDim2.fromOffset(8,8)
                knob.Position = UDim2.new(1,-4,0.5,-4)
                knob.BackgroundColor3 = ACCENT
                Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5,0)

                local val = Instance.new("TextLabel", Slider)
                val.BackgroundTransparency = 0.83
                val.BackgroundColor3 = Color3.new(0,0,0)
                val.TextColor3 = ACCENT_TEXT
                val.Font = Enum.Font.Gotham
                val.TextSize = 10
                val.Size = UDim2.fromOffset(40,16)
                val.Position = UDim2.new(1,-46,0,2)
                val.Text = tostring(min)

                local dragging = false
                local function setFromX(x)
                    local a = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(a,0,1,0)
                    local value = math.floor((min + (max - min)*a) * 100 + 0.5)/100
                    val.Text = tostring(value)
                    pcall(callback, value)
                end
                knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; ripple(knob, ACCENT) end end)
                knob.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        setFromX(i.Position.X)
                    end
                end)
                track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then setFromX(i.Position.X) end end)

                return {}
            end

            function page_api:CreateBox(placeholder, iconId, callback)
                placeholder = placeholder or "Input..."
                if iconId == "Default" or iconId == nil then iconId = 10045753138 end
                callback = callback or function() end

                local TextBox = Instance.new("Frame")
                TextBox.Name = "TextBox"
                TextBox.Parent = SectionContainer
                TextBox.BackgroundTransparency = 1
                TextBox.Size = UDim2.new(1,0,0,30)

                local Footer = Instance.new("Frame", TextBox)
                Footer.BackgroundColor3 = ACCENT
                Footer.BackgroundTransparency = 0.75
                Footer.Position = UDim2.new(0,0,1,-6)
                Footer.Size = UDim2.new(1,0,0,6)
                Instance.new("UICorner", Footer).CornerRadius = UDim.new(0,4)

                local Container = Instance.new("Frame", TextBox)
                Container.Name = "Container"
                Container.BackgroundColor3 = Color3.fromRGB(40,40,48)
                Container.BorderSizePixel = 0
                Container.Size = UDim2.new(1,0,1,-1)
                Container.ZIndex = 2
                Instance.new("UICorner", Container).CornerRadius = UDim.new(0,4)

                local EditIcon = Instance.new("ImageLabel", Container)
                EditIcon.BackgroundTransparency = 1
                EditIcon.Position = UDim2.new(0,6,0,6)
                EditIcon.Size = UDim2.fromOffset(16,16)
                EditIcon.Image = "rbxassetid://"..tostring(iconId)
                EditIcon.ImageColor3 = ACCENT

                local TextInput = Instance.new("TextBox", Container)
                TextInput.Name = "TextInput"
                TextInput.BackgroundTransparency = 1
                TextInput.Position = UDim2.new(0,28,0,0)
                TextInput.Size = UDim2.new(1,-28,1,0)
                TextInput.Font = Enum.Font.Gotham
                TextInput.PlaceholderColor3 = Color3.fromRGB(255,255,255)
                TextInput.PlaceholderText = placeholder
                TextInput.Text = ""
                TextInput.TextColor3 = Color3.fromRGB(255,255,255)
                TextInput.TextSize = 11
                TextInput.TextXAlignment = Enum.TextXAlignment.Left
                TextInput.FocusLost:Connect(function() pcall(callback, TextInput.Text) end)

                return { UpdateBox = function(_, t) TextInput.PlaceholderText = t end }
            end

            function page_api:CreateBind(title, defaultkey, callback)
                title = title or "Keybind"
                defaultkey = defaultkey or "F"
                callback = callback or function() end

                local Keybind = Instance.new("Frame")
                Keybind.Name = "Keybind"
                Keybind.Parent = SectionContainer
                Keybind.BackgroundTransparency = 1
                Keybind.Size = UDim2.new(1,0,0,30)

                local Footer = Instance.new("Frame", Keybind)
                Footer.BackgroundColor3 = ACCENT
                Footer.BackgroundTransparency = 0.75
                Footer.Position = UDim2.new(0,0,1,-6)
                Footer.Size = UDim2.new(1,0,0,6)
                Instance.new("UICorner", Footer).CornerRadius = UDim.new(0,4)

                local Container = Instance.new("Frame", Keybind)
                Container.BackgroundColor3 = Color3.fromRGB(40,40,48)
                Container.BorderSizePixel = 0
                Container.Size = UDim2.new(1,0,1,-1)
                Container.ZIndex = 2
                Instance.new("UICorner", Container).CornerRadius = UDim.new(0,4)

                local Title = Instance.new("TextLabel", Container)
                Title.Name = "Title"
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0,8,0,0)
                Title.Size = UDim2.new(1,-86,1,0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = title
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextSize = 11
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local KButton = Instance.new("TextButton", Container)
                KButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
                KButton.BackgroundTransparency = 0.83
                KButton.Position = UDim2.new(1,-80,0.5,-10)
                KButton.Size = UDim2.fromOffset(76,20)
                KButton.Font = Enum.Font.Gotham
                KButton.Text = defaultkey
                KButton.TextColor3 = ACCENT_TEXT
                KButton.TextSize = 10
                Instance.new("UICorner", KButton).CornerRadius = UDim.new(0,4)

                local current = defaultkey
                local listening = false
                KButton.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    KButton.Text = ". . ."
                    local con; con = UIS.InputBegan:Connect(function(Key, gp)
                        if gp then return end
                        if Key.UserInputType == Enum.UserInputType.Keyboard then
                            current = Key.KeyCode.Name
                            KButton.Text = current
                            pcall(callback, current)
                            con:Disconnect(); listening=false
                        end
                    end)
                end)
                UIS.InputBegan:Connect(function(Key, gp)
                    if gp then return end
                    if Key.UserInputType == Enum.UserInputType.Keyboard and Key.KeyCode.Name == current then
                        ripple(KButton, ACCENT)
                        pcall(callback, current)
                    end
                end)

                return { UpdateBind = function(_, t) Title.Text = t end }
            end

            -- ===== DROPDOWN =====
            function page_api:CreateDropdown(title, options, callback)
                title = title or "Dropdown"
                options = typeof(options)=="table" and options or {}
                callback = callback or function() end

                local Holder = Instance.new("Frame")
                Holder.Name = "Dropdown"
                Holder.Parent = SectionContainer
                Holder.BackgroundColor3 = Color3.fromRGB(40,40,48)
                Holder.Size = UDim2.new(1,0,0,36)
                Instance.new("UICorner", Holder).CornerRadius = UDim.new(0,4)

                local Title = Instance.new("TextLabel", Holder)
                Title.Name = "Title"
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0,7,0,2)
                Title.Size = UDim2.new(1,-40,0,16)
                Title.Font = Enum.Font.GothamBold
                Title.Text = title
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextSize = 11
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Current = Instance.new("TextLabel", Holder)
                Current.BackgroundTransparency = 1
                Current.Position = UDim2.new(0,7,0,18)
                Current.Size = UDim2.new(1,-40,0,14)
                Current.Font = Enum.Font.Gotham
                Current.Text = "-"
                Current.TextColor3 = Color3.fromRGB(200,200,200)
                Current.TextSize = 10
                Current.TextXAlignment = Enum.TextXAlignment.Left

                local OpenBtn = Instance.new("TextButton", Holder)
                OpenBtn.BackgroundTransparency = 1
                OpenBtn.Text = ""
                OpenBtn.Size = UDim2.new(1,0,1,0)

                local ListFrame = Instance.new("Frame")
                ListFrame.Name = "List"
                ListFrame.BackgroundColor3 = Color3.fromRGB(30,30,36)
                ListFrame.BorderSizePixel = 0
                ListFrame.Position = UDim2.new(0,0,1,2)
                ListFrame.Size = UDim2.new(1,0,0,120)
                ListFrame.Visible = false
                ListFrame.Parent = Holder
                ListFrame.ZIndex = 1000
                Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0,4)

                local Search = Instance.new("TextBox", ListFrame)
                Search.BackgroundTransparency = 1
                Search.Font = Enum.Font.Gotham
                Search.TextSize = 10
                Search.TextColor3 = Color3.new(1,1,1)
                Search.PlaceholderColor3 = Color3.fromRGB(215,215,215)
                Search.PlaceholderText = "Search..."
                Search.Text = ""
                Search.Size = UDim2.new(1,-10,0,18)
                Search.Position = UDim2.new(0,5,0,6)
                Search.ZIndex = 1001

                local Scroll = Instance.new("ScrollingFrame", ListFrame)
                Scroll.Active = true
                Scroll.BackgroundTransparency = 1
                Scroll.Size = UDim2.new(1,-10,1,-30)
                Scroll.Position = UDim2.new(0,5,0,26)
                Scroll.ScrollBarThickness = 5
                Scroll.ScrollBarImageColor3 = ACCENT
                Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                Scroll.CanvasSize = UDim2.new(0,0,0,0)
                Scroll.ZIndex = 1001

                local pad = Instance.new("UIPadding", Scroll)
                pad.PaddingTop = UDim.new(0,4); pad.PaddingBottom = UDim.new(0,4)

                local list = Instance.new("UIListLayout", Scroll)
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Padding = UDim.new(0,4)

                local opts = {}
                for _,v in ipairs(options) do table.insert(opts, tostring(v)) end
                table.sort(opts)
                local buttons = {}

                local function rebuild(filter)
                    for _,b in ipairs(buttons) do b:Destroy() end
                    table.clear(buttons)
                    local q = string.lower(filter or "")
                    for _,name in ipairs(opts) do
                        if q=="" or string.find(string.lower(name), q, 1, true) then
                            local b = Instance.new("TextButton")
                            b.BackgroundColor3 = Color3.fromRGB(40,40,48)
                            b.TextColor3 = Color3.new(1,1,1)
                            b.Font = Enum.Font.Gotham
                            b.TextSize = 10
                            b.TextXAlignment = Enum.TextXAlignment.Left
                            b.Text = name
                            b.Size = UDim2.new(1,-4,0,22)
                            b.Parent = Scroll
                            b.ZIndex = 1002
                            Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
                            b.MouseButton1Click:Connect(function()
                                Current.Text = name
                                ListFrame.Visible = false
                                ripple(b, ACCENT)
                                task.spawn(callback, name)
                            end)
                            table.insert(buttons, b)
                        end
                    end
                end
                rebuild("")
                OpenBtn.MouseButton1Click:Connect(function()
                    ListFrame.Visible = not ListFrame.Visible
                    ripple(OpenBtn, ACCENT)
                end)
                Search:GetPropertyChangedSignal("Text"):Connect(function()
                    rebuild(Search.Text)
                end)

                local api = {}
                function api:UpdateDropdown(newOptions)
                    opts = {}
                    if typeof(newOptions)=="table" then
                        for _,v in ipairs(newOptions) do table.insert(opts, tostring(v)) end
                    end
                    table.sort(opts)
                    rebuild(Search.Text)
                end
                function api:Set(text)
                    Current.Text = tostring(text or "-")
                end
                return api
            end

            -- return page api
            return page_api
        end

        return setmetatable({}, {__index=function(_,k)
            if k=="CreateFrame" then return tab_api.CreateFrame end
        end})
    end

    -- window API
    return setmetatable({}, {__index=function(_,k)
        if k=="CreateTab" then return window_api.CreateTab end
    end})
end

return library
