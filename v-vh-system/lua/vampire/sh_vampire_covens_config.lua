

VampireCovensConfig = {
    ["Coven of Blood"] = {
        description = "A coven focused on blood magic and power.",
        benefits = {
            speed = 300,
            health = 200,
            armor = 50
        },
        ranks = {
            "Initiate",
            "Acolyte",
            "Blood Mage",
            "Elder",
            "High Priest",
            "Lord of Blood"
        },
        customPerks = function(ply) 
            timer.Create("CovenOfBloodRegen_" .. ply:SteamID(), 10, 0, function()
                if IsValid(ply) and ply:Health() < ply:GetMaxHealth() then
                    ply:SetHealth(math.min(ply:Health() + 10, ply:GetMaxHealth()))
                end
            end)
        end
    },
    ["Coven of Shadows"] = {
        description = "A coven focused on stealth and assassination.",
        benefits = {
            speed = 350,
            health = 150,
            armor = 25
        },
        ranks = {
            "Initiate",
            "Acolyte",
            "Shadow Mage",
            "Elder",
            "High Priest",
            "Lord of Shadows"
        },
        customPerks = function(ply)
            ply:SetJumpPower(300)
        end
    },
    ["Coven of Strength"] = {
        description = "A coven focused on brute strength and combat.",
        benefits = {
            speed = 250,
            health = 250,
            armor = 75
        },
        ranks = {
            "Initiate",
            "Acolyte",
            "Warrior Mage",
            "Elder",
            "High Priest",
            "Lord of Strength"
        },
        customPerks = function(ply)
            ply:SetNWFloat("CovenOfStrengthMeleeDamage", 1.5)
        end
    }
}
