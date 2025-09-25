

local HunterMerchantItems = {}
local PurchasedItems = {}

net.Receive("SyncHunterMerchantItems", function()
    HunterMerchantItems = net.ReadTable()
end)

net.Receive("SyncPurchasedItems", function()
    PurchasedItems = net.ReadTable()
end)

net.Receive("OpenHunterMerchantMenu", function()
    local items = HunterMerchantItems

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Hunter Merchant")
    frame:SetSize(550, 600)
    frame:Center()
    frame:MakePopup()

    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:Dock(FILL)

    for _, item in ipairs(items) do
        local itemPanel = scrollPanel:Add("DPanel")
        itemPanel:SetTall(60)
        itemPanel:Dock(TOP)
        itemPanel:DockMargin(5, 5, 5, 0)

        local weapon = weapons.Get(item.class)
        local printName = weapon and weapon.PrintName or item.class
        local model = weapon and weapon.WorldModel or "models/props_junk/PopCan01a.mdl"

        local icon = vgui.Create("SpawnIcon", itemPanel)
        icon:SetModel(model)
        icon:Dock(LEFT)
        icon:SetSize(60, 60)

        local nameLabel = vgui.Create("DLabel", itemPanel)
        nameLabel:SetText(printName)
        nameLabel:SetFont("Trebuchet24")
        nameLabel:Dock(LEFT)
        nameLabel:SetWide(200)
        nameLabel:SetTextColor(Color(245, 210, 52))

        local costLabel = vgui.Create("DLabel", itemPanel)
        costLabel:SetText("Cost: " .. item.cost .. " hearts")
        costLabel:SetFont("Trebuchet24")
        costLabel:Dock(LEFT)
        costLabel:SizeToContents()
        costLabel:SetTextColor(Color(255, 0, 0))

        local buyButton = vgui.Create("DButton", itemPanel)
        buyButton:SetText("Buy")
        buyButton:SetFont("Trebuchet24")
        buyButton:Dock(RIGHT)
        buyButton:SetWide(80)

        local function updateButtonText(text)
            buyButton:SetText(text)
            buyButton:SizeToContentsX(20)
            buyButton:SetWide(math.max(buyButton:GetWide(), 80))
        end

        if table.HasValue(PurchasedItems, item.class) then
            updateButtonText("Purchased")
            buyButton:SetEnabled(false)
            buyButton:SetTextColor(Color(150, 150, 150))
        else
            buyButton.DoClick = function()
                net.Start("BuyHunterWeapon")
                net.WriteString(item.class)
                net.WriteInt(item.cost, 32)
                net.SendToServer()
                updateButtonText("Purchased")
                buyButton:SetEnabled(false)
                buyButton:SetTextColor(Color(150, 150, 150))
            end
        end
    end
end)
