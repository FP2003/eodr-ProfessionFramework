require "ProfessionFramework/B42"

if isClient() then
    return
end

Events.OnNewGame.Add(ProfessionFramework.onNewGame)
Events.OnSpawnRegionsLoaded.Add(ProfessionFramework.onSpawnRegionsLoaded)
