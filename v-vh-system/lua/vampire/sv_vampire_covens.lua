-- Vampire Covens Server Logic

include("vampire/sh_vampire_covens_config.lua") -- Include the Vampire Covens config
include("vampire/sh_vampire_covens.lua") -- Ensure the shared coven logic is included

util.AddNetworkString("OpenVampireCovensMenu")
util.AddNetworkString("JoinVampireCoven")
util.AddNetworkString("LeaveVampireCoven")
util.AddNetworkString("PromoteCovenRank")
util.AddNetworkString("DemoteCovenRank")
util.AddNetworkString("RequestCovenMembers")
util.AddNetworkString("ReceiveCovenMembers")
util.AddNetworkString("KickCovenMember")
util.AddNetworkString("SyncVampireCoven")

local function IsAdmin(ply)
    return GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
end

local function UpdateCovenHUD(ply, covenName)
    net.Start("SyncVampireCoven")
    net.WriteString(covenName or "None")
    net.Send(ply)
end

hook.Add("Initialize", "EnsureVampireDataTable", function()
    if not sql.TableExists("vampire_data") then
        sql.Query("CREATE TABLE vampire_data (steamID TEXT PRIMARY KEY, blood INTEGER, tier TEXT, medallions INTEGER, coven TEXT, covenRank TEXT)")
    elseif not sql.Query("PRAGMA table_info(vampire_data) WHERE name = 'coven'") then
        sql.Query("ALTER TABLE vampire_data ADD COLUMN coven TEXT")
        sql.Query("ALTER TABLE vampire_data ADD COLUMN covenRank TEXT")
    end
end)

function JoinCoven(ply, covenName)
    -- ...existing code...
    UpdateCovenHUD(ply, covenName) -- Update HUD
end

function LeaveCoven(ply)
    -- ...existing code...
    UpdateCovenHUD(ply, nil) -- Update HUD
end

net.Receive("JoinVampireCoven", function(len, ply)
    local covenName = net.ReadString()
    JoinCoven(ply, covenName)
end)

net.Receive("LeaveVampireCoven", function(len, ply)
    LeaveCoven(ply)
end)

net.Receive("PromoteCovenRank", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)

    if target then
        if IsAdmin(ply) then
            PromoteCovenRank(ply, target, true) -- Allow admin to promote
        else
            PromoteCovenRank(ply, target, false)
        end
    end
end)

net.Receive("DemoteCovenRank", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)

    if target then
        if IsAdmin(ply) then
            DemoteCovenRank(ply, target, true) -- Allow admin to demote
        else
            DemoteCovenRank(ply, target, false)
        end
    end
end)

net.Receive("RequestCovenMembers", function(len, ply)
    local covenName = net.ReadString()
    local covenMembers = {}

    -- Fetch members from the database
    local result = sql.Query("SELECT steamID, covenRank FROM vampire_data WHERE coven = " .. sql.SQLStr(covenName))
    if result then
        for _, row in ipairs(result) do
            local member = player.GetBySteamID(row.steamID)
            if member then
                table.insert(covenMembers, {name = member:Nick(), rank = row.covenRank})
            end
        end
    end

    net.Start("ReceiveCovenMembers")
    net.WriteTable(covenMembers)
    net.Send(ply)
end)

net.Receive("KickCovenMember", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        local coven = VampireCovensConfig[ply.vampireCoven]
        local playerRank = ply.vampireCovenRank
        local playerIndex = table.KeyFromValue(coven.ranks, playerRank)
        if IsAdmin(ply) or (playerIndex and playerIndex >= 4) then
            LeaveCoven(target)
            if ply.vampireCoven then
                target:ChatPrint("You have been kicked from the " .. ply.vampireCoven .. " coven.")
            else
                target:ChatPrint("You have been kicked from the coven.")
            end

            -- Reset coven data in the database
            vampires[target:SteamID()].coven = nil
            vampires[target:SteamID()].covenRank = nil
            SaveVampireData()
        end
    end
end)

hook.Add("PlayerSay", "OpenVampireCovensMenuCommand", function(ply, text)
    if string.lower(text) == "!vcoven" then
        if not IsVampire(ply) then
            ply:ChatPrint("Only vampires can access the coven menu.")
            return ""
        end
        net.Start("OpenVampireCovensMenu")
        net.Send(ply) -- Send the net message to open the coven menu
        return ""
    end
end)
