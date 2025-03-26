-- Hunter HUD

local hunterData = {
    experience = 0,
    tier = "Novice",
    hearts = 0,
    guild = "None"
}

local newTierMessage = ""
local newTierMessageTime = 0

net.Receive("UpdateHunterHUD", function()
    hunterData.experience = net.ReadInt(32)
    hunterData.tier = net.ReadString()
    hunterData.hearts = net.ReadInt(32)
    hunterData.guild = net.ReadString()

    -- Debug print to check the guild text
    print("[DEBUG] Received guild text:", hunterData.guild)
end)

net.Receive("SyncHunterGuild", function()
    hunterData.guild = net.ReadString() or "None" -- Update guild data
end)

net.Receive("SyncHunterData", function()
    hunters = net.ReadTable()
end)

net.Receive("NewHunterTierMessage", function()
    newTierMessage = net.ReadString()
    newTierMessageTime = CurTime() + 3 -- Shorten the duration to 3 seconds
end)

local function IsHunter(ply)
    return hunters[ply:SteamID()] ~= nil
end

local function GetNextTierThreshold(tier)
    local tiers = HunterConfig.Tiers
    local nextThreshold = math.huge
    for _, config in pairs(tiers) do
        if config.threshold > tiers[tier].threshold and config.threshold < nextThreshold then
            nextThreshold = config.threshold
        end
    end
    return nextThreshold
end

local function DrawHunterHUD()
    local ply = LocalPlayer()
    if not IsHunter(ply) then return end

    local experience = hunterData.experience
    local tier = hunterData.tier
    local hearts = hunterData.hearts
    local nextThreshold = GetNextTierThreshold(tier)
    local progress = math.Clamp(experience / nextThreshold, 0, 1)

    -- Reduce the height of the background box
    draw.RoundedBox(10, 10, ScrH() - 270, 250, 140, Color(0, 0, 0, 150))

    -- Draw experience amount
    draw.SimpleText("Experience: " .. tostring(experience), "Trebuchet24", 20, ScrH() - 260, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Draw hunter tier
    draw.SimpleText("Tier: " .. tostring(tier), "Trebuchet24", 20, ScrH() - 230, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Draw vampire hearts
    draw.SimpleText("Vampire Hearts: " .. tostring(hearts), "Trebuchet24", 20, ScrH() - 200, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Draw experience bar
    local experienceBarWidth = progress * 200
    draw.RoundedBox(5, 20, ScrH() - 170, 200, 20, Color(0, 100, 0, 150))
    draw.RoundedBox(5, 20, ScrH() - 170, experienceBarWidth, 20, Color(0, 255, 0, 255))

    -- Draw new tier message
    if newTierMessageTime > CurTime() then
        draw.SimpleText(newTierMessage, "Trebuchet24", ScrW() / 2, ScrH() / 2, Color(0, 255, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

hook.Add("HUDPaint", "DrawHunterHUD", DrawHunterHUD)
