local Sirenx = loadstring(game:HttpGet("https://github.com/Soruisme0/SirenX/raw/main/Ui%20Siren.lua"))()

local Window = Sirenx:Window({
  Title   = "SirenX |",
  Footer  = "Fish It",
  Image   = "117346863101172",
  Color   = Color3.fromRGB(255, 255, 255),
  Theme   = 129648704071138,
  Version = 1,
})

local svc = {
  Players     = game:GetService("Players"),
  RunService  = game:GetService("RunService"),
  HttpService = game:GetService("HttpService"),
  RS          = game:GetService("ReplicatedStorage"),
  VU          = game:GetService("VirtualUser"),
  VIM         = game:GetService("VirtualInputManager"),
  PG          = game:GetService("Players").LocalPlayer.PlayerGui,
  Camera      = workspace.CurrentCamera,
  GuiService  = game:GetService("GuiService"),
  CoreGui     = game:GetService("CoreGui"),
  Stats       = game:GetService("Stats"),
  TpService   = game:GetService("TeleportService"),
  Starter     = game:GetService("StarterPlayer"),
  UIS         = game:GetService("UserInputService"),
}

_G.httpRequest =
  (syn and syn.request)
  or (http and http.request)
  or http_request
  or (fluxus and fluxus.request)
  or request
if not _G.httpRequest then
  return
end

local player = svc.Players.LocalPlayer
local function getHRP()
  local char = player.Character or player.CharacterAdded:Wait()
  return char:WaitForChild("HumanoidRootPart")
end
local function getHumanoid()
  local char = player.Character or player.CharacterAdded:Wait()
  return char:WaitForChild("Humanoid")
end

local BaseFolder           = "Siren X/FishIt"
local PositionFile         = BaseFolder .. "/Position.json"

local gui = {
  Merchant        = svc.PG.Merchant,
  MerchantRoot    = svc.PG.Merchant.Main.Background,
  ItemsFrame      = svc.PG.Merchant.Main.Background.Items.ScrollingFrame,
  RefreshMerchant = svc.PG.Merchant.Main.Background.RefreshLabel,
}

local mods = {
  Net                     = svc.RS.Packages._Index["sleitnick_net@0.2.0"].net,
  Replion                 = require(svc.RS.Packages.Replion),
  FishingController       = require(svc.RS.Controllers.FishingController),
  NotificationController  = require(svc.RS.Controllers.NotificationController),
  AnimationController     = require(svc.RS.Controllers.AnimationController),
  CutsceneController      = require(svc.RS.Controllers.CutsceneController),
  TradingController       = require(svc.RS.Controllers.ItemTradingController),
  ItemUtility             = require(svc.RS.Shared.ItemUtility),
  VendorUtility           = require(svc.RS.Shared.VendorUtility),
  CutsceneUtility         = require(svc.RS.Shared.CutsceneUtility),
  PlayerStatsUtility      = require(svc.RS.Shared.PlayerStatsUtility),
  Effects                 = require(svc.RS.Shared.Effects),
  NotifierFish            = require(svc.RS.Controllers.TextNotificationController),
  InputControl            = require(svc.RS.Modules.InputControl),
  VFX                     = require(svc.RS.Controllers.VFXController)
}

local api = {
  Events = {
    RECutscene                    = mods.Net["RE/ReplicateCutscene"],
    REStop                        = mods.Net["RE/StopCutscene"],
    REFav                         = mods.Net["RE/FavoriteItem"],
    REFavChg                      = mods.Net["RE/FavoriteStateChanged"],
    REFishDone                    = mods.Net["RE/FishingCompleted"],
    REFishGot                     = mods.Net["RE/FishCaught"],
    RENotify                      = mods.Net["RE/TextNotification"],
    REEquip                       = mods.Net["RE/EquipToolFromHotbar"],
    REEquipItem                   = mods.Net["RE/EquipItem"],
    REAltar                       = mods.Net["RE/ActivateEnchantingAltar"],
    REAltar2                      = mods.Net["RE/ActivateSecondEnchantingAltar"],
    UpdateOxygen                  = mods.Net["URE/UpdateOxygen"],
    REPlayFishEffect              = mods.Net["RE/PlayFishingEffect"],
    RETextEffect                  = mods.Net["RE/ReplicateTextEffect"],
    REEvReward                    = mods.Net["RE/ClaimEventReward"],
    Totem                         = mods.Net["RE/SpawnTotem"],
    REObtainedNewFishNotification = mods.Net["RE/ObtainedNewFishNotification"],
    FishingMinigameChanged        = mods.Net["RE/FishingMinigameChanged"],
    FishingStopped                = mods.Net["RE/FishingStopped"],
  },
  Functions = {
    Trade       = mods.Net["RF/InitiateTrade"],
    BuyRod      = mods.Net["RF/PurchaseFishingRod"],
    BuyBait     = mods.Net["RF/PurchaseBait"],
    BuyWeather  = mods.Net["RF/PurchaseWeatherEvent"],
    ChargeRod   = mods.Net["RF/ChargeFishingRod"],
    StartMini   = mods.Net["RF/RequestFishingMinigameStarted"],
    UpdateRadar = mods.Net["RF/UpdateFishingRadar"],
    Cancel      = mods.Net["RF/CancelFishingInputs"],
    Dialogue    = mods.Net["RF/SpecialDialogueEvent"],
    SellItem    = mods.Net["RF/SellItem"],
    SellAllItem = mods.Net["RF/SellAllItems"],
    AutoEnabled = mods.Net["RF/UpdateAutoFishingState"]
  }
}

local st                   = {
  player           = player,
  walk             = false,
  walkSpeed        = 16,
  infiniteJump     = false,
  hideIdentity     = false,
  hideNames        = "SirenX",
  hideLevels       = "discord.gg/KxjMYW7QKs",
  char             = player.Character or player.CharacterAdded:Wait(),
  menuRings        = workspace:WaitForChild("!!! MENU RINGS"),
  zones            = workspace:WaitForChild("Zones"),
  vim              = svc.VIM,
  cam              = svc.Camera,
  fishingLegit     = false,
  minigameDelay    = 0.1,
  autoFishing      = false,
  completeDelay    = 0.5,
  instantFishing   = false,
  teleport = {
    island = nil,
    event  = nil,
    player = nil,
  },
  shop = {
    weather       = {},
    autoWeather   = false,
  },
  market = {
    autoSellThreshold = "Legendary",
    sellAtAmount      = 500,
    autoSell          = false,
    enchSellAt        = 100,
    enchSell          = false,
  },
  favorite = {
    auto             = false,
    names            = {},
    rarities         = {},
    mutations        = {},
  },
  hide = {
    notifications   = false,
    cutscenes       = false,
    animations      = false,
    vfx             = false,
  },
  quest = {
    autoDeepSea      = false,
    autoElement      = false,
    autoQuestFlow    = false,
    triggerRuin      = false,
    autoClassicEvent = false,
  }
}

st.player.CharacterAdded:Connect(function(char)
  st.char = char
end)

local repl = {
  Data = mods.Replion.Client:WaitReplion("Data"),
  Items = svc.RS:WaitForChild("Items"),
  Variants = svc.RS:WaitForChild("Variants"),
  PlayerStat = require(svc.RS.Packages._Index:FindFirstChild("ytrev_replion@2.0.0-rc.3").replion)
}

player.Idled:Connect(function()
	svc.VU:CaptureController()
	svc.VU:ClickButton2(Vector2.zero)
	st.vim:SendKeyEvent(true, Enum.KeyCode.RightMeta, false, game)
	st.vim:SendKeyEvent(false, Enum.KeyCode.RightMeta, false, game)
end)

local Tabs = {
  Info = Window:AddTab({ Name = "Info", Icon = "player" }),
  Player = Window:AddTab({ Name = "Player", Icon = "user" }),
  Fishing = Window:AddTab({ Name = "Fishing", Icon = "fish" }),
  Automation = Window:AddTab({ Name = "Automation", Icon = "next" }),
  Teleport = Window:AddTab({ Name = "Teleport", Icon = "gps" }),
  Quest = Window:AddTab({ Name = "Auto Quests", Icon = "scroll" }),
  Special = Window:AddTab({ Name = "Kaitun", Icon = "idea" }),
}

InfoSection = Tabs.Info:AddSection("Information", true)

InfoSection:AddParagraph({
  Title = "Join Our Discord",
  Content = "Join Us!",
  Icon = "discord",
  ButtonText = "Copy Discord Link",
  ButtonCallback = function()
    local link = "https://discord.gg/KxjMYW7QKs"
    if setclipboard then
      setclipboard(link)
      sirenx("Successfully Copied!")
    end
  end
})

ServerSection = Tabs.Info:AddSection("Server")

local CurrentServer = ServerSection:AddParagraph({
  Title = "Current Server",
  Content = [[
Ping: 0 ms | FPS: 0/s | Players: 0/0
  ]],
  Icon = "stat",
})

task.spawn(function()
  while task.wait(1) do
    CurrentServer:SetContent(
      string.format([[
Ping: %d ms | FPS: %d/s | Players: %d/%d
      ]],
        math.floor(svc.Stats.PerformanceStats.Ping:GetValue() + 0.5),
        math.floor(1 / svc.RunService.RenderStepped:Wait() + 0.5),
        #svc.Players:GetPlayers(),
        svc.Players.MaxPlayers
      )
    )
  end
end)

ServerSection:AddButton({
  Title = "Rejoin Server",
  Content = "Rejoins the current server",
  Callback = function()
    sirenx("Rejoining Server...")
    svc.TpService:Teleport(game.PlaceId, Player)
  end
})

Plyrs = Tabs.Player:AddSection("Player")

Plyrs:AddToggle({
  Title = "Enable",
  Content = "Enable Walk Speed Changer",
  Default = false,
  Callback = function(state)
    st.walk = state

    if ConnectionWalkSpeed then
      ConnectionWalkSpeed:Disconnect()
      ConnectionWalkSpeed = nil
    end

    if state then
      local hum = getHumanoid()
      hum.WalkSpeed = st.walkSpeed
      ConnectionWalkSpeed = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if st.walk and hum.WalkSpeed ~= st.walkSpeed then
          hum.WalkSpeed = st.walkSpeed
        end
      end)
    else
      getHumanoid().WalkSpeed = svc.Starter.CharacterWalkSpeed
    end
  end
})

Plyrs:AddSlider({
  Title = "Walk Speed",
  Content = "Change your walk speed",
  Min = 16,
  Max = 500,
  Increment = 1,
  Default = st.walkSpeed,
  Callback = function(value)
    st.walkSpeed = value
    if st.walk then
      getHumanoid().WalkSpeed = value
    end
  end
})

Plyrs:AddToggle({
  Title = "Infinite Jump",
  Content = "Allows you to jump infinitely",
  Default = false,
  Callback = function(state)
    st.infiniteJump = state
    if state then
      svc.UIS.JumpRequest:Connect(function()
        if st.infiniteJump then
          humanoid:ChangeState("Jumping")
        end
      end)
    end
  end
}, "InfiniteJump")

local Connections = {}
local OriginalText = {}
local DescendantAddedConnection = nil

local function HandleUsernameChange(Object)
	if not st.hideIdentity or not (Object:IsA("TextLabel") or Object:IsA("TextBox") or Object:IsA("TextButton")) then
		return
	end

	if not Connections[Object] then
		Connections[Object] = Object:GetPropertyChangedSignal("Text"):Connect(function()
			HandleUsernameChange(Object)
		end)
	end

	local text = Object.Text
	if text:find(st.player.Name) or text:find(st.player.DisplayName) then
		OriginalText[Object] = text
		Object.Text = text:gsub(st.player.Name, st.hideNames):gsub(st.player.DisplayName, st.hideNames)
	end
end

Plyrs:AddInput({
  Title = "Set Name",
  Content = "Sets the name to replace your username with",
  Default = st.hideNames,
  Placeholder = st.hideNames,
  Callback = function(value)
    st.hideNames = value
  end
})

Plyrs:AddInput({
  Title = "Set Level Text",
  Content = "Sets the text to replace your level with",
  Default = st.hideLevels,
  Placeholder = st.hideLevels,
  Callback = function(value)
    st.hideLevels = value
  end
})

Plyrs:AddToggle({
	Title = "Hide Identity",
	Content = "Hides your player identity locally",
	Default = false,
	Callback = function(state)
		st.hideIdentity = state

		if state then 
			if DescendantAddedConnection then
				DescendantAddedConnection:Disconnect()
			end

			for i,v in pairs(game:GetDescendants()) do
				pcall(function()
					HandleUsernameChange(v)
				end)
			end

			pcall(function()
				local label = st.char.HumanoidRootPart.Overhead.LevelContainer.Label
				if label and not OriginalText[label] then
					OriginalText[label] = label.Text
				end
				label.Text = st.hideLevels
			end)

			DescendantAddedConnection = game.DescendantAdded:Connect(function(v)
				pcall(function()
					HandleUsernameChange(v)
				end)
			end)
		else
			if DescendantAddedConnection then
				DescendantAddedConnection:Disconnect()
				DescendantAddedConnection = nil
			end

			for Object, Connection in pairs(Connections) do
				if Connection then
					Connection:Disconnect()
				end
			end
			Connections = {}

			if OriginalText then
				for Object, Text in pairs(OriginalText) do
					if Object and Object.Parent then
						pcall(function()
							Object.Text = Text
						end)
					end
				end
				OriginalText = {}
			end
		end
	end
})

Camera = Tabs.Player:AddSection("Camera")

Camera:AddToggle({
  Title = "Max Zoom",
  Content = "Allows you to zoom out the furthest",
  Default = false,
  Callback = function(state)
    ConnectionZoom = ConnectionZoom or nil

    if ConnectionZoom then
      ConnectionZoom:Disconnect()
      ConnectionZoom = nil
    end

    if state then
      st.player.CameraMaxZoomDistance = 50000
      ConnectionZoom = Player:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
        if st.player.CameraMaxZoomDistance ~= 50000 then
          st.player.CameraMaxZoomDistance = 50000
        end
      end)
    else
      st.player.CameraMaxZoomDistance = svc.Starter.CameraMaxZoomDistance
    end
  end
})

local LegitFishing = Tabs.Fishing:AddSection("Legit Fishing")

LegitFishing:AddToggle({
  Title = "Legit Fishing",
  Content = "Automatically fishes for you",
  Default = false,
  Callback = function(state)
    st.fishingLegit = state

    task.spawn(function()
      while st.fishingLegit do
        local GUID = mods.FishingController:GetCurrentGUID()

        if GUID then
          task.wait(st.MinigameDelay)
          api.Events.REFishDone:FireServer()
        elseif not mods.FishingController:OnCooldown() then
          api.Functions.Cancel:InvokeServer()
          mods.FishingController:RequestChargeFishingRod(nil, true)
        end
        task.wait(0.1)
      end
    end)
  end
})

local MD = LegitFishing:AddInput({
  Title = "Minigame Delay",
  Content = "Delay for finish the minigame",
  Default = tostring(st.minigameDelay),
  Placeholder = "0.1",
  Callback = function(value)
    local num = tonumber(value)
    if not num or num < 0 or num > 5 then
      task.spawn(function()
        task.wait()
        MD:Set(tostring(st.minigameDelay))
        sirenx("Invalid number! Must be between 0 and 5.")
      end)
    end
    st.MinigameDelay = num
  end
})

local AutoFishing = Tabs.Fishing:AddSection("Auto Fishing")

api.Events.RETextEffect.OnClientEvent:Connect(function(data)
  if not (data and data.TextData and data.TextData.EffectType == "Exclaim") then return end
  if not (st.char and data.Container == st.char:FindFirstChild("Head")) then return end

  if st.autoFishing then
    task.delay(st.completeDelay, function()
      pcall(api.Events.REFishDone.FireServer, api.Events.REFishDone)
    end)
  end
end)

AutoFishing:AddToggle({
  Title = "Auto Fishing",
  Content = "Automatically fishes for you",
  Default = false,
  Callback = function(state)
    st.autoFishing = state

    task.spawn(function()
      api.Functions.AutoEnabled:InvokeServer(state)
      while st.autoFishing do
        api.Functions.ChargeRod:InvokeServer()
        api.Functions.StartMini:InvokeServer(-1, 0.999, workspace:GetServerTimeNow())
        task.wait(0.5)
      end
    end)
  end
})

local CD = AutoFishing:AddInput({
  Title = "Complete Delay",
  Content = "Delay for complete fishing",
  Default = tostring(st.completeDelay),
  Callback = function(value)
    local num = tonumber(value)
    if not num or num < 0 or num > 5 then
      task.spawn(function()
        task.wait()
        CD:Set(tostring(st.completeDelay))
        sirenx("Invalid number! Must be between 0 and 5.")
      end)
    end
    st.completeDelay = num
  end
})

local Fish2 = Tabs.Fishing:AddSection("Instant Fishing")

function Fastest()
  task.spawn(function()
    pcall(function() api.Functions.Cancel:InvokeServer() end)
    local now = workspace:GetServerTimeNow()
    pcall(function() api.Functions.ChargeRod:InvokeServer(now) end)
    pcall(function() api.Functions.StartMini:InvokeServer(-1, 0.999) end)
    task.wait(_G.FishingDelay)
    pcall(function() api.Events.REFishDone:FireServer() end)
  end)
end

Fish2:AddInput({
  Title = "Delay Reel",
  Value = tostring(_G.Reel),
  Default = "1.9",
  Callback = function(v)
    local n = tonumber(v)
    if n and n > 0 then _G.Reel = n end
    SaveConfig()
  end
})

Fish2:AddInput({
  Title = "Delay Fishing",
  Value = tostring(_G.FishingDelay),
  Default = "1.1",
  Callback = function(v)
    local n = tonumber(v)
    if n and n > 0 then _G.FishingDelay = n end
    SaveConfig()
  end
})

Fish2:AddToggle({
  Title = "Instant Fishing",
  Default = _G.FBlatant,
  Callback = function(s)
    _G.FBlatant = s
    api.Functions.AutoEnabled:InvokeServer(s)
    if s then
      st.player:SetAttribute("Loading", nil)
      task.spawn(function()
        while _G.FBlatant do
          Fastest()
          task.wait(_G.Reel)
        end
      end)
    else
      st.player:SetAttribute("Loading", false)
    end
  end
})

Fish2:AddButton({
  Title = "Recovery Fishing",
  Callback = function()
    task.spawn(function()
      pcall(function()
        api.Functions.Cancel:InvokeServer()
      end)
      local lp = game:GetService("Players").LocalPlayer
      lp:SetAttribute("Loading", nil)
      task.wait(0.05)
      lp:SetAttribute("Loading", false)
      sirenx("Recovery Successfully!")
    end)
  end
})

local SellGroup = Tabs.Fishing:AddSection("Auto Selling")

SellGroup:AddDropdown({
  Options = { "Delay", "Count" },
  Default = "Delay",
  Title = "Select Sell Mode",
  Callback = function(o)
    st.sellMode = o
    SaveConfig()
  end
})

SellGroup:AddInput({
  Default = "1",
  Title = "Set Value",
  Content = "Delay = Minutes | Count = Backpack Count",
  Placeholder = "Input Here",
  Callback = function(v)
    local n = tonumber(v) or 1
    if st.sellMode == "Delay" then
      st.sellDelay = n * 60
    else
      st.inputSellCount = n
    end
    SaveConfig()
  end
})

SellGroup:AddToggle({
  Title = "Start Selling",
  Default = false,
  Callback = function(s)
    st.autoSellEnabled = s
    if s then
      task.spawn(function()
        local RFSellAllItems = mods.Net["RF/SellAllItems"]
        while st.autoSellEnabled do
          local bagLabel = player:WaitForChild("PlayerGui")
            :WaitForChild("Inventory")
            .Main.Top.Options.Fish.Label:FindFirstChild("BagSize")

          local cur, max = 0, 0
          if bagLabel and bagLabel:IsA("TextLabel") then
            local txt = bagLabel.Text or ""
            local c, m = txt:match("(%d+)%s*/%s*(%d+)")
            cur, max = tonumber(c) or 0, tonumber(m) or 0
          end

          if st.sellMode == "Delay" then
            task.wait(st.sellDelay)
            RFSellAllItems:InvokeServer()

          elseif st.sellMode == "Count" then
            local target = tonumber(st.inputSellCount) or max
            if cur >= target then
              RFSellAllItems:InvokeServer()
            end
            task.wait()
          end
        end
      end)
    end
  end
})

SellGroup:AddSubSection("Auto Sell Enchant Stone")

local function GetEnchantStoneCount()
  if not (repl.Data and repl.Data.Data and repl.Data.Data.Inventory) then return 0 end
  local Count = 0
  for _, Item in pairs(repl.Data.Data.Inventory.Items) do
    if Item.Id == 10 then Count = Count + 1 end
  end
  return Count
end

local EnchantStock = SellGroup:AddParagraph({
  Title = "Enchant Stone Count",
  Content = "0 Enchant Stones"
})

task.spawn(function()
  while task.wait(3) do
    EnchantStock:SetContent(string.format("%d Enchant Stones", GetEnchantStoneCount()))
  end
end)

local TAL = SellGroup:AddInput({
  Title = "Target Amount Left",
  Content = "Amount of enchant stones to keep",
  Default = tostring(st.market.enchSellAt),
  Callback = function(value)
    local num = tonumber(value)
    if not num or num < 1 then
      task.spawn(function()
        task.wait()
        TAL:Set(tostring(st.market.enchSellAt))
        sirenx("Invalid number! Must be greater than 0.")
      end)
      return
    end
    st.market.enchSellAt = num
  end
})

SellGroup:AddToggle({
  Title = "Auto Sell Enchant Stones",
  Content = "Automatically sells enchant stones for you",
  Default = false,
  Callback = function(state)
    st.market.enchSell = state

    task.spawn(function()
      while st.market.enchSell do
        if GetEnchantStoneCount() > tonumber(st.market.enchSellAt) then
          for _, Item in pairs(repl.Data.Data.Inventory.Items) do
            if Item.Id == 10 then
              st.Functions.SellItem:InvokeServer(Item.UUID)
              break
            end
          end
        end
        task.wait(1)
      end
    end)
  end
})

local Favorites = Tabs.Fishing:AddSection("Favorites")

local function IsFavorited(UUID, items)
  for _, Item in pairs(items) do
    if Item.UUID == UUID then return Item.Favorited == true end
  end
  return false
end

local RarityOrder = {Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythical = 6, Secret = 7}

local function AutoFavorite(names, rarities, mutations)
  local items = repl.Data.Data.Inventory.Items
  if not items or #items == 0 then return end

  local rarityTiers, namesList, mutationList = {}, {}, {}
  
  if rarities then
    for _, rarity in ipairs(rarities) do
      if RarityOrder[rarity] then 
        rarityTiers[RarityOrder[rarity]] = true
      end
    end
  end

  if names then for _, name in ipairs(names) do namesList[name] = true end end
  if mutations then for _, mutation in ipairs(mutations) do mutationList[mutation] = true end end

  local toFavorite = {}
  
  for _, Item in pairs(items) do
    if not Item.Favorited then
      local FishData = mods.ItemUtility:GetItemData(Item.Id)
      
      if FishData and FishData.Data then
        local data = FishData.Data
        if namesList[data.Name] or rarityTiers[data.Tier] or (Item.Metadata and Item.Metadata.VariantId and mutationList[Item.Metadata.VariantId]) then
          table.insert(toFavorite, Item.UUID)
        end
      end
    end
  end

  for i, uuid in ipairs(toFavorite) do
    task.spawn(function()
      task.wait(i * 0.05)
      api.Events.REFav:FireServer(uuid)
    end)
  end
end

local function UnAutoFavoriteAll()
  local Items = repl.Data.Data.Inventory.Items
  if not Items or #Items == 0 then return end

  for _, Item in pairs(Items) do
    if IsFavorited(Item.UUID) then
      pcall(api.Events.REFav.FireServer, api.Events.REFav, Item.UUID)
    end
  end
end

Favorites:AddDropdown({
  Title = "Auto Favorite by Rarity",
  Content = "Favorite by Fish Rarity",
  Multi = true,
  Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret"},
  Default = st.favorite.rarities,
  Callback = function(value)
    st.favorite.rarities = value
  end
})

local cachedFishNames = nil
local function GetFishNames()
  if cachedFishNames then return cachedFishNames end
  
  local Names = {}
  for _, Item in pairs(repl.Items:GetChildren()) do
    local FishData = mods.ItemUtility:GetItemData(Item.Name)
    if FishData and FishData.Data and FishData.Data.Type == "Fish" then
      table.insert(Names, FishData.Data.Name)
    end
  end
  cachedFishNames = Names
  return Names
end

Favorites:AddDropdown({
  Title = "Auto Favorite by Name",
  Content = "Favorite by Fish Name",
  Multi = true,
  Options = GetFishNames(),
  Default = st.favorite.names,
  Callback = function(value)
    st.favorite.names = value
  end
})

local cachedMutations = nil
local function GetFishMutation()
  if cachedMutations then return cachedMutations end
  
  local Names = {}
  for _, Item in pairs(repl.Variants:GetChildren()) do
    table.insert(Names, Item.Name)
  end
  cachedMutations = Names
  return Names
end

Favorites:AddDropdown({
  Title = "Auto Favorite by Mutation",
  Content = "Favorite by Fish Mutation",
  Multi = true,
  Options = GetFishMutation(),
  Default = st.favorite.mutations,
  Callback = function(value)
    st.favorite.mutations = value
  end
})

Favorites:AddToggle({
  Title = "Auto Favorite",
  Content = "Automatically favorites fish for you",
  Default = false,
  Callback = function(state)
    st.favorite.auto = state

    task.spawn(function()
      while st.favorite.auto do
        AutoFavorite(st.favorite.names, st.favorite.rarities, st.favorite.mutations)
        task.wait(2)
      end
    end)
  end
})

Favorites:AddButton({
  Title = "Unfavorite All",
  Content = "Unfavorites all favorited fish",
  Callback = UnAutoFavoriteAll
})

local HideFeature = Tabs.Fishing:AddSection("Hide Features")

pcall(function()
  local OriginalNotif = mods.NotificationController.PlaySmallItemObtained
  mods.NotificationController.PlaySmallItemObtained = function(self, ...)
    if st.hide.notifications then return end
    return OriginalNotif(self, ...)
  end
end)

HideFeature:AddToggle({
  Title = "Hide Notification",
  Content = "Hides get fishing notifications",
  Default = false,
  Callback = function(state)
    st.hide.notifications = state
  end
}, "HideNotification")

pcall(function()
  local OriginalInit = mods.CutsceneController.Init
  mods.CutsceneController.Init = function(self, ...)
    if st.hide.cutscenes then return end
    return OriginalInit(self, ...)
  end
end)

HideFeature:AddToggle({
  Title = "Skip Cutscenes",
  Content = "Automatically skips fishing cutscenes",
  Default = false,
  Callback = function(state)
    st.hide.cutscenes = state
  end
}, "HideCutscenes")

pcall(function()
  local OriginalAnim = mods.AnimationController.PlayAnimation
  mods.AnimationController.PlayAnimation = function(self, ...)
    if st.hide.animations then return end
    return OriginalAnim(self, ...)
  end
end)

HideFeature:AddToggle({
  Title = "Disable Animations",
  Content = "Disables fishing animations",
  Default = false,
  Callback = function(state)
    st.hide.animations = state
  end
}, "HideAnimations")

pcall(function()
  local OriginalRenderAP = mods.VFX.RenderAtPoint
  mods.VFX.RenderAtPoint = function(self, ...)
    if st.hide.vfx then return end
    return OriginalRenderAP(self, ...)
  end

  local OriginalRenderI = mods.VFX.RenderInstance
  mods.VFX.RenderInstance = function(self, ...)
    if st.hide.vfx then return end
    return OriginalRenderI(self, ...)
  end
end)

HideFeature:AddToggle({
  Title = "Disable Rod Effect",
  Content = "Hides the fishing rod bobber effect",
  Default = false,
  Callback = function(state)
    st.hide.vfx = state
  end
}, "HideVFX")

local Shop = Tabs.Automation:AddSection("Shop")

local ShopMerchant = Shop:AddParagraph({
  Title = "Merchant Stock Panel",
  Content = [[
- N/A
- N/A
- N/A

Next Refresh: 00H, 00M, 00S
  ]]
})

local function GetPanelItem(Panel)
  local Items = {}
  for _, Obj in ipairs(Panel:GetChildren()) do
    if Obj.Name == "Template" then
      local ItemName = Obj:FindFirstChild("Frame")
      if ItemName and ItemName:FindFirstChild("ItemName") then
        table.insert(Items, ItemName.ItemName.Text)
      end
    end
  end
  return Items
end

task.spawn(function()
  while task.wait(3) do
    local items = GetPanelItem(gui.ItemsFrame)
    ShopMerchant:SetContent(
      string.format([[
- %s
- %s
- %s

%s
      ]],
        items[1] or "N/A",
        items[2] or "N/A",
        items[3] or "N/A",
        gui.RefreshMerchant.Text
      ))
  end
end)

Shop:AddButton({
  Title = "Open / Close Merchant",
  Content = "Opens or closes the merchant shop panel",
  Callback = function()
    gui.Merchant.Enabled = not gui.Merchant.Enabled
  end
})

Shop:AddSubSection("Weather")

Shop:AddDropdown({
  Title = "Select Weather",
  Content = "Select a weather to change to",
  Multi = true,
  Options = {
    "Wind (10,000)",
    "Cloudy (20,000)",
    "Snow (15,000)",
    "Storm (35,000)",
    "Radiant (50,000)",
    "Shark Hunt (300,000)"
  },
  Default = {},
  Callback = function(value)
    st.shop.weather = value
  end
})

Shop:AddToggle({
  Title = "Auto Buy Weather",
  Content = "Automatically buys selected weather effects",
  Default = false,
  Callback = function(state)
    st.shop.autoWeather = state

    task.spawn(function()
      while st.shop.autoWeather and st.shop.weather do
        for _, weather in ipairs(st.shop.weather) do
          api.Functions.BuyWeather:InvokeServer(weather:match("^(.-) %("))
        end
        task.wait(5)
      end
    end)
  end
})

local Save = Tabs.Automation:AddSection("Save position Features")

function SavePosition(cf)
  local data = { cf:GetComponents() }
  writefile(PositionFile, svc.HttpService:JSONEncode(data))
end

function LoadPosition()
  if isfile(PositionFile) then
    local success, data = pcall(function()
      return svc.HttpService:JSONDecode(readfile(PositionFile))
    end)
    if success and typeof(data) == "table" then
      return CFrame.new(unpack(data))
    end
  end
  return nil
end

function TeleportLastPos(char)
  task.spawn(function()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local last = LoadPosition()

    if last then
      task.wait(2)
      hrp.CFrame = last
    end
  end)
end

player.CharacterAdded:Connect(TeleportLastPos)
if player.Character then
  TeleportLastPos(player.Character)
end

Save:AddButton({
  Title = "Save Position",
  Callback = function()
      local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
      SavePosition(hrp.CFrame)
      sirenx("Position saved successfully!")
    end
  end,
  SubTitle = "Reset Position",
  SubCallback = function()
    if isfile(PositionFile) then
      delfile(PositionFile)
    end
    sirenx("Last position has been reset.")
  end
})

local Islands= Tabs.Teleport:AddSection("Islands")

local TeleportLocations = {
  ["Fisherman Island"] = CFrame.new(92, 9, 2768),
  ["Arrow Lever"] = CFrame.new(898, 8, -363),
  ["Sisyphus Statue"] = CFrame.new(-3740, -136, -1013),
  ["Ancient Jungle"] = CFrame.new(1481, 11, -302),
  ["Weather Machine"] = CFrame.new(-1519, 2, 1908),
  ["Coral Refs"] = CFrame.new(-3105, 6, 2218),
  ["Tropical Island"] = CFrame.new(-2110, 53, 3649),
  ["Kohana"] = CFrame.new(-662, 3, 714),
  ["Esoteric Island"] = CFrame.new(2035, 27, 1386),
  ["Diamond Lever"] = CFrame.new(1818, 8, -285),
  ["Underground Cellar"] = CFrame.new(2098, -92, -703),
  ["Volcano"] = CFrame.new(-631, 54, 194),
  ["Enchant Room"] = CFrame.new(3255, -1302, 1371),
  ["Lost Isle"] = CFrame.new(-3717, 5, -1079),
  ["Sacred Temple"] = CFrame.new(1475, -22, -630),
  ["Creater Island"] = CFrame.new(981, 41, 5080),
  ["Double Enchant Room"] = CFrame.new(1480, 127, -590),
  ["Treasure Room"] = CFrame.new(-3599, -276, -1642),
  ["Crescent Lever"] = CFrame.new(1419, 31, 78),
  ["Hourglass Diamond Lever"] = CFrame.new(1484, 8, -862),
  ["Snow Island"] = CFrame.new(1627, 4, 3288),
  ["Ancient Ruin"] = CFrame.new(6087, -584, 4633),
  ["Classic Island"] = CFrame.new(1251, 11, 2803),
  ["Iron Cavern"] = CFrame.new(-8913, -580, 156),
  ["Iron Cafe"] = CFrame.new(-8642, -546, 149),
}

local function GetNameTeleport()
  local Names = {}
  for Key,_ in pairs(TeleportLocations) do table.insert(Names, Key) end
  return Names
end

Islands:AddDropdown({
  Title = "Select Island",
  Content = "Select an island to teleport to",
  Options = GetNameTeleport(),
  Default = nil,
  Callback = function(value)
    st.teleport.island = value
  end
})

Islands:AddButton({
  Title = "Teleport",
  Content = "Teleports you to the selected island",
  Callback = function()
    local loc = TeleportLocations[st.teleport.island]
    if not loc then return end

    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = loc
      sirenx("Teleported to " .. st.teleport.island)
    end
  end
})

local Events = Tabs.Teleport:AddSection("Events")

local function GetEventLocations()
  local List = {}
  for _, Obj in ipairs(st.menuRings:GetChildren()) do
    if Obj:IsA("Model") and Obj.Name == "Props" then
      for _, Prop in ipairs(Obj:GetChildren()) do
        if Prop:IsA("Model") then
          if Prop.Name == "Model" then
            table.insert(List, "Worm Hunt")
          else
            table.insert(List, Prop.Name)
          end
        end
      end
    end
  end
  return List
end

local EventList = Events:AddDropdown({
  Title = "Select Event",
  Content = "Select an event to teleport to",
  Options = GetEventLocations(),
  Default = nil,
  Callback = function(value)
    st.teleport.event = value
  end
})

Events:AddButton({
  Title = "Teleport",
  Content = "Teleports you to the selected event",
  Callback = function()
    if not st.teleport.event then return end

    local Target = nil
    for _, Obj in ipairs(st.menuRings:GetChildren()) do
      if Obj:IsA("Model") and Obj.Name == "Props" then
        for _, Prop in ipairs(Obj:GetChildren()) do
          if Prop:IsA("Model") then
            if st.teleport.event == "Worm Hunt" and Prop.Name == "Model" then
              Target = Prop
              break
            elseif Prop.Name == st.teleport.event then
              Target = Prop
              break
            end
          end
        end
        if Target then break end
      end
    end

    if Target then
      st.char:PivotTo(Target:GetPivot())
      task.wait(.5)

      local Ocean = st.zones:FindFirstChild("Ocean")
      for _, obj in ipairs(Ocean:GetDescendants()) do
        if obj:IsA("Texture") then
          obj.Parent.CanCollide = true
        end
      end
    end
  end
})

task.spawn(function()
	while task.wait(5) do
		EventList:SetValues(GetEventLocations(), st.teleport.event)
	end
end)

local Plyr = Tabs.Teleport:AddSection("Player")

local function GetPlayerNames()
  local Names = {}
  for _, Plr in pairs(svc.Players:GetPlayers()) do
    if Plr ~= player then
      table.insert(Names, Plr.Name)
    end
  end
  return Names
end

local PlayerList = Plyr:AddDropdown({
  Title = "Select Player",
  Content = "Select a player to teleport to",
  Options = GetPlayerNames(),
  Default = nil,
  Callback = function(value)
    st.teleport.player = value
  end
})

Plyr:AddButton({
  Title = "Refresh Player List",
  Callback = function()
    PlayerList:SetValues(GetPlayerNames(), st.teleport.player)
    sirenx("Player list refreshed.")
  end,
  SubTitle = "Go to Player",
  SubCallback = function()
    TargetPlayer = svc.Players:FindFirstChild(st.teleport.player)
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
      st.char:PivotTo(TargetPlayer.Character:GetPivot())
      sirenx("Teleported to " .. TargetPlayer.Name)
    end
  end
})

local LVR = Tabs.Quest:AddSection("Artifact Lever Location")

local Jungle = workspace:WaitForChild("JUNGLE INTERACTIONS")
local LOOP_DELAY, running, waitingArtifact = 1, false, nil
local ACTIVE_COLOR, DISABLE_COLOR = "0,255,0", "255,0,0"

_G.artifactPositions = {
  ["Arrow Artifact"] = CFrame.new(875, 3, -368) * CFrame.Angles(0, math.rad(90), 0),
  ["Crescent Artifact"] = CFrame.new(1403, 3, 123) * CFrame.Angles(0, math.rad(180), 0),
  ["Hourglass Diamond Artifact"] = CFrame.new(1487, 3, -842) * CFrame.Angles(0, math.rad(180), 0),
  ["Diamond Artifact"] = CFrame.new(1844, 3, -287) * CFrame.Angles(0, math.rad(-90), 0)
}

local orderList = { "Arrow Artifact", "Crescent Artifact", "Hourglass Diamond Artifact", "Diamond Artifact" }

local function getStatus()
  local s = {}
  for _, o in ipairs(Jungle:GetDescendants()) do
    if o:IsA("Model") and o.Name == "TempleLever" then
      s[o:GetAttribute("Type")] = not (o:FindFirstChild("RootPart") and o.RootPart:FindFirstChildWhichIsA("ProximityPrompt"))
    end
  end
  return s
end

local function setStatusUI(st)
  local function seg(k, v)
    local n = (k == "Hourglass Diamond Artifact" and "Hourglass Diamond") or (k == "Arrow Artifact" and "Arrow") or
      (k == "Crescent Artifact" and "Crescent") or "Diamond"
    local c = v and ACTIVE_COLOR or DISABLE_COLOR
    return ('%s : <b><font color="rgb(%s)">%s</font></b>'):format(n, c, v and "ACTIVE" or "DISABLE")
  end
  ArtifactParagraph:SetContent(table.concat({
    seg("Arrow Artifact", st["Arrow Artifact"]),
    seg("Crescent Artifact", st["Crescent Artifact"]),
    seg("Hourglass Diamond Artifact", st["Hourglass Diamond Artifact"]),
    seg("Diamond Artifact", st["Diamond Artifact"])
  }, "\n"))
end

local function firePromptFor(name)
  for _, o in ipairs(Jungle:GetDescendants()) do
    if o:IsA("Model") and o.Name == "TempleLever" and o:GetAttribute("Type") == name then
      local p = o:FindFirstChild("RootPart") and o.RootPart:FindFirstChildWhichIsA("ProximityPrompt")
      if p then fireproximityprompt(p) end
      break
    end
  end
end

ArtifactParagraph = LVR:AddParagraph({
  Title = "Panel Progress Artifact",
  Content = [[
Arrow : <b><font color="rgb(255,0,0)">DISABLE</font></b>
Crescent : <b><font color="rgb(255,0,0)">DISABLE</font></b>
Hourglass Diamond : <b><font color="rgb(255,0,0)">DISABLE</font></b>
Diamond : <b><font color="rgb(255,0,0)">DISABLE</font></b>
]]
})

api.Events.REFishGot.OnClientEvent:Connect(function(fish)
  if not running or not waitingArtifact then return end
  local head = string.split(waitingArtifact, " ")[1]
  if head and string.find(fish, head, 1, true) then
    task.wait(0)
    firePromptFor(waitingArtifact)
    waitingArtifact = nil
  end
end)

LVR:AddToggle({
  Title = "Artifact Progress",
  Default = false,
  Callback = function(state)
    running = state
    if state then
      task.spawn(function()
        while running do
          local status, all = getStatus(), true
          for _, v in pairs(status) do
            if not v then
              all = false
              break
            end
          end
          setStatusUI(status)
          if all then
            running = false
            break
          end

          for _, n in ipairs(orderList) do
            if not status[n] then
              waitingArtifact = n

              local hrp = getHRP()
              if hrp and _G.artifactPositions[n] then
                  hrp.CFrame = _G.artifactPositions[n]
              end

              repeat
                task.wait(LOOP_DELAY)
              until not waitingArtifact or not running
              break
            end
          end

          task.wait(2)
        end
      end)
    end
  end
})

task.spawn(function()
  while task.wait(3) do
    if not running then
      setStatusUI(getStatus())
    end
  end
end)

LVR:AddButton({
  Title = "Arrow",
  Callback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = _G.artifactPositions["Arrow Artifact"]
    end
  end,
  SubTitle = "Hourglass Diamond",
  SubCallback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = _G.artifactPositions["Hourglass Diamond Artifact"]
    end
  end
})

LVR:AddButton({
  Title = "Crescent",
  Callback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = _G.artifactPositions["Crescent Artifact"]
    end
  end,
  SubTitle = "Diamond",
  SubCallback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = _G.artifactPositions["Diamond Artifact"]
    end
  end
})

local DeepSeaQuest = Tabs.Quest:AddSection("Sisyphus Statue Quest")
local DeepSeaPara = DeepSeaQuest:AddParagraph({
  Title = "Deep Sea Panel",
  Content = ""
})

DeepSeaQuest:AddDivider()

DeepSeaQuest:AddToggle({
  Title = "Auto Deep Sea Quest",
  Content = "Automatically complete Deep Sea Quest!",
  Default = false,
  Callback = function(state)
    st.quest.autoDeepSea = state

    task.spawn(function()
      while st.quest.autoDeepSea do
        local tracker = workspace:FindFirstChild("!!! MENU RINGS") and workspace["!!! MENU RINGS"]:FindFirstChild("Deep Sea Tracker")
        if tracker then
          local content = tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui") and tracker.Board.Gui:FindFirstChild("Content")
          if content then
            local firstLabel
            for _, child in ipairs(content:GetChildren()) do
              if child:IsA("TextLabel") and child.Name ~= "Header" then
                firstLabel = child
                break
              end
            end

            if firstLabel then
              local text = string.lower(firstLabel.Text)
              local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
              if hrp then
                if string.find(text, "100%%") then
                  hrp.CFrame = CFrame.new(-3763, -135, -995) * CFrame.Angles(0, math.rad(180), 0)
                else
                  hrp.CFrame = CFrame.new(-3599, -276, -1641)
                end
              end
            end
          end
        end
        task.wait(2)
      end
    end)
  end
})

DeepSeaQuest:AddButton({
  Title = "Treasure Room",
  Callback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = CFrame.new(-3601, -283, -1611)
    end
  end,
  SubTitle = "Sisyphus Statue",
  SubCallback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = CFrame.new(-3698, -135, -1008)
    end
  end
})

local ElementQuest = Tabs.Quest:AddSection("Element Quest")
local ElementPara = ElementQuest:AddParagraph({
    Title = "Element Panel",
    Content = ""
})

ElementQuest:AddDivider()

ElementQuest:AddToggle({
  Title = "Auto Element Quest",
  Content = "Automatically teleport through Element quest stages.",
  Default = false,
  Callback = function(state)
    st.quest.autoElement = state

    task.spawn(function()
      while st.quest.autoElement do
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local tracker = workspace:FindFirstChild("!!! MENU RINGS") and workspace["!!! MENU RINGS"]:FindFirstChild("Element Tracker")

        if hrp and tracker then
          local content = tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui") and tracker.Board.Gui:FindFirstChild("Content")

          if content then
            local labels = {}
            for _, c in ipairs(content:GetChildren()) do
              if c:IsA("TextLabel") and c.Name ~= "Header" then
                table.insert(labels, string.lower(c.Text))
              end
            end

            if #labels >= 4 then
              local label2, label4 = labels[2], labels[4]

              if not string.find(label4, "100%%") then
                local targetCF = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0)
                hrp.CFrame = targetCF
                autoReturn(hrp, targetCF, 100)

              elseif string.find(label4, "100%%") and not string.find(label2, "100%%") then
                local targetCF = CFrame.new(1453, -22, -636)
                hrp.CFrame = targetCF
                autoReturn(hrp, targetCF, 100)

              elseif string.find(label2, "100%%") then
                local targetCF = CFrame.new(1480, 128, -593)
                hrp.CFrame = targetCF
                autoReturn(hrp, targetCF, 100)

                st.quest.autoElement = false
                ElementPara:SetContent("Element Quest Completed!")
                break
              end
            end
          end
        end
        task.wait(2)
      end
    end)
  end
})

ElementQuest:AddButton({
  Title = "Secred Temple",
  Callback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = CFrame.new(1453, -22, -636)
    end
  end,
  SubTitle = "Underground Cellar",
  SubCallback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = CFrame.new(2136, -91, -701)
    end
  end
})

ElementQuest:AddButton({
  Title = "Transcended Stones",
  Callback = function()
    local char = st.player.Character or st.player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
      hrp.CFrame = CFrame.new(1480, 128, -593)
    end
  end
})

local function readTracker(name)
  local path = workspace["!!! MENU RINGS"]:FindFirstChild(name)
  if not path then return "" end
  local content = path:FindFirstChild("Board") and path.Board:FindFirstChild("Gui") and
    path.Board.Gui:FindFirstChild("Content")
  if not content then return "" end
  local lines = {}
  local index = 1
  for _, child in ipairs(content:GetChildren()) do
    if child:IsA("TextLabel") and child.Name ~= "Header" then
      table.insert(lines, index .. ". " .. child.Text)
      index += 1
    end
  end
  return table.concat(lines, "\n")
end

task.spawn(function()
  while task.wait(5) do
    ElementPara:SetContent(readTracker("Element Tracker"))
    DeepSeaPara:SetContent(readTracker("Deep Sea Tracker"))
  end
end)

QuestSec = Tabs.Quest:AddSection("Auto Progress Quest Features")

QuestProgress = QuestSec:AddParagraph({
  Title = "Progress Quest Panel",
  Content = "Waiting for start..."
})

QuestSec:AddToggle({
  Title = "Auto Teleport Quest",
  Default = false,
  Callback = function(state)
    st.quest.autoQuestFlow = state
    task.spawn(function()
      local finishedDeep = false
      local finishedLever = false
      local finishedElem = false
      local teleported = { Deep = false, Lever = false, Element = false }

      function updateParagraph(content)
          if QuestProgress and QuestProgress.SetContent then
              QuestProgress:SetContent(content)
          end
      end

      while st.quest.autoQuestFlow and not (finishedDeep and finishedLever and finishedElem) do
        if not finishedDeep then
          local dsFolder = workspace:FindFirstChild("!!! MENU RINGS")
          local tracker = dsFolder and dsFolder:FindFirstChild("Deep Sea Tracker")
          local dsContent = tracker and tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui") and
              tracker.Board.Gui:FindFirstChild("Content")

          local allComplete, completed, total = true, 0, 0
          if dsContent then
            for _, lbl in ipairs(dsContent:GetChildren()) do
              if lbl:IsA("TextLabel") and lbl.Name ~= "Header" then
                total += 1
                if string.find(lbl.Text, "100%%") then
                  completed += 1
                else
                  allComplete = false
                end
              end
            end
          end

          local percent = total > 0 and math.floor((completed / total) * 100) or 0
          updateParagraph(string.format("Doing objective on Deep Sea Quest...\nProgress now %d%%.", percent))

          if not allComplete and not teleported.Deep then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
              hrp.CFrame = CFrame.new(-3599, -276, -1641)
              teleported.Deep = true
            end
          elseif allComplete then
            finishedDeep = true
            updateParagraph("Deep Sea Quest Completed!\nProceeding to Artifact Lever...")
          end
          task.wait(1)
        end

        if finishedDeep and not finishedLever and st.quest.autoQuestFlow then
          local Jungle = workspace:FindFirstChild("JUNGLE INTERACTIONS")
          local s, all = getStatus(), true
          for _, v in pairs(s) do
            if not v then
              all = false
              break
            end
          end

          if not all and not teleported.Lever then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and _G.artifactPositions["Arrow Artifact"] then
              hrp.CFrame = _G.artifactPositions["Arrow Artifact"]
              teleported.Lever = true
            end
            updateParagraph("Doing objective on Artifact Lever...\nProgress now 75%.")
          elseif all then
            finishedLever = true
            updateParagraph("Artifact Lever Completed!\nProceeding to Element Quest...")
          end
          task.wait(1)
        end

        if finishedDeep and finishedLever and not finishedElem and st.quest.autoQuestFlow then
          local elFolder = workspace:FindFirstChild("!!! MENU RINGS")
          local elTracker = elFolder and elFolder:FindFirstChild("Element Tracker")
          local elContent = elTracker and elTracker:FindFirstChild("Board") and
            elTracker.Board:FindFirstChild("Gui") and elTracker.Board.Gui:FindFirstChild("Content")

          if elContent then
            local lines = {}
            for _, child in ipairs(elContent:GetChildren()) do
              if child:IsA("TextLabel") and child.Name ~= "Header" then
                table.insert(lines, child.Text)
              end
            end

            local label2 = lines[2] and string.lower(lines[2]) or ""
            local label4 = lines[4] and string.lower(lines[4]) or ""
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

            if not (string.find(label2, "100%%") and string.find(label4, "100%%")) then
              if not teleported.Element and hrp then
                hrp.CFrame = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0)
                teleported.Element = true
              end

              if not string.find(label4, "100%%") then
                updateParagraph("Doing objective on Element Quest...\nProgress now 50%.")
              elseif string.find(label4, "100%%") and not string.find(label2, "100%%") then
                hrp.CFrame = CFrame.new(1453, -22, -636)
                updateParagraph("Doing objective on Element Quest...\nProgress now 75%.")
              end
            else
              finishedElem = true
              updateParagraph("All Quest Completed Successfully! :3")
              st.quest.autoQuestFlow = false
            end
          end
          task.wait(1)
        end
      end
    end)
  end
})
