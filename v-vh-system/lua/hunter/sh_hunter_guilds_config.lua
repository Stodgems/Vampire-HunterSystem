-- Hunter Guilds Configuration

HunterGuildsConfig = {
    ["Guild of Shadows"] = {
        description = "A guild focused on stealth and assassination.",
        benefits = {
            speed = 350,
            health = 150,
            armor = 50 -- Extra armor benefit
        },
        ranks = {
            "Rookie",
            "Hunter",
            "Experienced",
            "Leader",
            "Commander",
            "Lord"
        },
        customPerks = function(ply)
            -- Example custom perk: Increase jump power
            ply:SetJumpPower(300)
        end
    },
    ["Guild of Light"] = {
        description = "A guild focused on healing and support.",
        benefits = {
            speed = 300,
            health = 200,
            armor = 75 -- Extra armor benefit
        },
        ranks = {
            "Rookie",
            "Hunter",
            "Experienced",
            "Leader",
            "Commander",
            "Lord"
        },
        customPerks = function(ply)
            -- Example custom perk: Regenerate health over time
            timer.Create("GuildOfLightRegen_" .. ply:SteamID(), 10, 0, function()
                if IsValid(ply) and ply:Health() < ply:GetMaxHealth() then
                    ply:SetHealth(math.min(ply:Health() + 10, ply:GetMaxHealth()))
                end
            end)
        end
    },
    ["Guild of Strength"] = {
        description = "A guild focused on brute strength and combat.",
        benefits = {
            speed = 250,
            health = 250,
            armor = 100 -- Extra armor benefit
        },
        ranks = {
            "Rookie",
            "Hunter",
            "Experienced",
            "Leader",
            "Commander",
            "Lord"
        },
        customPerks = function(ply)
            -- Example custom perk: Increase melee damage
            ply:SetNWFloat("GuildOfStrengthMeleeDamage", 1.5)
        end
    }
}
