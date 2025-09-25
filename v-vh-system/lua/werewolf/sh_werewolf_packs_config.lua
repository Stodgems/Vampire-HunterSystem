

WerewolfPacksConfig = {
    ["Pack of the Wild"] = {
        description = "A pack focused on raw power and primal instincts.",
        benefits = {
            speed = 320,
            health = 180,
            rageMultiplier = 1.2
        },
        ranks = {
            "Omega",
            "Pack Member",
            "Beta",
            "Elder",
            "Alpha",
            "Pack Leader"
        },
        customPerks = function(ply) 
            ply:SetJumpPower(300)
            
            if ply.werewolfTransformDuration then
                ply.werewolfTransformDuration = ply.werewolfTransformDuration * 1.2
            end
        end
    },
    ["Pack of the Moon"] = {
        description = "A pack deeply connected to lunar magic and moon phases.",
        benefits = {
            speed = 300,
            health = 160,
            rageMultiplier = 1.0,
            moonEssenceMultiplier = 1.5
        },
        ranks = {
            "Omega",
            "Pack Member", 
            "Beta",
            "Elder",
            "Alpha",
            "Pack Leader"
        },
        customPerks = function(ply)
            
            local werewolf = werewolves[ply:SteamID()]
            if werewolf then
                local moonPhase = WerewolfConfig.MoonPhases[CurrentMoonPhase]
                if moonPhase then
                    
                    local bonusMultiplier = (moonPhase.multiplier - 1.0) * 2.0 + 1.0
                    ply:SetHealth(math.floor(ply:Health() * bonusMultiplier))
                    ply:SetRunSpeed(math.floor(ply:GetRunSpeed() * bonusMultiplier))
                end
            end
        end
    },
    ["Pack of the Hunt"] = {
        description = "A pack specializing in tracking and hunting prey.",
        benefits = {
            speed = 350,
            health = 150,
            rageMultiplier = 1.1,
            trackingBonus = true
        },
        ranks = {
            "Omega",
            "Pack Member",
            "Beta", 
            "Elder",
            "Alpha",
            "Pack Leader"
        },
        customPerks = function(ply)
            
            ply:SetRunSpeed(ply:GetRunSpeed() * 1.15)
            local werewolf = werewolves[ply:SteamID()]
            if werewolf then
                
                werewolf.transformCooldownReduction = 0.25
            end
        end
    },
    ["Pack of Shadows"] = {
        description = "A stealthy pack that moves unseen through the night.",
        benefits = {
            speed = 340,
            health = 140,
            rageMultiplier = 1.0,
            stealthBonus = true
        },
        ranks = {
            "Omega",
            "Pack Member",
            "Beta",
            "Elder", 
            "Alpha",
            "Pack Leader"
        },
        customPerks = function(ply)
            
            ply:SetNoDraw(false) 
            
            local time = (CurTime() % 86400) 
            if time > 64800 or time < 21600 then 
                
                ply:SetColor(Color(255, 255, 255, 200))
            else
                ply:SetColor(Color(255, 255, 255, 255))
            end
        end
    }
}