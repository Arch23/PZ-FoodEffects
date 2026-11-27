-- Read-only observation around the vanilla evolved-recipe completion path.
-- This is diagnostic instrumentation, not a trusted gameplay hook.
require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"

local D = FoodEffectsDiagnostics
if not FoodEffectsDiagnosticsConfig.evolvedRecipe then
    D.log("experiment=evolved-recipe enabled=false")
    return
end

require "TimedActions/ISAddItemInRecipe"

local original = ISAddItemInRecipe and ISAddItemInRecipe.complete
if type(original) ~= "function" then
    D.log("experiment=evolved-recipe wrapper-installed=false reason=missing-method")
    return
end

-- Counts are useful context only, not proof of ingredient provenance.
local function listSize(item, method)
    local list = D.call(item, method)
    return D.call(list, "size")
end

local function itemDetails(label, item, player)
    return label .. "={" .. D.itemSnapshot(item) ..
        " inInventory=" .. tostring(D.isInInventory(player, item)) ..
        " extraItemsCount=" .. tostring(listSize(item, "getExtraItems")) ..
        " spicesCount=" .. tostring(listSize(item, "getSpices")) .. "}"
end

local function snapshot(action, phase, invocation)
    local player = action and action.character
    local recipe = action and action.recipe
    D.log("experiment=evolved-recipe hook=ISAddItemInRecipe.complete phase=" .. phase ..
        " invocation=" .. tostring(invocation) ..
        " worldAge=" .. tostring(D.worldAgeHours()) .. " " .. D.playerSnapshot(player) ..
        " recipe=" .. tostring(D.call(recipe, "getUntranslatedName")) .. " " ..
        itemDetails("base", action and action.baseItem, player) .. " " ..
        itemDetails("ingredient", action and action.usedItem, player))
end

-- Observation failures must not alter the original action's control flow.
local function observe(action, phase, invocation)
    local ok = pcall(snapshot, action, phase, invocation)
    if not ok then pcall(D.log, "experiment=evolved-recipe phase=" .. phase .. " snapshot-error=true invocation=" .. tostring(invocation)) end
end

local invocationSequence = 0
local function after(action, invocation, ...)
    observe(action, "after", invocation)
    return ...
end

ISAddItemInRecipe.complete = function(self, ...)
    invocationSequence = invocationSequence + 1
    local invocation = invocationSequence
    observe(self, "before", invocation)
    return after(self, invocation, original(self, ...))
end

D.log("experiment=evolved-recipe wrapper-installed=true")
