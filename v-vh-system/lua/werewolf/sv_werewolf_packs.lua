

include("werewolf/sh_werewolf_packs_config.lua")
include("werewolf/sh_werewolf_packs.lua")

util.AddNetworkString("OpenWerewolfPacksMenu")
util.AddNetworkString("JoinWerewolfPack")
util.AddNetworkString("LeaveWerewolfPack")
util.AddNetworkString("PromotePackRank")
util.AddNetworkString("DemotePackRank")
util.AddNetworkString("RequestPackMembers")
util.AddNetworkString("ReceivePackMembers")
util.AddNetworkString("KickPackMember")
util.AddNetworkString("SyncWerewolfPack")

local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end

local function SyncPlayerPackData(ply)
    if IsWerewolf(ply) and ply.werewolfPack then
        local pack = WerewolfPacksConfig[ply.werewolfPack]
        ply.werewolfPackRank = ply.werewolfPackRank or "Omega"
        if IsAdmin(ply) then
            ply:ChatPrint("As an admin, you have full control over pack ranks.")
        end
    end
end

net.Receive("JoinWerewolfPack", function(len, ply)
    local packName = net.ReadString()
    JoinPack(ply, packName)
    
    SyncPlayerPackData(ply)
end)

net.Receive("LeaveWerewolfPack", function(len, ply)
    LeavePack(ply)
end)

net.Receive("PromotePackRank", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)

    if target then
        if IsAdmin(ply) then
            _G.PromotePackRank(ply, target, true)
        else
            _G.PromotePackRank(ply, target, false)
        end
    end
end)

net.Receive("DemotePackRank", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    print("[DEBUG] DemotePackRank called by " .. ply:Nick() .. " for target " .. (target and target:Nick() or "nil"))

    if target then
        if IsAdmin(ply) then
            print("[DEBUG] " .. ply:Nick() .. " is an admin. Proceeding with demotion.")
            DemotePackRank(ply, target, true)
        else
            print("[DEBUG] " .. ply:Nick() .. " is not an admin. Checking rank permissions.")
            DemotePackRank(ply, target, false)
        end
    else
        print("[DEBUG] Target player not found.")
    end
end)

net.Receive("KickPackMember", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        local pack = WerewolfPacksConfig[ply.werewolfPack]
        local playerRank = ply.werewolfPackRank
        local playerIndex = table.KeyFromValue(pack.ranks, playerRank)
        if IsAdmin(ply) or (playerIndex and playerIndex >= 4) then
            LeavePack(target)
            if ply.werewolfPack then
                target:ChatPrint("You have been kicked from the " .. ply.werewolfPack .. " pack.")
            else
                target:ChatPrint("You have been kicked from the pack.")
            end

            werewolves[target:SteamID()].pack = ""
            werewolves[target:SteamID()].packRank = ""
            SaveWerewolfData()
        end
    end
end)

net.Receive("RequestPackMembers", function(len, ply)
    local packName = net.ReadString()
    local packMembers = {}

    local result = sql.Query("SELECT steamID, packRank FROM werewolf_data WHERE pack = " .. sql.SQLStr(packName))
    if result then
        for _, row in ipairs(result) do
            local sid = row.steamID
            local member = player.GetBySteamID(sid)
            if member then
                table.insert(packMembers, {name = member:Nick(), rank = row.packRank, steamID = sid})
            else
                
                table.insert(packMembers, {name = sid, rank = row.packRank, steamID = sid})
            end
        end
    end

    net.Start("ReceivePackMembers")
    net.WriteTable(packMembers)
    net.Send(ply)
end)

hook.Add("PlayerInitialSpawn", "SyncWerewolfPacks", function(ply)
    if IsWerewolf(ply) and ply.werewolfPack then
        local pack = WerewolfPacksConfig[ply.werewolfPack]
        ply:SetHealth(pack.benefits.health)
        ply:SetRunSpeed(pack.benefits.speed)
        SyncPlayerPackData(ply)
    end
end)

hook.Add("PlayerSpawn", "SetWerewolfPackOnSpawn", function(ply)
    if IsWerewolf(ply) then
        local werewolfData = werewolves[ply:SteamID()]
        if werewolfData and werewolfData.pack and werewolfData.pack ~= "" then
            local pack = WerewolfPacksConfig[werewolfData.pack]
            if pack then
                ply.werewolfPack = werewolfData.pack
                ply.werewolfPackRank = werewolfData.packRank or "Omega"

                UpdateWerewolfStats(ply)

                ply:SetHealth(pack.benefits.health)
                ply:SetRunSpeed(pack.benefits.speed)

                if pack.customPerks then
                    pack.customPerks(ply)
                end

                SyncPlayerPackData(ply)
            end
        end
    end
end)

hook.Add("PlayerSay", "OpenWerewolfPacksMenuCommand", function(ply, text)
    if string.lower(text) == "!wpack" then
        if not IsWerewolf(ply) then
            ply:ChatPrint("Only werewolves can access the pack menu.")
            return ""
        end
        net.Start("OpenWerewolfPacksMenu")
        net.Send(ply)
        return ""
    end
end)