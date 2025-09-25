

include("hybrid/sh_hybrid_config.lua")

if SERVER then
    hybrids = hybrids or {}
    util.AddNetworkString("SyncHybridData")
    util.AddNetworkString("NewHybridTierMessage")
    util.AddNetworkString("UpdateHybridHUD")
    util.AddNetworkString("HybridTransformationStart")
    util.AddNetworkString("HybridTransformationEnd")
    util.AddNetworkString("HybridBalanceShift")
    util.AddNetworkString("HybridEclipseEvent")
else
    hybrids = hybrids or {}
    net.Receive("SyncHybridData", function()
        hybrids = net.ReadTable()
    end)
end

function SaveHybridData()
    for steamID, data in pairs(hybrids) do
        local query = string.format(
            "REPLACE INTO hybrid_data (steamID, blood, rage, tier, balance, dualEssence, lastTransform, currentForm) VALUES ('%s', %d, %d, '%s', %d, %d, %d, '%s')",
            steamID,
            data.blood or 0,
            data.rage or 0,
            data.tier or "Cursed",
            data.balance or 0,
            data.dualEssence or 0,
            data.lastTransform or 0,
            data.currentForm or "human"
        )
        sql.Query(query)
    end
end

local function RemoveHybridData(steamID)
    local steamIDEscaped = sql.SQLStr(steamID)
    sql.Query(string.format("DELETE FROM hybrid_data WHERE steamID = %s", steamIDEscaped))
end

local function LoadHybridData()
    if not sql.TableExists("hybrid_data") then
        sql.Query("CREATE TABLE hybrid_data (steamID TEXT PRIMARY KEY, blood INTEGER, rage INTEGER, tier TEXT, balance INTEGER, dualEssence INTEGER, lastTransform INTEGER, currentForm TEXT)")
    end

    local result = sql.Query("SELECT * FROM hybrid_data")
    if result then
        for _, row in ipairs(result) do
            hybrids[row.steamID] = { 
                blood = tonumber(row.blood) or 0,
                rage = tonumber(row.rage) or 0, 
                tier = row.tier or "Cursed", 
                balance = tonumber(row.balance) or 0,
                dualEssence = tonumber(row.dualEssence) or 0,
                lastTransform = tonumber(row.lastTransform) or 0,
                currentForm = row.currentForm or "human",
                transformed = (row.currentForm ~= "human")
            }
        end
    end
end

function SyncHybridData()
    if SERVER then
        if timer.Exists("SyncHybridDataTimer") then return end
        timer.Create("SyncHybridDataTimer", 1, 1, function()
            net.Start("SyncHybridData")
            net.WriteTable(hybrids)
            net.Broadcast()
        end)
    end
end

function MakeHybrid(ply)
    if not ply:IsPlayer() then return end
    
    
    if IsVampire(ply) then
        RemoveVampire(ply)
    end
    if IsWerewolf(ply) then
        RemoveWerewolf(ply)
    end
    if IsHunter(ply) then
        RemoveHunter(ply)
    end
    
    hybrids[ply:SteamID()] = { 
        blood = 0, 
        rage = 0,
        tier = "Cursed", 
        balance = 0, 
        dualEssence = 0,
        lastTransform = 0,
        currentForm = "human",
        transformed = false
    }
    
    UpdateHybridStats(ply)
    ply:ChatPrint("You have become a hybrid! The curse of both vampire and werewolf flows through your veins...")
    ply:Give("weapon_hybrid_claws")
    SaveHybridData()
    SyncHybridData()
    
    if SERVER then
        UpdateHybridHUD(ply)
    end
end

function RemoveHybrid(ply)
    if not ply:IsPlayer() then return end
    
    
    if hybrids[ply:SteamID()] and hybrids[ply:SteamID()].transformed then
        EndHybridTransformation(ply)
    end
    
    hybrids[ply:SteamID()] = nil
    RemoveHybridData(ply:SteamID())
    ResetHybridPerks(ply)
    SyncHybridData()
    ply:ChatPrint("You have been freed from the hybrid curse!")
    SaveHybridData()
    
    if SERVER then
        UpdateHybridHUD(ply)
    end
end

function ResetHybridPerks(ply)
    ply:SetRunSpeed(250)
    ply:SetHealth(100)
    ply:ConCommand("pp_mat_overlay ''")
end

function IsHybrid(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    return hybrids[ply:SteamID()] ~= nil
end

function GetHybridBalance(ply)
    if not IsHybrid(ply) then return 0 end
    return hybrids[ply:SteamID()].balance or 0
end

function GetHybridBalanceType(balance)
    if balance <= -50 then
        return "vampire"
    elseif balance >= 50 then
        return "werewolf" 
    else
        return "balanced"
    end
end

function ShiftHybridBalance(ply, vampireAmount, werewolfAmount)
    if not IsHybrid(ply) then return end
    
    local hybrid = hybrids[ply:SteamID()]
    local oldBalance = hybrid.balance
    local newBalance = math.max(-100, math.min(100, hybrid.balance + vampireAmount + werewolfAmount))
    
    hybrid.balance = newBalance
    
    
    if math.abs(newBalance - oldBalance) >= 5 then
        local balanceType = GetHybridBalanceType(newBalance)
        local balanceDescription = ""
        
        if balanceType == "vampire" then
            balanceDescription = "Your vampire nature grows stronger..."
        elseif balanceType == "werewolf" then
            balanceDescription = "Your werewolf nature grows stronger..."
        else
            balanceDescription = "You feel balanced between both natures."
        end
        
        ply:ChatPrint(balanceDescription)
        
        if SERVER then
            net.Start("HybridBalanceShift")
            net.WriteInt(newBalance, 16)
            net.WriteString(balanceType)
            net.Send(ply)
        end
    end
    
    UpdateHybridStats(ply)
    SaveHybridData()
    SyncHybridData()
end

function UpdateHybridStats(ply)
    local hybrid = hybrids[ply:SteamID()]
    if not hybrid then return end

    local tier = hybrid.tier
    local config = HybridConfig.Tiers[tier]
    local balance = hybrid.balance
    local balanceType = GetHybridBalanceType(balance)
    
    
    local health = config.health
    local speed = config.speed
    
    
    if balanceType == "vampire" then
        local effects = HybridConfig.DualNature.vampireLeaning.effects
        if effects.bloodEfficiency then
            
        end
    elseif balanceType == "werewolf" then
        local effects = HybridConfig.DualNature.werewolfLeaning.effects
        if effects.moonPowerBonus then
            local moonPhase = WerewolfConfig and WerewolfConfig.MoonPhases and WerewolfConfig.MoonPhases[CurrentMoonPhase]
            if moonPhase then
                health = health * moonPhase.multiplier
                speed = speed * moonPhase.multiplier
            end
        end
    else 
        local effects = HybridConfig.DualNature.balanced.effects
        if effects.resistanceBonus then
            health = health * effects.resistanceBonus
        end
    end
    
    
    if hybrid.transformed and hybrid.currentForm then
        local transformConfig = HybridConfig.Transformations[hybrid.currentForm]
        if transformConfig then
            health = health * transformConfig.effects.healthMultiplier
            speed = speed * transformConfig.effects.speedMultiplier
        end
    end

    ply:SetHealth(math.floor(health))
    ply:SetRunSpeed(math.floor(speed))

    
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
        UpdateHybridHUD(ply)
    end
end

function AddBloodToHybrid(ply, amount)
    if not IsHybrid(ply) then return end
    
    local hybrid = hybrids[ply:SteamID()]
    local balanceType = GetHybridBalanceType(hybrid.balance)
    local actualAmount = amount
    
    
    if balanceType == "vampire" then
        actualAmount = actualAmount * 1.5 
    end
    
    hybrid.blood = (hybrid.blood or 0) + actualAmount
    
    
    ShiftHybridBalance(ply, 2, -1)
    
    CheckHybridTierProgression(ply)
    SaveHybridData()
    SyncHybridData()
    
    if SERVER then
        UpdateHybridHUD(ply)
    end
end

function AddRageToHybrid(ply, amount)
    if not IsHybrid(ply) then return end
    
    local hybrid = hybrids[ply:SteamID()]
    local balanceType = GetHybridBalanceType(hybrid.balance)
    local actualAmount = amount
    
    
    if balanceType == "werewolf" then
        actualAmount = actualAmount * 1.3 
    end
    
    hybrid.rage = math.min(100, (hybrid.rage or 0) + actualAmount)
    
    
    ShiftHybridBalance(ply, -1, 2)
    
    CheckHybridTierProgression(ply)
    SaveHybridData()
    SyncHybridData()
    
    if SERVER then
        UpdateHybridHUD(ply)
    end
end

function CheckHybridTierProgression(ply)
    local hybrid = hybrids[ply:SteamID()]
    if not hybrid then return end
    
    local totalPower = (hybrid.blood or 0) + (hybrid.rage or 0)
    local newTier = hybrid.tier
    
    
    for tier, config in SortedPairsByMemberValue(HybridConfig.Tiers, "totalThreshold", true) do
        if totalPower >= config.totalThreshold and 
           (hybrid.blood >= config.bloodThreshold) and 
           (hybrid.rage >= config.rageThreshold) then
            newTier = tier
            break
        end
    end
    
    if newTier ~= hybrid.tier then
        hybrid.tier = newTier
        UpdateHybridStats(ply)
        
        if SERVER then
            net.Start("NewHybridTierMessage")
            net.WriteString("You have ascended to: " .. newTier)
            net.Send(ply)
        end
        
        ply:ChatPrint("Your hybrid nature has evolved! You are now: " .. newTier)
    end
end

function StartHybridTransformation(ply, formType)
    if not IsHybrid(ply) then return false end
    
    local hybrid = hybrids[ply:SteamID()]
    local transformConfig = HybridConfig.Transformations[formType]
    
    if not transformConfig then return false end
    
    
    local balance = hybrid.balance
    local balanceType = GetHybridBalanceType(balance)
    
    if transformConfig.requirements.balance == "vampire" and balanceType ~= "vampire" then
        ply:ChatPrint("Your vampire nature is not strong enough!")
        return false
    elseif transformConfig.requirements.balance == "werewolf" and balanceType ~= "werewolf" then
        ply:ChatPrint("Your werewolf nature is not strong enough!")
        return false
    elseif transformConfig.requirements.balance == "balanced" and balanceType ~= "balanced" then
        ply:ChatPrint("You must be perfectly balanced to use this form!")
        return false
    end
    
    if transformConfig.requirements.tier then
        local tierOrder = {"Cursed", "Conflicted", "Awakened", "Dual Soul", "Eclipse Walker", "Apex Hybrid", "Primordial"}
        local currentTierIndex = table.KeyFromValue(tierOrder, hybrid.tier)
        local requiredTierIndex = table.KeyFromValue(tierOrder, transformConfig.requirements.tier)
        
        if not currentTierIndex or not requiredTierIndex or currentTierIndex < requiredTierIndex then
            ply:ChatPrint("You need to reach " .. transformConfig.requirements.tier .. " tier!")
            return false
        end
    end
    
    
    local currentTime = CurTime()
    if currentTime - hybrid.lastTransform < transformConfig.cooldown then
        ply:ChatPrint("Transformation is on cooldown!")
        return false
    end
    
    hybrid.transformed = true
    hybrid.currentForm = formType
    hybrid.lastTransform = currentTime
    
    if SERVER then
        net.Start("HybridTransformationStart")
        net.WriteString(formType)
        net.Send(ply)
        
        ply:ChatPrint("You transform into your " .. formType .. "!")
        ply:EmitSound("ambient/creatures/town_child_scream1.wav", 75, 50)
        
        
        timer.Create("HybridTransform_" .. ply:SteamID(), transformConfig.duration, 1, function()
            if IsValid(ply) and IsHybrid(ply) then
                EndHybridTransformation(ply)
            end
        end)
        
        
        if formType == "eclipseForm" then
            timer.Create("EclipseDrain_" .. ply:SteamID(), 1, transformConfig.duration, function()
                if IsValid(ply) and IsHybrid(ply) then
                    local hybrid = hybrids[ply:SteamID()]
                    if hybrid then
                        hybrid.blood = math.max(0, hybrid.blood - 10)
                        hybrid.rage = math.max(0, hybrid.rage - 5)
                        UpdateHybridHUD(ply)
                    end
                end
            end)
        end
    end
    
    UpdateHybridStats(ply)
    SaveHybridData()
    SyncHybridData()
    return true
end

function EndHybridTransformation(ply)
    if not IsHybrid(ply) then return end
    
    local hybrid = hybrids[ply:SteamID()]
    hybrid.transformed = false
    local oldForm = hybrid.currentForm
    hybrid.currentForm = "human"
    
    if SERVER then
        net.Start("HybridTransformationEnd")
        net.WriteString(oldForm or "unknown")
        net.Send(ply)
        
        ply:ChatPrint("You return to your human form.")
        timer.Remove("HybridTransform_" .. ply:SteamID())
        timer.Remove("EclipseDrain_" .. ply:SteamID())
    end
    
    UpdateHybridStats(ply)
    SaveHybridData()
    SyncHybridData()
end


if SERVER then
    timer.Create("HybridResourceDecay", 1, 0, function()
        for steamID, hybrid in pairs(hybrids) do
            if hybrid.blood > 0 then
                hybrid.blood = math.max(0, hybrid.blood - HybridConfig.Resources.bloodDecay)
            end
            if hybrid.rage > 0 then
                hybrid.rage = math.max(0, hybrid.rage - HybridConfig.Resources.rageDecay)
            end
            
            local ply = player.GetBySteamID(steamID)
            if IsValid(ply) then
                UpdateHybridHUD(ply)
            end
        end
    end)
    
    function UpdateHybridHUD(ply)
        if not IsHybrid(ply) then return end
        local hybrid = hybrids[ply:SteamID()]
        net.Start("UpdateHybridHUD")
        net.WriteInt(hybrid.blood or 0, 32)
        net.WriteInt(hybrid.rage or 0, 32)
        net.WriteString(hybrid.tier or "Cursed")
        net.WriteInt(hybrid.balance or 0, 16)
        net.WriteInt(hybrid.dualEssence or 0, 16)
        net.WriteString(hybrid.currentForm or "human")
        net.WriteBool(hybrid.transformed or false)
        net.Send(ply)
    end
end


hook.Add("PlayerInitialSpawn", "LoadHybridData", function(ply)
    LoadHybridData(ply)
end)

hook.Add("PlayerDisconnected", "SaveHybridData", function(ply)
    SaveHybridData(ply)
end)

hook.Add("Initialize", "LoadHybridData", LoadHybridData)
hook.Add("ShutDown", "SaveHybridData", SaveHybridData)

hook.Add("PlayerInitialSpawn", "SyncHybridData", function(ply)
    net.Start("SyncHybridData")
    net.WriteTable(hybrids)
    net.Send(ply)
end)

hook.Add("PlayerSpawn", "HybridPlayerSpawn", function(ply)
    if IsHybrid(ply) then
        UpdateHybridStats(ply)
        ply:Give("weapon_hybrid_claws")
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHybridStats(ply)
            end
        end)
    end
end)

hook.Add("PlayerDeath", "HybridPlayerDeath", function(ply)
    if IsHybrid(ply) then
        
        if hybrids[ply:SteamID()] and hybrids[ply:SteamID()].transformed then
            EndHybridTransformation(ply)
        end
        
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHybridStats(ply)
            end
        end)
    end
end)

hook.Add("PlayerDeath", "HybridKillRewards", function(victim, inflictor, attacker)
    if IsHybrid(attacker) then
        local bloodGain = 30
        local rageGain = 15
        
        
        if IsVampire(victim) then
            bloodGain = bloodGain * 1.5
            ShiftHybridBalance(attacker, -5, 3) 
            attacker:ChatPrint("You gained extra power from killing a vampire!")
        elseif IsWerewolf(victim) then
            rageGain = rageGain * 1.5
            ShiftHybridBalance(attacker, 3, -5) 
            attacker:ChatPrint("You gained extra power from killing a werewolf!")
        elseif IsHunter(victim) then
            bloodGain = bloodGain * 1.2
            rageGain = rageGain * 1.2
            ShiftHybridBalance(attacker, 1, 1) 
            attacker:ChatPrint("You gained power from killing a hunter!")
        end
        
        AddBloodToHybrid(attacker, bloodGain)
        AddRageToHybrid(attacker, rageGain)
        
        
        local hybrid = hybrids[attacker:SteamID()]
        if hybrid then
            hybrid.dualEssence = math.min(HybridConfig.Resources.dualEssence.maxAmount, 
                                         (hybrid.dualEssence or 0) + HybridConfig.Resources.dualEssence.gainRate)
        end
    end
end)