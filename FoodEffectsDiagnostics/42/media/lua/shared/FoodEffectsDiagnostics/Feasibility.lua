require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"

local D = FoodEffectsDiagnostics

-- Read-only preflight. No capacity setter is invoked until restoration is proven.
if FoodEffectsDiagnosticsConfig.capacity then
    function D.inspectCapacity(player)
        D.log("experiment=capacity phase=inspect " .. D.playerSnapshot(player) ..
            " maxWeight=" .. tostring(D.call(player, "getMaxWeight")) ..
            " maxWeightDelta=" .. tostring(D.call(player, "getMaxWeightDelta")))
    end
    D.log("experiment=capacity enabled=true mode=read-only")
end

-- This checks only exposure; it does not register a native moodle.
if FoodEffectsDiagnosticsConfig.moodle then
    function D.inspectMoodle()
        local ok, value = pcall(function() return MoodleType and MoodleType.register end)
        D.log("experiment=moodle phase=inspect registerAccessible=" .. tostring(ok and value ~= nil) .. " valueType=" .. type(value))
    end
    D.log("experiment=moodle enabled=true mode=read-only")
end

-- SP-only synthetic record read/write for save/reload comparisons.
if FoodEffectsDiagnosticsConfig.persistenceTransport then
    function D.probeSinglePlayerRecord(player)
        if isClient() or isServer() or not player then
            D.log("experiment=persistence phase=skip reason=not-single-player")
            return
        end
        local data = player:getModData()
        local previous = data.FoodEffectsDiagnostics_transport_v1
        local count = type(previous) == "table" and previous.count or nil
        if type(count) ~= "number" or count ~= count or count < 0 or count > 1000000 then count = 0 end
        data.FoodEffectsDiagnostics_transport_v1 = { schema = 1, count = count + 1, worldAge = D.worldAgeHours() }
        D.log("experiment=persistence phase=single-player previousCount=" .. tostring(count) .. " count=" .. tostring(count + 1) .. " worldAge=" .. tostring(D.worldAgeHours()) .. " " .. D.playerSnapshot(player))
    end
end
