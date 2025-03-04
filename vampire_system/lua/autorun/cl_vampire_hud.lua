-- Vampire HUD

local vampireData = {
    blood = 0,
    tier = "Thrall"
}

net.Receive("UpdateVampireHUD", function()
    vampireData.blood = net.ReadInt(32)
    vampireData.tier = net.ReadString()
end)

net.Receive("SyncVampireData", function()
    vampires = net.ReadTable()
end)

local function DrawVampireHUD()
    local ply = LocalPlayer()
    if not IsVampire(ply) then return end

    local blood = vampireData.blood
    local tier = vampireData.tier

    -- Draw background
    draw.RoundedBox(10, 10, ScrH() - 230, 250, 100, Color(0, 0, 0, 150))

    -- Draw blood amount
    draw.SimpleText("Blood: " .. blood .. "ml", "Trebuchet24", 20, ScrH() - 220, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Draw vampire tier
    draw.SimpleText("Tier: " .. tier, "Trebuchet24", 20, ScrH() - 190, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Draw blood bar
    local bloodBarWidth = math.Clamp(blood / 1000, 0, 1) * 200
    draw.RoundedBox(5, 20, ScrH() - 160, 200, 20, Color(100, 0, 0, 150))
    draw.RoundedBox(5, 20, ScrH() - 160, bloodBarWidth, 20, Color(255, 0, 0, 255))
end

hook.Add("HUDPaint", "DrawVampireHUD", DrawVampireHUD)
