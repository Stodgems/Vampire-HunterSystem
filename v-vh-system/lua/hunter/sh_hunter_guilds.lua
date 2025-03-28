-- Hunter Guilds Logic

if SERVER and _G.HunterGuildsLoaded then return end
_G.HunterGuildsLoaded = true

include("hunter/sh_hunter_guilds_config.lua")

function PromoteGuildRank(ply, target, isAdmin)
    if not IsHunter(ply) or not ply.hunterGuild then
        return
    end

    if not IsHunter(target) or not target.hunterGuild or target.hunterGuild ~= ply.hunterGuild then
        return
    end

    local guild = HunterGuildsConfig[ply.hunterGuild]
    if not guild then
        return
    end

    local playerRank = ply.hunterGuildRank
    local targetRank = target.hunterGuildRank

    local playerIndex = table.KeyFromValue(guild.ranks, playerRank)
    local targetIndex = table.KeyFromValue(guild.ranks, targetRank)

    if not playerIndex or not targetIndex then
        return
    end

    if isAdmin or (playerIndex >= 4 and targetIndex < playerIndex) then
        if targetIndex < #guild.ranks then
            target.hunterGuildRank = guild.ranks[targetIndex + 1]
            hunters[target:SteamID()].guildRank = guild.ranks[targetIndex + 1]
            SaveHunterData()
            target:ChatPrint("You have been promoted to " .. target.hunterGuildRank .. " in the " .. target.hunterGuild .. "!")
        end
    end
end

_G.PromoteGuildRank = PromoteGuildRank

// Function to join a guild
function JoinGuild(ply, guildName)
    if not IsHunter(ply) then return end
    if not HunterGuildsConfig[guildName] then return end

    local guild = HunterGuildsConfig[guildName]
    ply.hunterGuild = guildName
    ply.hunterGuildRank = "Rookie"

    UpdateHunterStats(ply)

    ply:SetHealth(guild.benefits.health)
    ply:SetArmor(guild.benefits.armor)
    ply:SetRunSpeed(guild.benefits.speed)
    ply:ChatPrint("You have joined the " .. guildName .. " as a Rookie!")

    hunters[ply:SteamID()].guild = guildName
    hunters[ply:SteamID()].guildRank = "Rookie"
    SaveHunterData()

    if guild.customPerks then
        guild.customPerks(ply)
    end
end

function LeaveGuild(ply)
    if not IsHunter(ply) then return end
    ply.hunterGuild = nil
    ply.hunterGuildRank = nil

    ply:SetArmor(0)
    ply:SetNWFloat("GuildOfStrengthMeleeDamage", 1.0)
    timer.Remove("GuildOfLightRegen_" .. ply:SteamID())

    UpdateHunterStats(ply)

    hunters[ply:SteamID()].guild = nil
    hunters[ply:SteamID()].guildRank = nil
    SaveHunterData()

    ply:ChatPrint("You have left your guild.")
end

function GetGuild(ply)
    return ply.hunterGuild
end

function GetGuildRank(ply)
    return ply.hunterGuildRank
end

function DemoteGuildRank(ply, target, isAdmin)
    if not IsHunter(ply) or not ply.hunterGuild then return end
    if not IsHunter(target) or not target.hunterGuild or target.hunterGuild ~= ply.hunterGuild then return end

    local guild = HunterGuildsConfig[ply.hunterGuild]
    local playerRank = ply.hunterGuildRank
    local targetRank = target.hunterGuildRank

    local playerIndex = table.KeyFromValue(guild.ranks, playerRank)
    local targetIndex = table.KeyFromValue(guild.ranks, targetRank)

    if isAdmin or (playerIndex and targetIndex and playerIndex >= 4 and targetIndex > 1) then
        if targetIndex > 1 then
            target.hunterGuildRank = guild.ranks[targetIndex - 1]
            hunters[target:SteamID()].guildRank = guild.ranks[targetIndex - 1]
            SaveHunterData()
            target:ChatPrint("You have been demoted to " .. target.hunterGuildRank .. " in the " .. target.hunterGuild .. "!")
        end
    end
end

