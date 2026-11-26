-- Isolated Build 42 diagnostic support. This module intentionally applies no gameplay changes.
FoodEffectsDiagnostics = FoodEffectsDiagnostics or {}

local Diagnostics = FoodEffectsDiagnostics
Diagnostics.prefix = "[FoodEffectsDiagnostics]"
Diagnostics.sequence = Diagnostics.sequence or 0

function Diagnostics.side()
    if isServer and isServer() then return "server" end
    if isClient and isClient() then return "client" end
    return "single-player"
end

function Diagnostics.log(message)
    print(Diagnostics.prefix .. " side=" .. Diagnostics.side() .. " " .. tostring(message))
end

function Diagnostics.call(object, method)
    if not object or not object[method] then return nil end
    local ok, value = pcall(object[method], object)
    if ok then return value end
    return nil
end

function Diagnostics.worldAgeHours()
    local gameTime = getGameTime and getGameTime() or nil
    return Diagnostics.call(gameTime, "getWorldAgeHours")
end

function Diagnostics.itemSnapshot(item)
    if not item then return "item=nil" end
    return table.concat({
        "type=" .. tostring(Diagnostics.call(item, "getFullType")),
        "id=" .. tostring(Diagnostics.call(item, "getID")),
        "calories=" .. tostring(Diagnostics.call(item, "getCalories")),
        "carbohydrates=" .. tostring(Diagnostics.call(item, "getCarbohydrates")),
        "lipids=" .. tostring(Diagnostics.call(item, "getLipids")),
        "proteins=" .. tostring(Diagnostics.call(item, "getProteins")),
        "hunger=" .. tostring(Diagnostics.call(item, "getHungerChange")),
        "uses=" .. tostring(Diagnostics.call(item, "getCurrentUsesFloat"))
    }, " ")
end

function Diagnostics.isInInventory(player, item)
    local inventory = Diagnostics.call(player, "getInventory")
    if not inventory or not item or not inventory.contains then return nil end
    local ok, value = pcall(inventory.contains, inventory, item)
    if ok then return value end
    return nil
end

function Diagnostics.playerSnapshot(player)
    if not player then return "player=nil" end
    return "username=" .. tostring(Diagnostics.call(player, "getUsername")) ..
        " onlineId=" .. tostring(Diagnostics.call(player, "getOnlineID"))
end

function Diagnostics.nutritionSnapshot(player)
    local nutrition = Diagnostics.call(player, "getNutrition")
    return "playerCalories=" .. tostring(Diagnostics.call(nutrition, "getCalories")) ..
        " playerCarbohydrates=" .. tostring(Diagnostics.call(nutrition, "getCarbohydrates")) ..
        " playerLipids=" .. tostring(Diagnostics.call(nutrition, "getLipids")) ..
        " playerProteins=" .. tostring(Diagnostics.call(nutrition, "getProteins"))
end

function Diagnostics.actionSnapshot(action)
    local item = action and action.item or nil
    local requested = action and action.percentage or nil
    local consumed = action and action.consumedRatio or nil
    local fluid = action and action.fluidContainer or Diagnostics.call(item, "getFluidContainer")
    local networkAction = action and action.netAction or nil
    -- Vanilla ISBaseTimedAction:getJobDelta() dereferences self.action, which
    -- is absent for the server-side network action observed in MP.
    local jobProgress = nil
    if action and action.action then
        jobProgress = Diagnostics.call(action, "getJobDelta")
    end
    return "worldAge=" .. tostring(Diagnostics.worldAgeHours()) .. " " ..
        Diagnostics.playerSnapshot(action and action.character) .. " " .. Diagnostics.nutritionSnapshot(action and action.character) .. " requested=" .. tostring(requested) ..
        " observedRatio=" .. tostring(consumed) .. " jobProgress=" .. tostring(jobProgress) ..
        " networkProgress=" .. tostring(Diagnostics.call(networkAction, "getProgress")) ..
        " fluidAmount=" .. tostring(Diagnostics.call(fluid, "getAmount")) ..
        " fluidRatio=" .. tostring(Diagnostics.call(fluid, "getFilledRatio")) .. " inInventory=" ..
        tostring(Diagnostics.isInInventory(action and action.character, item)) .. " " .. Diagnostics.itemSnapshot(item)
end

-- This is deliberately only a test record. It is touched on the non-client side
-- when a diagnostic consumption wrapper runs; it neither changes stats nor items.
function Diagnostics.touchTestRecord(player, hook)
    if isClient and isClient() then return end
    if not player or not player.getModData then
        Diagnostics.log("record hook=" .. hook .. " unavailable=no-player-mod-data")
        return
    end
    local ok, data = pcall(player.getModData, player)
    if not ok or not data then
        Diagnostics.log("record hook=" .. hook .. " unavailable=getModData-failed")
        return
    end
    local previous = data.FoodEffectsDiagnostics_v1
    if type(previous) == "table" then
        Diagnostics.log("record-before hook=" .. hook .. " type=table schema=" .. tostring(previous.schema) ..
            " lastHook=" .. tostring(previous.lastHook) .. " lastWorldAge=" .. tostring(previous.lastWorldAge) ..
            " lastSide=" .. tostring(previous.lastSide) .. " " .. Diagnostics.playerSnapshot(player))
    else
        Diagnostics.log("record-before hook=" .. hook .. " type=" .. type(previous) .. " " .. Diagnostics.playerSnapshot(player))
    end
    data.FoodEffectsDiagnostics_v1 = {
        schema = 1,
        lastHook = hook,
        lastWorldAge = Diagnostics.worldAgeHours(),
        lastSide = Diagnostics.side()
    }
    Diagnostics.log("record hook=" .. hook .. " created-or-updated=true previousType=" .. type(previous))
end

Diagnostics.log("shared-load=true")
