

if SERVER and _G.WerewolfPacksLoaded then return end
_G.WerewolfPacksLoaded = true

include("werewolf/sh_werewolf_packs_config.lua")

function PromotePackRank(ply, target, isAdmin)
    if not IsWerewolf(ply) or not ply.werewolfPack then
        return
    end

    if not IsWerewolf(target) or not target.werewolfPack or target.werewolfPack ~= ply.werewolfPack then
        return
    end

    local pack = WerewolfPacksConfig[ply.werewolfPack]
    if not pack then
        return
    end

    local playerRank = ply.werewolfPackRank
    local targetRank = target.werewolfPackRank

    local playerIndex = table.KeyFromValue(pack.ranks, playerRank)
    local targetIndex = table.KeyFromValue(pack.ranks, targetRank)

    if not playerIndex or not targetIndex then
        return
    end

    if isAdmin or (playerIndex >= 4 and targetIndex < playerIndex) then
        if targetIndex < #pack.ranks then
            target.werewolfPackRank = pack.ranks[targetIndex + 1]
            werewolves[target:SteamID()].packRank = pack.ranks[targetIndex + 1]
            SaveWerewolfData()
            target:ChatPrint("You have been promoted to " .. target.werewolfPackRank .. " in the " .. target.werewolfPack .. "!")
            UpdateWerewolfStats(target)
        end
    end
end

_G.PromotePackRank = PromotePackRank

function JoinPack(ply, packName)
    if not IsWerewolf(ply) then return end
    if not WerewolfPacksConfig[packName] then return end

    local pack = WerewolfPacksConfig[packName]
    ply.werewolfPack = packName
    ply.werewolfPackRank = "Omega"

    UpdateWerewolfStats(ply)

    ply:SetHealth(pack.benefits.health)
    ply:SetRunSpeed(pack.benefits.speed)
    ply:ChatPrint("You have joined the " .. packName .. " as an Omega!")

    werewolves[ply:SteamID()].pack = packName
    werewolves[ply:SteamID()].packRank = "Omega"
    SaveWerewolfData()

    if pack.customPerks then
        pack.customPerks(ply)
    end
end

function LeavePack(ply)
    if not IsWerewolf(ply) then return end
    
    
    local oldPack = ply.werewolfPack
    if oldPack and WerewolfPacksConfig[oldPack] then
        
        ply:SetColor(Color(255, 255, 255, 255))
    end
    
    ply.werewolfPack = nil
    ply.werewolfPackRank = nil

    UpdateWerewolfStats(ply)

    werewolves[ply:SteamID()].pack = ""
    werewolves[ply:SteamID()].packRank = ""
    SaveWerewolfData()

    ply:ChatPrint("You have left your pack and returned to being a lone wolf.")
end

function GetPack(ply)
    return ply.werewolfPack
end

function GetPackRank(ply)
    return ply.werewolfPackRank
end

function DemotePackRank(ply, target, isAdmin)
    if not IsWerewolf(ply) or not ply.werewolfPack then return end
    if not IsWerewolf(target) or not target.werewolfPack or target.werewolfPack ~= ply.werewolfPack then return end

    local pack = WerewolfPacksConfig[ply.werewolfPack]
    local playerRank = ply.werewolfPackRank
    local targetRank = target.werewolfPackRank

    local playerIndex = table.KeyFromValue(pack.ranks, playerRank)
    local targetIndex = table.KeyFromValue(pack.ranks, targetRank)

    if isAdmin or (playerIndex and targetIndex and playerIndex >= 4 and targetIndex > 1) then
        if targetIndex > 1 then
            target.werewolfPackRank = pack.ranks[targetIndex - 1]
            werewolves[target:SteamID()].packRank = pack.ranks[targetIndex - 1]
            SaveWerewolfData()
            target:ChatPrint("You have been demoted to " .. target.werewolfPackRank .. " in the " .. target.werewolfPack .. "!")
            UpdateWerewolfStats(target)
        end
    end
end


function UpdateWerewolfStatsWithPack(ply)
    local werewolf = werewolves[ply:SteamID()]
    if not werewolf then return end

    
    UpdateWerewolfStats(ply)

    
    if ply.werewolfPack and WerewolfPacksConfig[ply.werewolfPack] then
        local pack = WerewolfPacksConfig[ply.werewolfPack]
        local tier = werewolf.tier
        local config = WerewolfConfig.Tiers[tier]
        local moonPhase = WerewolfConfig.MoonPhases[CurrentMoonPhase]
        
        local healthMultiplier = moonPhase.multiplier
        local speedMultiplier = moonPhase.multiplier
        
        
        if werewolf.transformed then
            healthMultiplier = healthMultiplier * 1.3
            speedMultiplier = speedMultiplier * 1.4
        end

        
        local packHealthBonus = pack.benefits.health - config.health
        local packSpeedBonus = pack.benefits.speed - config.speed
        
        ply:SetHealth(math.floor((config.health + packHealthBonus) * healthMultiplier))
        ply:SetRunSpeed(math.floor((config.speed + packSpeedBonus) * speedMultiplier))

        if pack.customPerks then
            pack.customPerks(ply)
        end
    end
end


local originalUpdateWerewolfStats = UpdateWerewolfStats
UpdateWerewolfStats = UpdateWerewolfStatsWithPack


function ApplyPackTransformationBonus(ply)
    if not IsWerewolf(ply) or not ply.werewolfPack then return end
    
    local pack = WerewolfPacksConfig[ply.werewolfPack]
    if not pack or not pack.benefits.rageMultiplier then return end
    
    local werewolf = werewolves[ply:SteamID()]
    if werewolf and werewolf.rage then
        
        if werewolf.transformed then
            local bonusRage = werewolf.rage * (pack.benefits.rageMultiplier - 1.0)
            
            return bonusRage
        end
    end
    return 0
end