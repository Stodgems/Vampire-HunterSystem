-- Hunter Merchant Purchase Logic

util.AddNetworkString("OpenHunterMerchantMenu")
util.AddNetworkString("BuyHunterWeapon")
util.AddNetworkString("SyncHunterMerchantItems")
util.AddNetworkString("SyncPurchasedItems")

HunterMerchantItems = {}
PurchasedItems = {}

local function LoadHunterMerchantItems()
    HunterMerchantItems = {} -- Clear the table to prevent duplicates

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
        sql.Query("INSERT INTO hunter_merchant_items (class, cost) VALUES ('weapon_hunter_sword', 5)")
    end
end

local function LoadPurchasedItems()
    if not sql.TableExists("purchased_items") then
        sql.Query("CREATE TABLE purchased_items (steamID TEXT, class TEXT)")
    end

    local result = sql.Query("SELECT * FROM purchased_items")
    if result then
        for _, row in ipairs(result) do
            PurchasedItems[row.steamID] = PurchasedItems[row.steamID] or {}
            table.insert(PurchasedItems[row.steamID], row.class)
        end
    end
end

local function SavePurchasedItem(ply, class)
    local steamID = sql.SQLStr(ply:SteamID())
    local classEscaped = sql.SQLStr(class)
    sql.Query(string.format("INSERT INTO purchased_items (steamID, class) VALUES (%s, %s)", steamID, classEscaped))
end

LoadHunterMerchantItems()
LoadPurchasedItems()

function SaveHunterWeapons(ply)
    if not ply.hunterWeapons then
        ply.hunterWeapons = {}
    end
    local weapons = table.concat(ply.hunterWeapons, ",")
    weapons = weapons:gsub("^,", "") -- Remove leading comma if present
    local steamID = sql.SQLStr(ply:SteamID())
    local weaponsEscaped = sql.SQLStr(weapons)
    local query = string.format("UPDATE hunter_data SET weapons = %s WHERE steamID = %s", weaponsEscaped, steamID)
    sql.Query(query)
end

local function LoadHunterWeapons(ply)
    local steamID = sql.SQLStr(ply:SteamID())
    local result = sql.QueryRow(string.format("SELECT weapons FROM hunter_data WHERE steamID = %s", steamID))
    if result and result.weapons then
        ply.hunterWeapons = string.Explode(",", result.weapons)
    else
        ply.hunterWeapons = {}
    end
    hunters[ply:SteamID()].weapons = ply.hunterWeapons -- Ensure the hunter data is updated with the loaded weapons
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
    if not table.HasValue(ply.hunterWeapons, weaponClass) then
        table.insert(ply.hunterWeapons, weaponClass)
        SaveHunterWeapons(ply)
    end
    -- Ensure the hunter data is updated with the new weapons
    hunters[ply:SteamID()].weapons = ply.hunterWeapons
    SaveHunterData()
    SyncHunterData()
    UpdateHunterHUD(ply)

    -- Track purchased items
    PurchasedItems[ply:SteamID()] = PurchasedItems[ply:SteamID()] or {}
    table.insert(PurchasedItems[ply:SteamID()], weaponClass)
    SavePurchasedItem(ply, weaponClass)
    net.Start("SyncPurchasedItems")
    net.WriteTable(PurchasedItems[ply:SteamID()])
    net.Send(ply)
end)

hook.Add("PlayerInitialSpawn", "SyncHunterMerchantItems", function(ply)
    net.Start("SyncHunterMerchantItems")
    net.WriteTable(HunterMerchantItems)
    net.Send(ply)

    net.Start("SyncPurchasedItems")
    net.WriteTable(PurchasedItems[ply:SteamID()] or {})
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
