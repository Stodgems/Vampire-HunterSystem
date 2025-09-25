

include("config/sh_global_config.lua")

local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end

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
