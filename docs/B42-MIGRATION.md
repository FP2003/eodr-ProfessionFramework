# Build 42.20 migration guide

The Build 42 port and this migration guide are authored by **Skizzo**. The
legacy Build 41 framework remains credited to **Fenris_Wolf**.

Build 42 loads this mod's `42/` package. It leaves the repository-root Build
41 package intact, so an add-on can support both builds by shipping its own
versioned directories.

Build 42 is **static first**: register every trait and profession before the
game loads script definitions. Profession Framework then attaches only runtime
behavior to definitions that already exist. It does not recreate the retired
`TraitFactory`, `ProfessionFactory`, or character-creation UI overrides.

## Consumer-mod layout

Use this structure in a dependent mod. A complete copyable fixture lives in
[`examples/build42-consumer`](../examples/build42-consumer).

```text
42/
  mod.info
  media/
    registries.lua
    scripts/MyDefinitions.txt
    lua/shared/MyBehavior.lua
    lua/shared/Translate/EN/UI.json
```

`42/mod.info` must depend on the framework's mod id, not its Steam Workshop id:

```ini
name=My Build 42 Add-on
id=MyAddon
require=ProfessionFramework
versionMin=42.20
```

### 1. Register ids

`42/media/registries.lua` is loaded before static scripts. Use canonical
`namespace:path` ids; ids are lower-cased by the game's resource system.

```lua
MyAddonRegistries = MyAddonRegistries or {}

MyAddonRegistries.Survivalist = CharacterTrait.register("MyAddon:survivalist")
MyAddonRegistries.Scout = CharacterProfession.register("MyAddon:scout")
```

### 2. Declare static definitions

Put selection-screen data in a static script, not a Lua table. The following
is a minimal trait and profession definition:

```txt
module MyAddon
{
    character_trait_definition MyAddon:survivalist
    {
        CharacterTrait = MyAddon:survivalist,
        UIName = UI_trait_MyAddon_Survivalist,
        UIDescription = UI_trait_MyAddon_SurvivalistDesc,
        Cost = 2,
        XPBoosts = Sneak=1,
    }

    character_profession_definition MyAddon:scout
    {
        CharacterProfession = MyAddon:scout,
        UIName = UI_prof_MyAddon_Scout,
        UIDescription = UI_profdesc_MyAddon_Scout,
        Cost = 0,
        IconPathName = profession_parkranger2,
        GrantedTraits = base:outdoorsman,
        XPBoosts = PlantScavenging=1;Trapping=1,
    }
}
```

Use B42 static fields for `GrantedTraits`, `GrantedRecipes`, `XPBoosts`,
`MutuallyExclusiveTraits`, point cost, labels, descriptions, icons, and
multiplayer availability. Add the translation keys to
`media/lua/shared/Translate/EN/UI.json`:

```json
{
  "UI_trait_MyAddon_Survivalist": "Survivalist",
  "UI_trait_MyAddon_SurvivalistDesc": "At home in the wilderness.",
  "UI_prof_MyAddon_Scout": "Scout",
  "UI_profdesc_MyAddon_Scout": "A practiced outdoor guide."
}
```

### 3. Attach runtime behavior

Require the B42 API from shared Lua only after the static ids exist. New code
should use `attachTraitBehavior` and `attachProfessionBehavior` explicitly.

```lua
require "ProfessionFramework/B42"

ProfessionFramework.attachTraitBehavior("MyAddon:survivalist", {
    inventory = { ["Base.Hammer"] = 1 },
    OnNewGame = function(player, square, traitId)
        -- Server / single-player only. `square` can be nil on a dedicated server.
    end,
    OnGameStart = function(traitId, player)
        -- Client presentation behavior only; do not grant items here.
    end,
})

ProfessionFramework.attachProfessionBehavior("MyAddon:scout", {
    square = { ["Base.Hammer"] = 1 },
    spawns = {
        ["Muldraugh, KY"] = {
            { position = "center" },
        },
    },
})
```

Starting-kit inventory and ground items run authoritatively on the server (or
in single-player) during `OnNewGame`. `AlwaysUseStartingKits` remains `true` by
default; set it to `false` before character creation if the sandbox
`StarterKit` setting should control those grants.

The framework validates behavior ids, item counts, spawn shapes, and duplicate
attachments. `addTrait` and `addProfession` remain as warning-emitting
compatibility aliases, but are behavior-only: they reject B41 static fields and
cannot create or alter selectable definitions.

## B41 to B42 changes

| Build 41 pattern | Build 42.20 replacement |
| --- | --- |
| `TraitFactory` / `ProfessionFactory` | `media/registries.lua` plus `character_*_definition` scripts |
| `BaseGameCharacterDetails` overrides | Static definitions; no framework UI override |
| `name`, `description`, `cost`, `icon`, `xp`, `traits`, `recipes`, `exclude` Lua fields | `UIName`, `UIDescription`, `Cost`, `IconPathName`, `XPBoosts`, `GrantedTraits`, `GrantedRecipes`, `MutuallyExclusiveTraits` in static scripts |
| `RemoveDefaultTraits` / `RemoveDefaultProfessions` | Unsupported. Build 42 keeps vanilla definitions registered. |
| `clothing`, experimental `restricted` / `required` | Unsupported by this framework. Implement a separate B42 UI system if needed. |
| `removeInMP` | Use static `DisabledInMultiplayer` for a new trait. |
| `requiresSleepEnabled` | No generic B42 extension point; do not rely on the B41 UI patch. |

`OnNewGame` behavior runs on server/single-player. `OnGameStart` runs on the
client, including each local split-screen player. Do not make client-only code
authoritative for inventories, traits, recipes, or XP.

`spawns` are inserted from `OnSpawnRegionsLoaded`. B42 spawn tables key by the
profession's *path* (for example `scout`), not its full namespace. Two mods
with the same profession path collide; the framework logs the collision and
does not overwrite the existing spawn table.

## Legacy profession traits

The package retains static bridge aliases for the B41 hidden profession traits
(`Brave2`, `SpeedDemon2`, and similar names). On first spawn, the B42 server converts
each supported alias to its matching `base:` trait and applies the trait's XP
and recipes. This keeps older dependent-mod data working while avoiding the
old dynamic factory path.

For new B42 definitions, grant the vanilla trait directly:

```txt
GrantedTraits = base:brave,
```

Do not use the bridge aliases in new content. `Lucky2` and `Unlucky2` have no
B42.20 vanilla equivalent, and the previously commented-out `Hypercondriac2`
is not provided. The supported aliases and their targets are exposed as
`ProfessionFramework.LegacyTraitAliases` and
`ProfessionFramework.LegacyTraitTargets` for migration tooling.

## Validation and smoke test

Run the repository validator against an installed 42.20 game directory:

```powershell
.\tools\validate-b42.ps1 -GameDir 'C:\steam\steamapps\common\ProjectZomboid'
```

It checks the package metadata, registry/script parity, the legacy bridge,
forbidden B41 runtime APIs, the consumer fixture, and (when `-GameDir` is
given) referenced vanilla traits and UI keys. Lua syntax is also checked in
this repository with:

```powershell
npx --yes luaparse --quiet --file .\42\media\lua\shared\ProfessionFramework\B42.lua
```

For an in-game smoke test, enable the framework and the consumer fixture,
create a new single-player character with the fixture trait/profession, then
verify that the static labels/points appear and that the starter item is
granted once. Repeat on a dedicated server to confirm ground items work when
the event's `square` argument is nil.
