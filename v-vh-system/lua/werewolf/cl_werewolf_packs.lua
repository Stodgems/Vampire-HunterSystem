

include("werewolf/sh_werewolf_packs_config.lua")

net.Receive("OpenWerewolfPacksMenu", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Werewolf Packs")
    frame:SetSize(600, 600)
    frame:Center()
    frame:MakePopup()

    local packList = vgui.Create("DListView", frame)
    packList:Dock(LEFT)
    packList:SetWidth(200)
    packList:SetMultiSelect(false)
    packList:AddColumn("Pack Name")
    
    if not packList.__oldAddLine then
        packList.__oldAddLine = packList.AddLine
        function packList:AddLine(...)
            local line = self:__oldAddLine(...)
            if line and line.Columns then
                for _, col in pairs(line.Columns) do
                    if col.SetTextColor then col:SetTextColor(Color(235,235,235)) end
                end
            end
            return line
        end
    end

    for packName, _ in pairs(WerewolfPacksConfig) do
        packList:AddLine(packName)
    end

    local memberList = vgui.Create("DListView", frame)
    memberList:Dock(FILL)
    memberList:SetMultiSelect(false)
    memberList:AddColumn("Player")
    memberList:AddColumn("Rank")
    memberList:AddColumn("SteamID")
    
    if not memberList.__oldAddLine then
        memberList.__oldAddLine = memberList.AddLine
        function memberList:AddLine(...)
            local line = self:__oldAddLine(...)
            if line and line.Columns then
                for _, col in pairs(line.Columns) do
                    if col.SetTextColor then col:SetTextColor(Color(235,235,235)) end
                end
            end
            return line
        end
    end

    local function updateMemberList(packName)
        memberList:Clear()
        local members = {}

        
        if packName == "Pack of the Wild" then
            table.insert(members, {name = "Alpha of the Wild", rank = "Pack Leader"})
        elseif packName == "Pack of the Moon" then
            table.insert(members, {name = "Lunar Alpha", rank = "Pack Leader"})
        elseif packName == "Pack of the Hunt" then
            table.insert(members, {name = "Hunt Master", rank = "Pack Leader"})
        elseif packName == "Pack of Shadows" then
            table.insert(members, {name = "Shadow Alpha", rank = "Pack Leader"})
        end

        net.Start("RequestPackMembers")
        net.WriteString(packName)
        net.SendToServer()

        net.Receive("ReceivePackMembers", function()
            local packMembers = net.ReadTable()
            for _, member in ipairs(packMembers) do
                table.insert(members, {name = member.name or member.steamID, rank = member.rank, steamID = member.steamID})
            end

            table.sort(members, function(a, b)
                local pack = WerewolfPacksConfig[packName]
                local aRankIndex = table.KeyFromValue(pack.ranks, a.rank) or 0
                local bRankIndex = table.KeyFromValue(pack.ranks, b.rank) or 0
                return aRankIndex > bRankIndex
            end)

            for _, member in ipairs(members) do
                memberList:AddLine(member.name, member.rank, member.steamID or "")
            end
        end)
    end

    packList.OnRowSelected = function(_, rowIndex, row)
        local packName = row:GetColumnText(1)
        updateMemberList(packName)
    end

    local function getSelectedPack()
        local selected = packList:GetSelectedLine()
        if not selected then return nil end
        return packList:GetLine(selected):GetColumnText(1)
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
        local sid = line:GetColumnText(3)
        if sid and sid ~= "" then return sid end
        
        for _, ply in ipairs(player.GetAll()) do
            if ply:Nick() == line:GetColumnText(1) then
                return ply:SteamID()
            end
        end
        return nil
    end

    local joinPackButton = vgui.Create("DButton", frame)
    joinPackButton:SetText("Join Pack")
    joinPackButton:Dock(BOTTOM)
    joinPackButton.DoClick = function()
        local packName = getSelectedPack()
        if packName then
            net.Start("JoinWerewolfPack")
            net.WriteString(packName)
            net.SendToServer()
            timer.Simple(1, function()
                updateMemberList(packName)
            end)
        end
    end

    local leavePackButton = vgui.Create("DButton", frame)
    leavePackButton:SetText("Leave Pack")
    leavePackButton:Dock(BOTTOM)
    leavePackButton.DoClick = function()
        net.Start("LeaveWerewolfPack")
        net.SendToServer()
        timer.Simple(1, function()
            local packName = getSelectedPack()
            if packName then
                updateMemberList(packName)
            end
        end)
    end

    
    local promoteRankButton = vgui.Create("DButton", frame)
    promoteRankButton:SetText("Promote Rank")
    promoteRankButton:Dock(BOTTOM)
    promoteRankButton.DoClick = function()
        local packName = getSelectedPack()
        local memberSteamID = getSelectedMemberSteamID()
        if packName and memberSteamID then
            net.Start("PromotePackRank")
            net.WriteString(memberSteamID)
            net.SendToServer()
            timer.Simple(1, function()
                updateMemberList(packName)
            end)
        end
    end

    local demoteRankButton = vgui.Create("DButton", frame)
    demoteRankButton:SetText("Demote Rank")
    demoteRankButton:Dock(BOTTOM)
    demoteRankButton.DoClick = function()
        local packName = getSelectedPack()
        local memberSteamID = getSelectedMemberSteamID()
        if packName and memberSteamID then
            net.Start("DemotePackRank")
            net.WriteString(memberSteamID)
            net.SendToServer()
            timer.Simple(1, function()
                updateMemberList(packName)
            end)
        end
    end

    local kickMemberButton = vgui.Create("DButton", frame)
    kickMemberButton:SetText("Kick Member")
    kickMemberButton:Dock(BOTTOM)
    kickMemberButton.DoClick = function()
        local packName = getSelectedPack()
        local memberSteamID = getSelectedMemberSteamID()
        if packName and memberSteamID then
            net.Start("KickPackMember")
            net.WriteString(memberSteamID)
            net.SendToServer()
            timer.Simple(1, function()
                updateMemberList(packName)
            end)
        end
    end

    
    local infoPanel = vgui.Create("DPanel", frame)
    infoPanel:Dock(RIGHT)
    infoPanel:SetWidth(250)
    infoPanel:SetBackgroundColor(Color(40, 40, 40))

    local infoTitle = vgui.Create("DLabel", infoPanel)
    infoTitle:SetText("Pack Information")
    infoTitle:SetFont("DermaLarge")
    infoTitle:SetTextColor(Color(255, 255, 255))
    infoTitle:Dock(TOP)
    infoTitle:SetTall(30)
    infoTitle:SetContentAlignment(5)

    local infoText = vgui.Create("DLabel", infoPanel)
    infoText:SetText("Select a pack to view information")
    infoText:SetTextColor(Color(200, 200, 200))
    infoText:SetWrap(true)
    infoText:SetAutoStretchVertical(true)
    infoText:Dock(TOP)
    infoText:DockMargin(10, 10, 10, 10)

    local benefitsText = vgui.Create("DLabel", infoPanel)
    benefitsText:SetText("")
    benefitsText:SetTextColor(Color(150, 255, 150))
    benefitsText:SetWrap(true)
    benefitsText:SetAutoStretchVertical(true)
    benefitsText:Dock(TOP)
    benefitsText:DockMargin(10, 5, 10, 10)

    packList.OnRowSelected = function(_, rowIndex, row)
        local packName = row:GetColumnText(1)
        updateMemberList(packName)
        
        
        local pack = WerewolfPacksConfig[packName]
        if pack then
            infoText:SetText(pack.description or "No description available")
            
            local benefitsStr = "Benefits:\n"
            if pack.benefits.health then
                benefitsStr = benefitsStr .. "• Health: " .. pack.benefits.health .. "\n"
            end
            if pack.benefits.speed then
                benefitsStr = benefitsStr .. "• Speed: " .. pack.benefits.speed .. "\n"
            end
            if pack.benefits.rageMultiplier then
                benefitsStr = benefitsStr .. "• Rage Multiplier: " .. pack.benefits.rageMultiplier .. "x\n"
            end
            if pack.benefits.moonEssenceMultiplier then
                benefitsStr = benefitsStr .. "• Moon Essence: " .. pack.benefits.moonEssenceMultiplier .. "x\n"
            end
            if pack.benefits.trackingBonus then
                benefitsStr = benefitsStr .. "• Tracking Bonus\n"
            end
            if pack.benefits.stealthBonus then
                benefitsStr = benefitsStr .. "• Stealth Bonus\n"
            end
            
            benefitsText:SetText(benefitsStr)
        end
    end

    memberList.OnRowRightClick = function(_, rowIndex, row)
        local menu = DermaMenu()
        menu:AddOption("Promote", function()
            local packName = getSelectedPack()
            local memberSteamID = getSelectedMemberSteamID()
            if packName and memberSteamID then
                net.Start("PromotePackRank")
                net.WriteString(memberSteamID)
                net.SendToServer()
                timer.Simple(1, function()
                    updateMemberList(packName)
                end)
            end
        end)
        menu:AddOption("Demote", function()
            local packName = getSelectedPack()
            local memberSteamID = getSelectedMemberSteamID()
            if packName and memberSteamID then
                net.Start("DemotePackRank")
                net.WriteString(memberSteamID)
                net.SendToServer()
                timer.Simple(1, function()
                    updateMemberList(packName)
                end)
            end
        end)
        menu:AddOption("Kick", function()
            local packName = getSelectedPack()
            local memberSteamID = getSelectedMemberSteamID()
            if packName and memberSteamID then
                net.Start("KickPackMember")
                net.WriteString(memberSteamID)
                net.SendToServer()
                timer.Simple(1, function()
                    updateMemberList(packName)
                end)
            end
        end)
        menu:Open()
    end
end)