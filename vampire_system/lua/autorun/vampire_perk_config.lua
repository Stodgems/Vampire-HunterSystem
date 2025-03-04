-- Vampire Perk Configuration

VampirePerkConfig = {
    Perks = {
        ["Night Vision"] = { cost = 1000, func = function(ply) print(ply:Nick() .. " purchased Night Vision") end, requires = nil },
        ["Super Speed"] = { cost = 2000, func = function(ply) print(ply:Nick() .. " purchased Super Speed") end, requires = "Night Vision" },
        ["Invisibility"] = { cost = 3000, func = function(ply) print(ply:Nick() .. " purchased Invisibility") end, requires = "Super Speed" },
        ["Teleportation"] = { cost = 4000, func = function(ply) print(ply:Nick() .. " purchased Teleportation") end, requires = "Invisibility" },
        ["Mind Control"] = { cost = 5000, func = function(ply) print(ply:Nick() .. " purchased Mind Control") end, requires = "Teleportation" }
    },
    AllowedAdminRanks = {
        "superadmin",
        "admin",
        "moderator"
    }
}
