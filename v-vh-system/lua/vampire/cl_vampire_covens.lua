-- Vampire Covens Menu

local VampireCovens = {}

net.Receive("SyncVampireCovens", function()
    VampireCovens = net.ReadTable()
end)

local function OpenVampireCovensMenu()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Vampire Covens")
    frame:SetSize(400, 600)
    frame:Center()
    frame:MakePopup()

    local covenList = vgui.Create("DListView", frame)
    covenList:Dock(FILL)
    covenList:SetMultiSelect(false)
    covenList:AddColumn("Coven Name")
    covenList:AddColumn("Leader")

    for covenID, coven in pairs(VampireCovens) do
        local leaderName = player.GetBySteamID(coven.leader) and player.GetBySteamID(coven.leader):Nick() or coven.leader
        covenList:AddLine(coven.name, leaderName)
    end

    local function getSelectedCoven()
        local selected = covenList:GetSelectedLine()
        if not selected then return nil end
        local line = covenList:GetLine(selected)
        for covenID, coven in pairs(VampireCovens) do
            if coven.name == line:GetColumnText(1) then
                return covenID
            end
        end
        return nil
    end

    local createCovenButton = vgui.Create("DButton", frame)
    createCovenButton:SetText("Create Coven (10k money)")
    createCovenButton:Dock(BOTTOM)
    createCovenButton.DoClick = function()
        Derma_StringRequest("Create Coven", "Enter the coven name:", "", function(name)
            net.Start("CreateVampireCoven")
            net.WriteString(name)
            net.SendToServer()
        end)
    end

    local joinCovenButton = vgui.Create("DButton", frame)
    joinCovenButton:SetText("Join Coven")
    joinCovenButton:Dock(BOTTOM)
    joinCovenButton.DoClick = function()
        local covenID = getSelectedCoven()
        if covenID then
            net.Start("JoinVampireCoven")
            net.WriteInt(covenID, 32)
            net.SendToServer()
        end
    end

    local leaveCovenButton = vgui.Create("DButton", frame)
    leaveCovenButton:SetText("Leave Coven")
    leaveCovenButton:Dock(BOTTOM)
    leaveCovenButton.DoClick = function()
        local covenID = getSelectedCoven()
        if covenID then
            net.Start("LeaveVampireCoven")
            net.WriteInt(covenID, 32)
            net.SendToServer()
        end
    end

    local invitePlayerButton = vgui.Create("DButton", frame)
    invitePlayerButton:SetText("Invite Player")
    invitePlayerButton:Dock(BOTTOM)
    invitePlayerButton.DoClick = function()
        local covenID = getSelectedCoven()
        if covenID then
            local inviteFrame = vgui.Create("DFrame")
            inviteFrame:SetTitle("Invite Player")
            inviteFrame:SetSize(300, 400)
            inviteFrame:Center()
            inviteFrame:MakePopup()

            local playerList = vgui.Create("DListView", inviteFrame)
            playerList:Dock(FILL)
            playerList:SetMultiSelect(false)
            playerList:AddColumn("Player Name")

            for _, ply in ipairs(player.GetAll()) do
                playerList:AddLine(ply:Nick())
            end

            local inviteButton = vgui.Create("DButton", inviteFrame)
            inviteButton:SetText("Invite")
            inviteButton:Dock(BOTTOM)
            inviteButton.DoClick = function()
                local selected = playerList:GetSelectedLine()
                if selected then
                    local line = playerList:GetLine(selected)
                    local playerName = line:GetColumnText(1)
                    local target = player.GetByNick(playerName)
                    if target then
                        net.Start("InvitePlayerToCoven")
                        net.WriteInt(covenID, 32)
                        net.WriteString(target:SteamID())
                        net.SendToServer()
                        inviteFrame:Close()
                    end
                end
            end
        end
    end

    local removePlayerButton = vgui.Create("DButton", frame)
    removePlayerButton:SetText("Remove Player")
    removePlayerButton:Dock(BOTTOM)
    removePlayerButton.DoClick = function()
        local covenID = getSelectedCoven()
        if covenID then
            local removeFrame = vgui.Create("DFrame")
            removeFrame:SetTitle("Remove Player")
            removeFrame:SetSize(300, 400)
            removeFrame:Center()
            removeFrame:MakePopup()

            local memberList = vgui.Create("DListView", removeFrame)
            memberList:Dock(FILL)
            memberList:SetMultiSelect(false)
            memberList:AddColumn("Player Name")

            local coven = VampireCovens[covenID]
            if coven then
                for _, member in ipairs(coven.members) do
                    local memberName = player.GetBySteamID(member.steamID) and player.GetBySteamID(member.steamID):Nick() or member.steamID
                    memberList:AddLine(memberName)
                end
            end

            local removeButton = vgui.Create("DButton", removeFrame)
            removeButton:SetText("Remove")
            removeButton:Dock(BOTTOM)
            removeButton.DoClick = function()
                local selected = memberList:GetSelectedLine()
                if selected then
                    local line = memberList:GetLine(selected)
                    local playerName = line:GetColumnText(1)
                    local target = player.GetByNick(playerName)
                    if target then
                        net.Start("RemovePlayerFromCoven")
                        net.WriteInt(covenID, 32)
                        net.WriteString(target:SteamID())
                        net.SendToServer()
                        removeFrame:Close()
                    end
                end
            end
        end
    end

    local promotePlayerButton = vgui.Create("DButton", frame)
    promotePlayerButton:SetText("Promote Player")
    promotePlayerButton:Dock(BOTTOM)
    promotePlayerButton.DoClick = function()
        local covenID = getSelectedCoven()
        if covenID then
            local promoteFrame = vgui.Create("DFrame")
            promoteFrame:SetTitle("Promote Player")
            promoteFrame:SetSize(300, 400)
            promoteFrame:Center()
            promoteFrame:MakePopup()

            local memberList = vgui.Create("DListView", promoteFrame)
            memberList:Dock(FILL)
            memberList:SetMultiSelect(false)
            memberList:AddColumn("Player Name")

            local coven = VampireCovens[covenID]
            if coven then
                for _, member in ipairs(coven.members) do
                    local memberName = player.GetBySteamID(member.steamID) and player.GetBySteamID(member.steamID):Nick() or member.steamID
                    memberList:AddLine(memberName)
                end
            end

            local promoteButton = vgui.Create("DButton", promoteFrame)
            promoteButton:SetText("Promote")
            promoteButton:Dock(BOTTOM)
            promoteButton.DoClick = function()
                local selected = memberList:GetSelectedLine()
                if selected then
                    local line = memberList:GetLine(selected)
                    local playerName = line:GetColumnText(1)
                    local target = player.GetByNick(playerName)
                    if target then
                        Derma_StringRequest("Promote Player", "Enter the new rank (Leader/Officer/Member):", "", function(rank)
                            net.Start("PromotePlayerInCoven")
                            net.WriteInt(covenID, 32)
                            net.WriteString(target:SteamID())
                            net.WriteString(rank)
                            net.SendToServer()
                            promoteFrame:Close()
                        end)
                    end
                end
            end
        end
    end
end

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

local function OpenCovenMembersMenu(covenID)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Coven Members")
    frame:SetSize(400, 500)
    frame:Center()
    frame:MakePopup()

    local memberList = vgui.Create("DListView", frame)
    memberList:Dock(FILL)
    memberList:SetMultiSelect(false)
    memberList:AddColumn("Player Name")
    memberList:AddColumn("Rank")

    local coven = VampireCovens[covenID]
    if coven then
        for _, member in ipairs(coven.members) do
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
            net.Start("InvitePlayerToCoven")
            net.WriteInt(covenID, 32)
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
            net.Start("RemovePlayerFromCoven")
            net.WriteInt(covenID, 32)
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
                net.Start("PromotePlayerInCoven")
                net.WriteInt(covenID, 32)
                net.WriteString(steamID)
                net.WriteString(rank)
                net.SendToServer()
            end)
        end
    end
end

concommand.Add("open_vampire_covens_menu", OpenVampireCovensMenu)

hook.Add("PlayerSay", "OpenVampireCovensMenuCommand", function(ply, text)
    if string.lower(text) == "!vcoven" then
        OpenVampireCovensMenu()
        return ""
    end
end)
