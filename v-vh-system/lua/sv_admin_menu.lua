

include("hunter/sv_hunter_merchant.lua")
include("hunter/sh_hunter_utils.lua")
include("vampire/sv_vampire_abilities.lua")
include("vampire/sh_vampire_utils.lua")
include("werewolf/sh_werewolf_utils.lua")
include("hybrid/sh_hybrid_utils.lua")
include("hybrid/sv_hybrid_orders.lua")

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
util.AddNetworkString("RequestVampireAbilities")
util.AddNetworkString("OpenVampireAbilitiesMenu")
util.AddNetworkString("EditVampireAbility")
util.AddNetworkString("RemoveVampireAbility")
util.AddNetworkString("RequestGuildMembers")
util.AddNetworkString("ReceiveGuildMembers")

util.AddNetworkString("AdminMakeWerewolf")
util.AddNetworkString("AdminRemoveWerewolf")
util.AddNetworkString("AdminAddRage")
util.AddNetworkString("AdminAddMoonEssence")
util.AddNetworkString("AdminStartWerewolfTransform")
util.AddNetworkString("AdminEndWerewolfTransform")
util.AddNetworkString("RequestWerewolfPacksMenu")

util.AddNetworkString("AdminMakeHybrid")
util.AddNetworkString("AdminRemoveHybrid")
util.AddNetworkString("AdminAddHybridBlood")
util.AddNetworkString("AdminAddHybridRage")
util.AddNetworkString("AdminSetHybridBalance")
util.AddNetworkString("AdminForceHybridTransform")

util.AddNetworkString("AdminAssignWerewolfToPack")
util.AddNetworkString("AdminRemoveFromWerewolfPack")

util.AddNetworkString("AdminAssignHybridToOrder")
util.AddNetworkString("AdminRemoveHybridFromOrder")
util.AddNetworkString("PromoteHybridOrderMember")
util.AddNetworkString("DemoteHybridOrderMember")

local function IsAdmin(ply)
    local isAdmin = GlobalConfig.AdminUserGroups[ply:GetUserGroup()] or false
    return isAdmin
end

local function SaveHunterMerchantItems()
    sql.Query("DELETE FROM hunter_merchant_items")
    for _, item in ipairs(HunterMerchantItems) do
        local classEscaped = sql.SQLStr(item.class)
        local cost = tonumber(item.cost)
        sql.Query(string.format("INSERT INTO hunter_merchant_items (class, cost) VALUES (%s, %d)", classEscaped, cost))
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

net.Receive("RequestVampireAbilities", function(len, ply)
    if not IsAdmin(ply) then return end
    net.Start("OpenVampireAbilitiesMenu")
    net.WriteTable(VampireAbilities)
    net.Send(ply)
end)

net.Receive("EditVampireAbility", function(len, ply)
    if not IsAdmin(ply) then return end
    local abilityClass = net.ReadString()
    local cost = net.ReadInt(32)
    for _, ability in ipairs(VampireAbilities) do
        if ability.class == abilityClass then
            ability.cost = cost
            break
        end
    end
    SaveVampireAbilities()
    net.Start("SyncVampireAbilities")
    net.WriteTable(VampireAbilities)
    net.Broadcast()
end)

net.Receive("RemoveVampireAbility", function(len, ply)
    if not IsAdmin(ply) then return end
    local abilityClass = net.ReadString()
    for i, ability in ipairs(VampireAbilities) do
        if ability.class == abilityClass then
            table.remove(VampireAbilities, i)
            break
        end
    end
    SaveVampireAbilities()
    net.Start("SyncVampireAbilities")
    net.WriteTable(VampireAbilities)
    net.Broadcast()
end)

net.Receive("RequestGuildMembers", function(len, ply)
    local guildName = net.ReadString()
    local guildMembers = {}

    local result = sql.Query("SELECT steamID, guildRank FROM hunter_data WHERE guild = " .. sql.SQLStr(guildName))
    if result then
        for _, row in ipairs(result) do
            local member = player.GetBySteamID(row.steamID)
            if member then
                table.insert(guildMembers, {name = member:Nick(), rank = row.guildRank})
            end
        end
    end

    net.Start("ReceiveGuildMembers")
    net.WriteTable(guildMembers)
    net.Send(ply)
end)


net.Receive("AdminMakeWerewolf", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        MakeWerewolf(target)
    end
end)

net.Receive("AdminRemoveWerewolf", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target and IsWerewolf(target) then
        RemoveWerewolf(target)
    end
end)

net.Receive("AdminAddRage", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local amount = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target then
        AddRage(target, amount)
    end
end)

net.Receive("AdminAddMoonEssence", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local amount = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target then
        AddMoonEssence(target, amount)
    end
end)

net.Receive("AdminStartWerewolfTransform", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        StartTransformation(target)
    end
end)

net.Receive("AdminEndWerewolfTransform", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        EndTransformation(target)
    end
end)

net.Receive("RequestWerewolfPacksMenu", function(len, ply)
    if not IsAdmin(ply) then return end
    net.Start("OpenWerewolfPacksMenu")
    net.Send(ply)
end)

net.Receive("AdminAssignWerewolfToPack", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local packName = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target and IsWerewolf(target) and WerewolfPacksConfig and WerewolfPacksConfig[packName] then
        JoinPack(target, packName)
    end
end)

net.Receive("AdminRemoveFromWerewolfPack", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target and IsWerewolf(target) then
        LeavePack(target)
    end
end)


net.Receive("AdminMakeHybrid", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target then
        MakeHybrid(target)
    end
end)

net.Receive("AdminRemoveHybrid", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target and IsHybrid(target) then
        RemoveHybrid(target)
    end
end)

net.Receive("AdminAddHybridBlood", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local amount = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target then
        AddBloodToHybrid(target, amount)
    end
end)

net.Receive("AdminAddHybridRage", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local amount = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target then
        AddRageToHybrid(target, amount)
    end
end)

net.Receive("AdminSetHybridBalance", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local balance = net.ReadInt(32)
    local target = player.GetBySteamID(targetSteamID)
    if target and IsHybrid(target) and balance and balance >= -100 and balance <= 100 then
        local hybrid = hybrids[target:SteamID()]
        hybrid.balance = balance
        UpdateHybridStats(target)
        SaveHybridData()
        SyncHybridData()
    end
end)

net.Receive("AdminForceHybridTransform", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local formKey = net.ReadString() 
    local target = player.GetBySteamID(targetSteamID)
    if target and IsHybrid(target) then
        local hybrid = hybrids[target:SteamID()]
        if hybrid.transformed then
            EndHybridTransformation(target)
        else
            hybrid.lastTransform = 0
            StartHybridTransformation(target, formKey)
        end
    end
end)


net.Receive("AdminAssignHybridToOrder", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local orderName = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target and IsHybrid(target) and HybridOrdersConfig and HybridOrdersConfig[orderName] then
        AssignHybridToOrder(target, orderName)
    end
end)

net.Receive("AdminRemoveHybridFromOrder", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target and IsHybrid(target) then
        RemoveHybridFromOrder(target)
    end
end)

net.Receive("PromoteHybridOrderMember", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target and IsHybrid(target) then
        PromoteHybridOrderRank(target)
    end
end)

net.Receive("DemoteHybridOrderMember", function(len, ply)
    if not IsAdmin(ply) then return end
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    if target and IsHybrid(target) then
        DemoteHybridOrderRank(target)
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
