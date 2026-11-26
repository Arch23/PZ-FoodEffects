require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"

local D = FoodEffectsDiagnostics

-- Capacity setter experiment is separately enabled and disposable-only.
if FoodEffectsDiagnosticsConfig.capacity then
    function D.inspectCapacity(player)
        D.log("experiment=capacity phase=inspect " .. D.playerSnapshot(player) ..
            " maxWeight=" .. tostring(D.call(player, "getMaxWeight")) ..
            " maxWeightDelta=" .. tostring(D.call(player, "getMaxWeightDelta")))
    end
    if FoodEffectsDiagnosticsConfig.capacityMutation then
        local active = nil
        local function tickCapacityProbe()
            if not active then return end
            active.ticks = active.ticks + 1
            if active.ticks < 120 then return end
            local probe = active
            active = nil
            if probe.restored then
                D.log("experiment=capacity phase=post-restore-updates ticks=" .. tostring(probe.ticks) ..
                    " maxWeight=" .. tostring(D.call(probe.player, "getMaxWeight")) ..
                    " maxWeightDelta=" .. tostring(D.call(probe.player, "getMaxWeightDelta")) .. " baseline=" .. tostring(probe.baseline))
                return
            end
            local current = D.call(probe.player, "getMaxWeightDelta")
            D.log("experiment=capacity phase=after-updates ticks=" .. tostring(probe.ticks) ..
                " maxWeight=" .. tostring(D.call(probe.player, "getMaxWeight")) .. " maxWeightDelta=" .. tostring(current))
            if type(current) ~= "number" or math.abs(current - probe.applied) > 0.00001 then
                D.log("experiment=capacity phase=restore-skipped reason=scalar-changed-or-unavailable baseline=" .. tostring(probe.baseline))
                return
            end
            local ok = pcall(probe.setter, probe.player, probe.baseline)
            D.log("experiment=capacity phase=restore-attempt callOk=" .. tostring(ok) .. " baseline=" .. tostring(probe.baseline) ..
                " maxWeight=" .. tostring(D.call(probe.player, "getMaxWeight")) .. " maxWeightDelta=" .. tostring(D.call(probe.player, "getMaxWeightDelta")))
            if ok then
                probe.restored = true
                probe.ticks = 0
                active = probe
            end
        end
        Events.OnTick.Add(tickCapacityProbe)
        function D.probeCapacityMutation(player)
            if not player or active or (isClient and isClient()) then
                D.log("experiment=capacity phase=mutation-skip reason=no-player-or-active-or-client")
                return
            end
            local baseline = D.call(player, "getMaxWeightDelta")
            local target = FoodEffectsDiagnosticsConfig.capacityMutationDelta
            if type(baseline) ~= "number" or baseline ~= baseline or baseline < 0 or baseline > 10 or type(target) ~= "number" or target ~= target or target < 0.1 or target > 3 then
                D.log("experiment=capacity phase=mutation-skip reason=invalid-baseline-or-target " .. D.playerSnapshot(player))
                return
            end
            D.log("experiment=capacity phase=mutation-before " .. D.playerSnapshot(player) ..
                " maxWeight=" .. tostring(D.call(player, "getMaxWeight")) .. " maxWeightDelta=" .. tostring(baseline) .. " targetDelta=" .. tostring(target))
            local setter = player.setMaxWeightDelta
            if type(setter) ~= "function" then
                D.log("experiment=capacity phase=mutation-skip reason=setter-unavailable")
                return
            end
            local applied = pcall(setter, player, target)
            D.log("experiment=capacity phase=mutation-applied callOk=" .. tostring(applied) ..
                " maxWeight=" .. tostring(D.call(player, "getMaxWeight")) .. " maxWeightDelta=" .. tostring(D.call(player, "getMaxWeightDelta")))
            local observed = D.call(player, "getMaxWeightDelta")
            if applied and type(observed) == "number" and observed == observed and math.abs(observed - target) <= 0.00001 then
                active = { player = player, baseline = baseline, applied = observed, setter = setter, ticks = 0 }
            else
                D.log("experiment=capacity phase=ownership-unconfirmed restoreSkipped=true observed=" .. tostring(observed) .. " baseline=" .. tostring(baseline))
            end
        end
        D.log("experiment=capacity mutation-enabled=true disposable-character-required=true")
    end
    D.log("experiment=capacity enabled=true mutation=" .. tostring(FoodEffectsDiagnosticsConfig.capacityMutation == true))
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
        local count, nextCount, validity = D.nextProbeCount(previous)
        data.FoodEffectsDiagnostics_transport_v1 = { schema = 1, count = nextCount, worldAge = D.worldAgeHours() }
        D.log("experiment=persistence phase=single-player recordStatus=" .. validity .. " previousCount=" .. tostring(count) .. " count=" .. tostring(nextCount) .. " worldAge=" .. tostring(D.worldAgeHours()) .. " " .. D.playerSnapshot(player))
    end
end
