require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"

-- Disposable dedicated-server experiment. The server selects both the target
-- and value; no client command is involved. Restarting while enabled re-arms it.
local C = FoodEffectsDiagnosticsConfig
local D = FoodEffectsDiagnostics
if isServer() and C.capacity and C.capacityMutation and C.capacityAutoServer then
    local attempted = false
    local waitingPlayer, waitingSince, probe = nil, nil, nil
    local function finite(n)
        return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
    end
    local function sample(phase, p)
        D.log("experiment=capacity-auto phase=" .. phase .. " maxWeight=" .. tostring(D.call(p, "getMaxWeight")) ..
            " maxWeightDelta=" .. tostring(D.call(p, "getMaxWeightDelta")))
    end
    local function exactPlayer()
        local players = getOnlinePlayers()
        if not players then return nil, 0 end
        local found, matches = nil, 0
        for i = 0, players:size() - 1 do
            local p = players:get(i)
            if p and D.call(p, "getUsername") == C.capacityAutoUsername then
                found, matches = p, matches + 1
            end
        end
        return found, matches
    end
    local function tick()
        local now = getTimestampMs()
        if not finite(now) then return end
        if probe then
            local p = probe.player
            if probe.phase == "post-restore-attempt" then
                if now >= probe.deadline then
                    sample("post-restore-attempt", p)
                    probe = nil
                end
                return
            end
            local currentPlayer, matches = exactPlayer()
            if probe.phase == "pre-apply" then
                if matches ~= 1 or currentPlayer ~= p then
                    D.log("experiment=capacity-auto phase=apply-skipped reason=player-disconnected-or-ambiguous")
                    probe = nil
                    return
                end
                if now < probe.deadline then return end
                local current = D.call(p, "getMaxWeightDelta")
                if not finite(current) or math.abs(current - probe.baseline) > 0.00001 then
                    D.log("experiment=capacity-auto phase=apply-skipped reason=baseline-changed-or-unavailable")
                    probe = nil
                    return
                end
                local ok = pcall(probe.setter, p, probe.target)
                local observed = D.call(p, "getMaxWeightDelta")
                D.log("experiment=capacity-auto phase=apply callOk=" .. tostring(ok) .. " target=" .. tostring(probe.target) ..
                    " elapsedMs=" .. tostring(now - probe.started))
                sample("apply-readback", p)
                if finite(observed) and math.abs(observed - probe.target) <= 0.00001 then
                    probe.applied = observed
                    probe.phase = "holding"
                    probe.deadline = now + 15000
                else
                    D.log("experiment=capacity-auto phase=ownership-unconfirmed restoreSkipped=true")
                    probe = nil
                end
                return
            end
            if now < probe.deadline and matches == 1 and currentPlayer == p then return end
            sample("before-restore", p)
            local current = D.call(p, "getMaxWeightDelta")
            if not finite(current) or math.abs(current - probe.applied) > 0.00001 then
                D.log("experiment=capacity-auto phase=restore-skipped reason=scalar-changed-or-unavailable")
                probe = nil
                return
            end
            local ok = pcall(probe.setter, p, probe.baseline)
            D.log("experiment=capacity-auto phase=restore-attempt callOk=" .. tostring(ok) ..
                " disconnected=" .. tostring(matches ~= 1 or currentPlayer ~= p) .. " elapsedMs=" .. tostring(now - probe.started))
            sample("restore-readback", p)
            probe.phase = "post-restore-attempt"
            probe.deadline = now + 10000
            return
        end
        if attempted then return end
        if type(C.capacityAutoUsername) ~= "string" or #C.capacityAutoUsername < 1 or #C.capacityAutoUsername > 128 then
            attempted = true
            D.log("experiment=capacity-auto phase=skip reason=invalid-configured-username")
            return
        end
        local player, matches = exactPlayer()
        if matches ~= 1 then waitingPlayer, waitingSince = nil, nil; return end
        if waitingPlayer ~= player then waitingPlayer, waitingSince = player, now; return end
        if now - waitingSince < 10000 then return end
        attempted = true
        local baseline, target = D.call(player, "getMaxWeightDelta"), C.capacityMutationDelta
        local onlineId = D.call(player, "getOnlineID")
        if not finite(baseline) or baseline < 0 or baseline > 10 or not finite(target) or target < 0.1 or target > 3 or math.abs(target - baseline) <= 0.00001 or not finite(onlineId) or onlineId < 0 then
            D.log("experiment=capacity-auto phase=skip reason=invalid-or-equal-baseline-target-or-id")
            return
        end
        local setter = player.setMaxWeightDelta
        if type(setter) ~= "function" then
            D.log("experiment=capacity-auto phase=skip reason=setter-unavailable")
            return
        end
        sample("before", player)
        local sent = pcall(sendServerCommand, player, "FoodEffectsDiagnostics", "capacityAutoObserve", { playerOnlineId = onlineId })
        D.log("experiment=capacity-auto phase=observe-request callOk=" .. tostring(sent))
        if not sent then return end
        probe = { player = player, baseline = baseline, target = target, setter = setter,
            started = now, phase = "pre-apply", deadline = now + 5000 }
        D.log("experiment=capacity-auto phase=pre-apply elapsedMs=0")
    end
    Events.OnTick.Add(tick)
    D.log("experiment=capacity-auto enabled=true disposable-server-required=true")
end
