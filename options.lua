local options = {
    name = addonName,
    handler = TradeTracker,
    type = "group",
    args = {
        open = {
            order = 1,
            name = "Open TradeTracker",
            desc = "Open the main TradeTracker GUI. You can also use the /tt or /tradetracker slash commands.",
            type = "execute",
            func = function() TradeTracker:ShowGUI() end
        },
        general = {
            order = 10,
            name = "General Settings",
            type = "header",
        },
        enable = {
            order = 11,
            name = "Enable",
            desc = "Enables / disables the addon",
            type = "toggle",
            set = function(info, val) if val then TradeTracker:Enable() else TradeTracker:Disable() end end,
            get = function(info) return TradeTracker.db.profile.enabled end
        },
        entry_separator ={
            order = 12,
            name = "Entry Separator",
            desc = "Insert some blank space between entries in the GUI for better readability",
            type = "toggle",
            set = function(info, val) TradeTracker.db.profile.entry_separator = val end,
            get = function(info) return TradeTracker.db.profile.entry_separator end
        },
        debug = {
            order = 13,
            name = "Debug Mode",
            desc = "Set debug mode (prints additional info to chat)",
            type = "select",
            values = {
                [0] = "Off",
                [1] = "Normal",
                [2] = "Verbose",
            },
            set = function(info, val) TradeTracker.db.profile.debug = val end,
            get = function(info) return TradeTracker.db.profile.debug end
        },
        expiry_time = {
            order = 14,
            name = "Expiry Time",
            desc = "The time (in minutes) after which a trade message is considered expired and removed.",
            type = "range",
            min = 1,
            max = 15,
            step = 1,
            set = function(info, val) TradeTracker.db.profile.expiry_time = val end,
            get = function(info) return TradeTracker.db.profile.expiry_time end
        },
        chat = {
            order = 20,
            name = "Chat Settings",
            type = "header",
        },
        channels = {
            order = 21,
            name = "Channels to monitor",
            desc = "Select which channels to monitor for trade messages",
            type = "multiselect",
            values = {
                ["Trade"] = "Trade",
                ["General"] = "General",
                ["Services"] = "Services",
                ["Yell"] = "Yelled messages (/yell)",
                ["Say"] = "Proximity chat (/say)",
            },
            set = function(info, key, val) TradeTracker:ToggleChannel(key) end,
            get = function(info, key) return TradeTracker.db.profile.channels[key] end
        },
        rt_icons = {
            order = 22,
            name = "Raid Target Icons",
            desc = "Show raid target icons that people might use in their messages (like star, circle, diamond, etc.). Disable this to remove icons entirely if you find them distracting.",
            type = "toggle",
            set = function(info, val) TradeTracker.db.profile.rt_icons = val end,
            get = function(info) return TradeTracker.db.profile.rt_icons end
        },
        sort_order = {
            order = 23,
            name = "Sort Order",
            desc = "The order in which entries are sorted in the GUI.",
            type = "select",
            values = {
                ["newest"] = "Newest First",
                ["oldest"] = "Oldest First",
            },
            set = function(info, val) TradeTracker.db.profile.sort_order = val end,
            get = function(info) return TradeTracker.db.profile.sort_order end
        },
    },
}

-- Register options table and add to Blizzard Options/AddOns GUI
AceConfig:RegisterOptionsTable(addonName, options, nil)
AceConfigDialog:AddToBlizOptions(addonName)

function TradeTracker:ToggleChannel(channel)
    local enabled = self.db.profile.channels[channel]

    if enabled then
        self.db.profile.channels[channel] = false
        self:Print("Stopped monitoring " .. channel .. " channel")
    else
        self.db.profile.channels[channel] = true
        self:Print("Started monitoring " .. channel .. " channel")
    end
end

function TradeTracker:GetEnabledChannels()
    local enabledChannels = {}

    for channel, enabled in pairs(self.db.profile.channels) do
        if enabled then
            table.insert(enabledChannels, channel)
        end
    end

    return enabledChannels
end
