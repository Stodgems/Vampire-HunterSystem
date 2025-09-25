

HybridConfig = {
    Tiers = {
        ["Cursed"] = { 
            health = 140, 
            speed = 290, 
            model = nil, 
            bloodThreshold = 1000,
            rageThreshold = 1000,
            totalThreshold = 2000
        },
        ["Conflicted"] = { 
            health = 180, 
            speed = 330, 
            model = nil, 
            bloodThreshold = 3000,
            rageThreshold = 3000,
            totalThreshold = 6000
        },
        ["Awakened"] = { 
            health = 220, 
            speed = 370, 
            model = nil, 
            bloodThreshold = 6000,
            rageThreshold = 6000,
            totalThreshold = 12000
        },
        ["Dual Soul"] = { 
            health = 270, 
            speed = 420, 
            model = nil, 
            bloodThreshold = 12000,
            rageThreshold = 12000,
            totalThreshold = 24000
        },
        ["Eclipse Walker"] = { 
            health = 320, 
            speed = 470, 
            model = nil, 
            bloodThreshold = 20000,
            rageThreshold = 20000,
            totalThreshold = 40000
        },
        ["Apex Hybrid"] = { 
            health = 380, 
            speed = 530, 
            model = nil, 
            bloodThreshold = 35000,
            rageThreshold = 35000,
            totalThreshold = 70000
        },
        ["Primordial"] = { 
            health = 500, 
            speed = 650, 
            model = nil, 
            bloodThreshold = 60000,
            rageThreshold = 60000,
            totalThreshold = 120000
        }
    },
    
    
    DualNature = {
        
        maxBalance = 100, 
        
        
        vampireLeaning = {
            threshold = -50,
            description = "Vampire nature dominates",
            effects = {
                bloodEfficiency = 1.5,
                moonResistance = true,
                sunWeakness = true,
                rageDecayBonus = 2.0
            }
        },
        
        balanced = {
            threshold_min = -49,
            threshold_max = 49,
            description = "Perfect balance between natures",
            effects = {
                dualTransformation = true,
                resistanceBonus = 1.2,
                versatility = true
            }
        },
        
        werewolfLeaning = {
            threshold = 50,
            description = "Werewolf nature dominates",
            effects = {
                moonPowerBonus = 1.5,
                packBonuses = true,
                bloodHunger = true,
                transformationDurationBonus = 1.3
            }
        }
    },
    
    
    Transformations = {
        vampireForm = {
            duration = 25,
            cooldown = 90,
            requirements = { balance = "vampire" },
            effects = {
                healthMultiplier = 1.4,
                speedMultiplier = 1.3,
                bloodDrainBonus = 2.0,
                nightVision = true
            }
        },
        
        werewolfForm = {
            duration = 25,
            cooldown = 90,
            requirements = { balance = "werewolf" },
            effects = {
                healthMultiplier = 1.6,
                speedMultiplier = 1.5,
                clawDamageBonus = 2.0,
                packSense = true
            }
        },
        
        eclipseForm = {
            duration = 20,
            cooldown = 180,
            requirements = { balance = "balanced", tier = "Eclipse Walker" },
            effects = {
                healthMultiplier = 2.0,
                speedMultiplier = 1.8,
                allAbilitiesBonus = 2.5,
                fearAura = true,
                energyDrain = true 
            }
        }
    },
    
    
    Abilities = {
        bloodRage = {
            name = "Blood Rage",
            description = "Channel blood to fuel rage",
            unlockTier = "Conflicted",
            cost = { blood = 20, rage = 10 },
            effect = "converts blood to rage with bonus efficiency"
        },
        
        lunarThirst = {
            name = "Lunar Thirst", 
            description = "Moon phases affect blood potency",
            unlockTier = "Awakened",
            effect = "blood gain varies with moon phase"
        },
        
        dualSense = {
            name = "Dual Sense",
            description = "Can sense both vampires and werewolves",
            unlockTier = "Dual Soul",
            effect = "shows vampire and werewolf players on minimap"
        },
        
        eclipsePower = {
            name = "Eclipse Power",
            description = "Massive power boost during solar/lunar eclipse",
            unlockTier = "Eclipse Walker",
            effect = "temporary godlike abilities during eclipse events"
        },
        
        primordialDominance = {
            name = "Primordial Dominance",
            description = "Can command lesser vampires and werewolves",
            unlockTier = "Primordial",
            effect = "mind control abilities over lower tier creatures"
        }
    },
    
    
    BalanceShifts = {
        bloodDrain = { vampire = 2, werewolf = -1 },
        moonEssenceGain = { vampire = -1, werewolf = 2 },
        killVampire = { vampire = -5, werewolf = 3 },
        killWerewolf = { vampire = 3, werewolf = -5 },
        killHunter = { vampire = 1, werewolf = 1 },
        fullMoon = { vampire = -2, werewolf = 2 },
        newMoon = { vampire = 2, werewolf = -2 },
        dayTime = { vampire = -1, werewolf = 0 },
        nightTime = { vampire = 1, werewolf = 0 }
    },
    
    
    Resources = {
        bloodDecay = 0.5, 
        rageDecay = 1.0,  
        dualEssence = {
            maxAmount = 50,
            conversionRate = 10, 
            gainRate = 1 
        }
    }
}