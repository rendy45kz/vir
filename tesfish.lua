-- ==== XSX UI INIT (Android fix) ====
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local XSX = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/XSX-UI-Library/refs/heads/main/xsx%20lib.lua'))()

-- (Opsional) Tema
XSX.headerColor  = Color3.fromRGB(51,158,190)
XSX.companyColor = Color3.fromRGB(163,151,255)
XSX.acientColor  = Color3.fromRGB(159,115,255)

-- Beberapa build XSX crash kalau pakai Blur di mobile, jadi OFF
XSX:Init({
    version   = "1.7.x",
    title     = "ZiaanHub - Fish It",
    company   = "@ziaandev",
    keybind   = Enum.KeyCode.G, -- masih bisa buat PC
    BlurEffect = false
})

-- Auto-OPEN jendela (beberapa versi XSX start dalam keadaan minimize).
local function forceOpenXSX()
    -- cobain method umum yang sering dipakai di fork XSX
    for _, m in ipairs({"ToggleUI", "Toggle", "Open", "Show"}) do
        local f = XSX[m]
        if type(f) == "function" then
            pcall(function()
                -- panggil 2x kalau method-nya toggle untuk memastikan "ON"
                f(XSX) ; task.wait(0.05) ; f(XSX)
            end)
            break
        end
    end
    -- fallback: pastikan ScreenGui XSX enabled
    local gui = CoreGui:FindFirstChildWhichIsA("ScreenGui", true)
    if gui and gui.DisplayOrder ~= nil then
        gui.Enabled = true
        pcall(function() gui.DisplayOrder = 1_000_000 end)
    end
end
task.defer(forceOpenXSX)

-- Tombol melayang untuk Android (touch) agar bisa Show/Hide tanpa keyboard
local function makeMobileToggle()
    if not UserInputService.TouchEnabled then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZiaanHub_XSX_Toggle"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = (gethui and gethui()) or CoreGui

    local b = Instance.new("TextButton")
    b.Name = "ToggleBtn"
    b.AnchorPoint = Vector2.new(1,1)
    b.Position = UDim2.new(1, -14, 1, -14)
    b.Size = UDim2.fromOffset(160, 50)
    b.BackgroundColor3 = Color3.fromRGB(30,32,46)
    b.TextColor3 = Color3.fromRGB(235,240,255)
    b.Text = "📋  TAMPILKAN MENU"
    b.Font = Enum.Font.GothamSemibold
    b.TextScaled = true
    b.AutoButtonColor = true
    b.Parent = sg
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local visible = true
    local function toggle()
        visible = not visible
        -- coba panggil method yang ada
        for _, m in ipairs({"ToggleUI", "Toggle", "Open", "Show"}) do
            local f = XSX[m]
            if type(f) == "function" then pcall(f, XSX) end
        end
        b.Text = visible and "📋  SEMBUNYIKAN MENU" or "📋  TAMPILKAN MENU"
    end
    b.MouseButton1Click:Connect(toggle)

    -- pastikan awalnya kelihatan
    b.Text = "📋  SEMBUNYIKAN MENU"
end
task.defer(makeMobileToggle)

-- Watermark & FPS
XSX:Watermark("ZiaanHub")
local fpsWM = XSX:Watermark("FPS")
game:GetService("RunService").RenderStepped:Connect(function(dt)
    pcall(function() fpsWM:SetText("FPS: "..math.max(1, math.round(1/dt))) end)
end)
-- ==== END XSX UI INIT (Android fix) ====


-------------------------------------------
----- =======[ Services & Globals ] =======
-------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

-- net root (sleitnick_net)
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

-- Optional requires (guarded)
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

local state = {
    AutoFavourite = false,
    AutoSell = false,
    AntiAFK = true,
}

-------------------------------------------
----- =======[ Remotes / UI refs ] =======
-------------------------------------------
local RF_ChargeFishingRod = net:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame  = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_FishingCompleted = net:WaitForChild("RE/FishingCompleted")
local RE_EquipHotbar      = net:WaitForChild("RE/EquipToolFromHotbar")
local RF_SellAll          = net:FindFirstChild("RF/SellAllItems")

local XPBar = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("XP")
if XPBar then task.spawn(function() XPBar.Enabled = true end) end

-------------------------------------------
----- =======[ Anti-AFK ] =======
-------------------------------------------
local AFKConnection
local function setAntiAFK(enabled)
    state.AntiAFK = enabled
    if enabled then
        if AFKConnection then AFKConnection:Disconnect() end
        AFKConnection = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end)
    else
        if AFKConnection then AFKConnection:Disconnect(); AFKConnection = nil end
    end
end
setAntiAFK(true)

-------------------------------------------
----- =======[ Auto Reconnect ] =======
-------------------------------------------
local PlaceId = game.PlaceId
task.spawn(function()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(PlaceId)
        end
    end
end)
Players.LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then
        TeleportService:Teleport(PlaceId)
    end
end)

-------------------------------------------
----- =======[ Animations ] =======
-------------------------------------------
local RodIdle  = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("FishingRodReelIdle")
local RodReel  = ReplicatedStorage.Modules.Animations:WaitForChild("EasyFishReelStart")
local RodShake = ReplicatedStorage.Modules.Animations:WaitForChild("CastFromFullChargePosition1Hand")

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local animator  = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShakeAnim = animator:LoadAnimation(RodShake)
local RodIdleAnim  = animator:LoadAnimation(RodIdle)
local RodReelAnim  = animator:LoadAnimation(RodReel)

-------------------------------------------
----- =======[ Boost FPS ] =======
-------------------------------------------
local function BoostFPS()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then effect.Enabled = false end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end
BoostFPS()

-------------------------------------------
----- =======[ Auto-rod delays ] =======
-------------------------------------------
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

local currentCustomDelay = 2.5
local currentBypassDelay = 1.2
local perfectCast        = true

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

local function refreshRodDelays(showNotify)
    local rodName = getEquippedRodName()
    if rodName and RodDelays[rodName] then
        currentCustomDelay = RodDelays[rodName].custom
        currentBypassDelay = RodDelays[rodName].bypass
        if showNotify then
            NotifySuccess("Rod Detected", string.format("%s | Delay: %.2fs | Bypass: %.2fs", rodName, currentCustomDelay, currentBypassDelay))
        end
    else
        currentCustomDelay = 10
        currentBypassDelay = 1
        if showNotify then NotifyWarning("Rod Detection", "No known rod found. Using safe defaults.") end
    end
end

do
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local display = pg:WaitForChild("Backpack"):WaitForChild("Display")
    display.ChildAdded:Connect(function()
        task.wait(0.05)
        refreshRodDelays(false)
    end)
end

-------------------------------------------
----- =======[ Auto Fishing V2 ] =======
-------------------------------------------
local FuncAutoFish = { enabled=false, fishingActive=false }

local RE_RepText =
    net:FindFirstChild("RE/ReplicateTextEffect")
    or (ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:FindFirstChild("RE/ReplicateTextEffect"))

if RE_RepText then
    RE_RepText.OnClientEvent:Connect(function(data)
        if not (FuncAutoFish.enabled and FuncAutoFish.fishingActive) then return end
        if not (data and data.TextData and data.TextData.EffectType == "Exclaim") then return end
        local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
        if head and data.Container == head then
            task.spawn(function()
                task.wait(currentBypassDelay)
                pcall(function() RE_FishingCompleted:FireServer() end)
            end)
        end
    end)
end

local function StartAutoFish()
    if FuncAutoFish.enabled then return end
    FuncAutoFish.enabled = true
    refreshRodDelays(true)
    task.spawn(function()
        while FuncAutoFish.enabled do
            pcall(function()
                FuncAutoFish.fishingActive = true

                if RE_EquipHotbar then RE_EquipHotbar:FireServer(1) end
                task.wait(0.1)

                local ts = workspace:GetServerTimeNow()
                RF_ChargeFishingRod:InvokeServer(ts)
                task.wait(0.4)
                RodShakeAnim:Play()
                pcall(function() RF_ChargeFishingRod:InvokeServer(workspace:GetServerTimeNow()) end)

                local baseX, baseY = -0.7499996423721313, 1
                local x, y
                if perfectCast then
                    x = baseX + (math.random(-500, 500) / 10000000)
                    y = baseY + (math.random(-500, 500) / 10000000)
                else
                    x = math.random(-1000, 1000) / 1000
                    y = math.random(0, 1000) / 1000
                end

                RodIdleAnim:Play()
                RF_RequestMinigame:InvokeServer(x, y)

                task.wait(currentCustomDelay)
                FuncAutoFish.fishingActive = false
                refreshRodDelays(false)
            end)
            task.wait(0.08) -- throttle (Android battery friendly)
        end
    end)
end

local function StopAutoFish()
    FuncAutoFish.enabled = false
    FuncAutoFish.fishingActive = false
    RodIdleAnim:Stop(); RodShakeAnim:Stop(); RodReelAnim:Stop()
end

-------------------------------------------
----- =======[ TABS & SECTIONS (XSX) ] =======
-------------------------------------------
local TabAuto    = XSX:NewTab("Auto Fishing")
local TabUtility = XSX:NewTab("Utility")
local TabSettings= XSX:NewTab("Settings")

-- Auto Fishing: main
TabAuto:NewSection("Fishing Automation")

-- Bypass Delay input
TabAuto:NewTextbox("Bypass Delay (sec)", "1.45", "e.g. 1.45", "small", true, false, function(val)
    local n = tonumber(val)
    if n then
        currentBypassDelay = n
        NotifySuccess("Bypass Delay", "Set to "..n)
    else
        NotifyError("Invalid", "Input bukan angka")
    end
end)

-- Auto Fish toggle
TabAuto:NewToggle("Auto Fish V2 (Rod Delay)", false, function(v)
    if v then StartAutoFish() else StopAutoFish() end
end):AddKeybind(Enum.KeyCode.RightAlt)

-- Perfect Cast toggle
TabAuto:NewToggle("Auto Perfect Cast", true, function(v)
    perfectCast = v
end)

-- Auto Sell / Favorite
TabAuto:NewSection("Sell & Favorite")

local lastSellTime = 0
local AUTO_SELL_THRESHOLD = 60
local AUTO_SELL_DELAY = 60

local function startAutoSell()
    task.spawn(function()
        while state.AutoSell do
            pcall(function()
                if not Replion then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end
                local unfav = 0
                for _, item in ipairs(items) do
                    if not item.Favorited then unfav += (item.Count or 1) end
                end
                if unfav >= AUTO_SELL_THRESHOLD and os.time() - lastSellTime >= AUTO_SELL_DELAY then
                    if RF_SellAll then
                        NotifyInfo("Auto Sell", "Selling non-favorited items...")
                        pcall(function() RF_SellAll:InvokeServer() end)
                        lastSellTime = os.time()
                    end
                end
            end)
            task.wait(10)
        end
    end)
end

local allowedTiers = { Secret=true, Mythic=true, Legendary=true }
local function startAutoFavourite()
    task.spawn(function()
        while state.AutoFavourite do
            pcall(function()
                if not (Replion and ItemUtility) then return end
                local DataReplion = Replion.Client:WaitReplion("Data")
                local items = DataReplion and DataReplion:Get({"Inventory","Items"})
                if type(items) ~= "table" then return end
                for _, item in ipairs(items) do
                    local base = ItemUtility:GetItemData(item.Id)
                    if base and base.Data and allowedTiers[base.Data.Tier] and not item.Favorited then
                        item.Favorited = true
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

TabAuto:NewToggle("Auto Sell (non-favorit > 60)", false, function(v)
    state.AutoSell = v
    if v then startAutoSell(); NotifySuccess("Auto Sell","Enabled") else NotifyWarning("Auto Sell","Disabled") end
end)

TabAuto:NewSection("Auto Favorite System")
TabAuto:NewLabel("Proteksi ikan berharga: Secret / Mythic / Legendary")
TabAuto:NewToggle("Enable Auto Favorite", false, function(v)
    state.AutoFavourite = v
    if v then startAutoFavourite(); NotifySuccess("Auto Favorite","Enabled") else NotifyWarning("Auto Favorite","Disabled") end
end)

-- Manual Actions
TabAuto:NewSection("Manual Actions")
TabAuto:NewLabel("Aksi manual: jual semua & enchant")

local function sellAllFishes()
    if not RF_SellAll then return NotifyError("Sell All", "Server function not available") end
    NotifyInfo("Selling...", "Selling all fish, please wait...", 3)
    local ok, err = pcall(function() RF_SellAll:InvokeServer() end)
    if ok then NotifySuccess("Sold!", "All fish sold successfully.", 3) else NotifyError("Sell Failed", tostring(err)) end
end
TabAuto:NewButton("Sell All Fishes", function()
    sellAllFishes()
end)

TabAuto:NewButton("Auto Enchant Rod (slot 5)", function()
    local ENCHANT_POSITION = Vector3.new(3231, -1303, 1402)
    local char = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(LocalPlayer.Name)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return NotifyError("Auto Enchant Rod", "Character HRP not found.") end

    NotifyInfo("Preparing Enchant...", "Letakkan Enchant Stone di slot 5.", 5)
    task.wait(2)

    local display = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Backpack"):WaitForChild("Display")
    local children = display:GetChildren()
    local slotIndex = 5
    local slot = children[slotIndex]
    local itemName = slot and slot:FindFirstChild("Inner") and slot.Inner:FindFirstChild("Tags") and slot.Inner.Tags:FindFirstChild("ItemName")
    if not (itemName and itemName.Text and itemName.Text:lower():find("enchant")) then
        return NotifyError("Auto Enchant Rod", "Slot 5 tidak berisi Enchant Stone.")
    end

    NotifyInfo("Enchanting...", "Proses enchanting...")
    local original = hrp.Position
    task.wait(0.5)
    hrp.CFrame = CFrame.new(ENCHANT_POSITION + Vector3.new(0,5,0))
    task.wait(1)
    local RE_ActivateEnchant = net:FindFirstChild("RE/ActivateEnchantingAltar")
    pcall(function() RE_EquipHotbar:FireServer(slotIndex) end)
    task.wait(0.4)
    if RE_ActivateEnchant then pcall(function() RE_ActivateEnchant:FireServer() end) end
    task.wait(7)
    NotifySuccess("Enchant", "Done!")
    pcall(function() hrp.CFrame = CFrame.new(original + Vector3.new(0,3,0)) end)
end)

-------------------------------------------
----- =======[ Utility: Teleports ] =======
-------------------------------------------
TabUtility:NewSection("Teleport Utility")
TabUtility:NewLabel("Quick Teleport System")

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

local islandList = {}
for name,_ in pairs(islandCoords) do table.insert(islandList, name) end
table.sort(islandList)

TabUtility:NewSelector("Island Teleport", islandList[1], islandList, function(selected)
    local pos = islandCoords[selected]
    if not pos then return end
    local ok, err = pcall(function()
        local charFolder = workspace:WaitForChild("Characters", 5)
        local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3))
        if not hrp then error("HumanoidRootPart not found") end
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
    end)
    if ok then NotifySuccess("Teleported!", "Now at "..selected) else NotifyError("Teleport Failed", tostring(err)) end
end)

local eventsList = { "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", "Ghost Worm", "Meteor Rain" }
TabUtility:NewSelector("Event Teleport", eventsList[1], eventsList, function(option)
    local props = workspace:FindFirstChild("Props")
    if props and props:FindFirstChild(option) and props[option]:FindFirstChild("Fishing Boat") then
        local boat = props[option]["Fishing Boat"]
        local cf = boat:GetPivot()
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = cf + Vector3.new(0,15,0); NotifySuccess("Event Available!", "Teleported To ".. option) end
    else
        NotifyError("Event Not Found", option .. " Not Found!")
    end
end)

-- NPC Teleport
local npcFolder = ReplicatedStorage:FindFirstChild("NPC") or ReplicatedStorage:WaitForChild("NPC")
local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
    if npc:IsA("Model") then
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if hrp then table.insert(npcList, npc.Name) end
    end
end

if #npcList > 0 then
    TabUtility:NewSelector("NPC Teleport", npcList[1], npcList, function(name)
        local npc = npcFolder:FindFirstChild(name)
        if npc and npc:IsA("Model") then
            local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            local charFolder = workspace:FindFirstChild("Characters")
            local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
            local my = char and char:FindFirstChild("HumanoidRootPart")
            if my and hrp then my.CFrame = hrp.CFrame + Vector3.new(0,3,0); NotifySuccess("Teleported!", "Near: "..name) end
        end
    end)
end

-- Server utils
TabUtility:NewSection("Server Utility")
local function Rejoin()
    local player = Players.LocalPlayer
    if player then TeleportService:Teleport(game.PlaceId, player) end
end
local function ServerHop()
    local placeId = game.PlaceId
    local servers, cursor = {}, ""
    for _ = 1, 3 do
        local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and ("&cursor="..cursor) or "")
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if success and result and result.data then
            for _, server in pairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then table.insert(servers, server.id) end
            end
            cursor = result.nextPageCursor or ""
            if #servers > 0 then break end
        else
            cursor = ""
        end
        if cursor == "" then break end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
    else
        NotifyError("Server Hop Failed", "No servers available or all full!")
    end
end
TabUtility:NewButton("Rejoin Server", Rejoin)
TabUtility:NewButton("Server Hop", ServerHop)

-- Visual
TabUtility:NewSection("Visual Utility")
TabUtility:NewLabel("Perbaikan visual & performa (Delta)")
TabUtility:NewButton("HDR Shader", function()
    local ok, src = pcall(game.HttpGet, game, "https://pastebin.com/raw/avvr1gTW")
    if ok and type(src)=="string" and #src>0 then
        local ok2, fn = pcall(loadstring, src)
        if ok2 then pcall(fn) else NotifyError("HDR Shader", "Loadstring error.") end
    else
        NotifyError("HDR Shader", "Gagal mengunduh shader.")
    end
end)

-------------------------------------------
----- =======[ Settings ] =======
-------------------------------------------
TabSettings:NewSection("Anti-AFK System")
TabSettings:NewLabel("Cegah kick AFK")
TabSettings:NewToggle("Anti-AFK", true, function(v)
    setAntiAFK(v)
    if v then NotifySuccess("Anti-AFK","Activated") else NotifyWarning("Anti-AFK","Deactivated") end
end)

TabSettings:NewSection("Script Information")
TabSettings:NewLabel("ZiaanHub - Fish It")
TabSettings:NewLabel("Version: XSX Edition 1.7.x")
TabSettings:NewLabel("Developer: @ziaandev")
TabSettings:NewLabel("Status: Operational")

NotifySuccess("ZiaanHub - Fish It", "Script loaded successfully! Enjoy your fishing.", 5)
