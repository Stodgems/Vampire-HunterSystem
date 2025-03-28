-- Vampire Covens Logic

if SERVER and _G.VampireCovensLoaded then return end
_G.VampireCovensLoaded = true

include("vampire/sh_vampire_covens_config.lua")

local presetLords = {
    ["Coven of Blood"] = {name = "Lord of Blood", rank = "Lord of Blood"},
    ["Coven of Shadows"] = {name = "Lord of Shadows", rank = "Lord of Shadows"},
    ["Coven of Strength"] = {name = "Lord of Strength", rank = "Lord of Strength"}
}

function PromoteCovenRank(ply, target, isAdmin)
    if not IsVampire(ply) or not ply.vampireCoven then
        return
    end

    if not IsVampire(target) or not target.vampireCoven or target.vampireCoven ~= ply.vampireCoven then
        return
    end

    local coven = VampireCovensConfig[ply.vampireCoven]
    if not coven then
        return
    end

    local playerRank = ply.vampireCovenRank
    local targetRank = target.vampireCovenRank

    local playerIndex = table.KeyFromValue(coven.ranks, playerRank)
    local targetIndex = table.KeyFromValue(coven.ranks, targetRank)

    if not playerIndex or not targetIndex then
        return
    end

    if isAdmin or (playerIndex >= 4 and targetIndex < playerIndex) then
        if targetIndex < #coven.ranks then
            target.vampireCovenRank = coven.ranks[targetIndex + 1]
            vampires[target:SteamID()].covenRank = coven.ranks[targetIndex + 1]
            SaveVampireData()
            target:ChatPrint("You have been promoted to " .. target.vampireCovenRank .. " in the " .. target.vampireCoven .. "!")
        end
    end
end

_G.PromoteCovenRank = PromoteCovenRank

function JoinCoven(ply, covenName)
    if not IsVampire(ply) then return end
    if not VampireCovensConfig[covenName] then return end

    local coven = VampireCovensConfig[covenName]
    ply.vampireCoven = covenName
    ply.vampireCovenRank = "Initiate"

    UpdateVampireStats(ply)

    ply:SetHealth(coven.benefits.health)
    ply:SetArmor(coven.benefits.armor)
    ply:SetRunSpeed(coven.benefits.speed)
    ply:ChatPrint("You have joined the " .. covenName .. " as an Initiate!")

    vampires[ply:SteamID()].coven = covenName
    vampires[ply:SteamID()].covenRank = "Initiate"
    SaveVampireData()

    local steamID = sql.SQLStr(ply:SteamID())
    local covenEscaped = sql.SQLStr(covenName)
    local rankEscaped = sql.SQLStr("Initiate")
    sql.Query(string.format("UPDATE vampire_data SET coven = %s, covenRank = %s WHERE steamID = %s", covenEscaped, rankEscaped, steamID))

    if coven.customPerks then
        coven.customPerks(ply)
    end
end

function LeaveCoven(ply)
    if not IsVampire(ply) then return end
    ply.vampireCoven = nil
    ply.vampireCovenRank = nil

    ply:SetArmor(0)
    timer.Remove("CovenOfBloodRegen_" .. ply:SteamID())

    UpdateVampireStats(ply)

    vampires[ply:SteamID()].coven = nil
    vampires[ply:SteamID()].covenRank = nil
    SaveVampireData()

    local steamID = sql.SQLStr(ply:SteamID())
    sql.Query(string.format("UPDATE vampire_data SET coven = NULL, covenRank = NULL WHERE steamID = %s", steamID))

    ply:ChatPrint("You have left your coven.")
end

function GetCoven(ply)
    return ply.vampireCoven
end

function GetCovenRank(ply)
    return ply.vampireCovenRank
end

function DemoteCovenRank(ply, target, isAdmin)
    if not IsVampire(ply) or not ply.vampireCoven then return end
    if not IsVampire(target) or not target.vampireCoven or target.vampireCoven ~= ply.vampireCoven then return end

    local coven = VampireCovensConfig[ply.vampireCoven]
    local playerRank = ply.vampireCovenRank
    local targetRank = target.vampireCovenRank

    local playerIndex = table.KeyFromValue(coven.ranks, playerRank)
    local targetIndex = table.KeyFromValue(coven.ranks, targetRank)

    if isAdmin or (playerIndex and targetIndex and playerIndex >= 4 and targetIndex > 1) then
        if targetIndex > 1 then
            target.vampireCovenRank = coven.ranks[targetIndex - 1]
            vampires[target:SteamID()].covenRank = coven.ranks[targetIndex - 1]
            SaveVampireData()
            target:ChatPrint("You have been demoted to " .. target.vampireCovenRank .. " in the " .. target.vampireCoven .. "!")
        end
    end
end
