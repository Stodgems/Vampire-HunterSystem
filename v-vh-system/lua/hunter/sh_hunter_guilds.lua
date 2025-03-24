-- Hunter Guilds Logic

include("hunter/sh_hunter_guilds_config.lua") -- Include the Hunter Guilds config

// Function to join a guild
function JoinGuild(ply, guildName)
    if not IsHunter(ply) then return end
    if not HunterGuildsConfig[guildName] then return end

    local guild = HunterGuildsConfig[guildName]
    ply.hunterGuild = guildName
    ply.hunterGuildRank = "Rookie" -- Set initial rank
    ply:SetHealth(guild.benefits.health)
    ply:SetRunSpeed(guild.benefits.speed)
    ply:ChatPrint("You have joined the " .. guildName .. " as a Rookie!")

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
    ply:SetHealth(100)
    ply:SetRunSpeed(250)
    ply:SetJumpPower(200) -- Reset jump power to default
    ply:SetNWFloat("GuildOfStrengthMeleeDamage", 1.0) -- Reset melee damage to default
    timer.Remove("GuildOfLightRegen_" .. ply:SteamID()) -- Remove health regeneration timer
    ply:ChatPrint("You have left your guild.")
    hunters[ply:SteamID()].guild = nil -- Update the database
    hunters[ply:SteamID()].guildRank = nil -- Update the database
    SaveHunterData() -- Save the updated hunter data
end

// Function to get the player's guild
function GetGuild(ply)
    return ply.hunterGuild
end

// Function to get the player's guild rank
function GetGuildRank(ply)
    return ply.hunterGuildRank
end

// Function to promote a player within their guild
function PromoteGuildRank(ply, target, isAdmin)
    if not IsHunter(ply) or not ply.hunterGuild then return end
    if not IsHunter(target) or not target.hunterGuild or target.hunterGuild ~= ply.hunterGuild then return end

    local guild = HunterGuildsConfig[ply.hunterGuild]
    local playerRank = ply.hunterGuildRank
    local targetRank = target.hunterGuildRank

    local playerIndex = table.KeyFromValue(guild.ranks, playerRank)
    local targetIndex = table.KeyFromValue(guild.ranks, targetRank)

    if isAdmin or (playerIndex and targetIndex and playerIndex >= 4 and targetIndex < playerIndex) then
        if targetIndex < #guild.ranks then -- Ensure the target is not already at the highest rank
            target.hunterGuildRank = guild.ranks[targetIndex + 1]
            hunters[target:SteamID()].guildRank = guild.ranks[targetIndex + 1] -- Update the database
            SaveHunterData() -- Save the updated hunter data
            target:ChatPrint("You have been promoted to " .. target.hunterGuildRank .. " in the " .. target.hunterGuild .. "!")
        end
    end
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

