function TradeTracker:SlashCommand(input)
    if input == "" then
        return self:ShowGUI()
    elseif input == "config" then
        return AceConfigDialog:Open(addonName)
    elseif input == "enable" then
        return self:Enable()
    elseif input == "disable" then
        return self:Disable()
    end

    self:Print("Unknown command: " .. input .. ". Available commands: config, enable, disable")
end

function TradeTracker:ProcessChatMessage(eventName, text, playerName, _, channelName, _, _, _, _, channelBaseName, _, lineID, guid, _, _, _, _, _)
    local enabledChannels = self:GetEnabledChannels()

    -- Remove any suffix from the channel (e.g. "Trade - City" becomes "Trade")
    channelBaseName = string.gsub(channelBaseName, " %- .*$", "")

    if eventName == "CHAT_MSG_YELL" then
        channelBaseName = "Yell"
    elseif eventName == "CHAT_MSG_SAY" then
        channelBaseName = "Say"
    end

    if not tContains(enabledChannels, channelBaseName) then
        self:DebugPrint("Ignoring message from unmonitored channel " .. channelBaseName, 2)
        return
    end

    -- Remove realm suffix from player name if present (e.g. "Player-Realm" becomes "Player")
    local shortPlayerName = string.gsub(playerName, "%-" .. GetRealmName() .. "$", "")

    -- Message categorization
    local filters = {
        ["lf "] = self.buyTable,
        ["wtb"] = self.buyTable,
        ["wts"] = self.sellTable,
        ["lfw"] = self.serviceTable,
    }

    local categories = {
        ["lf "] = "Buy",
        ["wtb"] = "Buy",
        ["wts"] = "Sell",
        ["lfw"] = "Service",
    }

    for filter, tbl in pairs(filters) do
        if string.match(string.lower(text), filter) then
            local lowerCategory = string.lower(categories[filter])

            -- If the message contains one of the ignore keywords, skip it
            local globalIgnoreKeywords = { string.split(",", self.db.profile.ignores["global"]) }
            local categoryIgnoreKeywords = { string.split(",", self.db.profile.ignores[lowerCategory]) }
            local allIgnoreKeywords = { unpack(globalIgnoreKeywords), unpack(categoryIgnoreKeywords) }

            for _, keyword in ipairs(allIgnoreKeywords) do
                if keyword ~= "" and string.match(string.lower(text), string.lower(keyword)) then
                    self:DebugPrint("Ignoring message from " .. playerName .. ": " .. text .. ", because it contains ignore keyword: " .. keyword)
                    return
                end
            end

            -- Otherwise, add the message to the respective table
            self:AddToTable(tbl, text, shortPlayerName, channelBaseName)
            self:DebugPrint("Added message to " .. categories[filter] .. " table: " .. text, 2)

            -- If the message contains one our highlight keywords and repeat highlight is set, then print it
            if self.db.profile.repeat_highlights["global"] or self.db.profile.repeat_highlights[lowerCategory] then
                local globalHighlightKeywords = { string.split(",", self.db.profile.highlights["global"]) }
                local categoryHighlightKeywords = { string.split(",", self.db.profile.highlights[lowerCategory]) }
                local allHighlightKeywords = { unpack(globalHighlightKeywords), unpack(categoryHighlightKeywords) }

                for _, keyword in ipairs(allHighlightKeywords) do
                    if keyword ~= "" and string.find(string.lower(text), string.lower(keyword), 1, true) then
                        self:DebugPrint("Repeating message from " .. playerName .. ": " .. text .. ", because it contains highlight keyword: " .. keyword)
                        self:PrintHighlight(lowerCategory, shortPlayerName, text)
                        break
                    end
                end
            end
        else
            self:DebugPrint("Message from " .. shortPlayerName .. " did not match any filter: " .. text, 2)
        end
    end
end

function TradeTracker:AddToTable(tbl, text, playerName, channelBaseName)
    -- If a duplicate message from the same player is found (regardless of channel), remove the old message, effectively just updating its timestamp and avoid spam.
    for i, entry in ipairs(tbl) do
        if entry.player == playerName and entry.item == text then
            self:DebugPrint("Duplicate message from " .. playerName .. " found: " .. text)
            table.remove(tbl, i)
            break
        end
    end

    table.insert(tbl, {
        player = playerName,
        item = text,
        channel = channelBaseName,
        timestamp = time(),
    })
end
