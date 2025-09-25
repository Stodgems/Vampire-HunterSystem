

include("config/sh_global_config.lua")

local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end


hook.Add("PlayerSay", "HybridMakeCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!makehybrid" then
        if args[2] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                MakeHybrid(target)
                ply:ChatPrint("Made " .. target:Nick() .. " a hybrid!")
                target:ChatPrint("You have been turned into a hybrid by " .. ply:Nick())
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !makehybrid <player>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "HybridRemoveCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!removehybrid" then
        if args[2] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsHybrid(target) then
                    RemoveHybrid(target)
                    ply:ChatPrint("Removed hybrid status from " .. target:Nick())
                    target:ChatPrint("Your hybrid status has been removed by " .. ply:Nick())
                else
                    ply:ChatPrint(target:Nick() .. " is not a hybrid!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !removehybrid <player>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "HybridAddBloodCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!addbloodhybrid" then
        if args[2] and args[3] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsHybrid(target) then
                    local amount = tonumber(args[3]) or 50
                    AddBloodToHybrid(target, amount)
                    ply:ChatPrint("Added " .. amount .. " blood to " .. target:Nick())
                    target:ChatPrint("You gained " .. amount .. " blood from " .. ply:Nick())
                else
                    ply:ChatPrint(target:Nick() .. " is not a hybrid!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !addbloodhybrid <player> <amount>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "HybridAddRageCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!addragehybrid" then
        if args[2] and args[3] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsHybrid(target) then
                    local amount = tonumber(args[3]) or 20
                    AddRageToHybrid(target, amount)
                    ply:ChatPrint("Added " .. amount .. " rage to " .. target:Nick())
                    target:ChatPrint("You gained " .. amount .. " rage from " .. ply:Nick())
                else
                    ply:ChatPrint(target:Nick() .. " is not a hybrid!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !addragehybrid <player> <amount>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "HybridSetBalanceCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!sethybridbalance" then
        if args[2] and args[3] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsHybrid(target) then
                    local balance = tonumber(args[3])
                    if balance and balance >= -100 and balance <= 100 then
                        local hybrid = hybrids[target:SteamID()]
                        hybrid.balance = balance
                        UpdateHybridStats(target)
                        SaveHybridData()
                        SyncHybridData()
                        
                        local balanceType = GetHybridBalanceType(balance)
                        ply:ChatPrint("Set " .. target:Nick() .. "'s balance to " .. balance .. " (" .. balanceType .. ")")
                        target:ChatPrint("Your balance has been set to " .. balance .. " by " .. ply:Nick())
                    else
                        ply:ChatPrint("Balance must be between -100 and 100!")
                    end
                else
                    ply:ChatPrint(target:Nick() .. " is not a hybrid!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !sethybridbalance <player> <balance (-100 to 100)>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "HybridForceTransformCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!forcehybridtransform" then
        if args[2] and args[3] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsHybrid(target) then
                    local formType = string.lower(args[3])
                    local validForms = {
                        ["vampire"] = "vampireForm",
                        ["werewolf"] = "werewolfForm", 
                        ["eclipse"] = "eclipseForm"
                    }
                    
                    local actualForm = validForms[formType]
                    if actualForm then
                        local hybrid = hybrids[target:SteamID()]
                        if hybrid.transformed then
                            EndHybridTransformation(target)
                            ply:ChatPrint("Ended transformation for " .. target:Nick())
                        else
                            
                            hybrid.lastTransform = 0
                            local success = StartHybridTransformation(target, actualForm)
                            if success then
                                ply:ChatPrint("Forced " .. formType .. " transformation for " .. target:Nick())
                            else
                                ply:ChatPrint("Failed to transform " .. target:Nick() .. " - check their tier/balance")
                            end
                        end
                    else
                        ply:ChatPrint("Invalid form! Use: vampire, werewolf, or eclipse")
                    end
                else
                    ply:ChatPrint(target:Nick() .. " is not a hybrid!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !forcehybridtransform <player> <vampire|werewolf|eclipse>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "HybridEclipseEventCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    if string.lower(text) == "!triggereclipse" then
        
        for _, p in ipairs(player.GetAll()) do
            if IsHybrid(p) then
                local hybrid = hybrids[p:SteamID()]
                
                hybrid.eclipseBoost = true
                
                p:ChatPrint("The eclipse empowers you! All abilities enhanced!")
                p:SetHealth(p:Health() * 1.5)
                p:SetRunSpeed(p:GetRunSpeed() * 1.3)
            end
        end
        
        ply:ChatPrint("Eclipse event triggered for all hybrids!")
        
        
        timer.Simple(120, function()
            for _, p in ipairs(player.GetAll()) do
                if IsHybrid(p) then
                    local hybrid = hybrids[p:SteamID()]
                    hybrid.eclipseBoost = false
                    UpdateHybridStats(p)
                    p:ChatPrint("The eclipse ends, your power returns to normal.")
                end
            end
        end)
        
        return ""
    end
end)


hook.Add("PlayerSay", "HybridListCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    if string.lower(text) == "!listhybrids" then
        local hybridList = {}
        for _, p in ipairs(player.GetAll()) do
            if IsHybrid(p) then
                local hybrid = hybrids[p:SteamID()]
                local balanceType = GetHybridBalanceType(hybrid.balance)
                local info = p:Nick() .. " (" .. hybrid.tier .. ") - " .. balanceType .. " (" .. hybrid.balance .. ")"
                if hybrid.transformed then
                    info = info .. " [" .. (hybrid.currentForm or "unknown") .. "]"
                end
                table.insert(hybridList, info)
            end
        end
        
        if #hybridList > 0 then
            ply:ChatPrint("=== HYBRIDS ===")
            for _, info in ipairs(hybridList) do
                ply:ChatPrint(info)
            end
        else
            ply:ChatPrint("No hybrids found.")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "HybridHelpCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    if string.lower(text) == "!hybridhelp" then
        ply:ChatPrint("=== HYBRID ADMIN COMMANDS ===")
        ply:ChatPrint("!makehybrid <player> - Turn player into hybrid")
        ply:ChatPrint("!removehybrid <player> - Remove hybrid status")
        ply:ChatPrint("!addbloodhybrid <player> <amount> - Add blood")
        ply:ChatPrint("!addragehybrid <player> <amount> - Add rage")
        ply:ChatPrint("!sethybridbalance <player> <balance> - Set balance (-100 to 100)")
        ply:ChatPrint("!forcehybridtransform <player> <form> - Force transformation")
        ply:ChatPrint("!triggereclipse - Global eclipse event")
        ply:ChatPrint("!listhybrids - List all hybrids")
        ply:ChatPrint("!hybridhelp - Show this help")
        return ""
    end
end)


hook.Add("PlayerSay", "HybridTransformPlayerCommand", function(ply, text)
    if string.lower(text) == "!vampireform" then
        if IsHybrid(ply) then
            local success = StartHybridTransformation(ply, "vampireForm")
            if not success then
                local hybrid = hybrids[ply:SteamID()]
                local balanceType = GetHybridBalanceType(hybrid.balance)
                if balanceType ~= "vampire" then
                    ply:ChatPrint("Your vampire nature is not strong enough! Balance: " .. hybrid.balance)
                else
                    local timeRemaining = math.ceil(HybridConfig.Transformations.vampireForm.cooldown - (CurTime() - hybrid.lastTransform))
                    ply:ChatPrint("Vampire form cooldown: " .. timeRemaining .. " seconds remaining")
                end
            end
        else
            ply:ChatPrint("Only hybrids can transform!")
        end
        return ""
    elseif string.lower(text) == "!werewolfform" then
        if IsHybrid(ply) then
            local success = StartHybridTransformation(ply, "werewolfForm")
            if not success then
                local hybrid = hybrids[ply:SteamID()]
                local balanceType = GetHybridBalanceType(hybrid.balance)
                if balanceType ~= "werewolf" then
                    ply:ChatPrint("Your werewolf nature is not strong enough! Balance: " .. hybrid.balance)
                else
                    local timeRemaining = math.ceil(HybridConfig.Transformations.werewolfForm.cooldown - (CurTime() - hybrid.lastTransform))
                    ply:ChatPrint("Werewolf form cooldown: " .. timeRemaining .. " seconds remaining")
                end
            end
        else
            ply:ChatPrint("Only hybrids can transform!")
        end
        return ""
    elseif string.lower(text) == "!eclipseform" then
        if IsHybrid(ply) then
            local success = StartHybridTransformation(ply, "eclipseForm")
            if not success then
                local hybrid = hybrids[ply:SteamID()]
                local balanceType = GetHybridBalanceType(hybrid.balance)
                if balanceType ~= "balanced" then
                    ply:ChatPrint("You must be perfectly balanced! Current balance: " .. hybrid.balance)
                elseif hybrid.tier ~= "Eclipse Walker" and hybrid.tier ~= "Apex Hybrid" and hybrid.tier ~= "Primordial" then
                    ply:ChatPrint("You must reach Eclipse Walker tier or higher!")
                else
                    local timeRemaining = math.ceil(HybridConfig.Transformations.eclipseForm.cooldown - (CurTime() - hybrid.lastTransform))
                    ply:ChatPrint("Eclipse form cooldown: " .. timeRemaining .. " seconds remaining")
                end
            end
        else
            ply:ChatPrint("Only hybrids can use eclipse form!")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "HybridAbilityCommands", function(ply, text)
    if string.lower(text) == "!bloodrage" then
        if IsHybrid(ply) then
            local hybrid = hybrids[ply:SteamID()]
            if hybrid.blood >= 20 and hybrid.rage >= 10 then
                hybrid.blood = hybrid.blood - 20
                hybrid.rage = math.min(100, hybrid.rage + 30) 
                ply:ChatPrint("You channel your blood into rage!")
                UpdateHybridHUD(ply)
                SaveHybridData()
            else
                ply:ChatPrint("Not enough blood (20) or rage (10) to use Blood Rage!")
            end
        else
            ply:ChatPrint("Only hybrids can use Blood Rage!")
        end
        return ""
    elseif string.lower(text) == "!dualessence" then
        if IsHybrid(ply) then
            local hybrid = hybrids[ply:SteamID()]
            if hybrid.dualEssence > 0 then
                local convertAmount = math.min(hybrid.dualEssence, 5)
                hybrid.dualEssence = hybrid.dualEssence - convertAmount
                local bloodGain = convertAmount * HybridConfig.Resources.dualEssence.conversionRate
                local rageGain = convertAmount * HybridConfig.Resources.dualEssence.conversionRate / 2
                
                hybrid.blood = hybrid.blood + bloodGain
                hybrid.rage = math.min(100, hybrid.rage + rageGain)
                
                ply:ChatPrint("Converted " .. convertAmount .. " dual essence into " .. bloodGain .. " blood and " .. rageGain .. " rage!")
                UpdateHybridHUD(ply)
                SaveHybridData()
            else
                ply:ChatPrint("You have no dual essence to convert!")
            end
        else
            ply:ChatPrint("Only hybrids can use dual essence!")
        end
        return ""
    end
end)