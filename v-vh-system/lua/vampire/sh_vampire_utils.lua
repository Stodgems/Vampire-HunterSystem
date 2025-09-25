

include("vampire/sh_vampire_config.lua")

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

function SaveVampireData()
    for steamID, data in pairs(vampires) do
        local query = string.format(
            "REPLACE INTO vampire_data (steamID, blood, tier, medallions, coven, covenRank) VALUES ('%s', %d, '%s', %d, '%s', '%s')",
            steamID,
            data.blood or 0,
            data.tier or "Thrall",
            data.medallions or 0,
            data.coven or "",
            data.covenRank or ""
        )
        sql.Query(query)
    end
end


local function RemoveVampireData(steamID)
    local steamIDEscaped = sql.SQLStr(steamID)
    sql.Query(string.format("DELETE FROM vampire_data WHERE steamID = %s", steamIDEscaped))
    sql.Query(string.format("DELETE FROM purchased_abilities WHERE steamID = %s", steamIDEscaped)) 
end

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

function SyncVampireData()
    if SERVER then
        if timer.Exists("SyncVampireDataTimer") then return end
        timer.Create("SyncVampireDataTimer", 1, 1, function()
            net.Start("SyncVampireData")
            net.WriteTable(vampires)
            net.Broadcast()
        end)
    end
end

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

function ResetVampirePerks(ply)
    ply:SetRunSpeed(250)
    ply:SetHealth(100)
    ply:ConCommand("pp_mat_overlay ''")
end

function IsVampire(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    return vampires[ply:SteamID()] ~= nil
end

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
        local jobModel
        if isfunction(ply.getJobTable) then
            local job = ply:getJobTable()
            if job and job.model then
                jobModel = job.model
            end
        end
        if istable(jobModel) then
            ply:SetModel(jobModel[1])
        elseif isstring(jobModel) then
            ply:SetModel(jobModel)
        end
    end

    if SERVER then
        UpdateVampireHUD(ply)
    end
end

function AddBlood(ply, amount)
    if not IsVampire(ply) then return end
    local vampire = vampires[ply:SteamID()]
    vampire.blood = vampire.blood + amount

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
        if SERVER then
            net.Start("NewTierMessage")
            net.WriteString("You have reached a new tier: " .. vampire.tier)
            net.Send(ply)
        end
    end

    SaveVampireData()
    SyncVampireData()
    if SERVER then
        UpdateVampireHUD(ply)
    end
end



function DrainBlood(ply, target, amount, rate)
    if not IsVampire(ply) then return end
    local toAdd = tonumber(amount) or 50
    AddBlood(ply, toAdd)
end


function StartDrainBlood(ply, target)
    return DrainBlood(ply, target, 50)
end

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

hook.Add("Initialize", "LoadVampireData", LoadVampireData)

hook.Add("ShutDown", "SaveVampireData", SaveVampireData)

hook.Add("PlayerInitialSpawn", "SyncVampireData", function(ply)
    net.Start("SyncVampireData")
    net.WriteTable(vampires)
    net.Send(ply)
end)

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

hook.Add("OnPlayerChangedTeam", "VampirePlayerChangedTeam", function(ply, oldTeam, newTeam)
    if IsVampire(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateVampireStats(ply)
            end
        end)
    end
end)

hook.Add("PlayerDeath", "VampirePlayerDeath", function(ply)
    if IsVampire(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateVampireStats(ply)
            end
        end)
    end
end)

hook.Add("PlayerDeath", "VampireKillsHunter", function(victim, inflictor, attacker)
    if IsVampire(attacker) and IsHunter(victim) then
        AddHunterMedallion(attacker)
        attacker:ChatPrint("You have collected a hunter's medallion!")
    end
end)