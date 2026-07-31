-- Profession Framework Build 42 API.
--
-- Build 42 registers selectable traits and professions before normal Lua runs.
-- This module therefore attaches runtime behaviour to static definitions; it
-- deliberately never creates or edits character-creation definitions.

ProfessionFramework = ProfessionFramework or {}

local PF = ProfessionFramework

if PF.B42_LOADED then
    return PF
end

PF.B42_LOADED = true
PF.VERSION = "2.0.0-b42"
PF.BUILD = "42.20"
PF.AUTHOR = "Skizzo"

PF.ERROR = 0
PF.WARN = 1
PF.INFO = 2
PF.DEBUG = 3

PF.LogLevel = PF.LogLevel or PF.INFO
PF.AlwaysUseStartingKits = PF.AlwaysUseStartingKits ~= false
PF.Traits = PF.Traits or {}
PF.Professions = PF.Professions or {}

local logLevelNames = {
    [PF.ERROR] = "ERROR",
    [PF.WARN] = "WARN",
    [PF.INFO] = "INFO",
    [PF.DEBUG] = "DEBUG",
}

PF.log = function(level, message)
    if level > PF.LogLevel then
        return
    end
    print("ProfessionFramework." .. (logLevelNames[level] or "LOG") .. ": " .. tostring(message))
end

local function fail(message)
    PF.log(PF.ERROR, message)
    error("ProfessionFramework Build 42: " .. message, 3)
end

local function sortedKeys(values)
    local result = {}
    for key in pairs(values) do
        table.insert(result, key)
    end
    table.sort(result)
    return result
end

local function lookup(kind, id)
    if type(id) ~= "string" or id == "" then
        return nil
    end

    local ok, value = pcall(function()
        local resource = ResourceLocation.of(id)
        if kind == "trait" then
            return CharacterTrait.get(resource)
        end
        return CharacterProfession.get(resource)
    end)

    if not ok then
        return nil
    end
    return value
end

PF.resolveTrait = function(id)
    return lookup("trait", id)
end

PF.resolveProfession = function(id)
    return lookup("profession", id)
end

-- B41 profession-trait aliases that have a static B42 compatibility bridge.
-- New B42 definitions should grant the mapped `base:` trait directly.
PF.LegacyTraitAliases = {
    SpeedDemon2 = "ProfessionFramework:speeddemon2",
    SundayDriver2 = "ProfessionFramework:sundaydriver2",
    BaseballPlayer2 = "ProfessionFramework:baseballplayer2",
    Brave2 = "ProfessionFramework:brave2",
    Cowardly2 = "ProfessionFramework:cowardly2",
    Clumsy2 = "ProfessionFramework:clumsy2",
    Graceful2 = "ProfessionFramework:graceful2",
    ShortSighted2 = "ProfessionFramework:shortsighted2",
    EagleEyed2 = "ProfessionFramework:eagleeyed2",
    HardOfHearing2 = "ProfessionFramework:hardofhearing2",
    Deaf2 = "ProfessionFramework:deaf2",
    KeenHearing2 = "ProfessionFramework:keenhearing2",
    HeartyAppitite2 = "ProfessionFramework:heartyappitite2",
    LightEater2 = "ProfessionFramework:lighteater2",
    ThickSkinned2 = "ProfessionFramework:thickskinned2",
    Thinskinned2 = "ProfessionFramework:thinskinned2",
    Resilient2 = "ProfessionFramework:resilient2",
    ProneToIllness2 = "ProfessionFramework:pronetoillness2",
    Dextrous2 = "ProfessionFramework:dextrous2",
    AllThumbs2 = "ProfessionFramework:allthumbs2",
    FastHealer2 = "ProfessionFramework:fasthealer2",
    SlowHealer2 = "ProfessionFramework:slowhealer2",
    FastLearner2 = "ProfessionFramework:fastlearner2",
    SlowLearner2 = "ProfessionFramework:slowlearner2",
    FastReader2 = "ProfessionFramework:fastreader2",
    SlowReader2 = "ProfessionFramework:slowreader2",
    Illiterate2 = "ProfessionFramework:illiterate2",
    NeedsLessSleep2 = "ProfessionFramework:needslesssleep2",
    NeedsMoreSleep2 = "ProfessionFramework:needsmoresleep2",
    Inconspicuous2 = "ProfessionFramework:inconspicuous2",
    Conspicuous2 = "ProfessionFramework:conspicuous2",
    Organized2 = "ProfessionFramework:organized2",
    Disorganized2 = "ProfessionFramework:disorganized2",
    LowThirst2 = "ProfessionFramework:lowthirst2",
    HighThirst2 = "ProfessionFramework:highthirst2",
    WeakStomach2 = "ProfessionFramework:weakstomach2",
    IronGut2 = "ProfessionFramework:irongut2",
    Outdoorsman2 = "ProfessionFramework:outdoorsman2",
    AdrenalineJunkie2 = "ProfessionFramework:adrenalinejunkie2",
    NightVision2 = "ProfessionFramework:nightvision2",
    Agoraphobic2 = "ProfessionFramework:agoraphobic2",
    Claustophobic2 = "ProfessionFramework:claustophobic2",
    Hemophobic2 = "ProfessionFramework:hemophobic2",
    Insomniac2 = "ProfessionFramework:insomniac2",
    Pacifist2 = "ProfessionFramework:pacifist2",
    Smoker2 = "ProfessionFramework:smoker2",
    Asthmatic2 = "ProfessionFramework:asthmatic2",
    Herbalist2 = "ProfessionFramework:herbalist2",
    Handy2 = "ProfessionFramework:handy2",
    Jogger2 = "ProfessionFramework:jogger2",
}

PF.LegacyTraitTargets = {
    SpeedDemon2 = "base:speeddemon",
    SundayDriver2 = "base:sundaydriver",
    BaseballPlayer2 = "base:baseballplayer",
    Brave2 = "base:brave",
    Cowardly2 = "base:cowardly",
    Clumsy2 = "base:clumsy",
    Graceful2 = "base:graceful",
    ShortSighted2 = "base:shortsighted",
    EagleEyed2 = "base:eagleeyed",
    HardOfHearing2 = "base:hardofhearing",
    Deaf2 = "base:deaf",
    KeenHearing2 = "base:keenhearing",
    HeartyAppitite2 = "base:heartyappetite",
    LightEater2 = "base:lighteater",
    ThickSkinned2 = "base:thickskinned",
    Thinskinned2 = "base:thinskinned",
    Resilient2 = "base:resilient",
    ProneToIllness2 = "base:pronetoillness",
    Dextrous2 = "base:dextrous",
    AllThumbs2 = "base:allthumbs",
    FastHealer2 = "base:fasthealer",
    SlowHealer2 = "base:slowhealer",
    FastLearner2 = "base:fastlearner",
    SlowLearner2 = "base:slowlearner",
    FastReader2 = "base:fastreader",
    SlowReader2 = "base:slowreader",
    Illiterate2 = "base:illiterate",
    NeedsLessSleep2 = "base:needslesssleep",
    NeedsMoreSleep2 = "base:needsmoresleep",
    Inconspicuous2 = "base:inconspicuous",
    Conspicuous2 = "base:conspicuous",
    Organized2 = "base:organized",
    Disorganized2 = "base:disorganized",
    LowThirst2 = "base:lowthirst",
    HighThirst2 = "base:highthirst",
    WeakStomach2 = "base:weakstomach",
    IronGut2 = "base:irongut",
    Outdoorsman2 = "base:outdoorsman",
    AdrenalineJunkie2 = "base:adrenalinejunkie",
    NightVision2 = "base:nightvision",
    Agoraphobic2 = "base:agoraphobic",
    Claustophobic2 = "base:claustrophobic",
    Hemophobic2 = "base:hemophobic",
    Insomniac2 = "base:insomniac",
    Pacifist2 = "base:pacifist",
    Smoker2 = "base:smoker",
    Asthmatic2 = "base:asthmatic",
    Herbalist2 = "base:herbalist",
    Handy2 = "base:handy",
    Jogger2 = "base:jogger",
    Lucky2 = false,
    Unlucky2 = false,
}

-- `CharacterCreationProfession` adds a profession's free traits directly to
-- the selected list and does not recursively expand their GrantedTraits. Keep
-- the B41 bridge explicit and authoritative on the B42 server.
PF.LegacyAliasRuntimeTargets = {}
for legacyId, aliasId in pairs(PF.LegacyTraitAliases) do
    local alias = lookup("trait", aliasId)
    local target = PF.LegacyTraitTargets[legacyId]
    if alias and target then
        PF.LegacyAliasRuntimeTargets[alias:toString()] = target
    elseif target then
        PF.log(PF.ERROR, "legacy trait alias '" .. aliasId .. "' is not registered; check media/registries.lua and the static trait script")
    end
end

local staticFields = {
    name = true,
    description = true,
    cost = true,
    icon = true,
    xp = true,
    traits = true,
    recipes = true,
    exclude = true,
    profession = true,
    removeInMP = true,
    requiresSleepEnabled = true,
    clothing = true,
    restricted = true,
    required = true,
}

local allowedTraitFields = {
    inventory = true,
    square = true,
    add = true,
    swap = true,
    OnNewGame = true,
    OnGameStart = true,
}

local allowedProfessionFields = {
    inventory = true,
    square = true,
    spawns = true,
    OnNewGame = true,
    OnGameStart = true,
}

local function canonicalId(kind, id)
    if type(id) ~= "string" or id == "" then
        fail("a " .. kind .. " id must be a non-empty string")
    end

    local canonical = id
    if not string.find(id, ":", 1, true) then
        if kind == "trait" and PF.LegacyTraitAliases[id] then
            canonical = PF.LegacyTraitAliases[id]
            PF.log(PF.WARN, "using legacy trait alias '" .. id .. "'; migrate to '" .. PF.LegacyTraitTargets[id] .. "'")
        elseif kind == "trait" and PF.LegacyTraitTargets[id] == false then
            fail("legacy trait '" .. id .. "' was removed in Build 42.20 and has no vanilla replacement")
        else
            canonical = "base:" .. string.lower(id)
            PF.log(PF.WARN, "using a bare " .. kind .. " id '" .. id .. "'; migrate to the canonical id '" .. canonical .. "'")
        end
    end

    local definition = lookup(kind, canonical)
    if not definition then
        fail(kind .. " '" .. canonical .. "' is not registered. Build 42 definitions must be registered in media/registries.lua and declared in a static script before attaching behavior.")
    end

    return definition:toString()
end

local function validateItemTable(id, field, items)
    if type(items) ~= "table" then
        fail(field .. " for '" .. id .. "' must be a table of item ids to positive whole counts")
    end

    local scriptManager = getScriptManager and getScriptManager()
    for item, count in pairs(items) do
        if type(item) ~= "string" or item == "" then
            fail(field .. " for '" .. id .. "' contains an invalid item id")
        end
        if type(count) ~= "number" or count <= 0 or count ~= math.floor(count) then
            fail(field .. " item '" .. item .. "' for '" .. id .. "' needs a positive whole count")
        end
        if scriptManager and not scriptManager:FindItem(item) then
            fail(field .. " item '" .. item .. "' for '" .. id .. "' is not defined")
        end
    end
end

local function validateSpawnPoint(id, region, index, point)
    if type(point) ~= "table" then
        fail("spawn " .. tostring(index) .. " for '" .. id .. "' in '" .. region .. "' must be a table")
    end
    if point.position == "center" then
        return
    end
    if type(point.posX) ~= "number" or type(point.posY) ~= "number" then
        fail("spawn " .. tostring(index) .. " for '" .. id .. "' in '" .. region .. "' needs posX and posY, or position='center'")
    end
    if point.posZ ~= nil and type(point.posZ) ~= "number" then
        fail("spawn " .. tostring(index) .. " for '" .. id .. "' in '" .. region .. "' has an invalid posZ")
    end
    if point.worldX ~= nil and type(point.worldX) ~= "number" then
        fail("spawn " .. tostring(index) .. " for '" .. id .. "' in '" .. region .. "' has an invalid worldX")
    end
    if point.worldY ~= nil and type(point.worldY) ~= "number" then
        fail("spawn " .. tostring(index) .. " for '" .. id .. "' in '" .. region .. "' has an invalid worldY")
    end
end

local function validateSpawns(id, spawns)
    if type(spawns) ~= "table" then
        fail("spawns for '" .. id .. "' must be a table keyed by spawn-region name")
    end
    for region, points in pairs(spawns) do
        if type(region) ~= "string" or region == "" then
            fail("spawns for '" .. id .. "' contain an invalid region name")
        end
        if type(points) ~= "table" then
            fail("spawns for '" .. id .. "' in '" .. region .. "' must be a list")
        end
        for index, point in ipairs(points) do
            validateSpawnPoint(id, region, index, point)
        end
    end
end

local function normalizeTraitList(id, field, values)
    if type(values) ~= "table" then
        fail(field .. " for '" .. id .. "' must be a list of trait ids")
    end
    local result = {}
    for index, value in ipairs(values) do
        result[index] = canonicalId("trait", value)
    end
    return result
end

local function normalizeDetails(kind, id, details)
    if type(details) ~= "table" then
        fail("behavior for '" .. id .. "' must be a table")
    end

    local allowed = kind == "trait" and allowedTraitFields or allowedProfessionFields
    local result = {}
    for key, value in pairs(details) do
        if staticFields[key] then
            fail("'" .. key .. "' for '" .. id .. "' is static in Build 42. Move it to a character_" .. kind .. "_definition script.")
        end
        if not allowed[key] then
            fail("unsupported Build 42 " .. kind .. " behavior field '" .. tostring(key) .. "' for '" .. id .. "'")
        end
        result[key] = value
    end

    if result.inventory then
        validateItemTable(id, "inventory", result.inventory)
    end
    if result.square then
        validateItemTable(id, "square", result.square)
    end
    if result.OnNewGame and type(result.OnNewGame) ~= "function" then
        fail("OnNewGame for '" .. id .. "' must be a function")
    end
    if result.OnGameStart and type(result.OnGameStart) ~= "function" then
        fail("OnGameStart for '" .. id .. "' must be a function")
    end
    if result.spawns then
        validateSpawns(id, result.spawns)
    end
    if result.swap then
        if kind ~= "trait" or type(result.swap) ~= "string" then
            fail("swap for '" .. id .. "' is only supported for trait behavior and must name a trait")
        end
        result.swap = canonicalId("trait", result.swap)
        PF.log(PF.WARN, "runtime swap for '" .. id .. "' runs after character setup. Prefer GrantedTraits in the static definition for character-creation UI and validation.")
    end
    if result.add then
        if kind ~= "trait" then
            fail("add is only supported for trait behavior; use GrantedTraits for professions")
        end
        result.add = normalizeTraitList(id, "add", result.add)
        PF.log(PF.WARN, "runtime add for '" .. id .. "' runs after character setup. Prefer GrantedTraits in the static definition for character-creation UI and validation.")
    end

    return result
end

local function attachBehavior(kind, id, details)
    local canonical = canonicalId(kind, id)
    local registrations = kind == "trait" and PF.Traits or PF.Professions
    if registrations[canonical] then
        fail(kind .. " behavior is already attached for '" .. canonical .. "'")
    end

    registrations[canonical] = normalizeDetails(kind, canonical, details)
    return registrations[canonical]
end

PF.attachTraitBehavior = function(id, details)
    return attachBehavior("trait", id, details)
end

PF.attachProfessionBehavior = function(id, details)
    return attachBehavior("profession", id, details)
end

PF.getTrait = function(id)
    if type(id) ~= "string" then
        return nil
    end
    if PF.Traits[id] then
        return PF.Traits[id]
    end
    local trait = lookup("trait", PF.LegacyTraitAliases[id] or id)
    return trait and PF.Traits[trait:toString()] or nil
end

PF.getProfession = function(id)
    if type(id) ~= "string" then
        return nil
    end
    if PF.Professions[id] then
        return PF.Professions[id]
    end
    local profession = lookup("profession", id)
    return profession and PF.Professions[profession:toString()] or nil
end

-- B41 compatibility entry points. In Build 42 these can attach runtime
-- behavior only; they cannot create a trait or profession for character setup.
PF.addTrait = function(id, details)
    PF.log(PF.WARN, "addTrait is a Build 42 behavior-only compatibility alias; use attachTraitBehavior and static definitions for selectable traits")
    return PF.attachTraitBehavior(id, details)
end

PF.addProfession = function(id, details)
    PF.log(PF.WARN, "addProfession is a Build 42 behavior-only compatibility alias; use attachProfessionBehavior and static definitions for selectable professions")
    return PF.attachProfessionBehavior(id, details)
end

local function starterKitEnabled()
    return PF.AlwaysUseStartingKits or (SandboxVars and SandboxVars.StarterKit)
end

PF.addStartingKit = function(player, square, details)
    if isClient() then
        fail("starting kits must run on the server or in single-player")
    end
    if not player or not details or not starterKitEnabled() then
        return false
    end

    local inventory = player:getInventory()
    if details.inventory then
        validateItemTable("starting kit", "inventory", details.inventory)
        for _, item in ipairs(sortedKeys(details.inventory)) do
            inventory:AddItems(item, details.inventory[item])
        end
    end

    if details.square then
        validateItemTable("starting kit", "square", details.square)
        local targetSquare = square or player:getCurrentSquare()
        if not targetSquare then
            PF.log(PF.WARN, "could not place square items because the player has no current square")
        else
            for _, item in ipairs(sortedKeys(details.square)) do
                for count = 1, details.square[item] do
                    targetSquare:AddWorldInventoryItem(item, 0, 0, 0)
                end
            end
        end
    end

    return true
end

local function addTraitObject(player, trait, visited)
    if not trait then
        fail("cannot add a missing trait")
    end

    local id = trait:toString()
    visited = visited or {}
    if visited[id] then
        return
    end
    visited[id] = true

    local traits = player:getCharacterTraits()
    if not traits:get(trait) then
        traits:add(trait)
        player:modifyTraitXPBoost(trait, false)
    end

    local definition = CharacterTraitDefinition.getCharacterTraitDefinition(trait)
    if not definition then
        return
    end

    local recipes = definition:getGrantedRecipes()
    if recipes then
        for index = 0, recipes:size() - 1 do
            player:learnRecipe(recipes:get(index))
        end
    end

    local grantedTraits = definition:getGrantedTraits()
    if grantedTraits then
        for index = 0, grantedTraits:size() - 1 do
            addTraitObject(player, grantedTraits:get(index), visited)
        end
    end
end

local function addTrait(player, id)
    local trait = lookup("trait", id)
    if not trait then
        fail("cannot add missing trait '" .. id .. "'")
    end
    addTraitObject(player, trait)
end

local function removeTrait(player, id)
    local trait = lookup("trait", id)
    if not trait then
        fail("cannot remove missing trait '" .. id .. "'")
    end
    local traits = player:getCharacterTraits()
    if traits:get(trait) then
        traits:remove(trait)
        player:modifyTraitXPBoost(trait, true)
    end
end

local function selectedTraitIds(player)
    local result = {}
    local traits = player:getCharacterTraits()
    local knownTraits = traits:getKnownTraits()
    for index = 0, knownTraits:size() - 1 do
        local trait = knownTraits:get(index)
        if trait and traits:get(trait) then
            table.insert(result, trait:toString())
        end
    end
    table.sort(result)
    return result
end

local function frameworkState(player, create)
    local modData = player:getModData()
    local state = modData.ProfessionFramework
    if type(state) ~= "table" then
        if not create then
            return nil
        end
        state = {}
        modData.ProfessionFramework = state
    end
    return state
end

local function appliedMarkers(player)
    local state = frameworkState(player, true)
    if type(state.B42Applied) ~= "table" then
        state.B42Applied = {}
    end
    return state.B42Applied
end

local function markLegacyTraitOrigin(player, id)
    local state = frameworkState(player, true)
    if type(state.B42LegacyTraitOrigins) ~= "table" then
        state.B42LegacyTraitOrigins = {}
    end
    state.B42LegacyTraitOrigins[id] = true
end

local function legacyOriginTraitIds(player)
    local state = frameworkState(player, false)
    local origins = state and state.B42LegacyTraitOrigins
    if type(origins) ~= "table" then
        return {}
    end

    local result = {}
    local traits = player:getCharacterTraits()
    for aliasId, targetId in pairs(PF.LegacyAliasRuntimeTargets) do
        if origins[aliasId] then
            local target = lookup("trait", targetId)
            if target and traits:get(target) then
                table.insert(result, aliasId)
            end
        end
    end
    table.sort(result)
    return result
end

local function applyBehavior(kind, id, details, player, square)
    local marker = kind .. ":" .. id
    local markers = appliedMarkers(player)
    if markers[marker] then
        PF.log(PF.DEBUG, "skipping already-applied " .. marker)
        return
    end

    -- Store the marker before callbacks so a retried creation event cannot
    -- duplicate items when an integration callback fails.
    markers[marker] = true
    local ok, failure = pcall(function()
        PF.addStartingKit(player, square, details)

        if kind == "trait" then
            if details.swap then
                removeTrait(player, id)
                addTrait(player, details.swap)
            end
            if details.add then
                for _, trait in ipairs(details.add) do
                    addTrait(player, trait)
                end
            end
        end

        if details.OnNewGame then
            details.OnNewGame(player, square, id)
        end
    end)

    if not ok then
        PF.log(PF.ERROR, "OnNewGame behavior for '" .. id .. "' failed: " .. tostring(failure))
    end
end

local function traitIsActive(player, id)
    local trait = lookup("trait", id)
    return trait and player:getCharacterTraits():get(trait)
end

local function enqueueActiveTraits(player, queue, queued)
    for _, id in ipairs(selectedTraitIds(player)) do
        if not queued[id] then
            queued[id] = true
            table.insert(queue, id)
        end
    end
end

local function runNewGameTraitBehaviors(player, square)
    local queue = {}
    local queued = {}
    enqueueActiveTraits(player, queue, queued)

    local index = 1
    while index <= #queue do
        local id = queue[index]
        index = index + 1

        if traitIsActive(player, id) then
            local legacyTarget = PF.LegacyAliasRuntimeTargets[id]
            if legacyTarget then
                -- Preserve the legacy id for its client-side OnGameStart
                -- behavior, then replace it with the real B42 vanilla trait.
                markLegacyTraitOrigin(player, id)
                removeTrait(player, id)
                addTrait(player, legacyTarget)
            end

            local details = PF.Traits[id]
            if details then
                applyBehavior("trait", id, details, player, square)
            end

            -- Trait add/swap behavior can activate further traits. Queue each
            -- newly active trait once so its kit and callback run this spawn.
            enqueueActiveTraits(player, queue, queued)
        end
    end
end

PF.onNewGame = function(player, square)
    if isClient() or not player then
        return
    end

    runNewGameTraitBehaviors(player, square)

    local descriptor = player:getDescriptor()
    local profession = descriptor and descriptor:getCharacterProfession()
    if profession then
        local id = profession:toString()
        local details = PF.Professions[id]
        if details then
            applyBehavior("profession", id, details, player, square)
        end
    end
end

local function eachRegion(regions)
    local result = {}
    if type(regions) == "table" then
        for _, region in ipairs(regions) do
            table.insert(result, region)
        end
    elseif regions and regions.size then
        for index = 0, regions:size() - 1 do
            table.insert(result, regions:get(index))
        end
    end
    return result
end

local function findRegion(regions, name)
    for _, region in ipairs(eachRegion(regions)) do
        if region and region.name == name then
            return region
        end
    end
    return nil
end

PF.onSpawnRegionsLoaded = function(regions)
    if isClient() then
        return
    end

    for _, id in ipairs(sortedKeys(PF.Professions)) do
        local details = PF.Professions[id]
        if details.spawns then
            local profession = lookup("profession", id)
            if not profession then
                PF.log(PF.ERROR, "registered profession '" .. id .. "' disappeared before spawn regions loaded")
            else
                local path = profession:getName()
                for _, regionName in ipairs(sortedKeys(details.spawns)) do
                    local region = findRegion(regions, regionName)
                    if not region then
                        PF.log(PF.WARN, "spawn region '" .. regionName .. "' for '" .. id .. "' was not loaded")
                    else
                        region.points = region.points or {}
                        if region.points[path] and region.points[path] ~= details.spawns[regionName] then
                            PF.log(PF.ERROR, "not replacing spawn path '" .. path .. "' in '" .. regionName .. "'; B42 spawn tables discard the namespace and another definition already owns it")
                        else
                            region.points[path] = details.spawns[regionName]
                            PF.log(PF.INFO, "injected spawn points for '" .. id .. "' in '" .. regionName .. "'")
                        end
                    end
                end
            end
        end
    end
end

local function runGameStartBehavior(kind, id, details, player)
    if details.OnGameStart then
        local ok, failure = pcall(details.OnGameStart, id, player)
        if not ok then
            PF.log(PF.ERROR, "OnGameStart behavior for '" .. id .. "' failed: " .. tostring(failure))
        end
    end
end

PF.onGameStart = function()
    if isServer() then
        return
    end

    local playerCount = getNumActivePlayers and getNumActivePlayers() or 1
    for playerIndex = 0, playerCount - 1 do
        local player = getSpecificPlayer(playerIndex)
        if player then
            local dispatchedTraits = {}
            for _, id in ipairs(selectedTraitIds(player)) do
                local details = PF.Traits[id]
                if details then
                    runGameStartBehavior("trait", id, details, player)
                    dispatchedTraits[id] = true
                end
            end

            -- Legacy aliases are removed server-side during OnNewGame. Their
            -- origin marker lets an old add-on's client-only hook continue to
            -- run while the player carries the mapped vanilla trait.
            for _, id in ipairs(legacyOriginTraitIds(player)) do
                if not dispatchedTraits[id] then
                    local details = PF.Traits[id]
                    if details then
                        runGameStartBehavior("trait", id, details, player)
                    end
                end
            end

            local descriptor = player:getDescriptor()
            local profession = descriptor and descriptor:getCharacterProfession()
            if profession then
                local id = profession:toString()
                local details = PF.Professions[id]
                if details then
                    runGameStartBehavior("profession", id, details, player)
                end
            end
        end
    end
end

return PF
