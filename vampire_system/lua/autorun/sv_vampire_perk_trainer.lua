-- Vampire Perk Trainer Server-Side

if SERVER then
    include("vampire_perk_config.lua")
    include("vampire_utils.lua")

    util.AddNetworkString("OpenVampirePerkMenu")
    util.AddNetworkString("BuyVampirePerk")
    util.AddNetworkString("UpdateVampirePerks")

    net.Receive("BuyVampirePerk", function(len, ply)
        local perkName = net.ReadString()
        local perk = VampirePerkConfig.Perks[perkName]

        if perk and IsVampire(ply) and vampires[ply:SteamID()].blood >= perk.cost then
            if perk.requires and not HasVampirePerk(ply, perk.requires) then
                ply:ChatPrint("You need to unlock the previous perk first.")
                return
            end

            vampires[ply:SteamID()].blood = vampires[ply:SteamID()].blood - perk.cost
            perk.func(ply)
            ply:ChatPrint("You have purchased the " .. perkName .. " perk!")
            AddVampirePerk(ply, perkName)
            SaveVampireData()
            UpdateVampireHUD(ply)
        else
            ply:ChatPrint("You do not have enough blood to purchase this perk.")
        end
    end)

    -- Function to check if a player has a specific perk
    function HasVampirePerk(ply, perkName)
        local vampire = vampires[ply:SteamID()]
        return vampire and vampire.perks and vampire.perks[perkName] or false
    end

    -- Function to add a perk to a player
    function AddVampirePerk(ply, perkName)
        local vampire = vampires[ply:SteamID()]
        if not vampire then return end
        vampire.perks = vampire.perks or {}
        vampire.perks[perkName] = true
        net.Start("UpdateVampirePerks")
        net.WriteTable(vampire.perks)
        net.Send(ply)
    end

    -- Ensure the user perk trainer menu is opened when interacting with the perk trainer entity
    hook.Add("PlayerUse", "OpenVampirePerkMenuOnUse", function(ply, ent)
        if ent:GetClass() == "npc_vampire_perk_trainer" then
            net.Start("OpenVampirePerkMenu")
            net.Send(ply)
        end
    end)

    -- Function to reset a player's perks when they are cured of vampirism
    function ResetVampirePerks(ply)
        local vampire = vampires[ply:SteamID()]
        if not vampire then return end
        vampire.perks = {}
        net.Start("UpdateVampirePerks")
        net.WriteTable(vampire.perks)
        net.Send(ply)
    end
end
