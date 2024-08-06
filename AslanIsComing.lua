local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_INDOORS")

local lastZoneTimes = {}
local defaultCooldown = 600 -- Default cooldown time in seconds (10 minutes)

-- Korean string variables including guild recruitment link

local koreanMessages = {
    "안두인의 서포터즈 길드에서 함께 성장하며 와우의 세계로 빠져보세요! ",
    "새로운 모험의 시작, 안두인의 서포터즈 길드에서 환영합니다",
    "초보와 복귀 유저들을 위한 와우 적응 길잡이, 안두인의 서포터즈 길드"
}

local autoChatButton = CreateFrame("Button", "AutoChatButton", UIParent, "SecureActionButtonTemplate")
autoChatButton:SetAttribute("type", "macro")
autoChatButton:SetPoint("CENTER")
autoChatButton:SetSize(100, 40)
autoChatButton:SetText("Auto Chat")
autoChatButton:SetNormalFontObject("GameFontNormal")

-- Add a texture to the auto chat button
local ntex = autoChatButton:CreateTexture()
ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
ntex:SetTexCoord(0, 0.625, 0, 0.6875)
ntex:SetAllPoints()
autoChatButton:SetNormalTexture(ntex)

local htex = autoChatButton:CreateTexture()
htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
htex:SetTexCoord(0, 0.625, 0, 0.6875)
htex:SetAllPoints()
autoChatButton:SetHighlightTexture(htex)

local ptex = autoChatButton:CreateTexture()
ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
ptex:SetTexCoord(0, 0.625, 0, 0.6875)
ptex:SetAllPoints()
autoChatButton:SetPushedTexture(ptex)

autoChatButton:Hide()

local closeButton = CreateFrame("Button", "CloseButton", UIParent, "UIPanelButtonTemplate")
closeButton:SetPoint("LEFT", autoChatButton, "RIGHT", 10, 0)
closeButton:SetSize(100, 40)
closeButton:SetText("닫기")
closeButton:SetNormalFontObject("GameFontNormal")

-- Function to hide the auto chat button after running the macro
autoChatButton:SetScript("OnClick", function(self)
    local zoneName = GetZoneText()
    -- Randomly choose a Korean message
    local randomMessage = koreanMessages[math.random(#koreanMessages)]
    -- Run the macro
    RunScript("SendChatMessage('" .. randomMessage .. "', 'YELL')")
    RunScript("SendChatMessage('" .. randomMessage .. "', 'CHANNEL', nil, 1)")

    -- Remember the zone and time
    lastZoneTimes[zoneName] = GetTime()
    -- Hide the button after a short delay
    C_Timer.After(0.1, function() self:Hide() end)
    closeButton:Hide()
end)

closeButton:SetScript("OnClick", function()
    autoChatButton:Hide()
    closeButton:Hide()
end)

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "AslanIsComing" then
            -- Addon loaded
            autoChatButton:Hide()
            closeButton:Hide()
        end
    else
        local zoneType = select(2, IsInInstance())
        if zoneType == "none" then
            local zoneName = GetZoneText()
            local currentTime = GetTime()
            if not lastZoneTimes[zoneName] or (currentTime - lastZoneTimes[zoneName] > defaultCooldown) then
                -- Show the buttons to manually trigger the macro and close
                autoChatButton:Show()
                closeButton:Show()
            else
                autoChatButton:Hide()
                closeButton:Hide()
            end
        else
            autoChatButton:Hide()
            closeButton:Hide()
        end
    end
end

frame:SetScript("OnEvent", OnEvent)

-- Slash command to toggle the addon on/off
SLASH_AUTOCHAT1 = "/AslanIsComing"
SlashCmdList["AslanIsComing"] = function(msg)
    if msg == "toggle" then
        if frame:IsEventRegistered("ZONE_CHANGED_NEW_AREA") then
            frame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
            frame:UnregisterEvent("ZONE_CHANGED")
            frame:UnregisterEvent("ZONE_CHANGED_INDOORS")
            print("AslanIsComing disabled.")
        else
            frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
            frame:RegisterEvent("ZONE_CHANGED")
            frame:RegisterEvent("ZONE_CHANGED_INDOORS")
            print("AslanIsComing enabled.")
        end
    else
        print("Usage: /AslanIsComing toggle - Toggle the addon on/off")
    end
end
