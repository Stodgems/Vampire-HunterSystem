-- Hunter Guilds Server Logic

include("hunter/sh_hunter_guilds_config.lua") -- Include the Hunter Guilds config

util.AddNetworkString("OpenHunterGuildsMenu")
util.AddNetworkString("JoinHunterGuild")
util.AddNetworkString("LeaveHunterGuild")
util.AddNetworkString("PromoteGuildRank")
util.AddNetworkString("DemoteGuildRank")
util.AddNetworkString("RequestGuildMembers")
util.AddNetworkString("ReceiveGuildMembers")
util.AddNetworkString("KickGuildMember")

local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end

net.Receive("JoinHunterGuild", function(len, ply)
    local guildName = net.ReadString()
    JoinGuild(ply, guildName)
end)

net.Receive("LeaveHunterGuild", function(len, ply)
    LeaveGuild(ply)
end)

net.Receive("PromoteGuildRank", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        if IsAdmin(ply) then
            PromoteGuildRank(ply, target, true) -- Allow admin to promote
        else
            PromoteGuildRank(ply, target, false)
        end
    end
end)

net.Receive("DemoteGuildRank", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        if IsAdmin(ply) then
            DemoteGuildRank(ply, target, true) -- Allow admin to demote
        else
            DemoteGuildRank(ply, target, false)
        end
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
            hunters[target:SteamID()].guild = nil -- Update the database
            hunters[target:SteamID()].guildRank = nil -- Update the database
            SaveHunterData() -- Save the updated hunter data
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
                ply:SetHealth(guild.benefits.health)
                ply:SetRunSpeed(guild.benefits.speed)
            end
        end
    end
end)

hook.Add("PlayerSay", "OpenHunterGuildsMenuCommand", function(ply, text)
    if string.lower(text) == "!hguild" then
        net.Start("OpenHunterGuildsMenu")
        net.Send(ply) -- Ensure the net message is sent to the player
        return ""
    end
end)