-- Admin Menu

net.Receive("OpenAdminMenu", function()
    print("[Vampire System] Opening Admin Menu") -- Debug print to verify the menu is opening
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Admin Menu")
    frame:SetSize(700, 600) -- Increase the width to accommodate new columns
    frame:Center()
    frame:MakePopup()

    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)

    local playerPanel = vgui.Create("DPanel", sheet)
    playerPanel:Dock(FILL)
    sheet:AddSheet("Players", playerPanel, "icon16/user.png")

    local playerList = vgui.Create("DListView", playerPanel)
    playerList:Dock(FILL)
    playerList:SetMultiSelect(false)
    playerList:AddColumn("Player")
    playerList:AddColumn("SteamID")
    playerList:AddColumn("Role")
    playerList:AddColumn("Experience/Blood")
    playerList:AddColumn("Hearts/Medallions")

    for _, ply in ipairs(player.GetAll()) do
        local role = "None"
        local expOrBlood = "N/A"
        local heartsOrMedallions = "N/A"
        if IsVampire(ply) then
            role = "Vampire"
            expOrBlood = vampires[ply:SteamID()].blood
            heartsOrMedallions = vampires[ply:SteamID()].medallions
        elseif IsHunter(ply) then
            role = "Hunter"
            expOrBlood = hunters[ply:SteamID()].experience
            heartsOrMedallions = hunters[ply:SteamID()].hearts
        end
        playerList:AddLine(ply:Nick(), ply:SteamID(), role, expOrBlood, heartsOrMedallions)
    end

    local function getSelectedPlayer()
        local selected = playerList:GetSelectedLine()
        if not selected then return nil end
        local line = playerList:GetLine(selected)
        return player.GetBySteamID(line:GetColumnText(2))
    end

    local makeVampireButton = vgui.Create("DButton", playerPanel)
    makeVampireButton:SetText("Make Vampire")
    makeVampireButton:Dock(BOTTOM)
    makeVampireButton.DoClick = function()
        local target = getSelectedPlayer()
        if target then
            net.Start("AdminMakeVampire")
            net.WriteString(target:SteamID())
            net.SendToServer()
        end
    end

    local makeHunterButton = vgui.Create("DButton", playerPanel)
    makeHunterButton:SetText("Make Hunter")
    makeHunterButton:Dock(BOTTOM)
    makeHunterButton.DoClick = function()
        local target = getSelectedPlayer()
        if target then
            net.Start("AdminMakeHunter")
            net.WriteString(target:SteamID())
            net.SendToServer()
        end
    end

    local addBloodButton = vgui.Create("DButton", playerPanel)
    addBloodButton:SetText("Add Blood")
    addBloodButton:Dock(BOTTOM)
    addBloodButton.DoClick = function()
        local target = getSelectedPlayer()
        if target then
            Derma_StringRequest("Add Blood", "Enter the amount of blood to add:", "", function(amount)
                net.Start("AdminAddBlood")
                net.WriteString(target:SteamID())
                net.WriteInt(tonumber(amount), 32)
                net.SendToServer()
            end)
        end
    end

    local addExperienceButton = vgui.Create("DButton", playerPanel)
    addExperienceButton:SetText("Add Experience")
    addExperienceButton:Dock(BOTTOM)
    addExperienceButton.DoClick = function()
        local target = getSelectedPlayer()
        if target then
            Derma_StringRequest("Add Experience", "Enter the amount of experience to add:", "", function(amount)
                net.Start("AdminAddExperience")
                net.WriteString(target:SteamID())
                net.WriteInt(tonumber(amount), 32)
                net.SendToServer()
            end)
        end
    end

    local addItemButton = vgui.Create("DButton", playerPanel)
    addItemButton:SetText("Add Item to Merchant")
    addItemButton:Dock(BOTTOM)
    addItemButton.DoClick = function()
        Derma_StringRequest("Add Item", "Enter the weapon class:", "", function(weaponClass)
            Derma_StringRequest("Add Item", "Enter the cost in hearts:", "", function(cost)
                net.Start("AdminAddMerchantItem")
                net.WriteString(weaponClass)
                net.WriteInt(tonumber(cost), 32)
                net.SendToServer()
            end)
        end)
    end

    local removeRoleButton = vgui.Create("DButton", playerPanel)
    removeRoleButton:SetText("Remove from Vampire/Hunter")
    removeRoleButton:Dock(BOTTOM)
    removeRoleButton.DoClick = function()
        local target = getSelectedPlayer()
        if target then
            net.Start("AdminRemoveRole")
            net.WriteString(target:SteamID())
            net.SendToServer()
        end
    end

    local addHeartsButton = vgui.Create("DButton", playerPanel)
    addHeartsButton:SetText("Add Hearts")
    addHeartsButton:Dock(BOTTOM)
    addHeartsButton.DoClick = function()
        local target = getSelectedPlayer()
        if target then
            Derma_StringRequest("Add Hearts", "Enter the amount of hearts to add:", "", function(amount)
                net.Start("AdminAddHearts")
                net.WriteString(target:SteamID())
                net.WriteInt(tonumber(amount), 32)
                net.SendToServer()
            end)
        end
    end

    local addMedallionsButton = vgui.Create("DButton", playerPanel)
    addMedallionsButton:SetText("Add Medallions")
    addMedallionsButton:Dock(BOTTOM)
    addMedallionsButton.DoClick = function()
        local target = getSelectedPlayer()
        if target then
            Derma_StringRequest("Add Medallions", "Enter the amount of medallions to add:", "", function(amount)
                net.Start("AdminAddMedallions")
                net.WriteString(target:SteamID())
                net.WriteInt(tonumber(amount), 32)
                net.SendToServer()
            end)
        end
    end

    local manageMerchantItemsButton = vgui.Create("DButton", playerPanel)
    manageMerchantItemsButton:SetText("Manage Merchant Items")
    manageMerchantItemsButton:Dock(BOTTOM)
    manageMerchantItemsButton.DoClick = function()
        net.Start("RequestMerchantItems")
        net.SendToServer()
    end

    local managePlayerWeaponsButton = vgui.Create("DButton", playerPanel)
    managePlayerWeaponsButton:SetText("Manage Player Weapons")
    managePlayerWeaponsButton:Dock(BOTTOM)
    managePlayerWeaponsButton.DoClick = function()
        local target = getSelectedPlayer()
        if target then
            net.Start("RequestPlayerWeapons")
            net.WriteString(target:SteamID())
            net.SendToServer()
        end
    end

    -- New tab for managing squads and covens
    local squadsCovensPanel = vgui.Create("DPanel", sheet)
    squadsCovensPanel:Dock(FILL)
    sheet:AddSheet("Squads & Covens", squadsCovensPanel, "icon16/group.png")

    local squadsCovensList = vgui.Create("DListView", squadsCovensPanel)
    squadsCovensList:Dock(FILL)
    squadsCovensList:SetMultiSelect(false)
    squadsCovensList:AddColumn("Name")
    squadsCovensList:AddColumn("Leader")

    local function populateSquadsCovensList()
        squadsCovensList:Clear()
        if HunterSquads then
            for squadID, squad in pairs(HunterSquads) do
                local leaderName = player.GetBySteamID(squad.leader) and player.GetBySteamID(squad.leader):Nick() or squad.leader
                squadsCovensList:AddLine(squad.name, leaderName)
            end
        end
        if VampireCovens then
            for covenID, coven in pairs(VampireCovens) do
                local leaderName = player.GetBySteamID(coven.leader) and player.GetBySteamID(coven.leader):Nick() or coven.leader
                squadsCovensList:AddLine(coven.name, leaderName)
            end
        end
    end

    populateSquadsCovensList()

    local manageButton = vgui.Create("DButton", squadsCovensPanel)
    manageButton:SetText("Manage")
    manageButton:Dock(BOTTOM)
    manageButton.DoClick = function()
        local selected = squadsCovensList:GetSelectedLine()
        if not selected then return end
        local line = squadsCovensList:GetLine(selected)
        local name = line:GetColumnText(1)
        local leader = line:GetColumnText(2)

        local isSquad = false
        local id = nil
        if HunterSquads then
            for squadID, squad in pairs(HunterSquads) do
                if squad.name == name and squad.leader == leader then
                    isSquad = true
                    id = squadID
                    break
                end
            end
        end
        if not isSquad and VampireCovens then
            for covenID, coven in pairs(VampireCovens) do
                if coven.name == name and coven.leader == leader then
                    id = covenID
                    break
                end
            end
        end

        if id then
            OpenManageMenu(isSquad, id)
        end
    end
end)

net.Receive("OpenMerchantItemsMenu", function()
    local items = net.ReadTable()

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Manage Merchant Items")
    frame:SetSize(400, 500)
    frame:Center()
    frame:MakePopup()

    local itemList = vgui.Create("DListView", frame)
    itemList:Dock(FILL)
    itemList:SetMultiSelect(false)
    itemList:AddColumn("Weapon Class")
    itemList:AddColumn("Cost")

    for _, item in ipairs(items) do
        itemList:AddLine(item.class, item.cost)
    end

    local function getSelectedItem()
        local selected = itemList:GetSelectedLine()
        if not selected then return nil end
        return itemList:GetLine(selected)
    end

    local editItemButton = vgui.Create("DButton", frame)
    editItemButton:SetText("Edit Item")
    editItemButton:Dock(BOTTOM)
    editItemButton.DoClick = function()
        local selectedItem = getSelectedItem()
        if selectedItem then
            local weaponClass = selectedItem:GetColumnText(1)
            Derma_StringRequest("Edit Item", "Enter the new cost in hearts:", selectedItem:GetColumnText(2), function(cost)
                net.Start("EditMerchantItem")
                net.WriteString(weaponClass)
                net.WriteInt(tonumber(cost), 32)
                net.SendToServer()
            end)
        end
    end

    local removeItemButton = vgui.Create("DButton", frame)
    removeItemButton:SetText("Remove Item")
    removeItemButton:Dock(BOTTOM)
    removeItemButton.DoClick = function()
        local selectedItem = getSelectedItem()
        if selectedItem then
            local weaponClass = selectedItem:GetColumnText(1)
            net.Start("RemoveMerchantItem")
            net.WriteString(weaponClass)
            net.SendToServer()
        end
    end
end)

net.Receive("OpenPlayerWeaponsMenu", function()
    local weapons = net.ReadTable()
    local targetSteamID = net.ReadString()

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Manage Player Weapons")
    frame:SetSize(400, 500)
    frame:Center()
    frame:MakePopup()

    local weaponList = vgui.Create("DListView", frame)
    weaponList:Dock(FILL)
    weaponList:SetMultiSelect(false)
    weaponList:AddColumn("Weapon Class")

    for _, weapon in ipairs(weapons) do
        weaponList:AddLine(weapon)
    end

    local function getSelectedWeapon()
        local selected = weaponList:GetSelectedLine()
        if not selected then return nil end
        return weaponList:GetLine(selected):GetColumnText(1)
    end

    local addWeaponButton = vgui.Create("DButton", frame)
    addWeaponButton:SetText("Add Weapon")
    addWeaponButton:Dock(BOTTOM)
    addWeaponButton.DoClick = function()
        Derma_StringRequest("Add Weapon", "Enter the weapon class:", "", function(weaponClass)
            net.Start("AdminAddPlayerWeapon")
            net.WriteString(targetSteamID)
            net.WriteString(weaponClass)
            net.SendToServer()
        end)
    end

    local removeWeaponButton = vgui.Create("DButton", frame)
    removeWeaponButton:SetText("Remove Weapon")
    removeWeaponButton:Dock(BOTTOM)
    removeWeaponButton.DoClick = function()
        local weaponClass = getSelectedWeapon()
        if weaponClass then
            net.Start("AdminRemovePlayerWeapon")
            net.WriteString(targetSteamID)
            net.WriteString(weaponClass)
            net.SendToServer()
        end
    end
end)

-- Define OpenAdminSquadManagementMenu
local function OpenAdminSquadManagementMenu()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Admin Squad Management")
    frame:SetSize(500, 600)
    frame:Center()
    frame:MakePopup()

    local squadList = vgui.Create("DListView", frame)
    squadList:Dock(FILL)
    squadList:SetMultiSelect(false)
    squadList:AddColumn("Squad ID")
    squadList:AddColumn("Squad Name")
    squadList:AddColumn("Leader")

    for squadID, squad in pairs(HunterSquads) do
        local leaderName = player.GetBySteamID(squad.leader) and player.GetBySteamID(squad.leader):Nick() or squad.leader
        squadList:AddLine(squadID, squad.name, leaderName)
    end

    local function getSelectedSquad()
        local selected = squadList:GetSelectedLine()
        if not selected then return nil end
        local line = squadList:GetLine(selected)
        return tonumber(line:GetColumnText(1))
    end

    local viewMembersButton = vgui.Create("DButton", frame)
    viewMembersButton:SetText("View Members")
    viewMembersButton:Dock(BOTTOM)
    viewMembersButton.DoClick = function()
        local squadID = getSelectedSquad()
        if squadID then
            OpenSquadMembersMenu(squadID)
        end
    end
end

-- Define OpenAdminCovenManagementMenu
local function OpenAdminCovenManagementMenu()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Admin Coven Management")
    frame:SetSize(500, 600)
    frame:Center()
    frame:MakePopup()

    local covenList = vgui.Create("DListView", frame)
    covenList:Dock(FILL)
    covenList:SetMultiSelect(false)
    covenList:AddColumn("Coven ID")
    covenList:AddColumn("Coven Name")
    covenList:AddColumn("Leader")

    for covenID, coven in pairs(VampireCovens) do
        local leaderName = player.GetBySteamID(coven.leader) and player.GetBySteamID(coven.leader):Nick() or coven.leader
        covenList:AddLine(covenID, coven.name, leaderName)
    end

    local function getSelectedCoven()
        local selected = covenList:GetSelectedLine()
        if not selected then return nil end
        local line = covenList:GetLine(selected)
        return tonumber(line:GetColumnText(1))
    end

    local viewMembersButton = vgui.Create("DButton", frame)
    viewMembersButton:SetText("View Members")
    viewMembersButton:Dock(BOTTOM)
    viewMembersButton.DoClick = function()
        local covenID = getSelectedCoven()
        if covenID then
            OpenCovenMembersMenu(covenID)
        end
    end
end

local function OpenManageMenu(isSquad, id)
    local frame = vgui.Create("DFrame")
    frame:SetTitle(isSquad and "Manage Squad" or "Manage Coven")
    frame:SetSize(400, 500)
    frame:Center()
    frame:MakePopup()

    local memberList = vgui.Create("DListView", frame)
    memberList:Dock(FILL)
    memberList:SetMultiSelect(false)
    memberList:AddColumn("Player Name")
    memberList:AddColumn("Rank")

    local group = isSquad and HunterSquads[id] or VampireCovens[id]
    if group then
        for _, member in ipairs(group.members) do
            local memberName = player.GetBySteamID(member.steamID) and player.GetBySteamID(member.steamID):Nick() or member.steamID
            memberList:AddLine(memberName, member.rank)
        end
    end

    local function getSelectedMember()
        local selected = memberList:GetSelectedLine()
        if not selected then return nil end
        return memberList:GetLine(selected):GetColumnText(1)
    end

    local addMemberButton = vgui.Create("DButton", frame)
    addMemberButton:SetText("Add Member")
    addMemberButton:Dock(BOTTOM)
    addMemberButton.DoClick = function()
        Derma_StringRequest("Add Member", "Enter the player's SteamID:", "", function(steamID)
            net.Start(isSquad and "InvitePlayerToSquad" or "InvitePlayerToCoven")
            net.WriteInt(id, 32)
            net.WriteString(steamID)
            net.SendToServer()
        end)
    end

    local removeMemberButton = vgui.Create("DButton", frame)
    removeMemberButton:SetText("Remove Member")
    removeMemberButton:Dock(BOTTOM)
    removeMemberButton.DoClick = function()
        local steamID = getSelectedMember()
        if steamID then
            net.Start(isSquad and "RemovePlayerFromSquad" or "RemovePlayerFromCoven")
            net.WriteInt(id, 32)
            net.WriteString(steamID)
            net.SendToServer()
        end
    end

    local promoteMemberButton = vgui.Create("DButton", frame)
    promoteMemberButton:SetText("Promote Member")
    promoteMemberButton:Dock(BOTTOM)
    promoteMemberButton.DoClick = function()
        local steamID = getSelectedMember()
        if steamID then
            Derma_StringRequest("Promote Member", "Enter the new rank (Leader/Officer/Member):", "", function(rank)
                net.Start(isSquad and "PromotePlayerInSquad" or "PromotePlayerInCoven")
                net.WriteInt(id, 32)
                net.WriteString(steamID)
                net.WriteString(rank)
                net.SendToServer()
            end)
        end
    end
end
