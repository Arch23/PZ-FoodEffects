require "FoodEffectsDiagnostics/Diagnostics"
require "FoodEffectsDiagnostics/Config"

local diagnostics = FoodEffectsDiagnostics
if FoodEffectsDiagnosticsConfig.syntheticPresentation ~= true or not isServer() or diagnostics.syntheticPresentationServerLoaded then return end

local durationHours = 0.25

local function onClientCommand(module, command, player, args)
    if module ~= "FoodEffectsDiagnostics" or command ~= "syntheticPresentationRequest" or not player then return end
    if type(args) ~= "table" or diagnostics.call(player, "isDead") ~= false then return end

    -- This value only correlates the response with the local menu request.
    local request = args.request
    if type(request) ~= "number" or request < 1 or request > 2147483647 or request ~= math.floor(request) then return end

    local onlineId = diagnostics.call(player, "getOnlineID")
    if type(onlineId) ~= "number" or onlineId < 0 or onlineId > 32767 or onlineId ~= math.floor(onlineId) then return end
    if getPlayerByOnlineID(onlineId) ~= player then return end

    local started = diagnostics.worldAgeHours()
    if type(started) ~= "number" or started ~= started or started < 0 or started == math.huge then return end
    local deadline = started + durationHours
    if deadline <= started then return end

    -- One reply per request. There is no server record to retain or resync.
    local sent = pcall(sendServerCommand, player, "FoodEffectsDiagnostics", "syntheticPresentationRecord", {
        request = request,
        playerOnlineId = onlineId,
        started = started,
        deadline = deadline
    })
    diagnostics.log("experiment=presentation phase=server-response status=" .. (sent and "send-returned" or "send-error") ..
        " worldAge=" .. tostring(started) .. " deadline=" .. tostring(deadline))
end

Events.OnClientCommand.Add(onClientCommand)
diagnostics.syntheticPresentationServerLoaded = true
