-- Hunter Guilds Logic

if SERVER and _G.HunterGuildsLoaded then return end -- Prevent multiple inclusions
_G.HunterGuildsLoaded = true

include("hunter/sh_hunter_guilds_config.lua") -- Include the Hunter Guilds config

-- Ensure PromoteGuildRank is globally accessible
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
        if targetIndex < #guild.ranks then -- Ensure the target is not already at the highest rank
            target.hunterGuildRank = guild.ranks[targetIndex + 1]
            hunters[target:SteamID()].guildRank = guild.ranks[targetIndex + 1] -- Update the database
            SaveHunterData() -- Save the updated hunter data
            target:ChatPrint("You have been promoted to " .. target.hunterGuildRank .. " in the " .. target.hunterGuild .. "!")
        end
    end
end

_G.PromoteGuildRank = PromoteGuildRank -- Ensure the function is globally accessible

// Function to join a guild
function JoinGuild(ply, guildName)
    if not IsHunter(ply) then return end
    if not HunterGuildsConfig[guildName] then return end

    local guild = HunterGuildsConfig[guildName]
    ply.hunterGuild = guildName
    ply.hunterGuildRank = "Rookie" -- Set initial rank

    -- Apply tier perks first
    UpdateHunterStats(ply)

    -- Apply guild-specific perks
    ply:SetHealth(guild.benefits.health)
    ply:SetArmor(guild.benefits.armor)
    ply:SetRunSpeed(guild.benefits.speed)
    ply:ChatPrint("You have joined the " .. guildName .. " as a Rookie!")

    -- Save guild data to the database
    hunters[ply:SteamID()].guild = guildName
    hunters[ply:SteamID()].guildRank = "Rookie"
    SaveHunterData()

    -- Apply custom perks/benefits
    if guild.customPerks then
        guild.customPerks(ply)
    end
end

// Function to leave a guild
function LeaveGuild(ply)
    if not IsHunter(ply) then return end
    ply.hunterGuild = nil
    ply.hunterGuildRank = nil

    -- Reset guild-specific perks
    ply:SetArmor(0) -- Reset armor to default
    ply:SetNWFloat("GuildOfStrengthMeleeDamage", 1.0) -- Reset melee damage to default
    timer.Remove("GuildOfLightRegen_" .. ply:SteamID()) -- Remove health regeneration timer

    -- Reapply tier perks
    UpdateHunterStats(ply)

    -- Reset guild data in the database
    hunters[ply:SteamID()].guild = nil
    hunters[ply:SteamID()].guildRank = nil
    SaveHunterData()

    ply:ChatPrint("You have left your guild.")
end

// Function to get the player's guild
function GetGuild(ply)
    return ply.hunterGuild
end

// Function to get the player's guild rank
function GetGuildRank(ply)
    return ply.hunterGuildRank
end

// Function to demote a player within their guild
function DemoteGuildRank(ply, target, isAdmin)
    if not IsHunter(ply) or not ply.hunterGuild then return end
    if not IsHunter(target) or not target.hunterGuild or target.hunterGuild ~= ply.hunterGuild then return end

    local guild = HunterGuildsConfig[ply.hunterGuild]
    local playerRank = ply.hunterGuildRank
    local targetRank = target.hunterGuildRank

    local playerIndex = table.KeyFromValue(guild.ranks, playerRank)
    local targetIndex = table.KeyFromValue(guild.ranks, targetRank)

    if isAdmin or (playerIndex and targetIndex and playerIndex >= 4 and targetIndex > 1) then
        if targetIndex > 1 then -- Ensure the target is not already at the lowest rank
            target.hunterGuildRank = guild.ranks[targetIndex - 1]
            hunters[target:SteamID()].guildRank = guild.ranks[targetIndex - 1] -- Update the database
            SaveHunterData() -- Save the updated hunter data
            target:ChatPrint("You have been demoted to " .. target.hunterGuildRank .. " in the " .. target.hunterGuild .. "!")
        end
    end
end

