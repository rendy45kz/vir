--------------------------------------------------
-- ASH LIBS
--------------------------------------------------
local GUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/BloodLetters/Ash-Libs/refs/heads/main/source.lua"
))()

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Camera       = workspace.CurrentCamera
local LocalPlayer  = Players.LocalPlayer

--------------------------------------------------
-- STATE (OBSERVER)
--------------------------------------------------
local observerEnabled = false
local spectatingPlayer = nil
local charConnection = nil
local selectedName = nil

--------------------------------------------------
-- WINDOW
--------------------------------------------------
GUI:CreateMain({
    Name = "Aegis HUB",
    title = "Aegis Fish It",
    ToggleUI = "K",
    WindowIcon = "home"
})

--------------------------------------------------
-- MAIN TAB (OBSERVER)
--------------------------------------------------
local mainTab = GUI:CreateTab("Main", "home")

GUI:CreateSection({
    parent = mainTab,
    text = "Observer Camera"
})

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------
local function getPlayerNames()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(t, p.Name)
        end
    end
    return t
end

--------------------------------------------------
-- RESET CAMERA
--------------------------------------------------
local function resetCamera()
    if charConnection then
        charConnection:Disconnect()
        charConnection = nil
    end

    spectatingPlayer = nil
    Camera.CameraType = Enum.CameraType.Custom

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end
    end
end

--------------------------------------------------
-- APPLY SPECTATE (REAL AUTO SWITCH)
--------------------------------------------------
local function applySpectate(player)
    if not observerEnabled or not player then return end
    spectatingPlayer = player

    if charConnection then
        charConnection:Disconnect()
    end

    local function attach(char)
        if not observerEnabled then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = hum
        end
    end

    if player.Character then
        attach(player.Character)
    end

    charConnection = player.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        attach(char)
    end)
end

--------------------------------------------------
-- PLAYER DROPDOWN
--------------------------------------------------
GUI:CreateDropdown({
    parent = mainTab,
    text = "Select Player",
    options = getPlayerNames(),
    callback = function(name)
        selectedName = name
        if observerEnabled then
            applySpectate(Players:FindFirstChild(name))
        end
    end
})

--------------------------------------------------
-- TOGGLE OBSERVER
--------------------------------------------------
GUI:CreateToggle({
    parent = mainTab,
    text = "Enable Camera Observer",
    default = false,
    callback = function(state)
        observerEnabled = state
        if not state then
            resetCamera()
        elseif selectedName then
            applySpectate(Players:FindFirstChild(selectedName))
        end
    end
})

--------------------------------------------------
-- UNLIMITED CAMERA ZOOM
--------------------------------------------------
GUI:CreateToggle({
    parent = mainTab,
    text = "Unlimited Camera Zoom",
    default = true,
    callback = function(state)
        LocalPlayer.CameraMinZoomDistance = state and 0.1 or 0.5
        LocalPlayer.CameraMaxZoomDistance = state and 100000 or 50
    end
})

--------------------------------------------------
-- TELEPORT TAB
--------------------------------------------------
local teleportTab = GUI:CreateTab("Teleport", "map")

GUI:CreateSection({
    parent = teleportTab,
    text = "Teleport System"
})

--------------------------------------------------
-- UTIL
--------------------------------------------------
local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- SAFE SMOOTH TELEPORT
--------------------------------------------------
local function smoothTeleport(cf)
    local char = LocalPlayer.Character
    local hrp = getHRP(char)
    if not hrp then return end

    hrp.Anchored = true

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { CFrame = cf }
    )
    tween:Play()
    tween.Completed:Wait()

    task.wait(0.15)
    hrp.Anchored = false
end

--------------------------------------------------
-- TELEPORT PLAYER
--------------------------------------------------
GUI:CreateDropdown({
    parent = teleportTab,
    text = "Teleport Player",
    options = getPlayerNames(),
    callback = function(name)
        local target = Players:FindFirstChild(name)
        if not target or not target.Character then return end

        local myHRP = getHRP(LocalPlayer.Character)
        local tHRP = getHRP(target.Character)
        if myHRP and tHRP then
            smoothTeleport(tHRP.CFrame * CFrame.new(0, 0, -4))
        end
    end
})

--------------------------------------------------
-- TELEPORT NPC
--------------------------------------------------
local function getNPCFolder()
    return workspace:FindFirstChild("NPC")
        or workspace:FindFirstChild("NPCs")
end

local function getNPCList()
    local list = {}
    local folder = getNPCFolder()
    if not folder then return list end

    for _, npc in ipairs(folder:GetChildren()) do
        if npc:IsA("Model") then
            table.insert(list, npc.Name)
        end
    end
    return list
end

GUI:CreateDropdown({
    parent = teleportTab,
    text = "Teleport NPC",
    options = getNPCList(),
    callback = function(name)
        local folder = getNPCFolder()
        if not folder then return end
        local npc = folder:FindFirstChild(name)
        if not npc then return end

        local npcHRP = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        local myHRP = getHRP(LocalPlayer.Character)

        if myHRP and npcHRP then
            smoothTeleport(npcHRP.CFrame * CFrame.new(0, 0, -4))
        end
    end
})

--------------------------------------------------
-- ISLAND LIST (FULL CFRAME)
--------------------------------------------------
local islands = {
    ["Fisherman Island"] = CFrame.new(128.62, 3.53, 2783.18),
    ["Kohana"] = CFrame.new(-663.904236, 3.04580712, 718.796875),
    ["Kohana Volcano"] = CFrame.new(-572.879456, 22.4521465, 148.355331),
    ["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801), 
    ["Sisyphus Statue"] = CFrame.new(-3727.16, -135.07, -1014.40),
    ["Treasure Room"] = CFrame.new(-3606.34985, -266.57373, -1580.97339),    
    ["Esoteric Depths"] = CFrame.new(3248.37109, -1301.53027, 1403.82727),    
    ["Coral Reefs"] = CFrame.new(-3114.78198, 1.32066584, 2237.52295), 
    ["Crater Island"] = CFrame.new(987.96, 3.30, 5148.49), 
    ["Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008), 
    ["Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298),
    ["Underground Cellar"] = CFrame.new(2135.89, -91.20, -698.50),     
    ["Ancient Jungle"] = CFrame.new(1483.11, 11.14, -300.08), 
    ["Sacred Temple"] = CFrame.new(1506.53, -22.13, -640.17), 
    ["Ancient Ruin"] = CFrame.new(6040.64, -578.44, 4715.02), 
    ["Crystalline Passage"] = CFrame.new(6049.71, -538.90, 4385.69), 
    ["Arrow Artifact"] = CFrame.new(881.40, 6.34, -346.27),     
    ["Crescent Artifact"] = CFrame.new(1404.67, 5.08, 120.55),     
    ["Diamond Artifact"] = CFrame.new(1841.52, 2.76, -300.38),  
    ["Hourglass Diamond Artifact"] = CFrame.new(1466.40, 3.19, -846.62),  
    ["Classic Island"] = CFrame.new(1246.1, 13.7, 2852.7),     
    ["Iron Cavern"] = CFrame.new(-8795.1, -580.0, 91.6),  
    ["Iron Cafe"] = CFrame.new(-8641.5, -542.8, 161.3),
}

local islandList = {}
for name in pairs(islands) do
    table.insert(islandList, name)
end
table.sort(islandList)

--------------------------------------------------
-- TELEPORT ISLAND
--------------------------------------------------
GUI:CreateSection({
    parent = teleportTab,
    text = "Teleport Island"
})

GUI:CreateDropdown({
    parent = teleportTab,
    text = "Select Island",
    options = islandList,
    callback = function(name)
        local cf = islands[name]
        if cf then
            smoothTeleport(cf * CFrame.new(0, 3, 0))
        end
    end
})

--------------------------------------------------
-- EVENT TAB
--------------------------------------------------
local eventTab = GUI:CreateTab("Event", "gift")

GUI:CreateSection({
    parent = eventTab,
    text = "Auto Event System"
})

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- CONFIG
--------------------------------------------------
local EventCfg = {
    Enabled = false,
    Cooldown = 5 -- 2 jam
}

local nextAt = 0
local loopRunning = false

--------------------------------------------------
-- FORMAT TIME
--------------------------------------------------
local function fmt(sec)
    sec = math.max(0, math.floor(sec or 0))
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

--------------------------------------------------
-- LIVE LABEL
--------------------------------------------------
local statusLabel = GUI:CreateLabel({
    parent = eventTab,
    text = "Status: OFF\nCooldown: 02:00:00\nNext in: --:--:--"
})

task.spawn(function()
    while task.wait(1) do
        local left = (EventCfg.Enabled and nextAt > 0) and (nextAt - tick()) or 0
        statusLabel:Set(
    string.format(
        "Status: %s\nCooldown: 00:00:05\nNext in: %s",
        EventCfg.Enabled and "ON" or "OFF",
        (EventCfg.Enabled and nextAt > 0) and fmt(left) or "--:--:--"
    )
)

    end
end)

--------------------------------------------------
-- FIND REMOTE FUNCTION
--------------------------------------------------
local function getSpecialDialogueRF()
    -- Net module
    local ok1, rf1 = pcall(function()
        local pkg = ReplicatedStorage:FindFirstChild("Packages")
        if pkg and pkg:FindFirstChild("Net") then
            local Net = require(pkg.Net)
            if Net and typeof(Net.RemoteFunction) == "function" then
                return Net:RemoteFunction("SpecialDialogueEvent")
            end
        end
    end)
    if ok1 and rf1 then return rf1 end

    -- sleitnick_net fallback
    local ok2, rf2 = pcall(function()
        local net = ReplicatedStorage
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")

        return net:FindFirstChild("RF/SpecialDialogueEvent")
            or net:FindFirstChild("SpecialDialogueEvent")
    end)

    if ok2 then return rf2 end
    return nil
end

--------------------------------------------------
-- NPC SCAN (AUTO)
--------------------------------------------------
local function listNPCNames()
    local found = {}
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and Players:GetPlayerFromCharacter(m) == nil then
            if m:FindFirstChildOfClass("Humanoid") then
                found[m.Name] = true
            end
        end
    end

    local list = {}
    for n in pairs(found) do table.insert(list, n) end
    table.sort(list)
    return list
end

--------------------------------------------------
-- RUN ONCE
--------------------------------------------------
local function runOnce()
    local rf = getSpecialDialogueRF()
    if not rf then
        warn("[Event] SpecialDialogueEvent RF tidak ditemukan")
        return
    end

    local npcList = listNPCNames()
    if #npcList == 0 then
        warn("[Event] NPC tidak ditemukan")
        return
    end

    for _, npcName in ipairs(npcList) do
        pcall(function()
            -- Event 1
            rf:InvokeServer(npcName, "ChristmasPresents")
            task.wait(0.05)

            -- Event 2 (Door)
            rf:InvokeServer(npcName, "PresentsChristmasDoor")
        end)

        task.wait(0.15) -- aman, mobile-friendly
    end
end

--------------------------------------------------
-- LOOP SYSTEM
--------------------------------------------------
local function eventLoop()
    if loopRunning then return end
    loopRunning = true

    while EventCfg.Enabled do
        runOnce()
        nextAt = tick() + EventCfg.Cooldown

        while EventCfg.Enabled and tick() < nextAt do
            task.wait(1)
        end
    end

    loopRunning = false
    nextAt = 0
end

--------------------------------------------------
-- TOGGLE UI
--------------------------------------------------

GUI:CreateToggle({
    parent = eventTab,
    text = "Enable Auto Christmas Presents",
    default = false,
    callback = function(state)
        EventCfg.Enabled = state
        nextAt = 0

        if state then
            task.spawn(eventLoop)
        end
    end
})

