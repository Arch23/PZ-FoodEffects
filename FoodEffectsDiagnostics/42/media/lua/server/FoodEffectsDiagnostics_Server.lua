require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"
FoodEffectsDiagnostics.log("server-load=true")

if FoodEffectsDiagnosticsConfig.capacity and FoodEffectsDiagnosticsConfig.capacityMutation and FoodEffectsDiagnosticsConfig.capacityMutationServer and isServer() then
    local function onCapacityRequest(module, command, player, args)
        if module ~= "FoodEffectsDiagnostics" or command ~= "capacityMutation" or not player then return end
        local ok, allowed = pcall(function() return player:getRole():hasCapability(Capability.UseDebugContextMenu) end)
        if not ok or not allowed or not FoodEffectsDiagnostics.probeCapacityMutation then
            FoodEffectsDiagnostics.log("experiment=capacity phase=server-request-denied")
            return
        end
        FoodEffectsDiagnostics.log("experiment=capacity phase=server-request-accepted " .. FoodEffectsDiagnostics.playerSnapshot(player))
        FoodEffectsDiagnostics.probeCapacityMutation(player)
    end
    Events.OnClientCommand.Add(onCapacityRequest)
end

if FoodEffectsDiagnosticsConfig.persistenceTransport and isServer() then
    local function onDiagnosticRequest(module, command, player, args)
        if module ~= "FoodEffectsDiagnostics" or command ~= "probe" or not player then return end
        local data = player:getModData()
        local previous = data.FoodEffectsDiagnostics_transport_v1
        local count, nextCount, validity = FoodEffectsDiagnostics.nextProbeCount(previous)
        local record = { schema = 1, count = nextCount, worldAge = FoodEffectsDiagnostics.worldAgeHours() }
        data.FoodEffectsDiagnostics_transport_v1 = record
        FoodEffectsDiagnostics.log("experiment=transport phase=server recordStatus=" .. validity .. " previousCount=" .. tostring(count) .. " count=" .. tostring(record.count) .. " worldAge=" .. tostring(record.worldAge) .. " " .. FoodEffectsDiagnostics.playerSnapshot(player))
        sendServerCommand(player, "FoodEffectsDiagnostics", "probeResult", record)
    end
    Events.OnClientCommand.Add(onDiagnosticRequest)
end
