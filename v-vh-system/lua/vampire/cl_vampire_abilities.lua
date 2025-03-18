-- Vampire Abilities Menu

local VampireAbilities = {}
local PurchasedAbilities = {}

net.Receive("SyncVampireAbilities", function()
    VampireAbilities = net.ReadTable()
end)

net.Receive("SyncPurchasedAbilities", function()
    PurchasedAbilities = net.ReadTable()
end)

net.Receive("OpenVampireAbilitiesMenu", function()
    local abilities = VampireAbilities

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Vampire Abilities Trainer")
    frame:SetSize(550, 600) -- Increase the width to accommodate more text
    frame:Center()
    frame:MakePopup()

    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:Dock(FILL)

    for _, ability in ipairs(abilities) do
        local abilityPanel = scrollPanel:Add("DPanel")
        abilityPanel:SetTall(60)
        abilityPanel:Dock(TOP)
        abilityPanel:DockMargin(5, 5, 5, 0)

        local weapon = weapons.Get(ability.class)
        local printName = weapon and weapon.PrintName or ability.class
        local model = weapon and weapon.WorldModel or "models/props_junk/PopCan01a.mdl"

        local icon = vgui.Create("SpawnIcon", abilityPanel)
        icon:SetModel(model)
        icon:Dock(LEFT)
        icon:SetSize(60, 60)

        local nameLabel = vgui.Create("DLabel", abilityPanel)
        nameLabel:SetText(printName)
        nameLabel:SetFont("Trebuchet24")
        nameLabel:Dock(LEFT)
        nameLabel:SetWide(200)
        nameLabel:SetTextColor(Color(245, 210, 52))

        local costLabel = vgui.Create("DLabel", abilityPanel)
        costLabel:SetText("Cost: " .. ability.cost .. " medallions")
        costLabel:SetFont("Trebuchet24")
        costLabel:Dock(LEFT)
        costLabel:SizeToContents() -- Adjust the size to fit the text
        costLabel:SetTextColor(Color(255, 0, 0))

        local buyButton = vgui.Create("DButton", abilityPanel)
        buyButton:SetText("Buy")
        buyButton:SetFont("Trebuchet24")
        buyButton:Dock(RIGHT)
        buyButton:SetWide(80)

        local function updateButtonText(text)
            buyButton:SetText(text)
            buyButton:SizeToContentsX(20) -- Add some padding
            buyButton:SetWide(math.max(buyButton:GetWide(), 80)) -- Ensure minimum width
        end

        if table.HasValue(PurchasedAbilities, ability.class) then
            updateButtonText("Purchased")
            buyButton:SetEnabled(false)
            buyButton:SetTextColor(Color(150, 150, 150))
        else
            buyButton.DoClick = function()
                net.Start("BuyVampireAbility")
                net.WriteString(ability.class)
                net.WriteInt(ability.cost, 32)
                net.SendToServer()
                updateButtonText("Purchased")
                buyButton:SetEnabled(false)
                buyButton:SetTextColor(Color(150, 150, 150))
            end
        end
    end
end)
