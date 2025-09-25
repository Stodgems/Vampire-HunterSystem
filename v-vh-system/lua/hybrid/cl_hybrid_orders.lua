

include("hybrid/sh_hybrid_orders_config.lua")

net.Receive("OpenHybridOrdersMenu", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Hybrid Orders")
    frame:SetSize(600, 600)
    frame:Center()
    frame:MakePopup()

    local orderList = vgui.Create("DListView", frame)
    orderList:Dock(LEFT)
    orderList:SetWidth(200)
    orderList:SetMultiSelect(false)
    orderList:AddColumn("Order Name")
    
    if not orderList.__oldAddLine then
        orderList.__oldAddLine = orderList.AddLine
        function orderList:AddLine(...)
            local line = self:__oldAddLine(...)
            if line and line.Columns then
                for _, col in pairs(line.Columns) do
                    if col.SetTextColor then col:SetTextColor(Color(235,235,235)) end
                end
            end
            return line
        end
    end

    for orderName, _ in pairs(HybridOrdersConfig) do
        orderList:AddLine(orderName)
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

    local function updateMemberList(orderName)
        memberList:Clear()
        local members = {}

        net.Start("RequestHybridOrderMembers")
        net.WriteString(orderName)
        net.SendToServer()

        net.Receive("ReceiveHybridOrderMembers", function()
            local orderMembers = net.ReadTable()
            for _, member in ipairs(orderMembers) do
                table.insert(members, { name = member.name or member.steamID, rank = member.rank, steamID = member.steamID })
            end

            table.sort(members, function(a, b)
                local order = HybridOrdersConfig[orderName]
                local aRankIndex = table.KeyFromValue(order.ranks, a.rank) or 0
                local bRankIndex = table.KeyFromValue(order.ranks, b.rank) or 0
                return aRankIndex > bRankIndex
            end)

            for _, member in ipairs(members) do
                memberList:AddLine(member.name, member.rank, member.steamID or "")
            end
        end)
    end

    orderList.OnRowSelected = function(_, rowIndex, row)
        local orderName = row:GetColumnText(1)
        updateMemberList(orderName)
    end

    local function getSelectedOrder()
        local selected = orderList:GetSelectedLine()
        if not selected then return nil end
        return orderList:GetLine(selected):GetColumnText(1)
    end

    local function getSelectedMemberSID()
        local selected = memberList:GetSelectedLine()
        if not selected then return nil end
        return memberList:GetLine(selected):GetColumnText(3)
    end

    local joinBtn = vgui.Create("DButton", frame)
    joinBtn:SetText("Join Order")
    joinBtn:Dock(BOTTOM)
    joinBtn.DoClick = function()
        local ord = getSelectedOrder()
        if ord then
            net.Start("JoinHybridOrder")
            net.WriteString(ord)
            net.SendToServer()
            timer.Simple(1, function() updateMemberList(ord) end)
        end
    end

    local leaveBtn = vgui.Create("DButton", frame)
    leaveBtn:SetText("Leave Order")
    leaveBtn:Dock(BOTTOM)
    leaveBtn.DoClick = function()
        net.Start("LeaveHybridOrder")
        net.SendToServer()
        local ord = getSelectedOrder()
        if ord then
            timer.Simple(1, function() updateMemberList(ord) end)
        end
    end

    local promoteBtn = vgui.Create("DButton", frame)
    promoteBtn:SetText("Promote Rank")
    promoteBtn:Dock(BOTTOM)
    promoteBtn.DoClick = function()
        local ord = getSelectedOrder()
        local sid = getSelectedMemberSID()
        if ord and sid then
            net.Start("PromoteOrderRank")
            net.WriteString(sid)
            net.SendToServer()
            timer.Simple(1, function() updateMemberList(ord) end)
        end
    end

    local demoteBtn = vgui.Create("DButton", frame)
    demoteBtn:SetText("Demote Rank")
    demoteBtn:Dock(BOTTOM)
    demoteBtn.DoClick = function()
        local ord = getSelectedOrder()
        local sid = getSelectedMemberSID()
        if ord and sid then
            net.Start("DemoteOrderRank")
            net.WriteString(sid)
            net.SendToServer()
            timer.Simple(1, function() updateMemberList(ord) end)
        end
    end

    local kickBtn = vgui.Create("DButton", frame)
    kickBtn:SetText("Kick Member")
    kickBtn:Dock(BOTTOM)
    kickBtn.DoClick = function()
        local ord = getSelectedOrder()
        local sid = getSelectedMemberSID()
        if ord and sid then
            net.Start("KickOrderMember")
            net.WriteString(sid)
            net.SendToServer()
            timer.Simple(1, function() updateMemberList(ord) end)
        end
    end
end)
