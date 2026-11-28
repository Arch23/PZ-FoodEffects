require "FoodEffectsDiagnostics/Config"

local C = FoodEffectsDiagnosticsConfig
if not isServer() or C.capacityReadOnlyServer ~= true then return end

require "FoodEffectsDiagnostics/Diagnostics"
local D = FoodEffectsDiagnostics
if C.capacity and C.capacityMutation and (C.capacityAutoServer or C.capacityMutationServer) then
    D.log("experiment=capacity-read-only phase=skip reason=server-mutation-enabled")
    return
end

local username = C.capacityReadOnlyUsername
if type(username) ~= "string" or #username > 128 or not username:find("%S") or username:find("%c") then
    D.log("experiment=capacity-read-only phase=skip reason=invalid-configured-username")
    return
end

local settleDelayMs = 10000
local observedPlayer, firstAt, settled = nil, nil, false
local sequence = 0

local function isFinite(value)
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function readNumber(getter, player)
    local ok, value = pcall(getter, player)
    if ok and isFinite(value) then return tostring(value) end
    return "unknown"
end

local function readTrait(player, name)
    local ok, value = pcall(function()
        local trait = CharacterTrait and CharacterTrait[name]
        if trait then return player:hasTrait(trait) end
    end)
    if ok and type(value) == "boolean" then return tostring(value) end
    return "unknown"
end

local function sample(phase, player, elapsedMs)
    D.log(table.concat({
        "experiment=capacity-read-only phase=" .. phase,
        "connection=" .. tostring(sequence),
        "elapsedMs=" .. tostring(elapsedMs),
        "maxWeightDelta=" .. readNumber(function(p) return p:getMaxWeightDelta() end, player),
        "maxWeight=" .. readNumber(function(p) return p:getMaxWeight() end, player),
        "strength=" .. readNumber(function(p) return p:getPerkLevel(Perks.Strength) end, player),
        "weak=" .. readTrait(player, "WEAK"),
        "feeble=" .. readTrait(player, "FEEBLE"),
        "stout=" .. readTrait(player, "STOUT"),
        "strong=" .. readTrait(player, "STRONG")
    }, " "))
end

-- Keep the observed player across ambiguous scans while that player is online.
-- An incomplete scan cannot establish either an exact match or a disconnect.
local function findPlayer()
    local players = getOnlinePlayers()
    if not players then return end
    local match, matches, stillOnline = nil, 0, false
    for index = 0, players:size() - 1 do
        local player = players:get(index)
        local account = player and player:getUsername()
        if type(account) ~= "string" then return end
        if player == observedPlayer then stillOnline = true end
        if account == username then
            match, matches = player, matches + 1
        end
    end
    if matches == 1 then return match, stillOnline end
    return nil, stillOnline
end

local function tick()
    local clockOk, now = pcall(getTimestampMs)
    if not clockOk or not isFinite(now) then return end
    local scanOk, player, stillOnline = pcall(findPlayer)
    if not scanOk or stillOnline == nil then return end
    if not stillOnline then observedPlayer = nil end
    if not player then return end

    if not observedPlayer then
        observedPlayer, firstAt, settled = player, now, false
        sequence = sequence + 1
        sample("first", player, 0)
    elseif player == observedPlayer and not settled then
        if now < firstAt then firstAt = now end
        if now - firstAt >= settleDelayMs then
            settled = true
            sample("settled", player, now - firstAt)
        end
    end
end

Events.OnTick.Add(tick)
D.log("experiment=capacity-read-only enabled=true")
