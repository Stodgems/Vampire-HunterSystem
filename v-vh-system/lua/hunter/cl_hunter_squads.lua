-- Hunter Squads Menu

local HunterSquads = {}

net.Receive("SyncHunterSquads", function()
    HunterSquads = net.ReadTable()
end)

local function OpenHunterSquadsMenu()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Hunter Squads")
    frame:SetSize(400, 600)
    frame:Center()
    frame:MakePopup()

    local squadList = vgui.Create("DListView", frame)
    squadList:Dock(FILL)
    squadList:SetMultiSelect(false)
    squadList:AddColumn("Squad Name")
    squadList:AddColumn("Leader")

    for squadID, squad in pairs(HunterSquads) do
        local leaderName = player.GetBySteamID(squad.leader) and player.GetBySteamID(squad.leader):Nick() or squad.leader
        squadList:AddLine(squad.name, leaderName)
    end

    local function getSelectedSquad()
        local selected = squadList:GetSelectedLine()
        if not selected then return nil end
        local line = squadList:GetLine(selected)
        for squadID, squad in pairs(HunterSquads) do
            if squad.name == line:GetColumnText(1) then
                return squadID
            end
        end
        return nil
    end

    local createSquadButton = vgui.Create("DButton", frame)
    createSquadButton:SetText("Create Squad (10k money)")
    createSquadButton:Dock(BOTTOM)
    createSquadButton.DoClick = function()
        Derma_StringRequest("Create Squad", "Enter the squad name:", "", function(name)
            net.Start("CreateHunterSquad")
            net.WriteString(name)
            net.SendToServer()
        end)
    end

    local joinSquadButton = vgui.Create("DButton", frame)
    joinSquadButton:SetText("Join Squad")
    joinSquadButton:Dock(BOTTOM)
    joinSquadButton.DoClick = function()
        local squadID = getSelectedSquad()
        if squadID then
            net.Start("JoinHunterSquad")
            net.WriteInt(squadID, 32)
            net.SendToServer()
        end
    end

    local leaveSquadButton = vgui.Create("DButton", frame)
    leaveSquadButton:SetText("Leave Squad")
    leaveSquadButton:Dock(BOTTOM)
    leaveSquadButton.DoClick = function()
        local squadID = getSelectedSquad()
        if squadID then
            net.Start("LeaveHunterSquad")
            net.WriteInt(squadID, 32)
            net.SendToServer()
        end
    end

    local invitePlayerButton = vgui.Create("DButton", frame)
    invitePlayerButton:SetText("Invite Player")
    invitePlayerButton:Dock(BOTTOM)
    invitePlayerButton.DoClick = function()
        local squadID = getSelectedSquad()
        if squadID then
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
                        net.Start("InvitePlayerToSquad")
                        net.WriteInt(squadID, 32)
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
        local squadID = getSelectedSquad()
        if squadID then
            local removeFrame = vgui.Create("DFrame")
            removeFrame:SetTitle("Remove Player")
            removeFrame:SetSize(300, 400)
            removeFrame:Center()
            removeFrame:MakePopup()

            local memberList = vgui.Create("DListView", removeFrame)
            memberList:Dock(FILL)
            memberList:SetMultiSelect(false)
            memberList:AddColumn("Player Name")

            local squad = HunterSquads[squadID]
            if squad then
                for _, member in ipairs(squad.members) do
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
                        net.Start("RemovePlayerFromSquad")
                        net.WriteInt(squadID, 32)
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
        local squadID = getSelectedSquad()
        if squadID then
            local promoteFrame = vgui.Create("DFrame")
            promoteFrame:SetTitle("Promote Player")
            promoteFrame:SetSize(300, 400)
            promoteFrame:Center()
            promoteFrame:MakePopup()

            local memberList = vgui.Create("DListView", promoteFrame)
            memberList:Dock(FILL)
            memberList:SetMultiSelect(false)
            memberList:AddColumn("Player Name")

            local squad = HunterSquads[squadID]
            if squad then
                for _, member in ipairs(squad.members) do
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
                            net.Start("PromotePlayerInSquad")
                            net.WriteInt(squadID, 32)
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

local function OpenSquadMembersMenu(squadID)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Squad Members")
    frame:SetSize(400, 500)
    frame:Center()
    frame:MakePopup()

    local memberList = vgui.Create("DListView", frame)
    memberList:Dock(FILL)
    memberList:SetMultiSelect(false)
    memberList:AddColumn("Player Name")
    memberList:AddColumn("Rank")

    local squad = HunterSquads[squadID]
    if squad then
        for _, member in ipairs(squad.members) do
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
            net.Start("InvitePlayerToSquad")
            net.WriteInt(squadID, 32)
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
            net.Start("RemovePlayerFromSquad")
            net.WriteInt(squadID, 32)
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
                net.Start("PromotePlayerInSquad")
                net.WriteInt(squadID, 32)
                net.WriteString(steamID)
                net.WriteString(rank)
                net.SendToServer()
            end)
        end
    end
end

concommand.Add("open_hunter_squads_menu", OpenHunterSquadsMenu)


