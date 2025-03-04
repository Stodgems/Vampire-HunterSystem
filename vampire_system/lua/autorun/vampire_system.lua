-- Vampire System

-- Table to store vampire players and their blood levels
local vampires = {}

-- Function to turn a player into a vampire
function MakeVampire(ply)
    if not ply:IsPlayer() then return end
    vampires[ply:SteamID()] = { blood = 0, tier = "Thrall" }
    UpdateVampireStats(ply)
    ply:ChatPrint("You have been turned into a vampire!")
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
    local health, speed

    if tier == "Thrall" then
        health = 100
        speed = 300
    elseif tier == "Vampire" then
        health = 150
        speed = 350
    elseif tier == "Vampire Veteran" then
        health = 200
        speed = 400
    elseif tier == "Vampire Master" then
        health = 250
        speed = 450
    elseif tier == "Vampire Lord" then
        health = 300
        speed = 500
    elseif tier == "Dracula" then
        health = 400
        speed = 600
    end

    ply:SetHealth(health)
    ply:SetRunSpeed(speed)
end

-- Function to add blood to a vampire
function AddBlood(ply, amount)
    if not IsVampire(ply) then return end
    local vampire = vampires[ply:SteamID()]
    vampire.blood = vampire.blood + amount

    -- Update tier based on blood level
    if vampire.blood >= 100000 then
        vampire.tier = "Dracula"
    elseif vampire.blood >= 50000 then
        vampire.tier = "Vampire Lord"
    elseif vampire.blood >= 25000 then
        vampire.tier = "Vampire Master"
    elseif vampire.blood >= 10000 then
        vampire.tier = "Vampire Veteran"
    elseif vampire.blood >= 5000 then
        vampire.tier = "Vampire"
    else
        vampire.tier = "Thrall"
    end

    UpdateVampireStats(ply)
    ply:ChatPrint("You have drunk blood. Current tier: " .. vampire.tier)
end

-- Function to drain blood from a target
function DrainBlood(ply, target, amount, rate)
    if not IsVampire(ply) then return end
    if not IsValid(target) then return end

    local totalDrained = 0
    local drainTimer = "DrainBlood_" .. ply:SteamID() .. "_" .. target:EntIndex()

    timer.Create(drainTimer, 1, 0, function()
        if not IsValid(ply) or not IsValid(target) or totalDrained >= amount then
            timer.Remove(drainTimer)
            return
        end

        if target:IsPlayer() then
            target:SetHealth(target:Health() - rate)
        elseif target:IsNPC() then
            target:SetHealth(target:Health() - rate)
        end

        AddBlood(ply, rate)
        totalDrained = totalDrained + rate

        if target:Health() <= 0 then
            target:Kill()
            timer.Remove(drainTimer)
        end
    end)
end

-- Hook to handle player spawn
hook.Add("PlayerSpawn", "VampirePlayerSpawn", function(ply)
    if IsVampire(ply) then
        UpdateVampireStats(ply)
    end
end)
