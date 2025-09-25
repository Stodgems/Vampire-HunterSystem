

include("config/sh_global_config.lua")

local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end

concommand.Add("make_vampire", function(ply, cmd, args)
    if not IsAdmin(ply) then return end
    local target = args[1]
    local targetPlayer = player.GetBySteamID(target)
    if targetPlayer then
        if IsHunter(targetPlayer) then
            RemoveHunter(targetPlayer)
        end
        MakeVampire(targetPlayer)
    else
        ply:ChatPrint("Player not found.")
    end
end)

concommand.Add("add_blood", function(ply, cmd, args)
    if not IsAdmin(ply) then return end
    local target = args[1]
    local amount = tonumber(args[2])
    local targetPlayer = player.GetBySteamID(target)
    if targetPlayer and amount then
        AddBlood(targetPlayer, amount)
    else
        ply:ChatPrint("Invalid arguments.")
    end
end)

concommand.Add("drain_blood", function(ply, cmd, args)
    if not IsAdmin(ply) then return end
    local target = args[1]
    local amount = tonumber(args[2])
    local targetEntity = Entity(tonumber(target))
    if targetEntity and amount then
        local rate = targetEntity:IsPlayer() and 100 or 50
        local maxAmount = targetEntity:IsPlayer() and 1000 or 500
        DrainBlood(ply, targetEntity, math.min(amount, maxAmount), rate)
    else
        ply:ChatPrint("Invalid arguments.")
    end
end)