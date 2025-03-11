-- Admin Menu Logic

include("hunter/sv_hunter_merchant.lua")
include("hunter/sh_hunter_utils.lua") -- Ensure this file is included to access SaveHunterWeapons

util.AddNetworkString("OpenAdminMenu")
util.AddNetworkString("AdminMakeVampire")
util.AddNetworkString("AdminMakeHunter")
util.AddNetworkString("AdminAddBlood")
util.AddNetworkString("AdminAddExperience")
util.AddNetworkString("AdminAddMerchantItem")
util.AddNetworkString("AdminRemoveRole")
util.AddNetworkString("AdminAddHearts")
util.AddNetworkString("AdminAddMedallions")
util.AddNetworkString("SyncHunterMerchantItems")
util.AddNetworkString("RequestMerchantItems")
util.AddNetworkString("OpenMerchantItemsMenu")
util.AddNetworkString("EditMerchantItem")
util.AddNetworkString("RemoveMerchantItem")
util.AddNetworkString("RequestPlayerWeapons")
util.AddNetworkString("OpenPlayerWeaponsMenu")
util.AddNetworkString("AdminAddPlayerWeapon")
util.AddNetworkString("AdminRemovePlayerWeapon")

-- Function to check if a player is an admin
local function IsAdmin(ply)
    local isAdmin = GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
    return isAdmin
end

local function SaveHunterMerchantItems()
    sql.Query("DELETE FROM hunter_merchant_items")
    for _, item in ipairs(HunterMerchantItems) do
        sql.Query(string.format("INSERT INTO hunter_merchant_items (class, cost) VALUES ('%s', %d)", item.class, item.cost))
    end
end

net.Receive("AdminMakeVampire", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        if IsHunter(target) then
            RemoveHunter(target)
        end
        MakeVampire(target)
    end
end)

net.Receive("AdminMakeHunter", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        if IsVampire(target) then
            RemoveVampire(target)
        end
        MakeHunter(target)
    end
end)

net.Receive("AdminAddBlood", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local amount = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target and amount then
        AddBlood(target, amount)
    end
end)

net.Receive("AdminAddExperience", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local amount = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target and amount then
        AddExperience(target, amount)
    end
end)

net.Receive("AdminAddMerchantItem", function(len, ply)
    if not IsAdmin(ply) then return end
    local weaponClass = net.ReadString()
    local cost = net.ReadInt(32)
    table.insert(HunterMerchantItems, {class = weaponClass, cost = cost})
    ply:ChatPrint("Added " .. weaponClass .. " to the merchant for " .. cost .. " hearts.")
    SaveHunterMerchantItems()
    net.Start("SyncHunterMerchantItems")
    net.WriteTable(HunterMerchantItems)
    net.Broadcast()
end)

net.Receive("AdminRemoveRole", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        if IsHunter(target) then
            RemoveHunter(target)
            target:ChatPrint("You have been removed from the hunter system!")
        elseif IsVampire(target) then
            RemoveVampire(target)
            target:ChatPrint("You have been cured of vampirism!")
        else
            ply:ChatPrint("The player is neither a hunter nor a vampire.")
        end
    end
end)

net.Receive("AdminAddHearts", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local amount = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target and amount then
        if IsHunter(target) then
            local hunter = hunters[target:SteamID()]
            hunter.hearts = (hunter.hearts or 0) + amount
            ply:ChatPrint("Added " .. amount .. " hearts to " .. target:Nick())
            SaveHunterData()
            SyncHunterData()
            UpdateHunterHUD(target)
        else
            ply:ChatPrint("The player is not a hunter.")
        end
    end
end)

net.Receive("AdminAddMedallions", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local amount = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target and amount then
        if IsVampire(target) then
            local vampire = vampires[target:SteamID()]
            vampire.medallions = (vampire.medallions or 0) + amount
            ply:ChatPrint("Added " .. amount .. " medallions to " .. target:Nick())
            SaveVampireData()
            SyncVampireData()
            UpdateVampireHUD(target)
            net.Start("UpdateVampireHUD")
            net.WriteInt(vampire.medallions, 32)
            net.Send(target)
        else
            ply:ChatPrint("The player is not a vampire.")
        end
    end
end)

net.Receive("RequestMerchantItems", function(len, ply)
    if not IsAdmin(ply) then return end
    net.Start("OpenMerchantItemsMenu")
    net.WriteTable(HunterMerchantItems)
    net.Send(ply)
end)

net.Receive("EditMerchantItem", function(len, ply)
    if not IsAdmin(ply) then return end
    local weaponClass = net.ReadString()
    local cost = net.ReadInt(32)
    for _, item in ipairs(HunterMerchantItems) do
        if item.class == weaponClass then
            item.cost = cost
            break
        end
    end
    SaveHunterMerchantItems()
    net.Start("SyncHunterMerchantItems")
    net.WriteTable(HunterMerchantItems)
    net.Broadcast()
end)

net.Receive("RemoveMerchantItem", function(len, ply)
    if not IsAdmin(ply) then return end
    local weaponClass = net.ReadString()
    for i, item in ipairs(HunterMerchantItems) do
        if item.class == weaponClass then
            table.remove(HunterMerchantItems, i)
            break
        end
    end
    SaveHunterMerchantItems()
    net.Start("SyncHunterMerchantItems")
    net.WriteTable(HunterMerchantItems)
    net.Broadcast()
end)

net.Receive("RequestPlayerWeapons", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        local weapons = target.hunterWeapons or {}
        net.Start("OpenPlayerWeaponsMenu")
        net.WriteTable(weapons)
        net.WriteString(targetSteamID)
        net.Send(ply)
    end
end)

net.Receive("AdminAddPlayerWeapon", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local weaponClass = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        if not target.hunterWeapons then
            target.hunterWeapons = {}
        end
        if not table.HasValue(target.hunterWeapons, weaponClass) then
            table.insert(target.hunterWeapons, weaponClass)
            SaveHunterWeapons(target)
            target:ChatPrint("You have been given the weapon: " .. weaponClass)
        end
    end
end)

net.Receive("AdminRemovePlayerWeapon", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local weaponClass = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        if target.hunterWeapons and table.HasValue(target.hunterWeapons, weaponClass) then
            table.RemoveByValue(target.hunterWeapons, weaponClass)
            SaveHunterWeapons(target)
            target:StripWeapon(weaponClass)
            target:ChatPrint("The weapon " .. weaponClass .. " has been removed from you.")
        end
    end
end)

hook.Add("PlayerSay", "OpenAdminMenuCommand", function(ply, text)
    if string.lower(text) == "!vhadmin" then
        if IsAdmin(ply) then
            net.Start("OpenAdminMenu")
            net.Send(ply)
            return ""
        else
            ply:ChatPrint("You are not an admin.")
        end
    end
end)
