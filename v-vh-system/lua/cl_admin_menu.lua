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

    -- New buttons for managing Vampire Abilities
    local manageVampireAbilitiesButton = vgui.Create("DButton", playerPanel)
    manageVampireAbilitiesButton:SetText("Manage Vampire Abilities")
    manageVampireAbilitiesButton:Dock(BOTTOM)
    manageVampireAbilitiesButton.DoClick = function()
        net.Start("RequestVampireAbilities")
        net.SendToServer()
    end

    -- Guild Admin Panel
    local guildAdminPanel = vgui.Create("DPanel", sheet)
    guildAdminPanel:Dock(FILL)
    sheet:AddSheet("Guild Admin", guildAdminPanel, "icon16/group.png")

    local guildList = vgui.Create("DListView", guildAdminPanel)
    guildList:Dock(LEFT)
    guildList:SetWidth(200)
    guildList:SetMultiSelect(false)
    guildList:AddColumn("Guild Name")

    for guildName, _ in pairs(HunterGuildsConfig) do
        guildList:AddLine(guildName)
    end

    local memberList = vgui.Create("DListView", guildAdminPanel)
    memberList:Dock(FILL)
    memberList:SetMultiSelect(false)
    memberList:AddColumn("Player")
    memberList:AddColumn("Rank")

    local function updateMemberList(guildName)
        memberList:Clear()
        local members = {}
        if guildName == "Guild of Shadows" then
            table.insert(members, {name = "Lord of Shadow", rank = "Lord"})
        elseif guildName == "Guild of Light" then
            table.insert(members, {name = "Lord of Light", rank = "Lord"})
        elseif guildName == "Guild of Strength" then
            table.insert(members, {name = "Lord of Strength", rank = "Lord"})
        end

        -- Fetch player list from the database
        net.Start("RequestGuildMembers")
        net.WriteString(guildName)
        net.SendToServer()

        net.Receive("ReceiveGuildMembers", function()
            local guildMembers = net.ReadTable()
            for _, member in ipairs(guildMembers) do
                table.insert(members, {name = member.name, rank = member.rank})
            end

            table.sort(members, function(a, b)
                local guild = HunterGuildsConfig[guildName]
                local aRankIndex = table.KeyFromValue(guild.ranks, a.rank) or 0
                local bRankIndex = table.KeyFromValue(guild.ranks, b.rank) or 0
                return aRankIndex < bRankIndex -- Change comparison to ensure higher ranks are at the top
            end)

            for _, member in ipairs(members) do
                memberList:AddLine(member.name, member.rank)
            end
        end)
    end

    guildList.OnRowSelected = function(_, rowIndex, row)
        local guildName = row:GetColumnText(1)
        updateMemberList(guildName)
    end

    local function getSelectedGuild()
        local selected = guildList:GetSelectedLine()
        if not selected then return nil end
        return guildList:GetLine(selected):GetColumnText(1)
    end

    local function getSelectedMember()
        local selected = memberList:GetSelectedLine()
        if not selected then return nil end
        return memberList:GetLine(selected):GetColumnText(1)
    end

    -- Remove promote and demote buttons
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

-- New menu for managing Vampire Abilities
net.Receive("OpenVampireAbilitiesMenu", function()
    local abilities = net.ReadTable()

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Manage Vampire Abilities")
    frame:SetSize(400, 500)
    frame:Center()
    frame:MakePopup()

    local abilityList = vgui.Create("DListView", frame)
    abilityList:Dock(FILL)
    abilityList:SetMultiSelect(false)
    abilityList:AddColumn("Ability Class")
    abilityList:AddColumn("Cost")

    for _, ability in ipairs(abilities) do
        abilityList:AddLine(ability.class, ability.cost)
    end

    local function getSelectedAbility()
        local selected = abilityList:GetSelectedLine()
        if not selected then return nil end
        return abilityList:GetLine(selected)
    end

    local editAbilityButton = vgui.Create("DButton", frame)
    editAbilityButton:SetText("Edit Ability")
    editAbilityButton:Dock(BOTTOM)
    editAbilityButton.DoClick = function()
        local selectedAbility = getSelectedAbility()
        if selectedAbility then
            local abilityClass = selectedAbility:GetColumnText(1)
            Derma_StringRequest("Edit Ability", "Enter the new cost in medallions:", selectedAbility:GetColumnText(2), function(cost)
                net.Start("EditVampireAbility")
                net.WriteString(abilityClass)
                net.WriteInt(tonumber(cost), 32)
                net.SendToServer()
            end)
        end
    end

    local removeAbilityButton = vgui.Create("DButton", frame)
    removeAbilityButton:SetText("Remove Ability")
    removeAbilityButton:Dock(BOTTOM)
    removeAbilityButton.DoClick = function()
        local selectedAbility = getSelectedAbility()
        if selectedAbility then
            local abilityClass = selectedAbility:GetColumnText(1)
            net.Start("RemoveVampireAbility")
            net.WriteString(abilityClass)
            net.SendToServer()
        end
    end
end)
