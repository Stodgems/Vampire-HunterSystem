-- Hunter Squads Logic

util.AddNetworkString("CreateHunterSquad")
util.AddNetworkString("JoinHunterSquad")
util.AddNetworkString("LeaveHunterSquad")
util.AddNetworkString("InvitePlayerToSquad")
util.AddNetworkString("RemovePlayerFromSquad")
util.AddNetworkString("PromotePlayerInSquad")
util.AddNetworkString("SyncHunterSquads")

HunterSquads = HunterSquads or {}

local function SyncHunterSquads()
    net.Start("SyncHunterSquads")
    net.WriteTable(HunterSquads)
    net.Broadcast()
end

local function LoadHunterSquads()
    if not sql.TableExists("hunter_squads") then
        sql.Query("CREATE TABLE hunter_squads (squadID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, leader TEXT)")
    end
    if not sql.TableExists("hunter_squad_members") then
        sql.Query("CREATE TABLE hunter_squad_members (squadID INTEGER, steamID TEXT, rank TEXT)")
    end

    local squads = sql.Query("SELECT * FROM hunter_squads")
    if squads then
        for _, squad in ipairs(squads) do
            HunterSquads[tonumber(squad.squadID)] = { name = squad.name, leader = squad.leader, members = {} }
        end
    end

    local members = sql.Query("SELECT * FROM hunter_squad_members")
    if members then
        for _, member in ipairs(members) do
            if HunterSquads[tonumber(member.squadID)] then
                table.insert(HunterSquads[tonumber(member.squadID)].members, { steamID = member.steamID, rank = member.rank })
            end
        end
    end
end

local function SaveHunterSquad(squadID)
    local squad = HunterSquads[squadID]
    if not squad then return end

    local nameEscaped = sql.SQLStr(squad.name)
    local leaderEscaped = sql.SQLStr(squad.leader)
    sql.Query(string.format("REPLACE INTO hunter_squads (squadID, name, leader) VALUES (%d, %s, %s)", squadID, nameEscaped, leaderEscaped))

    sql.Query(string.format("DELETE FROM hunter_squad_members WHERE squadID = %d", squadID))
    for _, member in ipairs(squad.members) do
        local steamIDEscaped = sql.SQLStr(member.steamID)
        local rankEscaped = sql.SQLStr(member.rank)
        sql.Query(string.format("INSERT INTO hunter_squad_members (squadID, steamID, rank) VALUES (%d, %s, %s)", squadID, steamIDEscaped, rankEscaped))
    end
end

local function CreateHunterSquad(ply, name)
    for _, squad in pairs(HunterSquads) do
        if squad.leader == ply:SteamID() then
            ply:ChatPrint("You already lead a squad.")
            return
        end
    end

    if ply:getDarkRPVar("money") < 10000 then
        ply:ChatPrint("You need 10k money to create a squad.")
        return
    end

    ply:addMoney(-10000)

    local squadID = tonumber(sql.QueryValue("SELECT MAX(squadID) FROM hunter_squads") or 0)
    squadID = squadID or 0
    squadID = squadID + 1

    HunterSquads[squadID] = { name = name, leader = ply:SteamID(), members = { { steamID = ply:SteamID(), rank = "Leader" } } }
    SaveHunterSquad(squadID)

    ply:ChatPrint("You have created a new squad: " .. name)
    SyncHunterSquads()
end

local function JoinHunterSquad(ply, squadID)
    for _, squad in pairs(HunterSquads) do
        for _, member in ipairs(squad.members) do
            if member.steamID == ply:SteamID() then
                ply:ChatPrint("You are already in a squad.")
                return
            end
        end
    end

    local squad = HunterSquads[tonumber(squadID)]
    if not squad then return end

    table.insert(squad.members, { steamID = ply:SteamID(), rank = "Member" })
    SaveHunterSquad(squadID)

    ply:ChatPrint("You have joined the squad: " .. squad.name)
    SyncHunterSquads()
end

local function LeaveHunterSquad(ply, squadID)
    local squad = HunterSquads[tonumber(squadID)]
    if not squad then return end

    for i, member in ipairs(squad.members) do
        if member.steamID == ply:SteamID() then
            table.remove(squad.members, i)
            break
        end
    end

    if #squad.members == 0 then
        sql.Query(string.format("DELETE FROM hunter_squads WHERE squadID = %d", squadID))
        sql.Query(string.format("DELETE FROM hunter_squad_members WHERE squadID = %d", squadID))
        HunterSquads[squadID] = nil
    else
        SaveHunterSquad(squadID)
    end

    ply:ChatPrint("You have left the squad: " .. squad.name)
    SyncHunterSquads()
end

local function InvitePlayerToSquad(ply, squadID, steamID)
    local squad = HunterSquads[tonumber(squadID)]
    if not squad then return end
    local member = table.KeyFromValue(squad.members, ply:SteamID(), "steamID")
    if not member or (squad.leader ~= ply:SteamID() and squad.members[member].rank ~= "Leader" and squad.members[member].rank ~= "Officer") then
        ply:ChatPrint("You do not have permission to invite players.")
        return
    end

    for _, squad in pairs(HunterSquads) do
        for _, member in ipairs(squad.members) do
            if member.steamID == steamID then
                ply:ChatPrint("This player is already in a squad.")
                return
            end
        end
    end

    table.insert(squad.members, { steamID = steamID, rank = "Member" })
    SaveHunterSquad(squadID)

    ply:ChatPrint("You have invited " .. steamID .. " to the squad: " .. squad.name)
    SyncHunterSquads()
end

local function RemovePlayerFromSquad(ply, squadID, steamID)
    local squad = HunterSquads[tonumber(squadID)]
    if not squad then return end
    local member = table.KeyFromValue(squad.members, ply:SteamID(), "steamID")
    if not member or (squad.leader ~= ply:SteamID() and squad.members[member].rank ~= "Leader" and squad.members[member].rank ~= "Officer") then
        ply:ChatPrint("You do not have permission to remove players.")
        return
    end

    for i, member in ipairs(squad.members) do
        if member.steamID == steamID then
            table.remove(squad.members, i)
            break
        end
    end

    SaveHunterSquad(squadID)
    ply:ChatPrint("You have removed " .. steamID .. " from the squad: " .. squad.name)
    SyncHunterSquads()
end

local function PromotePlayerInSquad(ply, squadID, steamID, rank)
    local squad = HunterSquads[tonumber(squadID)]
    if not squad then return end
    local member = table.KeyFromValue(squad.members, ply:SteamID(), "steamID")
    if not member or (squad.leader ~= ply:SteamID() and squad.members[member].rank ~= "Leader") then
        ply:ChatPrint("You do not have permission to promote players.")
        return
    end

    for i, member in ipairs(squad.members) do
        if member.steamID == steamID then
            squad.members[i].rank = rank
            break
        end
    end

    SaveHunterSquad(squadID)
    ply:ChatPrint("You have promoted " .. steamID .. " to " .. rank .. " in the squad: " .. squad.name)
    SyncHunterSquads()
end

net.Receive("CreateHunterSquad", function(len, ply)
    local name = net.ReadString()
    CreateHunterSquad(ply, name)
end)

net.Receive("JoinHunterSquad", function(len, ply)
    local squadID = net.ReadInt(32)
    JoinHunterSquad(ply, squadID)
end)

net.Receive("LeaveHunterSquad", function(len, ply)
    local squadID = net.ReadInt(32)
    LeaveHunterSquad(ply, squadID)
end)

net.Receive("InvitePlayerToSquad", function(len, ply)
    local squadID = net.ReadInt(32)
    local steamID = net.ReadString()
    InvitePlayerToSquad(ply, squadID, steamID)
end)

net.Receive("RemovePlayerFromSquad", function(len, ply)
    local squadID = net.ReadInt(32)
    local steamID = net.ReadString()
    RemovePlayerFromSquad(ply, squadID, steamID)
end)

net.Receive("PromotePlayerInSquad", function(len, ply)
    local squadID = net.ReadInt(32)
    local steamID = net.ReadString()
    local rank = net.ReadString()
    PromotePlayerInSquad(ply, squadID, steamID, rank)
end)

hook.Add("PlayerInitialSpawn", "SyncHunterSquads", function(ply)
    net.Start("SyncHunterSquads")
    net.WriteTable(HunterSquads)
    net.Send(ply)
end)

hook.Add("PlayerSay", "OpenHunterSquadsMenuCommand", function(ply, text)
    if string.lower(text) == "!hsquad" then
        ply:ConCommand("open_hunter_squads_menu")
        return ""
    end
end)

LoadHunterSquads()
