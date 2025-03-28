-- Hunter Guilds Server Logic

include("hunter/sh_hunter_guilds_config.lua")
include("hunter/sh_hunter_guilds.lua")

util.AddNetworkString("OpenHunterGuildsMenu")
util.AddNetworkString("JoinHunterGuild")
util.AddNetworkString("LeaveHunterGuild")
util.AddNetworkString("PromoteGuildRank")
util.AddNetworkString("DemoteGuildRank")
util.AddNetworkString("RequestGuildMembers")
util.AddNetworkString("ReceiveGuildMembers")
util.AddNetworkString("KickGuildMember")
util.AddNetworkString("SyncHunterGuild")

local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end

local function SyncPlayerGuildData(ply)
    if IsHunter(ply) and ply.hunterGuild then
        local guild = HunterGuildsConfig[ply.hunterGuild]
        ply.hunterGuildRank = ply.hunterGuildRank or "Rookie"
        if IsAdmin(ply) then
            ply:ChatPrint("As an admin, you have full control over guild ranks.")
        end
    end
end

net.Receive("JoinHunterGuild", function(len, ply)
    local guildName = net.ReadString()
    JoinGuild(ply, guildName)

    SyncPlayerGuildData(ply)
end)

net.Receive("LeaveHunterGuild", function(len, ply)
    LeaveGuild(ply)
end)

net.Receive("PromoteGuildRank", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)

    if target then
        if IsAdmin(ply) then
            _G.PromoteGuildRank(ply, target, true)
        else
            _G.PromoteGuildRank(ply, target, false)
        end
    end
end)

net.Receive("DemoteGuildRank", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    print("[DEBUG] DemoteGuildRank called by " .. ply:Nick() .. " for target " .. (target and target:Nick() or "nil"))

    if target then
        if IsAdmin(ply) then
            print("[DEBUG] " .. ply:Nick() .. " is an admin. Proceeding with demotion.")
            DemoteGuildRank(ply, target, true)
        else
            print("[DEBUG] " .. ply:Nick() .. " is not an admin. Checking rank permissions.")
            DemoteGuildRank(ply, target, false)
        end
    else
        print("[DEBUG] Target player not found.")
    end
end)

net.Receive("KickGuildMember", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        local guild = HunterGuildsConfig[ply.hunterGuild]
        local playerRank = ply.hunterGuildRank
        local playerIndex = table.KeyFromValue(guild.ranks, playerRank)
        if IsAdmin(ply) or (playerIndex and playerIndex >= 4) then
            LeaveGuild(target)
            if ply.hunterGuild then
                target:ChatPrint("You have been kicked from the " .. ply.hunterGuild .. " guild.")
            else
                target:ChatPrint("You have been kicked from the guild.")
            end

            hunters[target:SteamID()].guild = nil
            hunters[target:SteamID()].guildRank = nil
            SaveHunterData()
        end
    end
end)

net.Receive("RequestGuildMembers", function(len, ply)
    local guildName = net.ReadString()
    local guildMembers = {}

    local result = sql.Query("SELECT steamID, guildRank FROM hunter_data WHERE guild = " .. sql.SQLStr(guildName))
    if result then
        for _, row in ipairs(result) do
            local member = player.GetBySteamID(row.steamID)
            if member then
                table.insert(guildMembers, {name = member:Nick(), rank = row.guildRank})
            end
        end
    end

    net.Start("ReceiveGuildMembers")
    net.WriteTable(guildMembers)
    net.Send(ply)
end)

hook.Add("PlayerInitialSpawn", "SyncHunterGuilds", function(ply)
    if IsHunter(ply) and ply.hunterGuild then
        local guild = HunterGuildsConfig[ply.hunterGuild]
        ply:SetHealth(guild.benefits.health)
        ply:SetRunSpeed(guild.benefits.speed)
        SyncPlayerGuildData(ply)
    end
end)

hook.Add("PlayerSpawn", "SetHunterGuildOnSpawn", function(ply)
    if IsHunter(ply) then
        local hunterData = hunters[ply:SteamID()]
        if hunterData and hunterData.guild and hunterData.guild ~= "" then
            local guild = HunterGuildsConfig[hunterData.guild]
            if guild then
                ply.hunterGuild = hunterData.guild
                ply.hunterGuildRank = hunterData.guildRank or "Rookie"

                UpdateHunterStats(ply)

                ply:SetHealth(guild.benefits.health)
                ply:SetArmor(guild.benefits.armor)
                ply:SetRunSpeed(guild.benefits.speed)

                if guild.customPerks then
                    guild.customPerks(ply)
                end

                SyncPlayerGuildData(ply)
            end
        end
    end
end)

hook.Add("PlayerSay", "OpenHunterGuildsMenuCommand", function(ply, text)
    if string.lower(text) == "!hguild" then
        if not IsHunter(ply) then
            ply:ChatPrint("Only hunters can access the guild menu.")
            return ""
        end
        net.Start("OpenHunterGuildsMenu")
        net.Send(ply)
        return ""
    end
end)