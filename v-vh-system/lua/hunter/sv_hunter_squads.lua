-- Hunter Squads Logic

hook.Add("PlayerSay", "OpenHunterSquadsMenuCommand", function(ply, text)
    if string.lower(text) == "!hsquad" then
        ply:ChatPrint("Squads are no longer available.")
        return ""
    end
end)
