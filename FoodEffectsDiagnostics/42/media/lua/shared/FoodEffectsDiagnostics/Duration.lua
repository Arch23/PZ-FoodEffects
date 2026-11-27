-- Observe selected vanilla action adjustment calls; never apply a modifier.
require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"

local D = FoodEffectsDiagnostics
if not FoodEffectsDiagnosticsConfig.durationObservation then
    D.log("experiment=duration enabled=false")
    return
end

require "TimedActions/ISAddItemInRecipe"
require "TimedActions/ISWashClothing"

-- Identity and invocation counters are local to this Lua process and are not
-- shared across client/server or stable across a reload.
local instances = setmetatable({}, { __mode = "k" })
local instanceSequence, invocationSequence = 0, 0

local function finite(value)
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function describe(value)
    if finite(value) then return tostring(value) end
    return "unavailable-or-nonfinite"
end

local function before(action, className, input)
    local instance = instances[action]
    if not instance then
        instanceSequence = instanceSequence + 1
        instance = instanceSequence
        instances[action] = instance
    end
    invocationSequence = invocationSequence + 1
    local invocation = invocationSequence
    D.log("experiment=duration phase=before class=" .. className ..
        " instance=" .. tostring(instance) .. " invocation=" .. tostring(invocation) ..
        " input=" .. describe(input))
    return instance, invocation
end

local function after(className, instance, invocation, input, ...)
    local output = select(1, ...)
    pcall(D.log, "experiment=duration phase=after class=" .. className ..
        " instance=" .. tostring(instance) .. " invocation=" .. tostring(invocation) ..
        " input=" .. describe(input) .. " output=" .. describe(output))
    return ...
end

local function install(class, className)
    -- ISBaseObject:derive supplies inherited methods through the metatable.
    -- Restrict interposition to these action classes, not ISBaseTimedAction.
    local original = class and class.adjustMaxTime
    if type(original) ~= "function" then
        D.log("experiment=duration class=" .. className .. " wrapper-installed=false reason=missing-method")
        return
    end
    class.adjustMaxTime = function(self, input, ...)
        local ok, instance, invocation = pcall(before, self, className, input)
        if not ok then instance, invocation = "unavailable", "unavailable" end
        -- No protected call around the original: its errors propagate as before.
        -- Passing results through `after` preserves their count and values.
        return after(className, instance, invocation, input, original(self, input, ...))
    end
    D.log("experiment=duration class=" .. className .. " wrapper-installed=true")
end

install(ISAddItemInRecipe, "ISAddItemInRecipe")
install(ISWashClothing, "ISWashClothing")
