-- Edit only for a disposable test, then restart every participating game process.
FoodEffectsDiagnosticsConfig = {
    consumption = false,
    durationObservation = false,
    evolvedRecipe = false,
    pairedMealSnapshot = false,
    pairedMealType = "Base.Salad",
    persistenceTransport = false,
    offlineExpiry = false,
    -- Disposable test servers only. Server chooses these values and ignores
    -- any item type or quantity sent by the client.
    giveTestItems = false,
    testItemType = "Base.BeefJerky",
    testItemCount = 3,
    -- Optional contiguous array of { itemType = "Module.Item", count = N }.
    -- When nil, the single-item settings above remain in use.
    testItemKit = {
        { itemType = "Base.Bowl", count = 1 },
        { itemType = "Base.Tomato", count = 1 },
        { itemType = "Base.Lettuce", count = 1 }
    },
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
