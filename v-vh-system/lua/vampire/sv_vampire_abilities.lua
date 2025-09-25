

util.AddNetworkString("OpenVampireAbilitiesMenu")
util.AddNetworkString("BuyVampireAbility")
util.AddNetworkString("SyncVampireAbilities")
util.AddNetworkString("SyncPurchasedAbilities")

VampireAbilities = {}
PurchasedAbilities = {}

local function LoadVampireAbilities()
    VampireAbilities = {}

    if not sql.TableExists("vampire_abilities") then
        sql.Query("CREATE TABLE vampire_abilities (class TEXT, cost INTEGER)")
    end

    local result = sql.Query("SELECT * FROM vampire_abilities")
    if result then
        for _, row in ipairs(result) do
            table.insert(VampireAbilities, {class = row.class, cost = tonumber(row.cost)})
        end
    end

    local clawsExists = false
    for _, ability in ipairs(VampireAbilities) do
        if ability.class == "weapon_vampire_claws_leap" then
            clawsExists = true
            break
        end
    end
    if not clawsExists then
        table.insert(VampireAbilities, {class = "weapon_vampire_claws_leap", cost = 5})
        sql.Query("INSERT INTO vampire_abilities (class, cost) VALUES ('weapon_vampire_claws_leap', 5)")
    end
end

local function LoadPurchasedAbilities()
    if not sql.TableExists("purchased_abilities") then
        sql.Query("CREATE TABLE purchased_abilities (steamID TEXT, class TEXT)")
    end

    local result = sql.Query("SELECT * FROM purchased_abilities")
    if result then
        for _, row in ipairs(result) do
            PurchasedAbilities[row.steamID] = PurchasedAbilities[row.steamID] or {}
            table.insert(PurchasedAbilities[row.steamID], row.class)
        end
    end
end

local function SavePurchasedAbility(ply, class)
    local steamID = sql.SQLStr(ply:SteamID())
    local classEscaped = sql.SQLStr(class)
    sql.Query(string.format("INSERT INTO purchased_abilities (steamID, class) VALUES (%s, %s)", steamID, classEscaped))
end

LoadVampireAbilities()
LoadPurchasedAbilities()

local function LoadPlayerVampireAbilities(ply)
    local steamID = ply:SteamID()
    ply.vampireAbilities = table.Copy(PurchasedAbilities[steamID] or {})
    vampires[steamID] = vampires[steamID] or {}
    vampires[steamID].abilities = ply.vampireAbilities
end

net.Receive("BuyVampireAbility", function(len, ply)
    local abilityClass = net.ReadString()
    local cost = net.ReadInt(32)

    if not IsVampire(ply) then return end

    local vampire = vampires[ply:SteamID()]
    if vampire.medallions < cost then
        ply:ChatPrint("You do not have enough medallions.")
        return
    end

    vampire.medallions = vampire.medallions - cost
    ply:Give(abilityClass)
    ply:ChatPrint("You have purchased " .. abilityClass .. " for " .. cost .. " medallions.")
    
    if not ply.vampireAbilities then
        ply.vampireAbilities = {}
    end
    if not table.HasValue(ply.vampireAbilities, abilityClass) then
        table.insert(ply.vampireAbilities, abilityClass)
    end

    vampires[ply:SteamID()].abilities = ply.vampireAbilities
    SaveVampireData()
    SyncVampireData()
    UpdateVampireHUD(ply)

    
    PurchasedAbilities[ply:SteamID()] = PurchasedAbilities[ply:SteamID()] or {}
    table.insert(PurchasedAbilities[ply:SteamID()], abilityClass)
    SavePurchasedAbility(ply, abilityClass)
    net.Start("SyncPurchasedAbilities")
    net.WriteTable(PurchasedAbilities[ply:SteamID()])
    net.Send(ply)
end)

hook.Add("PlayerInitialSpawn", "SyncVampireAbilities", function(ply)
    net.Start("SyncVampireAbilities")
    net.WriteTable(VampireAbilities)
    net.Send(ply)

    net.Start("SyncPurchasedAbilities")
    net.WriteTable(PurchasedAbilities[ply:SteamID()] or {})
    net.Send(ply)
end)

hook.Add("PlayerSpawn", "GiveVampireAbilitiesOnSpawn", function(ply)
    if IsVampire(ply) then
        LoadPlayerVampireAbilities(ply)
        for _, ability in ipairs(ply.vampireAbilities) do
            ply:Give(ability)
        end
    end
end)
