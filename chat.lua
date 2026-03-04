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
    shortPlayerName = string.gsub(playerName, "%-" .. GetRealmName() .. "$", "")

    -- If the message has "WTS" in it, add it to the sell table
    if string.match(text, "[Ww][Tt][Ss]") then
        self:AddToTable(self.sellTable, text, shortPlayerName, channelBaseName)
        self:DebugPrint("Added message to sell table: " .. text, 2)
    end

    -- If the message has "WTB" in it, add it to the buy table
    if string.match(text, "[Ww][Tt][Bb]") then
        self:AddToTable(self.buyTable, text, shortPlayerName, channelBaseName)
        self:DebugPrint("Added message to buy table: " .. text, 2)
    end

    -- If the message has "LFW" in it, add it to the service table
    if string.match(text, "[Ll][Ff][Ww]") then
        self:AddToTable(self.serviceTable, text, shortPlayerName, channelBaseName)
        self:DebugPrint("Added message to service table: " .. text, 2)
    end
end

function TradeTracker:AddToTable(tbl, text, playerName, channelBaseName)
    -- If a duplicate message from the same player is found (regardless of channel), remove the old message, effectively just updating its timestamp and avoid spam.
    for i, entry in ipairs(tbl) do
        if entry.player == playerName and entry.item == text then
            self:DebugPrint("Duplicate message from " .. playerName .. " found: " .. text)
            table.remove(tbl, i)
            return
        end
    end

    table.insert(tbl, {
        player = playerName,
        item = text,
        channel = channelBaseName,
        timestamp = time(),
    })
end
