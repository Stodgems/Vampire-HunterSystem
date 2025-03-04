-- Vampire Perk Admin Panel

include("vampire_perk_config.lua")

local perkPositions = {}
local activePerks = {}

local function OpenVampirePerkAdminPanel()
    if IsValid(VampirePerkAdminPanel) then return end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Vampire Perk Admin Panel")
    frame:SetSize(800, 600)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false) -- Remove the default close button
    frame:SetBackgroundBlur(true)
    frame:SetDraggable(true)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(50, 50, 50, 200)) -- Slightly see-through grey background
    end
    VampirePerkAdminPanel = frame

    frame.OnClose = function()
        VampirePerkAdminPanel = nil
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
        local text = perkName .. " - " .. perk.cost .. " blood"
        surface.SetFont("Trebuchet24")
        local textWidth, textHeight = surface.GetTextSize(text)

        local panel = vgui.Create("DPanel", tree)
        panel:SetSize(textWidth + 100, textHeight + 20)
        local pos = perkPositions[perkName] or { x = 200, y = yOffset }
        panel:SetPos(pos.x, pos.y)
        panel:SetMouseInputEnabled(true)
        panel.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, Color(50, 50, 50, 200)) -- Slightly see-through grey background
        end

        local label = vgui.Create("DLabel", panel)
        label:SetText(text)
        label:SetFont("Trebuchet24")
        label:Dock(LEFT)
        label:DockMargin(10, 10, 0, 10)
        label:SetTextColor(Color(255, 255, 255))

        -- Implement custom dragging logic
        panel.OnMousePressed = function(self)
            self:MouseCapture(true)
            self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
            self:MouseCapture(true)
        end

        panel.OnMouseReleased = function(self)
            self:MouseCapture(false)
            self.Dragging = nil
        end

        panel.Think = function(self)
            if self.Dragging then
                local x, y = gui.MousePos()
                self:SetPos(x - self.Dragging[1], y - self.Dragging[2])
            end
        end

        perkPanels[perkName] = panel
        yOffset = yOffset + panel:GetTall() + 30 -- Add space between perks

        -- Add checkbox to toggle active state
        local checkbox = vgui.Create("DCheckBoxLabel", panel)
        checkbox:SetText("Active")
        checkbox:SetValue(activePerks[perkName] and 1 or 0)
        checkbox:Dock(RIGHT)
        checkbox:DockMargin(0, 10, 10, 10)
        checkbox.OnChange = function(self, val)
            activePerks[perkName] = val
        end
    end

    local saveButton = vgui.Create("DButton", frame)
    saveButton:SetText("Save Positions")
    saveButton:SetSize(100, 30)
    saveButton:SetPos(frame:GetWide() - 110, frame:GetTall() - 40)
    saveButton.DoClick = function()
        local positions = {}
        for perkName, panel in pairs(perkPanels) do
            local x, y = panel:GetPos()
            positions[perkName] = { x = x, y = y }
        end
        net.Start("SaveVampirePerkPositions")
        net.WriteTable(positions)
        net.SendToServer()

        net.Start("SaveActivePerks")
        net.WriteTable(activePerks)
        net.SendToServer()

        frame:Close()
    end
end

net.Receive("LoadVampirePerkAdminPositions", function()
    perkPositions = net.ReadTable()
    activePerks = net.ReadTable()
    OpenVampirePerkAdminPanel()
end)

concommand.Add("open_vampire_perk_admin", function()
    local ply = LocalPlayer()
    local rank = ply:GetUserGroup()
    if table.HasValue(VampirePerkConfig.AllowedAdminRanks, rank) then
        net.Start("RequestVampirePerkAdminPositions")
        net.SendToServer()
    else
        ply:ChatPrint("You do not have permission to open the admin panel.")
    end
end)
