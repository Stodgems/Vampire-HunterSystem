

include("config/sh_global_config.lua")

local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end


hook.Add("PlayerSay", "WerewolfMakeCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!makewerewolf" then
        if args[2] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                MakeWerewolf(target)
                ply:ChatPrint("Made " .. target:Nick() .. " a werewolf!")
                target:ChatPrint("You have been turned into a werewolf by " .. ply:Nick())
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !makewerewolf <player>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "WerewolfRemoveCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!removewerewolf" then
        if args[2] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsWerewolf(target) then
                    RemoveWerewolf(target)
                    ply:ChatPrint("Removed werewolf status from " .. target:Nick())
                    target:ChatPrint("Your werewolf status has been removed by " .. ply:Nick())
                else
                    ply:ChatPrint(target:Nick() .. " is not a werewolf!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !removewerewolf <player>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "WerewolfAddRageCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!addrage" then
        if args[2] and args[3] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsWerewolf(target) then
                    local amount = tonumber(args[3]) or 10
                    AddRage(target, amount)
                    ply:ChatPrint("Added " .. amount .. " rage to " .. target:Nick())
                    target:ChatPrint("You gained " .. amount .. " rage from " .. ply:Nick())
                else
                    ply:ChatPrint(target:Nick() .. " is not a werewolf!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !addrage <player> <amount>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "WerewolfForceTransformCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!forcetransform" then
        if args[2] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsWerewolf(target) then
                    local werewolf = werewolves[target:SteamID()]
                    if werewolf.transformed then
                        EndTransformation(target)
                        ply:ChatPrint("Ended transformation for " .. target:Nick())
                    else
                        
                        werewolf.lastTransform = 0
                        StartTransformation(target)
                        ply:ChatPrint("Forced transformation for " .. target:Nick())
                    end
                else
                    ply:ChatPrint(target:Nick() .. " is not a werewolf!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !forcetransform <player>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "WerewolfSetMoonPhaseCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!setmoonphase" then
        if args[2] then
            local phase = string.lower(args[2])
            local validPhases = {
                ["new"] = "New Moon",
                ["waxingcrescent"] = "Waxing Crescent", 
                ["firstquarter"] = "First Quarter",
                ["waxinggibbous"] = "Waxing Gibbous",
                ["full"] = "Full Moon",
                ["waninggibbous"] = "Waning Gibbous",
                ["lastquarter"] = "Last Quarter",
                ["waningcrescent"] = "Waning Crescent"
            }
            
            if validPhases[phase] then
                CurrentMoonPhase = validPhases[phase]
                
                net.Start("UpdateMoonPhase")
                net.WriteString(CurrentMoonPhase)
                net.Broadcast()
                
                
                for _, p in ipairs(player.GetAll()) do
                    if IsWerewolf(p) then
                        UpdateWerewolfStats(p)
                    end
                end
                
                ply:ChatPrint("Moon phase set to: " .. CurrentMoonPhase)
                for _, p in ipairs(player.GetAll()) do
                    if IsWerewolf(p) then
                        p:ChatPrint("The moon phase has changed to: " .. CurrentMoonPhase)
                    end
                end
            else
                ply:ChatPrint("Invalid moon phase! Valid phases: new, waxingcrescent, firstquarter, waxinggibbous, full, waninggibbous, lastquarter, waningcrescent")
            end
        else
            ply:ChatPrint("Usage: !setmoonphase <phase>")
            ply:ChatPrint("Valid phases: new, waxingcrescent, firstquarter, waxinggibbous, full, waninggibbous, lastquarter, waningcrescent")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "WerewolfAddMoonEssenceCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    local args = string.Explode(" ", text)
    if string.lower(args[1]) == "!addmoonessence" then
        if args[2] and args[3] then
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Nick()):find(string.lower(args[2])) then
                    target = p
                    break
                end
            end
            
            if target then
                if IsWerewolf(target) then
                    local amount = tonumber(args[3]) or 1
                    AddMoonEssence(target, amount)
                    ply:ChatPrint("Added " .. amount .. " moon essence to " .. target:Nick())
                    target:ChatPrint("You gained " .. amount .. " moon essence from " .. ply:Nick())
                else
                    ply:ChatPrint(target:Nick() .. " is not a werewolf!")
                end
            else
                ply:ChatPrint("Player not found!")
            end
        else
            ply:ChatPrint("Usage: !addmoonessence <player> <amount>")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "WerewolfListCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    if string.lower(text) == "!listwerewolves" then
        local werewolfList = {}
        for _, p in ipairs(player.GetAll()) do
            if IsWerewolf(p) then
                local werewolf = werewolves[p:SteamID()]
                local info = p:Nick() .. " (" .. werewolf.tier .. ")"
                if p.werewolfPack then
                    info = info .. " - " .. p.werewolfPack .. " (" .. p.werewolfPackRank .. ")"
                end
                if werewolf.transformed then
                    info = info .. " [TRANSFORMED]"
                end
                table.insert(werewolfList, info)
            end
        end
        
        if #werewolfList > 0 then
            ply:ChatPrint("=== WEREWOLVES ===")
            for _, info in ipairs(werewolfList) do
                ply:ChatPrint(info)
            end
            ply:ChatPrint("Current Moon Phase: " .. CurrentMoonPhase)
        else
            ply:ChatPrint("No werewolves found.")
        end
        return ""
    end
end)


hook.Add("PlayerSay", "WerewolfHelpCommand", function(ply, text)
    if not IsAdmin(ply) then return end
    
    if string.lower(text) == "!werewolfhelp" then
        ply:ChatPrint("=== WEREWOLF ADMIN COMMANDS ===")
        ply:ChatPrint("!makewerewolf <player> - Turn player into werewolf")
        ply:ChatPrint("!removewerewolf <player> - Remove werewolf status")
        ply:ChatPrint("!addrage <player> <amount> - Add rage to werewolf")
        ply:ChatPrint("!forcetransform <player> - Force/end transformation")
        ply:ChatPrint("!setmoonphase <phase> - Change moon phase")
        ply:ChatPrint("!addmoonessence <player> <amount> - Add moon essence")
        ply:ChatPrint("!listwerewolves - List all werewolves")
        ply:ChatPrint("!werewolfhelp - Show this help")
        return ""
    end
end)


hook.Add("PlayerSay", "WerewolfTransformPlayerCommand", function(ply, text)
    if string.lower(text) == "!transform" then
        if IsWerewolf(ply) then
            local werewolf = werewolves[ply:SteamID()]
            if werewolf.transformed then
                ply:ChatPrint("You are already transformed!")
            else
                local success = StartTransformation(ply)
                if not success then
                    local timeRemaining = math.ceil(WerewolfConfig.Transformation.cooldown - (CurTime() - werewolf.lastTransform))
                    ply:ChatPrint("Transformation cooldown: " .. timeRemaining .. " seconds remaining")
                end
            end
        else
            ply:ChatPrint("Only werewolves can transform!")
        end
        return ""
    end
end)