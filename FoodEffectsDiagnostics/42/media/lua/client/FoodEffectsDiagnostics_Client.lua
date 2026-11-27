require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"
FoodEffectsDiagnostics.log("client-load=true")

-- Diagnostic world context menu; only enabled probes appear.
local function diagnosticMenu(playerNum, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end
    local config = FoodEffectsDiagnosticsConfig
    if not (config.capacity or config.moodle or config.persistenceTransport or config.offlineExpiry or (config.pairedMealSnapshot and isClient()) or (config.giveTestItems and isClient())) then return end
    local player = getSpecificPlayer(playerNum)
    if not player then return end
    local option = context:addOption("FoodEffects diagnostics", worldobjects, nil)
    local menu = ISContextMenu:getNew(context)
    context:addSubMenu(option, menu)
    if config.pairedMealSnapshot and isClient() then
        menu:addOption("Compare configured meal snapshots (log)", player, function(requestingPlayer)
            sendClientCommand(requestingPlayer, "FoodEffectsDiagnostics", "mealSnapshot", {})
            FoodEffectsDiagnostics.log("experiment=paired-meal phase=request " .. FoodEffectsDiagnostics.playerSnapshot(requestingPlayer))
        end)
    end
    if config.giveTestItems and isClient() then
        menu:addOption("Request configured test items", player, function(requestingPlayer)
            sendClientCommand(requestingPlayer, "FoodEffectsDiagnostics", "giveTestItems", {})
            FoodEffectsDiagnostics.log("experiment=test-items phase=request")
        end)
    end
    if config.offlineExpiry and isClient() then
        menu:addOption("Start synthetic offline expiry (resets deadline)", nil, function()
            sendClientCommand("FoodEffectsDiagnostics", "expiryStart", {})
            FoodEffectsDiagnostics.log("experiment=offline-expiry phase=start-request")
        end)
        menu:addOption("Check synthetic offline expiry", nil, function()
            sendClientCommand("FoodEffectsDiagnostics", "expiryCheck", {})
            FoodEffectsDiagnostics.log("experiment=offline-expiry phase=check-request")
        end)
    end
    if config.capacity and FoodEffectsDiagnostics.inspectCapacity then
        menu:addOption("Inspect local capacity (log)", player, FoodEffectsDiagnostics.inspectCapacity)
    end
    if config.capacity and config.capacityMutation and not isClient() and FoodEffectsDiagnostics.probeCapacityMutation then
        menu:addOption("Run capacity mutation (disposable only)", player, FoodEffectsDiagnostics.probeCapacityMutation)
    end
    if config.capacity and config.capacityMutation and config.capacityMutationServer and isClient() then
        menu:addOption("Request server capacity mutation (disposable only)", nil, function()
            sendClientCommand("FoodEffectsDiagnostics", "capacityMutation", {})
            FoodEffectsDiagnostics.log("experiment=capacity phase=server-request")
        end)
    end
    if config.moodle and FoodEffectsDiagnostics.inspectMoodle then
        menu:addOption("Inspect moodle exposure (log)", nil, FoodEffectsDiagnostics.inspectMoodle)
    end
    if config.persistenceTransport then
        if isClient() and FoodEffectsDiagnostics.requestTransportProbe then
            menu:addOption("Request server transport probe", nil, FoodEffectsDiagnostics.requestTransportProbe)
        elseif not isClient() and not isServer() and FoodEffectsDiagnostics.probeSinglePlayerRecord then
            menu:addOption("Probe SP persistence record", player, FoodEffectsDiagnostics.probeSinglePlayerRecord)
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(diagnosticMenu)

-- Sample locally only after the server responds. Values and item selection
-- are never sent to the server; the sequence only relates the two log lines.
if FoodEffectsDiagnosticsConfig.pairedMealSnapshot and isClient() then
    local function onMealSnapshotResponse(module, command, args)
        if module ~= "FoodEffectsDiagnostics" or command ~= "mealSnapshotResult" or type(args) ~= "table" then return end
        local seq, onlineId = args.sequence, args.playerOnlineId
        if type(seq) ~= "number" or seq ~= seq or seq < 1 or seq == math.huge or seq ~= math.floor(seq) or type(onlineId) ~= "number" or onlineId ~= onlineId then
            FoodEffectsDiagnostics.log("experiment=paired-meal phase=client status=invalid-response")
            return
        end
        local player, playerMatches = nil, 0
        for i = 0, getNumActivePlayers() - 1 do
            local candidate = getSpecificPlayer(i)
            if candidate and FoodEffectsDiagnostics.call(candidate, "getOnlineID") == onlineId then player = candidate; playerMatches = playerMatches + 1 end
        end
        local itemType = FoodEffectsDiagnosticsConfig.pairedMealType
        local status, count, found = "unavailable", 0, nil
        if playerMatches ~= 1 then
            status = "player-unavailable-or-ambiguous"
        elseif type(itemType) ~= "string" or #itemType < 3 or #itemType > 128 or not itemType:match("^[%w_%-]+%.[%w_%-]+$") then
            status = "invalid-config"
        else
            local ok = pcall(function()
                local items = player:getInventory():getItems()
                local size = items:size()
                if size > 10000 then error("inventory too large") end
                for i = 0, size - 1 do
                    local item = items:get(i)
                    local fullType = item and FoodEffectsDiagnostics.call(item, "getFullType")
                    if not fullType then error("item type unavailable") end
                    if fullType == itemType then count = count + 1; found = item end
                end
            end)
            if ok then status = count == 1 and "unique" or (count == 0 and "missing" or "ambiguous") end
        end
        local snapshot = "item=nil"
        if status == "unique" then
            local ok, value = pcall(FoodEffectsDiagnostics.itemSnapshot, found)
            if ok then snapshot = value .. " inInventory=" .. tostring(FoodEffectsDiagnostics.isInInventory(player, found)) else status = "snapshot-error" end
        end
        FoodEffectsDiagnostics.log("experiment=paired-meal phase=client sequence=" .. tostring(seq) .. " configuredType=" .. tostring(itemType) .. " status=" .. status .. " matches=" .. tostring(count) .. " worldAge=" .. tostring(FoodEffectsDiagnostics.worldAgeHours()) .. " " .. FoodEffectsDiagnostics.playerSnapshot(player) .. " " .. snapshot)
    end
    Events.OnServerCommand.Add(onMealSnapshotResponse)
end

if FoodEffectsDiagnosticsConfig.persistenceTransport and isClient() then
    function FoodEffectsDiagnostics.requestTransportProbe()
        sendClientCommand("FoodEffectsDiagnostics", "probe", {})
        FoodEffectsDiagnostics.log("experiment=transport phase=request")
    end
    local function onDiagnosticResponse(module, command, args)
        if module ~= "FoodEffectsDiagnostics" or command ~= "probeResult" or type(args) ~= "table" then return end
        FoodEffectsDiagnostics.log("experiment=transport phase=client count=" .. tostring(args.count) .. " serverWorldAge=" .. tostring(args.worldAge) .. " clientWorldAge=" .. tostring(FoodEffectsDiagnostics.worldAgeHours()))
    end
    Events.OnServerCommand.Add(onDiagnosticResponse)
end
