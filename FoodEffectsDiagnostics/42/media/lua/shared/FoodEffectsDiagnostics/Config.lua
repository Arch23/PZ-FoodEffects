-- Edit only for a disposable test, then restart every participating game process.
FoodEffectsDiagnosticsConfig = {
    consumption = false,
    persistenceTransport = false,
    capacity = false,
    -- Requires capacity=true. Disposable characters only; the probe holds
    -- a temporary scalar across ticks before attempting restoration.
    capacityMutation = false,
    -- Server must explicitly enable this as well; requests require the
    -- vanilla debug capability and always target the requesting player.
    capacityMutationServer = false,
    capacityMutationDelta = 1.25,
    moodle = false
}
