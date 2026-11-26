-- Experimental observation only. The wrappers below are justified by the shipped
-- Build 42 timed-action sources, which invoke these methods around consumption.
-- They preserve each observed method's single return value and never alter inputs.
require "FoodEffectsDiagnostics/Diagnostics"
require "TimedActions/ISEatFoodAction"
require "TimedActions/ISDrinkFromBottle"
require "TimedActions/ISDrinkFluidAction"

local Diagnostics = FoodEffectsDiagnostics
local actions = setmetatable({}, { __mode = "k" })
local actionSequence = 0

local function argumentSnapshot(hookName, ...)
    if hookName == "ISEatFoodAction.eat" or hookName == "ISDrinkFromBottle.drink" then
        local item, fraction = ...
        return " argumentItemId=" .. tostring(Diagnostics.call(item, "getID")) .. " argumentFraction=" .. tostring(fraction)
    elseif hookName == "ISDrinkFluidAction.updateEat" then
        local delta = ...
        return " argumentDelta=" .. tostring(delta)
    elseif hookName == "ISDrinkFluidAction.animEvent" then
        local event, parameter = ...
        return " argumentEvent=" .. tostring(event) .. " argumentParameter=" .. tostring(parameter)
    end
    return ""
end

-- Logging is best-effort: an unavailable diagnostic field must not interrupt vanilla.
local function logSnapshot(self, hookName, phase, invocation, state, parent, extra, result)
    local ok, message = pcall(function()
        return "hook=" .. hookName .. " phase=" .. phase .. " invocation=" .. invocation ..
            " action=" .. state.id .. " depth=" .. state.depth .. " parent=" .. tostring(parent) ..
            (result and " result=" .. result or "") .. extra .. " " .. Diagnostics.actionSnapshot(self)
    end)
    if ok then Diagnostics.log(message) else Diagnostics.log("snapshot-error hook=" .. hookName .. " phase=" .. phase) end
end

local function installWrapper(actionClass, methodName, hookName)
    local original = actionClass and actionClass[methodName]
    if type(original) ~= "function" then
        Diagnostics.log("wrapper hook=" .. hookName .. " installed=false reason=missing-method")
        return
    end

    actionClass[methodName] = function(self, ...)
        Diagnostics.sequence = Diagnostics.sequence + 1
        local invocation = Diagnostics.sequence
        local state = actions[self]
        if not state then
            actionSequence = actionSequence + 1
            state = { id = actionSequence, depth = 0, stack = {} }
            actions[self] = state
        end
        local parent = state.stack[state.depth]
        state.depth = state.depth + 1
        state.stack[state.depth] = invocation
        local ok, extra = pcall(argumentSnapshot, hookName, ...)
        if not ok then extra = " argumentSnapshot=error" end
        logSnapshot(self, hookName, "before", invocation, state, parent, extra)
        local result = original(self, ...)
        logSnapshot(self, hookName, "after", invocation, state, parent, extra, tostring(result))
        state.stack[state.depth] = nil
        state.depth = state.depth - 1
        local recordOk = pcall(Diagnostics.touchTestRecord, self and self.character, hookName)
        if not recordOk then Diagnostics.log("record-error hook=" .. hookName) end
        return result
    end
    Diagnostics.log("wrapper hook=" .. hookName .. " installed=true")
end

-- Food: complete invokes IsoGameCharacter:Eat; eat is also used by serverStop on cancellation.
installWrapper(ISEatFoodAction, "complete", "ISEatFoodAction.complete")
installWrapper(ISEatFoodAction, "eat", "ISEatFoodAction.eat")
installWrapper(ISEatFoodAction, "serverStop", "ISEatFoodAction.serverStop")

-- Legacy bottles mutate thirst/container amount in drink, including the stop path.
installWrapper(ISDrinkFromBottle, "complete", "ISDrinkFromBottle.complete")
installWrapper(ISDrinkFromBottle, "drink", "ISDrinkFromBottle.drink")
installWrapper(ISDrinkFromBottle, "stop", "ISDrinkFromBottle.stop")

-- Fluids call updateEat incrementally and again from complete; server animation events can call it too.
installWrapper(ISDrinkFluidAction, "animEvent", "ISDrinkFluidAction.animEvent")
installWrapper(ISDrinkFluidAction, "complete", "ISDrinkFluidAction.complete")
installWrapper(ISDrinkFluidAction, "updateEat", "ISDrinkFluidAction.updateEat")

Diagnostics.log("consumption-wrappers-load=true")
