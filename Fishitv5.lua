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
    Cooldown = 5
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

