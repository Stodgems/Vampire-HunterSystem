

include("werewolf/sh_werewolf_config.lua")

if SERVER then
    werewolves = werewolves or {}
    util.AddNetworkString("SyncWerewolfData")
    util.AddNetworkString("NewWerewolfTierMessage")
    util.AddNetworkString("UpdateWerewolfHUD")
    util.AddNetworkString("WerewolfTransformationStart")
    util.AddNetworkString("WerewolfTransformationEnd")
    util.AddNetworkString("UpdateMoonPhase")
else
    werewolves = werewolves or {}
    net.Receive("SyncWerewolfData", function()
        werewolves = net.ReadTable()
    end)
end


CurrentMoonPhase = "First Quarter"
local moonPhaseIndex = 3

function SaveWerewolfData()
    for steamID, data in pairs(werewolves) do
        local query = string.format(
            "REPLACE INTO werewolf_data (steamID, rage, tier, moonEssence, pack, packRank, transformed, lastTransform) VALUES ('%s', %d, '%s', %d, '%s', '%s', %d, %d)",
            steamID,
            data.rage or 0,
            data.tier or "Pup",
            data.moonEssence or 0,
            data.pack or "",
            data.packRank or "",
            data.transformed and 1 or 0,
            data.lastTransform or 0
        )
        sql.Query(query)
    end
end

local function RemoveWerewolfData(steamID)
    local steamIDEscaped = sql.SQLStr(steamID)
    sql.Query(string.format("DELETE FROM werewolf_data WHERE steamID = %s", steamIDEscaped))
end

local function LoadWerewolfData()
    if not sql.TableExists("werewolf_data") then
        sql.Query("CREATE TABLE werewolf_data (steamID TEXT PRIMARY KEY, rage INTEGER, tier TEXT, moonEssence INTEGER, pack TEXT, packRank TEXT, transformed INTEGER, lastTransform INTEGER)")
    end

    local result = sql.Query("SELECT * FROM werewolf_data")
    if result then
        for _, row in ipairs(result) do
            werewolves[row.steamID] = { 
                rage = tonumber(row.rage) or 0, 
                tier = row.tier or "Pup", 
                moonEssence = tonumber(row.moonEssence) or 0,
                pack = row.pack or "",
                packRank = row.packRank or "",
                transformed = tonumber(row.transformed) == 1,
                lastTransform = tonumber(row.lastTransform) or 0
            }
        end
    end
end

function SyncWerewolfData()
    if SERVER then
        if timer.Exists("SyncWerewolfDataTimer") then return end
        timer.Create("SyncWerewolfDataTimer", 1, 1, function()
            net.Start("SyncWerewolfData")
            net.WriteTable(werewolves)
            net.Broadcast()
        end)
    end
end

function MakeWerewolf(ply)
    if not ply:IsPlayer() then return end
    if IsVampire(ply) then
        RemoveVampire(ply)
    end
    if IsHunter(ply) then
        RemoveHunter(ply)
    end
    werewolves[ply:SteamID()] = { 
        rage = 0, 
        tier = "Pup", 
        moonEssence = 0,
        pack = "",
        packRank = "",
        transformed = false,
        lastTransform = 0
    }
    UpdateWerewolfStats(ply)
    ply:ChatPrint("You have been turned into a werewolf! The moon calls to you...")
    ply:Give("weapon_werewolf_claws")
    SaveWerewolfData()
    SyncWerewolfData()
    if SERVER then
        UpdateWerewolfHUD(ply)
    end
end

function RemoveWerewolf(ply)
    if not ply:IsPlayer() then return end
    
    
    if werewolves[ply:SteamID()] and werewolves[ply:SteamID()].transformed then
        EndTransformation(ply)
    end
    
    werewolves[ply:SteamID()] = nil
    RemoveWerewolfData(ply:SteamID())
    ResetWerewolfPerks(ply)
    SyncWerewolfData()
    ply:ChatPrint("You have been cured of lycanthropy!")
    SaveWerewolfData()
    UpdateWerewolfHUD(ply)
end

function ResetWerewolfPerks(ply)
    ply:SetRunSpeed(250)
    ply:SetHealth(100)
    ply:ConCommand("pp_mat_overlay ''")
end

function IsWerewolf(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    return werewolves[ply:SteamID()] ~= nil
end

function UpdateWerewolfStats(ply)
    local werewolf = werewolves[ply:SteamID()]
    if not werewolf then return end

    local tier = werewolf.tier
    local config = WerewolfConfig.Tiers[tier]
    local moonPhase = WerewolfConfig.MoonPhases[CurrentMoonPhase]
    
    local healthMultiplier = moonPhase.multiplier
    local speedMultiplier = moonPhase.multiplier
    
    
    if werewolf.transformed then
        healthMultiplier = healthMultiplier * 1.3
        speedMultiplier = speedMultiplier * 1.4
    end

    ply:SetHealth(math.floor(config.health * healthMultiplier))
    ply:SetRunSpeed(math.floor(config.speed * speedMultiplier))

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
        UpdateWerewolfHUD(ply)
    end
end

function AddRage(ply, amount)
    if not IsWerewolf(ply) then return end
    local werewolf = werewolves[ply:SteamID()]
    werewolf.rage = math.min(werewolf.rage + amount, WerewolfConfig.Transformation.maxRage)

    local newTier = werewolf.tier
    for tier, config in SortedPairsByMemberValue(WerewolfConfig.Tiers, "threshold", true) do
        if werewolf.rage >= config.threshold then
            newTier = tier
            break
        end
    end

    if newTier ~= werewolf.tier then
        werewolf.tier = newTier
        UpdateWerewolfStats(ply)
        if SERVER then
            net.Start("NewWerewolfTierMessage")
            net.WriteString("You have reached a new tier: " .. werewolf.tier)
            net.Send(ply)
        end
    end

    SaveWerewolfData()
    SyncWerewolfData()
    if SERVER then
        UpdateWerewolfHUD(ply)
    end
end

function StartTransformation(ply)
    if not IsWerewolf(ply) then return false end
    local werewolf = werewolves[ply:SteamID()]
    
    
    local currentTime = CurTime()
    if currentTime - werewolf.lastTransform < WerewolfConfig.Transformation.cooldown then
        if SERVER then
            ply:ChatPrint("You must wait before transforming again!")
        end
        return false
    end
    
    werewolf.transformed = true
    werewolf.lastTransform = currentTime
    
    if SERVER then
        net.Start("WerewolfTransformationStart")
        net.Send(ply)
        
        ply:ChatPrint("You transform into your wolf form!")
        ply:EmitSound("ambient/creatures/town_child_scream1.wav", 75, 70)
        
        
        timer.Create("WerewolfTransform_" .. ply:SteamID(), WerewolfConfig.Transformation.duration, 1, function()
            if IsValid(ply) and IsWerewolf(ply) then
                EndTransformation(ply)
            end
        end)
    end
    
    UpdateWerewolfStats(ply)
    SaveWerewolfData()
    SyncWerewolfData()
    return true
end

function EndTransformation(ply)
    if not IsWerewolf(ply) then return end
    local werewolf = werewolves[ply:SteamID()]
    
    werewolf.transformed = false
    
    if SERVER then
        net.Start("WerewolfTransformationEnd")
        net.Send(ply)
        
        ply:ChatPrint("You return to your human form.")
        timer.Remove("WerewolfTransform_" .. ply:SteamID())
    end
    
    UpdateWerewolfStats(ply)
    SaveWerewolfData()
    SyncWerewolfData()
end

function AddMoonEssence(ply, amount)
    if not IsWerewolf(ply) then return end
    local werewolf = werewolves[ply:SteamID()]
    werewolf.moonEssence = (werewolf.moonEssence or 0) + (amount or 1)
    SaveWerewolfData()
    SyncWerewolfData()
    if SERVER then
        UpdateWerewolfHUD(ply)
    end
end


if SERVER then
    function UpdateMoonPhase()
        local moonPhases = {"New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"}
        moonPhaseIndex = (moonPhaseIndex % 8) + 1
        CurrentMoonPhase = moonPhases[moonPhaseIndex]
        
        net.Start("UpdateMoonPhase")
        net.WriteString(CurrentMoonPhase)
        net.Broadcast()
        
        
        for _, ply in ipairs(player.GetAll()) do
            if IsWerewolf(ply) then
                UpdateWerewolfStats(ply)
            end
        end
        
        print("[Werewolf System] Moon phase changed to: " .. CurrentMoonPhase)
    end
    
    
    timer.Create("MoonPhaseTimer", 600, 0, UpdateMoonPhase)
    
    function UpdateWerewolfHUD(ply)
        if not IsWerewolf(ply) then return end
        local werewolf = werewolves[ply:SteamID()]
        net.Start("UpdateWerewolfHUD")
        net.WriteInt(werewolf.rage or 0, 32)
        net.WriteString(werewolf.tier or "Pup")
        net.WriteInt(werewolf.moonEssence or 0, 32)
        net.WriteString(CurrentMoonPhase)
        net.WriteBool(werewolf.transformed or false)
        net.Send(ply)
    end
else
    net.Receive("UpdateMoonPhase", function()
        CurrentMoonPhase = net.ReadString()
    end)
end


if SERVER then
    timer.Create("WerewolfRageDecay", 1, 0, function()
        for steamID, werewolf in pairs(werewolves) do
            if werewolf.rage > 0 then
                werewolf.rage = math.max(0, werewolf.rage - WerewolfConfig.Transformation.rageDecay)
                local ply = player.GetBySteamID(steamID)
                if IsValid(ply) then
                    UpdateWerewolfHUD(ply)
                end
            end
        end
    end)
end

hook.Add("PlayerInitialSpawn", "LoadWerewolfData", function(ply)
    LoadWerewolfData(ply)
end)

hook.Add("PlayerDisconnected", "SaveWerewolfData", function(ply)
    SaveWerewolfData(ply)
end)

hook.Add("Initialize", "LoadWerewolfData", LoadWerewolfData)

hook.Add("ShutDown", "SaveWerewolfData", SaveWerewolfData)

hook.Add("PlayerInitialSpawn", "SyncWerewolfData", function(ply)
    net.Start("SyncWerewolfData")
    net.WriteTable(werewolves)
    net.Send(ply)
    
    if SERVER then
        net.Start("UpdateMoonPhase")
        net.WriteString(CurrentMoonPhase)
        net.Send(ply)
    end
end)

hook.Add("PlayerSpawn", "WerewolfPlayerSpawn", function(ply)
    if IsWerewolf(ply) then
        UpdateWerewolfStats(ply)
        ply:Give("weapon_werewolf_claws")
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateWerewolfStats(ply)
            end
        end)
    end
end)

hook.Add("OnPlayerChangedTeam", "WerewolfPlayerChangedTeam", function(ply, oldTeam, newTeam)
    if IsWerewolf(ply) then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateWerewolfStats(ply)
            end
        end)
    end
end)

hook.Add("PlayerDeath", "WerewolfPlayerDeath", function(ply)
    if IsWerewolf(ply) then
        
        if werewolves[ply:SteamID()] and werewolves[ply:SteamID()].transformed then
            EndTransformation(ply)
        end
        
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateWerewolfStats(ply)
            end
        end)
    end
end)

hook.Add("PlayerDeath", "WerewolfKillsGain", function(victim, inflictor, attacker)
    if IsWerewolf(attacker) then
        local rageGain = WerewolfConfig.Transformation.rageGain
        
        
        if IsVampire(victim) then
            rageGain = rageGain * 1.5
            attacker:ChatPrint("You gained extra rage for killing a vampire!")
        elseif IsHunter(victim) then
            rageGain = rageGain * 1.5
            attacker:ChatPrint("You gained extra rage for killing a hunter!")
        end
        
        AddRage(attacker, rageGain)
        attacker:ChatPrint("You gained " .. rageGain .. " rage!")
    end
end)