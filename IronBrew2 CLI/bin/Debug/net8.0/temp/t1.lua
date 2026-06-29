
local now = tick()
if _G.UILoaded and (now - (_G.LastUILoadTime or 0)) < 5 then
    return
end

_G.UILoaded = true
_G.LastUILoadTime = now

if getgenv().uiActive then
    getgenv().uiActive = false
    task.wait(0.5)
end
if getgenv().uiUpd then
    pcall(function() getgenv().uiUpd:Unload() end)
end

getgenv().isStartup = true

local repo = "https://raw.githubusercontent.com/nostrainu/ObsidianFork/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local folder, path = "bobcat", "bobcat/games/AS/config.json"

getgenv().Library = Library
getgenv().uiUpd = Library
getgenv().uiActive = true


local Macro = getgenv().Macro

if not Macro then
    getfenv()["wa" .. "rn"]("[Anime Squadron ASMain] Macro is nil in getgenv()!")
    error("[Anime Squadron] ASFunc.lua failed to load before ASMain.lua")
end

local Loading = Library:CreateLoading({
    Title = "Poop-Cat",
    Icon = "loader-2",
    CurrentStep = 0,
    TotalSteps = 3,
    ShowSidebar = true,
})


local Window = Library:CreateWindow({
    Title = "Pop-cat",
    Footer = "Anime Squadron",
    MobileButtonsSide = "Left",
    ShowMobileButtons = true,
    NotifySide = "Right",
    Center = true,
    SideBarText = false,
    ScrollLongText = true,
    Size = UDim2.fromOffset(650, 450),
    DisableFloatingMenu = registerSetting("DisableFloatingMenu", false)
})

task.wait(0.2)
Loading:SetCurrentStep(3)
Loading:Destroy()


Window:AddTabSection("Main Features")
local Tabs = {
    
    Main = Window:AddTab("Main", "layers-2"),

    
    Macro = Window:AddTab("Macro", "video"),

    
    

    
    Rotation = Window:AddTab("Map Rotation", "refresh-cw"),

    
    Misc = Window:AddTab("Miscellaneous", "book"),

    
    Webhook = Window:AddTab("Webhook", "external-link")
}


local MainGroupBox = Tabs.Main:AddLeftGroupbox({
    Name = "Join Room",
    Center = true,
    Collapsible = true,
    DefaultCollapsed = false
})

local findWorldsModule = getgenv().findWorldsModule
local updateMapModeLevelDropdowns = getgenv().updateMapModeLevelDropdowns

local mapValues = getgenv().initialMapValues or {"GT City", "Marine Lobby", "Ninja Village", "Katakura Wasteland", "Eclipse (Before)", "Katakara Bridge"}
local modeValues = getgenv().initialModeValues or {"Story", "Squadron", "Raid"}
local difficultyValues = getgenv().initialDifficultyValues or {"Normal", "Hard"}
local levelValues = getgenv().initialLevelValues or {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
local webhookItemValues = getgenv().initialWebhookItems or {
    "Yen", "Gems", "Perfect Cubes", "Reroll Cubes", "Trait Shards",
    "Beastblood Catalyst", "Binding Cloth", "Bounty Tickets", "Chakra Fragment",
    "Currentbinder Rope", "Depthglass Bottle", "Eclipse Godstone", "Fuin Script Paper",
    "Genjutsu Fog Vial", "Hogyoku", "Ki Resonant Crystal", "Limitbreak Obsidian",
    "Meat", "Narutomaki", "Ninja Headband", "Omega Chest", "Omega Coins"
}

MainGroupBox:AddDropdown("SelectedMap", {
    Text = "Select Map",
    Values = mapValues,
    Multi = false,
    Default = registerSetting("SelectedMap"),
    Callback = function(val)
        setConfig("SelectedMap", val)
        updateMapModeLevelDropdowns()
    end
})

MainGroupBox:AddDropdown("SelectedMode", {
    Text = "Select Mode",
    Values = modeValues,
    Multi = false,
    Default = registerSetting("SelectedMode"),
    Callback = function(val)
        setConfig("SelectedMode", val)
        updateMapModeLevelDropdowns()
    end
})

MainGroupBox:AddDropdown("SelectedDifficulty", {
    Text = "Select Difficulty",
    Values = difficultyValues,
    Multi = false,
    Default = registerSetting("SelectedDifficulty"),
    Callback = function(val)
        setConfig("SelectedDifficulty", val)
        updateMapModeLevelDropdowns()
    end
})

MainGroupBox:AddDropdown("SelectedLevel", {
    Text = "Select Level",
    Values = levelValues,
    Multi = false,
    Default = registerSetting("SelectedLevel"),
    Callback = function(val)
        setConfig("SelectedLevel", val)
        updateMapModeLevelDropdowns()
    end
})

MainGroupBox:AddDivider()

MainGroupBox:AddSlider("JoinDelay", {
    Text = "Join Delay",
    Default = registerSetting("JoinDelay", 3),
    Min = 1, Max = 15, Rounding = 0,
    Suffix = "s",
    Callback = function(val) setConfig("JoinDelay", val) end
})

MainGroupBox:AddToggle("AutoJoin", {
    Text = "Auto Join",
    Default = registerSetting("AutoJoin", false),
    Callback = function(val)
        if getgenv().updatingUI then return end
        setConfig("AutoJoin", val)
        if val then
            setConfig("AutoChallenge", false)
            setConfig("AutoRaid", false)
            if Library.Toggles.MapRotation then
                Library.Toggles.MapRotation:SetValue(false)
            end
            SyncUI()
        end
    end
})

local ChallengeGroupBox = Tabs.Main:AddRightGroupbox({
    Name = "Challenge",
    Center = true,
    Collapsible = true,
    DefaultCollapsed = false
})

local ChallengeInfoLabel = ChallengeGroupBox:AddLabel("Loading challenge data...", true)
getgenv().ChallengeInfoLabel = ChallengeInfoLabel

ChallengeGroupBox:AddDropdown("ChallengeType", {
    Text = "Challenge Type",
    Values = {"30m", "1d", "Katakara Bridge"},
    Multi = true,
    Default = registerSetting("ChallengeType", { ["30m"] = true, ["1d"] = true, ["Katakara Bridge"] = true }),
    Callback = function(val) setConfig("ChallengeType", val) end
})

ChallengeGroupBox:AddDropdown("ChallengeRewardFilter", {
    Text = "Required Reward Filter",
    Values = {"Trait Shards", "Perfect Cubes", "Reroll Cubes", "Gems"},
    Multi = true,
    Default = registerSetting("ChallengeRewardFilter", {}),
    Callback = function(val) setConfig("ChallengeRewardFilter", val) end
})

ChallengeGroupBox:AddSlider("ChallengeDelay", {
    Text = "Challenge Join Delay",
    Default = registerSetting("ChallengeDelay", 3),
    Min = 1, Max = 15, Rounding = 0,
    Suffix = "s",
    Callback = function(val) setConfig("ChallengeDelay", val) end
})

ChallengeGroupBox:AddToggle("AutoChallenge", {
    Text = "Auto Challenge",
    Default = registerSetting("AutoChallenge", false),
    Callback = function(val)
        if getgenv().updatingUI then return end
        setConfig("AutoChallenge", val)
        if val then
            setConfig("AutoJoin", false)
            setConfig("AutoRaid", false)
            if Library.Toggles.MapRotation then
                Library.Toggles.MapRotation:SetValue(false)
            end
            SyncUI()
        end
    end
})


local MiscGroupBox = Tabs.Misc:AddLeftGroupbox({
    Name = "Summon",
    Center = true,
    Collapsible = true,
    DefaultCollapsed = false
})

MiscGroupBox:AddDropdown("SummonBanner", {
    Text = "Select Banner",
    Values = {"Basic Banner", "Selection Banner"},
    Multi = false,
    Default = registerSetting("SummonBanner", "Basic Banner"),
    Callback = function(val) setConfig("SummonBanner", val) end
})

MiscGroupBox:AddDropdown("SummonAmount", {
    Text = "Summon Amount",
    Values = {"1", "10"},
    Multi = false,
    Default = registerSetting("SummonAmount", "10"),
    Callback = function(val) setConfig("SummonAmount", val) end
})

MiscGroupBox:AddToggle("AutoSummon", {
    Text = "Auto Summon",
    Default = registerSetting("AutoSummon", false),
    Callback = function(val) setConfig("AutoSummon", val) end
})

MiscGroupBox:AddDivider()

MiscGroupBox:AddToggle("AutoRedeemCodes", {
    Text = "Auto Redeem Codes",
    Default = registerSetting("AutoRedeemCodes", false),
    Callback = function(val)
        setConfig("AutoRedeemCodes", val)
    end
})

local MapRotationTabbox = Tabs.Rotation:AddMiddleTabbox({
    Name = "Map Rotation",
    Collapsible = true,
    Center = true,
    DefaultCollapsed = false
})

local MapSettings = MapRotationTabbox:AddTab("Map Priority")
local MapTab = MapRotationTabbox:AddTab("Map Selection")

local function updatePriorityMapDropdown(i)
    local modeOption = Library.Options["Priority" .. i]
    local mapOption = Library.Options["Priority" .. i .. "Map"]
    if not modeOption or not mapOption then return end

    local currentMode = modeOption.Value
    local currentMap = mapOption.Value

    local allowedMaps = getMapsForMode(currentMode)
    mapOption:SetValues(allowedMaps)

    if not table.find(allowedMaps, currentMap) then
        local newMap = allowedMaps[1] or ""
        mapOption:SetValue(newMap)
        setConfig("Priority" .. i .. "Map", newMap)
    end
end

MapSettings:AddDropdown("Priority1", {
    Text = "Priority 1",
    Values = {"None", "Story", "Squadron", "Raid"},
    Default = registerSetting("Priority1", "Story"),
    Callback = function(val)
        if getgenv().updatingUI then return end
        setConfig("Priority1", val)
        updatePriorityMapDropdown(1)
        if getgenv().config.MapRotation and getgenv().initMapRotation then
            getgenv().initMapRotation()
        end
    end
})

MapSettings:AddDropdown("Priority2", {
    Text = "Priority 2",
    Values = {"None", "Story", "Squadron", "Raid"},
    Default = registerSetting("Priority2", "Story"),
    Callback = function(val)
        if getgenv().updatingUI then return end
        setConfig("Priority2", val)
        updatePriorityMapDropdown(2)
        if getgenv().config.MapRotation and getgenv().initMapRotation then
            getgenv().initMapRotation()
        end
    end
})

MapSettings:AddDropdown("Priority3", {
    Text = "Priority 3",
    Values = {"None", "Story", "Squadron", "Raid"},
    Default = registerSetting("Priority3", "Squadron"),
    Callback = function(val)
        if getgenv().updatingUI then return end
        setConfig("Priority3", val)
        updatePriorityMapDropdown(3)
        if getgenv().config.MapRotation and getgenv().initMapRotation then
            getgenv().initMapRotation()
        end
    end
})

MapSettings:AddSlider("PriorityRunsLimit", {
    Text = "Runs Per Mode",
    Default = registerSetting("PriorityRunsLimit", 5),
    Min = 1, Max = 50, Rounding = 0,
    Suffix = " run(s)",
    Callback = function(val) setConfig("PriorityRunsLimit", val) end
})

MapSettings:AddSlider("PriorityJoinDelay", {
    Text = "Cycle Join Delay",
    Default = registerSetting("PriorityJoinDelay", 5),
    Min = 1, Max = 15, Rounding = 0,
    Suffix = "s",
    Callback = function(val) setConfig("PriorityJoinDelay", val) end
})

MapSettings:AddToggle("MapRotation", {
    Text = "Auto Map Rotation",
    Default = registerSetting("MapRotation", false),
    Callback = function(val)
        if getgenv().updatingUI then return end
        setConfig("MapRotation", val)
        if val then
            if not getgenv().isStartup then
                getgenv().CurrentPriorityIndex = 1
                setConfig("CurrentPriorityIndex", 1)
                getgenv().CurrentModeRuns = 0
                setConfig("CurrentModeRuns", 0)
                getgenv().SessionRuns = 0
            end
            if Library.Toggles.AutoJoin then
                Library.Toggles.AutoJoin:SetValue(false)
            else
                setConfig("AutoJoin", false)
            end
            if Library.Toggles.AutoChallenge then
                Library.Toggles.AutoChallenge:SetValue(false)
            else
                setConfig("AutoChallenge", false)
            end
            setConfig("AutoRaid", false)
            if getgenv().initMapRotation then
                getgenv().initMapRotation()
            end
        else
            if getgenv().initMapRotation then
                getgenv().initMapRotation()
            end
        end
        if getgenv().SyncUI then
            getgenv().SyncUI()
        end
    end
})

for i = 1, 3 do
    MapTab:AddLabel({ Text = "Priority " .. i .. " Settings", DoesWrap = true })
    MapTab:AddDropdown("Priority" .. i .. "Map", {
        Text = "Map",
        Values = mapValues,
        Default = registerSetting("Priority" .. i .. "Map", "GT City"),
        Callback = function(val) setConfig("Priority" .. i .. "Map", val) end
    })
    MapTab:AddDropdown("Priority" .. i .. "Difficulty", {
        Text = "Difficulty",
        Values = difficultyValues,
        Default = registerSetting("Priority" .. i .. "Difficulty", "Normal"),
        Callback = function(val) setConfig("Priority" .. i .. "Difficulty", val) end
    })
    MapTab:AddDropdown("Priority" .. i .. "Level", {
        Text = "Level",
        Values = levelValues,
        Default = registerSetting("Priority" .. i .. "Level", "1"),
        Callback = function(val) setConfig("Priority" .. i .. "Level", val) end
    })

    if i < 3 then
        MapTab:AddDivider()
    end

    task.spawn(function()
        task.wait(0.2)
        updatePriorityMapDropdown(i)
    end)
end

local WebhookGroupBox = Tabs.Webhook:AddLeftGroupbox({
    Name = "Webhook Settings",
    Center = true,
    Collapsible = true,
    DefaultCollapsed = false
})

WebhookGroupBox:AddInput("WebhookURL", {
    Text = "Webhook URL",
    Default = registerSetting("WebhookURL", ""),
    Placeholder = "Enter Discord Webhook URL...",
    Callback = function(val) setConfig("WebhookURL", val) end
})

WebhookGroupBox:AddToggle("AutoChallengeWebhook", {
    Text = "Send Match Webhooks",
    Default = registerSetting("AutoChallengeWebhook", false),
    Callback = function(val) setConfig("AutoChallengeWebhook", val) end
})

WebhookGroupBox:AddToggle("PingSecretUnit", {
    Text = "Ping on Secret Unit",
    Default = registerSetting("PingSecretUnit", false),
    Callback = function(val) setConfig("PingSecretUnit", val) end
})

WebhookGroupBox:AddInput("DiscordUserID", {
    Text = "Discord User ID",
    Default = registerSetting("DiscordUserID", ""),
    Placeholder = "Enter Discord User ID for pings...",
    Callback = function(val) setConfig("DiscordUserID", val) end
})

WebhookGroupBox:AddDropdown("WebhookItems", {
    Text = "Show Items in Webhook",
    Values = webhookItemValues,
    Multi = true,
    Default = registerSetting("WebhookItems", { ["Yen"] = true, ["Gems"] = true, ["Perfect Cubes"] = true, ["Reroll Cubes"] = true }),
    Callback = function(val) setConfig("WebhookItems", val) end
})

WebhookGroupBox:AddButton("Test Webhook", function()
    local url = Library.Options.WebhookURL and Library.Options.WebhookURL.Value or ""
    if url == "" or not url:find("discord.com") then
        Library:Notify("Invalid Discord Webhook URL!", 3)
        return
    end
    
    local fields = { { name = "Status", value = "Online / Working", inline = true } }
    pcall(function()
        local getInventoryTotal = getgenv().getInventoryTotal
        local formatNumber = getgenv().formatNumber
        if getInventoryTotal and formatNumber then
            local selected = getgenv().config and getgenv().config.WebhookItems or { ["Yen"] = true, ["Gems"] = true, ["Perfect Cubes"] = true, ["Reroll Cubes"] = true }
            local order = getgenv().initialWebhookItems or { "Yen", "Gems", "Perfect Cubes", "Reroll Cubes", "Trait Shards" }
            local statsList = {}
            local processed = {}
            for _, name in ipairs(order) do
                processed[name] = true
                if selected[name] then
                    local val = getInventoryTotal(name) or 0
                    table.insert(statsList, string.format("- **%s:** %s", name, formatNumber(val)))
                end
            end
            for name, isSelected in pairs(selected) do
                if isSelected and not processed[name] then
                    local val = getInventoryTotal(name) or 0
                    table.insert(statsList, string.format("- **%s:** %s", name, formatNumber(val)))
                end
            end
            if #statsList > 0 then
                table.insert(fields, { name = "Player Data (Selected)", value = table.concat(statsList, "\n"), inline = false })
            end
        end
    end)
    
    pcall(function()
        local getgenv = getgenv
        if getgenv().sendDiscordWebhook then
            getgenv().sendDiscordWebhook(
                "Test Webhook",
                "Your Anime Squadron script webhook is configured correctly!",
                fields
            )
            Library:Notify("Test Webhook sent!", 3)
        else
            Library:Notify("Webhook function not loaded!", 3)
        end
    end)
end)

local MacroStatus


local RecorderBox = Tabs.Macro:AddLeftGroupbox({
    Name = "Record",
    Center = true,
    Collapsible = true,
    DefaultCollapsed = false
})

MacroStatus = RecorderBox:AddMacroStatus("MacroStatus")

local dummyLabel = {
    SetText = function() end,
    SetVisible = function() end,
}
Macro.StatusLabel = MacroStatus
Macro.SpaceLabel = dummyLabel
Macro.ActionLabel = dummyLabel
Macro.NextLabel = dummyLabel

RecorderBox:AddDivider()

RecorderBox:AddSlider("MacroDelay", {
    Text = "Delay",
    Default = registerSetting("MacroDelay", 0.2),
    Min = 0.2, Max = 1, Rounding = 1,
    Suffix = "x",
    Callback = function(val) setConfig("MacroDelay", val) end
})


RecorderBox:AddToggle("MacroRecord", {
    Text = "Record Macro",
    Default = registerSetting("MacroRecord", false),
    Callback = function(val)
        setConfig("MacroRecord", val)
        local selected = (Library.Options and Library.Options.MacroSelect) and Library.Options.MacroSelect.Value or ""
        if val then
            if Library.Toggles.MacroPlay and Library.Toggles.MacroPlay.Value then
                Library.Toggles.MacroPlay:SetValue(false)
            end
            if Macro.IsPlaying then
                task.spawn(function() Library.Toggles.MacroRecord:SetValue(false) end)
                return
            end
            if selected == "" or selected == "---" then
                task.spawn(function() Library.Toggles.MacroRecord:SetValue(false) end)
                return
            end
            local path = "bobcat/games/AS/macros/" .. selected .. ".json"
            if not isfile(path) then
                task.spawn(function() Library.Toggles.MacroRecord:SetValue(false) end)
                return
            end
            if not Macro.IsRecording then
                Macro:StartRecording()
                MacroStatus:Update({ State = "Recording (0 steps)", Current = "Waiting for actions..." })

                Macro.OnRecord = function(stepNum, actionType, args, cost)
                    local label = getLabelText(actionType)
                    local unitName = Macro:ResolveName(args[1])
                    if cost and cost > 0 then
                        unitName = string.format("%s | Â¥ %d", unitName, cost)
                    end
                    MacroStatus:Update({
                        State = string.format("Recording (%d steps)", stepNum),
                        Current = string.format("%s - %s", label, unitName),
                    })
                end
            end
        else
            if Macro.IsRecording then
                Macro:StopRecording()
                if selected ~= "" and selected ~= "---" and isfile("bobcat/games/AS/macros/" .. selected .. ".json") then
                    Macro:SaveMacro(selected)
                    if Library.Options.MacroSelect then
                        Library.Options.MacroSelect:SetValues(Macro:GetMacroList())
                    end
                end
            end
            local statusText = getgenv().MacroStatus or ("Stopped â " .. #Macro.Recording .. " steps")
            MacroStatus:Update({ State = statusText })
            getgenv().MacroStatus = nil
        end
    end
})

RecorderBox:AddToggle("MacroPlay", {
    Text = "Play Macro",
    Default = registerSetting("MacroPlay", false),
    Callback = function(val)
        setConfig("MacroPlay", val)
        if val then
            if Library.Toggles.InfiniteAutoplay and Library.Toggles.InfiniteAutoplay.Value then
                Library.Toggles.InfiniteAutoplay:SetValue(false)
            end
            Macro.HasPlayedThisMatch = false
            if Library.Toggles.MacroRecord and Library.Toggles.MacroRecord.Value then
                Library.Toggles.MacroRecord:SetValue(false)
            end
            if Macro.IsRecording then
                Macro:StopRecording()
            end
            if #Macro.Recording == 0 then
                if not getgenv().isStartup then
                    task.spawn(function() Library.Toggles.MacroPlay:SetValue(false) end)
                end
                MacroStatus:Update({ State = "Idle" })
                return
            end
            local inLobby = getgenv().isInLobby and getgenv().isInLobby()
            if not inLobby and not getgenv().isStartup then
                Macro:StartPlayback()
            end
        else
            if Macro.IsPlaying then
                Macro:Stop()
            end
            local statusText = getgenv().MacroStatus or "Stopped"
            MacroStatus:Update({ State = statusText })
            getgenv().MacroStatus = nil
        end
    end
})

RecorderBox:AddToggle("AutoReplay", {
    Text = "Auto Replay",
    Default = registerSetting("AutoReplay", false),
    Callback = function(val)
        setConfig("AutoReplay", val)
        if val then
            local inLobby = getgenv().isInLobby and getgenv().isInLobby()
            local isMid = getgenv().isMidGame and getgenv().isMidGame()
            if not inLobby and isMid == false then
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("replay"):FireServer()
                end)
            end
        end
    end
})

RecorderBox:AddToggle("AutoNext", {
    Text = "Auto Next",
    Default = registerSetting("AutoNext", false),
    Callback = function(val)
        setConfig("AutoNext", val)
        if val then
            local inLobby = getgenv().isInLobby and getgenv().isInLobby()
            local isMid = getgenv().isMidGame and getgenv().isMidGame()
            if not inLobby and isMid == false then
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("next"):FireServer()
                end)
            end
        end
    end
})

RecorderBox:AddDivider()

RecorderBox:AddDropdown("AutoSpeed", {
    Text = "Speed Value",
    Values = {"1", "2", "3"},
    Default = registerSetting("AutoSpeed", "2"),
    Callback = function(val)
        setConfig("AutoSpeed", val)
        local speedVal = tonumber(val)
        if speedVal then
            pcall(function()
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("change_speed"):InvokeServer(speedVal)
            end)
        end
    end
})

RecorderBox:AddToggle("AutoSpeedToggle", {
    Text = "Auto Speed Change",
    Default = registerSetting("AutoSpeedToggle", false),
    Callback = function(val) setConfig("AutoSpeedToggle", val) end
})



local MacroBox = Tabs.Macro:AddRightGroupbox({
    Name = "Macros",
    Center = true,
    Collapsible = true,
    DefaultCollapsed = false
})

MacroBox:AddInput("MacroName", {
    Text = "Macro Name",
    Default = "",
    Placeholder = "Enter name...",
})

MacroBox:AddButton("Create Macro", function()
    local name = Library.Options.MacroName and Library.Options.MacroName.Value or ""
    if name == "" then
        return
    end
    local temp = Macro.Recording
    Macro.Recording = {}
    local ok = Macro:SaveMacro(name)
    if ok then
        if Library.Options.MacroSelect then
            Library.Options.MacroSelect:SetValues(Macro:GetMacroList())
            Library.Options.MacroSelect:SetValue(name)
        end
    else
        Macro.Recording = temp
    end
end)

MacroBox:AddDivider()

MacroBox:AddDropdown("MacroSelect", {
    Text = "Saved Macros",
    Values = Macro:GetMacroList(),
    Default = registerSetting("MacroSelect", ""),
    Callback = function(val)
        setConfig("MacroSelect", val)
        if Macro:LoadMacro(val) then
            MacroStatus:Update({ State = "Loaded: " .. val .. " â " .. #Macro.Recording .. " steps" })
            if not getgenv().isStartup and getgenv().config.AutoEquipUnits and val ~= "" and val ~= "---" and (not getgenv().isInLobby or getgenv().isInLobby()) then
                task.spawn(function()
                    local ok, msg = getgenv().equipMacroUnits(val)
                    if ok and msg and msg ~= "" then
                        Library:Notify(msg, 5)
                    end
                end)
            end
        end
    end
})

MacroBox:AddToggle("AutoEquipUnits", {
    Text = "Auto Equip Units",
    Default = registerSetting("AutoEquipUnits", false),
    Callback = function(val) setConfig("AutoEquipUnits", val) end
})

MacroBox:AddButton("Delete Selected", function()
    local selected = Library.Options.MacroSelect and Library.Options.MacroSelect.Value
    if not selected or selected == "" or selected == "---" then
        return
    end
    
    local Dialog = Window:AddDialog("DeletePrompt", {
        Title = "Delete Macro",
        Description = "Are you sure you want to delete '" .. selected .. "'?",
        AutoDismiss = true,
        OutsideClickDismiss = true,
    })
    Dialog:AddFooterButton("YesButton", {
        Title = "Yes",
        Text = "Yes",
        Callback = function()
            if Macro:DeleteMacro(selected) then
                Macro.Recording = {}
                MacroStatus:Update({ State = "Idle" })
                Library.Options.MacroSelect:SetValues(Macro:GetMacroList())
                Library.Options.MacroSelect:SetValue(nil)
            end
            Dialog:Dismiss()
        end
    })
    Dialog:AddFooterButton("NoButton", {
        Title = "Cancel",
        Text = "Cancel",
        Callback = function()
            Dialog:Dismiss()
        end
    })
    Dialog:Resize()
end)

MacroBox:AddButton("Refresh List", function()
    Library.Options.MacroSelect:SetValues(Macro:GetMacroList())
end)

getgenv().refreshMacroDropdown = function()
    if Library.Options.MacroSelect then
        Library.Options.MacroSelect:SetValues(Macro:GetMacroList())
    end
end

MacroBox:AddInput("ImportMacroData", {
    Text = "Import Macro (URL or JSON)",
    Default = "",
    Placeholder = "Paste raw JSON or Discord URL...",
})

MacroBox:AddButton("Import Macro", function()
    local customName = Library.Options.MacroName and Library.Options.MacroName.Value or ""
    if customName == "" then
        Library:Notify("Please enter a Macro Name first!", 3)
        return
    end
    local inputVal = Library.Options.ImportMacroData and Library.Options.ImportMacroData.Value or ""
    if inputVal == "" then
        Library:Notify("Please enter a valid URL or JSON data.", 3)
        return
    end
    local ok, nameOrErr = getgenv().importMacroFromURL(inputVal, customName)
    if ok then
        Library:Notify("Macro successfully imported as: " .. nameOrErr, 5)
        if Library.Options.MacroSelect then
            Library.Options.MacroSelect:SetValue(nameOrErr)
        end
        if Library.Options.MacroName then
            Library.Options.MacroName:SetValue(nameOrErr)
        end
        if Library.Options.ImportMacroData then
            Library.Options.ImportMacroData:SetValue("")
        end
    else
        Library:Notify("Import failed: " .. tostring(nameOrErr), 5)
    end
end)

MacroBox:AddButton("Export Macro", function()
    local selected = Library.Options.MacroSelect and Library.Options.MacroSelect.Value
    if not selected or selected == "" or selected == "---" then
        Library:Notify("Please select a macro first.", 3)
        return
    end
    
    local ok, err = getgenv().exportMacroWebhook(selected)
    if ok then
        Library:Notify("Macro successfully exported via Webhook!", 3)
    else
        Library:Notify("Export failed: " .. tostring(err), 5)
    end
end)

MacroBox:AddDivider()

MacroBox:AddButton("Check Macro Units", function()
    local selected = Library.Options.MacroSelect and Library.Options.MacroSelect.Value
    if not selected or selected == "" or selected == "---" then
        Library:Notify("Please select a macro first.", 3)
        return
    end
    
    local units, err = getgenv().getMacroRequiredUnits(selected)
    if not units then
        Library:Notify("Failed to analyze macro: " .. tostring(err), 5)
        return
    end
    
    if #units == 0 then
        Library:Notify("No units found in this macro.", 5)
    else
        local text = "Units used in macro:\n" .. table.concat(units, "\n")
        Library:Notify(text, 10)
    end
end)

MacroBox:AddButton("Equip Macro Units", function()
    local selected = Library.Options.MacroSelect and Library.Options.MacroSelect.Value
    if not selected or selected == "" or selected == "---" then
        Library:Notify("Please select a macro first.", 3)
        return
    end
    
    local ok, msg = getgenv().equipMacroUnits(selected)
    if ok and msg and msg ~= "" then
        Library:Notify(msg, 5)
    end
end)
























































Window:AddTabSection("Config")
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Side = "Header", Visible = false })
local InfoTab = Window:AddTab({ Name = "Info", Icon = "info", Side = "Sidebar" })

local SettingsGroup = SettingsTab:AddLeftGroupbox("Controls")
SettingsGroup:AddLabel("Toggle UI Bind"):AddKeyPicker("MenuKeybind", {
    Default = "LeftControl",
    NoUI = true,
    Text = "Menu Keybind"
})
Library.ToggleKeybind = Library.Options.MenuKeybind

SettingsGroup:AddDivider()

SettingsGroup:AddToggle("DisableFloatingMenu", {
    Text = "Disable Floating",
    Default = registerSetting("DisableFloatingMenu", false),
    Callback = function(val)
        setConfig("DisableFloatingMenu", val)
        Library.DisableFloatingMenu = val
    end
})

SettingsGroup:AddToggle("AutoReconnect", {
    Text = "Auto Reconnect",
    Default = registerSetting("AutoReconnect", false),
    Callback = function(val) setConfig("AutoReconnect", val) end
})

SettingsGroup:AddToggle("AutoExecute", {
    Text = "Auto Execute",
    Default = registerSetting("AutoExecute", false),
    Callback = function(val) setConfig("AutoExecute", val) end
})

SettingsGroup:AddButton("Unload", function()
    Library:Unload()
end)

local InfoMiddleTabbox = InfoTab:AddMiddleTabbox({
    Name = "Changelogs",
    IconName = "info",
    Collapsible = true,
    Center = true,
    DefaultCollapsed = false
})

local InfoSubTab = InfoMiddleTabbox:AddTab("v1.0")
InfoSubTab:AddLabel({ Text = "Anime Squadron Macro v1.0" })
InfoSubTab:AddLabel({ Text = "- Added Macro Tab: Record, replay, save, load & auto-equip" })
InfoSubTab:AddLabel({ Text = "- Added Auto Joiner: Story, Squadron, Raid, and Infinite" })
InfoSubTab:AddLabel({ Text = "- Added Priority Cycling System" })
InfoSubTab:AddLabel({ Text = "- Added Webhook Settings tab" })
InfoSubTab:AddLabel({ Text = "- Added Auto Summon (to be fixed)" })
InfoSubTab:AddLabel({ Text = "- Bug Fixes: Fixed macro deletion confirmation window" })

SyncUI()
updateMapModeLevelDropdowns()
getgenv().isStartup = false

Library:OnUnload(function()
    getgenv().uiActive = false
    getgenv().uiUpd = nil
    _G.UILoaded = nil
    _G.LastUILoadTime = nil
end)