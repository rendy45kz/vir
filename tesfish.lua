--[[
  ZiaanHub - Fish It (Premium, Delta-ready)
  Version: v1.8.1-Delta
  - Delta compatibility: robust WindUI loader (multi-URL fallback) + safe pcall guards
  - Premium pack: Adaptive Delay (EMA + jitter), Rod Profiles Manager, Auto Sell/Favorite, Utilities
]]

-------------------------------------------
----- =======[ Safe Loader / WindUI ] =======
-------------------------------------------
local function safe_httpget(url)
    local ok, res = pcall(game.HttpGet, game, url)
    if ok and type(res) == "string" and #res > 0 then return res end
    return nil
end

local function try_loadstring(src)
    if not src then return nil end
    local ok, fn = pcall(loadstring, src)
    if ok and type(fn) == "function" then
        local ok2, lib = pcall(fn)
        if ok2 and lib then return lib end
    end
    return nil
end

-- WindUI URLs (fallback berurutan, hindari redirect GitHub)
local WINDUI_URLS = {
    "https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua",
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
}

local WindUI
for _, u in ipairs(WINDUI_URLS) do
    WindUI = try_loadstring(safe_httpget(u))
    if WindUI then break end
end

-- Fallback mini-notifier jika WindUI gagal
local MiniNotify = {}
function MiniNotify.NotifyOK(t, c) print("[OK] "..(t or "Info")..": "..(c or "")) end
function MiniNotify.NotifyWarn(t, c) warn("[WARN] "..(t or "Warn")..": "..(c or "")) end
function MiniNotify.NotifyErr(t, c) warn("[ERR] "..(t or "Error")..": "..(c or "")) end
function MiniNotify.NotifyInfo(t, c) print("[INFO] "..(t or "Info")..": "..(c or "")) end

local hasUI = WindUI ~= nil

-------------------------------------------
----- =======[ Services & Globals ] =======
-------------------------------------------
local Players            = game:GetService("Players")
local LocalPlayer        = Players.LocalPlayer
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local TeleportService    = game:GetService("TeleportService")
local Lighting           = game:GetService("Lighting")
local VirtualUser        = game:GetService("VirtualUser")

-- net root (sleitnick_net)
local net = ReplicatedStorage:WaitForChild("Packages")
  :WaitForChild("_Index")
  :WaitForChild("sleitnick_net@0.2.0")
  :WaitForChild("net")

-- Optional libs (safe require)
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

-- Notifs switches
local Notifs = {
  WBN = true, FavBlockNotif = true, FishBlockNotif = true,
  DelayBlockNotif = true, AFKBN = true, APIBN = true
}

-- Feature state
local state = { AutoFavourite = false, AutoSell = false, AntiAFK = true }

-------------------------------------------
----- =======[ Remotes / UI ] =======
-------------------------------------------
local RF_ChargeFishingRod = net:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame  = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_FishingCompleted = net:WaitForChild("RE/FishingCompleted")
local RE_EquipHotbar      = net:WaitForChild("RE/EquipToolFromHotbar")
local RF_SellAll          = net:FindFirstChild("RF/SellAllItems")

local XPBar = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("XP")
if XPBar then task.spawn(function() XPBar.Enabled = true end) end

-------------------------------------------
----- =======[ Notify Helpers ] =======
-------------------------------------------
local function NotifySuccess(title, message, duration)
    if hasUI then
        WindUI:Notify({ Title = title, Content = message, Duration = duration or 4, Icon = "circle-check" })
    else
        MiniNotify.NotifyOK(title, message)
    end
end
local function NotifyError(title, message, duration)
    if hasUI then
        WindUI:Notify({ Title = title, Content = message, Duration = duration or 5, Icon = "ban" })
    else
        MiniNotify.NotifyErr(title, message)
    end
end
local function NotifyInfo(title, message, duration)
    if hasUI then
        WindUI:Notify({ Title = title, Content = message, Duration = duration or 4, Icon = "info" })
    else
        MiniNotify.NotifyInfo(title, message)
    end
end
local function NotifyWarning(title, message, duration)
    if hasUI then
        WindUI:Notify({ Title = title, Content = message, Duration = duration or 4, Icon = "triangle-alert" })
    else
        MiniNotify.NotifyWarn(title, message)
    end
end

-------------------------------------------
----- =======[ Window / Tabs ] =======
-------------------------------------------
local Window, AutoFishTab, UtilityTab, SettingsTab, PremiumTab
if hasUI then
    Window = WindUI:CreateWindow({
        Title = "ZiaanHub - Fish It (Delta)",
        Icon = "fish",
        Author = "by @ziaandev",
        Folder = "ZiaanHub",
        Size = UDim2.fromOffset(600, 450),
        Theme = "Indigo",
        KeySystem = false,
    })
    pcall(function() Window:SetToggleKey(Enum.KeyCode.G) end)
    pcall(function() WindUI:SetNotificationLower(true) end)
    NotifySuccess("ZiaanHub - Fish It", "UI loaded successfully!")

    AutoFishTab = Window:Tab({ Title = "Auto Fishing", Icon = "fish" })
    UtilityTab  = Window:Tab({ Title = "Utility", Icon = "settings" })
    SettingsTab = Window:Tab({ Title = "Settings", Icon = "user-cog" })
    PremiumTab  = Window:Tab({ Title = "Premium",  Icon = "diamond" })
else
    -- tanpa UI, kita tetap jalan (headless)
    NotifyWarning("ZiaanHub - Fish It", "WindUI gagal dimuat. Menggunakan mode minimal (tanpa UI).")
end

-------------------------------------------
----- =======[ Anti-AFK (unified) ] =======
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
local function AutoReconnect()
  while task.wait(5) do
    if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
      TeleportService:Teleport(PlaceId)
    end
  end
end
Players.LocalPlayer.OnTeleport:Connect(function(teleportState)
  if teleportState == Enum.TeleportState.Failed then
    TeleportService:Teleport(PlaceId)
  end
end)
task.spawn(AutoReconnect)

-------------------------------------------
----- =======[ Animations ] =======
-------------------------------------------
local RodIdle  = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("FishingRodReelIdle")
local RodReel  = ReplicatedStorage.Modules.Animations:WaitForChild("EasyFishReelStart")
local RodShake = ReplicatedStorage.Modules.Animations:WaitForChild("CastFromFullChargePosition1Hand")

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

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
----- =======[ Rod Delay Profile ] =======
-------------------------------------------
local RodDelays = {
  -- S Tier
  ["Element Rod"]   = {custom = 0.95, bypass = 1.30},
  ["Bamboo Rod"]    = {custom = 1.05, bypass = 1.35},
  ["Ghostfinn Rod"] = {custom = 1.10, bypass = 1.45},
  ["Angler Rod"]    = {custom = 1.12, bypass = 1.45},
  ["Ares Rod"]      = {custom = 1.12, bypass = 1.45},

  -- A Tier
  ["Astral Rod"]      = {custom = 1.90, bypass = 1.45},
  ["Hazmat Rod"]      = {custom = 2.00, bypass = 1.60},
  ["Fluorescent Rod"] = {custom = 2.10, bypass = 1.80},
  ["Chrome Rod"]      = {custom = 2.30, bypass = 2.00},

  -- B Tier
  ["Hyper Rod"]     = {custom = 2.60, bypass = 2.20}, -- Gamepass
  ["Angelic Rod"]   = {custom = 2.80, bypass = 2.30}, -- Gamepass
  ["Gold Rod"]      = {custom = 3.00, bypass = 2.50}, -- Gamepass
  ["Steampunk Rod"] = {custom = 2.50, bypass = 2.30},
  ["Midnight Rod"]  = {custom = 3.30, bypass = 3.40},
  ["Lucky Rod"]     = {custom = 3.50, bypass = 3.60},

  -- C Tier
  ["Ice Rod"]      = {custom = 3.70, bypass = 3.60},
  ["Grass Rod"]    = {custom = 3.80, bypass = 3.90},
  ["Demascus Rod"] = {custom = 3.90, bypass = 3.80},
  ["Lava Rod"]     = {custom = 4.20, bypass = 4.10},

  -- D Tier
  ["Carbon Rod"]  = {custom = 4.00, bypass = 3.80},
  ["Luck Rod"]    = {custom = 4.20, bypass = 4.10},
  ["Starter Rod"] = {custom = 4.30, bypass = 4.20},
  ["Toy Rod"]     = {custom = 4.40, bypass = 4.20},
}

local currentCustomDelay  = 2.5
local currentBypassDelay  = 1.2
local perfectCast         = true

-------------------------------------------
----- =======[ Rod Profiles Manager ] =======
-------------------------------------------
local function getEquippedRodName()
  local pg = LocalPlayer:FindFirstChild("PlayerGui"); if not pg then return nil end
  local backpack = pg:FindFirstChild("Backpack"); if not backpack then return nil end
  local display = backpack:FindFirstChild("Display"); if not display then return nil end
  for _, tile in ipairs(display:GetChildren()) do
    local ok, label = pcall(function() return tile.Inner.Tags.ItemName end)
    if ok and label and label:IsA("TextLabel") then
      local name = label.Text
      if RodDelays[name] then return name end
    end
  end
  return nil
end

local RodOverrides = {}   -- runtime overrides { [rod] = {custom, bypass} }
local function setRodOverride(name, custom, bypass) RodOverrides[name] = {custom = custom, bypass = bypass} end
local function getActiveDelays(name)
  local base = RodDelays[name]
  local over = RodOverrides[name]
  if over then
    return over.custom or (base and base.custom) or currentCustomDelay,
           over.bypass or (base and base.bypass) or currentBypassDelay
  end
  if base then return base.custom, base.bypass end
  return currentCustomDelay, currentBypassDelay
end

local function refreshRodDelays(optNotify)
  local rodName = getEquippedRodName()
  if rodName then
    local c, b = getActiveDelays(rodName)
    currentCustomDelay, currentBypassDelay = c, b
    if optNotify then
      NotifySuccess("Rod Detected", string.format("%s | Delay: %.2fs | Bypass: %.2fs", rodName, currentCustomDelay, currentBypassDelay))
    end
  else
    currentCustomDelay = 10
    currentBypassDelay = 1
    if optNotify then NotifyWarning("Rod Detection", "No known rod found. Using safe defaults.") end
  end
end

local function setupRodWatcher()
  local pg = LocalPlayer:WaitForChild("PlayerGui")
  local display = pg:WaitForChild("Backpack"):WaitForChild("Display")
  display.ChildAdded:Connect(function()
    task.wait(0.05)
    refreshRodDelays(false)
  end)
end
setupRodWatcher()

-------------------------------------------
----- =======[ Adaptive Delay Calibrator ] =======
-------------------------------------------
local Premium = {
  Enabled       = true,
  AdaptiveDelay = true,
  AdaptiveAlpha = 0.35,
  SafetyCut     = 0.08,
  Jitter        = true,
  JitterMax     = 0.035,
}

local LastCastTS = nil
local RodEMA = {} -- { [rod] = {ema, samples} }
local function now() return os.clock() end
local function markCastStart() LastCastTS = now() end

local function onExclaimForAdaptive()
  if not (Premium.Enabled and Premium.AdaptiveDelay) then return end
  local rodName = getEquippedRodName()
  if not (rodName and LastCastTS) then return end

  local dt = now() - LastCastTS
  local r = RodEMA[rodName] or {ema = dt, samples = 0}
  r.ema = (Premium.AdaptiveAlpha * dt) + ((1 - Premium.AdaptiveAlpha) * (r.ema or dt))
  r.samples = math.min((r.samples or 0) + 1, 9999)
  RodEMA[rodName] = r

  local recCustom = math.max(0.45, r.ema - Premium.SafetyCut)
  local recBypass = math.clamp((r.ema * 0.12), 0.10, 0.40)

  if Premium.Jitter then
    local j = (math.random() * 2 - 1) * Premium.JitterMax
    recCustom = math.max(0.40, recCustom + j)
  end

  setRodOverride(rodName, recCustom, recBypass)
  currentCustomDelay, currentBypassDelay = recCustom, recBypass

  if r.samples % 5 == 0 then
    NotifyInfo("Adaptive Delay", string.format("%s → custom %.2fs | bypass %.2fs (n=%d)",
      rodName, recCustom, recBypass, r.samples), 3)
  end
end

-------------------------------------------
----- =======[ Auto Fishing V2 ] =======
-------------------------------------------
local FuncAutoFish = { enabled = false, fishingActive = false }

local RE_ReplicateTextEffect =
  net:FindFirstChild("RE/ReplicateTextEffect")
  or (ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:FindFirstChild("RE/ReplicateTextEffect"))

if RE_ReplicateTextEffect then
  RE_ReplicateTextEffect.OnClientEvent:Connect(function(data)
    if not (FuncAutoFish.enabled and FuncAutoFish.fishingActive) then return end
    if not (data and data.TextData and data.TextData.EffectType == "Exclaim") then return end
    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if head and data.Container == head then
      onExclaimForAdaptive()
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
        markCastStart()
        RF_RequestMinigame:InvokeServer(x, y)

        task.wait(currentCustomDelay)
        FuncAutoFish.fishingActive = false
        refreshRodDelays(false)
      end)
      task.wait(0.05)
    end
  end)
end

local function StopAutoFish()
  FuncAutoFish.enabled = false
  FuncAutoFish.fishingActive = false
  RodIdleAnim:Stop(); RodShakeAnim:Stop(); RodReelAnim:Stop()
end

-------------------------------------------
----- =======[ UI: Auto Fishing ] =======
-------------------------------------------
if hasUI then
  local AutoFishSection = AutoFishTab:Section({ Title = "Fishing Automation", Icon = "fish" })

  AutoFishSection:Input({
    Title = "Bypass Delay",
    Content = "Delay sebelum kirim FishingCompleted",
    Placeholder = "Contoh: 1.45",
    Callback = function(value)
      if Notifs.DelayBlockNotif then Notifs.DelayBlockNotif = false return end
      local number = tonumber(value)
      if number then currentBypassDelay = number; NotifySuccess("Bypass Delay", "Set to ".. number)
      else NotifyError("Invalid Input", "Input bukan angka") end
    end,
  })

  AutoFishSection:Toggle({
    Title = "Auto Fish V2 (Rod Delay)",
    Content = "Auto fishing dengan delay per rod",
    Callback = function(val) if val then StartAutoFish() else StopAutoFish() end end
  })

  AutoFishSection:Toggle({
    Title = "Auto Perfect Cast",
    Content = "Selalu cast sempurna",
    Value = true,
    Callback = function(v) perfectCast = v end
  })

  -- Override aktif
  AutoFishSection:Label({ Title = "Profil Rod Aktif", Content = "Diset otomatis atau manual override" })
  AutoFishSection:Input({
    Title = "Set Custom Delay (Rod Aktif)",
    Content = "Detik, contoh: 1.45",
    Placeholder = "1.45",
    Callback = function(v)
      local num = tonumber(v); local name = getEquippedRodName()
      if name and num then local _, b = getActiveDelays(name); setRodOverride(name, num, b); refreshRodDelays(true)
      else NotifyError("Rod Override", "Tidak ada rod terdeteksi atau input bukan angka") end
    end
  })
  AutoFishSection:Input({
    Title = "Set Bypass Delay (Rod Aktif)",
    Content = "Detik, contoh: 1.30",
    Placeholder = "1.30",
    Callback = function(v)
      local num = tonumber(v); local name = getEquippedRodName()
      if name and num then local c, _ = getActiveDelays(name); setRodOverride(name, c, num); refreshRodDelays(true)
      else NotifyError("Rod Override", "Tidak ada rod terdeteksi atau input bukan angka") end
    end
  })
end

-------------------------------------------
----- =======[ Auto Sell / Favourite ] =======
-------------------------------------------
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

local allowedTiers = { Secret = true, Mythic = true, Legendary = true }
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

if hasUI then
  local AutoFishSection = AutoFishTab:Section({ Title = "Sell & Favorite", Icon = "star" })
  AutoFishSection:Toggle({
    Title = "Auto Sell",
    Content = "Jual otomatis ikan non-favorit saat > 60",
    Callback = function(v)
      state.AutoSell = v
      if v then startAutoSell(); NotifySuccess("Auto Sell", "Enabled") else NotifyWarning("Auto Sell", "Disabled") end
    end
  })
  AutoFishSection:Toggle({
    Title = "Enable Auto Favorite",
    Content = "Favoritkan Secret/Mythic/Legendary",
    Callback = function(v)
      state.AutoFavourite = v
      if v then startAutoFavourite(); NotifySuccess("Auto Favorite", "Enabled") else NotifyWarning("Auto Favorite", "Disabled") end
    end
  })
end

-------------------------------------------
----- =======[ Manual Actions ] =======
-------------------------------------------
local function sellAllFishes()
  if not RF_SellAll then return NotifyError("Sell All", "Server function not available") end
  NotifyInfo("Selling...", "Selling all fish, please wait...", 3)
  local ok, err = pcall(function() RF_SellAll:InvokeServer() end)
  if ok then NotifySuccess("Sold!", "All fish sold successfully.", 3) else NotifyError("Sell Failed", tostring(err)) end
end

if hasUI then
  local ManualSection = UtilityTab:Section({ Title = "Manual Actions", Icon = "hand" })
  ManualSection:Button({ Title = "Sell All Fishes", Content = "Jual semua ikan non-favorit", Callback = sellAllFishes })

  ManualSection:Button({
    Title = "Auto Enchant Rod",
    Content = "Enchant rod menggunakan item di slot 5",
    Callback = function()
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
    end
  })
end

-------------------------------------------
----- =======[ Utility: Teleports ] =======
-------------------------------------------
local islandCoords = {
  ["Weather Machine"] = Vector3.new(-1471, -3, 1929),
  ["Esoteric Depths"] = Vector3.new(3157, -1303, 1439),
  ["Tropical Grove"] = Vector3.new(-2038, 3, 3650),
  ["Stingray Shores"] = Vector3.new(-32, 4, 2773),
  ["Kohana Volcano"] = Vector3.new(-519, 24, 189),
  ["Coral Reefs"] = Vector3.new(-3095, 1, 2177),
  ["Crater Island"] = Vector3.new(968, 1, 4854),
  ["Kohana"] = Vector3.new(-658, 3, 719),
  ["Winter Fest"] = Vector3.new(1611, 4, 3280),
  ["Isoteric Island"] = Vector3.new(1987, 4, 1400),
  ["Treasure Hall"] = Vector3.new(-3600, -267, -1558),
  ["Lost Shore"] = Vector3.new(-3663, 38, -989),
  ["Sishypus Statue"] = Vector3.new(-3792, -135, -986),
}

if hasUI then
  local TeleportSection = UtilityTab:Section({ Title = "Teleport Utility", Icon = "map-pin" })
  TeleportSection:Paragraph({ Title = "Quick Teleport System", Content = "Travel cepat ke berbagai lokasi" })

  local islandNames = {}
  for name,_ in pairs(islandCoords) do table.insert(islandNames, name) end
  table.sort(islandNames)

  TeleportSection:Dropdown({
    Title = "Island Teleport",
    Content = "Pilih pulau",
    Values = islandNames,
    Callback = function(selected)
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
    end
  })

  local eventsList = { "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", "Ghost Worm", "Meteor Rain" }
  TeleportSection:Dropdown({
    Title = "Event Teleport",
    Content = "Teleport ke event aktif",
    Values = eventsList,
    Callback = function(option)
      local props = workspace:FindFirstChild("Props")
      if props and props:FindFirstChild(option) and props[option]:FindFirstChild("Fishing Boat") then
        local boat = props[option]["Fishing Boat"]
        local cf = boat:GetPivot()
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = cf + Vector3.new(0,15,0); NotifySuccess("Event Available!", "Teleported To ".. option) end
      else
        NotifyError("Event Not Found", option .. " Not Found!")
      end
    end
  })

  -- NPC Teleport
  local npcFolder = ReplicatedStorage:FindFirstChild("NPC") or ReplicatedStorage:WaitForChild("NPC")
  local npcList = {}
  for _, npc in pairs(npcFolder:GetChildren()) do
    if npc:IsA("Model") then
      local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
      if hrp then table.insert(npcList, npc.Name) end
    end
  end
  TeleportSection:Dropdown({
    Title = "NPC Teleport",
    Content = "Teleport ke NPC",
    Values = npcList,
    Callback = function(name)
      local npc = npcFolder:FindFirstChild(name)
      if npc and npc:IsA("Model") then
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        local charFolder = workspace:FindFirstChild("Characters")
        local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
        local my = char and char:FindFirstChild("HumanoidRootPart")
        if my and hrp then my.CFrame = hrp.CFrame + Vector3.new(0,3,0); NotifySuccess("Teleported!", "Near: "..name) end
      end
    end
  })
end

-------------------------------------------
----- =======[ Utility: Server ] =======
-------------------------------------------
local function Rejoin()
  local player = Players.LocalPlayer
  if player then TeleportService:Teleport(game.PlaceId, player) end
end

local function ServerHop()
  local placeId = game.PlaceId
  local servers = {}
  local cursor = ""
  for attempt = 1, 3 do
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
  if #servers > 0 then TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
  else NotifyError("Server Hop Failed", "No servers available or all full!") end
end

if hasUI then
  local ServerSection = UtilityTab:Section({ Title = "Server Utility", Icon = "server" })
  ServerSection:Button({ Title = "Rejoin Server", Content = "Rejoin current server", Callback = Rejoin })
  ServerSection:Button({ Title = "Server Hop", Content = "Join a new server", Callback = ServerHop })
end

-------------------------------------------
----- =======[ Visual Button ] =======
-------------------------------------------
if hasUI then
  local VisualSection = UtilityTab:Section({ Title = "Visual Utility", Icon = "eye" })
  VisualSection:Button({ Title = "HDR Shader", Content = "Apply HDR visual enhancements", Callback = function()
    local src = safe_httpget("https://pastebin.com/raw/avvr1gTW")
    if src then try_loadstring(src) else NotifyError("HDR Shader", "Gagal mengunduh shader.") end
  end })
end

-------------------------------------------
----- =======[ Settings ] =======
-------------------------------------------
if hasUI then
  local ConfigSection = SettingsTab:Section({ Title = "Configuration", Icon = "save" })
  local ConfigManager = Window.ConfigManager
  local myConfig = ConfigManager:CreateConfig("ZiaanHubConfig")
  ConfigSection:Button({ Title = "Save Settings", Content = "Simpan konfigurasi", Callback = function()
    myConfig:Save(); NotifySuccess("Config Saved", "Configuration has been saved!")
  end })
  ConfigSection:Button({ Title = "Load Settings", Content = "Muat konfigurasi", Callback = function()
    myConfig:Load(); NotifySuccess("Config Loaded", "Configuration has been loaded!")
  end })

  local AFKSection = SettingsTab:Section({ Title = "Anti-AFK System", Icon = "user-x" })
  AFKSection:Toggle({
    Title = "Anti-AFK",
    Content = "Prevent automatic disconnection",
    Value = true,
    Callback = function(v)
      if Notifs.AFKBN then Notifs.AFKBN = false; return end
      setAntiAFK(v)
      if v then NotifySuccess("Anti-AFK", "Activated") else NotifyWarning("Anti-AFK", "Deactivated") end
    end
  })

  local InfoSection = SettingsTab:Section({ Title = "Script Information", Icon = "info" })
  InfoSection:Label({ Title = "Version",   Content = "1.8.1-Delta" })
  InfoSection:Label({ Title = "Developer", Content = "@ziaandev" })
  InfoSection:Label({ Title = "Status",    Content = "Operational" })
end
