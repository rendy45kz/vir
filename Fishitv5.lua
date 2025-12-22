--------------------------------------------------
-- ASH LIBS
--------------------------------------------------
local GUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/BloodLetters/Ash-Libs/refs/heads/main/source.lua"
))()

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
-- UTIL
--------------------------------------------------
local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function smoothTeleport(cf)
    local char = LocalPlayer.Character
    local hrp = getHRP(char)
    if not hrp then return end

    hrp.Anchored = true
    TweenService:Create(
        hrp,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = cf}
    ):Play()
    task.wait(1.1)
    hrp.Anchored = false
end

--------------------------------------------------
-- PLAYER LIST (REFRESHABLE)
--------------------------------------------------
local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    table.sort(list)
    return list
end

--------------------------------------------------
-- NPC LIST (REFRESHABLE)
--------------------------------------------------
local function getNPCList()
    local list, added = {}, {}
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model")
        and m:FindFirstChildOfClass("Humanoid")
        and not Players:GetPlayerFromCharacter(m) then
            if not added[m.Name] then
                table.insert(list, m.Name)
                added[m.Name] = true
            end
        end
    end
    table.sort(list)
    return list
end

--------------------------------------------------
-- TAB : CAMERA
--------------------------------------------------
local cameraTab = GUI:CreateTab("Camera", "camera")

GUI:CreateSection({ parent = cameraTab, text = "Spectate Player" })

local camDropdown
local selectedCamPlayer

camDropdown = GUI:CreateDropdown({
    parent = cameraTab,
    text = "Select Player",
    options = getPlayerList(),
    callback = function(v)
        selectedCamPlayer = v
    end
})

GUI:CreateButton({
    parent = cameraTab,
    text = "Refresh Player List",
    callback = function()
        camDropdown:Refresh(getPlayerList())
    end
})

GUI:CreateToggle({
    parent = cameraTab,
    text = "Enable Spectate",
    default = false,
    callback = function(state)
        if not state then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            return
        end
        local plr = Players:FindFirstChild(selectedCamPlayer or "")
        if plr and plr.Character then
            Camera.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

--------------------------------------------------
-- TAB : TELEPORT
--------------------------------------------------
local teleportTab = GUI:CreateTab("Teleport", "map")

--------------------------------------------------
-- TELEPORT ISLAND
--------------------------------------------------
GUI:CreateSection({
    parent = teleportTab,
    text = "Teleport Island"
})

local islands = {
    ["Fisherman Island"] = CFrame.new(128.62, 3.53, 2783.18),
    ["Kohana"] = CFrame.new(-663.9, 3.04, 718.79),
    ["Kohana Volcano"] = CFrame.new(-572.87, 22.45, 148.35),
    ["Lost Isle"] = CFrame.new(-3618.15, 240.83, -1317.45),
    ["Sisyphus Statue"] = CFrame.new(-3727.16, -135.07, -1014.4),
    ["Treasure Room"] = CFrame.new(-3606.34, -266.57, -1580.97),
    ["Esoteric Depths"] = CFrame.new(3248.37, -1301.53, 1403.82),
    ["Coral Reefs"] = CFrame.new(-3114.78, 1.32, 2237.52),
    ["Crater Island"] = CFrame.new(987.96, 3.3, 5148.49),
    ["Tropical Grove"] = CFrame.new(-2095.34, 197.19, 3718.08),
    ["Weather Machine"] = CFrame.new(-1488.51, 83.17, 1876.3),
    ["Underground Cellar"] = CFrame.new(2135.89, -91.2, -698.5),
    ["Ancient Jungle"] = CFrame.new(1483.11, 11.14, -300.08),
    ["Sacred Temple"] = CFrame.new(1506.53, -22.13, -640.17),
    ["Ancient Ruin"] = CFrame.new(6040.64, -578.44, 4715.02),
    ["Crystalline Passage"] = CFrame.new(6049.71, -538.9, 4385.69),
    ["Classic Island"] = CFrame.new(1246.1, 13.7, 2852.7),
    ["Iron Cavern"] = CFrame.new(-8795.1, -580, 91.6),
    ["Iron Cafe"] = CFrame.new(-8641.5, -542.8, 161.3),
}

local islandNames = {}
for k in pairs(islands) do table.insert(islandNames, k) end
table.sort(islandNames)

local selectedIsland

GUI:CreateDropdown({
    parent = teleportTab,
    text = "Select Island",
    options = islandNames,
    callback = function(name)
        selectedIsland = name
    end
})

GUI:CreateButton({
    parent = teleportTab,
    text = "Teleport To Island",
    callback = function()
        if selectedIsland then
            smoothTeleport(islands[selectedIsland] * CFrame.new(0, 3, 0))
        end
    end
})

--------------------------------------------------
-- TELEPORT PLAYER
--------------------------------------------------
GUI:CreateSection({ parent = teleportTab, text = "Teleport Player" })

local tpPlayerDropdown
local selectedTPPlayer

tpPlayerDropdown = GUI:CreateDropdown({
    parent = teleportTab,
    text = "Select Player",
    options = getPlayerList(),
    callback = function(v)
        selectedTPPlayer = v
    end
})

GUI:CreateButton({
    parent = teleportTab,
    text = "Refresh Player",
    callback = function()
        tpPlayerDropdown:Refresh(getPlayerList())
    end
})

GUI:CreateButton({
    parent = teleportTab,
    text = "Teleport To Player",
    callback = function()
        local plr = Players:FindFirstChild(selectedTPPlayer or "")
        if plr and plr.Character then
            local hrp = getHRP(plr.Character)
            if hrp then
                smoothTeleport(hrp.CFrame * CFrame.new(0, 0, -3))
            end
        end
    end
})

--------------------------------------------------
-- TELEPORT NPC
--------------------------------------------------
GUI:CreateSection({ parent = teleportTab, text = "Teleport NPC" })

local npcDropdown
local selectedNPC

npcDropdown = GUI:CreateDropdown({
    parent = teleportTab,
    text = "Select NPC",
    options = getNPCList(),
    callback = function(v)
        selectedNPC = v
    end
})

GUI:CreateButton({
    parent = teleportTab,
    text = "Refresh NPC",
    callback = function()
        npcDropdown:Refresh(getNPCList())
    end
})

GUI:CreateButton({
    parent = teleportTab,
    text = "Teleport To NPC",
    callback = function()
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m.Name == selectedNPC then
                local hrp = m:FindFirstChild("HumanoidRootPart")
                if hrp then
                    smoothTeleport(hrp.CFrame * CFrame.new(0, 0, -3))
                end
                break
            end
        end
    end
})

--------------------------------------------------
-- TAB : EVENT
--------------------------------------------------
local eventTab = GUI:CreateTab("Event", "gift")

GUI:CreateSection({ parent = eventTab, text = "Christmas Event" })

local EventCfg = {
    Enabled = false,
    Cooldown = 3600
}

local function getEventRF()
    local pkg = ReplicatedStorage:FindFirstChild("Packages")
    if pkg and pkg:FindFirstChild("Net") then
        local Net = require(pkg.Net)
        return Net:RemoteFunction("SpecialDialogueEvent")
    end
end

local function runEvent()
    local rf = getEventRF()
    if not rf then return end

    for _, npc in ipairs(getNPCList()) do
        pcall(function()
            rf:InvokeServer(npc, "ChristmasPresents")
            task.wait(0.05)
            rf:InvokeServer(npc, "PresentsChristmasDoor")
        end)
        task.wait(0.1)
    end
end

GUI:CreateToggle({
    parent = eventTab,
    text = "Enable Auto Christmas",
    default = false,
    callback = function(state)
        EventCfg.Enabled = state
        if state then
            task.spawn(function()
                while EventCfg.Enabled do
                    runEvent()
                    task.wait(EventCfg.Cooldown)
                end
            end)
        end
    end
})

--------------------------------------------------
-- PLAYER TAB
--------------------------------------------------
local playerTab = GUI:CreateTab("Player", "user")

GUI:CreateSection({
    parent = playerTab,
    text = "Player Movement"
})

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--------------------------------------------------
-- PLAYER STATE
--------------------------------------------------
local PlayerCfg = {
    Speed = 16,
    Jump = 50,
    Fly = false,
    FlySpeed = 60,
    NoClip = false,
    WalkOnWater = false,
    SwimSpeed = false,
    SwimValue = 30
}

--------------------------------------------------
-- CHARACTER UTILS
--------------------------------------------------
local function getChar()
    return LocalPlayer.Character
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- SPEED
--------------------------------------------------
GUI:CreateSlider({
    parent = playerTab,
    text = "Walk Speed",
    min = 16,
    max = 300,
    default = 16,
    callback = function(v)
        PlayerCfg.Speed = v
        local hum = getHum()
        if hum then hum.WalkSpeed = v end
    end
})

--------------------------------------------------
-- JUMP POWER
--------------------------------------------------
GUI:CreateSlider({
    parent = playerTab,
    text = "Jump Power",
    min = 50,
    max = 300,
    default = 50,
    callback = function(v)
        PlayerCfg.Jump = v
        local hum = getHum()
        if hum then hum.JumpPower = v end
    end
})

--------------------------------------------------
-- NO CLIP
--------------------------------------------------
GUI:CreateToggle({
    parent = playerTab,
    text = "No Clip",
    default = false,
    callback = function(state)
        PlayerCfg.NoClip = state
    end
})

RunService.Stepped:Connect(function()
    if PlayerCfg.NoClip then
        local char = getChar()
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
end)

--------------------------------------------------
-- WALK ON WATER (REAL)
--------------------------------------------------
local waterPart

GUI:CreateToggle({
    parent = playerTab,
    text = "Walk On Water",
    default = false,
    callback = function(state)
        PlayerCfg.WalkOnWater = state

        if not state and waterPart then
            waterPart:Destroy()
            waterPart = nil
        end
    end
})

RunService.Heartbeat:Connect(function()
    if not PlayerCfg.WalkOnWater then return end

    local hrp = getHRP()
    if not hrp then return end

    if not waterPart then
        waterPart = Instance.new("Part")
        waterPart.Size = Vector3.new(20, 1, 20)
        waterPart.Anchored = true
        waterPart.CanCollide = true
        waterPart.Transparency = 1
        waterPart.Parent = workspace
    end

    waterPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
end)

--------------------------------------------------
-- FLY (REAL)
--------------------------------------------------
local bv, bg

GUI:CreateToggle({
    parent = playerTab,
    text = "Fly",
    default = false,
    callback = function(state)
        PlayerCfg.Fly = state

        local hrp = getHRP()
        if not hrp then return end

        if state then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

            bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = hrp.CFrame
        else
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
})

RunService.RenderStepped:Connect(function()
    if PlayerCfg.Fly and bv and bg then
        local cam = workspace.CurrentCamera
        bv.Velocity = cam.CFrame.LookVector * PlayerCfg.FlySpeed
        bg.CFrame = cam.CFrame
    end
end)

--------------------------------------------------
-- SWIM SPEED
--------------------------------------------------
GUI:CreateSlider({
    parent = playerTab,
    text = "Swim Speed",
    min = 16,
    max = 200,
    default = 30,
    callback = function(v)
        PlayerCfg.SwimValue = v
    end
})

GUI:CreateToggle({
    parent = playerTab,
    text = "Enable Swim Speed",
    default = false,
    callback = function(state)
        PlayerCfg.SwimSpeed = state
    end
})

task.spawn(function()
    while task.wait(0.2) do
        if not PlayerCfg.SwimSpeed then continue end
        local hum = getHum()
        if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
            hum.WalkSpeed = PlayerCfg.SwimValue
        end
    end
end)

--------------------------------------------------
-- ANTI AFK (AUTO ON)
--------------------------------------------------
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--------------------------------------------------
-- ANTI FALL DAMAGE (AUTO ENABLE)
--------------------------------------------------
task.spawn(function()
    local function applyAntiFall(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end

        hum.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Freefall then
                task.wait(0.1)
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end

    if LocalPlayer.Character then
        applyAntiFall(LocalPlayer.Character)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        applyAntiFall(char)
    end)
end)

--------------------------------------------------
-- MISC TAB
--------------------------------------------------
local miscTab = GUI:CreateTab("Misc", "settings")

GUI:CreateSection({
    parent = miscTab,
    text = "Performance & Utility"
})

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Lighting    = game:GetService("Lighting")
local Stats       = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

--------------------------------------------------
-- ANTI AFK (AUTO ON)
--------------------------------------------------
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
end)

--------------------------------------------------
-- UNLOCK FPS
--------------------------------------------------
GUI:CreateToggle({
    parent = miscTab,
    text = "Unlock FPS",
    default = true,
    callback = function(state)
        if setfpscap then
            setfpscap(state and 999 or 60)
        end
    end
})

--------------------------------------------------
-- FPS BOOSTER
--------------------------------------------------
GUI:CreateToggle({
    parent = miscTab,
    text = "FPS Booster",
    default = false,
    callback = function(state)
        if not state then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter")
            or v:IsA("Trail")
            or v:IsA("Beam") then
                v.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
    end
})

--------------------------------------------------
-- CPU OPTIMIZER
--------------------------------------------------
GUI:CreateToggle({
    parent = miscTab,
    text = "Optimized CPU Usage",
    default = false,
    callback = function(state)
        RunService:Set3dRenderingEnabled(not state)
    end
})

--------------------------------------------------
-- LIVE PING
--------------------------------------------------
GUI:CreateLabel({
    parent = miscTab,
    text = "Ping: -- ms"
})

task.spawn(function()
    while task.wait(1) do
        local ping = math.floor(
            Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        )
        miscTab:FindFirstChildWhichIsA("TextLabel").Text = "Ping: "..ping.." ms"
    end
end)

--------------------------------------------------
-- PERFORMANCE PRESET
--------------------------------------------------
GUI:CreateSection({
    parent = miscTab,
    text = "Performance Preset"
})

local function applyPreset(mode)
    if mode == "LOW" then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 5000

    elseif mode == "MEDIUM" then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level06
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000

    elseif mode == "EXTREME" then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter")
            or v:IsA("Trail")
            or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            end
        end
    end
end

GUI:CreateButton({ parent = miscTab, text = "Preset: LOW", callback = function() applyPreset("LOW") end })
GUI:CreateButton({ parent = miscTab, text = "Preset: MEDIUM", callback = function() applyPreset("MEDIUM") end })
GUI:CreateButton({ parent = miscTab, text = "Preset: EXTREME", callback = function() applyPreset("EXTREME") end })


