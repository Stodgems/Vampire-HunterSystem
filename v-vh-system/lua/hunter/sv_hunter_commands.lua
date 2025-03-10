-- Hunter Commands

include("config/sh_global_config.lua")

-- Function to check if a player is an admin
local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end

-- Command to turn a player into a hunter
concommand.Add("make_hunter", function(ply, cmd, args)
    if not IsAdmin(ply) then return end
    local target = args[1]
    local targetPlayer = player.GetBySteamID(target)
    if targetPlayer then
        if IsVampire(targetPlayer) then
            RemoveVampire(targetPlayer)
        end
        MakeHunter(targetPlayer)
    else
        ply:ChatPrint("Player not found.")
    end
end)

-- Command to add experience to a hunter
concommand.Add("add_experience", function(ply, cmd, args)
    if not IsAdmin(ply) then return end
    local target = args[1]
    local amount = tonumber(args[2])
    local targetPlayer = player.GetBySteamID(target)
    if targetPlayer and amount then
        AddExperience(targetPlayer, amount)
    else
        ply:ChatPrint("Invalid arguments.")
    end
end)
