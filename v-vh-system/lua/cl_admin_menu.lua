

net.Receive("OpenAdminMenu", function()
    print("[Vampire System] Opening Admin Menu")
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Admin Menu")
    frame:SetSize(700, 600)
    frame:Center()
    frame:MakePopup()

    
    function frame:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 32, 36, 245))
    end

    
    local header = vgui.Create("DPanel", frame)
    header:Dock(TOP)
    header:SetTall(48)
    header:DockPadding(8, 8, 8, 8)
    function header:Paint(w, h)
        surface.SetDrawColor(22, 24, 28, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 54, 60, 255)
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    
    local logToggleBtn = vgui.Create("DButton", header)
    logToggleBtn:Dock(RIGHT)
    logToggleBtn:DockMargin(8, 0, 0, 0)
    logToggleBtn:SetText("Log")
    logToggleBtn:SetTall(28)
    if logToggleBtn.SizeToContentsX then logToggleBtn:SizeToContentsX(16) end
    if logToggleBtn.SetTextColor then logToggleBtn:SetTextColor(Color(0,0,0)) end

    
    local commandCenterBtn = vgui.Create("DButton", header)
    commandCenterBtn:Dock(RIGHT)
    commandCenterBtn:DockMargin(8, 0, 0, 0)
    commandCenterBtn:SetText("Command Center")
    commandCenterBtn:SetTall(28)
    if commandCenterBtn.SizeToContentsX then commandCenterBtn:SizeToContentsX(20) end
    if commandCenterBtn.SetTextColor then commandCenterBtn:SetTextColor(Color(0,0,0)) end

    
    local titleLabel = vgui.Create("DLabel", header)
    titleLabel:Dock(FILL)
    titleLabel:DockMargin(4, 0, 0, 0)
    titleLabel:SetText("Admin Menu")
    titleLabel:SetFont("Trebuchet24")
    if titleLabel.SetTextColor then titleLabel:SetTextColor(Color(235,235,235)) end
    if titleLabel.SetContentAlignment then titleLabel:SetContentAlignment(4) end 

    
    local actionLog = vgui.Create("DListView", frame)
    actionLog:Dock(TOP)
    actionLog:SetTall(96)
    actionLog:SetVisible(false)
    actionLog:AddColumn("Time").Header:SetTextColor(Color(220, 220, 220))
    actionLog:AddColumn("Action").Header:SetTextColor(Color(220, 220, 220))
    function actionLog:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end

    local function logAction(msg)
        if not IsValid(actionLog) then return end
        local t = os.date("%H:%M:%S")
        actionLog:AddLine(t, tostring(msg))
        local maxRows = 100
        while actionLog:GetLineCount() > maxRows do
            actionLog:RemoveLine(1)
        end
    end

    logToggleBtn.DoClick = function()
        actionLog:SetVisible(not actionLog:IsVisible())
    end

    
    local selectedTargetSteamID = nil

    local function getTargetFromSID()
        if not selectedTargetSteamID then return nil end
        return player.GetBySteamID(selectedTargetSteamID)
    end

    commandCenterBtn.DoClick = function()
        local menu = DermaMenu(false, commandCenterBtn)

        local subTarget, pnlTarget = menu:AddSubMenu("Target Player")
        pnlTarget:SetIcon("icon16/user.png")
        for _, ply in ipairs(player.GetAll()) do
            subTarget:AddOption(ply:Nick() .. " (" .. ply:SteamID() .. ")", function()
                selectedTargetSteamID = ply:SteamID()
                logAction("Target set -> " .. ply:Nick() .. " (" .. ply:SteamID() .. ")")
            end)
        end

        menu:AddOption("Actions…", function()
            local tgt = getTargetFromSID()
            if not IsValid(tgt) then
                Derma_Message("Set a Target Player first (Command Center > Target Player).", "Command Center", "OK")
                return
            end
            
            openActionMenu(commandCenterBtn, tgt)
        end):SetIcon("icon16/cog.png")

        menu:AddSpacer()
        menu:AddOption("Open Merchant Items", function()
            net.Start("RequestMerchantItems")
            net.SendToServer()
            logAction("Open Merchant Items manager")
        end):SetIcon("icon16/cart.png")

        menu:AddOption("Open Vampire Abilities", function()
            net.Start("RequestVampireAbilities")
            net.SendToServer()
            logAction("Open Vampire Abilities manager")
        end):SetIcon("icon16/lightning.png")

        menu:Open()
    end

    
    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)
    function sheet:Paint(w, h)
        surface.SetDrawColor(32, 34, 38, 255)
        surface.DrawRect(0, 0, w, h)
    end
    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)

    
    local playerPanel = vgui.Create("DPanel", sheet)
    playerPanel:Dock(FILL)
    function playerPanel:Paint(w, h)
        surface.SetDrawColor(32, 34, 38, 255)
        surface.DrawRect(0, 0, w, h)
    end
    sheet:AddSheet("Players", playerPanel, "icon16/user.png")

    
    local function MakeListViewReadable(list)
        if not IsValid(list) then return end
        
        if not list.__oldAddLine then
            list.__oldAddLine = list.AddLine
            function list:AddLine(...)
                local line = self:__oldAddLine(...)
                if line and line.Columns then
                    for _, col in pairs(line.Columns) do
                        if col.SetTextColor then col:SetTextColor(Color(235,235,235)) end
                    end
                end
                return line
            end
        end
        
        if list.Columns then
            for _, col in ipairs(list.Columns) do
                if col and col.Header and col.Header.SetTextColor then
                    col.Header:SetTextColor(Color(220,220,220))
                end
            end
        end
    end

    
    local playerToolbar = vgui.Create("DPanel", playerPanel)
    playerToolbar:Dock(TOP)
    playerToolbar:SetTall(36)
    function playerToolbar:Paint(w, h)
        surface.SetDrawColor(26, 28, 32, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 54, 60, 255)
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    local searchEntry = vgui.Create("DTextEntry", playerToolbar)
    searchEntry:Dock(LEFT)
    searchEntry:SetWide(220)
    searchEntry:SetUpdateOnType(true)
    searchEntry:SetPlaceholderText("Search players, SteamID, role…")
    searchEntry:DockMargin(8, 6, 8, 6)
    if searchEntry.SetTextColor then searchEntry:SetTextColor(Color(235,235,235)) end

    local actionsBtn = vgui.Create("DButton", playerToolbar)
    actionsBtn:Dock(RIGHT)
    actionsBtn:SetText("Actions…")
    actionsBtn:DockMargin(8, 6, 8, 6)
    if actionsBtn.SetTextColor then actionsBtn:SetTextColor(Color(0,0,0)) end

    local function addToolbarSpacer()
        local spacer = vgui.Create("DPanel", playerToolbar)
        spacer:Dock(LEFT)
        spacer:SetWide(8)
        function spacer:Paint(w, h) end
    end
    addToolbarSpacer()

    
    local playerList = vgui.Create("DListView", playerPanel)
    playerList:Dock(FILL)
    function playerList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    playerList:SetMultiSelect(false)
    playerList:AddColumn("Player")
    playerList:AddColumn("SteamID")
    playerList:AddColumn("Role")
    playerList:AddColumn("Experience/Blood")
    playerList:AddColumn("Hearts/Medallions")
    MakeListViewReadable(playerList)

    local function getRoleData(ply)
        local role = "None"
        local expOrBlood = "N/A"
        local heartsOrMedallions = "N/A"
        if IsVampire(ply) then
            role = "Vampire"
            if vampires[ply:SteamID()] then
                expOrBlood = vampires[ply:SteamID()].blood
                heartsOrMedallions = vampires[ply:SteamID()].medallions
            end
        elseif IsHunter(ply) then
            role = "Hunter"
            if hunters[ply:SteamID()] then
                expOrBlood = hunters[ply:SteamID()].experience
                heartsOrMedallions = hunters[ply:SteamID()].hearts
            end
        end
        return role, expOrBlood, heartsOrMedallions
    end

    local function repopulatePlayers(filterText)
        playerList:Clear()
        local ft = string.lower(tostring(filterText or ""))
        for _, ply in ipairs(player.GetAll()) do
            local role, expOrBlood, heartsOrMedallions = getRoleData(ply)
            local nick = ply:Nick()
            local sid = ply:SteamID()
            local rowText = string.lower(nick .. " " .. sid .. " " .. role)
            if ft == "" or string.find(rowText, ft, 1, true) then
                playerList:AddLine(nick, sid, role, expOrBlood, heartsOrMedallions)
            end
        end
    end

    repopulatePlayers("")

    function searchEntry:OnValueChange(val)
        repopulatePlayers(val)
    end

    local function getSelectedPlayer()
        local selected = playerList:GetSelectedLine()
        if not selected then return nil end
        local line = playerList:GetLine(selected)
        return player.GetBySteamID(line:GetColumnText(2))
    end

    
    local function openActionMenu(anchorPanel, targetPly)
        local menu = DermaMenu(false, anchorPanel)

        local function ensureTarget(cb)
            local t = targetPly or getSelectedPlayer()
            if not IsValid(t) and selectedTargetSteamID then
                t = player.GetBySteamID(selectedTargetSteamID)
            end
            if not IsValid(t) then
                Derma_Message("Select a player (Players tab) or set a Target Player from Command Center.", "Admin", "OK")
                return
            end
            cb(t)
        end

        
        local subVampire, pnlVampire = menu:AddSubMenu("Vampire")
        pnlVampire:SetIcon("icon16/bug.png")
        subVampire:AddOption("Make Vampire", function()
            ensureTarget(function(t)
                net.Start("AdminMakeVampire")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Make Vampire -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
            end)
        end)
        subVampire:AddOption("Remove Vampire", function()
            ensureTarget(function(t)
                net.Start("AdminRemoveRole")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Remove Vampire -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
            end)
        end):SetIcon("icon16/user_delete.png")
        subVampire:AddOption("Add Blood…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Blood", "Enter the amount of blood to add:", "", function(amount)
                    net.Start("AdminAddBlood")
                    net.WriteString(t:SteamID())
                    net.WriteInt(tonumber(amount) or 0, 32)
                    net.SendToServer()
                    logAction("Add Blood +" .. tostring(amount) .. " -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
                end)
            end)
        end):SetIcon("icon16/heart.png")
        subVampire:AddOption("Add Medallions…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Medallions", "Enter the amount of medallions to add:", "", function(amount)
                    net.Start("AdminAddMedallions")
                    net.WriteString(t:SteamID())
                    net.WriteInt(tonumber(amount) or 0, 32)
                    net.SendToServer()
                    logAction("Add Medallions +" .. tostring(amount) .. " -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
                end)
            end)
        end):SetIcon("icon16/coins.png")

        local subHunter, pnlHunter = menu:AddSubMenu("Hunter")
        pnlHunter:SetIcon("icon16/gun.png")
        subHunter:AddOption("Make Hunter", function()
            ensureTarget(function(t)
                net.Start("AdminMakeHunter")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Make Hunter -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
            end)
        end)
        subHunter:AddOption("Remove Hunter", function()
            ensureTarget(function(t)
                net.Start("AdminRemoveRole")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Remove Hunter -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
            end)
        end):SetIcon("icon16/user_delete.png")
        subHunter:AddOption("Add Experience…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Experience", "Enter the amount of experience to add:", "", function(amount)
                    net.Start("AdminAddExperience")
                    net.WriteString(t:SteamID())
                    net.WriteInt(tonumber(amount) or 0, 32)
                    net.SendToServer()
                    logAction("Add Experience +" .. tostring(amount) .. " -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
                end)
            end)
        end):SetIcon("icon16/chart_line.png")
        subHunter:AddOption("Add Hearts…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Hearts", "Enter the amount of hearts to add:", "", function(amount)
                    net.Start("AdminAddHearts")
                    net.WriteString(t:SteamID())
                    net.WriteInt(tonumber(amount) or 0, 32)
                    net.SendToServer()
                    logAction("Add Hearts +" .. tostring(amount) .. " -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
                end)
            end)
        end):SetIcon("icon16/brick.png")

        
        local subWere, pnlWere = menu:AddSubMenu("Werewolf")
        pnlWere:SetIcon("icon16/flag_yellow.png")
        subWere:AddOption("Make Werewolf", function()
            ensureTarget(function(t)
                net.Start("AdminMakeWerewolf")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Make Werewolf -> " .. t:Nick())
            end)
        end)
        subWere:AddOption("Remove Werewolf", function()
            ensureTarget(function(t)
                net.Start("AdminRemoveWerewolf")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Remove Werewolf -> " .. t:Nick())
            end)
        end)
        subWere:AddOption("Add Rage…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Rage", "Enter the amount of rage to add:", "", function(amount)
                    net.Start("AdminAddRage")
                    net.WriteString(t:SteamID())
                    net.WriteInt(tonumber(amount) or 0, 32)
                    net.SendToServer()
                    logAction("Add Werewolf Rage +" .. tostring(amount) .. " -> " .. t:Nick())
                end)
            end)
        end)
        subWere:AddOption("Add Moon Essence…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Moon Essence", "Enter the amount to add:", "", function(amount)
                    net.Start("AdminAddMoonEssence")
                    net.WriteString(t:SteamID())
                    net.WriteInt(tonumber(amount) or 0, 32)
                    net.SendToServer()
                    logAction("Add Moon Essence +" .. tostring(amount) .. " -> " .. t:Nick())
                end)
            end)
        end)
        subWere:AddOption("Start Transformation", function()
            ensureTarget(function(t)
                net.Start("AdminStartWerewolfTransform")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Werewolf Transform START -> " .. t:Nick())
            end)
        end)
        subWere:AddOption("End Transformation", function()
            ensureTarget(function(t)
                net.Start("AdminEndWerewolfTransform")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Werewolf Transform END -> " .. t:Nick())
            end)
        end)
        subWere:AddOption("Open Packs Manager", function()
            net.Start("RequestWerewolfPacksMenu")
            net.SendToServer()
            logAction("Open Werewolf Packs manager")
        end)

        
        local subHybrid, pnlHybrid = menu:AddSubMenu("Hybrid")
        pnlHybrid:SetIcon("icon16/ruby.png")
        subHybrid:AddOption("Make Hybrid", function()
            ensureTarget(function(t)
                net.Start("AdminMakeHybrid")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Make Hybrid -> " .. t:Nick())
            end)
        end)
        subHybrid:AddOption("Remove Hybrid", function()
            ensureTarget(function(t)
                net.Start("AdminRemoveHybrid")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Remove Hybrid -> " .. t:Nick())
            end)
        end)
        subHybrid:AddOption("Add Blood…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Blood (Hybrid)", "Enter amount:", "", function(amount)
                    net.Start("AdminAddHybridBlood")
                    net.WriteString(t:SteamID())
                    net.WriteInt(tonumber(amount) or 0, 32)
                    net.SendToServer()
                    logAction("Hybrid Blood +" .. tostring(amount) .. " -> " .. t:Nick())
                end)
            end)
        end)
        subHybrid:AddOption("Add Rage…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Rage (Hybrid)", "Enter amount:", "", function(amount)
                    net.Start("AdminAddHybridRage")
                    net.WriteString(t:SteamID())
                    net.WriteInt(tonumber(amount) or 0, 32)
                    net.SendToServer()
                    logAction("Hybrid Rage +" .. tostring(amount) .. " -> " .. t:Nick())
                end)
            end)
        end)
        subHybrid:AddOption("Set Balance…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Set Hybrid Balance", "Enter balance (-100 to 100):", "", function(val)
                    local balance = math.floor(tonumber(val) or 0)
                    net.Start("AdminSetHybridBalance")
                    net.WriteString(t:SteamID())
                    net.WriteInt(balance, 32)
                    net.SendToServer()
                    logAction("Hybrid Balance set to " .. tostring(balance) .. " -> " .. t:Nick())
                end)
            end)
        end)
        local subForce, pnlForce = subHybrid:AddSubMenu("Force Transform")
        pnlForce:SetIcon("icon16/wand.png")
        subForce:AddOption("Vampire Form", function()
            ensureTarget(function(t)
                net.Start("AdminForceHybridTransform")
                net.WriteString(t:SteamID())
                net.WriteString("vampireForm")
                net.SendToServer()
                logAction("Force Hybrid Vampire Form -> " .. t:Nick())
            end)
        end)
        subForce:AddOption("Werewolf Form", function()
            ensureTarget(function(t)
                net.Start("AdminForceHybridTransform")
                net.WriteString(t:SteamID())
                net.WriteString("werewolfForm")
                net.SendToServer()
                logAction("Force Hybrid Werewolf Form -> " .. t:Nick())
            end)
        end)
        subForce:AddOption("Eclipse Form", function()
            ensureTarget(function(t)
                net.Start("AdminForceHybridTransform")
                net.WriteString(t:SteamID())
                net.WriteString("eclipseForm")
                net.SendToServer()
                logAction("Force Hybrid Eclipse Form -> " .. t:Nick())
            end)
        end)

        menu:AddSpacer()

        
        local subShop, pnlShop = menu:AddSubMenu("Merchant Items")
        pnlShop:SetIcon("icon16/cart.png")
        subShop:AddOption("Open Manager", function()
            net.Start("RequestMerchantItems")
            net.SendToServer()
            logAction("Open Merchant Items manager")
        end)
        subShop:AddOption("Add Item…", function()
            Derma_StringRequest("Add Item", "Enter the weapon class:", "", function(weaponClass)
                Derma_StringRequest("Add Item", "Enter the cost in hearts:", "", function(cost)
                    net.Start("AdminAddMerchantItem")
                    net.WriteString(weaponClass)
                    net.WriteInt(tonumber(cost) or 0, 32)
                    net.SendToServer()
                    logAction("Add Merchant Item -> " .. tostring(weaponClass) .. ", cost " .. tostring(cost))
                end)
            end)
        end)

        local subWeapons, pnlWeapons = menu:AddSubMenu("Player Weapons")
        pnlWeapons:SetIcon("icon16/wrench.png")
        subWeapons:AddOption("Open Manager", function()
            ensureTarget(function(t)
                net.Start("RequestPlayerWeapons")
                net.WriteString(t:SteamID())
                net.SendToServer()
                logAction("Open Player Weapons manager -> " .. t:Nick())
            end)
        end)
        subWeapons:AddOption("Add Weapon…", function()
            ensureTarget(function(t)
                Derma_StringRequest("Add Weapon", "Enter the weapon class:", "", function(weaponClass)
                    net.Start("AdminAddPlayerWeapon")
                    net.WriteString(t:SteamID())
                    net.WriteString(weaponClass)
                    net.SendToServer()
                    logAction("Add Player Weapon -> " .. t:Nick() .. ": " .. tostring(weaponClass))
                end)
            end)
        end)

        local subVamp, pnlVamp = menu:AddSubMenu("Vampire Abilities")
        pnlVamp:SetIcon("icon16/lightning.png")
        subVamp:AddOption("Open Manager", function()
            net.Start("RequestVampireAbilities")
            net.SendToServer()
            logAction("Open Vampire Abilities manager")
        end)


        menu:AddSpacer()

        menu:AddOption("Remove from Vampire/Hunter", function()
            ensureTarget(function(t)
                Derma_Query("Remove this player from their current role?", "Confirm Removal", "Yes", function()
                    net.Start("AdminRemoveRole")
                    net.WriteString(t:SteamID())
                    net.SendToServer()
                    logAction("Remove Role -> " .. t:Nick() .. " (" .. t:SteamID() .. ")")
                end, "No")
            end)
        end):SetIcon("icon16/user_delete.png")

        menu:Open()
    end

    actionsBtn.DoClick = function()
        openActionMenu(actionsBtn, getSelectedPlayer())
    end

    

    function playerList:OnRowRightClick(rowIndex, row)
        openActionMenu(playerList, player.GetBySteamID(row:GetColumnText(2)))
    end

    function playerList:DoDoubleClick(lineID, line)
        openActionMenu(playerList, player.GetBySteamID(line:GetColumnText(2)))
    end



    local guildAdminPanel = vgui.Create("DPanel", sheet)
    guildAdminPanel:Dock(FILL)
    function guildAdminPanel:Paint(w, h)
        surface.SetDrawColor(32, 34, 38, 255)
        surface.DrawRect(0, 0, w, h)
    end
    sheet:AddSheet("Guild Admin", guildAdminPanel, "icon16/group.png")

    local guildList = vgui.Create("DListView", guildAdminPanel)
    guildList:Dock(LEFT)
    guildList:SetWidth(200)
    function guildList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    guildList:SetMultiSelect(false)
    guildList:AddColumn("Guild Name")
    MakeListViewReadable(guildList)

    for guildName, _ in pairs(HunterGuildsConfig) do
        guildList:AddLine(guildName)
    end

    local memberList = vgui.Create("DListView", guildAdminPanel)
    memberList:Dock(FILL)
    function memberList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    memberList:SetMultiSelect(false)
    memberList:AddColumn("Player")
    memberList:AddColumn("Rank")
    MakeListViewReadable(memberList)

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
                return aRankIndex < bRankIndex
            end)

            for _, member in ipairs(members) do
                local ft = string.lower(tostring(memberSearch:GetValue() or ""))
                local rowText = string.lower(member.name .. " " .. tostring(member.rank))
                if ft == "" or string.find(rowText, ft, 1, true) then
                    memberList:AddLine(member.name, member.rank)
                end
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

    local function getSelectedMemberSteamID()
        local selected = memberList:GetSelectedLine()
        if not selected then return nil end
        local line = memberList:GetLine(selected)
        for _, ply in ipairs(player.GetAll()) do
            if ply:Nick() == line:GetColumnText(1) then
                return ply:SteamID()
            end
        end
        return nil
    end

    
    local guildToolbar = vgui.Create("DPanel", guildAdminPanel)
    guildToolbar:Dock(TOP)
    guildToolbar:SetTall(36)
    function guildToolbar:Paint(w, h)
        surface.SetDrawColor(26, 28, 32, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 54, 60, 255)
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    local guildSearch = vgui.Create("DTextEntry", guildToolbar)
    guildSearch:Dock(LEFT)
    guildSearch:SetWide(180)
    guildSearch:SetUpdateOnType(true)
    guildSearch:SetPlaceholderText("Filter guilds…")
    guildSearch:DockMargin(6, 6, 6, 6)
    if guildSearch.SetTextColor then guildSearch:SetTextColor(Color(235,235,235)) end

    local memberSearch = vgui.Create("DTextEntry", guildToolbar)
    memberSearch:Dock(LEFT)
    memberSearch:SetWide(220)
    memberSearch:SetUpdateOnType(true)
    memberSearch:SetPlaceholderText("Filter members…")
    memberSearch:DockMargin(0, 6, 6, 6)
    if memberSearch.SetTextColor then memberSearch:SetTextColor(Color(235,235,235)) end

    local guildActionsBtn = vgui.Create("DButton", guildToolbar)
    guildActionsBtn:Dock(RIGHT)
    guildActionsBtn:SetText("Actions…")
    guildActionsBtn:DockMargin(6, 6, 6, 6)
    if guildActionsBtn.SetTextColor then guildActionsBtn:SetTextColor(Color(0,0,0)) end

    local function repopulateGuildList(filterText)
        guildList:Clear()
        local ft = string.lower(tostring(filterText or ""))
        for guildName, _ in pairs(HunterGuildsConfig) do
            if ft == "" or string.find(string.lower(guildName), ft, 1, true) then
                guildList:AddLine(guildName)
            end
        end
    end

    repopulateGuildList("")

    function guildSearch:OnValueChange(val)
        repopulateGuildList(val)
        memberList:Clear()
    end

    function memberSearch:OnValueChange(val)
        local g = getSelectedGuild()
        if g then updateMemberList(g) end
    end

    local function openGuildActionMenu(anchor)
        local guildName = getSelectedGuild()
        local memberSteamID = getSelectedMemberSteamID()
        local m = DermaMenu(false, anchor)
        m:AddOption("Promote Rank", function()
            if guildName and memberSteamID then
                net.Start("PromoteGuildRank")
                net.WriteString(memberSteamID)
                net.SendToServer()
                logAction("Guild Promote -> " .. tostring(getSelectedMember() or memberSteamID))
                timer.Simple(1, function()
                    updateMemberList(guildName)
                end)
            end
        end):SetIcon("icon16/arrow_up.png")
        m:AddOption("Demote Rank", function()
            if guildName and memberSteamID then
                net.Start("DemoteGuildRank")
                net.WriteString(memberSteamID)
                net.SendToServer()
                logAction("Guild Demote -> " .. tostring(getSelectedMember() or memberSteamID))
                timer.Simple(1, function()
                    updateMemberList(guildName)
                end)
            end
        end):SetIcon("icon16/arrow_down.png")
        m:AddOption("Kick Member", function()
            if guildName and memberSteamID then
                Derma_Query("Kick this member from the guild?", "Confirm Kick", "Yes", function()
                    net.Start("KickGuildMember")
                    net.WriteString(memberSteamID)
                    net.SendToServer()
                    logAction("Guild Kick -> " .. tostring(getSelectedMember() or memberSteamID))
                    timer.Simple(1, function()
                        updateMemberList(guildName)
                    end)
                end, "No")
            end
        end):SetIcon("icon16/user_delete.png")
        m:Open()
    end

    guildActionsBtn.DoClick = function()
        openGuildActionMenu(guildActionsBtn)
    end

    function memberList:OnRowRightClick(rowIndex, row)
        openGuildActionMenu(memberList)
    end

    function memberList:DoDoubleClick(lineID, line)
        openGuildActionMenu(memberList)
    end

    
    local covenAdminPanel = vgui.Create("DPanel", sheet)
    covenAdminPanel:Dock(FILL)
    function covenAdminPanel:Paint(w, h)
        surface.SetDrawColor(32, 34, 38, 255)
        surface.DrawRect(0, 0, w, h)
    end
    sheet:AddSheet("Coven Admin", covenAdminPanel, "icon16/group.png")

    local covenList = vgui.Create("DListView", covenAdminPanel)
    covenList:Dock(LEFT)
    covenList:SetWidth(200)
    function covenList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    covenList:SetMultiSelect(false)
    covenList:AddColumn("Coven Name")
    MakeListViewReadable(covenList)

    for covenName, _ in pairs(VampireCovensConfig) do
        covenList:AddLine(covenName)
    end

    local memberList = vgui.Create("DListView", covenAdminPanel)
    memberList:Dock(FILL)
    function memberList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    memberList:SetMultiSelect(false)
    memberList:AddColumn("Player")
    memberList:AddColumn("Rank")
    MakeListViewReadable(memberList)

    local function updateMemberList(covenName)
        memberList:Clear()
        local members = {}

        if covenName == "Coven of Blood" then
            table.insert(members, {name = "Lord of Blood", rank = "Lord of Blood"})
        elseif covenName == "Coven of Shadows" then
            table.insert(members, {name = "Lord of Shadows", rank = "Lord of Shadows"})
        elseif covenName == "Coven of Strength" then
            table.insert(members, {name = "Lord of Strength", rank = "Lord of Strength"})
        end

        net.Start("RequestCovenMembers")
        net.WriteString(covenName)
        net.SendToServer()

        net.Receive("ReceiveCovenMembers", function()
            local covenMembers = net.ReadTable()
            for _, member in ipairs(covenMembers) do
                table.insert(members, {name = member.name, rank = member.rank})
            end

            table.sort(members, function(a, b)
                local coven = VampireCovensConfig[covenName]
                local aRankIndex = table.KeyFromValue(coven.ranks, a.rank) or 0
                local bRankIndex = table.KeyFromValue(coven.ranks, b.rank) or 0
                return aRankIndex > bRankIndex
            end)

            for _, member in ipairs(members) do
                local ft = string.lower(tostring(covenMemberSearch:GetValue() or ""))
                local rowText = string.lower(member.name .. " " .. tostring(member.rank))
                if ft == "" or string.find(rowText, ft, 1, true) then
                    memberList:AddLine(member.name, member.rank)
                end
            end
        end)
    end

    covenList.OnRowSelected = function(_, rowIndex, row)
        local covenName = row:GetColumnText(1)
        updateMemberList(covenName)
    end

    local function getSelectedCoven()
        local selected = covenList:GetSelectedLine()
        if not selected then return nil end
        return covenList:GetLine(selected):GetColumnText(1)
    end

    local function getSelectedMemberSteamID()
        local selected = memberList:GetSelectedLine()
        if not selected then return nil end
        local line = memberList:GetLine(selected)
        for _, ply in ipairs(player.GetAll()) do
            if ply:Nick() == line:GetColumnText(1) then
                return ply:SteamID()
            end
        end
        return nil
    end

    
    local covenToolbar = vgui.Create("DPanel", covenAdminPanel)
    covenToolbar:Dock(TOP)
    covenToolbar:SetTall(36)
    function covenToolbar:Paint(w, h)
        surface.SetDrawColor(26, 28, 32, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 54, 60, 255)
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    local covenSearch = vgui.Create("DTextEntry", covenToolbar)
    covenSearch:Dock(LEFT)
    covenSearch:SetWide(180)
    covenSearch:SetUpdateOnType(true)
    covenSearch:SetPlaceholderText("Filter covens…")
    covenSearch:DockMargin(6, 6, 6, 6)
    if covenSearch.SetTextColor then covenSearch:SetTextColor(Color(235,235,235)) end

    local covenMemberSearch = vgui.Create("DTextEntry", covenToolbar)
    covenMemberSearch:Dock(LEFT)
    covenMemberSearch:SetWide(220)
    covenMemberSearch:SetUpdateOnType(true)
    covenMemberSearch:SetPlaceholderText("Filter members…")
    covenMemberSearch:DockMargin(0, 6, 6, 6)
    if covenMemberSearch.SetTextColor then covenMemberSearch:SetTextColor(Color(235,235,235)) end

    local covenActionsBtn = vgui.Create("DButton", covenToolbar)
    covenActionsBtn:Dock(RIGHT)
    covenActionsBtn:SetText("Actions…")
    covenActionsBtn:DockMargin(6, 6, 6, 6)
    if covenActionsBtn.SetTextColor then covenActionsBtn:SetTextColor(Color(0,0,0)) end

    local function repopulateCovenList(filterText)
        covenList:Clear()
        local ft = string.lower(tostring(filterText or ""))
        for covenName, _ in pairs(VampireCovensConfig) do
            if ft == "" or string.find(string.lower(covenName), ft, 1, true) then
                covenList:AddLine(covenName)
            end
        end
    end

    repopulateCovenList("")

    function covenSearch:OnValueChange(val)
        repopulateCovenList(val)
        memberList:Clear()
    end

    function covenMemberSearch:OnValueChange(val)
        local c = getSelectedCoven()
        if c then updateMemberList(c) end
    end

    local function openCovenActionMenu(anchor)
        local covenName = getSelectedCoven()
        local memberSteamID = getSelectedMemberSteamID()
        local m = DermaMenu(false, anchor)
        m:AddOption("Promote Rank", function()
            if covenName and memberSteamID then
                net.Start("PromoteCovenRank")
                net.WriteString(memberSteamID)
                net.SendToServer()
                logAction("Coven Promote -> " .. tostring(getSelectedMember() or memberSteamID))
                timer.Simple(1, function()
                    updateMemberList(covenName)
                end)
            end
        end):SetIcon("icon16/arrow_up.png")
        m:AddOption("Demote Rank", function()
            if covenName and memberSteamID then
                net.Start("DemoteCovenRank")
                net.WriteString(memberSteamID)
                net.SendToServer()
                logAction("Coven Demote -> " .. tostring(getSelectedMember() or memberSteamID))
                timer.Simple(1, function()
                    updateMemberList(covenName)
                end)
            end
        end):SetIcon("icon16/arrow_down.png")
        m:AddOption("Kick Member", function()
            if covenName and memberSteamID then
                Derma_Query("Kick this member from the coven?", "Confirm Kick", "Yes", function()
                    net.Start("KickCovenMember")
                    net.WriteString(memberSteamID)
                    net.SendToServer()
                    logAction("Coven Kick -> " .. tostring(getSelectedMember() or memberSteamID))
                    timer.Simple(1, function()
                        updateMemberList(covenName)
                    end)
                end, "No")
            end
        end):SetIcon("icon16/user_delete.png")
        m:Open()
    end

    covenActionsBtn.DoClick = function()
        openCovenActionMenu(covenActionsBtn)
    end

    function memberList:OnRowRightClick(rowIndex, row)
        openCovenActionMenu(memberList)
    end

    function memberList:DoDoubleClick(lineID, line)
        openCovenActionMenu(memberList)
    end

    
    local packAdminPanel = vgui.Create("DPanel", sheet)
    packAdminPanel:Dock(FILL)
    function packAdminPanel:Paint(w, h)
        surface.SetDrawColor(32, 34, 38, 255)
        surface.DrawRect(0, 0, w, h)
    end
    sheet:AddSheet("Pack Admin", packAdminPanel, "icon16/group.png")

    local packList = vgui.Create("DListView", packAdminPanel)
    packList:Dock(LEFT)
    packList:SetWidth(200)
    function packList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    packList:SetMultiSelect(false)
    packList:AddColumn("Pack Name")
    MakeListViewReadable(packList)
    for packName, _ in pairs(WerewolfPacksConfig or {}) do
        packList:AddLine(packName)
    end

    local packMemberList = vgui.Create("DListView", packAdminPanel)
    packMemberList:Dock(FILL)
    function packMemberList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    packMemberList:SetMultiSelect(false)
    packMemberList:AddColumn("Player")
    packMemberList:AddColumn("Rank")
    packMemberList:AddColumn("SteamID")
    MakeListViewReadable(packMemberList)

    local function updatePackMemberList(packName)
        packMemberList:Clear()
        local members = {}
        net.Start("RequestPackMembers")
        net.WriteString(packName)
        net.SendToServer()
        net.Receive("ReceivePackMembers", function()
            local packMembers = net.ReadTable()
            for _, member in ipairs(packMembers) do
                table.insert(members, {name = member.name, rank = member.rank})
            end
            table.sort(members, function(a, b)
                local pack = WerewolfPacksConfig[packName]
                local aRankIndex = table.KeyFromValue(pack.ranks, a.rank) or 0
                local bRankIndex = table.KeyFromValue(pack.ranks, b.rank) or 0
                return aRankIndex > bRankIndex
            end)
            for _, member in ipairs(members) do
                packMemberList:AddLine(member.name, member.rank, member.steamID or "")
            end
        end)
    end

    packList.OnRowSelected = function(_, rowIndex, row)
        local packName = row:GetColumnText(1)
        updatePackMemberList(packName)
    end

    local function getSelectedPack()
        local selected = packList:GetSelectedLine()
        if not selected then return nil end
        return packList:GetLine(selected):GetColumnText(1)
    end

    local function getSelectedPackMemberName()
        local selected = packMemberList:GetSelectedLine()
        if not selected then return nil end
        return packMemberList:GetLine(selected):GetColumnText(1)
    end

    local function getSelectedPackMemberSteamID()
        local selected = packMemberList:GetSelectedLine()
        if not selected then return nil end
        local sid = packMemberList:GetLine(selected):GetColumnText(3)
        if sid and sid ~= "" then return sid end
        
        local name = getSelectedPackMemberName()
        for _, ply in ipairs(player.GetAll()) do
            if ply:Nick() == name then return ply:SteamID() end
        end
        return nil
    end

    local packToolbar = vgui.Create("DPanel", packAdminPanel)
    packToolbar:Dock(TOP)
    packToolbar:SetTall(36)
    function packToolbar:Paint(w, h)
        surface.SetDrawColor(26, 28, 32, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 54, 60, 255)
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    local packActionsBtn = vgui.Create("DButton", packToolbar)
    packActionsBtn:Dock(RIGHT)
    packActionsBtn:SetText("Actions…")
    packActionsBtn:DockMargin(6, 6, 6, 6)
    if packActionsBtn.SetTextColor then packActionsBtn:SetTextColor(Color(0,0,0)) end

    local function openPackActionMenu(anchor)
        local packName = getSelectedPack()
        local memberSID = getSelectedPackMemberSteamID()
        local m = DermaMenu(false, anchor)
        m:AddOption("Promote Rank", function()
            if packName and memberSID then
                net.Start("PromotePackRank")
                net.WriteString(memberSID)
                net.SendToServer()
                logAction("Pack Promote -> " .. tostring(getSelectedPackMemberName() or memberSID))
                timer.Simple(1, function() updatePackMemberList(packName) end)
            end
        end):SetIcon("icon16/arrow_up.png")
        m:AddOption("Demote Rank", function()
            if packName and memberSID then
                net.Start("DemotePackRank")
                net.WriteString(memberSID)
                net.SendToServer()
                logAction("Pack Demote -> " .. tostring(getSelectedPackMemberName() or memberSID))
                timer.Simple(1, function() updatePackMemberList(packName) end)
            end
        end):SetIcon("icon16/arrow_down.png")
        m:AddOption("Kick Member", function()
            if packName and memberSID then
                Derma_Query("Kick this member from the pack?", "Confirm Kick", "Yes", function()
                    net.Start("KickPackMember")
                    net.WriteString(memberSID)
                    net.SendToServer()
                    logAction("Pack Kick -> " .. tostring(getSelectedPackMemberName() or memberSID))
                    timer.Simple(1, function() updatePackMemberList(packName) end)
                end, "No")
            end
        end):SetIcon("icon16/user_delete.png")
        m:AddSpacer()
        m:AddOption("Assign Player to Pack…", function()
            local pack = getSelectedPack()
            if not pack then return end
            local opts = DermaMenu()
            for _, ply in ipairs(player.GetAll()) do
                opts:AddOption(ply:Nick(), function()
                    local proceed = function()
                        net.Start("AdminAssignWerewolfToPack")
                        net.WriteString(ply:SteamID())
                        net.WriteString(pack)
                        net.SendToServer()
                        logAction("Assign to Pack -> " .. pack .. ": " .. ply:Nick())
                        timer.Simple(1, function() updatePackMemberList(pack) end)
                    end
                    if not (IsWerewolf and IsWerewolf(ply)) then
                        Derma_Query("Convert this player to Werewolf before assigning?", "Auto-convert", "Yes", function()
                            net.Start("AdminMakeWerewolf")
                            net.WriteString(ply:SteamID())
                            net.SendToServer()
                            timer.Simple(0.5, proceed)
                        end, "No")
                    else
                        proceed()
                    end
                end)
            end
            opts:Open()
        end):SetIcon("icon16/user_add.png")
        m:AddOption("Remove Player from Pack", function()
            local memberSID2 = getSelectedPackMemberSteamID()
            if memberSID2 then
                net.Start("AdminRemoveFromWerewolfPack")
                net.WriteString(memberSID2)
                net.SendToServer()
                logAction("Remove from Pack -> " .. tostring(getSelectedPackMemberName() or memberSID2))
                local p = getSelectedPack()
                if p then timer.Simple(1, function() updatePackMemberList(p) end) end
            end
        end):SetIcon("icon16/user_delete.png")
        m:Open()
    end

    packActionsBtn.DoClick = function()
        openPackActionMenu(packActionsBtn)
    end

    function packMemberList:OnRowRightClick()
        openPackActionMenu(packMemberList)
    end

    function packMemberList:DoDoubleClick()
        openPackActionMenu(packMemberList)
    end

    
    local orderAdminPanel = vgui.Create("DPanel", sheet)
    orderAdminPanel:Dock(FILL)
    function orderAdminPanel:Paint(w, h)
        surface.SetDrawColor(32, 34, 38, 255)
        surface.DrawRect(0, 0, w, h)
    end
    sheet:AddSheet("Order Admin", orderAdminPanel, "icon16/group.png")

    local orderList = vgui.Create("DListView", orderAdminPanel)
    orderList:Dock(LEFT)
    orderList:SetWidth(200)
    function orderList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    orderList:SetMultiSelect(false)
    orderList:AddColumn("Order Name")
    MakeListViewReadable(orderList)
    for orderName, _ in pairs(HybridOrdersConfig or {}) do
        orderList:AddLine(orderName)
    end

    local orderMemberList = vgui.Create("DListView", orderAdminPanel)
    orderMemberList:Dock(FILL)
    function orderMemberList:Paint(w, h)
        surface.SetDrawColor(28, 30, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    orderMemberList:SetMultiSelect(false)
    orderMemberList:AddColumn("Player")
    orderMemberList:AddColumn("Rank")
    orderMemberList:AddColumn("SteamID")
    MakeListViewReadable(orderMemberList)

    local function updateOrderMemberList(orderName)
        orderMemberList:Clear()
        local members = {}
        net.Start("RequestHybridOrderMembers")
        net.WriteString(orderName)
        net.SendToServer()
        net.Receive("ReceiveHybridOrderMembers", function()
            local orderMembers = net.ReadTable()
            for _, member in ipairs(orderMembers) do
                table.insert(members, {name = member.name, rank = member.rank})
            end
            table.sort(members, function(a, b)
                local order = HybridOrdersConfig[orderName]
                local aRankIndex = table.KeyFromValue(order.ranks, a.rank) or 0
                local bRankIndex = table.KeyFromValue(order.ranks, b.rank) or 0
                return aRankIndex > bRankIndex
            end)
            for _, member in ipairs(members) do
                orderMemberList:AddLine(member.name, member.rank, member.steamID or "")
            end
        end)
    end

    orderList.OnRowSelected = function(_, rowIndex, row)
        local orderName = row:GetColumnText(1)
        updateOrderMemberList(orderName)
    end

    local function getSelectedOrder()
        local selected = orderList:GetSelectedLine()
        if not selected then return nil end
        return orderList:GetLine(selected):GetColumnText(1)
    end

    local function getSelectedOrderMemberName()
        local selected = orderMemberList:GetSelectedLine()
        if not selected then return nil end
        return orderMemberList:GetLine(selected):GetColumnText(1)
    end

    local function getSelectedOrderMemberSteamID()
        local selected = orderMemberList:GetSelectedLine()
        if not selected then return nil end
        local sid = orderMemberList:GetLine(selected):GetColumnText(3)
        if sid and sid ~= "" then return sid end
        local name = getSelectedOrderMemberName()
        for _, ply in ipairs(player.GetAll()) do
            if ply:Nick() == name then return ply:SteamID() end
        end
        return nil
    end

    local orderToolbar = vgui.Create("DPanel", orderAdminPanel)
    orderToolbar:Dock(TOP)
    orderToolbar:SetTall(36)
    function orderToolbar:Paint(w, h)
        surface.SetDrawColor(26, 28, 32, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 54, 60, 255)
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    local orderActionsBtn = vgui.Create("DButton", orderToolbar)
    orderActionsBtn:Dock(RIGHT)
    orderActionsBtn:SetText("Actions…")
    orderActionsBtn:DockMargin(6, 6, 6, 6)
    if orderActionsBtn.SetTextColor then orderActionsBtn:SetTextColor(Color(235,235,235)) end

    local function openOrderActionMenu(anchor)
        local orderName = getSelectedOrder()
        local memberSID = getSelectedOrderMemberSteamID()
        local m = DermaMenu(false, anchor)
        m:AddOption("Promote Rank", function()
            if orderName and memberSID then
                net.Start("PromoteHybridOrderMember")
                net.WriteString(memberSID)
                net.SendToServer()
                logAction("Order Promote -> " .. tostring(getSelectedOrderMemberName() or memberSID))
                timer.Simple(1, function() updateOrderMemberList(orderName) end)
            end
        end):SetIcon("icon16/arrow_up.png")
        m:AddOption("Demote Rank", function()
            if orderName and memberSID then
                net.Start("DemoteHybridOrderMember")
                net.WriteString(memberSID)
                net.SendToServer()
                logAction("Order Demote -> " .. tostring(getSelectedOrderMemberName() or memberSID))
                timer.Simple(1, function() updateOrderMemberList(orderName) end)
            end
        end):SetIcon("icon16/arrow_down.png")
        m:AddOption("Kick Member", function()
            if orderName and memberSID then
                Derma_Query("Kick this member from the order?", "Confirm Kick", "Yes", function()
                    net.Start("AdminRemoveHybridFromOrder")
                    net.WriteString(memberSID)
                    net.SendToServer()
                    logAction("Order Kick -> " .. tostring(getSelectedOrderMemberName() or memberSID))
                    timer.Simple(1, function() updateOrderMemberList(orderName) end)
                end, "No")
            end
        end):SetIcon("icon16/user_delete.png")
        m:AddSpacer()
        m:AddOption("Assign Player to Order…", function()
            local ord = getSelectedOrder()
            if not ord then return end
            local opts = DermaMenu()
            for _, ply in ipairs(player.GetAll()) do
                opts:AddOption(ply:Nick(), function()
                    local proceed = function()
                        net.Start("AdminAssignHybridToOrder")
                        net.WriteString(ply:SteamID())
                        net.WriteString(ord)
                        net.SendToServer()
                        logAction("Assign to Order -> " .. ord .. ": " .. ply:Nick())
                        timer.Simple(1, function() updateOrderMemberList(ord) end)
                    end
                    if not (IsHybrid and IsHybrid(ply)) then
                        Derma_Query("Convert this player to Hybrid before assigning?", "Auto-convert", "Yes", function()
                            net.Start("AdminMakeHybrid")
                            net.WriteString(ply:SteamID())
                            net.SendToServer()
                            timer.Simple(0.5, proceed)
                        end, "No")
                    else
                        proceed()
                    end
                end)
            end
            opts:Open()
        end):SetIcon("icon16/user_add.png")
        m:Open()
    end

    orderActionsBtn.DoClick = function()
        openOrderActionMenu(orderActionsBtn)
    end

    function orderMemberList:OnRowRightClick()
        openOrderActionMenu(orderMemberList)
    end

    function orderMemberList:DoDoubleClick()
        openOrderActionMenu(orderMemberList)
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
