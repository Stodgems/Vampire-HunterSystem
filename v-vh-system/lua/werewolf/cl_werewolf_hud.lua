

local werewolfRage = 0
local werewolfTier = "Pup"
local werewolfMoonEssence = 0
local werewolfMoonPhase = "First Quarter"
local werewolfTransformed = false

net.Receive("UpdateWerewolfHUD", function()
    werewolfRage = net.ReadInt(32)
    werewolfTier = net.ReadString()
    werewolfMoonEssence = net.ReadInt(32)
    werewolfMoonPhase = net.ReadString()
    werewolfTransformed = net.ReadBool()
end)

net.Receive("NewWerewolfTierMessage", function()
    local message = net.ReadString()
    chat.AddText(Color(139, 69, 19), "[Werewolf] ", Color(255, 255, 255), message)
    
    
    notification.AddLegacy(message, NOTIFY_GENERIC, 5)
    surface.PlaySound("buttons/bell1.wav")
end)

net.Receive("WerewolfTransformationStart", function()
    chat.AddText(Color(139, 69, 19), "[Werewolf] ", Color(255, 165, 0), "You feel the beast awaken within you!")
    
    
    local effectData = EffectData()
    effectData:SetOrigin(LocalPlayer():GetPos())
    util.Effect("explosion", effectData)
    
    
    util.ScreenShake(LocalPlayer():GetPos(), 5, 5, 2, 100)
    
    notification.AddLegacy("Transformation activated!", NOTIFY_HINT, 3)
end)

net.Receive("WerewolfTransformationEnd", function()
    chat.AddText(Color(139, 69, 19), "[Werewolf] ", Color(100, 100, 100), "The beast retreats... for now.")
    notification.AddLegacy("Transformation ended", NOTIFY_UNDO, 2)
end)


local moonPhaseColors = {
    ["New Moon"] = Color(50, 50, 50),
    ["Waxing Crescent"] = Color(100, 100, 100),
    ["First Quarter"] = Color(150, 150, 150),
    ["Waxing Gibbous"] = Color(200, 200, 200),
    ["Full Moon"] = Color(255, 255, 100),
    ["Waning Gibbous"] = Color(200, 200, 200),
    ["Last Quarter"] = Color(150, 150, 150),
    ["Waning Crescent"] = Color(100, 100, 100)
}

local function DrawWerewolfHUD()
    if not IsWerewolf(LocalPlayer()) then return end

    local scrW, scrH = ScrW(), ScrH()
    
    
    local hudX = 20
    local hudY = scrH - 160
    local hudW = 250
    local hudH = 140
    
    
    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawRect(hudX, hudY, hudW, hudH)
    
    
    surface.SetDrawColor(139, 69, 19, 255) 
    surface.DrawOutlinedRect(hudX, hudY, hudW, hudH, 2)
    
    
    surface.SetFont("DermaDefault")
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(hudX + 10, hudY + 5)
    surface.DrawText("WEREWOLF STATUS")
    
    
    surface.SetTextPos(hudX + 10, hudY + 25)
    surface.SetTextColor(200, 150, 100, 255)
    surface.DrawText("Tier: " .. werewolfTier)
    
    
    local rageBarX = hudX + 10
    local rageBarY = hudY + 45
    local rageBarW = hudW - 20
    local rageBarH = 15
    
    
    surface.SetDrawColor(50, 50, 50, 255)
    surface.DrawRect(rageBarX, rageBarY, rageBarW, rageBarH)
    
    
    local ragePercent = werewolfRage / 100
    local rageColor = Color(255 * (1 - ragePercent), 255 * ragePercent, 0) 
    surface.SetDrawColor(rageColor.r, rageColor.g, rageColor.b, 255)
    surface.DrawRect(rageBarX, rageBarY, rageBarW * ragePercent, rageBarH)
    
    
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(rageBarX + 5, rageBarY + 1)
    surface.DrawText("Rage: " .. werewolfRage .. "/100")
    
    
    surface.SetTextPos(hudX + 10, hudY + 65)
    surface.SetTextColor(173, 216, 230, 255) 
    surface.DrawText("Moon Essence: " .. werewolfMoonEssence)
    
    
    local moonColor = moonPhaseColors[werewolfMoonPhase] or Color(255, 255, 255)
    surface.SetTextPos(hudX + 10, hudY + 85)
    surface.SetTextColor(moonColor.r, moonColor.g, moonColor.b, 255)
    surface.DrawText("Moon Phase: " .. werewolfMoonPhase)
    
    
    local moonPhaseConfig = WerewolfConfig and WerewolfConfig.MoonPhases and WerewolfConfig.MoonPhases[werewolfMoonPhase]
    if moonPhaseConfig then
        surface.SetFont("DermaDefault")
        surface.SetTextColor(180, 180, 180, 255)
        surface.SetTextPos(hudX + 10, hudY + 105)
        local effectText = "Effect: " .. string.format("%.0f%%", moonPhaseConfig.multiplier * 100)
        surface.DrawText(effectText)
    end
    
    
    if werewolfTransformed then
        surface.SetTextColor(255, 0, 0, math.sin(CurTime() * 8) * 127 + 128) 
        surface.SetTextPos(hudX + 10, hudY + 120)
        surface.DrawText("🌕 TRANSFORMED 🌕")
    end
end

local function DrawTransformationIndicator()
    if not IsWerewolf(LocalPlayer()) or not werewolfTransformed then return end
    
    local scrW, scrH = ScrW(), ScrH()
    
    
    local alpha = math.sin(CurTime() * 6) * 30 + 50
    surface.SetDrawColor(139, 69, 19, alpha)
    
    
    surface.DrawRect(0, 0, scrW, 10)
    
    surface.DrawRect(0, scrH - 10, scrW, 10)
    
    surface.DrawRect(0, 0, 10, scrH)
    
    surface.DrawRect(scrW - 10, 0, 10, scrH)
end


hook.Add("HUDPaint", "WerewolfHUD", function()
    DrawWerewolfHUD()
    DrawTransformationIndicator()
end)


hook.Add("HUDShouldDraw", "WerewolfHideHUD", function(name)
    if not IsWerewolf(LocalPlayer()) or not werewolfTransformed then return end
    
    
    if name == "CHudCrosshair" and werewolfTransformed then
        return false 
    end
end)


local function DrawControlHints()
    if not IsWerewolf(LocalPlayer()) then return end
    
    local scrW, scrH = ScrW(), ScrH()
    
    
    surface.SetFont("DermaDefault")
    surface.SetTextColor(200, 200, 200, 200)
    surface.SetTextPos(scrW - 200, scrH - 40)
    surface.DrawText("Press 'T' and type !transform")
    
    
    local werewolf = werewolves[LocalPlayer():SteamID()]
    if werewolf and werewolf.lastTransform then
        local cooldownTime = WerewolfConfig.Transformation.cooldown
        local timeSinceTransform = CurTime() - werewolf.lastTransform
        local timeRemaining = cooldownTime - timeSinceTransform
        
        if timeRemaining > 0 and not werewolf.transformed then
            surface.SetTextPos(scrW - 200, scrH - 60)
            surface.SetTextColor(255, 100, 100, 200)
            surface.DrawText("Transform cooldown: " .. math.ceil(timeRemaining) .. "s")
        end
    end
end

hook.Add("HUDPaint", "WerewolfControlHints", DrawControlHints)