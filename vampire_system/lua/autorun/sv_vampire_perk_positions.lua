-- Server-side handling of Vampire Perk Positions

if SERVER then
    util.AddNetworkString("SaveVampirePerkPositions")
    util.AddNetworkString("LoadVampirePerkPositions")
    util.AddNetworkString("RequestVampirePerkPositions")
    util.AddNetworkString("LoadVampirePerkAdminPositions")
    util.AddNetworkString("RequestVampirePerkAdminPositions")
    util.AddNetworkString("SaveActivePerks")
    util.AddNetworkString("LoadActivePerks")

    local perkPositions = {}
    local activePerks = {}

    local function LoadPerkPositions()
        local result = sql.Query("SELECT * FROM vampire_perk_positions")
        if result then
            for _, row in ipairs(result) do
                perkPositions[row.perkName] = { x = tonumber(row.x), y = tonumber(row.y) }
            end
        end
    end

    local function SavePerkPositions()
        sql.Query("DELETE FROM vampire_perk_positions")
        for perkName, pos in pairs(perkPositions) do
            sql.Query(string.format("INSERT INTO vampire_perk_positions (perkName, x, y) VALUES ('%s', %d, %d)", perkName, pos.x, pos.y))
        end
    end

    local function LoadActivePerks()
        local result = sql.Query("SELECT * FROM vampire_active_perks")
        if result then
            for _, row in ipairs(result) do
                activePerks[row.perkName] = true
            end
        end
    end

    local function SaveActivePerks()
        sql.Query("DELETE FROM vampire_active_perks")
        for perkName, _ in pairs(activePerks) do
            sql.Query(string.format("INSERT INTO vampire_active_perks (perkName) VALUES ('%s')", perkName))
        end
    end

    -- Ensure the tables exist
    if not sql.TableExists("vampire_perk_positions") then
        sql.Query("CREATE TABLE vampire_perk_positions (perkName TEXT, x INTEGER, y INTEGER)")
    end

    if not sql.TableExists("vampire_active_perks") then
        sql.Query("CREATE TABLE vampire_active_perks (perkName TEXT)")
    end

    net.Receive("SaveVampirePerkPositions", function(len, ply)
        if not ply:IsAdmin() then return end
        perkPositions = net.ReadTable()
        SavePerkPositions()
    end)

    net.Receive("RequestVampirePerkPositions", function(len, ply)
        net.Start("LoadVampirePerkPositions")
        net.WriteTable(perkPositions)
        net.WriteTable(activePerks)
        net.Send(ply)
    end)

    net.Receive("RequestVampirePerkAdminPositions", function(len, ply)
        if ply:IsAdmin() then
            net.Start("LoadVampirePerkAdminPositions")
            net.WriteTable(perkPositions)
            net.WriteTable(activePerks)
            net.Send(ply)
        end
    end)

    net.Receive("SaveActivePerks", function(len, ply)
        if not ply:IsAdmin() then return end
        activePerks = net.ReadTable()
        SaveActivePerks()
    end)

    hook.Add("Initialize", "LoadVampirePerkPositions", LoadPerkPositions)
    hook.Add("Initialize", "LoadActivePerks", LoadActivePerks)
end
