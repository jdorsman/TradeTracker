local options = {
    name = addonName,
    handler = TradeTracker,
    type = "group",
    childGroups = "tree",
    args = {
        open = {
            order = 1,
            name = "Open TradeTracker",
            desc = "Open the main TradeTracker GUI. You can also use the /tt or /tradetracker slash commands.",
            type = "execute",
            func = function() TradeTracker:ShowGUI() end,
            -- Only show this button in Blizzard's Interface Options
            hidden = function() return AceConfigDialog.OpenFrames[addonName] ~= nil end
        },
        general = {
            order = 10,
            name = "General Settings",
            type = "group",
            args = {
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
                    desc = "The time (in minutes) after which a trade message is considered expired and will be removed.",
                    type = "range",
                    width = "full",
                    min = 1,
                    max = 15,
                    step = 1,
                    set = function(info, val) TradeTracker.db.profile.expiry_time = val end,
                    get = function(info) return TradeTracker.db.profile.expiry_time end
                },
            }
        },
        chat = {
            order = 20,
            name = "Chat Settings",
            type = "group",
            args = {
                channels = {
                    order = 21,
                    name = "Channels to monitor",
                    desc = "Select which channels to monitor for trade messages",
                    type = "multiselect",
                    values = {
                        ["Trade"] = "Trade",
                        ["General"] = "General",
                        ["Services"] = "Services",
                        ["Yell"] = "Yells (/yell)",
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
            }
        },
        highlights_and_ignores = {
            order = 30,
            name = "Highlights & Ignores",
            type = "group",
            childGroups = "tab",
            args = {
                global_highlights_ignores = {
                    order = 40,
                    name = "Global",
                    type = "group",
                    args = {
                        highlights = {
                            order = 41,
                            name = "Highlight Keywords",
                            desc = "Comma-separated list of case-insensitive keywords to highlight in the GUI, regardless of Buy/Sell/Trade categorization. Partial matches are considered a match (e.g. \"port\" will also match \"portal\"). If a message matches both a highlight and ignore keyword, the ignore has priority.",
                            type = "input",
                            multiline = true,
                            width = "full",
                            set = function(info, val) TradeTracker.db.profile.highlights.global = val end,
                            get = function(info) return TradeTracker.db.profile.highlights.global end
                        },
                        ignores = {
                            order = 43,
                            name = "Ignore Keywords",
                            desc = "Comma-separated list of case-insensitive keywords to ignore, regardless of Buy/Sell/Trade categorization. Messages containing these words will not be shown in the GUI. Partial matches are considered a match (e.g. \"port\" will also match \"portal\"). If a message matches both a highlight and ignore keyword, the ignore has priority.",
                            type = "input",
                            multiline = true,
                            width = "full",
                            set = function(info, val) TradeTracker.db.profile.ignores.global = val end,
                            get = function(info) return TradeTracker.db.profile.ignores.global end
                        },
                    }
                },
                buy_highlights_ignores = {
                    order = 50,
                    name = "Buy",
                    type = "group",
                    args = {
                        buy_highlights = {
                            order = 51,
                            name = "Highlight Keywords",
                            desc = "Comma-separated list of case-insensitive keywords to highlight in the GUI's Buy tab. Partial matches are considered a match (e.g. \"port\" will also match \"portal\"). If a message matches both a highlight and ignore keyword, the ignore has priority.",
                            type = "input",
                            multiline = true,
                            width = "full",
                            set = function(info, val) TradeTracker.db.profile.highlights.buy = val end,
                            get = function(info) return TradeTracker.db.profile.highlights.buy end
                        },
                        buy_highlight_color = {
                            order = 52,
                            name = "Highlight Color",
                            desc = "The color used to highlight messages that match the keywords in the 'Highlight Keywords' setting.",
                            type = "color",
                            set = function(info, r, g, b) TradeTracker.db.profile.highlight_color.buy = {r, g, b} end,
                            get = function(info) return unpack(TradeTracker.db.profile.highlight_color.buy) end
                        },
                        buy_repeat_highlights = {
                            order = 53,
                            name = "Repeat Highlights",
                            desc = "Messages that match the highlight keywords will be repeated in the chat frame with the specified highlight color. This is particularly useful if you have the trade chats hidden from the main chat frame, but want to be alerted to matching trades.",
                            type = "toggle",
                            set = function(info, val) TradeTracker.db.profile.repeat_highlights.buy = val end,
                            get = function(info) return TradeTracker.db.profile.repeat_highlights.buy end
                        },
                        buy_ignores = {
                            order = 54,
                            name = "Ignore Keywords",
                            desc = "Comma-separated list of case-insensitive keywords to ignore. Messages containing these words will not be shown in the GUI's Buy tab. Partial matches are considered a match (e.g. \"port\" will also match \"portal\"). If a message matches both a highlight and ignore keyword, the ignore has priority.",
                            type = "input",
                            multiline = true,
                            width = "full",
                            set = function(info, val) TradeTracker.db.profile.ignores.buy = val end,
                            get = function(info) return TradeTracker.db.profile.ignores.buy end
                        },
                    }
                },
                sell_highlights_ignores = {
                    order = 60,
                    name = "Sell",
                    type = "group",
                    args = {
                        sell_highlights = {
                            order = 61,
                            name = "Highlight Keywords",
                            desc = "Comma-separated list of case-insensitive keywords to highlight in the GUI's Sell tab. Partial matches are considered a match (e.g. \"port\" will also match \"portal\"). If a message matches both a highlight and ignore keyword, the ignore has priority.",
                            type = "input",
                            multiline = true,
                            width = "full",
                            set = function(info, val) TradeTracker.db.profile.highlights.sell = val end,
                            get = function(info) return TradeTracker.db.profile.highlights.sell end
                        },
                        sell_highlight_color = {
                            order = 62,
                            name = "Highlight Color",
                            desc = "The color used to highlight messages that match the keywords in the 'Highlight Keywords' setting.",
                            type = "color",
                            set = function(info, r, g, b) TradeTracker.db.profile.highlight_color.sell = {r, g, b} end,
                            get = function(info) return unpack(TradeTracker.db.profile.highlight_color.sell) end
                        },
                        sell_repeat_highlights = {
                            order = 63,
                            name = "Repeat Highlights",
                            desc = "Messages that match the highlight keywords will be repeated in the chat frame with the specified highlight color. This is particularly useful if you have the trade chats hidden from the main chat frame, but want to be alerted to matching trades.",
                            type = "toggle",
                            set = function(info, val) TradeTracker.db.profile.repeat_highlights.sell = val end,
                            get = function(info) return TradeTracker.db.profile.repeat_highlights.sell end
                        },
                        sell_ignores = {
                            order = 64,
                            name = "Ignore Keywords",
                            desc = "Comma-separated list of case-insensitive keywords to ignore. Messages containing these words will not be shown in the GUI's Sell tab. Partial matches are considered a match (e.g. \"port\" will also match \"portal\"). If a message matches both a highlight and ignore keyword, the ignore has priority.",
                            type = "input",
                            multiline = true,
                            width = "full",
                            set = function(info, val) TradeTracker.db.profile.ignores.sell = val end,
                            get = function(info) return TradeTracker.db.profile.ignores.sell end
                        },
                    }
                },
                service_highlights_ignores = {
                    order = 70,
                    name = "Service",
                    type = "group",
                    args = {
                        service_highlights = {
                            order = 71,
                            name = "Highlight Keywords",
                            desc = "Comma-separated list of case-insensitive keywords to highlight in the GUI's Service tab. Partial matches are considered a match (e.g. \"port\" will also match \"portal\"). If a message matches both a highlight and ignore keyword, the ignore has priority.",
                            type = "input",
                            multiline = true,
                            width = "full",
                            set = function(info, val) TradeTracker.db.profile.highlights.service = val end,
                            get = function(info) return TradeTracker.db.profile.highlights.service end
                        },
                        service_highlight_color = {
                            order = 72,
                            name = "Highlight Color",
                            desc = "The color used to highlight messages that match the keywords in the 'Highlight Keywords' setting.",
                            type = "color",
                            set = function(info, r, g, b) TradeTracker.db.profile.highlight_color.service = {r, g, b} end,
                            get = function(info) return unpack(TradeTracker.db.profile.highlight_color.service) end
                        },
                        service_repeat_highlights = {
                            order = 73,
                            name = "Repeat Highlights",
                            desc = "Messages that match the highlight keywords will be repeated in the chat frame with the specified highlight color. This is particularly useful if you have the trade chats hidden from the main chat frame, but want to be alerted to matching trades.",
                            type = "toggle",
                            set = function(info, val) TradeTracker.db.profile.repeat_highlights.service = val end,
                            get = function(info) return TradeTracker.db.profile.repeat_highlights.service end
                        },
                        service_ignores = {
                            order = 74,
                            name = "Ignore Keywords",
                            desc = "Comma-separated list of case-insensitive keywords to ignore. Messages containing these words will not be shown in the GUI's Service tab. Partial matches are considered a match (e.g. \"port\" will also match \"portal\"). If a message matches both a highlight and ignore keyword, the ignore has priority.",
                            type = "input",
                            multiline = true,
                            width = "full",
                            set = function(info, val) TradeTracker.db.profile.ignores.service = val end,
                            get = function(info) return TradeTracker.db.profile.ignores.service end
                        },
                    }
                },
            }
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
