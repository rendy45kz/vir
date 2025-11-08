if not game:IsLoaded() then game.Loaded:Wait() end

-- Vanis UI (Blue Accent, Auto-Size Fix, Overlay Toggle)
-- Catatan:
-- 1) Perbaikan utama: Section & SectionContainer sekarang auto-size (tidak lagi pakai akumulasi tinggi)
-- 2) Page (ScrollingFrame) pakai AutomaticCanvasSize.Y agar tidak memotong isi
-- 3) Tema aksen diganti ke biru; ubah ACCENT kalau ingin warna lain
-- 4) Tambah overlay tombol kecil (draggable) untuk hide/show window

local ACCENT = Color3.fromRGB(110, 175, 255)   -- warna aksen biru
local ACCENT_SOFT = Color3.fromRGB(110, 175, 255)
local ACCENT_TEXT = Color3.fromRGB(227, 229, 255)

-- extra credits to twink marie
local library = {}
local request = request or http_request or (identifyexecutor() == "Synapse X" and syn.request) or (http and http.request)
loadstring(request({Url="https://raw.githubusercontent.com/cypherdh/Script-Library/main/InstanceProtect",Method="GET"}).Body)()

local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")

function library:CreateWindow(name, version, icon)
	name    = name or "Name"
	version = version or "Version"
	icon    = icon or math.random()

	-- ========= roots =========
	local MyGui = Instance.new("ScreenGui")
	local Window = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local TitleBar = Instance.new("Frame")
	local Icon = Instance.new("ImageLabel")
	local MainTitle = Instance.new("TextLabel")
	local TitleUnderline = Instance.new("Frame")
	local UIGradient = Instance.new("UIGradient")
	local Bar = Instance.new("Frame")
	local Bar_2 = Instance.new("Frame")
	local Close = Instance.new("ImageButton")
	local Minimize = Instance.new("ImageButton")
	local _4pxShadow2px_2 = Instance.new("ImageLabel")

	-- ========= overlay toggle (draggable) =========
	local OverlaySG = Instance.new("ScreenGui")
	local OverlayBtn = Instance.new("ImageButton")
	do
		local rs = ""
		for i = 1, math.random(3,20) do rs = rs..string.char(math.random(97,122)) end
		MyGui.Name = rs
	end

	ProtectInstance(MyGui)
	ProtectInstance(Window)
	ProtectInstance(OverlaySG)
	ProtectInstance(OverlayBtn)

	-- ScreenGui mount
	MyGui.Parent = cloneref(game:GetService("CoreGui"))
	MyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	OverlaySG.Parent = MyGui
	OverlaySG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- ========= window =========
	Window.Name = "Window"
	Window.Parent = MyGui
	Window.BackgroundColor3 = Color3.fromRGB(49, 49, 59)
	Window.Position = UDim2.new(0.5, -300, 0.6, -200)
	Window.Size = UDim2.new(0, 0, 0, 0)
	Window.ClipsDescendants = false -- penting: jangan clip, agar dropdown/isi tak kepotong

	UICorner.CornerRadius = UDim.new(0, 4)
	UICorner.Parent = Window

	TitleBar.Name = "TitleBar"
	TitleBar.Parent = Window
	TitleBar.BackgroundTransparency = 1
	TitleBar.Size = UDim2.new(1, 0, 0, 30)

	Icon.Name = "Icon"
	Icon.Parent = TitleBar
	Icon.BackgroundTransparency = 1
	Icon.Position = UDim2.new(0, 6, 0, 6)
	Icon.Size = UDim2.new(0, 18, 0, 18)
	Icon.Image = "rbxassetid://"..icon
	Icon.ImageColor3 = ACCENT

	MainTitle.Name = "Title"
	MainTitle.Parent = TitleBar
	MainTitle.BackgroundTransparency = 1
	MainTitle.Position = UDim2.new(0, 30, 0, 1)
	MainTitle.Size = UDim2.new(1, -30, 1, 0)
	MainTitle.Font = Enum.Font.Gotham
	MainTitle.Text = ("%s | %s"):format(name, version)
	MainTitle.TextColor3 = Color3.fromRGB(255,255,255)
	MainTitle.TextSize = 12
	MainTitle.TextXAlignment = Enum.TextXAlignment.Left

	TitleUnderline.Name = "TitleUnderline"
	TitleUnderline.Parent = TitleBar
	TitleUnderline.BackgroundColor3 = ACCENT
	TitleUnderline.BorderSizePixel = 0
	TitleUnderline.Position = UDim2.new(0, 0, 1, 0)
	TitleUnderline.Size = UDim2.new(1, 0, 0, 1)
	UIGradient.Parent = TitleUnderline

	Bar.Name = "Bar"
	Bar.Parent = TitleUnderline
	Bar.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Bar.BackgroundTransparency = 0.75
	Bar.BorderSizePixel = 0
	Bar.Position = UDim2.new(0, 6, 0, 0)
	Bar.Size = UDim2.new(0, 18, 1, 0)

	Bar_2.Name = "Bar"
	Bar_2.Parent = TitleUnderline
	Bar_2.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Bar_2.BackgroundTransparency = 0.75
	Bar_2.BorderSizePixel = 0
	Bar_2.Position = UDim2.new(1, -24, 0, 0)
	Bar_2.Size = UDim2.new(0, 18, 1, 0)

	Close.Name = "Close"
	Close.Parent = TitleBar
	Close.BackgroundTransparency = 1
	Close.Position = UDim2.new(0.953333378, 0, 0.0666666627, 0)
	Close.Size = UDim2.new(0, 25, 0, 25)
	Close.ZIndex = 2
	Close.Image = "rbxassetid://3926305904"
	Close.ImageRectOffset = Vector2.new(284, 4)
	Close.ImageRectSize = Vector2.new(24, 24)

	Minimize.Name = "Minimize"
	Minimize.Parent = TitleBar
	Minimize.BackgroundTransparency = 1
	Minimize.Position = UDim2.new(0.953, -24, -0.2, 6)
	Minimize.Size = UDim2.new(0, 26, 0, 30)
	Minimize.Image = "http://www.roblox.com/asset/?id=6035067836"

	_4pxShadow2px_2.Name = "4pxShadow(2px)"
	_4pxShadow2px_2.Parent = Window
	_4pxShadow2px_2.BackgroundTransparency = 1
	_4pxShadow2px_2.Position = UDim2.new(0, -15, 0, -15)
	_4pxShadow2px_2.Size = UDim2.new(1, 30, 1, 30)
	_4pxShadow2px_2.Image = "http://www.roblox.com/asset/?id=5761504593"
	_4pxShadow2px_2.ImageColor3 = Color3.fromRGB(49, 49, 59)
	_4pxShadow2px_2.ImageTransparency = 0.3
	_4pxShadow2px_2.ScaleType = Enum.ScaleType.Slice
	_4pxShadow2px_2.SliceCenter = Rect.new(17, 17, 283, 283)

	-- ========= overlay toggle button =========
	OverlayBtn.Parent = OverlaySG
	OverlayBtn.Name = "OverlayToggle"
	OverlayBtn.BackgroundColor3 = Color3.fromRGB(32,34,46)
	OverlayBtn.AutoButtonColor = true
	OverlayBtn.Size = UDim2.fromOffset(40, 40)
	OverlayBtn.Position = UDim2.new(0, 12, 0, 120)
	OverlayBtn.Image = "rbxassetid://10045753138" -- ikon default (search). Ganti ke ikon Vanis-mu jika ada.
	OverlayBtn.ImageColor3 = ACCENT
	local overlayCorner = Instance.new("UICorner", OverlayBtn)
	overlayCorner.CornerRadius = UDim.new(1,0)
	local overlayStroke = Instance.new("UIStroke", OverlayBtn)
	overlayStroke.Thickness = 1
	overlayStroke.Color = Color3.fromRGB(255,255,255)
	overlayStroke.Transparency = 0.85

	-- drag overlay
	do
		local dragging, dragStart, startPos
		local function update(input)
			local delta = input.Position - dragStart
			OverlayBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
		OverlayBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = OverlayBtn.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
	end
	local isHidden = false
	OverlayBtn.MouseButton1Click:Connect(function()
		isHidden = not isHidden
		Window.Visible = not isHidden
		TS:Create(OverlayBtn, TweenInfo.new(0.15), {ImageColor3 = isHidden and Color3.fromRGB(200,200,200) or ACCENT}):Play()
	end)

	-- ========= close/minimize =========
	Close.MouseButton1Click:Connect(function()
		TS:Create(Window, TweenInfo.new(0.5), {Size = UDim2.new(0, 600, 0, 0)}):Play()
		repeat task.wait() until Window.Size == UDim2.new(0, 600, 0, 0)
		task.wait(0.1)
		TS:Create(Window, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 0, 0)}):Play()
		repeat task.wait() until Window.Size == UDim2.new(0, 0, 0, 0)
		MyGui:Destroy()
	end)

	local MinimizeGui = false
	Minimize.MouseButton1Click:Connect(function()
		if not MinimizeGui then
			MinimizeGui = true
			if Window.Size == UDim2.new(0, 600,0, 400) then
				TS:Create(Window, TweenInfo.new(0.25), {Size = UDim2.new(0, 600,0, 32)}):Play()
			end
		else
			MinimizeGui = false
			if Window.Size == UDim2.new(0, 600,0, 32) then
				TS:Create(Window, TweenInfo.new(0.25), {Size = UDim2.new(0, 600,0, 400)}):Play()
			end
		end
	end)

	-- ========= drag window =========
	local function dragify(Frame)
		local dragToggle, dragInput, dragStart, startPos
		local function updateInput(input)
			local Delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
			TS:Create(Frame, TweenInfo.new(0.25), {Position = Position}):Play()
		end
		Frame.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UIS:GetFocusedTextBox() == nil then
				dragToggle = true
				dragStart = input.Position
				startPos = Frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
				end)
			end
		end)
		Frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
		end)
		UIS.InputChanged:Connect(function(input)
			if input == dragInput and dragToggle then updateInput(input) end
		end)
	end
	dragify(Window)

	-- anim buka
	TS:Create(Window, TweenInfo.new(0.5), {Size = UDim2.new(0, 600, 0, 0)}):Play()
	repeat task.wait() until Window.Size == UDim2.new(0, 600, 0, 0)
	task.wait(0.1)
	TS:Create(Window, TweenInfo.new(0.5), {Size = UDim2.new(0, 600, 0, 400)}):Play()

	-- ========= tabs container =========
	local tabs = {}

	function tabs:CreateTab(name)
		name = name or "Section 1"

		local Tabs = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local SectionLabel = Instance.new("TextLabel")
		local UIListLayout = Instance.new("UIListLayout")
		local Indicator = Instance.new("Frame")

		Tabs.Name = "Tabs"
		Tabs.Parent = Window
		Tabs.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		Tabs.Position = UDim2.new(0, 5, 0, 36)
		Tabs.Size = UDim2.new(0, 140, 1, -41)

		UICorner_2.CornerRadius = UDim.new(0, 4)
		UICorner_2.Parent = Tabs

		SectionLabel.Name = "SectionLabel"
		SectionLabel.Parent = Tabs
		SectionLabel.BackgroundTransparency = 1
		SectionLabel.Position = UDim2.new(0, 7, 0, 0)
		SectionLabel.Size = UDim2.new(1, -7, 0, 30)
		SectionLabel.Font = Enum.Font.GothamBlack
		SectionLabel.Text = name
		SectionLabel.TextColor3 = Color3.fromRGB(255,255,255)
		SectionLabel.TextSize = 12
		SectionLabel.TextXAlignment = Enum.TextXAlignment.Left

		UIListLayout.Parent = Tabs
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		Indicator.Name = "Indicator"
		Indicator.Parent = Tabs
		Indicator.BackgroundColor3 = ACCENT
		Indicator.BorderSizePixel = 0
		Indicator.BackgroundTransparency = 1
		Indicator.Position = UDim2.new(0, -14, 0, 4)
		Indicator.Size = UDim2.new(0, 2, 1, -8)
		Indicator.Visible = false

		local mytabbuttons = {}

		function mytabbuttons:CreateFrame(pagename)
			pagename = pagename or "Page 1"

			-- ========= Page (scrolling) =========
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
			local _4pxShadow2px = Instance.new("ImageLabel")
			local UIPadding_2 = Instance.new("UIPadding")
			local UIListLayout_3 = Instance.new("UIListLayout")
			local UICorner_8 = Instance.new("UICorner")

			Page.Name = "Page"
			Page.Parent = Window
			Page.Active = true
			Page.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
			Page.BorderSizePixel = 0
			Page.Position = UDim2.new(0, 150, 0, 36)
			Page.Size = UDim2.new(1, -155, 1, -41)
			Page.ScrollBarThickness = 5
			Page.ScrollBarImageColor3 = ACCENT
			Page.AutomaticCanvasSize = Enum.AutomaticSize.Y   -- FIX penting
			Page.CanvasSize = UDim2.new(0,0,0,0)
			Page.Visible = false

			UICorner_3.CornerRadius = UDim.new(0, 4)
			UICorner_3.Parent = Page

			UIListLayout_2.Parent = Page
			UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_2.Padding = UDim.new(0, 4)

			UIPadding.Parent = Page
			UIPadding.PaddingBottom = UDim.new(0, 4)
			UIPadding.PaddingLeft = UDim.new(0, 4)
			UIPadding.PaddingRight = UDim.new(0, 4)
			UIPadding.PaddingTop = UDim.new(0, 4)

			-- search bar
			SearchBar.Name = "SearchBar"
			SearchBar.Parent = Page
			SearchBar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
			SearchBar.Size = UDim2.new(1, 0, 0, 30)

			UICorner_4.CornerRadius = UDim.new(0, 4)
			UICorner_4.Parent = SearchBar

			SearchIcon.Name = "SearchIcon"
			SearchIcon.Parent = SearchBar
			SearchIcon.BackgroundTransparency = 1
			SearchIcon.Position = UDim2.new(0, 6, 0, 6)
			SearchIcon.Size = UDim2.new(0, 18, 0, 18)
			SearchIcon.Image = "rbxassetid://10045418551"
			SearchIcon.ImageColor3 = ACCENT

			Bar_3.Name = "Bar"
			Bar_3.Parent = SearchBar
			Bar_3.BackgroundColor3 = ACCENT
			Bar_3.Position = UDim2.new(0, 30, 0, 10)
			Bar_3.Size = UDim2.new(0, 1, 1, -20)

			SearchBox.Name = "SearchBox"
			SearchBox.Parent = SearchBar
			SearchBox.BackgroundTransparency = 1
			SearchBox.Position = UDim2.new(0, 40, 0, 1)
			SearchBox.Size = UDim2.new(1, -40, 1, 0)
			SearchBox.Font = Enum.Font.Gotham
			SearchBox.PlaceholderColor3 = ACCENT_TEXT
			SearchBox.PlaceholderText = "Search Here"
			SearchBox.Text = ""
			SearchBox.TextColor3 = ACCENT_TEXT
			SearchBox.TextSize = 12
			SearchBox.TextXAlignment = Enum.TextXAlignment.Left

			-- section (auto size)
			Section.Name = "Section"
			Section.Parent = Page
			Section.BackgroundTransparency = 1
			Section.BorderSizePixel = 0
			Section.Position = UDim2.new(0,0,0,0)
			Section.Size = UDim2.new(1, 0, 0, 0)
			Section.AutomaticSize = Enum.AutomaticSize.Y   -- FIX penting

			UICorner_5.CornerRadius = UDim.new(0, 4)
			UICorner_5.Parent = Section

			SectionContainer.Name = "SectionContainer"
			SectionContainer.Parent = Section
			SectionContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
			SectionContainer.BorderSizePixel = 0
			SectionContainer.ClipsDescendants = false     -- FIX penting
			SectionContainer.Position = UDim2.new(0, 0, 0, 0)
			SectionContainer.Size = UDim2.new(1, 0, 0, 0)
			SectionContainer.AutomaticSize = Enum.AutomaticSize.Y -- FIX penting
			SectionContainer.ZIndex = 2

			Header.Name = "Header"
			Header.Parent = Section
			Header.BackgroundColor3 = ACCENT
			Header.BorderSizePixel = 0
			Header.Size = UDim2.new(1, 0, 0, 8)

			UICorner_23.CornerRadius = UDim.new(0, 4)
			UICorner_23.Parent = Header

			UIGradient_2.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0.00, 0.75),
				NumberSequenceKeypoint.new(0.50, 0.00),
				NumberSequenceKeypoint.new(1.00, 0.75)
			}
			UIGradient_2.Parent = Header

			UIPadding_2.Parent = SectionContainer
			UIPadding_2.PaddingBottom = UDim.new(0, 4)
			UIPadding_2.PaddingLeft   = UDim.new(0, 4)
			UIPadding_2.PaddingRight  = UDim.new(0, 4)
			UIPadding_2.PaddingTop    = UDim.new(0, 4)

			UIListLayout_3.Parent = SectionContainer
			UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_3.Padding = UDim.new(0, 4)
			UIListLayout_3.FillDirection = Enum.FillDirection.Vertical

			UICorner_8.CornerRadius = UDim.new(0, 4)
			UICorner_8.Parent = SectionContainer

			-- Search logic
			local function UpdateResults()
				local search = string.lower(SearchBox.Text)
				for _, v in pairs(SectionContainer:GetChildren()) do
					if v:IsA("Frame") then
						if search ~= "" then
							local key = ""
							if v.Name == "Button" or v.Name == "Toggle" or v.Name == "Slider" then
								local t = v:FindFirstChild("Title")
								key = t and t.Text or ""
							elseif v.Name == "Label" then
								local t = v:FindFirstChild("LabelContent")
								key = t and t.Text or ""
							elseif v.Name == "TextBox" then
								local c = v:FindFirstChild("Container")
								local tb = c and c:FindFirstChild("TextInput")
								key = tb and tb.Text or ""
							elseif v.Name == "Keybind" then
								local c = v:FindFirstChild("Container")
								local t = c and c:FindFirstChild("Title")
								key = t and t.Text or ""
							end
							v.Visible = string.find(string.lower(key), search or "") ~= nil
						else
							v.Visible = true
						end
					end
				end
			end
			SearchBox.Changed:Connect(UpdateResults)

			-- Page Button (di sisi kiri)
			local PageButton = Instance.new("TextButton")
			PageButton.Name = "PageButton"
			PageButton.Parent = Tabs
			PageButton.BackgroundTransparency = 1
			PageButton.Size = UDim2.new(1, -14, 0, 20)
			PageButton.Font = Enum.Font.Gotham
			PageButton.Text = pagename
			PageButton.TextColor3 = Color3.fromRGB(255,255,255)
			PageButton.TextSize = 12
			PageButton.TextTransparency = 0.5
			PageButton.TextXAlignment = Enum.TextXAlignment.Left

			PageButton.MouseButton1Down:Connect(function()
				if Indicator.Visible == false then Indicator.Visible = true end
				TS:Create(Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				task.wait()
				TS:Create(Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
				for _, v in next, Tabs:GetChildren() do
					if v:IsA("TextButton") and v.Name == "PageButton" then
						TS:Create(v, TweenInfo.new(0.2), {TextTransparency = 0.5}):Play()
					end
				end
				task.wait()
				TS:Create(PageButton, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
				Indicator.Parent = PageButton
				for _,v in pairs(Window:GetChildren()) do
					if v:IsA("ScrollingFrame") and v.Name == "Page" then
						v.Visible = false
					end
				end
				Page.Visible = true
			end)

			-- ========= page API =========
			local pagebuttons = {}

			function pagebuttons:CreateButton(name, desc, callback)
				name = name or "Button"
				desc = desc or "Description"
				callback = callback or function() end

				local Button = Instance.new("Frame")
				local UICornerB = Instance.new("UICorner")
				local Title = Instance.new("TextLabel")
				local Description = Instance.new("TextLabel")
				local Caller = Instance.new("TextButton")
				local Sample = Instance.new("ImageLabel")

				Button.Name = "Button"
				Button.Parent = SectionContainer
				Button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
				Button.Size = UDim2.new(1, 0, 0, 40)

				UICornerB.CornerRadius = UDim.new(0, 4)
				UICornerB.Parent = Button

				Title.Name = "Title"
				Title.Parent = Button
				Title.BackgroundTransparency = 1
				Title.Position = UDim2.new(0, 7, 0, 1)
				Title.Size = UDim2.new(1, -7, 0.5, 0)
				Title.Font = Enum.Font.GothamBlack
				Title.Text = name
				Title.TextColor3 = Color3.fromRGB(255,255,255)
				Title.TextSize = 12
				Title.TextXAlignment = Enum.TextXAlignment.Left

				Description.Name = "Description"
				Description.Parent = Button
				Description.BackgroundTransparency = 1
				Description.Position = UDim2.new(0, 7, 0.5, -1)
				Description.Size = UDim2.new(1, -7, 0.5, 0)
				Description.Font = Enum.Font.Gotham
				Description.Text = desc
				Description.TextColor3 = Color3.fromRGB(159,159,159)
				Description.TextSize = 12
				Description.TextXAlignment = Enum.TextXAlignment.Left

				Caller.Name = "Caller"
				Caller.Parent = Button
				Caller.BackgroundTransparency = 0.999
				Caller.ClipsDescendants = true
				Caller.Size = UDim2.new(1, 0, 1, 0)
				Caller.Text = ""

				-- ripple
				Sample.Name = "Sample"
				Sample.Parent = Caller
				Sample.BackgroundTransparency = 1
				Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
				Sample.ImageColor3 = ACCENT
				Sample.ImageTransparency = 0.6

				Caller.MouseButton1Click:Connect(function()
					local ms = game.Players.LocalPlayer:GetMouse()
					local c = Sample:Clone()
					c.Parent = Caller
					local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
					c.Position = UDim2.new(0, x, 0, y)
					local len = 0.35
					local size = math.max(Caller.AbsoluteSize.X, Caller.AbsoluteSize.Y) * 1.5
					c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, -size/2, 0.5, -size/2), 'Out','Quad',len,true)
					for i = 1, 10 do c.ImageTransparency = c.ImageTransparency + 0.05; task.wait(len/12) end
					c:Destroy()
					callback()
				end)

				return {
					UpdateButton = function(_, newName) Title.Text = newName end
				}
			end

			function pagebuttons:CreateLabel(text)
				text = text or "Label"
				local Label = Instance.new("Frame")
				local UICorner_16 = Instance.new("UICorner")
				local Shadow = Instance.new("ImageLabel")
				local LabelContent = Instance.new("TextLabel")

				Label.Name = "Label"
				Label.Parent = SectionContainer
				Label.BackgroundColor3 = ACCENT
				Label.BackgroundTransparency = 0.5
				Label.Size = UDim2.new(1, 0, 0, 24)

				UICorner_16.CornerRadius = UDim.new(0, 4)
				UICorner_16.Parent = Label

				Shadow.Name = "4pxShadow(2px)"
				Shadow.Parent = Label
				Shadow.BackgroundTransparency = 1
				Shadow.Position = UDim2.new(0,-15,0,-15)
				Shadow.Size = UDim2.new(1,30,1,30)
				Shadow.Image = "http://www.roblox.com/asset/?id=5761504593"
				Shadow.ImageColor3 = ACCENT
				Shadow.ImageTransparency = 0.7
				Shadow.ScaleType = Enum.ScaleType.Slice
				Shadow.SliceCenter = Rect.new(17,17,283,283)

				LabelContent.Name = "LabelContent"
				LabelContent.Parent = Label
				LabelContent.BackgroundTransparency = 1
				LabelContent.Position = UDim2.new(0,7,0,0)
				LabelContent.Size = UDim2.new(1,-7,1,0)
				LabelContent.Font = Enum.Font.Gotham
				LabelContent.TextColor3 = Color3.fromRGB(255,255,255)
				LabelContent.Text = text
				LabelContent.TextSize = 12
				LabelContent.TextXAlignment = Enum.TextXAlignment.Left

				return {
					UpdateLabel = function(_, t) LabelContent.Text = t end
				}
			end

			function pagebuttons:CreateSlider(name,min,max,callback)
				name = name or "Slider"
				min = min or 16
				max = max or 100
				callback = callback or function() end

				local Slider = Instance.new("Frame")
				local UICorner_17 = Instance.new("UICorner")
				local Title_4 = Instance.new("TextLabel")
				local Tracker = Instance.new("Frame")
				local Indicator_3 = Instance.new("Frame")
				local Knob = Instance.new("TextButton")
				local UICorner_18 = Instance.new("UICorner")
				local Fade = Instance.new("Frame")
				local UICorner_19 = Instance.new("UICorner")
				local Value = Instance.new("Frame")
				local UICorner_20 = Instance.new("UICorner")
				local ValueText = Instance.new("TextLabel")
				local Shadow_1 = Instance.new("ImageLabel")
				local Shadow_2 = Instance.new("ImageLabel")

				Slider.Name = "Slider"
				Slider.Parent = SectionContainer
				Slider.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
				Slider.Size = UDim2.new(1, 0, 0, 40)

				UICorner_17.CornerRadius = UDim.new(0, 4)
				UICorner_17.Parent = Slider

				Title_4.Name = "Title"
				Title_4.Parent = Slider
				Title_4.BackgroundTransparency = 1
				Title_4.Position = UDim2.new(0, 7, 0, 0)
				Title_4.Size = UDim2.new(1, -7, 0, 30)
				Title_4.Font = Enum.Font.GothamBlack
				Title_4.Text = name
				Title_4.TextColor3 = Color3.fromRGB(255,255,255)
				Title_4.TextSize = 12
				Title_4.TextXAlignment = Enum.TextXAlignment.Left

				Tracker.Name = "Tracker"
				Tracker.Parent = Slider
				Tracker.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
				Tracker.BorderSizePixel = 0
				Tracker.Position = UDim2.new(0, 7, 1, -10)
				Tracker.Size = UDim2.new(1, -14, 0, 2)

				Indicator_3.Name = "Indicator"
				Indicator_3.Parent = Tracker
				Indicator_3.BackgroundColor3 = ACCENT
				Indicator_3.BorderSizePixel = 0
				Indicator_3.Size = UDim2.new(0, 0, 1, 0)

				Shadow_1.Parent = Indicator_3
				Shadow_1.BackgroundTransparency = 1
				Shadow_1.Position = UDim2.new(0,-15,0,-15)
				Shadow_1.Size = UDim2.new(1,30,1,30)
				Shadow_1.Image = "http://www.roblox.com/asset/?id=5761504593"
				Shadow_1.ImageColor3 = ACCENT
				Shadow_1.ImageTransparency = 1
				Shadow_1.ScaleType = Enum.ScaleType.Slice
				Shadow_1.SliceCenter = Rect.new(17,17,283,283)

				Knob.Parent = Indicator_3
				Knob.BackgroundColor3 = ACCENT
				Knob.Position = UDim2.new(1, -4, 0.5, -4)
				Knob.Size = UDim2.new(0, 8, 0, 8)
				Knob.Text = ""

				Shadow_2.Parent = Knob
				Shadow_2.BackgroundTransparency = 1
				Shadow_2.Position = UDim2.new(0,-15,0,-15)
				Shadow_2.Size = UDim2.new(1,30,1,30)
				Shadow_2.Image = "http://www.roblox.com/asset/?id=5761504593"
				Shadow_2.ImageColor3 = ACCENT
				Shadow_2.ImageTransparency = 1
				Shadow_2.ScaleType = Enum.ScaleType.Slice
				Shadow_2.SliceCenter = Rect.new(17,17,283,283)

				UICorner_18.CornerRadius = UDim.new(0.5, 0)
				UICorner_18.Parent = Knob

				Fade.Name = "Fade"
				Fade.Parent = Knob
				Fade.BackgroundColor3 = ACCENT
				Fade.BackgroundTransparency = 1
				Fade.Position = UDim2.new(-0.5, 0, -0.5, 0)
				Fade.Size = UDim2.new(2, 0, 2, 0)

				UICorner_19.CornerRadius = UDim.new(0.5, 0)
				UICorner_19.Parent = Fade

				Value.Name = "Value"
				Value.Parent = Slider
				Value.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Value.BackgroundTransparency = 0.83
				Value.Position = UDim2.new(1, -47, 0, 4)
				Value.Size = UDim2.new(0, 43, 0, 22)

				UICorner_20.CornerRadius = UDim.new(0, 4)
				UICorner_20.Parent = Value

				ValueText.Name = "ValueText"
				ValueText.Parent = Value
				ValueText.BackgroundTransparency = 1
				ValueText.Size = UDim2.new(1, 0, 1, 0)
				ValueText.Font = Enum.Font.Gotham
				ValueText.Text = tostring(min)
				ValueText.TextColor3 = ACCENT_TEXT
				ValueText.TextSize = 12

				local dragging = false
				local function setFromInput(input)
					local pos = UDim2.new(math.clamp((input.Position.X - Tracker.AbsolutePosition.X) / Tracker.AbsoluteSize.X, 0, 1), 0, 0, Tracker.AbsoluteSize.Y)
					Indicator_3:TweenSize(pos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
					local value = math.floor((((pos.X.Scale * max) / max) * (max - min) + min) * 100) / 100
					ValueText.Text = tostring(math.round(value))
					callback(value)
				end
				Knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						TS:Create(Fade, TweenInfo.new(.1), {BackgroundTransparency=0.8}):Play()
						TS:Create(Shadow_1, TweenInfo.new(.1), {ImageTransparency=0.7}):Play()
						TS:Create(Shadow_2, TweenInfo.new(.1), {ImageTransparency=0.7}):Play()
					end
				end)
				Knob.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						TS:Create(Fade, TweenInfo.new(.1), {BackgroundTransparency=1}):Play()
						TS:Create(Shadow_1, TweenInfo.new(.1), {ImageTransparency=1}):Play()
						TS:Create(Shadow_2, TweenInfo.new(.1), {ImageTransparency=1}):Play()
					end
				end)
				Knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then setFromInput(input) end
				end)
				UIS.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setFromInput(input) end
				end)

				return {
					Value = min
				}
			end

			function pagebuttons:CreateBox(placeholder, iconId, callback)
				placeholder = placeholder or "Input Text Here..."
				if iconId == "Default" or iconId == nil then iconId = 10045753138 end
				callback = callback or function() end

				local TextBox = Instance.new("Frame")
				local Footer = Instance.new("Frame")
				local UICorner_21 = Instance.new("UICorner")
				local Container = Instance.new("Frame")
				local UICorner_22 = Instance.new("UICorner")
				local TextInput = Instance.new("TextBox")
				local EditIcon = Instance.new("ImageLabel")

				TextBox.Name = "TextBox"
				TextBox.Parent = SectionContainer
				TextBox.BackgroundTransparency = 1
				TextBox.Size = UDim2.new(1, 0, 0, 30)

				Footer.Name = "Footer"
				Footer.Parent = TextBox
				Footer.BackgroundColor3 = ACCENT
				Footer.BackgroundTransparency = 0.75
				Footer.Position = UDim2.new(0, 0, 1, -8)
				Footer.Size = UDim2.new(1, 0, 0, 8)

				UICorner_21.CornerRadius = UDim.new(0, 4)
				UICorner_21.Parent = Footer

				Container.Name = "Container"
				Container.Parent = TextBox
				Container.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
				Container.BorderSizePixel = 0
				Container.Size = UDim2.new(1, 0, 1, -1)
				Container.ZIndex = 2

				UICorner_22.CornerRadius = UDim.new(0, 4)
				UICorner_22.Parent = Container

				TextInput.Name = "TextInput"
				TextInput.Parent = Container
				TextInput.BackgroundTransparency = 1
				TextInput.Position = UDim2.new(0, 30, 0, 0)
				TextInput.Size = UDim2.new(1, -30, 1, 0)
				TextInput.Font = Enum.Font.Gotham
				TextInput.PlaceholderColor3 = Color3.fromRGB(255,255,255)
				TextInput.PlaceholderText = placeholder
				TextInput.Text = ""
				TextInput.TextColor3 = Color3.fromRGB(255,255,255)
				TextInput.TextSize = 12
				TextInput.TextXAlignment = Enum.TextXAlignment.Left
				TextInput.FocusLost:Connect(function() callback(TextInput.Text) end)

				EditIcon.Name = "EditIcon"
				EditIcon.Parent = Container
				EditIcon.BackgroundTransparency = 1
				EditIcon.Position = UDim2.new(0, 6, 0, 6)
				EditIcon.Size = UDim2.new(0, 18, 0, 18)
				EditIcon.Image = "rbxassetid://"..tostring(iconId)
				EditIcon.ImageColor3 = ACCENT

				return {
					UpdateBox = function(_, t) TextInput.PlaceholderText = t end
				}
			end

			function pagebuttons:CreateBind(title, defaultkey, callback)
				title = title or "Keybind"
				defaultkey = defaultkey or "Unknown"
				callback = callback or function() end

				local Keybind = Instance.new("Frame")
				local Footer = Instance.new("Frame")
				local UICorner_13 = Instance.new("UICorner")
				local Container = Instance.new("Frame")
				local UICorner_14 = Instance.new("UICorner")
				local Title_3 = Instance.new("TextLabel")
				local KButton = Instance.new("TextButton")
				local Sample = Instance.new("ImageLabel")
				local UICorner_15 = Instance.new("UICorner")

				Keybind.Name = "Keybind"
				Keybind.Parent = SectionContainer
				Keybind.BackgroundTransparency = 1
				Keybind.Size = UDim2.new(1, 0, 0, 30)

				Footer.Name = "Footer"
				Footer.Parent = Keybind
				Footer.BackgroundColor3 = ACCENT
				Footer.BackgroundTransparency = 0.75
				Footer.Position = UDim2.new(0, 0, 1, -8)
				Footer.Size = UDim2.new(1, 0, 0, 8)

				UICorner_13.CornerRadius = UDim.new(0, 4)
				UICorner_13.Parent = Footer

				Container.Name = "Container"
				Container.Parent = Keybind
				Container.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
				Container.BorderSizePixel = 0
				Container.Size = UDim2.new(1, 0, 1, -1)
				Container.ZIndex = 2

				UICorner_14.CornerRadius = UDim.new(0, 4)
				UICorner_14.Parent = Container

				Title_3.Name = "Title"
				Title_3.Parent = Container
				Title_3.BackgroundTransparency = 1
				Title_3.Position = UDim2.new(0.0169, 0, 0, 0)
				Title_3.Size = UDim2.new(0, 55, 0, 29)
				Title_3.Font = Enum.Font.GothamBlack
				Title_3.Text = title
				Title_3.TextColor3 = Color3.fromRGB(255,255,255)
				Title_3.TextSize = 12
				Title_3.TextXAlignment = Enum.TextXAlignment.Left

				KButton.Name = "KButton"
				KButton.Parent = Container
				KButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
				KButton.BackgroundTransparency = 0.83
				KButton.Position = UDim2.new(0.815, 0, 0.13, 0)
				KButton.Size = UDim2.new(0, 72, 0, 22)
				KButton.Font = Enum.Font.Gotham
				KButton.Text = defaultkey
				KButton.TextColor3 = ACCENT_TEXT
				KButton.TextSize = 12
				KButton.ClipsDescendants = true

				Sample.Name = "Sample"
				Sample.Parent = KButton
				Sample.BackgroundTransparency = 1
				Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
				Sample.ImageColor3 = ACCENT
				Sample.ImageTransparency = 0.6

				UICorner_15.CornerRadius = UDim.new(0, 4)
				UICorner_15.Parent = KButton

				local CurrentKey = defaultkey
				local binding = false
				KButton.MouseButton1Click:Connect(function()
					if binding then return end
					binding = true
					KButton.Text = ". . ."
					local con; con = UIS.InputBegan:Connect(function(Key, gp)
						if gp then return end
						if Key.UserInputType == Enum.UserInputType.Keyboard then
							CurrentKey = Key.KeyCode.Name
							KButton.Text = CurrentKey
							callback(CurrentKey)
							con:Disconnect()
							binding = false
						end
					end)
				end)
				UIS.InputBegan:Connect(function(Key, gp)
					if gp then return end
					if Key.UserInputType == Enum.UserInputType.Keyboard and Key.KeyCode.Name == CurrentKey then
						local btn = KButton
						local ms  = game.Players.LocalPlayer:GetMouse()
						local c = Sample:Clone()
						c.Parent = btn
						local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
						c.Position = UDim2.new(0, x, 0, y)
						local len = 0.35
						local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.5
						c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, -size/2, 0.5, -size/2), 'Out','Quad',len,true)
						for i = 1,10 do c.ImageTransparency = c.ImageTransparency + 0.05; task.wait(len/12) end
						c:Destroy()
					end
				end)

				return {
					UpdateBind = function(_, t) Title_3.Text = t end
				}
			end

			function pagebuttons:CreateToggle(title, desc, callback)
				title = title or "Title"
				desc = desc or "Description"
				callback = callback or function() end

				local Toggle = Instance.new("Frame")
				local UICornerT = Instance.new("UICorner")
				local ToggleTitle = Instance.new("TextLabel")
				local Description = Instance.new("TextLabel")
				local Indicator = Instance.new("Frame")
				local UIStroke = Instance.new("UIStroke")
				local Dot = Instance.new("Frame")
				local UICornerDot = Instance.new("UICorner")
				local UICornerInd = Instance.new("UICorner")
				local TButton = Instance.new("TextButton")
				local UICornerBtn = Instance.new("UICorner")

				Toggle.Name = "Toggle"
				Toggle.Parent = SectionContainer
				Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
				Toggle.Size = UDim2.new(1,0,0,40)

				UICornerT.CornerRadius = UDim.new(0,4)
				UICornerT.Parent = Toggle

				ToggleTitle.Name = "Title"
				ToggleTitle.Parent = Toggle
				ToggleTitle.BackgroundTransparency = 1
				ToggleTitle.Position = UDim2.new(0,7,0,1)
				ToggleTitle.Size = UDim2.new(1,-7,0.5,0)
				ToggleTitle.Font = Enum.Font.GothamBlack
				ToggleTitle.Text = title
				ToggleTitle.TextColor3 = Color3.fromRGB(255,255,255)
				ToggleTitle.TextSize = 12
				ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left

				Description.Name = "Description"
				Description.Parent = Toggle
				Description.BackgroundTransparency = 1
				Description.Position = UDim2.new(0,7,0.5,-1)
				Description.Size = UDim2.new(1,-7,0.5,0)
				Description.Font = Enum.Font.Gotham
				Description.Text = desc
				Description.TextColor3 = Color3.fromRGB(159,159,159)
				Description.TextSize = 12
				Description.TextXAlignment = Enum.TextXAlignment.Left

				Indicator.Name = "Indicator"
				Indicator.Parent = Toggle
				Indicator.BackgroundTransparency = 1
				Indicator.Position = UDim2.new(1,-29,0,11)
				Indicator.Size = UDim2.new(0,18,0,18)

				UIStroke.Parent = Indicator
				UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				UIStroke.Color = ACCENT
				UIStroke.LineJoinMode = Enum.LineJoinMode.Round
				UIStroke.Thickness = 2

				Dot.Name = "Dot"
				Dot.Parent = Indicator
				Dot.BackgroundColor3 = ACCENT
				Dot.BackgroundTransparency = 1
				Dot.Position = UDim2.new(0,2,0,2)
				Dot.Size = UDim2.new(1,-4,1,-4)

				UICornerDot.CornerRadius = UDim.new(0.5,0)
				UICornerDot.Parent = Dot

				UICornerInd.CornerRadius = UDim.new(0.5,0)
				UICornerInd.Parent = Indicator

				TButton.Name = "TButton"
				TButton.Parent = Toggle
				TButton.BackgroundTransparency = 0.99
				TButton.Position = UDim2.new(0.92,0,0.175,0)
				TButton.Size = UDim2.new(0,25,0,26)
				TButton.Text = ""

				UICornerBtn.CornerRadius = UDim.new(0.5,0)
				UICornerBtn.Parent = TButton

				local f = false
				TButton.MouseButton1Click:Connect(function()
					f = not f
					TS:Create(Dot, TweenInfo.new(.1), {BackgroundTransparency = f and 0 or 1}):Play()
					callback(f)
				end)

				return {
					UpdateToggle = function(_, newTitle, newDesc)
						ToggleTitle.Text = newTitle
						Description.Text = newDesc
					end
				}
			end

			-- (ColorPicker dari sumber aslinya tetap ada; jika perlu aktifkan kembali di sini)
			-- ...

			return pagebuttons
		end -- CreateFrame

		return mytabbuttons
	end -- CreateTab

	return tabs
end

return library
