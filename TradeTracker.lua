addonName = "TradeTracker"

TradeTracker = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
AceConfig = LibStub("AceConfig-3.0")
AceConfigDialog = LibStub("AceConfigDialog-3.0")
AceGUI = LibStub("AceGUI-3.0")

DefaultOptions = {
    profile = {
        enabled = true,
        entry_separator = true,
        debug = 0,
        expiry_time = 5,
        channels = {
            ["Trade"] = true,
            ["General"] = false,
            ["Services"] = false,
            ["Say"] = false,
            ["Yell"] = false,
        },
        rt_icons = true,
        sort_order = "newest",
        trigger_words = {
            buy = "LF ,WTB",
            sell = "WTS",
            service = "LFW",
        },
        highlights = {
            ["global"] = "",
            ["buy"] = "",
            ["sell"] = "",
            ["service"] = "",
        },
        highlight_sounds = {
            ["buy"] = "",
            ["sell"] = "",
            ["service"] = "",
        },
        blink_tray_icon = {
            ["buy"] = false,
            ["sell"] = false,
            ["service"] = false,
        },
        ignores = {
            ["global"] = "",
            ["buy"] = "",
            ["sell"] = "",
            ["service"] = "",
        },
        highlight_color = {
            ["buy"] = { 1, 1, 0 },
            ["sell"] = { 1, 1, 0 },
            ["service"] = { 1, 1, 0 },
        },
        repeat_highlights = {
            ["buy"] = true,
            ["sell"] = true,
            ["service"] = true,
        },
    },
}

local function RemoveExpiredEntries(tbl, tblName)
    local removed = 0
    local currentTime = time()
    local expiryTime = TradeTracker.db.profile.expiry_time * 60

    for i = #tbl, 1, -1 do
        if currentTime - tbl[i].timestamp > expiryTime then
            TradeTracker:DebugPrint(string.format("Removing expired entry from %s table: %s %s (added at %s)", tblName, tbl[i].player, tbl[i].item, date("%H:%M:%S", tbl[i].timestamp)), 2)
            table.remove(tbl, i)
            removed = removed + 1
        end
    end

    if removed > 0 then
        TradeTracker:DebugPrint(string.format("Removed %d expired entries from %s table", removed, tblName))
    end
end

function TradeTracker:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addonName .. "DB", DefaultOptions)
    self.db.RegisterCallback(self, "OnProfileChanged", function() self:Print("Profile changed to " .. self.db:GetCurrentProfile()) end)
    self.db.RegisterCallback(self, "OnProfileReset", function() self:Print("Profile " .. self.db:GetCurrentProfile() .. " has been reset to default settings.") end)
    self:RegisterOptions()

    -- Register slash commands
    self:RegisterChatCommand("tt", "SlashCommand")
    self:RegisterChatCommand("tradetracker", "SlashCommand")

    -- Initialize data tables
    self.buyTable = {}
    self.sellTable = {}
    self.serviceTable = {}

    C_Timer.NewTicker(60, function()
        TradeTracker:DebugPrint("Running periodic cleanup of expired entries")

        RemoveExpiredEntries(TradeTracker.buyTable, "buy")
        RemoveExpiredEntries(TradeTracker.sellTable, "sell")
        RemoveExpiredEntries(TradeTracker.serviceTable, "service")
    end)
end

function TradeTracker:OnEnable()
    self.db.profile.enabled = true

    -- Listen for chat messages
    self:RegisterEvent("CHAT_MSG_CHANNEL", "ProcessChatMessage")
    self:RegisterEvent("CHAT_MSG_YELL", "ProcessChatMessage")
    self:RegisterEvent("CHAT_MSG_SAY", "ProcessChatMessage")

    self:Print("enabled (Profile: " .. self.db:GetCurrentProfile() .. ")")
end

function TradeTracker:OnDisable()
    self.db.profile.enabled = false

    -- Stop listening for chat messages
    self:UnregisterEvent("CHAT_MSG_CHANNEL")
    self:UnregisterEvent("CHAT_MSG_YELL")
    self:UnregisterEvent("CHAT_MSG_SAY")

    self:Print("disabled")
end

function TradeTracker:GetAddOnStatusLabel()
    return TradeTracker.db.profile.enabled and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
end

-- Print a message with the highlight color defined in the settings
function TradeTracker:PrintHighlight(category, player, msg)
    -- Create a clickable player link that opens a whisper when clicked
    local clickablePlayer = string.format("|Hplayer:%s|h[%s]|h", player, player)

    -- Print the clickable player name with highlighted message
    self:Print(string.format(
        "%s |cff%02x%02x%02x%s|r",
        clickablePlayer,
        self.db.profile.highlight_color[category][1] * 255,
        self.db.profile.highlight_color[category][2] * 255,
        self.db.profile.highlight_color[category][3] * 255,
        msg
    ))
end

-- Play a sound based on the category and the user's settings for that category
function TradeTracker:PlayHighlightSound(category)
    if self.db.profile.highlight_sounds[category] ~= "" and self.db.profile.highlight_sounds[category] ~= "custom" then
        PlaySoundFile(self.db.profile.highlight_sounds[category])
    end
end

-- Print a message only when Debug Mode is enabled, with optional verbosity level.
-- Verbosity can be 1 = Normal or 2 = Verbose. If not specified, it defaults to 1
function TradeTracker:DebugPrint(msg, verbosity)
    if self.db.profile.debug >= (verbosity or 1) then
        self:Print("|cffff0000DEBUG:|r " .. msg)
    end
end
