require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"

local diagnostics = FoodEffectsDiagnostics
if FoodEffectsDiagnosticsConfig.syntheticPresentation ~= true or isServer() or diagnostics.syntheticPresentationClientLoaded then return end
require "ISUI/ISPanel"

local durationHours = 0.25
local allowedClockLagHours = 5 / 60
local requestTimeoutMs = 10000
local requestNumber = 0
local pending = {}
local panels = {}
local title = "Synthetic record"
local countdown = "%d world min remaining"
local padding = 8
local screenMargin = 16
local Panel = ISPanel:derive("FoodEffectsDiagnosticsSyntheticPanel")

function Panel:render()
    self:drawText(title, padding, padding, 1, 1, 1, 1, UIFont.Small)
    self:drawText(string.format(countdown, self.minutes), padding, padding + self.lineHeight, 1, 1, 1, 1, UIFont.Small)
end

local function validWorldAge(value)
    return type(value) == "number" and value == value and value >= 0 and value < math.huge
end

local function livePlayerAt(slot, player)
    return player and getSpecificPlayer(slot) == player and diagnostics.call(player, "isDead") == false
end

local function localSlotFor(onlineId)
    local found = nil
    for slot = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(slot)
        if player and diagnostics.call(player, "getOnlineID") == onlineId then
            if found ~= nil then return nil end
            found = slot
        end
    end
    return found
end

local function removePanel(slot, reason, now)
    local panel = panels[slot]
    if panel then
        panel:setVisible(false)
        panel:removeFromUIManager()
        panels[slot] = nil
        diagnostics.log("experiment=presentation phase=clear reason=" .. reason ..
            " worldAge=" .. tostring(now) .. " deadline=" .. tostring(panel.deadline))
    end
end

local function clearSlot(slot)
    pending[slot] = nil
    removePanel(slot, "character-created")
end

local function clearAll(reason)
    for slot in pairs(pending) do pending[slot] = nil end
    for slot in pairs(panels) do removePanel(slot, reason) end
end

local function positionPanel(panel, slot)
    local width = getPlayerScreenWidth(slot)
    local height = getPlayerScreenHeight(slot)
    if panel.width + 2 * screenMargin > width or panel.height + 2 * screenMargin > height then return false end
    local x = getPlayerScreenLeft(slot) + math.floor((width - panel.width) / 2)
    local y = getPlayerScreenTop(slot) + screenMargin
    if panel.x ~= x then panel:setX(x) end
    if panel.y ~= y then panel:setY(y) end
    return true
end

local function showRecord(slot, player, onlineId, started, deadline, now)
    if not validWorldAge(now) or now < started - allowedClockLagHours or now >= deadline then
        diagnostics.log("experiment=presentation phase=display-skip reason=clock worldAge=" .. tostring(now) ..
            " started=" .. tostring(started) .. " deadline=" .. tostring(deadline))
        return
    end

    local textManager = getTextManager()
    local width = math.max(textManager:MeasureStringX(UIFont.Small, title), textManager:MeasureStringX(UIFont.Small, string.format(countdown, 15)))
    local lineHeight = textManager:getFontHeight(UIFont.Small)
    local panel = Panel:new(0, 0, width + 2 * padding, 2 * lineHeight + 2 * padding)
    if not positionPanel(panel, slot) then
        diagnostics.log("experiment=presentation phase=display-skip reason=viewport")
        return
    end
    removePanel(slot, "replacement", now)

    panel.player = player
    panel.onlineId = onlineId
    panel.deadline = deadline
    panel.lastWorldAge = math.max(started, now)
    panel.minutes = math.ceil((deadline - panel.lastWorldAge) * 60)
    panel.lineHeight = lineHeight
    panel:initialise()
    panel:setWantMouseEvents(false)
    panel:addToUIManager()
    panel:setVisible(true)
    panels[slot] = panel
    diagnostics.log("experiment=presentation phase=visible worldAge=" .. tostring(now) ..
        " started=" .. tostring(started) .. " deadline=" .. tostring(deadline))
end

local function requestIsCurrent(slot, request, now)
    return now >= request.sentAt and now - request.sentAt <= requestTimeoutMs and
        livePlayerAt(slot, request.player) and localSlotFor(request.onlineId) == slot
end

local function startProbe(player, slot)
    if not livePlayerAt(slot, player) then return end
    if not isClient() then
        local now = diagnostics.worldAgeHours()
        if validWorldAge(now) then showRecord(slot, player, nil, now, now + durationHours, now) end
        return
    end

    local onlineId = diagnostics.call(player, "getOnlineID")
    if type(onlineId) ~= "number" or onlineId < 0 or onlineId > 32767 or onlineId ~= math.floor(onlineId) then return end
    if localSlotFor(onlineId) ~= slot then return end

    requestNumber = requestNumber % 2147483647 + 1
    pending[slot] = { player = player, onlineId = onlineId, sentAt = getTimestampMs(), number = requestNumber }
    if not pcall(sendClientCommand, player, "FoodEffectsDiagnostics", "syntheticPresentationRequest", { request = requestNumber }) then
        pending[slot] = nil
    end
end

local function onServerCommand(module, command, args)
    if not isClient() or module ~= "FoodEffectsDiagnostics" or command ~= "syntheticPresentationRecord" or type(args) ~= "table" then return end
    local onlineId, started, deadline = args.playerOnlineId, args.started, args.deadline
    if type(onlineId) ~= "number" or onlineId < 0 or onlineId > 32767 or onlineId ~= math.floor(onlineId) then return end
    if not validWorldAge(started) or not validWorldAge(deadline) or deadline - started ~= durationHours then return end

    local slot = localSlotFor(onlineId)
    local request = slot and pending[slot]
    if not request or request.number ~= args.request or request.onlineId ~= onlineId or not requestIsCurrent(slot, request, getTimestampMs()) then return end
    pending[slot] = nil
    showRecord(slot, request.player, onlineId, started, deadline, diagnostics.worldAgeHours())
end

local function onTick()
    for slot, request in pairs(pending) do
        if not isClient() or not requestIsCurrent(slot, request, getTimestampMs()) then pending[slot] = nil end
    end

    local now = nil
    for slot, panel in pairs(panels) do
        if now == nil then now = diagnostics.worldAgeHours() end
        if not livePlayerAt(slot, panel.player) or (panel.onlineId and (not isClient() or localSlotFor(panel.onlineId) ~= slot)) then
            removePanel(slot, "character-unavailable", now)
        elseif not validWorldAge(now) or now < panel.lastWorldAge - allowedClockLagHours then
            removePanel(slot, "clock", now)
        elseif now >= panel.deadline then
            removePanel(slot, "elapsed", now)
        elseif not positionPanel(panel, slot) then
            removePanel(slot, "viewport", now)
        else
            panel.lastWorldAge = math.max(panel.lastWorldAge, now)
            panel.minutes = math.ceil((panel.deadline - panel.lastWorldAge) * 60)
        end
    end
end

local function onWorldMenu(slot, context, worldObjects, test)
    if test then return end
    local player = getSpecificPlayer(slot)
    if livePlayerAt(slot, player) then context:addOption("Show FoodEffects synthetic countdown", player, startProbe, slot) end
end

local function onPlayerDeath(player)
    for slot, request in pairs(pending) do
        if request.player == player then pending[slot] = nil end
    end
    for slot, panel in pairs(panels) do
        if panel.player == player then removePanel(slot, "death") end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onWorldMenu)
Events.OnServerCommand.Add(onServerCommand)
Events.OnTickEvenPaused.Add(onTick)
Events.OnCreatePlayer.Add(clearSlot)
Events.OnPlayerDeath.Add(onPlayerDeath)
Events.OnDisconnect.Add(function() clearAll("disconnect") end)
Events.OnMainMenuEnter.Add(function() clearAll("main-menu") end)
diagnostics.syntheticPresentationClientLoaded = true
