-- Vampire Covens Menu

hook.Add("PlayerSay", "OpenVampireCovensMenuCommand", function(ply, text)
    if string.lower(text) == "!vcoven" then
        ply:ChatPrint("Covens are no longer available.")
        return ""
    end
end)


