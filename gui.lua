local selectedGroup = "buy"

local function ReverseTable(tbl)
    local reversed = {}

    for i = #tbl, 1, -1 do
        table.insert(reversed, tbl[i])
    end

    return reversed
end

local function FilterData(entries, text)
    local filteredTable = {}

    for _, entry in ipairs(entries) do
        if string.find(string.lower(entry.player), string.lower(text)) or string.find(string.lower(entry.item), string.lower(text)) then
            table.insert(filteredTable, entry)
        end
    end

    return filteredTable
end

-- Replace raid target placeholders with icon textures
local function ReplaceRaidTargets(text)
    if not TradeTracker.db.profile.rt_icons then
        -- Remove placeholders if icons are disabled
        return string.gsub(text, "{[^}]+}", "")
    end

    local raidIcons = {
        star = 1, circle = 2, diamond = 3, triangle = 4,
        moon = 5, square = 6, cross = 7, skull = 8
    }

    -- Show the corresponding icons for placeholders. If the placeholder doesn't match a known icon, leave it unchanged.
    return string.gsub(text, "{([^}]+)}", function(icon)
        local idx = raidIcons[icon:lower()]
        if idx then
            return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. idx .. ":0|t"
        else
            return "{" .. icon .. "}"
        end
    end)
end

local function DrawTab(container, tbl)
    -- Create a scrollable area for the entries
    local scrollcontainer = AceGUI:Create("SimpleGroup")
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetLayout("Fill")

    container:AddChild(scrollcontainer)

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("List")
    scrollcontainer:AddChild(scrollFrame)

    if #tbl == 0 then
        local label = AceGUI:Create("Label")
        label:SetText("No recent trade activity found in this category (that matches your search criteria).")
        label:SetRelativeWidth(1)
        scrollFrame:AddChild(label)
        return
    end

    if TradeTracker.db.profile.sort_order == "newest" then
        tbl = ReverseTable(tbl)
    end

    -- Print a header for our table, giving it a soft blue background color
    local headerGroup = AceGUI:Create("SimpleGroup")
    headerGroup:SetLayout("Flow")
    headerGroup:SetRelativeWidth(1)

    local playerHeader = AceGUI:Create("Label")
    playerHeader:SetText("|cff3399ffPlayer|r")
    playerHeader:SetRelativeWidth(0.2)
    headerGroup:AddChild(playerHeader)

    local itemHeader = AceGUI:Create("Label")
    itemHeader:SetText("|cff3399ffItem / Service|r")
    itemHeader:SetRelativeWidth(0.7)
    headerGroup:AddChild(itemHeader)

    local timeHeader = AceGUI:Create("Label")
    timeHeader:SetText("|cff3399ffTime|r")
    timeHeader:SetRelativeWidth(0.1)
    headerGroup:AddChild(timeHeader)
    scrollFrame:AddChild(headerGroup)

    local headerSpacer = AceGUI:Create("Label")
    headerSpacer:SetText(" ")
    headerSpacer:SetRelativeWidth(1)
    headerGroup:AddChild(headerSpacer)

    for i, data in ipairs(tbl) do
        -- Create a container for this entry to hold multiple columns
        local entryGroup = AceGUI:Create("SimpleGroup")
        entryGroup:SetLayout("Flow")
        entryGroup:SetRelativeWidth(1)

        -- Player column (medium)
        local playerLabel = AceGUI:Create("InteractiveLabel")
        playerLabel:SetText(data.player)
        playerLabel:SetRelativeWidth(0.2)
        playerLabel:SetCallback("OnClick", function(_, _, button)
            if button == "LeftButton" then
                ChatFrame_SendTell(data.player)
            elseif button == "RightButton" then
                C_FriendList.SendWho("n-\"" .. data.player .. "\"")
            end
        end)
        playerLabel:SetCallback("OnEnter", function(widget)
            GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR")
            GameTooltip:AddLine(data.player, 0.925, 0.737, 0.129)
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine("|TInterface\\TutorialFrame\\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:228:283|t Whisper", 1, 1, 1)
            GameTooltip:AddLine("|TInterface\\TutorialFrame\\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:330:385|t /who", 1, 1, 1)
            GameTooltip:Show()
        end)
        playerLabel:SetCallback("OnLeave", function(widget)
            GameTooltip:Hide()
        end)
        entryGroup:AddChild(playerLabel)

        -- Item column (wide)
        local itemLabel = AceGUI:Create("InteractiveLabel")
        local itemText = ReplaceRaidTargets(data.item)
        itemLabel:SetText(itemText)

        -- Highlight the item if it contains any of the user-defined keywords
        local globalHighlights = { string.split(",", TradeTracker.db.profile.highlights["global"]) }
        local tabHighlights = { string.split(",", TradeTracker.db.profile.highlights[selectedGroup]) }
        local highlights = { unpack(globalHighlights), unpack(tabHighlights) }

        if #highlights > 0 then
            for _, word in ipairs(highlights) do
                word = string.trim(word)

                if word ~= "" and string.find(string.lower(itemText), string.lower(word), 1, true) then
                    itemLabel:SetColor(unpack(TradeTracker.db.profile.highlight_color[selectedGroup]))
                    break
                end
            end
        end

        itemLabel:SetCallback("OnClick", function(widget, event, button)
            -- Get the mouse position relative to the widget frame
            local cursorX, cursorY = GetCursorPosition()
            local scale = widget.frame:GetEffectiveScale()
            cursorX = cursorX / scale
            cursorY = cursorY / scale

            local frameLeft = widget.frame:GetLeft()
            local frameTop = widget.frame:GetTop()
            local frameRight = widget.frame:GetRight()
            local frameBottom = widget.frame:GetBottom()

            -- Extract all links from the text with their positions
            local links = {}
            local lastEnd = 0
            for link in string.gmatch(data.item, "(|%x+|H.-|h%[.-%]|h|r)") do
                local linkStart, linkEnd = string.find(data.item, link, lastEnd + 1, true)
                if linkStart then
                    table.insert(links, {link = link, startPos = linkStart, endPos = linkEnd})
                    lastEnd = linkEnd
                end
            end

            if #links > 0 then
                -- Calculate approximate character position based on cursor X and Y position
                local textWidth = frameRight - frameLeft
                local textHeight = frameTop - frameBottom
                local relativeX = cursorX - frameLeft
                local relativeY = frameTop - cursorY

                -- Estimate which line the cursor is on (assuming uniform line height)
                local fontString = widget.frame:GetRegions()
                local lineHeight = select(2, fontString:GetFont())
                local lineNumber = math.floor(relativeY / lineHeight)

                -- Calculate character position within the line
                local charsPerLine = math.floor(textWidth / (fontString:GetStringWidth() / string.len(data.item)))
                local charPosition = (lineNumber * charsPerLine) + math.floor((relativeX / textWidth) * charsPerLine)
                charPosition = math.max(1, math.min(charPosition, string.len(data.item)))

                -- Find which link the cursor is over
                local selectedLink = links[1].link -- Default to first link
                for _, linkData in ipairs(links) do
                    if charPosition >= linkData.startPos and charPosition <= linkData.endPos then
                    selectedLink = linkData.link
                    break
                    end
                end

                -- Show the tooltip
                GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR")
                GameTooltip:SetHyperlink(selectedLink)
                GameTooltip:Show()
            end
        end)
        itemLabel:SetCallback("OnLeave", function(widget) GameTooltip:Hide() end)
        itemLabel:SetRelativeWidth(0.7)
        entryGroup:AddChild(itemLabel)

        scrollFrame:AddChild(entryGroup)

        -- Time column (narrow)
        local timeLabel = AceGUI:Create("Label")
        if time() - data.timestamp < 60 then
            timeLabel:SetText(string.format("%d sec ago", time() - data.timestamp))
        else
            timeLabel:SetText(string.format("%d min ago", math.floor((time() - data.timestamp) / 60)))
        end
        timeLabel:SetRelativeWidth(0.1)
        entryGroup:AddChild(timeLabel)

        if TradeTracker.db.profile.entry_separator then
            -- Add a separator between entries for better readability
            local separator = AceGUI:Create("Label")
            separator:SetText(" ")
            scrollFrame:AddChild(separator)
        end
    end
end

-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
    selectedGroup = group -- Store the selected group for use in the search filter
    container:ReleaseChildren()

    local tables = {
        buy = TradeTracker.buyTable,
        sell = TradeTracker.sellTable,
        service = TradeTracker.serviceTable
    }

    DrawTab(container, tables[group])
end

function TradeTracker:ShowGUI()
    -- Do not open the GUI again if it is already open
    if _G["TradeTrackerGUI"] and _G["TradeTrackerGUI"]:IsShown() then
        return
    end

    local frame = AceGUI:Create("Frame")
    frame:SetTitle(addonName .. " v" .. C_AddOns.GetAddOnMetadata(addonName, "Version"))
    frame:SetStatusText(addonName .. " is ".. TradeTracker:GetAddOnStatusLabel() .. " | You have " .. GetMoneyString(GetMoney()))
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")

    -- Create search box
    local searchLabel = AceGUI:Create("Label")
    searchLabel:SetText("Search:")
    searchLabel:SetRelativeWidth(0.1)
    frame:AddChild(searchLabel)

    local search = AceGUI:Create("EditBox")
    search:DisableButton(true)
    search:SetRelativeWidth(0.3)
    frame:AddChild(search)

    -- Create some spacing between the search box and the refresh button
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetRelativeWidth(0.23)
    frame:AddChild(spacer)

    -- Create a button that will open the options menu when clicked
    local optionsButton = AceGUI:Create("Button")
    optionsButton:SetText("Options")
    optionsButton:SetRelativeWidth(0.17)
    optionsButton:SetCallback("OnClick", function()
        -- Hide the main GUI before opening options to prevent overlap issues
        AceGUI:Release(frame)
        AceConfigDialog:Open(addonName)
    end)
    frame:AddChild(optionsButton)

    -- Add another spacer to push the refresh button and options button apart
    local spacer2 = AceGUI:Create("Label")
    spacer2:SetText(" ")
    spacer2:SetRelativeWidth(0.02)
    frame:AddChild(spacer2)

    local tab -- Declare tab group variable here, to be used in the refresh button callback

    -- Create refresh button that reloads the current tab, keeping the current search filter
    local refreshButton = AceGUI:Create("Button")
    refreshButton:SetText("Refresh")
    refreshButton:SetRelativeWidth(0.17)
    refreshButton:SetCallback("OnClick", function()
        local tables = {
            buy = TradeTracker.buyTable,
            sell = TradeTracker.sellTable,
            service = TradeTracker.serviceTable
        }
        tab:ReleaseChildren()
        DrawTab(tab, FilterData(tables[selectedGroup], search:GetText()))
    end)
    frame:AddChild(refreshButton)

    -- Create the TabGroup
    tab = AceGUI:Create("TabGroup")
    tab:SetLayout("Fill")
    tab:SetFullWidth(true)
    tab:SetFullHeight(true)

    -- Setup which tabs to show
    tab:SetTabs({
        {text = "Buy", value = "buy"},
        {text = "Sell", value = "sell"},
        {text = "Service", value = "service"}
    })

    -- Register callback
    tab:SetCallback("OnGroupSelected", function(container, event, group)
        SelectGroup(container, event, group)

        -- Apply the current search filter to the newly selected tab
        if search:GetText() and search:GetText() ~= "" then
            local tables = {
                buy = TradeTracker.buyTable,
                sell = TradeTracker.sellTable,
                service = TradeTracker.serviceTable
            }
            container:ReleaseChildren()
            DrawTab(container, FilterData(tables[group], search:GetText()))
        end
    end)

    -- Set initial Tab (this will fire the OnGroupSelected callback)
    tab:SelectTab("buy")

    -- add to the frame container
    frame:AddChild(tab)

    search:SetCallback("OnTextChanged", function(widget, event, text)
        -- Filter the current table based on the search text and redraw the current tab
        local tables = {
            buy = TradeTracker.buyTable,
            sell = TradeTracker.sellTable,
            service = TradeTracker.serviceTable
        }

        tab:ReleaseChildren()
        DrawTab(tab, FilterData(tables[selectedGroup], text))
    end)

    -- Register the frame in the UISpecialFrames so it can be closed with the Escape key
    _G["TradeTrackerGUI"] = frame
    table.insert(UISpecialFrames, "TradeTrackerGUI")
end
