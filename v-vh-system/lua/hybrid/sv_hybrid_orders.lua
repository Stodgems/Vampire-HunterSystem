

include("hybrid/sh_hybrid_orders_config.lua")


util.AddNetworkString("RequestHybridOrderMembers")
util.AddNetworkString("ReceiveHybridOrderMembers")
util.AddNetworkString("OpenHybridOrdersMenu")
util.AddNetworkString("JoinHybridOrder")
util.AddNetworkString("LeaveHybridOrder")
util.AddNetworkString("PromoteOrderRank")
util.AddNetworkString("DemoteOrderRank")
util.AddNetworkString("KickOrderMember")


local function EnsureOrdersTable()
    if not sql.TableExists("hybrid_orders") then
        sql.Query("CREATE TABLE hybrid_orders (steamID TEXT PRIMARY KEY, `order` TEXT, orderRank TEXT)")
    end
end

EnsureOrdersTable()

local function SaveHybridOrder(steamID, orderName, orderRank)
    EnsureOrdersTable()
    local q = string.format(
        "REPLACE INTO hybrid_orders (steamID, `order`, orderRank) VALUES ('%s', %s, %s)",
        steamID,
        sql.SQLStr(orderName or ""),
        sql.SQLStr(orderRank or "")
    )
    sql.Query(q)
end

local function RemoveHybridOrder(steamID)
    EnsureOrdersTable()
    local q = string.format("DELETE FROM hybrid_orders WHERE steamID = '%s'", steamID)
    sql.Query(q)
end


function AssignHybridToOrder(ply, orderName)
    if not IsHybrid(ply) then return end
    if not HybridOrdersConfig[orderName] then return end
    local rank = HybridOrdersConfig[orderName].ranks[1] or "Acolyte"
    SaveHybridOrder(ply:SteamID(), orderName, rank)
    ply:ChatPrint("You have joined the " .. orderName .. " as " .. rank .. ".")
end

function RemoveHybridFromOrder(ply)
    RemoveHybridOrder(ply:SteamID())
    ply:ChatPrint("You have left your hybrid order.")
end

local function GetOrderRow(steamID)
    EnsureOrdersTable()
    local rows = sql.Query("SELECT * FROM hybrid_orders WHERE steamID = '" .. steamID .. "'")
    return rows and rows[1] or nil
end

function PromoteHybridOrderRank(ply)
    local row = GetOrderRow(ply:SteamID())
    if not row then return end
    local orderName = row["order"]
    local rank = row.orderRank
    local order = HybridOrdersConfig[orderName]
    if not order then return end
    local idx = table.KeyFromValue(order.ranks, rank) or 1
    if idx < #order.ranks then
        local newRank = order.ranks[idx + 1]
        SaveHybridOrder(ply:SteamID(), orderName, newRank)
        ply:ChatPrint("Promoted to " .. newRank .. " in " .. orderName)
    end
end

function DemoteHybridOrderRank(ply)
    local row = GetOrderRow(ply:SteamID())
    if not row then return end
    local orderName = row["order"]
    local rank = row.orderRank
    local order = HybridOrdersConfig[orderName]
    if not order then return end
    local idx = table.KeyFromValue(order.ranks, rank) or 1
    if idx > 1 then
        local newRank = order.ranks[idx - 1]
        SaveHybridOrder(ply:SteamID(), orderName, newRank)
        ply:ChatPrint("Demoted to " .. newRank .. " in " .. orderName)
    end
end


net.Receive("RequestHybridOrderMembers", function(len, ply)
    local orderName = net.ReadString()
    local members = {}
    local rows = sql.Query("SELECT steamID, orderRank FROM hybrid_orders WHERE `order` = " .. sql.SQLStr(orderName))
    if rows then
        for _, row in ipairs(rows) do
            local sid = row.steamID
            local p = player.GetBySteamID(sid)
            if p then
                table.insert(members, { name = p:Nick(), rank = row.orderRank, steamID = sid })
            else
                table.insert(members, { name = sid, rank = row.orderRank, steamID = sid })
            end
        end
    end
    net.Start("ReceiveHybridOrderMembers")
    net.WriteTable(members)
    net.Send(ply)
end)


hook.Add("PlayerSay", "OpenHybridOrdersMenuCommand", function(ply, text)
    if string.lower(text) == "!horder" then
        if not IsHybrid(ply) then
            ply:ChatPrint("Only hybrids can access the orders menu.")
            return ""
        end
        net.Start("OpenHybridOrdersMenu")
        net.Send(ply)
        return ""
    end
end)


local function GetPlayerOrderInfo(ply)
    local row = GetOrderRow(ply:SteamID())
    if not row then return nil end
    local orderName = row["order"]
    local rank = row.orderRank
    local order = HybridOrdersConfig[orderName]
    if not order then return nil end
    local idx = table.KeyFromValue(order.ranks, rank) or 1
    return orderName, rank, idx, order
end

net.Receive("JoinHybridOrder", function(len, ply)
    local orderName = net.ReadString()
    AssignHybridToOrder(ply, orderName)
end)

net.Receive("LeaveHybridOrder", function(len, ply)
    RemoveHybridFromOrder(ply)
end)

net.Receive("PromoteOrderRank", function(len, ply)
    local targetSID = net.ReadString()
    local target = player.GetBySteamID(targetSID)
    if not IsValid(target) then return end
    local orderName, playerRank, playerIdx, order = GetPlayerOrderInfo(ply)
    local _, targetRank, targetIdx = GetPlayerOrderInfo(target)
    if order and orderName and targetIdx and playerIdx and orderName == select(1, GetPlayerOrderInfo(target)) then
        if playerIdx >= 4 and targetIdx < playerIdx then
            PromoteHybridOrderRank(target)
        end
    end
end)

net.Receive("DemoteOrderRank", function(len, ply)
    local targetSID = net.ReadString()
    local target = player.GetBySteamID(targetSID)
    if not IsValid(target) then return end
    local orderName, playerRank, playerIdx, order = GetPlayerOrderInfo(ply)
    local targetOrderName, targetRank, targetIdx = GetPlayerOrderInfo(target)
    if order and orderName and targetOrderName == orderName and playerIdx and targetIdx then
        if playerIdx >= 4 and targetIdx > 1 then
            DemoteHybridOrderRank(target)
        end
    end
end)

net.Receive("KickOrderMember", function(len, ply)
    local targetSID = net.ReadString()
    local target = player.GetBySteamID(targetSID)
    if not IsValid(target) then return end
    local orderName, playerRank, playerIdx, order = GetPlayerOrderInfo(ply)
    local targetOrderName = select(1, GetPlayerOrderInfo(target))
    if order and orderName and targetOrderName == orderName and playerIdx then
        if playerIdx >= 4 then
            RemoveHybridFromOrder(target)
            target:ChatPrint("You have been kicked from the order by " .. ply:Nick())
        end
    end
end)
