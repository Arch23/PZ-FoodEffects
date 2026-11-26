require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"
FoodEffectsDiagnostics.log("server-load=true")

if FoodEffectsDiagnosticsConfig.persistenceTransport and isServer() then
    local function onDiagnosticRequest(module, command, player, args)
        if module ~= "FoodEffectsDiagnostics" or command ~= "probe" or not player then return end
        local data = player:getModData()
        local previous = data.FoodEffectsDiagnostics_transport_v1
        local count = type(previous) == "table" and previous.count or nil
        if type(count) ~= "number" or count ~= count or count < 0 or count > 1000000 then count = 0 end
        local record = { schema = 1, count = count + 1, worldAge = FoodEffectsDiagnostics.worldAgeHours() }
        data.FoodEffectsDiagnostics_transport_v1 = record
        FoodEffectsDiagnostics.log("experiment=transport phase=server previousCount=" .. tostring(count) .. " count=" .. tostring(record.count) .. " worldAge=" .. tostring(record.worldAge) .. " " .. FoodEffectsDiagnostics.playerSnapshot(player))
        sendServerCommand(player, "FoodEffectsDiagnostics", "probeResult", record)
    end
    Events.OnClientCommand.Add(onDiagnosticRequest)
end
