-- Vanis UI Library (Compact + Dropdown + Overlay Toggle)
-- - Compact sizing (480x320), small fonts, slim controls
-- - Safe auto-size pages (no clipping on Android)
-- - Dropdown component with UpdateDropdown
-- - Overlay ImageButton (same icon as window) to hide/show menu; draggable; stays visible

if not game:IsLoaded() then game.Loaded:Wait() end

local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Optional instance protection (no-op if unavailable)
local ProtectInstance = function(_) end
local request = request or http_request or (identifyexecutor and identifyexecutor() == "Synapse X" and syn and syn.request) or (http and http.request)
pcall(function()
    if request then
        local body = request({Url="https://raw.githubusercontent.com/cypherdh/Script-Library/main/InstanceProtect",Method="GET"}).Body
        local ok,fn = pcall(loadstring, body)
        if ok and fn then fn() end
        ProtectInstance = getfenv().ProtectInstance or ProtectInstance
    end
end)

-- Utils
local function ripple(btn, color)
    local ms = LP:GetMouse()
    local s = Instance.new("ImageLabel")
    s.BackgroundTransparency = 1
    s.Image = "http://www.roblox.com/asset/?id=4560909609"
    s.ImageTransparency = 0.6
    s.ImageColor3 = color or Color3.fromRGB(135,255,135)
    s.Size = UDim2.fromOffset(0,0)
    s.ZIndex = (btn.ZIndex or 1) + 1
    s.Parent = btn
    s.Position = UDim2.fromOffset(ms.X - btn.AbsolutePosition.X, ms.Y - btn.AbsolutePosition.Y)
    local len = 0.3
    local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.35
    s:TweenSizeAndPosition(UDim2.fromOffset(size,size), UDim2.new(0.5,-size/2,0.5,-size/2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, len, true)
    task.spawn(function()
        for i=1,10 do
            s.ImageTransparency = s.ImageTransparency + 0.05
            task.wait(len/12)
        end
        s:Destroy()
    end)
end

local function makeDraggable(Frame, speed)
    local dragging, start, origin
    Frame.InputBegan:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch)
            and UIS:GetFocusedTextBox() == nil then
            dragging = true; start = i.Position; origin = Frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            TS:Create(Frame, TweenInfo.new(speed or 0.12), {
                Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
            }):Play()
        end
    end)
end

-- Library
local library = {}

function library:CreateWindow(name, version, iconId)
    name = name or "Name"
    version = version or "Version"
    iconId = iconId or 0

    -- Main SG + Window (COMPACT)
    local sg = Instance.new("ScreenGui")
    ProtectInstance(sg)
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 10^6
    sg.Name = "VanisUI_"..tostring(math.random(1000,9999))
    sg.Parent = (gethui and gethui()) or CoreGui

    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.fromOffset(480, 320) -- compact
    Window.Position = UDim2.new(0.5, -240, 0.5, -160)
    Window.BackgroundColor3 = Color3.fromRGB(49,49,59)
    Window.Parent = sg
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0,6)
    makeDraggable(Window, 0.1)

    -- Titlebar (COMPACT)
    local TitleBar = Instance.new("Frame")
    TitleBar.BackgroundTransparency = 1
    TitleBar.Size = UDim2.new(1,0,0,28)
    TitleBar.Parent = Window

    local Icon = Instance.new("ImageLabel")
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.fromOffset(16,16)
    Icon.Position = UDim2.new(0,8,0,6)
    Icon.Image = "rbxassetid://"..tostring(iconId)
    Icon.ImageColor3 = Color3.fromRGB(135,255,135)
    Icon.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 11
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Text = string.format("%s | %s", name, version)
    Title.Size = UDim2.new(1,-38,1,0)
    Title.Position = UDim2.new(0,30,0,0)
    Title.Parent = TitleBar

    local Under = Instance.new("Frame")
    Under.BorderSizePixel = 0
    Under.BackgroundColor3 = Color3.fromRGB(135,255,135)
    Under.Size = UDim2.new(1,0,0,1)
    Under.Position = UDim2.new(0,0,1,0)
    Under.Parent = TitleBar

    -- Tabs (COMPACT)
    local Tabs = Instance.new("Frame")
    Tabs.Name = "Tabs"
    Tabs.Size = UDim2.new(0,120,1,-34)
    Tabs.Position = UDim2.new(0,6,0,34)
    Tabs.BackgroundColor3 = Color3.fromRGB(40,40,48)
    Tabs.Parent = Window
    Instance.new("UICorner", Tabs).CornerRadius = UDim.new(0,6)

    local tl = Instance.new("UIListLayout", Tabs)
    tl.SortOrder = Enum.SortOrder.LayoutOrder
    tl.Padding = UDim.new(0,4)

    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Font = Enum.Font.GothamBold
    header.TextSize = 11
    header.TextColor3 = Color3.new(1,1,1)
    header.Text = "Sections"
    header.Size = UDim2.new(1,-10,0,20)
    header.Position = UDim2.new(0,6,0,6)
    header.Parent = Tabs

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0,2,0,16)
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

    -- OVERLAY SG: Image button with same icon; toggles Window.Visible
    local overlaySG = Instance.new("ScreenGui")
    ProtectInstance(overlaySG)
    overlaySG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    overlaySG.DisplayOrder = 10^6 + 1
    overlaySG.Name = "VanisUI_Overlay_"..tostring(math.random(1000,9999))
    overlaySG.Parent = (gethui and gethui()) or CoreGui

    local overlayBtn = Instance.new("ImageButton")
    overlayBtn.Name = "OverlayToggle"
    overlayBtn.Size = UDim2.fromOffset(36,36) -- compact round button
    overlayBtn.Position = UDim2.new(0, 10, 0.5, -18)
    overlayBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    overlayBtn.AutoButtonColor = true
    overlayBtn.Image = "rbxassetid://"..tostring(iconId) -- same image
    overlayBtn.ImageColor3 = Color3.fromRGB(135,255,135)
    overlayBtn.Parent = overlaySG
    Instance.new("UICorner", overlayBtn).CornerRadius = UDim.new(1,0)
    local st = Instance.new("UIStroke", overlayBtn)
    st.Thickness = 2
    st.Color = Color3.fromRGB(80,140,120)
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    makeDraggable(overlayBtn, 0.08)

    local shown = true
    local function toggleWindow()
        shown = not shown
        Window.Visible = shown
        ripple(overlayBtn, Color3.fromRGB(135,255,135))
    end
    overlayBtn.MouseButton1Click:Connect(toggleWindow)

    -- Window API
    local win = {}

    function win:CreateTab(tabName)
        tabName = tabName or "Tab"
        local tabObj = {}

        function tabObj:CreateFrame(pageName)
            pageName = pageName or "Page 1"

            local Page = Instance.new("ScrollingFrame")
            Page.Name = "Page"
            Page.Active = true
            Page.BackgroundColor3 = Color3.fromRGB(40,40,48)
            Page.BorderSizePixel = 0
            Page.Position = UDim2.new(0, 128, 0, 34)
            Page.Size = UDim2.new(1, -134, 1, -40)
            Page.ScrollBarThickness = 5
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
            list.Padding = UDim.new(0,4)

            -- Page Button
            local PageButton = Instance.new("TextButton")
            PageButton.Name = "PageButton"
            PageButton.BackgroundTransparency = 1
            PageButton.TextXAlignment = Enum.TextXAlignment.Left
            PageButton.Font = Enum.Font.Gotham
            PageButton.TextSize = 11
            PageButton.TextColor3 = Color3.new(1,1,1)
            PageButton.TextTransparency = 0.45
            PageButton.Text = pageName
            PageButton.Size = UDim2.new(1,-10,0,18)
            PageButton.Parent = Tabs

            PageButton.MouseButton1Click:Connect(function()
                Indicator.Visible = true
                Indicator.Position = UDim2.new(0,-2,0,PageButton.AbsolutePosition.Y - Tabs.AbsolutePosition.Y + (PageButton.AbsoluteSize.Y-Indicator.AbsoluteSize.Y)/2)
                Indicator.Parent = PageButton
                for _,v in ipairs(Tabs:GetChildren()) do
                    if v:IsA("TextButton") then TS:Create(v, TweenInfo.new(0.15), {TextTransparency=0.45}):Play() end
                end
                TS:Create(PageButton, TweenInfo.new(0.15), {TextTransparency=0}):Play()
                hideAllPages()
                Page.Visible = true
            end)

            -- Page API (controls)
            local page = {}

            function page:CreateLabel(text)
                text = text or "Label"
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 11
                Label.TextColor3 = Color3.new(1,1,1)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Size = UDim2.new(1,-4,0,20)
                Label.Text = text
                Label.Parent = Page
                local api = {}
                function api:UpdateLabel(t) Label.Text = t end
                return api
            end

            function page:CreateButton(title, desc, callback)
                title = title or "Button"; desc = desc or "Description"; callback = callback or function() end
                local f = Instance.new("Frame")
                f.Name = "Button"
                f.BackgroundColor3 = Color3.fromRGB(40,40,48)
                f.Size = UDim2.new(1,0,0,36)
                Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
                f.Parent = Page

                local Title = Instance.new("TextLabel", f)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 11
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,2)
                Title.Size = UDim2.new(1,-8,0,16)
                Title.Text = title

                local Desc = Instance.new("TextLabel", f)
                Desc.BackgroundTransparency = 1
                Desc.Font = Enum.Font.Gotham
                Desc.TextSize = 10
                Desc.TextColor3 = Color3.fromRGB(180,180,180)
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Position = UDim2.new(0,8,0,18)
                Desc.Size = UDim2.new(1,-8,0,14)
                Desc.Text = desc

                local btn = Instance.new("TextButton", f)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Size = UDim2.new(1,0,1,0)
                btn.MouseButton1Click:Connect(function()
                    ripple(btn, Color3.fromRGB(135,255,135))
                    task.spawn(callback)
                end)
                local api = {}
                function api:UpdateButton(newTitle) Title.Text = newTitle or Title.Text end
                return api
            end

            function page:CreateToggle(title, desc, callback)
                title = title or "Toggle"; desc = desc or "Description"; callback = callback or function() end
                local f = Instance.new("Frame")
                f.Name = "Toggle"
                f.BackgroundColor3 = Color3.fromRGB(40,40,48)
                f.Size = UDim2.new(1,0,0,36)
                Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
                f.Parent = Page

                local Title = Instance.new("TextLabel", f)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 11
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,2)
                Title.Size = UDim2.new(1,-40,0,16)
                Title.Text = title

                local Desc = Instance.new("TextLabel", f)
                Desc.BackgroundTransparency = 1
                Desc.Font = Enum.Font.Gotham
                Desc.TextSize = 10
                Desc.TextColor3 = Color3.fromRGB(180,180,180)
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Position = UDim2.new(0,8,0,18)
                Desc.Size = UDim2.new(1,-40,0,14)
                Desc.Text = desc

                local circle = Instance.new("Frame", f)
                circle.Size = UDim2.fromOffset(18,18)
                circle.Position = UDim2.new(1,-26,0,9)
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
                    TS:Create(dot, TweenInfo.new(0.1), {BackgroundTransparency = on and 0 or 1}):Play()
                    task.spawn(callback, on)
                end
                btn.MouseButton1Click:Connect(function() set(not on) end)

                local api = {}
                function api:UpdateToggle(newTitle, newDesc)
                    if newTitle then Title.Text = newTitle end
                    if newDesc then Desc.Text = newDesc end
                end
                function api:Set(v) set(v) end
                return api
            end

            function page:CreateBox(placeholder, icon, callback)
                placeholder = placeholder or "Input..."
                icon = icon or 0
                callback = callback or function() end

                local Holder = Instance.new("Frame")
                Holder.Name = "TextBox"
                Holder.BackgroundTransparency = 1
                Holder.Size = UDim2.new(1,0,0,32)
                Holder.Parent = Page

                local Bar = Instance.new("Frame", Holder)
                Bar.BackgroundColor3 = Color3.fromRGB(40,40,48)
                Bar.Size = UDim2.new(1,0,1,0)
                Bar.BorderSizePixel = 0
                Instance.new("UICorner", Bar).CornerRadius = UDim.new(0,6)

                local I = Instance.new("ImageLabel", Bar)
                I.BackgroundTransparency = 1
                I.Size = UDim2.fromOffset(16,16)
                I.Position = UDim2.new(0,8,0,8)
                I.Image = "rbxassetid://"..tostring(icon)
                I.ImageColor3 = Color3.fromRGB(135,255,135)

                local TB = Instance.new("TextBox", Bar)
                TB.ClearTextOnFocus = false
                TB.BackgroundTransparency = 1
                TB.Font = Enum.Font.Gotham
                TB.TextSize = 11
                TB.TextXAlignment = Enum.TextXAlignment.Left
                TB.TextColor3 = Color3.new(1,1,1)
                TB.PlaceholderColor3 = Color3.fromRGB(215,215,215)
                TB.PlaceholderText = placeholder
                TB.Text = ""
                TB.Size = UDim2.new(1,-30,1,0)
                TB.Position = UDim2.new(0,28,0,0)

                TB.FocusLost:Connect(function()
                    pcall(callback, TB.Text)
                end)

                local api = {}
                function api:UpdateBox(newTitle) TB.PlaceholderText = newTitle or TB.PlaceholderText end
                return api
            end

            function page:CreateSlider(name,min,max,callback)
                name = name or "Slider"; min = tonumber(min) or 0; max = tonumber(max) or 100
                callback = callback or function() end

                local f = Instance.new("Frame")
                f.Name = "Slider"
                f.BackgroundColor3 = Color3.fromRGB(40,40,48)
                f.Size = UDim2.new(1,0,0,42)
                Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
                f.Parent = Page

                local Title = Instance.new("TextLabel", f)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 11
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,2)
                Title.Size = UDim2.new(1,-8,0,16)
                Title.Text = name

                local track = Instance.new("Frame", f)
                track.BorderSizePixel = 0
                track.BackgroundColor3 = Color3.fromRGB(30,30,36)
                track.Size = UDim2.new(1,-16,0,2)
                track.Position = UDim2.new(0,8,0,28)

                local fill = Instance.new("Frame", track)
                fill.BorderSizePixel = 0
                fill.BackgroundColor3 = Color3.fromRGB(135,255,135)
                fill.Size = UDim2.new(0,0,1,0)

                local knob = Instance.new("TextButton", fill)
                knob.Text = ""
                knob.AutoButtonColor = false
                knob.Size = UDim2.fromOffset(9,9)
                knob.Position = UDim2.new(1,-4,0.5,-4)
                knob.BackgroundColor3 = Color3.fromRGB(135,255,135)
                Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5,0)

                local val = Instance.new("TextLabel", f)
                val.BackgroundTransparency = 0.83
                val.BackgroundColor3 = Color3.new(0,0,0)
                val.TextColor3 = Color3.fromRGB(227,225,228)
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
                knob.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; ripple(knob) end
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
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then setFromX(i.Position.X) end
                end)
                return {}
            end

            function page:CreateBind(name, defaultKey, callback)
                name = name or "Keybind"; defaultKey = defaultKey or "F"; callback = callback or function() end

                local f = Instance.new("Frame")
                f.Name = "Keybind"
                f.BackgroundTransparency = 1
                f.Size = UDim2.new(1,0,0,28)
                f.Parent = Page

                local bar = Instance.new("Frame", f)
                bar.BackgroundColor3 = Color3.fromRGB(40,40,48)
                bar.BorderSizePixel = 0
                bar.Size = UDim2.new(1,0,1,0)
                Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

                local Title = Instance.new("TextLabel", bar)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 11
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,0)
                Title.Size = UDim2.new(1,-86,1,0)
                Title.Text = name

                local btn = Instance.new("TextButton", bar)
                btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
                btn.BackgroundTransparency = 0.83
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 10
                btn.TextColor3 = Color3.fromRGB(227,225,228)
                btn.Size = UDim2.fromOffset(76,20)
                btn.Position = UDim2.new(1,-82,0.5,-10)
                btn.Text = defaultKey
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

                local current = defaultKey
                local listening = false
                btn.MouseButton1Click:Connect(function() listening = true; btn.Text = "..." end)
                UIS.InputBegan:Connect(function(i,gp)
                    if gp then return end
                    if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                        current = i.KeyCode.Name; btn.Text = current; listening = false; ripple(btn)
                        pcall(callback, current)
                    elseif i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == current then
                        ripple(btn); pcall(callback, current)
                    end
                end)

                local api = {}
                function api:UpdateBind(newTitle) Title.Text = newTitle or Title.Text end
                return api
            end

            -- DROPDOWN (with search + UpdateDropdown)
            function page:CreateDropdown(title, options, callback)
                title = title or "Dropdown"
                options = typeof(options)=="table" and options or {}
                callback = callback or function() end

                local holder = Instance.new("Frame")
                holder.Name = "Dropdown"
                holder.BackgroundColor3 = Color3.fromRGB(40,40,48)
                holder.Size = UDim2.new(1,0,0,36)
                holder.Parent = Page
                Instance.new("UICorner", holder).CornerRadius = UDim.new(0,6)

                local Title = Instance.new("TextLabel", holder)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamBold
                Title.TextSize = 11
                Title.TextColor3 = Color3.new(1,1,1)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Position = UDim2.new(0,8,0,2)
                Title.Size = UDim2.new(1,-40,0,16)
                Title.Text = title

                local current = Instance.new("TextLabel", holder)
                current.BackgroundTransparency = 1
                current.Font = Enum.Font.Gotham
                current.TextSize = 10
                current.TextColor3 = Color3.fromRGB(200,200,200)
                current.TextXAlignment = Enum.TextXAlignment.Left
                current.Position = UDim2.new(0,8,0,18)
                current.Size = UDim2.new(1,-40,0,14)
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
                listFrame.Size = UDim2.new(1,0,0,120)
                Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,6)

                local Search = Instance.new("TextBox", listFrame)
                Search.BackgroundTransparency = 1
                Search.Font = Enum.Font.Gotham
                Search.TextSize = 10
                Search.TextColor3 = Color3.new(1,1,1)
                Search.PlaceholderColor3 = Color3.fromRGB(215,215,215)
                Search.PlaceholderText = "Search..."
                Search.Text = ""
                Search.Size = UDim2.new(1,-10,0,18)
                Search.Position = UDim2.new(0,5,0,6)

                local scroll = Instance.new("ScrollingFrame", listFrame)
                scroll.Active = true
                scroll.BackgroundTransparency = 1
                scroll.Size = UDim2.new(1,-10,1,-30)
                scroll.Position = UDim2.new(0,5,0,26)
                scroll.ScrollBarThickness = 5
                scroll.ScrollBarImageColor3 = Color3.fromRGB(135,255,135)
                scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                scroll.CanvasSize = UDim2.new(0,0,0,0)

                local pad = Instance.new("UIPadding", scroll)
                pad.PaddingTop = UDim.new(0,4)
                pad.PaddingBottom = UDim.new(0,4)

                local list = Instance.new("UIListLayout", scroll)
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Padding = UDim.new(0,4)

                local buttons = {}
                local opts = {}
                for _,v in ipairs(options) do table.insert(opts, tostring(v)) end
                table.sort(opts)

                local function rebuild(filter)
                    for _,b in ipairs(buttons) do b:Destroy() end
                    table.clear(buttons)
                    local q = string.lower(filter or "")
                    for _,name in ipairs(opts) do
                        if q == "" or string.find(string.lower(name), q, 1, true) then
                            local b = Instance.new("TextButton")
                            b.BackgroundColor3 = Color3.fromRGB(40,40,48)
                            b.TextColor3 = Color3.new(1,1,1)
                            b.Font = Enum.Font.Gotham
                            b.TextSize = 10
                            b.TextXAlignment = Enum.TextXAlignment.Left
                            b.Text = name
                            b.Size = UDim2.new(1, -4, 0, 22)
                            b.Parent = scroll
                            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
                            b.MouseButton1Click:Connect(function()
                                current.Text = name
                                listFrame.Visible = false
                                ripple(b, Color3.fromRGB(135,255,135))
                                task.spawn(callback, name)
                            end)
                            table.insert(buttons, b)
                        end
                    end
                end
                rebuild("")

                openBtn.MouseButton1Click:Connect(function()
                    listFrame.Visible = not listFrame.Visible
                    ripple(openBtn, Color3.fromRGB(135,255,135))
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
                return api
            end

            return page
        end

        return setmetatable({}, { __index = function(_,k)
            if k=="CreateFrame" then return tabObj.CreateFrame end
        end})
    end

    -- Return window API
    return setmetatable({}, { __index = function(_,k)
        if k=="CreateTab" then return win.CreateTab end
    end})
end

return library
