-- Hunter Utility Functions

include("hunter/sh_hunter_config.lua")
include("hunter/sh_hunter_guilds.lua") -- Include the Hunter Guilds logic

-- Initialize the hunters table
if SERVER then
    hunters = hunters or {}
    util.AddNetworkString("SyncHunterData")
    util.AddNetworkString("NewHunterTierMessage")
    util.AddNetworkString("UpdateHunterHUD")
else
    hunters = hunters or {}
    net.Receive("SyncHunterData", function()
        hunters = net.ReadTable()
    end)
end

-- Function to save hunter data to the SQLite database
function SaveHunterData()
    for steamID, data in pairs(hunters) do
        local query = string.format("REPLACE INTO hunter_data (steamID, experience, tier, hearts, weapons, guild, guildRank) VALUES ('%s', %d, '%s', %d, '%s', '%s', '%s')", steamID, data.experience, data.tier, data.hearts or 0, table.concat(data.weapons or {}, ","), data.guild or "", data.guildRank or "")
        sql.Query(query)
    end
end

-- Function to remove hunter data from the SQLite database
local function RemoveHunterData(steamID)
    local query = string.format("DELETE FROM hunter_data WHERE steamID = '%s'", steamID)
    sql.Query(query)
    sql.Query(string.format("DELETE FROM purchased_items WHERE steamID = %s", sql.SQLStr(steamID))) -- Remove purchased items
end

-- Function to load hunter data from the SQLite database
local function LoadHunterData()
    if not sql.TableExists("hunter_data") then
        sql.Query("CREATE TABLE hunter_data (steamID TEXT PRIMARY KEY, experience INTEGER, tier TEXT, hearts INTEGER, weapons TEXT, guild TEXT, guildRank TEXT)")
    end

    local result = sql.Query("SELECT * FROM hunter_data")
    if result then
        for _, row in ipairs(result) do
            hunters[row.steamID] = { experience = tonumber(row.experience), tier = row.tier, hearts = tonumber(row.hearts) or 0, weapons = string.Explode(",", row.weapons or ""), guild = row.guild or "", guildRank = row.guildRank or "" }
        end
    end
end

-- Function to sync hunter data with clients
function SyncHunterData()
    if SERVER then
        if timer.Exists("SyncHunterDataTimer") then return end
        timer.Create("SyncHunterDataTimer", 1, 1, function()
            net.Start("SyncHunterData")
            net.WriteTable(hunters)
            net.Broadcast()
        end)
    end
end

-- Function to give hunter weapons
local function GiveHunterWeapons(ply)
    ply:Give("weapon_stake")
end

-- Function to turn a player into a hunter
function MakeHunter(ply)
    if not ply:IsPlayer() then return end
    if IsVampire(ply) then
        RemoveVampire(ply)
    end
    hunters[ply:SteamID()] = { experience = 0, tier = "Novice", hearts = 0, weapons = {} }
    UpdateHunterStats(ply)
    ply:ChatPrint("You have been turned into a hunter!")
    GiveHunterWeapons(ply)
    SaveHunterData()
    SyncHunterData()
    if SERVER then
        UpdateHunterHUD(ply)
    end
end

-- Function to remove a player from being a hunter
function RemoveHunter(ply)
    if not ply:IsPlayer() then return end
    hunters[ply:SteamID()] = nil
    RemoveHunterData(ply:SteamID())
    ResetHunterPerks(ply)
    LeaveGuild(ply) -- Ensure the player leaves their guild
    SyncHunterData()
    ply:ChatPrint("You have been removed from the hunter system!")
    SaveHunterData()
    UpdateHunterHUD(ply)
end

-- Function to reset all perks for a player
function ResetHunterPerks(ply)
    ply:SetRunSpeed(250) -- Reset to default speed
    ply:SetHealth(100) -- Reset to default health
    ply:ConCommand("pp_mat_overlay ''") -- Reset night vision
end

-- Function to check if a player is a hunter
function IsHunter(ply)
    return hunters[ply:SteamID()] ~= nil
end

-- Function to update hunter stats based on their tier
function UpdateHunterStats(ply)
    local hunter = hunters[ply:SteamID()]
    if not hunter then return end

    local tier = hunter.tier
    local config = HunterConfig.Tiers[tier]

    ply:SetHealth(config.health)
    ply:SetRunSpeed(config.speed)

    if config.model then
        ply:SetModel(config.model)
    else
        local jobModel = ply:getJobTable().model
        if istable(jobModel) then
            ply:SetModel(jobModel[1])
        else
            ply:SetModel(jobModel)
        end
    end

    if SERVER then
        UpdateHunterHUD(ply)
    end
end

-- Function to add experience to a hunter
function AddExperience(ply, amount)
    if not IsHunter(ply) then return end
    local hunter = hunters[ply:SteamID()]
    hunter.experience = hunter.experience + amount

    -- Update tier based on experience level
    local newTier = hunter.tier
    for tier, config in SortedPairsByMemberValue(HunterConfig.Tiers, "threshold", true) do
        if hunter.experience >= config.threshold then
            newTier = tier
            break
        end
    end

    if newTier ~= hunter.tier then
        hunter.tier = newTier
        UpdateHunterStats(ply)
        net.Start("NewHunterTierMessage")
        net.WriteString("You have reached a new tier: " .. hunter.tier)
        net.Send(ply)
    end

    SaveHunterData()
    SyncHunterData()
    if SERVER then
        UpdateHunterHUD(ply)
    end
end

-- Function to add a vampire heart to a hunter
function AddVampireHeart(ply)
    if not IsHunter(ply) then return end
    local hunter = hunters[ply:SteamID()]
    hunter.hearts = (hunter.hearts or 0) + 1
    SaveHunterData()
    SyncHunterData()
    if SERVER then
        UpdateHunterHUD(ply)
    end
end

-- Function to update the hunter HUD
if SERVER then
    function UpdateHunterHUD(ply)
        if not IsHunter(ply) then return end
        local hunter = hunters[ply:SteamID()]
        net.Start("UpdateHunterHUD")
        net.WriteInt(hunter.experience, 32)
        net.WriteString(hunter.tier)
        net.WriteInt(hunter.hearts or 0, 32)
        net.Send(ply)
    end
end

-- Function to join a guild
function JoinGuild(ply, guildName)
    if not IsHunter(ply) then return end
    if not HunterGuildsConfig[guildName] then return end

    local guild = HunterGuildsConfig[guildName]
    ply.hunterGuild = guildName
    ply.hunterGuildRank = "Rookie" -- Set initial rank
    hunters[ply:SteamID()].guild = guildName -- Save the guild in the hunter data
    hunters[ply:SteamID()].guildRank = "Rookie" -- Save the guild rank in the hunter data
    SaveHunterData() -- Save the updated hunter data
    ply:SetHealth(guild.benefits.health)
    ply:SetRunSpeed(guild.benefits.speed)
    ply:ChatPrint("You have joined the " .. guildName .. " as a Rookie!")
end

-- Function to leave a guild
function LeaveGuild(ply)
    if not IsHunter(ply) then return end
    ply.hunterGuild = nil
    ply.hunterGuildRank = nil
    hunters[ply:SteamID()].guild = "" -- Remove the guild from the hunter data
    hunters[ply:SteamID()].guildRank = "" -- Remove the guild rank from the hunter data
    SaveHunterData() -- Save the updated hunter data
    ply:SetHealth(100)
    ply:SetRunSpeed(250)
    ply:ChatPrint("You have left your guild.")
end

-- Function to promote a player within their guild
function PromoteGuildRank(ply, target)
    if not IsHunter(ply) or not ply.hunterGuild then return end
    if not IsHunter(target) or not target.hunterGuild or target.hunterGuild ~= ply.hunterGuild then return end

    local guild = HunterGuildsConfig[ply.hunterGuild]
    local playerRank = ply.hunterGuildRank
    local targetRank = target.hunterGuildRank

    local playerIndex = table.KeyFromValue(guild.ranks, playerRank)
    local targetIndex = table.KeyFromValue(guild.ranks, targetRank)

    if playerIndex and targetIndex and playerIndex >= 4 and targetIndex < playerIndex then
        target.hunterGuildRank = guild.ranks[targetIndex + 1]
        hunters[target:SteamID()].guildRank = guild.ranks[targetIndex + 1] -- Save the new rank in the hunter data
        SaveHunterData() -- Save the updated hunter data
        target:ChatPrint("You have been promoted to " .. target.hunterGuildRank .. " in the " .. target.hunterGuild .. "!")
    end
end

-- Function to demote a player within their guild
function DemoteGuildRank(ply, target)
    if not IsHunter(ply) or not ply.hunterGuild then return end
    if not IsHunter(target) or not target.hunterGuild or target.hunterGuild ~= ply.hunterGuild then return end

    local guild = HunterGuildsConfig[ply.hunterGuild]
    local playerRank = ply.hunterGuildRank
    local targetRank = target.hunterGuildRank

    local playerIndex = table.KeyFromValue(guild.ranks, playerRank)
    local targetIndex = table.KeyFromValue(guild.ranks, targetRank)

    if playerIndex and targetIndex and playerIndex >= 4 and targetIndex > 1 then
        target.hunterGuildRank = guild.ranks[targetIndex - 1]
        hunters[target:SteamID()].guildRank = guild.ranks[targetIndex - 1] -- Save the new rank in the hunter data
        SaveHunterData() -- Save the updated hunter data
        target:ChatPrint("You have been demoted to " .. target.hunterGuildRank .. " in the " .. target.hunterGuild .. "!")
    end
end

hook.Add("PlayerInitialSpawn", "LoadHunterData", function(ply)
    LoadHunterData(ply)
end)

hook.Add("PlayerDisconnected", "SaveHunterData", function(ply)
    SaveHunterData(ply)
end)

-- Load hunter data when the server starts
hook.Add("Initialize", "LoadHunterData", LoadHunterData)

-- Save hunter data when the server shuts down
hook.Add("ShutDown", "SaveHunterData", SaveHunterData)

// Sync hunter data with clients when they join
hook.Add("PlayerInitialSpawn", "SyncHunterData", function(ply)
    net.Start("SyncHunterData")
    net.WriteTable(hunters)
    net.Send(ply)
end)

// Give hunter weapons to hunters when they spawn
hook.Add("PlayerSpawn", "HunterPlayerSpawn", function(ply)
    if IsHunter(ply) then
        UpdateHunterStats(ply)
        GiveHunterWeapons(ply)
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHunterStats(ply)
            end
        end)
    end
end)

// Give hunter weapons to hunters when they change job
hook.Add("OnPlayerChangedTeam", "HunterPlayerChangedTeam", function(ply, oldTeam, newTeam)
    if IsHunter(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHunterStats(ply)
            end
        end)
    end
end)

// Update hunter model if they reach the threshold when they die
hook.Add("PlayerDeath", "HunterPlayerDeath", function(ply)
    if IsHunter(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHunterStats(ply)
            end
        end)
    end
end)

// Add experience and a vampire heart to hunter when they kill a vampire
hook.Add("PlayerDeath", "HunterKillsVampire", function(victim, inflictor, attacker)
    if IsHunter(attacker) and IsVampire(victim) then
        AddExperience(attacker, 1000)
        AddVampireHeart(attacker)
        attacker:ChatPrint("You have gained 1000 experience and a vampire heart for killing a vampire!")
    end
end)
