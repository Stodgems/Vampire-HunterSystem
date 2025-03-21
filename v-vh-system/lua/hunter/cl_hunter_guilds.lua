-- Hunter Guilds Menu

include("hunter/sh_hunter_guilds_config.lua") -- Include the Hunter Guilds config

net.Receive("OpenHunterGuildsMenu", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Hunter Guilds")
    frame:SetSize(600, 600) -- Increase the size to accommodate more information
    frame:Center()
    frame:MakePopup()

    local guildList = vgui.Create("DListView", frame)
    guildList:Dock(LEFT)
    guildList:SetWidth(200)
    guildList:SetMultiSelect(false)
    guildList:AddColumn("Guild Name")

    for guildName, _ in pairs(HunterGuildsConfig) do
        guildList:AddLine(guildName)
    end

    local memberList = vgui.Create("DListView", frame)
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

    local function canPromoteOrDemote()
        local ply = LocalPlayer()
        if not ply.hunterGuild then return false end
        local guild = HunterGuildsConfig[ply.hunterGuild]
        if not guild then return false end
        local playerRank = ply.hunterGuildRank
        local playerIndex = table.KeyFromValue(guild.ranks, playerRank)
        return playerIndex and playerIndex >= 4 -- Leader or above
    end

    local joinGuildButton = vgui.Create("DButton", frame)
    joinGuildButton:SetText("Join Guild")
    joinGuildButton:Dock(BOTTOM)
    joinGuildButton.DoClick = function()
        local guildName = getSelectedGuild()
        if guildName then
            net.Start("JoinHunterGuild")
            net.WriteString(guildName)
            net.SendToServer()
            timer.Simple(1, function() -- Delay to ensure the server processes the join request
                updateMemberList(guildName)
            end)
        end
    end

    local leaveGuildButton = vgui.Create("DButton", frame)
    leaveGuildButton:SetText("Leave Guild")
    leaveGuildButton:Dock(BOTTOM)
    leaveGuildButton.DoClick = function()
        net.Start("LeaveHunterGuild")
        net.SendToServer()
        timer.Simple(1, function() -- Delay to ensure the server processes the leave request
            local guildName = getSelectedGuild()
            if guildName then
                updateMemberList(guildName)
            end
        end)
    end

    local promoteRankButton = vgui.Create("DButton", frame)
    promoteRankButton:SetText("Promote Rank")
    promoteRankButton:Dock(BOTTOM)
    promoteRankButton:SetEnabled(canPromoteOrDemote())
    promoteRankButton.DoClick = function()
        local selectedMember = memberList:GetSelectedLine()
        if selectedMember then
            local targetName = memberList:GetLine(selectedMember):GetColumnText(1)
            local target = player.GetByNick(targetName)
            if target then
                net.Start("PromoteGuildRank")
                net.WriteString(target:SteamID())
                net.SendToServer()
                timer.Simple(1, function() -- Delay to ensure the server processes the promotion
                    local guildName = getSelectedGuild()
                    if guildName then
                        updateMemberList(guildName)
                    end
                end)
            end
        end
    end

    local demoteRankButton = vgui.Create("DButton", frame)
    demoteRankButton:SetText("Demote Rank")
    demoteRankButton:Dock(BOTTOM)
    demoteRankButton:SetEnabled(canPromoteOrDemote())
    demoteRankButton.DoClick = function()
        local selectedMember = memberList:GetSelectedLine()
        if selectedMember then
            local targetName = memberList:GetLine(selectedMember):GetColumnText(1)
            local target = player.GetByNick(targetName)
            if target then
                net.Start("DemoteGuildRank")
                net.WriteString(target:SteamID())
                net.SendToServer()
                timer.Simple(1, function() -- Delay to ensure the server processes the demotion
                    local guildName = getSelectedGuild()
                    if guildName then
                        updateMemberList(guildName)
                    end
                end)
            end
        end
    end
end)


