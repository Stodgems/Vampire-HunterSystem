-- Vampire Perk Menu

include("vampire_perk_config.lua")

local perkPositions = {}
local activePerks = {}

local function OpenVampirePerkMenu()
    if IsValid(VampirePerkMenu) then return end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Vampire Perk Trainer")
    frame:SetSize(800, 600) -- Increase the frame size to accommodate longer text
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false) -- Remove the default close button
    frame:SetBackgroundBlur(true)
    frame:SetDraggable(true)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(50, 50, 50, 200)) -- Slightly see-through grey background
    end
    VampirePerkMenu = frame

    frame.OnClose = function()
        VampirePerkMenu = nil
    end

    -- Add custom "X" close button
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetText("X")
    closeButton:SetFont("Trebuchet24")
    closeButton:SetSize(30, 30)
    closeButton:SetPos(frame:GetWide() - 35, 5)
    closeButton.DoClick = function()
        frame:Close()
    end

    local tree = vgui.Create("DPanel", frame)
    tree:Dock(FILL)
    tree:DockMargin(10, 10, 10, 10)
    tree.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(50, 50, 50, 200)) -- Slightly see-through grey background
    end

    local perkPanels = {}
    local yOffset = 0

    for perkName, perk in pairs(VampirePerkConfig.Perks) do
        if not activePerks[perkName] then continue end

        local text = perkName .. " - " .. perk.cost .. " blood"
        surface.SetFont("Trebuchet24")
        local textWidth, textHeight = surface.GetTextSize(text)

        local panel = vgui.Create("DPanel", tree)
        panel:SetSize(textWidth + 150, textHeight + 20) -- Increase width to accommodate longer text
        local pos = perkPositions[perkName] or { x = 200, y = yOffset }
        panel:SetPos(pos.x, pos.y)
        panel.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, Color(50, 50, 50, 200)) -- Slightly see-through grey background
        end

        local label = vgui.Create("DLabel", panel)
        label:SetText(text)
        label:SetFont("Trebuchet24")
        label:SizeToContents() -- Automatically adjust the size to fit the text
        label:Dock(LEFT)
        label:DockMargin(10, 10, 0, 10)
        label:SetTextColor(Color(255, 255, 255))

        local button = vgui.Create("DButton", panel)
        button:SetText("Buy")
        button:SetSize(50, textHeight)
        button:SetPos(panel:GetWide() - 60, 10)
        button.DoClick = function()
            net.Start("BuyVampirePerk")
            net.WriteString(perkName)
            net.SendToServer()
            frame:Close()
        end

        perkPanels[perkName] = panel
        yOffset = yOffset + panel:GetTall() + 30 -- Add space between perks

        -- Delay the check until LocalPlayer is available
        timer.Simple(0.1, function()
            if IsValid(LocalPlayer()) then
                if perk.requires and not LocalPlayerHasVampirePerk(perk.requires) then
                    button:SetEnabled(false)
                end

                if LocalPlayerHasVampirePerk(perkName) then
                    button:SetText("Purchased")
                    button:SetEnabled(false)
                end
            end
        end)
    end

    -- Draw lines connecting the perks based on their requirements
    tree.PaintOver = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        for perkName, perk in pairs(VampirePerkConfig.Perks) do
            if perk.requires and activePerks[perkName] and activePerks[perk.requires] then
                local startPanel = perkPanels[perk.requires]
                local endPanel = perkPanels[perkName]
                if startPanel and endPanel then
                    local startX, startY = startPanel:GetPos()
                    local endX, endY = endPanel:GetPos()
                    startX = startX + startPanel:GetWide() / 2
                    startY = startY
                    endX = endX + endPanel:GetWide() / 2
                    endY = endY + endPanel:GetTall()
                    surface.DrawLine(startX, startY, endX, endY)
                end
            end
        end
    end
end

net.Receive("LoadVampirePerkPositions", function()
    perkPositions = net.ReadTable()
    activePerks = net.ReadTable()
    OpenVampirePerkMenu()
end)

net.Receive("OpenVampirePerkMenu", function()
    net.Start("RequestVampirePerkPositions")
    net.SendToServer()
end)

net.Receive("OpenVampirePerkMenu", OpenVampirePerkMenu)

-- Function to check if a player has a specific perk
function LocalPlayerHasVampirePerk(perkName)
    local ply = LocalPlayer()
    return ply.VampirePerks and ply.VampirePerks[perkName] or false
end

-- Update the player's perks when they are received from the server
net.Receive("UpdateVampirePerks", function()
    LocalPlayer().VampirePerks = net.ReadTable()
end)
