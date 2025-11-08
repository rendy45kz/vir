-- Vanis UI Library (Fixed + Dropdown Support)
-- - Auto-size scrolling pages (no clipping)
-- - New CreateDropdown + UpdateDropdown
-- - API compatible with your previous usage

if not game:IsLoaded() then game.Loaded:Wait() end

local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local lp = game:GetService("Players").LocalPlayer

local request = request or http_request or (identifyexecutor and identifyexecutor() == "Synapse X" and syn and syn.request) or (http and http.request)
local ProtectInstance = function(_) end
pcall(function()
    if request then
        local src = request({Url="https://raw.githubusercontent.com/cypherdh/Script-Library/main/InstanceProtect",Method="GET"}).Body
        local ok,fn = pcall(loadstring, src)
        if ok and fn then fn() end
        ProtectInstance = getfenv().ProtectInstance or ProtectInstance
    end
end)

local function rippleOn(button, color)
    local ms = lp:GetMouse()
    local sample = Instance.new("ImageLabel")
    sample.Name = "Ripple"
    sample.BackgroundTransparency = 1
    sample.Image = "http://www.roblox.com/asset/?id=4560909609"
    sample.ImageTransparency = 0.6
    sample.ImageColor3 = color or Color3.fromRGB(135,255,135)
    sample.Size = UDim2.fromOffset(0,0)
    sample.Position = UDim2.fromOffset(ms.X - button.AbsolutePosition.X, ms.Y - button.AbsolutePosition.Y)
    sample.ZIndex = (button.ZIndex or 1) + 1
    sample.Parent = button
    local len = 0.35
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
    sample:TweenSizeAndPosition(UDim2.fromOffset(size,size), UDim2.new(0.5, -size/2, 0.5, -size/2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, len, true)
    task.spawn(function()
        for i=1,10 do
            sample.ImageTransparency = sample.ImageTransparency + 0.05
            task.wait(len/12)
        end
        sample:Destroy()
    end)
end

local function makeDraggable(Frame)
    local dragging, dragStart, startPos
    Frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
            and UIS:GetFocusedTextBox() == nil then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TS:Create(Frame, TweenInfo.new(0.15), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end

local library = {}

function library:CreateWindow(name, version, icon)
    name = name or "Name"
    version = version or "Version"
    icon = icon or 0

    local sg = Instance.new("ScreenGui")
    ProtectInstance(sg)
    sg.DisplayOrder = 10^6
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Name = "VanisUI_"..tostring(math.random(1000,9999))
    sg.Parent = (gethui and gethui()) or CoreGui

    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.fromOffset(600, 400)
    Window.Position = UDim2.new(0.5, -300, 0.5, -200)
    Window.BackgroundColor3 = Color3.fromRGB(49,49,59)
    Window.Parent = sg
    local wc = Instance.new("UICorner", Window)
    wc.CornerRadius = UDim.new(0,6)

    makeDraggable(Window)

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundTransparency = 1
    TitleBar.Size = UDim2.new(1,0,0,32)
    TitleBar.Parent = Window

    local Icon = Instance.new("ImageLabel")
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.fromOffset(18,18)
    Icon.Position = UDim2.new(0,8,0,7)
    Icon.Image = "rbxassetid://"..tostring(icon)
    Icon.ImageColor3 = Color3.fromRGB(135,255,135)
    Icon.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 12
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Text = string.format("%s | %s", name, version)
    Title.Size = UDim2.new(1,-40,1,0)
    Title.Position = UDim2.new(0,32,0,0)
    Title.Parent = TitleBar

    local Under = Instance.new("Frame")
    Under.BorderSizePixel = 0
    Under.BackgroundColor3 = Color3.fromRGB(135,255,135)
    Under.Size = UDim2.new(1,0,0,1)
    Under.Position = UDim2.new(0,0,1,0)
    Under.Parent = TitleBar

    local Tabs = Instance.new("Frame")
    Tabs.Name = "Tabs"
    Tabs.Size = UDim2.new(0,150,1,-36)
    Tabs.Position = UDim2.new(0,6,0,36)
    Tabs.BackgroundColor3 = Color3.fromRGB(40,40,48)
    Tabs.Parent = Window
    Instance.new("UICorner", Tabs).CornerRadius = UDim.new(0,6)

    local tabList = Instance.new("UIListLayout", Tabs)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0,6)

    local tabHeader = Instance.new("TextLabel")
    tabHeader.BackgroundTransparency = 1
    tabHeader.TextXAlignment = Enum.TextXAlignment.Left
    tabHeader.Font = Enum.Font.GothamBlack
    tabHeader.TextSize = 12
    tabHeader.TextColor3 = Color3.new(1,1,1)
    tabHeader.Text = "Sections"
    tabHeader.Size = UDim2.new(1,-12,0,24)
    tabHeader.Position = UDim2.new(0,6,0,6)
    tabHeader.Parent = Tabs

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0,2,0,20)
    Indicator.BackgroundColor3 = Color3.fromRGB(135,255,135)
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Tabs

    local function hideAllPages()
        for _,v in ipairs(Window:GetChildren()) do
            if v:IsA("ScrollingFrame") and v.Name == "Page" then
                v.Visible = false
            end
        end
    end

    local win = {}
    function win:CreateTab(tabName)
        tabName = tabName or "Tab"

        local tabObj = {}

        function tabObj:CreateFrame(pageName)
            pageName = pageName or "Page 1"

            -- page (scrolling with autosize)
            local Page = Instance.new("ScrollingFrame")
            Page.Name = "Page"
            Page.Active = true
            Page.BackgroundColor3 = Color3.fromRGB(40,40,48)
            Page.BorderSizePixel = 0
            Page.Position = UDim2.new(0, 160, 0, 36)
            Page.Size = UDim2.new(1, -166, 1, -42)
            Page.ScrollBarThickness = 6
            Page.ScrollBarImageColor3 = Color3.fromRGB(135,255,135)
            Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Page.CanvasSize = UDim2.new(0,0,0,0)
            Page.Visible = false
            Instance.new("UICorner", Page).CornerRadius = UDim.new(0,6)
            Page.Parent = Window

            local pad = Instance.new("UIPadding", Page)
            pad.PaddingLeft = UDim.new(0,6)
            pad.PaddingRight = UDim.new(0,6)
            pad.PaddingTop = UDim.new(0,6)
            pad.PaddingBottom = UDim.new(0,6)

            local list = Instance.new("UIListLayout", Page)
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Padding = UDim.new(0,6)

            -- page button on left
            local PageButton = Instance.new("TextButton")
            PageButton.Name = "PageButton"
            PageButton.BackgroundTransparency = 1
            PageButton.TextXAlignment = Enum.TextXAlignment.Left
            PageButton.Font = Enum.Font.Gotham
            PageButton.TextSize = 12
            PageButton.TextColor3 = Color3.new(1,1,1)
            PageButton.TextTransparency = 0.5
            PageButton.Text = pageName
            PageButton.Size = UDim2.new(1,-12,0,20)
            PageButton.Parent = Tabs

            PageButton.MouseButton1Click:Connect(function()
                Indicator.Visible = true
                Indicator.Position = UDim2.new(0,-2,0,PageButton.AbsolutePosition.Y - Tabs.AbsolutePosition.Y + (PageButton.AbsoluteSize.Y-Indicator.AbsoluteSize.Y)/2)
                Indicator.Parent = PageButton
                for _,v in ipairs(Tabs:GetChildren()) do
                    if v:IsA("TextButton") then TS:Create(v, TweenInfo.new(0.2), {TextTransparency=0.5}):Play() end
                end
                TS:Create(PageButton, TweenInfo.new(0.2), {TextTransparency=0}):Play()
                hideAllPages()
                Page.Visible = true
            end)

            local page = {}

            function page:CreateLabel(text)
                text = text or "Label"
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextColor3 = Color3.new(1,1,1)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Size = UDim2.new(1,-4,0,22)
                Label.Text = text
                Label.Parent = Page
                local api = {}
                function api:UpdateLabel(t) Label.Text = t end
                return api
            end

            function page:CreateButton(title, desc, callback)
                title = title or "Button"
                desc = desc or "Description"
                callback = callback or function() end
                local f = Instance.new("Frame")
                f.Name = "Button"
                f.BackgroundColor3 = Color3.fromRGB(40,40,48)
                f.Size = UDim2.new(1,0,0,44)
                Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
                f.Parent = Page

                local Title = Instance.new("TextLabel", f)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 12
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,2)
                Title.Size = UDim2.new(1,-8,0,20)
                Title.Text = title

                local Desc = Instance.new("TextLabel", f)
                Desc.BackgroundTransparency = 1
                Desc.Font = Enum.Font.Gotham
                Desc.TextSize = 12
                Desc.TextColor3 = Color3.fromRGB(180,180,180)
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Position = UDim2.new(0,8,0,22)
                Desc.Size = UDim2.new(1,-8,0,20)
                Desc.Text = desc

                local btn = Instance.new("TextButton", f)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Size = UDim2.new(1,0,1,0)
                btn.MouseButton1Click:Connect(function()
                    rippleOn(btn, Color3.fromRGB(135,255,135))
                    task.spawn(callback)
                end)
                local api = {}
                function api:UpdateButton(newTitle) Title.Text = newTitle end
                return api
            end

            function page:CreateToggle(title, desc, callback)
                title = title or "Toggle"
                desc = desc or "Description"
                callback = callback or function() end

                local f = Instance.new("Frame")
                f.Name = "Toggle"
                f.BackgroundColor3 = Color3.fromRGB(40,40,48)
                f.Size = UDim2.new(1,0,0,44)
                Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
                f.Parent = Page

                local Title = Instance.new("TextLabel", f)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 12
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,2)
                Title.Size = UDim2.new(1,-40,0,20)
                Title.Text = title

                local Desc = Instance.new("TextLabel", f)
                Desc.BackgroundTransparency = 1
                Desc.Font = Enum.Font.Gotham
                Desc.TextSize = 12
                Desc.TextColor3 = Color3.fromRGB(180,180,180)
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Position = UDim2.new(0,8,0,22)
                Desc.Size = UDim2.new(1,-40,0,20)
                Desc.Text = desc

                local circle = Instance.new("Frame", f)
                circle.Size = UDim2.fromOffset(20,20)
                circle.Position = UDim2.new(1,-28,0,12)
                circle.BackgroundColor3 = Color3.fromRGB(40,40,48)
                circle.BorderSizePixel = 0
                Instance.new("UICorner", circle).CornerRadius = UDim.new(0.5,0)
                local stroke = Instance.new("UIStroke", circle)
                stroke.Color = Color3.fromRGB(135,255,135)
                stroke.Thickness = 2

                local dot = Instance.new("Frame", circle)
                dot.Size = UDim2.new(1,-6,1,-6)
                dot.Position = UDim2.new(0,3,0,3)
                dot.BackgroundColor3 = Color3.fromRGB(135,255,135)
                dot.BackgroundTransparency = 1
                Instance.new("UICorner", dot).CornerRadius = UDim.new(0.5,0)

                local btn = Instance.new("TextButton", f)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Size = UDim2.new(1,0,1,0)

                local on = false
                local function set(v)
                    on = v and true or false
                    TS:Create(dot, TweenInfo.new(0.12), {BackgroundTransparency = on and 0 or 1}):Play()
                    task.spawn(callback, on)
                end

                btn.MouseButton1Click:Connect(function()
                    set(not on)
                end)

                local api = {}
                function api:UpdateToggle(newTitle, newDesc)
                    if newTitle then Title.Text = newTitle end
                    if newDesc then Desc.Text = newDesc end
                end
                function api:Set(v) set(v) end
                return api
            end

            function page:CreateBox(titleOrPlaceholder, iconId, callback)
                local placeholder = titleOrPlaceholder or "Input..."
                iconId = iconId or 0
                callback = callback or function() end

                local Holder = Instance.new("Frame")
                Holder.Name = "TextBox"
                Holder.BackgroundTransparency = 1
                Holder.Size = UDim2.new(1,0,0,36)
                Holder.Parent = Page

                local bar = Instance.new("Frame", Holder)
                bar.BackgroundColor3 = Color3.fromRGB(40,40,48)
                bar.Size = UDim2.new(1,0,1,0)
                bar.BorderSizePixel = 0
                Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

                local icon = Instance.new("ImageLabel", bar)
                icon.BackgroundTransparency = 1
                icon.Size = UDim2.fromOffset(18,18)
                icon.Position = UDim2.new(0,8,0,9)
                icon.Image = "rbxassetid://"..tostring(iconId)
                icon.ImageColor3 = Color3.fromRGB(135,255,135)

                local tb = Instance.new("TextBox", bar)
                tb.ClearTextOnFocus = false
                tb.BackgroundTransparency = 1
                tb.Font = Enum.Font.Gotham
                tb.TextSize = 12
                tb.TextXAlignment = Enum.TextXAlignment.Left
                tb.TextColor3 = Color3.new(1,1,1)
                tb.PlaceholderColor3 = Color3.fromRGB(215,215,215)
                tb.PlaceholderText = placeholder
                tb.Text = ""
                tb.Size = UDim2.new(1,-34,1,0)
                tb.Position = UDim2.new(0,30,0,0)

                tb.FocusLost:Connect(function(enter)
                    pcall(callback, tb.Text)
                end)

                local api = {}
                function api:UpdateBox(newTitle) tb.PlaceholderText = newTitle or tb.PlaceholderText end
                return api
            end

            function page:CreateSlider(name,min,max,callback)
                name = name or "Slider"
                min = tonumber(min) or 0
                max = tonumber(max) or 100
                callback = callback or function() end

                local f = Instance.new("Frame")
                f.Name = "Slider"
                f.BackgroundColor3 = Color3.fromRGB(40,40,48)
                f.Size = UDim2.new(1,0,0,50)
                Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
                f.Parent = Page

                local Title = Instance.new("TextLabel", f)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 12
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,4)
                Title.Size = UDim2.new(1,-8,0,18)
                Title.Text = name

                local track = Instance.new("Frame", f)
                track.BorderSizePixel = 0
                track.BackgroundColor3 = Color3.fromRGB(30,30,36)
                track.Size = UDim2.new(1,-16,0,3)
                track.Position = UDim2.new(0,8,0,32)

                local fill = Instance.new("Frame", track)
                fill.BorderSizePixel = 0
                fill.BackgroundColor3 = Color3.fromRGB(135,255,135)
                fill.Size = UDim2.new(0,0,1,0)

                local knob = Instance.new("TextButton", fill)
                knob.Text = ""
                knob.AutoButtonColor = false
                knob.Size = UDim2.fromOffset(10,10)
                knob.Position = UDim2.new(1,-5,0.5,-5)
                knob.BackgroundColor3 = Color3.fromRGB(135,255,135)
                Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5,0)

                local valBox = Instance.new("TextLabel", f)
                valBox.BackgroundTransparency = 0.83
                valBox.BackgroundColor3 = Color3.new(0,0,0)
                valBox.TextColor3 = Color3.fromRGB(227,225,228)
                valBox.Font = Enum.Font.Gotham
                valBox.TextSize = 12
                valBox.Size = UDim2.fromOffset(48,18)
                valBox.Position = UDim2.new(1,-56,0,4)
                valBox.Text = tostring(min)

                local dragging = false
                local function setFromX(x)
                    local alpha = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(alpha,0,1,0)
                    local value = math.floor((min + (max - min)*alpha) * 100 + 0.5)/100
                    valBox.Text = tostring(value)
                    pcall(callback, value)
                end
                knob.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        rippleOn(knob, Color3.fromRGB(135,255,135))
                    end
                end)
                knob.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        setFromX(i.Position.X)
                    end
                end)
                track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        setFromX(i.Position.X)
                    end
                end)
                return {}
            end

            function page:CreateBind(name, defaultKey, callback)
                name = name or "Keybind"
                defaultKey = defaultKey or "F"
                callback = callback or function() end

                local f = Instance.new("Frame")
                f.Name = "Keybind"
                f.BackgroundTransparency = 1
                f.Size = UDim2.new(1,0,0,32)
                f.Parent = Page

                local bar = Instance.new("Frame", f)
                bar.BackgroundColor3 = Color3.fromRGB(40,40,48)
                bar.BorderSizePixel = 0
                bar.Size = UDim2.new(1,0,1,0)
                Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

                local Title = Instance.new("TextLabel", bar)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 12
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,0)
                Title.Size = UDim2.new(1,-90,1,0)
                Title.Text = name

                local btn = Instance.new("TextButton", bar)
                btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
                btn.BackgroundTransparency = 0.83
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.TextColor3 = Color3.fromRGB(227,225,228)
                btn.Size = UDim2.fromOffset(80,22)
                btn.Position = UDim2.new(1,-86,0.5,-11)
                btn.Text = defaultKey
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

                local current = defaultKey
                local listening = false

                btn.MouseButton1Click:Connect(function()
                    listening = true
                    btn.Text = "..."
                end)

                UIS.InputBegan:Connect(function(i,gp)
                    if gp then return end
                    if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                        current = i.KeyCode.Name
                        btn.Text = current
                        listening = false
                        rippleOn(btn, Color3.fromRGB(135,255,135))
                        pcall(callback, current)
                    elseif i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == current then
                        rippleOn(btn, Color3.fromRGB(135,255,135))
                        pcall(callback, current)
                    end
                end)

                local api = {}
                function api:UpdateBind(newTitle) Title.Text = newTitle or Title.Text end
                return api
            end

            ----------------------------------------------------------------
            -- DROPDOWN (baru)
            ----------------------------------------------------------------
            function page:CreateDropdown(title, options, callback)
                title = title or "Dropdown"
                options = typeof(options)=="table" and options or {}
                callback = callback or function() end

                local holder = Instance.new("Frame")
                holder.Name = "Dropdown"
                holder.BackgroundColor3 = Color3.fromRGB(40,40,48)
                holder.Size = UDim2.new(1,0,0,40)
                holder.Parent = Page
                Instance.new("UICorner", holder).CornerRadius = UDim.new(0,6)

                local Title = Instance.new("TextLabel", holder)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 12
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,2)
                Title.Size = UDim2.new(1,-40,0,18)
                Title.Text = title

                local current = Instance.new("TextLabel", holder)
                current.BackgroundTransparency = 1
                current.Font = Enum.Font.Gotham
                current.TextSize = 12
                current.TextColor3 = Color3.fromRGB(200,200,200)
                current.TextXAlignment = Enum.TextXAlignment.Left
                current.Position = UDim2.new(0,8,0,20)
                current.Size = UDim2.new(1,-40,0,18)
                current.Text = "-"

                local openBtn = Instance.new("TextButton", holder)
                openBtn.BackgroundTransparency = 1
                openBtn.Text = ""
                openBtn.Size = UDim2.new(1,0,1,0)

                local listFrame = Instance.new("Frame")
                listFrame.Name = "List"
                listFrame.BackgroundColor3 = Color3.fromRGB(30,30,36)
                listFrame.Visible = false
                listFrame.Parent = holder
                listFrame.Position = UDim2.new(0,0,1,2)
                listFrame.Size = UDim2.new(1,0,0,140)
                Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,6)

                local Search = Instance.new("TextBox", listFrame)
                Search.BackgroundTransparency = 1
                Search.Font = Enum.Font.Gotham
                Search.TextSize = 12
                Search.TextColor3 = Color3.new(1,1,1)
                Search.PlaceholderColor3 = Color3.fromRGB(215,215,215)
                Search.PlaceholderText = "Search..."
                Search.Text = ""
                Search.Size = UDim2.new(1,-12,0,20)
                Search.Position = UDim2.new(0,6,0,6)

                local scroll = Instance.new("ScrollingFrame", listFrame)
                scroll.Active = true
                scroll.BackgroundTransparency = 1
                scroll.Size = UDim2.new(1,-12,1,-36)
                scroll.Position = UDim2.new(0,6,0,30)
                scroll.ScrollBarThickness = 6
                scroll.ScrollBarImageColor3 = Color3.fromRGB(135,255,135)
                scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                scroll.CanvasSize = UDim2.new(0,0,0,0)

                local pad = Instance.new("UIPadding", scroll)
                pad.PaddingTop = UDim.new(0,4)
                pad.PaddingBottom = UDim.new(0,4)

                local list = Instance.new("UIListLayout", scroll)
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Padding = UDim.new(0,4)

                local optButtons = {}

                local function rebuild(listData, filter)
                    for _,b in ipairs(optButtons) do b:Destroy() end
                    table.clear(optButtons)
                    local q = string.lower(filter or "")
                    for _,name in ipairs(listData) do
                        if q == "" or string.find(string.lower(name), q, 1, true) then
                            local b = Instance.new("TextButton")
                            b.BackgroundColor3 = Color3.fromRGB(40,40,48)
                            b.TextColor3 = Color3.new(1,1,1)
                            b.Font = Enum.Font.Gotham
                            b.TextSize = 12
                            b.TextXAlignment = Enum.TextXAlignment.Left
                            b.Text = name
                            b.Size = UDim2.new(1, -6, 0, 26)
                            b.Parent = scroll
                            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
                            b.MouseButton1Click:Connect(function()
                                current.Text = name
                                listFrame.Visible = false
                                rippleOn(b, Color3.fromRGB(135,255,135))
                                task.spawn(callback, name)
                            end)
                            table.insert(optButtons, b)
                        end
                    end
                end

                local optionsList = {}
                for _,v in ipairs(options) do table.insert(optionsList, tostring(v)) end
                table.sort(optionsList)
                rebuild(optionsList, "")

                openBtn.MouseButton1Click:Connect(function()
                    listFrame.Visible = not listFrame.Visible
                    rippleOn(openBtn, Color3.fromRGB(135,255,135))
                end)

                Search:GetPropertyChangedSignal("Text"):Connect(function()
                    rebuild(optionsList, Search.Text)
                end)

                local api = {}
                function api:UpdateDropdown(newOptions)
                    optionsList = {}
                    if typeof(newOptions)=="table" then
                        for _,v in ipairs(newOptions) do table.insert(optionsList, tostring(v)) end
                    end
                    table.sort(optionsList)
                    rebuild(optionsList, Search.Text)
                end
                return api
            end

            return page
        end

        return setmetatable({}, {
            __index = function(_, k)
                if k == "CreateFrame" then
                    return tabObj.CreateFrame
                end
            end
        })
    end

    return setmetatable({}, {
        __index = function(_, k)
            if k == "CreateTab" then
                return win.CreateTab
            end
        end
    })
end

return library
