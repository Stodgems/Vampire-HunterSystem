

WerewolfConfig = {
    Tiers = {
        ["Pup"] = { health = 120, speed = 280, model = nil, threshold = 0 },
        ["Young Wolf"] = { health = 160, speed = 320, model = nil, threshold = 3000 },
        ["Wolf"] = { health = 200, speed = 360, model = nil, threshold = 8000 },
        ["Beta Wolf"] = { health = 250, speed = 400, model = nil, threshold = 20000 },
        ["Alpha Wolf"] = { health = 300, speed = 450, model = nil, threshold = 40000 },
        ["Pack Leader"] = { health = 350, speed = 500, model = nil, threshold = 75000 },
        ["Lycanthrope Lord"] = { health = 450, speed = 600, model = nil, threshold = 150000 }
    },
    
    
    MoonPhases = {
        ["New Moon"] = { 
            multiplier = 0.8, 
            description = "Weakest phase - reduced abilities" 
        },
        ["Waxing Crescent"] = { 
            multiplier = 0.9, 
            description = "Growing strength" 
        },
        ["First Quarter"] = { 
            multiplier = 1.0, 
            description = "Balanced power" 
        },
        ["Waxing Gibbous"] = { 
            multiplier = 1.1, 
            description = "Increasing power" 
        },
        ["Full Moon"] = { 
            multiplier = 1.5, 
            description = "Peak power - maximum abilities" 
        },
        ["Waning Gibbous"] = { 
            multiplier = 1.1, 
            description = "High power" 
        },
        ["Last Quarter"] = { 
            multiplier = 1.0, 
            description = "Balanced power" 
        },
        ["Waning Crescent"] = { 
            multiplier = 0.9, 
            description = "Diminishing power" 
        }
    },
    
    
    Transformation = {
        duration = 30, 
        cooldown = 120, 
        rageGain = 20, 
        rageDecay = 1, 
        maxRage = 100
    }
}