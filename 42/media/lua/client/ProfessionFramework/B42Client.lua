require "ProfessionFramework/B42"

if isServer() then
    return
end

Events.OnGameStart.Add(ProfessionFramework.onGameStart)
