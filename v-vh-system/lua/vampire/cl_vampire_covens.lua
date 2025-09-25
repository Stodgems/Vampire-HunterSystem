

include("vampire/sh_vampire_covens_config.lua")

net.Receive("OpenVampireCovensMenu", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Vampire Covens")
    frame:SetSize(600, 600)
    frame:Center()
    frame:MakePopup()

    local covenList = vgui.Create("DListView", frame)
    covenList:Dock(LEFT)
    covenList:SetWidth(200)
    covenList:SetMultiSelect(false)
    covenList:AddColumn("Coven Name")
    
    if not covenList.__oldAddLine then
        covenList.__oldAddLine = covenList.AddLine
        function covenList:AddLine(...)
            local line = self:__oldAddLine(...)
            if line and line.Columns then
                for _, col in pairs(line.Columns) do
                    if col.SetTextColor then col:SetTextColor(Color(235,235,235)) end
                end
            end
            return line
        end
    end

    for covenName, _ in pairs(VampireCovensConfig) do
        covenList:AddLine(covenName)
    end

    local memberList = vgui.Create("DListView", frame)
    memberList:Dock(FILL)
    memberList:SetMultiSelect(false)
    memberList:AddColumn("Player")
    memberList:AddColumn("Rank")
    
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
                memberList:AddLine(member.name, member.rank)
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

    local joinCovenButton = vgui.Create("DButton", frame)
    joinCovenButton:SetText("Join Coven")
    joinCovenButton:Dock(BOTTOM)
    joinCovenButton.DoClick = function()
        local covenName = getSelectedCoven()
        if covenName then
            net.Start("JoinVampireCoven")
            net.WriteString(covenName)
            net.SendToServer()
            timer.Simple(1, function()
                updateMemberList(covenName)
            end)
        end
    end

    local leaveCovenButton = vgui.Create("DButton", frame)
    leaveCovenButton:SetText("Leave Coven")
    leaveCovenButton:Dock(BOTTOM)
    leaveCovenButton.DoClick = function()
        net.Start("LeaveVampireCoven")
        net.SendToServer()
        timer.Simple(1, function()
            local covenName = getSelectedCoven()
            if covenName then
                updateMemberList(covenName)
            end
        end)
    end

    
    local promoteRankButton = vgui.Create("DButton", frame)
    promoteRankButton:SetText("Promote Rank")
    promoteRankButton:Dock(BOTTOM)
    promoteRankButton.DoClick = function()
        local covenName = getSelectedCoven()
        local memberSteamID = getSelectedMemberSteamID()
        if covenName and memberSteamID then
            net.Start("PromoteCovenRank")
            net.WriteString(memberSteamID)
            net.SendToServer()
            timer.Simple(1, function()
                updateMemberList(covenName)
            end)
        end
    end

    local demoteRankButton = vgui.Create("DButton", frame)
    demoteRankButton:SetText("Demote Rank")
    demoteRankButton:Dock(BOTTOM)
    demoteRankButton.DoClick = function()
        local covenName = getSelectedCoven()
        local memberSteamID = getSelectedMemberSteamID()
        if covenName and memberSteamID then
            net.Start("DemoteCovenRank")
            net.WriteString(memberSteamID)
            net.SendToServer()
            timer.Simple(1, function()
                updateMemberList(covenName)
            end)
        end
    end

    local kickMemberButton = vgui.Create("DButton", frame)
    kickMemberButton:SetText("Kick Member")
    kickMemberButton:Dock(BOTTOM)
    kickMemberButton.DoClick = function()
        local covenName = getSelectedCoven()
        local memberSteamID = getSelectedMemberSteamID()
        if covenName and memberSteamID then
            net.Start("KickCovenMember")
            net.WriteString(memberSteamID)
            net.SendToServer()
            timer.Simple(1, function()
                updateMemberList(covenName)
            end)
        end
    end


    memberList.OnRowRightClick = function(_, rowIndex, row)
        local menu = DermaMenu()
        menu:AddOption("Promote", function()
            local covenName = getSelectedCoven()
            local memberSteamID = getSelectedMemberSteamID()
            if covenName and memberSteamID then
                net.Start("PromoteCovenRank")
                net.WriteString(memberSteamID)
                net.SendToServer()
                timer.Simple(1, function()
                    updateMemberList(covenName)
                end)
            end
        end)
        menu:AddOption("Demote", function()
            local covenName = getSelectedCoven()
            local memberSteamID = getSelectedMemberSteamID()
            if covenName and memberSteamID then
                net.Start("DemoteCovenRank")
                net.WriteString(memberSteamID)
                net.SendToServer()
                timer.Simple(1, function()
                    updateMemberList(covenName)
                end)
            end
        end)
        menu:AddOption("Kick", function()
            local covenName = getSelectedCoven()
            local memberSteamID = getSelectedMemberSteamID()
            if covenName and memberSteamID then
                net.Start("KickCovenMember")
                net.WriteString(memberSteamID)
                net.SendToServer()
                timer.Simple(1, function()
                    updateMemberList(covenName)
                end)
            end
        end)
        menu:Open()
    end
end)


