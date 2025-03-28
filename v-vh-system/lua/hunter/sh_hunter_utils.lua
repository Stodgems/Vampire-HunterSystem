-- Hunter Utility Functions

include("hunter/sh_hunter_config.lua")
include("hunter/sh_hunter_guilds.lua")

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

function SaveHunterData()
    for steamID, data in pairs(hunters) do
        local query = string.format("REPLACE INTO hunter_data (steamID, experience, tier, hearts, weapons, guild, guildRank) VALUES ('%s', %d, '%s', %d, '%s', '%s', '%s')", steamID, data.experience, data.tier, data.hearts or 0, table.concat(data.weapons or {}, ","), data.guild or "", data.guildRank or "")
        sql.Query(query)
    end
end

local function RemoveHunterData(steamID)
    local query = string.format("DELETE FROM hunter_data WHERE steamID = '%s'", steamID)
    sql.Query(query)
    sql.Query(string.format("DELETE FROM purchased_items WHERE steamID = %s", sql.SQLStr(steamID))) -- Remove purchased items
end

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

local function GiveHunterWeapons(ply)
    ply:Give("weapon_stake")
end

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

function RemoveHunter(ply)
    if not ply:IsPlayer() then return end
    hunters[ply:SteamID()] = nil
    RemoveHunterData(ply:SteamID())
    ResetHunterPerks(ply)
    LeaveGuild(ply)
    SyncHunterData()
    ply:ChatPrint("You have been removed from the hunter system!")
    SaveHunterData()
    UpdateHunterHUD(ply)
end

function ResetHunterPerks(ply)
    ply:SetRunSpeed(250)
    ply:SetHealth(100)
    ply:ConCommand("pp_mat_overlay ''")
end

function IsHunter(ply)
    return hunters[ply:SteamID()] ~= nil
end

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

    if ply.hunterGuild and HunterGuildsConfig[ply.hunterGuild] then
        local guild = HunterGuildsConfig[ply.hunterGuild]
        ply:SetHealth(guild.benefits.health)
        ply:SetArmor(guild.benefits.armor)
        ply:SetRunSpeed(guild.benefits.speed)

        if guild.customPerks then
            guild.customPerks(ply)
        end
    end

    if SERVER then
        UpdateHunterHUD(ply)
    end
end

function AddExperience(ply, amount)
    if not IsHunter(ply) then return end
    local hunter = hunters[ply:SteamID()]
    hunter.experience = hunter.experience + amount

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

function JoinGuild(ply, guildName)
    if not IsHunter(ply) then return end
    if not HunterGuildsConfig[guildName] then return end

    local guild = HunterGuildsConfig[guildName]
    ply.hunterGuild = guildName
    ply.hunterGuildRank = "Rookie"
    hunters[ply:SteamID()].guild = guildName
    hunters[ply:SteamID()].guildRank = "Rookie"
    SaveHunterData()
    ply:SetHealth(guild.benefits.health)
    ply:SetRunSpeed(guild.benefits.speed)
    ply:ChatPrint("You have joined the " .. guildName .. " as a Rookie!")
end

function LeaveGuild(ply)
    if not IsHunter(ply) then return end
    ply.hunterGuild = nil
    ply.hunterGuildRank = nil
    hunters[ply:SteamID()].guild = ""
    hunters[ply:SteamID()].guildRank = ""
    SaveHunterData()
    ply:SetHealth(100)
    ply:SetRunSpeed(250)
    ply:ChatPrint("You have left your guild.")
end

hook.Add("PlayerInitialSpawn", "LoadHunterData", function(ply)
    LoadHunterData(ply)
end)

hook.Add("PlayerDisconnected", "SaveHunterData", function(ply)
    SaveHunterData(ply)
end)

hook.Add("Initialize", "LoadHunterData", LoadHunterData)

hook.Add("ShutDown", "SaveHunterData", SaveHunterData)

hook.Add("PlayerInitialSpawn", "SyncHunterData", function(ply)
    net.Start("SyncHunterData")
    net.WriteTable(hunters)
    net.Send(ply)
end)

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

hook.Add("OnPlayerChangedTeam", "HunterPlayerChangedTeam", function(ply, oldTeam, newTeam)
    if IsHunter(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHunterStats(ply)
            end
        end)
    end
end)

hook.Add("PlayerDeath", "HunterPlayerDeath", function(ply)
    if IsHunter(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHunterStats(ply)
            end
        end)
    end
end)

hook.Add("PlayerDeath", "HunterKillsVampire", function(victim, inflictor, attacker)
    if IsHunter(attacker) and IsVampire(victim) then
        AddExperience(attacker, 1000)
        AddVampireHeart(attacker)
        attacker:ChatPrint("You have gained 1000 experience and a vampire heart for killing a vampire!")
    end
end)
