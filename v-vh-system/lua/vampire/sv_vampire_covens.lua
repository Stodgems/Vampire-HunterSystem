-- Vampire Covens Logic

util.AddNetworkString("CreateVampireCoven")
util.AddNetworkString("JoinVampireCoven")
util.AddNetworkString("LeaveVampireCoven")
util.AddNetworkString("InvitePlayerToCoven")
util.AddNetworkString("RemovePlayerFromCoven")
util.AddNetworkString("PromotePlayerInCoven")
util.AddNetworkString("SyncVampireCovens")

VampireCovens = VampireCovens or {}

local function LoadVampireCovens()
    if not sql.TableExists("vampire_covens") then
        sql.Query("CREATE TABLE vampire_covens (covenID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, leader TEXT)")
    end
    if not sql.TableExists("vampire_coven_members") then
        sql.Query("CREATE TABLE vampire_coven_members (covenID INTEGER, steamID TEXT, rank TEXT)")
    end

    local covens = sql.Query("SELECT * FROM vampire_covens")
    if covens then
        for _, coven in ipairs(covens) do
            VampireCovens[tonumber(coven.covenID)] = { name = coven.name, leader = coven.leader, members = {} }
        end
    end

    local members = sql.Query("SELECT * FROM vampire_coven_members")
    if members then
        for _, member in ipairs(members) do
            if VampireCovens[tonumber(member.covenID)] then
                table.insert(VampireCovens[tonumber(member.covenID)].members, { steamID = member.steamID, rank = member.rank })
            end
        end
    end
end

local function SaveVampireCoven(covenID)
    local coven = VampireCovens[covenID]
    if not coven then return end

    local nameEscaped = sql.SQLStr(coven.name)
    local leaderEscaped = sql.SQLStr(coven.leader)
    sql.Query(string.format("REPLACE INTO vampire_covens (covenID, name, leader) VALUES (%d, %s, %s)", covenID, nameEscaped, leaderEscaped))

    sql.Query(string.format("DELETE FROM vampire_coven_members WHERE covenID = %d", covenID))
    for _, member in ipairs(coven.members) do
        local steamIDEscaped = sql.SQLStr(member.steamID)
        local rankEscaped = sql.SQLStr(member.rank)
        sql.Query(string.format("INSERT INTO vampire_coven_members (covenID, steamID, rank) VALUES (%d, %s, %s)", covenID, steamIDEscaped, rankEscaped))
    end
end

local function CreateVampireCoven(ply, name)
    for _, coven in pairs(VampireCovens) do
        if coven.leader == ply:SteamID() then
            ply:ChatPrint("You already lead a coven.")
            return
        end
    end

    if ply:getDarkRPVar("money") < 10000 then
        ply:ChatPrint("You need 10k money to create a coven.")
        return
    end

    ply:addMoney(-10000)

    local covenID = tonumber(sql.QueryValue("SELECT MAX(covenID) FROM vampire_covens") or 0)
    covenID = covenID or 0
    covenID = covenID + 1

    VampireCovens[covenID] = { name = name, leader = ply:SteamID(), members = { { steamID = ply:SteamID(), rank = "Leader" } } }
    SaveVampireCoven(covenID)

    ply:ChatPrint("You have created a new coven: " .. name)
    SyncVampireCovens()
end

local function JoinVampireCoven(ply, covenID)
    local coven = VampireCovens[tonumber(covenID)]
    if not coven then return end

    table.insert(coven.members, { steamID = ply:SteamID(), rank = "Member" })
    SaveVampireCoven(covenID)

    ply:ChatPrint("You have joined the coven: " .. coven.name)
    SyncVampireCovens()
end

local function LeaveVampireCoven(ply, covenID)
    local coven = VampireCovens[tonumber(covenID)]
    if not coven then return end

    for i, member in ipairs(coven.members) do
        if member.steamID == ply:SteamID() then
            table.remove(coven.members, i)
            break
        end
    end

    if #coven.members == 0 then
        sql.Query(string.format("DELETE FROM vampire_covens WHERE covenID = %d", covenID))
        sql.Query(string.format("DELETE FROM vampire_coven_members WHERE covenID = %d", covenID))
        VampireCovens[covenID] = nil
    else
        SaveVampireCoven(covenID)
    end

    ply:ChatPrint("You have left the coven: " .. coven.name)
    SyncVampireCovens()
end

local function InvitePlayerToCoven(ply, covenID, steamID)
    local coven = VampireCovens[tonumber(covenID)]
    if not coven then return end
    local member = table.KeyFromValue(coven.members, ply:SteamID(), "steamID")
    if not member or (coven.leader ~= ply:SteamID() and coven.members[member].rank ~= "Leader" and coven.members[member].rank ~= "Officer") then
        ply:ChatPrint("You do not have permission to invite players.")
        return
    end

    table.insert(coven.members, { steamID = steamID, rank = "Member" })
    SaveVampireCoven(covenID)

    ply:ChatPrint("You have invited " .. steamID .. " to the coven: " .. coven.name)
    SyncVampireCovens()
end

local function RemovePlayerFromCoven(ply, covenID, steamID)
    local coven = VampireCovens[tonumber(covenID)]
    if not coven then return end
    local member = table.KeyFromValue(coven.members, ply:SteamID(), "steamID")
    if not member or (coven.leader ~= ply:SteamID() and coven.members[member].rank ~= "Leader" and coven.members[member].rank ~= "Officer") then
        ply:ChatPrint("You do not have permission to remove players.")
        return
    end

    for i, member in ipairs(coven.members) do
        if member.steamID == steamID then
            table.remove(coven.members, i)
            break
        end
    end

    SaveVampireCoven(covenID)
    ply:ChatPrint("You have removed " .. steamID .. " from the coven: " .. coven.name)
    SyncVampireCovens()
end

local function PromotePlayerInCoven(ply, covenID, steamID, rank)
    local coven = VampireCovens[tonumber(covenID)]
    if not coven then return end
    local member = table.KeyFromValue(coven.members, ply:SteamID(), "steamID")
    if not member or (coven.leader ~= ply:SteamID() and coven.members[member].rank ~= "Leader") then
        ply:ChatPrint("You do not have permission to promote players.")
        return
    end

    for i, member in ipairs(coven.members) do
        if member.steamID == steamID then
            coven.members[i].rank = rank
            break
        end
    end

    SaveVampireCoven(covenID)
    ply:ChatPrint("You have promoted " .. steamID .. " to " .. rank .. " in the coven: " .. coven.name)
    SyncVampireCovens()
end

local function SyncVampireCovens()
    net.Start("SyncVampireCovens")
    net.WriteTable(VampireCovens)
    net.Broadcast()
end

net.Receive("CreateVampireCoven", function(len, ply)
    local name = net.ReadString()
    CreateVampireCoven(ply, name)
end)

net.Receive("JoinVampireCoven", function(len, ply)
    local covenID = net.ReadInt(32)
    JoinVampireCoven(ply, covenID)
end)

net.Receive("LeaveVampireCoven", function(len, ply)
    local covenID = net.ReadInt(32)
    LeaveVampireCoven(ply, covenID)
end)

net.Receive("InvitePlayerToCoven", function(len, ply)
    local covenID = net.ReadInt(32)
    local steamID = net.ReadString()
    InvitePlayerToCoven(ply, covenID, steamID)
end)

net.Receive("RemovePlayerFromCoven", function(len, ply)
    local covenID = net.ReadInt(32)
    local steamID = net.ReadString()
    RemovePlayerFromCoven(ply, covenID, steamID)
end)

net.Receive("PromotePlayerInCoven", function(len, ply)
    local covenID = net.ReadInt(32)
    local steamID = net.ReadString()
    local rank = net.ReadString()
    PromotePlayerInCoven(ply, covenID, steamID, rank)
end)

hook.Add("PlayerInitialSpawn", "SyncVampireCovens", function(ply)
    net.Start("SyncVampireCovens")
    net.WriteTable(VampireCovens)
    net.Send(ply)
end)

LoadVampireCovens()
