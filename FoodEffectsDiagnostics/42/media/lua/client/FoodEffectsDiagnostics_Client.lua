require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"
FoodEffectsDiagnostics.log("client-load=true")

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
