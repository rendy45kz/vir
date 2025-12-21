--------------------------------------------------
-- ASH LIBS
--------------------------------------------------
local GUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/BloodLetters/Ash-Libs/refs/heads/main/source.lua"
))()

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players     = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
-- MAIN TAB
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
-- APPLY SPECTATE
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
-- UNLIMITED ZOOM
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
        TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { CFrame = cf }
    )
    tween:Play()
    tween.Completed:Wait()

    task.wait(0.15)
    hrp.Anchored = false
end

--------------------------------------------------
-- ISLAND DATA (VECTOR3 / CFRAME MIX)
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
-- TELEPORT ISLAND (SMOOTH + SAFE)
--------------------------------------------------
GUI:CreateSection({
    parent = teleportTab,
    text = "Teleport Island"
})

GUI:CreateDropdown({
    parent = teleportTab,
    text = "Select Island",
    options = islandList,
    callback = function(islandName)
        local data = islands[islandName]
        if not data then return end

        local cf
        if typeof(data) == "CFrame" then
            cf = data
        else
            cf = CFrame.new(data + Vector3.new(0, 3, 0))
        end

        smoothTeleport(cf)
    end
})
