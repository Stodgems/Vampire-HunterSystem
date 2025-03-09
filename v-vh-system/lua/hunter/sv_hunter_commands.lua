-- Hunter Commands

-- Command to turn a player into a hunter
concommand.Add("make_hunter", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    local target = args[1]
    local targetPlayer = player.GetBySteamID(target)
    if targetPlayer then
        MakeHunter(targetPlayer)
    else
        ply:ChatPrint("Player not found.")
    end
end)

-- Command to add experience to a hunter
concommand.Add("add_experience", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    local target = args[1]
    local amount = tonumber(args[2])
    local targetPlayer = player.GetBySteamID(target)
    if targetPlayer and amount then
        AddExperience(targetPlayer, amount)
    else
        ply:ChatPrint("Invalid arguments.")
    end
end)
