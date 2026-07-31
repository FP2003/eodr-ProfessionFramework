require "ProfessionFramework/B42"

-- Static definition data belongs in PFBuild42Consumer.txt. This file only
-- adds behavior that must run after a new character enters the world.
ProfessionFramework.attachTraitBehavior("PFBuild42Consumer:survivalist", {
    inventory = {
        ["Base.Hammer"] = 1,
    },
})

ProfessionFramework.attachProfessionBehavior("PFBuild42Consumer:scout", {
    square = {
        ["Base.Hammer"] = 1,
    },
    spawns = {
        ["Muldraugh, KY"] = {
            { position = "center" },
        },
    },
})
