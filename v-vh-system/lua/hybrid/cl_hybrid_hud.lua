

local hybridBlood = 0
local hybridRage = 0
local hybridTier = "Cursed"
local hybridBalance = 0
local hybridDualEssence = 0
local hybridCurrentForm = "human"
local hybridTransformed = false

net.Receive("UpdateHybridHUD", function()
    hybridBlood = net.ReadInt(32)
    hybridRage = net.ReadInt(32)
    hybridTier = net.ReadString()
    hybridBalance = net.ReadInt(16)
    hybridDualEssence = net.ReadInt(16)
    hybridCurrentForm = net.ReadString()
    hybridTransformed = net.ReadBool()
end)

net.Receive("NewHybridTierMessage", function()
    local message = net.ReadString()
    chat.AddText(Color(128, 0, 128), "[Hybrid] ", Color(255, 255, 255), message)
    
    
    notification.AddLegacy(message, NOTIFY_GENERIC, 5)
    surface.PlaySound("buttons/bell1.wav")
end)

net.Receive("HybridTransformationStart", function()
    local formType = net.ReadString()
    local formName = formType:gsub("Form", "")
    chat.AddText(Color(128, 0, 128), "[Hybrid] ", Color(255, 165, 0), "You transform into " .. formName .. " form!")
    
    
    local effectData = EffectData()
    effectData:SetOrigin(LocalPlayer():GetPos())
    util.Effect("explosion", effectData)
    
    
    util.ScreenShake(LocalPlayer():GetPos(), 3, 3, 1.5, 100)
    
    notification.AddLegacy("Transformation: " .. formName, NOTIFY_HINT, 3)
end)

net.Receive("HybridTransformationEnd", function()
    local formType = net.ReadString()
    chat.AddText(Color(128, 0, 128), "[Hybrid] ", Color(100, 100, 100), "You return to human form.")
    notification.AddLegacy("Transformation ended", NOTIFY_UNDO, 2)
end)

net.Receive("HybridBalanceShift", function()
    local balance = net.ReadInt(16)
    local balanceType = net.ReadString()
    
    local balanceColor = Color(255, 255, 255)
    if balanceType == "vampire" then
        balanceColor = Color(200, 0, 0)
    elseif balanceType == "werewolf" then  
        balanceColor = Color(139, 69, 19)
    else
        balanceColor = Color(128, 0, 128)
    end
    
    chat.AddText(Color(128, 0, 128), "[Hybrid] ", balanceColor, "Balance shifted: " .. balance .. " (" .. balanceType .. ")")
end)


local function GetBalanceInfo(balance)
    if balance <= -50 then
        return Color(200, 0, 0), "Vampire Dominant", "Your vampiric nature overwhelms"
    elseif balance >= 50 then
        return Color(139, 69, 19), "Werewolf Dominant", "Your lycanthropic nature overwhelms"
    else
        return Color(128, 0, 128), "Balanced", "Perfect harmony of both natures"
    end
end

local function DrawHybridHUD()
    if not IsHybrid(LocalPlayer()) then return end

    local scrW, scrH = ScrW(), ScrH()
    
    
    local hudX = 20
    local hudY = scrH - 200
    local hudW = 300
    local hudH = 180
    
    
    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawRect(hudX, hudY, hudW, hudH)
    
    
    surface.SetDrawColor(128, 0, 128, 255)
    surface.DrawOutlinedRect(hudX, hudY, hudW, hudH, 2)
    
    
    surface.SetFont("DermaDefault")
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(hudX + 10, hudY + 5)
    surface.DrawText("HYBRID STATUS")
    
    
    surface.SetTextPos(hudX + 10, hudY + 25)
    surface.SetTextColor(128, 0, 128, 255)
    surface.DrawText("Tier: " .. hybridTier)
    
    
    local bloodBarX = hudX + 10
    local bloodBarY = hudY + 45
    local bloodBarW = (hudW - 30) / 2 - 5
    local bloodBarH = 12
    
    
    surface.SetDrawColor(50, 0, 0, 255)
    surface.DrawRect(bloodBarX, bloodBarY, bloodBarW, bloodBarH)
    
    
    local bloodPercent = math.min(hybridBlood / 1000, 1) 
    surface.SetDrawColor(200, 0, 0, 255)
    surface.DrawRect(bloodBarX, bloodBarY, bloodBarW * bloodPercent, bloodBarH)
    
    
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetFont("DermaDefault")
    surface.SetTextPos(bloodBarX + 2, bloodBarY - 1)
    surface.DrawText("Blood: " .. hybridBlood)
    
    
    local rageBarX = bloodBarX + bloodBarW + 10
    local rageBarY = bloodBarY
    
    
    surface.SetDrawColor(50, 25, 0, 255)
    surface.DrawRect(rageBarX, rageBarY, bloodBarW, bloodBarH)
    
    
    local ragePercent = hybridRage / 100
    surface.SetDrawColor(255, 165, 0, 255)
    surface.DrawRect(rageBarX, rageBarY, bloodBarW * ragePercent, bloodBarH)
    
    
    surface.SetTextPos(rageBarX + 2, rageBarY - 1)
    surface.DrawText("Rage: " .. hybridRage .. "/100")
    
    
    local balanceY = hudY + 70
    local balanceColor, balanceType, balanceDesc = GetBalanceInfo(hybridBalance)
    
    surface.SetTextPos(hudX + 10, balanceY)
    surface.SetTextColor(balanceColor.r, balanceColor.g, balanceColor.b, 255)
    surface.DrawText("Balance: " .. hybridBalance .. " (" .. balanceType .. ")")
    
    
    local balanceBarX = hudX + 10
    local balanceBarY = balanceY + 20
    local balanceBarW = hudW - 20
    local balanceBarH = 8
    
    
    surface.SetDrawColor(30, 30, 30, 255)
    surface.DrawRect(balanceBarX, balanceBarY, balanceBarW, balanceBarH)
    
    
    local balancePercent = (hybridBalance + 100) / 200 
    local balanceColorFill = Color(200, 0, 0) 
    if hybridBalance >= 50 then
        balanceColorFill = Color(139, 69, 19) 
    elseif hybridBalance >= -49 and hybridBalance <= 49 then
        balanceColorFill = Color(128, 0, 128) 
    end
    
    surface.SetDrawColor(balanceColorFill.r, balanceColorFill.g, balanceColorFill.b, 150)
    surface.DrawRect(balanceBarX, balanceBarY, balanceBarW * balancePercent, balanceBarH)
    
    
    local centerX = balanceBarX + balanceBarW / 2
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawRect(centerX - 1, balanceBarY, 2, balanceBarH)
    
    
    surface.SetTextPos(hudX + 10, balanceBarY + 20)
    surface.SetTextColor(255, 215, 0, 255) 
    surface.DrawText("Dual Essence: " .. hybridDualEssence .. "/" .. (HybridConfig and HybridConfig.Resources.dualEssence.maxAmount or 50))
    
    
    if hybridTransformed then
        local formDisplayName = hybridCurrentForm:gsub("Form", "")
        surface.SetTextPos(hudX + 10, balanceBarY + 40)
        surface.SetTextColor(255, 0, 0, math.sin(CurTime() * 8) * 127 + 128) 
        surface.DrawText("🔥 " .. string.upper(formDisplayName) .. " FORM 🔥")
    end
    
    
    surface.SetFont("DermaDefault")
    surface.SetTextColor(200, 200, 200, 200)
    surface.SetTextPos(hudX + 10, balanceBarY + 60)
    surface.DrawText("Commands: !vampireform, !werewolfform, !eclipseform")
end

local function DrawTransformationEffects()
    if not IsHybrid(LocalPlayer()) or not hybridTransformed then return end
    
    local scrW, scrH = ScrW(), ScrH()
    
    
    local effectColor = Color(255, 0, 0, 30) 
    if hybridCurrentForm == "werewolfForm" then
        effectColor = Color(139, 69, 19, 30)
    elseif hybridCurrentForm == "eclipseForm" then
        effectColor = Color(128, 0, 128, 50)
    end
    
    
    local alpha = math.sin(CurTime() * 4) * 20 + 30
    effectColor.a = alpha
    
    surface.SetDrawColor(effectColor.r, effectColor.g, effectColor.b, effectColor.a)
    
    
    local borderSize = 8
    if hybridCurrentForm == "eclipseForm" then
        borderSize = 15
    end
    
    
    surface.DrawRect(0, 0, scrW, borderSize) 
    surface.DrawRect(0, scrH - borderSize, scrW, borderSize) 
    surface.DrawRect(0, 0, borderSize, scrH) 
    surface.DrawRect(scrW - borderSize, 0, borderSize, scrH) 
end

local function DrawEclipseForm()
    if not IsHybrid(LocalPlayer()) or hybridCurrentForm ~= "eclipseForm" then return end
    
    local scrW, scrH = ScrW(), ScrH()
    
    
    local time = CurTime()
    
    
    if math.random(1, 3) == 1 then
        local x = math.random(0, scrW)
        local y = math.random(0, scrH)
        
        surface.SetMaterial(Material("sprites/light_glow02_add"))
        surface.SetDrawColor(128, 0, 128, math.random(50, 150))
        surface.DrawTexturedRect(x - 5, y - 5, 10, 10)
    end
    
    
    local centerX, centerY = scrW / 2, scrH / 2 + 50
    
    surface.SetFont("DermaLarge")
    surface.SetTextColor(128, 0, 128, math.sin(time * 6) * 100 + 155)
    surface.SetTextPos(centerX - 40, centerY)
    surface.DrawText("◐ ECLIPSE ◑")
end


hook.Add("HUDPaint", "HybridHUD", function()
    DrawHybridHUD()
    DrawTransformationEffects()
    DrawEclipseForm()
end)


hook.Add("HUDShouldDraw", "HybridHideHUD", function(name)
    if not IsHybrid(LocalPlayer()) then return end
    
    if name == "CHudCrosshair" and hybridCurrentForm == "eclipseForm" then
        return false
    end
end)


local function DrawControlHints()
    if not IsHybrid(LocalPlayer()) then return end
    
    local scrW, scrH = ScrW(), ScrH()
    
    
    local balanceColor, balanceType = GetBalanceInfo(hybridBalance)
    
    surface.SetFont("DermaDefault")
    surface.SetTextColor(200, 200, 200, 200)
    
    local hintY = scrH - 80
    if balanceType == "Vampire Dominant" then
        surface.SetTextPos(scrW - 200, hintY)
        surface.DrawText("Available: !vampireform")
    elseif balanceType == "Werewolf Dominant" then
        surface.SetTextPos(scrW - 200, hintY)
        surface.DrawText("Available: !werewolfform")
    else
        surface.SetTextPos(scrW - 250, hintY)
        surface.DrawText("Available: !vampireform, !werewolfform")
        if hybridTier == "Eclipse Walker" or hybridTier == "Apex Hybrid" or hybridTier == "Primordial" then
            surface.SetTextPos(scrW - 200, hintY + 15)
            surface.DrawText("Special: !eclipseform")
        end
    end
    
    
    surface.SetTextPos(scrW - 200, hintY + 30)
    surface.DrawText("Abilities: !bloodrage, !dualessence")
    
    
    if hybridTransformed then
        surface.SetTextPos(scrW - 200, hintY - 15)
        surface.SetTextColor(255, 100, 100, 200)
        surface.DrawText("Transformed: " .. hybridCurrentForm:gsub("Form", ""))
    end
end

hook.Add("HUDPaint", "HybridControlHints", DrawControlHints)


hook.Add("PlayerSay", "HybridHelpChat", function(ply, text)
    if ply ~= LocalPlayer() then return end
    
    if string.lower(text) == "!hybridhelp" then
        chat.AddText(Color(128, 0, 128), "[Hybrid Help]")
        chat.AddText(Color(255, 255, 255), "Transformations: !vampireform, !werewolfform, !eclipseform")
        chat.AddText(Color(255, 255, 255), "Abilities: !bloodrage (converts blood to rage), !dualessence (converts essence)")
        chat.AddText(Color(255, 255, 255), "Balance affects which forms you can use:")
        chat.AddText(Color(200, 0, 0), "  Vampire dominant (-50 to -100): Vampire form only")
        chat.AddText(Color(139, 69, 19), "  Werewolf dominant (50 to 100): Werewolf form only") 
        chat.AddText(Color(128, 0, 128), "  Balanced (-49 to 49): All forms available")
        return ""
    end
end)