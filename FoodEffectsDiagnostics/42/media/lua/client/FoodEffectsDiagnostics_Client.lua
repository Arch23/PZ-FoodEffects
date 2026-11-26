require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"
FoodEffectsDiagnostics.log("client-load=true")

-- Diagnostic world context menu; only enabled probes appear.
local function diagnosticMenu(playerNum, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end
    local config = FoodEffectsDiagnosticsConfig
    if not (config.capacity or config.moodle or config.persistenceTransport) then return end
    local player = getSpecificPlayer(playerNum)
    if not player then return end
    local option = context:addOption("FoodEffects diagnostics", worldobjects, nil)
    local menu = ISContextMenu:getNew(context)
    context:addSubMenu(option, menu)
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
