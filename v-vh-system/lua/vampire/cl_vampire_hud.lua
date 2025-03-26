-- Vampire HUD

local vampireData = {
    blood = 0,
    tier = "Thrall",
    medallions = 0,
    coven = "None"
}

local newTierMessage = ""
local newTierMessageTime = 0

net.Receive("UpdateVampireHUD", function()
    vampireData.blood = net.ReadInt(32)
    vampireData.tier = net.ReadString()
    vampireData.medallions = net.ReadInt(32)
    vampireData.coven = net.ReadString()

    -- Debug print to check the coven text
    print("[DEBUG] Received coven text:", vampireData.coven)
end)

net.Receive("SyncVampireCoven", function()
    vampireData.coven = net.ReadString() or "None" -- Update coven data
end)

net.Receive("SyncVampireData", function()
    vampires = net.ReadTable()
end)

net.Receive("NewTierMessage", function()
    newTierMessage = net.ReadString()
    newTierMessageTime = CurTime() + 3 -- Shorten the duration to 3 seconds
end)

local function IsVampire(ply)
    return vampires[ply:SteamID()] ~= nil
end

local function GetNextTierThreshold(tier)
    local tiers = VampireConfig.Tiers
    local nextThreshold = math.huge
    for _, config in pairs(tiers) do
        if config.threshold > tiers[tier].threshold and config.threshold < nextThreshold then
            nextThreshold = config.threshold
        end
    end
    return nextThreshold
end

local function DrawVampireHUD()
    local ply = LocalPlayer()
    if not IsVampire(ply) then return end

    local blood = vampireData.blood
    local tier = vampireData.tier
    local medallions = vampireData.medallions
    local nextThreshold = GetNextTierThreshold(tier)
    local progress = math.Clamp(blood / nextThreshold, 0, 1)

    -- Reduce the height of the background box
    draw.RoundedBox(10, 10, ScrH() - 270, 250, 140, Color(0, 0, 0, 150))

    -- Draw blood amount
    draw.SimpleText("Blood: " .. tostring(blood), "Trebuchet24", 20, ScrH() - 260, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Draw vampire tier
    draw.SimpleText("Tier: " .. tostring(tier), "Trebuchet24", 20, ScrH() - 230, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Draw medallions
    draw.SimpleText("Medallions: " .. tostring(medallions), "Trebuchet24", 20, ScrH() - 200, Color(255, 215, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Draw blood bar
    local bloodBarWidth = progress * 200
    draw.RoundedBox(5, 20, ScrH() - 170, 200, 20, Color(100, 0, 0, 150))
    draw.RoundedBox(5, 20, ScrH() - 170, bloodBarWidth, 20, Color(255, 0, 0, 255))

    -- Draw new tier message
    if newTierMessageTime > CurTime() then
        draw.SimpleText(newTierMessage, "Trebuchet24", ScrW() / 2, ScrH() / 2, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

hook.Add("HUDPaint", "DrawVampireHUD", DrawVampireHUD)
