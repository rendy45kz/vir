--// ZiaanHub • Fish It • Delta Android Standalone GUI
--// Game: https://www.roblox.com/games/121864768012064/Fish-It
--// No external UI libs. Mobile friendly + Floating Toggle.

--=========[ Bootstrap / Join Game ]=========
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TARGET_PLACE = 121864768012064
if game.PlaceId ~= TARGET_PLACE then
    TeleportService:Teleport(TARGET_PLACE, LocalPlayer)
    return
end

--=========[ Safe utils ]=========
local function safepcall(f, ...)
    local ok, res = pcall(f, ...)
    if not ok then warn("[ZiaanHub] ".. tostring(res)) end
    return ok, res
end

--=========[ Anti-AFK ]=========
local VirtualUser = game:GetService("VirtualUser")
local antiAFKConn
local function setAntiAFK(on)
    if on then
        if antiAFKConn then antiAFKConn:Disconnect() end
        antiAFKConn = LocalPlayer.Idled:Connect(function()
            safepcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end)
    else
        if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn=nil end
    end
end
setAntiAFK(true)

--=========[ Net / Remotes ]=========
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = net:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame  = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_FishingCompleted = net:WaitForChild("RE/FishingCompleted")
local RE_EquipHotbar      = net:WaitForChild("RE/EquipToolFromHotbar")
local RF_SellAll          = net:FindFirstChild("RF/SellAllItems")

-- Optional modules
local Replion do
    local ok, mod = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("replion"))
    end)
    if ok then Replion = mod end
end
local ItemUtility do
    local ok, mod = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ItemUtility"))
    end)
    if ok then ItemUtility = mod end
end

--=========[ Animations ]=========
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodIdle  = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("FishingRodReelIdle")
local RodReel  = ReplicatedStorage.Modules.Animations:WaitForChild("EasyFishReelStart")
local RodShake = ReplicatedStorage.Modules.Animations:WaitForChild("CastFromFullChargePosition1Hand")

local AnimIdle  = animator:LoadAnimation(RodIdle)
local AnimReel  = animator:LoadAnimation(RodReel)
local AnimShake = animator:LoadAnimation(RodShake)

--=========[ Rod Delays Table ]=========
local RodDelays = {
    ["Ares Rod"]      = {custom = 1.12, bypass = 1.45},
    ["Angler Rod"]    = {custom = 1.12, bypass = 1.45},
    ["Ghostfinn Rod"] = {custom = 1.12, bypass = 1.45},
    ["Astral Rod"]    = {custom = 1.90, bypass = 1.45},
    ["Chrome Rod"]    = {custom = 2.30, bypass = 2.00},
    ["Steampunk Rod"] = {custom = 2.50, bypass = 2.30},
    ["Lucky Rod"]     = {custom = 3.50, bypass = 3.60},
    ["Midnight Rod"]  = {custom = 3.30, bypass = 3.40},
    ["Demascus Rod"]  = {custom = 3.90, bypass = 3.80},
    ["Grass Rod"]     = {custom = 3.80, bypass = 3.90},
    ["Luck Rod"]      = {custom = 4.20, bypass = 4.10},
    ["Carbon Rod"]    = {custom = 4.00, bypass = 3.80},
    ["Lava Rod"]      = {custom = 4.20, bypass = 4.10},
    ["Starter Rod"]   = {custom = 4.30, bypass = 4.20},
}

local currentCustomDelay, currentBypassDelay = 2.5, 1.2
local perfectCast = true

local function getEquippedRodName()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local backpack = pg:FindFirstChild("Backpack")
    if not backpack then return nil end
    local display = backpack:FindFirstChild("Display")
    if not display then return nil end
    for _, tile in ipairs(display:GetChildren()) do
        local ok, label = pcall(function() return tile.Inner.Tags.ItemName end)
        if ok and label and label:IsA("TextLabel") then
            local name = label.Text
            if RodDelays[name] then return name end
        end
    end
    return nil
end

local function refreshRodDelays()
    local rod = getEquippedRodName()
    if rod and RodDelays[rod] then
        currentCustomDelay = RodDelays[rod].custom
        currentBypassDelay = RodDelays[rod].bypass
    else
        currentCustomDelay = 10
        currentBypassDelay = 1
    end
end

--=========[ Auto Fishing ]=========
local AF = {enabled=false, fishing=false}

-- finish on “Exclaim” text over head (server minigame sync)
local RE_RepText = net:FindFirstChild("RE/ReplicateTextEffect")
if RE_RepText then
    RE_RepText.OnClientEvent:Connect(function(data)
        if not (AF.enabled and AF.fishing) then return end
        if not (data and data.TextData and data.TextData.EffectType == "Exclaim") then return end
        local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
        if head and data.Container == head then
            task.spawn(function()
                task.wait(currentBypassDelay)
                safepcall(function() RE_FishingCompleted:FireServer() end)
            end)
        end
    end)
end

local function StartAutoFish()
    if AF.enabled then return end
    AF.enabled = true
    refreshRodDelays()
    task.spawn(function()
        while AF.enabled do
            safepcall(function()
                AF.fishing = true
                if RE_EquipHotbar then RE_EquipHotbar:FireServer(1) end
                task.wait(0.1)

                local ts = workspace:GetServerTimeNow()
                RF_ChargeFishingRod:InvokeServer(ts)
                task.wait(0.4)
                AnimShake:Play()
                safepcall(function() RF_ChargeFishingRod:InvokeServer(workspace:GetServerTimeNow()) end)

                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                if perfectCast then
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end
                AnimIdle:Play()
                RF_RequestMinigame:InvokeServer(x, y)

                task.wait(currentCustomDelay)
                AF.fishing = false
                refreshRodDelays()
            end)
            task.wait(0.08) -- battery friendly
        end
    end)
end
local function StopAutoFish()
    AF.enabled=false
    AF.fishing=false
    AnimIdle:Stop(); AnimReel:Stop(); AnimShake:Stop()
end

--=========[ Auto Sell / Protect ]=========
local protectTiers = {Legendary=true, Mythic=true, Secret=true, Common=false, Uncommon=false, Rare=false, Epic=false}
local function protectByTiers()
    if not (Replion and ItemUtility) then return end
    local DataReplion = Replion.Client:WaitReplion("Data")
    local items = DataReplion and DataReplion:Get({"Inventory","Items"})
    if type(items) ~= "table" then return end
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        local tier = base and base.Data and tostring(base.Data.Tier)
        if tier and protectTiers[tier] and not item.Favorited then
            item.Favorited = true
        end
    end
end
local function sellAllNonFavorite()
    protectByTiers()
    task.wait(0.2)
    if RF_SellAll then
        safepcall(function() RF_SellAll:InvokeServer() end)
    end
end

local AutoSell = {on=false, last=0}
task.spawn(function()
    while true do
        if AutoSell.on and (os.time() - AutoSell.last >= 60) then
            -- threshold: non-fav >= 60
            local count = 0
            if Replion then
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items)=="table" then
                    for _,it in ipairs(items) do if not it.Favorited then count += (it.Count or 1) end end
                end
            end
            if count >= 60 then sellAllNonFavorite(); AutoSell.last = os.time() end
        end
        task.wait(10)
    end
end)

--=========[ Teleport Targets ]=========
local islandCoords = {
    ["Weather Machine"] = Vector3.new(-1471, -3, 1929),
    ["Esoteric Depths"] = Vector3.new(3157, -1303, 1439),
    ["Tropical Grove"]  = Vector3.new(-2038, 3, 3650),
    ["Stingray Shores"] = Vector3.new(-32, 4, 2773),
    ["Kohana Volcano"]  = Vector3.new(-519, 24, 189),
    ["Coral Reefs"]     = Vector3.new(-3095, 1, 2177),
    ["Crater Island"]   = Vector3.new(968, 1, 4854),
    ["Kohana"]          = Vector3.new(-658, 3, 719),
    ["Winter Fest"]     = Vector3.new(1611, 4, 3280),
    ["Isoteric Island"] = Vector3.new(1987, 4, 1400),
    ["Treasure Hall"]   = Vector3.new(-3600, -267, -1558),
    ["Lost Shore"]      = Vector3.new(-3663, 38, -989),
    ["Sishypus Statue"] = Vector3.new(-3792, -135, -986),
}

--=========[ Simple UI ]=========
local pg = LocalPlayer:WaitForChild("PlayerGui")
local SG = Instance.new("ScreenGui")
SG.Name = "ZiaanHub_FishIt_GUI"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = (gethui and gethui()) or pg

-- Draggable frame
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(370, 420)
Main.Position = UDim2.new(0, 20, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(22,24,36)
Main.BackgroundTransparency = 0.15
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Main)
Title.BackgroundTransparency = 1
Title.Text = "ZiaanHub • Fish It"
Title.Font = Enum.Font.GothamSemibold
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(235,240,255)
Title.Size = UDim2.fromOffset(240, 32)
Title.Position = UDim2.new(0, 12, 0, 8)

local function makeButton(parent, text, posY, onClick, color)
    local b = Instance.new("TextButton", parent)
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextScaled = true
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Size = UDim2.fromOffset(340, 34)
    b.Position = UDim2.new(0, 15, 0, posY)
    b.BackgroundColor3 = color or Color3.fromRGB(40,42,58)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(onClick)
    return b
end
local function makeToggle(parent, label, posY, default, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.fromOffset(340, 32)
    holder.Position = UDim2.new(0, 15, 0, posY)
    holder.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", holder)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextScaled = true
    lbl.TextColor3 = Color3.fromRGB(230,235,255)
    lbl.Size = UDim2.fromOffset(220, 32)
    lbl.Position = UDim2.new(0,0,0,0)
    local btn = Instance.new("TextButton", holder)
    btn.Size = UDim2.fromOffset(100, 32)
    btn.Position = UDim2.new(1, -100, 0, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(46,160,67) or Color3.fromRGB(110,110,120)
    btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.GothamSemibold
    btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(46,160,67) or Color3.fromRGB(110,110,120)
        callback(state)
    end)
    -- init
    task.defer(function() callback(default) end)
    return btn
end
local function makeTextbox(parent, placeholder, posY, onCommit)
    local tb = Instance.new("TextBox", parent)
    tb.PlaceholderText = placeholder
    tb.Font = Enum.Font.Gotham
    tb.Text = ""
    tb.TextScaled = true
    tb.BackgroundColor3 = Color3.fromRGB(30,32,46)
    tb.TextColor3 = Color3.fromRGB(235,240,255)
    tb.Size = UDim2.fromOffset(340, 34)
    tb.Position = UDim2.new(0, 15, 0, posY)
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    tb.FocusLost:Connect(function(enter) if enter then onCommit(tb.Text) end end)
    return tb
end

-- Dragging
do
    local dragging, offset
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; offset = i.Position - Main.AbsolutePosition
        end
    end)
    Main.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            Main.Position = UDim2.fromOffset(i.Position.X - offset.X, i.Position.Y - offset.Y)
        end
    end)
end

-- Sections
local y = 48
makeToggle(Main, "Auto Fish (per-rod)", y, false, function(v) if v then StartAutoFish() else StopAutoFish() end end) y += 38
makeToggle(Main, "Perfect Cast", y, true, function(v) perfectCast = v end) y += 38
makeTextbox(Main, "Bypass Delay (e.g. 1.45)", y, function(t) local n=tonumber(t); if n then currentBypassDelay=n end end) y += 40
makeButton(Main, "Sell All Non-Favorite", y, sellAllNonFavorite, Color3.fromRGB(180,80,80)) y += 40
makeToggle(Main, "Auto Sell (non-fav ≥ 60)", y, false, function(v) AutoSell.on=v end) y += 38
makeButton(Main, "Protect Tiers (L/M/S)", y, function()
    protectTiers.Legendary=true; protectTiers.Mythic=true; protectTiers.Secret=true
    protectByTiers()
end, Color3.fromRGB(90,120,200)) y += 40

-- Teleport dropdown (simple cycle)
local tpList, idx = {}, 1
for k,_ in pairs(islandCoords) do table.insert(tpList, k) end
table.sort(tpList)
local tpLabel = Instance.new("TextLabel", Main)
tpLabel.BackgroundTransparency = 1
tpLabel.Font = Enum.Font.GothamSemibold
tpLabel.TextScaled = true
tpLabel.TextColor3 = Color3.fromRGB(235,240,255)
tpLabel.Text = "Teleport: "..tpList[idx]
tpLabel.Size = UDim2.fromOffset(220, 30)
tpLabel.Position = UDim2.new(0, 15, 0, y)
local tpPrev = makeButton(Main, "◀", y, function()
    idx = (idx-2) % #tpList + 1
    tpLabel.Text = "Teleport: "..tpList[idx]
end, Color3.fromRGB(40,42,58))
tpPrev.Size = UDim2.fromOffset(50,30); tpPrev.Position = UDim2.new(0, 240, 0, y)
local tpGo = makeButton(Main, "Go", y, function()
    local name = tpList[idx]; local pos = islandCoords[name]
    local charFolder = workspace:FindFirstChild("Characters")
    local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 2))
    if hrp and pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0)) end
end, Color3.fromRGB(46,160,67))
tpGo.Size = UDim2.fromOffset(70,30); tpGo.Position = UDim2.new(0, 300, 0, y) y += 36

makeButton(Main, "Rejoin Server", y, function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, Color3.fromRGB(70,120,200)) y += 36
makeButton(Main, "Server Hop", y, function()
    local placeId = game.PlaceId
    local servers, cursor = {}, ""
    for _=1,3 do
        local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor~="" and("&cursor="..cursor) or "")
        local ok,res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if ok and res and res.data then
            for _,sv in ipairs(res.data) do
                if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then table.insert(servers, sv.id) end
            end
            cursor = res.nextPageCursor or ""
            if #servers>0 then break end
        else break end
    end
    if #servers>0 then TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1,#servers)], LocalPlayer) end
end, Color3.fromRGB(90,90,120)) y += 36

makeToggle(Main, "Anti-AFK", y, true, function(v) setAntiAFK(v) end) y += 38

-- HUD (bottom-right)
local HUD = Instance.new("TextLabel")
HUD.Parent = SG
HUD.AnchorPoint = Vector2.new(1,1)
HUD.Position = UDim2.new(1, -12, 1, -12)
HUD.Size = UDim2.fromOffset(360, 34)
HUD.BackgroundColor3 = Color3.fromRGB(21,24,37)
HUD.BackgroundTransparency = 0.25
HUD.Font = Enum.Font.GothamSemibold
HUD.TextScaled = true
HUD.TextColor3 = Color3.fromRGB(235,240,255)
HUD.TextXAlignment = Enum.TextXAlignment.Right
HUD.Text = "Rod: ?  |  C: -  |  B: -  |  OFF"
Instance.new("UICorner", HUD).CornerRadius = UDim.new(0,10)

local function updateHUD()
    local rn = getEquippedRodName() or "?"
    local on = AF.enabled and "ON" or "OFF"
    HUD.Text = string.format("Rod: %s  |  C: %.2fs  |  B: %.2fs  |  %s", rn, currentCustomDelay or 0, currentBypassDelay or 0, on)
end
RS.RenderStepped:Connect(updateHUD)

-- Rod watcher (update delays if GUI backpack changes)
task.spawn(function()
    local pg2 = LocalPlayer:WaitForChild("PlayerGui")
    local display = pg2:WaitForChild("Backpack"):WaitForChild("Display")
    display.ChildAdded:Connect(function() task.wait(0.05); refreshRodDelays(); updateHUD() end)
end)

-- Floating Toggle button (mobile)
do
    local TSG = Instance.new("ScreenGui")
    TSG.Name = "ZiaanHub_Toggle"
    TSG.ResetOnSpawn = false
    TSG.IgnoreGuiInset = true
    TSG.Parent = (gethui and gethui()) or pg

    local BTN = Instance.new("TextButton", TSG)
    BTN.AnchorPoint = Vector2.new(1,1)
    BTN.Position = UDim2.new(1, -14, 1, -14)
    BTN.Size = UDim2.fromOffset(180, 50)
    BTN.BackgroundColor3 = Color3.fromRGB(30,32,46)
    BTN.TextColor3 = Color3.fromRGB(235,240,255)
    BTN.Text = "📋  SEMBUNYIKAN MENU"
    BTN.Font = Enum.Font.GothamSemibold
    BTN.TextScaled = true
    Instance.new("UICorner", BTN).CornerRadius = UDim.new(0,10)

    local visible = true
    BTN.MouseButton1Click:Connect(function()
        visible = not visible
        SG.Enabled = visible
        BTN.Text = visible and "📋  SEMBUNYIKAN MENU" or "📋  TAMPILKAN MENU"
    end)
end

-- Optional: light blur for style
local Blur = Instance.new("BlurEffect"); Blur.Size = 0; Blur.Parent = Lighting
task.spawn(function()
    while SG and SG.Parent do
        Blur.Enabled = SG.Enabled
        Blur.Size = SG.Enabled and 16 or 0
        task.wait(0.1)
    end
end)

-- Finish: enable XP GUI if ada
local XPBar = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindChild("XP")
if XPBar then safepcall(function() XPBar.Enabled = true end) end

print("[ZiaanHub] GUI loaded. Enjoy!")
