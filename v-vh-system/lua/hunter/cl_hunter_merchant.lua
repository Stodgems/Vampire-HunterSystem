-- Hunter Merchant Menu

local HunterMerchantItems = {}

net.Receive("SyncHunterMerchantItems", function()
    HunterMerchantItems = net.ReadTable()
end)

net.Receive("OpenHunterMerchantMenu", function()
    local items = HunterMerchantItems

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Hunter Merchant")
    frame:SetSize(300, 400)
    frame:Center()
    frame:MakePopup()

    local weaponList = vgui.Create("DPanelList", frame)
    weaponList:Dock(FILL)
    weaponList:SetSpacing(5)
    weaponList:EnableVerticalScrollbar(true)

    for _, item in ipairs(items) do
        local panel = vgui.Create("DPanel")
        panel:SetTall(50)

        local nameLabel = vgui.Create("DLabel", panel)
        nameLabel:SetText(item.class)
        nameLabel:Dock(LEFT)
        nameLabel:SetWide(150)

        local costLabel = vgui.Create("DLabel", panel)
        costLabel:SetText("Cost: " .. item.cost .. " hearts")
        costLabel:Dock(LEFT)
        costLabel:SetWide(100)

        local buyButton = vgui.Create("DButton", panel)
        buyButton:SetText("Buy")
        buyButton:Dock(RIGHT)
        buyButton.DoClick = function()
            net.Start("BuyHunterWeapon")
            net.WriteString(item.class)
            net.WriteInt(item.cost, 32)
            net.SendToServer()
        end

        weaponList:AddItem(panel)
    end
end)
