--!strict
-- Roblox GUI Premium Library (Luau)
-- One-file ModuleScript providing a set of polished UI components for Roblox
-- Place this as ModuleScript named `UIPremium` in ReplicatedStorage (or StarterPlayerScripts),
-- then see the DEMO LocalScript at the end of this file (after __DEMO__) for usage.

local UIPremium = {}

export type Theme = {
	Font: Enum.Font,
	TextColor: Color3,
	TextMuted: Color3,
	BG: Color3,
	Panel: Color3,
	PanelDark: Color3,
	Border: Color3,
	Primary: Color3,
	PrimaryHover: Color3,
	Danger: Color3,
	Divider: Color3,
	ShadowTransparency: number,
	Radius: number,
}

local DEFAULT_THEME: Theme = {
	Font = Enum.Font.Gotham,
	TextColor = Color3.fromRGB(25, 28, 35),
	TextMuted = Color3.fromRGB(120, 127, 139),
	BG = Color3.fromRGB(247, 249, 255),
	Panel = Color3.fromRGB(255, 255, 255),
	PanelDark = Color3.fromRGB(20, 20, 24),
	Border = Color3.fromRGB(222, 226, 235),
	Primary = Color3.fromRGB(86, 105, 250),
	PrimaryHover = Color3.fromRGB(70, 88, 220),
	Danger = Color3.fromRGB(229, 62, 87),
	Divider = Color3.fromRGB(235, 238, 245),
	ShadowTransparency = 0.85,
	Radius = 12,
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- internal util
local function create(className: string, props: {[string]: any}?, children: {Instance}?)
	local inst = Instance.new(className)
	if props then for k, v in pairs(props) do (inst :: any)[k] = v end end
	if children then for _, c in ipairs(children) do c.Parent = inst end end
	return inst
end

local function corner(parent: Instance, r: number?)
	local c = create("UICorner", { CornerRadius = UDim.new(0, r or DEFAULT_THEME.Radius) })
	c.Parent = parent
	return c
end

local function stroke(parent: Instance, color: Color3?, thickness: number?)
	local s = create("UIStroke", { Thickness = thickness or 1, Color = color or DEFAULT_THEME.Border, Transparency = 0 })
	s.Parent = parent
	return s
end

local function shadow(parent: Instance)
	-- soft drop shadow using ImageLabel
	local img = create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217", -- soft shadow circle sprite (common placeholder)
		ImageColor3 = Color3.new(0,0,0),
		ImageTransparency = DEFAULT_THEME.ShadowTransparency,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(64,64,64,64),
		Size = UDim2.fromScale(1,1),
		Position = UDim2.fromOffset(0,0),
		ZIndex = 0,
	})
	img.Parent = parent
	return img
end

local function padding(parent: Instance, px: number)
	local p = create("UIPadding", {PaddingLeft = UDim.new(0,px), PaddingRight = UDim.new(0,px), PaddingTop = UDim.new(0,px), PaddingBottom = UDim.new(0,px)})
	p.Parent = parent
	return p
end

local function list(parent: Instance, dir: Enum.FillDirection, gap: number)
	local l = create("UIListLayout", {FillDirection = dir, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap)})
	l.Parent = parent
	return l
end

local function textLabel(props): TextLabel
	local lbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Font = DEFAULT_THEME.Font,
		TextColor3 = DEFAULT_THEME.TextColor,
		TextSize = props.TextSize or 16,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = props.Text or "",
		Size = props.Size or UDim2.new(1,0,0, props.TextSize and props.TextSize+4 or 20),
		AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.None,
	})
	return lbl
end

local _mountParent: Instance? = nil

function UIPremium.SetMount(parent: Instance)
	_mountParent = parent
end

function UIPremium.CreateScreen(name: string?, parent: Instance?)
	local target = parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	local sg = create("ScreenGui", { Name = name or "UIPremium", ResetOnSpawn = false, IgnoreGuiInset = false })
	sg.Parent = target
	_mountParent = sg
	return sg
end

function UIPremium.Title(text: string, level: number?, props: {[string]: any}?)
	local size = (level == 2 and 28) or (level == 3 and 22) or 34
	local lbl = textLabel({ Text = text, TextSize = size })
	lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
	if props then for k,v in pairs(props) do (lbl :: any)[k] = v end end
	lbl.Parent = props and props.Parent or (_mountParent :: Instance)
	return lbl
end

function UIPremium.Text(text: string, muted: boolean?, props: {[string]: any}?)
	local lbl = textLabel({ Text = text, TextSize = 16 })
	lbl.TextColor3 = if muted then DEFAULT_THEME.TextMuted else DEFAULT_THEME.TextColor
	if props then for k,v in pairs(props) do (lbl :: any)[k] = v end end
	lbl.Parent = props and props.Parent or (_mountParent :: Instance)
	return lbl
end

function UIPremium.Label(text: string, props: {[string]: any}?)
	local lbl = textLabel({ Text = text, TextSize = 14 })
	lbl.TextColor3 = DEFAULT_THEME.TextMuted
	if props then for k,v in pairs(props) do (lbl :: any)[k] = v end end
	lbl.Parent = props and props.Parent or (_mountParent :: Instance)
	return lbl
end

function UIPremium.Divider(props: {[string]: any}?)
	local f = create("Frame", {BackgroundColor3 = DEFAULT_THEME.Divider, BorderSizePixel = 0, Size = UDim2.new(1,0,0,1)})
	if props then for k,v in pairs(props) do (f :: any)[k] = v end end
	f.Parent = props and props.Parent or (_mountParent :: Instance)
	return f
end

export type ButtonHandle = {
	Instance: TextButton,
	SetEnabled: (boolean) -> (),
}

function UIPremium.Button(text: string, onActivated: (() -> ())?, variant: string?, props: {[string]: any}?) : ButtonHandle
	variant = variant or "primary"
	local btn = create("TextButton", {
		AutoButtonColor = false,
		Text = text,
		Font = DEFAULT_THEME.Font,
		TextSize = 16,
		TextColor3 = if variant == "outline" or variant == "ghost" then DEFAULT_THEME.TextColor else Color3.new(1,1,1),
		BackgroundColor3 = if variant == "danger" then DEFAULT_THEME.Danger elseif variant=="outline" or variant=="ghost" then DEFAULT_THEME.Panel else DEFAULT_THEME.Primary,
		Size = props and props.Size or UDim2.fromOffset(120, 36),
		BorderSizePixel = 0,
	})
	corner(btn)
	if variant == "outline" then stroke(btn, DEFAULT_THEME.Border, 1) end
	if onActivated then btn.Activated:Connect(onActivated) end
	btn.MouseEnter:Connect(function()
		if variant == "primary" then btn.BackgroundColor3 = DEFAULT_THEME.PrimaryHover end
	end)
	btn.MouseLeave:Connect(function()
		if variant == "primary" then btn.BackgroundColor3 = DEFAULT_THEME.Primary end
	end)
	if props then for k,v in pairs(props) do (btn :: any)[k] = v end end
	btn.Parent = props and props.Parent or (_mountParent :: Instance)
	return {
		Instance = btn,
		SetEnabled = function(enabled: boolean)
			btn.Active = enabled; btn.AutoButtonColor = enabled; btn.TextTransparency = enabled and 0 or 0.4; btn.BackgroundTransparency = enabled and 0 or 0.4
		end,
	}
end

function UIPremium.Badge(text: string, tone: string?, props: {[string]: any}?)
	local chip = create("TextLabel", {
		BackgroundColor3 = Color3.fromRGB(240, 242, 255),
		BorderSizePixel = 0,
		Text = text,
		TextSize = 12,
		Font = DEFAULT_THEME.Font,
		TextColor3 = DEFAULT_THEME.TextColor,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0,0),
		Padding = 0,
	})
	corner(chip, 999)
	padding(chip, 8)
	if tone == "success" then chip.BackgroundColor3 = Color3.fromRGB(214, 245, 219) end
	if tone == "warning" then chip.BackgroundColor3 = Color3.fromRGB(250, 240, 200) end
	if tone == "danger" then chip.BackgroundColor3 = Color3.fromRGB(255, 220, 220) end
	if props then for k,v in pairs(props) do (chip :: any)[k] = v end end
	chip.Parent = props and props.Parent or (_mountParent :: Instance)
	return chip
end

function UIPremium.Card(props: {[string]: any}?)
	local card = create("Frame", {
		BackgroundColor3 = DEFAULT_THEME.Panel,
		BorderSizePixel = 0,
		Size = props and props.Size or UDim2.fromOffset(320, 220),
	})
	corner(card)
	stroke(card, DEFAULT_THEME.Border, 1)
	shadow(card)
	if props then for k,v in pairs(props) do (card :: any)[k] = v end end
	card.Parent = props and props.Parent or (_mountParent :: Instance)
	return card
end

function UIPremium.CardHeader(parent: Instance, title: string?, subtitle: string?)
	local header = create("Frame", { BackgroundColor3 = Color3.fromRGB(248, 249, 255), BorderSizePixel = 0, Size = UDim2.new(1,0,0,48) })
	corner(header, DEFAULT_THEME.Radius)
	header.Parent = parent
	local stack = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,-20,1,0), Position = UDim2.fromOffset(10,0) })
	list(stack, Enum.FillDirection.Vertical, 2)
	stack.Parent = header
	if title then
		UIPremium.Title(title, 3, {Parent = stack, Size = UDim2.new(1,0,0,24)})
	end
	if subtitle then
		UIPremium.Text(subtitle, true, {Parent = stack, Size = UDim2.new(1,0,0,18)})
	end
	return header
end

export type SwitchHandle = { Instance: Frame, Set: (boolean)->(), Value: boolean }
function UIPremium.Switch(value: boolean, onChanged: (boolean)->()?, props: {[string]: any}?) : SwitchHandle
	local track = create("Frame", {BackgroundColor3 = Color3.fromRGB(220,224,235), BorderSizePixel = 0, Size = UDim2.fromOffset(44, 24)})
	corner(track, 12)
	local knob = create("Frame", {BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, Size = UDim2.fromOffset(20,20), Position = UDim2.fromOffset(2,2)})
	corner(knob, 10); stroke(knob, Color3.fromRGB(230,230,235), 1)
	knob.Parent = track
	local function render(v: boolean)
		TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = v and DEFAULT_THEME.Primary or Color3.fromRGB(220,224,235)}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {Position = v and UDim2.fromOffset(22,2) or UDim2.fromOffset(2,2)}):Play()
	end
	render(value)
	track.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
			value = not value
			render(value)
			if onChanged then onChanged(value) end
		end
	end)
	if props then for k,v in pairs(props) do (track :: any)[k] = v end end
	track.Parent = props and props.Parent or (_mountParent :: Instance)
	return { Instance = track, Set = function(v) value=v; render(v) end, Value = value }
end

export type CheckboxHandle = { Instance: TextButton, Set: (boolean)->(), Value: boolean }
function UIPremium.Checkbox(text: string, value: boolean, onChanged: (boolean)->()?, props: {[string]: any}?) : CheckboxHandle
	local btn = create("TextButton", {AutoButtonColor = false, BackgroundTransparency = 1, Text = "", Size = UDim2.fromOffset(160, 24)})
	local box = create("Frame", {Size = UDim2.fromOffset(20,20), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, Position = UDim2.fromOffset(0,2)})
	corner(box, 6); stroke(box)
	local tick = create("TextLabel", {BackgroundTransparency = 1, Text = "✓", TextColor3 = DEFAULT_THEME.Primary, Font = DEFAULT_THEME.Font, TextSize = 16, Visible = value, Size = UDim2.fromScale(1,1)})
	tick.Parent = box
	box.Parent = btn
	local lbl = UIPremium.Text(text, false, {Parent = btn, Position = UDim2.fromOffset(28,0), Size = UDim2.new(1,-28,1,0)})
	btn.Activated:Connect(function()
		value = not value; tick.Visible = value; if onChanged then onChanged(value) end
	end)
	if props then for k,v in pairs(props) do (btn :: any)[k] = v end end
	btn.Parent = props and props.Parent or (_mountParent :: Instance)
	return { Instance = btn, Set = function(v) value = v; tick.Visible = v end, Value = value }
end

export type SliderHandle = { Instance: Frame, Set: (number)->(), Value: number }
function UIPremium.Slider(value: number, onChanged: (number)->()?, props: {[string]: any}?) : SliderHandle
	local w = (props and props.Width) or 200
	local bar = create("Frame", {BackgroundColor3 = DEFAULT_THEME.Divider, BorderSizePixel = 0, Size = UDim2.fromOffset(w, 6)})
	corner(bar, 999)
	local fill = create("Frame", {BackgroundColor3 = DEFAULT_THEME.Primary, BorderSizePixel = 0, Size = UDim2.fromOffset(math.floor(w*value), 6)})
	corner(fill, 999); fill.Parent = bar
	local dragging = false
	bar.InputBegan:Connect(function(io)
		if io.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
	end)
	bar.InputEnded:Connect(function(io)
		if io.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
	end)
	RunService.RenderStepped:Connect(function()
		if dragging then
			local mx = bar.AbsolutePosition.X
			local px = math.clamp(game:GetService('UserInputService'):GetMouseLocation().X - mx, 0, bar.AbsoluteSize.X)
			value = px / bar.AbsoluteSize.X
			fill.Size = UDim2.fromOffset(px,6)
			if onChanged then onChanged(value) end
		end
	end)
	if props then for k,v in pairs(props) do (bar :: any)[k] = v end end
	bar.Parent = props and props.Parent or (_mountParent :: Instance)
	return { Instance = bar, Set = function(v) value=v; fill.Size = UDim2.fromOffset(math.floor(w*v),6) end, Value = value }
end

export type InputHandle = { Instance: TextBox, SetText: (string)->(), GetText: ()->string }
function UIPremium.TextInput(placeholder: string?, props: {[string]: any}?) : InputHandle
	local box = create("TextBox", {
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		Font = DEFAULT_THEME.Font,
		PlaceholderText = placeholder or "",
		Text = "",
		TextSize = 16,
		TextColor3 = DEFAULT_THEME.TextColor,
		ClearTextOnFocus = false,
		Size = props and props.Size or UDim2.fromOffset(220, 36),
		AutomaticSize = Enum.AutomaticSize.None,
	})
	corner(box, DEFAULT_THEME.Radius)
	stroke(box)
	padding(box, 10)
	if props then for k,v in pairs(props) do (box :: any)[k] = v end end
	box.Parent = props and props.Parent or (_mountParent :: Instance)
	return { Instance = box, SetText = function(t) box.Text = t end, GetText = function() return box.Text end }
end

export type DropdownState = { Value: number?, Open: boolean }
function UIPremium.Dropdown(items: {string}, state: DropdownState, onChanged: (number)->()?, props: {[string]: any}?)
	local root = create("Frame", { BackgroundTransparency = 1, Size = props and props.Size or UDim2.fromOffset(220, 36) })
	local field = create("TextButton", { AutoButtonColor = false, Text = items[state.Value or 0] or (props and props.Placeholder) or "Pilih...", Font = DEFAULT_THEME.Font, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, Size = UDim2.fromScale(1,1)})
	padding(field, 10); corner(field, DEFAULT_THEME.Radius); stroke(field)
	field.Parent = root
	local popup = create("Frame", { BackgroundColor3 = DEFAULT_THEME.Panel, BorderSizePixel = 0, Visible = false, Position = UDim2.fromOffset(0, 40), Size = UDim2.fromOffset(root.AbsoluteSize.X, 0) })
	corner(popup, DEFAULT_THEME.Radius); stroke(popup)
	popup.Parent = root
	local lay = list(popup, Enum.FillDirection.Vertical, 0)
	field.Activated:Connect(function()
		state.Open = not state.Open
		popup.Visible = state.Open
		if state.Open then
			popup.Size = UDim2.fromOffset(root.AbsoluteSize.X, math.min(#items*32, 200))
			for _, c in ipairs(popup:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
			for i, txt in ipairs(items) do
				local row = create("TextButton", {AutoButtonColor=false, BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel=0, Text = txt, Font=DEFAULT_THEME.Font, TextSize=16, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1,0,0,32)})
				padding(row, 10)
				row.Parent = popup
				row.Activated:Connect(function()
					state.Value = i; field.Text = txt; state.Open = false; popup.Visible = false; if onChanged then onChanged(i) end
				end)
			end
		end
	end)
	if props then for k,v in pairs(props) do (root :: any)[k] = v end end
	root.Parent = props and props.Parent or (_mountParent :: Instance)
	return root
end

function UIPremium.Tabs(labels: {string}, value: number, onChanged: (number)->()?, props: {[string]: any}?)
	local root = create("Frame", {BackgroundTransparency = 1, Size = props and props.Size or UDim2.fromOffset(300, 40)})
	local bg = create("Frame", {BackgroundColor3 = Color3.fromRGB(245,246,250), BorderSizePixel=0, Size = UDim2.fromScale(1,1)})
	corner(bg, DEFAULT_THEME.Radius); bg.Parent = root
	local l = list(bg, Enum.FillDirection.Horizontal, 4)
	for i, name in ipairs(labels) do
		local tab = UIPremium.Button(name, function()
			value = i; if onChanged then onChanged(i) end
		end, (value==i) and "primary" or "ghost", {Parent = bg, Size = UDim2.new(1/#labels, -6, 1, -6)})
		tab.Instance.LayoutOrder = i
	end
	if props then for k,v in pairs(props) do (root :: any)[k] = v end end
	root.Parent = props and props.Parent or (_mountParent :: Instance)
	return root
end

function UIPremium.Progress(value: number, props: {[string]: any}?)
	local root = create("Frame", {BackgroundColor3 = DEFAULT_THEME.Divider, BorderSizePixel = 0, Size = props and props.Size or UDim2.fromOffset(300, 8)})
	corner(root, 999)
	local fill = create("Frame", {BackgroundColor3 = DEFAULT_THEME.Primary, BorderSizePixel = 0, Size = UDim2.fromScale(math.clamp(value,0,1), 1)})
	corner(fill, 999); fill.Parent = root
	if props then for k,v in pairs(props) do (root :: any)[k] = v end end
	root.Parent = props and props.Parent or (_mountParent :: Instance)
	return root
end

function UIPremium.Tooltip(target: Instance, text: string)
	local tip = create("TextLabel", { BackgroundColor3 = Color3.fromRGB(18,18,20), TextColor3 = Color3.new(1,1,1), Text = text, Font = DEFAULT_THEME.Font, TextSize = 12, ZIndex = 100, Visible = false, AutomaticSize = Enum.AutomaticSize.XY })
	padding(tip, 6); corner(tip, 6)
	tip.Parent = _mountParent
	(target :: any).MouseEnter:Connect(function()
		tip.Visible = true; tip.Position = UDim2.fromOffset(target.AbsolutePosition.X, target.AbsolutePosition.Y- tip.AbsoluteSize.Y - 8)
	end)
	(target :: any).MouseLeave:Connect(function() tip.Visible = false end)
	return tip
end

function UIPremium.Toast(text: string, tone: string?)
	local holderName = "UIPremiumToastHolder"
	local holder = (_mountParent and (_mountParent :: Instance):FindFirstChild(holderName)) or create("Frame", {Name = holderName, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1,1), Position = UDim2.fromScale(1,1), Size = UDim2.fromOffset(300,0), ZIndex = 200})
	if holder.Parent == nil then holder.Parent = _mountParent end
	local toast = create("TextLabel", {BackgroundColor3 = tone=="danger" and DEFAULT_THEME.Danger or Color3.fromRGB(30,30,36), TextColor3 = Color3.new(1,1,1), Text = text, Font = DEFAULT_THEME.Font, TextSize = 14, AutomaticSize = Enum.AutomaticSize.XY})
	padding(toast, 10); corner(toast, 10)
	toast.Parent = holder
	toast.Position = UDim2.fromOffset(-16, -16 - #holder:GetChildren()* (toast.AbsoluteSize.Y + 8))
	toast.TextWrapped = true
	-- auto fade
	local t = TweenService:Create(toast, TweenInfo.new(0.25), {BackgroundTransparency = 0})
	t:Play()
	task.delay(2.5, function()
		TweenService:Create(toast, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		task.delay(0.35, function() toast:Destroy() end)
	end)
	return toast
end

-- Sidebar (collapsible) with items { {Text = "Home", OnActivated = function() end} }
function UIPremium.Sidebar(items: {{Text: string, OnActivated: (()->())?}}, open: boolean, props: {[string]: any}?)
	local wOpen, wClosed = 260, 64
	local root = create("Frame", {BackgroundColor3 = DEFAULT_THEME.PanelDark, Size = UDim2.fromOffset(open and wOpen or wClosed, (props and props.Height) or 0), BorderSizePixel = 0})
	shadow(root); corner(root, 0)
	local toggle = UIPremium.Button("", function() open = not open; root.Size = UDim2.fromOffset(open and wOpen or wClosed, root.Size.Y.Offset) end, "ghost", {Parent = root, Size = UDim2.fromOffset(36,36), Position = UDim2.fromOffset((open and wOpen-44 or wClosed-44), 12)})
	local icon = create("TextLabel", {BackgroundTransparency = 1, Text = "≡", TextColor3 = Color3.new(1,1,1), TextSize = 20, Size = UDim2.fromOffset(36,36), Position = UDim2.fromOffset(16,12)})
	icon.Parent = root
	local y = 60
	for i, it in ipairs(items) do
		local row = create("TextButton", {AutoButtonColor=false, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1,0,0,40), Position = UDim2.fromOffset(0,y)})
		local lbl = create("TextLabel", {BackgroundTransparency = 1, Text = it.Text, TextColor3 = Color3.new(1,1,1), Font = DEFAULT_THEME.Font, TextSize = 16, AnchorPoint = Vector2.new(0,0.5), Position = UDim2.fromOffset(56, 20)})
		lbl.Parent = row
		row.MouseEnter:Connect(function() row.BackgroundTransparency = 0.9; row.BackgroundColor3 = Color3.fromRGB(255,255,255) end)
		row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)
		row.Activated:Connect(function() if it.OnActivated then it.OnActivated() end end)
		row.Parent = root
		y += 42
	end
	if props then for k,v in pairs(props) do (root :: any)[k] = v end end
	root.Parent = props and props.Parent or (_mountParent :: Instance)
	return root
end

-- Modal
function UIPremium.Modal(title: string, contentBuilder: (Instance)->(), actionsBuilder: ((Instance)->())?, props: {[string]: any}?)
	local root = create("Frame", {BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.4, Size = UDim2.fromScale(1,1)})
	local card = UIPremium.Card({Parent = root, Size = UDim2.fromOffset(520, 320), Position = UDim2.fromScale(0.5,0.5), AnchorPoint = Vector2.new(0.5,0.5)})
	UIPremium.CardHeader(card, title, nil)
	local content = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,-32,1,-96), Position = UDim2.fromOffset(16, 72)})
	content.Parent = card
	contentBuilder(content)
	local actions = create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromOffset(card.AbsoluteSize.X-32, 36), Position = UDim2.fromOffset(16, card.Size.Y.Offset-52)})
	actions.Parent = card
	if actionsBuilder then actionsBuilder(actions) end
	root.Parent = props and props.Parent or (_mountParent :: Instance)
	return root
end

-- Tabs are above.

-- ======== END OF MODULE ========
return UIPremium

--[[
==================== __DEMO__ ====================
Place this LocalScript under StarterPlayerScripts (or StarterGui) to preview the components.
Make sure the ModuleScript `UIPremium` is in ReplicatedStorage.
--]]


local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local UIPremium = require(ReplicatedStorage:WaitForChild('UIPremium'))

local screen = UIPremium.CreateScreen('UIPremiumDemo')

-- Layout root
local root = Instance.new('Frame')
root.BackgroundTransparency = 1
root.Size = UDim2.fromScale(1,1)
root.Parent = screen

-- Sidebar
local side = UIPremium.Sidebar({
	{ Text = 'Beranda', OnActivated = function() UIPremium.Toast('Beranda dibuka') end },
	{ Text = 'Pengaturan', OnActivated = function() UIPremium.Toast('Masuk menu Pengaturan') end },
	{ Text = 'Profil', OnActivated = function() UIPremium.Toast('Buka profil') end },
}, true, { Parent = root, Position = UDim2.fromOffset(0,0), Size = UDim2.new(0,260,1,0) })

-- Content container
local content = Instance.new('Frame')
content.BackgroundTransparency = 1
content.Position = UDim2.fromOffset(280, 24)
content.Size = UDim2.new(1,-300,1,-48)
content.Parent = root

UIPremium.Title('Roblox GUI Premium', 1, {Parent = content, Position = UDim2.fromOffset(0,0)})
UIPremium.Text('Komponen lengkap siap produksi (Luau).', true, {Parent = content, Position = UDim2.fromOffset(0,40)})

local row = Instance.new('Frame')
row.BackgroundTransparency = 1; row.Size = UDim2.fromOffset(900, 280); row.Position = UDim2.fromOffset(0, 80); row.Parent = content
local list = Instance.new('UIListLayout'); list.Padding = UDim.new(0,20); list.FillDirection = Enum.FillDirection.Horizontal; list.Parent = row

-- Card 1: Form
local card1 = UIPremium.Card({Parent = row, Size = UDim2.fromOffset(420, 260)})
UIPremium.CardHeader(card1, 'Formulir', 'Elemen input premium')
UIPremium.Label('Nama', {Parent = card1, Position = UDim2.fromOffset(16, 56)})
local nameInput = UIPremium.TextInput('Masukkan nama', {Parent = card1, Position = UDim2.fromOffset(16, 80)})
UIPremium.Label('Peran', {Parent = card1, Position = UDim2.fromOffset(16, 122)})
local ddState = {Value = nil, Open = false}
UIPremium.Dropdown({'Frontend','Backend','Fullstack'}, ddState, function(i)
	UIPremium.Toast('Peran: '..({'Frontend','Backend','Fullstack'})[i])
end, {Parent = card1, Position = UDim2.fromOffset(16, 146)})
local sw = UIPremium.Switch(true, function(v) UIPremium.Toast('Aktif: '..tostring(v)) end, {Parent = card1, Position = UDim2.fromOffset(16, 190)})
local saveBtn = UIPremium.Button('Simpan', function() UIPremium.Toast('Tersimpan','success') end, 'primary', {Parent = card1, Position = UDim2.fromOffset(16, 222)})
UIPremium.Button('Hapus', function() UIPremium.Toast('Dihapus','danger') end, 'danger', {Parent = card1, Position = UDim2.fromOffset(146, 222)})

-- Card 2: Status
local card2 = UIPremium.Card({Parent = row, Size = UDim2.fromOffset(420, 260)})
UIPremium.CardHeader(card2, 'Status Proyek', 'Progress & kontrol')
UIPremium.Text('Kemajuan saat ini:', false, {Parent = card2, Position = UDim2.fromOffset(16, 56)})
local prog = UIPremium.Progress(0.42, {Parent = card2, Position = UDim2.fromOffset(16, 80), Size = UDim2.fromOffset(388, 8)})
UIPremium.Button('-10%', function() UIPremium.Toast('-10%'); end, 'outline', {Parent = card2, Position = UDim2.fromOffset(16, 106)})
UIPremium.Button('+10%', function() UIPremium.Toast('+10%') end, 'primary', {Parent = card2, Position = UDim2.fromOffset(112, 106)})
UIPremium.Badge('Premium', 'success', {Parent = card2, Position = UDim2.fromOffset(340, 12)})

-- Tabs
UIPremium.Tabs({'Overview','Tasks','Team'}, 1, function(i) UIPremium.Toast('Tab '..tostring(i)) end, {Parent = content, Position = UDim2.fromOffset(0, 380), Size = UDim2.fromOffset(420, 40)})

-- Modal example
UIPremium.Button('Buka Modal', function()
	UIPremium.Modal('Pratinjau', function(container)
		UIPremium.Text('Ini isi modal.', false, {Parent = container})
	end, function(actions)
		UIPremium.Button('Tutup', function() actions.Parent.Parent.Parent:Destroy() end, 'outline', {Parent = actions, Position = UDim2.fromOffset(280, 0)})
		UIPremium.Button('Konfirmasi', function() UIPremium.Toast('OK'); actions.Parent.Parent.Parent:Destroy() end, 'primary', {Parent = actions, Position = UDim2.fromOffset(370,0)})
	end, {Parent = screen})
end, 'primary', {Parent = content, Position = UDim2.fromOffset(0, 440)})

-- Slider + Checkbox
UIPremium.Label('Volume', {Parent = content, Position = UDim2.fromOffset(0, 500)})
UIPremium.Slider(0.5, function(v) end, {Parent = content, Position = UDim2.fromOffset(0, 520), Width = 280})
UIPremium.Checkbox('Terima email notifikasi', true, function(v) end, {Parent = content, Position = UDim2.fromOffset(300, 512)})

-- Tooltip example
UIPremium.Tooltip(saveBtn.Instance, 'Simpan data formulir')
