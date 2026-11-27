require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"
FoodEffectsDiagnostics.log("server-load=true")

-- Diagnostic-only, non-recursive inventory scan; no item data is taken from
-- the requester. A process-local sequence correlates logs, not transactions.
if FoodEffectsDiagnosticsConfig.pairedMealSnapshot and isServer() then
    local snapshotSequence = 0
    local function onMealSnapshot(module, command, player, args)
        if module ~= "FoodEffectsDiagnostics" or command ~= "mealSnapshot" or not player then return end
        snapshotSequence = snapshotSequence + 1
        local seq = snapshotSequence
        local itemType = FoodEffectsDiagnosticsConfig.pairedMealType
        local status, count, found = "unavailable", 0, nil
        if type(itemType) ~= "string" or #itemType < 3 or #itemType > 128 or not itemType:match("^[%w_%-]+%.[%w_%-]+$") then
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
        FoodEffectsDiagnostics.log("experiment=paired-meal phase=server sequence=" .. tostring(seq) .. " configuredType=" .. tostring(itemType) .. " status=" .. status .. " matches=" .. tostring(count) .. " worldAge=" .. tostring(FoodEffectsDiagnostics.worldAgeHours()) .. " " .. FoodEffectsDiagnostics.playerSnapshot(player) .. " " .. snapshot)
        sendServerCommand(player, "FoodEffectsDiagnostics", "mealSnapshotResult", { sequence = seq, playerOnlineId = FoodEffectsDiagnostics.call(player, "getOnlineID") })
    end
    Events.OnClientCommand.Add(onMealSnapshot)
end

-- This is intentionally enabled only for disposable test servers. Any client
-- can request the fixed server configuration while it is enabled.
if FoodEffectsDiagnosticsConfig.giveTestItems and isServer() then
    local function onTestItemsRequest(module, command, player, args)
        if module ~= "FoodEffectsDiagnostics" or command ~= "giveTestItems" or not player then return end
        local configuredKit = FoodEffectsDiagnosticsConfig.testItemKit
        if configuredKit == nil then
            configuredKit = { { itemType = FoodEffectsDiagnosticsConfig.testItemType, count = FoodEffectsDiagnosticsConfig.testItemCount } }
        end
        if type(configuredKit) ~= "table" then
            FoodEffectsDiagnostics.log("experiment=test-items phase=denied reason=invalid-config")
            return
        end
        -- Validate the entire bounded kit before changing inventory. Copy the
        -- fields so the mutation loop never reads a partially valid config.
        local entryCount, total = 0, 0
        for key in pairs(configuredKit) do
            if type(key) ~= "number" or key ~= math.floor(key) or key < 1 or key > 10 then
                FoodEffectsDiagnostics.log("experiment=test-items phase=denied reason=invalid-kit-index")
                return
            end
            entryCount = entryCount + 1
        end
        if entryCount < 1 or entryCount > 10 then
            FoodEffectsDiagnostics.log("experiment=test-items phase=denied reason=invalid-kit-size")
            return
        end
        local kit = {}
        for i = 1, entryCount do
            local entry = configuredKit[i]
            if type(entry) ~= "table" then
                FoodEffectsDiagnostics.log("experiment=test-items phase=denied reason=invalid-kit-entry")
                return
            end
            local itemType, count = entry.itemType, entry.count
            if type(itemType) ~= "string" or #itemType < 3 or #itemType > 128 or not itemType:match("^[%w_%-]+%.[%w_%-]+$") or
                type(count) ~= "number" or count ~= count or count < 1 or count > 10 or count ~= math.floor(count) then
                FoodEffectsDiagnostics.log("experiment=test-items phase=denied reason=invalid-config")
                return
            end
            total = total + count
            if total > 20 then
                FoodEffectsDiagnostics.log("experiment=test-items phase=denied reason=kit-total-limit")
                return
            end
            local valid, scriptItem = pcall(function() return getScriptManager():FindItem(itemType) end)
            if not valid or not scriptItem then
                FoodEffectsDiagnostics.log("experiment=test-items phase=denied reason=unknown-item index=" .. tostring(i))
                return
            end
            kit[i] = { itemType = itemType, count = count }
        end
        local gotInventory, inventory = pcall(function() return player:getInventory() end)
        if not gotInventory or not inventory then
            FoodEffectsDiagnostics.log("experiment=test-items phase=denied reason=inventory-unavailable")
            return
        end
        local added, sent, failed = 0, 0, false
        for _, entry in ipairs(kit) do
            local entryAdded, entrySent = 0, 0
            for i = 1, entry.count do
                local ok, item = pcall(function() return inventory:AddItem(entry.itemType) end)
                if not ok or not item then failed = true; break end
                added, entryAdded = added + 1, entryAdded + 1
                local sentOk = pcall(sendAddItemToContainer, inventory, item)
                if not sentOk then failed = true; break end
                sent, entrySent = sent + 1, entrySent + 1
            end
            FoodEffectsDiagnostics.log("experiment=test-items phase=entry itemType=" .. entry.itemType .. " requested=" .. tostring(entry.count) ..
                " added=" .. tostring(entryAdded) .. " sendCalls=" .. tostring(entrySent))
            if failed then break end
        end
        FoodEffectsDiagnostics.log("experiment=test-items phase=server requested=" .. tostring(total) ..
            " added=" .. tostring(added) .. " sendCalls=" .. tostring(sent) .. " failed=" .. tostring(failed) .. " " .. FoodEffectsDiagnostics.playerSnapshot(player))
    end
    Events.OnClientCommand.Add(onTestItemsRequest)
end

if FoodEffectsDiagnosticsConfig.capacity and FoodEffectsDiagnosticsConfig.capacityMutation and FoodEffectsDiagnosticsConfig.capacityMutationServer and isServer() then
    local function onCapacityRequest(module, command, player, args)
        if module ~= "FoodEffectsDiagnostics" or command ~= "capacityMutation" or not player then return end
        local ok, allowed = pcall(function() return player:getRole():hasCapability(Capability.UseDebugContextMenu) end)
        if not ok or not allowed or not FoodEffectsDiagnostics.probeCapacityMutation then
            local reason = not ok and "capability-check-error" or (not allowed and "capability-not-granted" or "probe-unavailable")
            FoodEffectsDiagnostics.log("experiment=capacity phase=server-request-denied reason=" .. reason)
            return
        end
        FoodEffectsDiagnostics.log("experiment=capacity phase=server-request-accepted " .. FoodEffectsDiagnostics.playerSnapshot(player))
        FoodEffectsDiagnostics.probeCapacityMutation(player)
    end
    Events.OnClientCommand.Add(onCapacityRequest)
end

-- A server-owned synthetic deadline, unrelated to gameplay effects.
if FoodEffectsDiagnosticsConfig.offlineExpiry and isServer() then
    local function onExpiryRequest(module, command, player, args)
        if module ~= "FoodEffectsDiagnostics" or not player then return end
        if command ~= "expiryStart" and command ~= "expiryCheck" then return end
        local now = FoodEffectsDiagnostics.worldAgeHours()
        if type(now) ~= "number" or now ~= now or now < 0 or now == math.huge then
            FoodEffectsDiagnostics.log("experiment=offline-expiry phase=error reason=invalid-clock")
            return
        end
        local data = player:getModData()
        if command == "expiryStart" then
            data.FoodEffectsDiagnostics_expiry_v1 = { schema = 1, started = now, expires = now + 1 }
        end
        local record = data.FoodEffectsDiagnostics_expiry_v1
        if type(record) ~= "table" or record.schema ~= 1 or type(record.started) ~= "number" or type(record.expires) ~= "number" or record.started ~= record.started or record.expires ~= record.expires or record.started < 0 or record.expires ~= record.started + 1 or record.expires == math.huge then
            FoodEffectsDiagnostics.log("experiment=offline-expiry phase=check status=missing-or-invalid")
            return
        end
        FoodEffectsDiagnostics.log("experiment=offline-expiry phase=" .. command .. " started=" .. tostring(record.started) .. " expires=" .. tostring(record.expires) .. " now=" .. tostring(now) .. " remaining=" .. tostring(math.max(0, record.expires - now)) .. " " .. FoodEffectsDiagnostics.playerSnapshot(player))
    end
    Events.OnClientCommand.Add(onExpiryRequest)
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
