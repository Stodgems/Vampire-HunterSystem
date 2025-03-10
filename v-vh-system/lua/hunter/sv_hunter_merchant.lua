-- Hunter Merchant Purchase Logic

util.AddNetworkString("OpenHunterMerchantMenu")
util.AddNetworkString("BuyHunterWeapon")
util.AddNetworkString("SyncHunterMerchantItems")

HunterMerchantItems = HunterMerchantItems or {}

local function LoadHunterMerchantItems()
    if not sql.TableExists("hunter_merchant_items") then
        sql.Query("CREATE TABLE hunter_merchant_items (class TEXT, cost INTEGER)")
    end

    local result = sql.Query("SELECT * FROM hunter_merchant_items")
    if result then
        for _, row in ipairs(result) do
            table.insert(HunterMerchantItems, {class = row.class, cost = tonumber(row.cost)})
        end
    end

    -- Ensure weapon_hunter_sword is always available
    local swordExists = false
    for _, item in ipairs(HunterMerchantItems) do
        if item.class == "weapon_hunter_sword" then
            swordExists = true
            break
        end
    end
    if not swordExists then
        table.insert(HunterMerchantItems, {class = "weapon_hunter_sword", cost = 5})
    end
end

LoadHunterMerchantItems()

local function SaveHunterWeapons(ply)
    local weapons = table.concat(ply.hunterWeapons, ",")
    sql.Query(string.format("UPDATE hunter_data SET weapons = '%s' WHERE steamID = '%s'", weapons, ply:SteamID()))
end

local function LoadHunterWeapons(ply)
    local result = sql.QueryRow(string.format("SELECT weapons FROM hunter_data WHERE steamID = '%s'", ply:SteamID()))
    if result and result.weapons then
        ply.hunterWeapons = string.Explode(",", result.weapons)
    else
        ply.hunterWeapons = {}
    end
end

net.Receive("BuyHunterWeapon", function(len, ply)
    local weaponClass = net.ReadString()
    local cost = net.ReadInt(32)

    if not IsHunter(ply) then return end

    local hunter = hunters[ply:SteamID()]
    if hunter.hearts < cost then
        ply:ChatPrint("You do not have enough vampire hearts.")
        return
    end

    hunter.hearts = hunter.hearts - cost
    ply:Give(weaponClass)
    ply:ChatPrint("You have purchased " .. weaponClass .. " for " .. cost .. " vampire hearts.")
    
    if not ply.hunterWeapons then
        ply.hunterWeapons = {}
    end
    table.insert(ply.hunterWeapons, weaponClass)
    SaveHunterWeapons(ply)
    SaveHunterData()
    SyncHunterData()
    UpdateHunterHUD(ply)
end)

hook.Add("PlayerInitialSpawn", "SyncHunterMerchantItems", function(ply)
    net.Start("SyncHunterMerchantItems")
    net.WriteTable(HunterMerchantItems)
    net.Send(ply)
end)

hook.Add("PlayerSpawn", "GiveHunterWeaponsOnSpawn", function(ply)
    if IsHunter(ply) then
        LoadHunterWeapons(ply)
        for _, weapon in ipairs(ply.hunterWeapons) do
            ply:Give(weapon)
        end
    end
end)
