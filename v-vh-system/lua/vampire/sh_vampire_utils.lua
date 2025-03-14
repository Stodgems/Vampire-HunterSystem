-- Vampire Utility Functions

include("vampire/sh_vampire_config.lua")

-- Initialize the vampires table
if SERVER then
    vampires = vampires or {}
    util.AddNetworkString("SyncVampireData")
    util.AddNetworkString("NewTierMessage")
    util.AddNetworkString("UpdateVampireHUD")
else
    vampires = vampires or {}
    net.Receive("SyncVampireData", function()
        vampires = net.ReadTable()
    end)
end

-- Function to save vampire data to the SQLite database
function SaveVampireData()
    for steamID, data in pairs(vampires) do
        local steamIDEscaped = sql.SQLStr(steamID)
        local blood = tonumber(data.blood)
        local tierEscaped = sql.SQLStr(data.tier)
        local medallions = tonumber(data.medallions or 0)
        sql.Query(string.format("REPLACE INTO vampire_data (steamID, blood, tier, medallions) VALUES (%s, %d, %s, %d)", steamIDEscaped, blood, tierEscaped, medallions))
    end
end

-- Function to remove vampire data from the SQLite database
local function RemoveVampireData(steamID)
    local steamIDEscaped = sql.SQLStr(steamID)
    sql.Query(string.format("DELETE FROM vampire_data WHERE steamID = %s", steamIDEscaped))
end

-- Function to load vampire data from the SQLite database
local function LoadVampireData()
    if not sql.TableExists("vampire_data") then
        sql.Query("CREATE TABLE vampire_data (steamID TEXT PRIMARY KEY, blood INTEGER, tier TEXT, medallions INTEGER)")
    end

    local result = sql.Query("SELECT * FROM vampire_data")
    if result then
        for _, row in ipairs(result) do
            vampires[row.steamID] = { blood = tonumber(row.blood), tier = row.tier, medallions = tonumber(row.medallions) or 0 }
        end
    end
end

-- Function to sync vampire data with clients
local function SyncVampireData()
    if SERVER then
        if timer.Exists("SyncVampireDataTimer") then return end
        timer.Create("SyncVampireDataTimer", 1, 1, function()
            net.Start("SyncVampireData")
            net.WriteTable(vampires)
            net.Broadcast()
        end)
    end
end

-- Function to turn a player into a vampire
function MakeVampire(ply)
    if not ply:IsPlayer() then return end
    if IsHunter(ply) then
        RemoveHunter(ply)
    end
    vampires[ply:SteamID()] = { blood = 0, tier = "Thrall", medallions = 0 }
    UpdateVampireStats(ply)
    ply:ChatPrint("You have been turned into a vampire!")
    ply:Give("weapon_vampire")
    SaveVampireData()
    SyncVampireData()
    if SERVER then
        UpdateVampireHUD(ply)
    end
end

-- Function to remove a player from being a vampire
function RemoveVampire(ply)
    if not ply:IsPlayer() then return end
    vampires[ply:SteamID()] = nil
    RemoveVampireData(ply:SteamID())
    ResetVampirePerks(ply)
    SyncVampireData()
    ply:ChatPrint("You have been cured of vampirism!")
    SaveVampireData()
    UpdateVampireHUD(ply)
end

-- Function to reset all perks for a player
function ResetVampirePerks(ply)
    ply:SetRunSpeed(250) -- Reset to default speed
    ply:SetHealth(100) -- Reset to default health
    ply:ConCommand("pp_mat_overlay ''") -- Reset night vision
end

-- Function to check if a player is a vampire
function IsVampire(ply)
    return vampires[ply:SteamID()] ~= nil
end

-- Function to update vampire stats based on their tier
function UpdateVampireStats(ply)
    local vampire = vampires[ply:SteamID()]
    if not vampire then return end

    local tier = vampire.tier
    local config = VampireConfig.Tiers[tier]

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
        UpdateVampireHUD(ply)
    end
end

-- Function to add blood to a vampire
function AddBlood(ply, amount)
    if not IsVampire(ply) then return end
    local vampire = vampires[ply:SteamID()]
    vampire.blood = vampire.blood + amount

    -- Update tier based on blood level
    local newTier = vampire.tier
    for tier, config in SortedPairsByMemberValue(VampireConfig.Tiers, "threshold", true) do
        if vampire.blood >= config.threshold then
            newTier = tier
            break
        end
    end

    if newTier ~= vampire.tier then
        vampire.tier = newTier
        UpdateVampireStats(ply)
        net.Start("NewTierMessage")
        net.WriteString("You have reached a new tier: " .. vampire.tier)
        net.Send(ply)
    end

    SaveVampireData()
    SyncVampireData()
    if SERVER then
        UpdateVampireHUD(ply)
    end
end

-- Function to start draining blood from a target
function StartDrainBlood(ply, target)
    if not IsVampire(ply) then return end
    if not IsValid(target) or target:Health() <= 0 then return end

    local drainTimer = "DrainBlood_" .. ply:SteamID() .. "_" .. target:EntIndex()

    timer.Create(drainTimer, 1, 0, function()
        if not IsValid(ply) or not IsValid(target) or target:Health() <= 0 then
            timer.Remove(drainTimer)
            return
        end

        DrainBlood(ply, target)
    end)
end

-- Function to drain blood from a target
function DrainBlood(ply, target)
    if not IsVampire(ply) then return end
    if not IsValid(target) or target:Health() <= 0 then return end

    AddBlood(ply, 50)
end

-- Function to add a hunter medallion to a vampire
function AddHunterMedallion(ply)
    if not IsVampire(ply) then return end
    local vampire = vampires[ply:SteamID()]
    vampire.medallions = (vampire.medallions or 0) + 1
    SaveVampireData()
    SyncVampireData()
    if SERVER then
        UpdateVampireHUD(ply)
    end
end

-- Function to update the vampire HUD
if SERVER then
    function UpdateVampireHUD(ply)
        if not IsVampire(ply) then return end
        local vampire = vampires[ply:SteamID()]
        net.Start("UpdateVampireHUD")
        net.WriteInt(vampire.blood, 32)
        net.WriteString(vampire.tier)
        net.WriteInt(vampire.medallions or 0, 32)
        net.Send(ply)
    end
end

hook.Add("PlayerInitialSpawn", "LoadVampireData", function(ply)
    LoadVampireData(ply)
end)

hook.Add("PlayerDisconnected", "SaveVampireData", function(ply)
    SaveVampireData(ply)
end)

-- Load vampire data when the server starts
hook.Add("Initialize", "LoadVampireData", LoadVampireData)

-- Save vampire data when the server shuts down
hook.Add("ShutDown", "SaveVampireData", SaveVampireData)

// Sync vampire data with clients when they join
hook.Add("PlayerInitialSpawn", "SyncVampireData", function(ply)
    net.Start("SyncVampireData")
    net.WriteTable(vampires)
    net.Send(ply)
end)

// Give vampire weapon to vampires when they spawn
hook.Add("PlayerSpawn", "VampirePlayerSpawn", function(ply)
    if IsVampire(ply) then
        UpdateVampireStats(ply)
        ply:Give("weapon_vampire")
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateVampireStats(ply)
            end
        end)
    end
end)

// Give vampire weapon to vampires when they change job
hook.Add("OnPlayerChangedTeam", "VampirePlayerChangedTeam", function(ply, oldTeam, newTeam)
    if IsVampire(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateVampireStats(ply)
            end
        end)
    end
end)

// Update vampire model if they reach the threshold when they die
hook.Add("PlayerDeath", "VampirePlayerDeath", function(ply)
    if IsVampire(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateVampireStats(ply)
            end
        end)
    end
end)

// Add a hunter medallion to vampire when they kill a hunter
hook.Add("PlayerDeath", "VampireKillsHunter", function(victim, inflictor, attacker)
    if IsVampire(attacker) and IsHunter(victim) then
        AddHunterMedallion(attacker)
        attacker:ChatPrint("You have collected a hunter's medallion!")
    end
end)