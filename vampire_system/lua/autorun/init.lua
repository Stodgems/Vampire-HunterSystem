-- Initialize the Vampire System addon
AddCSLuaFile("vampire_config.lua")
AddCSLuaFile("vampire_system.lua")
AddCSLuaFile("vampire_commands.lua")
AddCSLuaFile("vampire_utils.lua")
AddCSLuaFile("vampire_perk_config.lua")
AddCSLuaFile("weapons/weapon_vampire.lua")
AddCSLuaFile("cl_vampire_hud.lua")
AddCSLuaFile("cl_vampire_perk_menu.lua")
AddCSLuaFile("cl_vampire_perk_admin.lua")
AddCSLuaFile("entities/ent_vampire_blood.lua")
AddCSLuaFile("entities/ent_vampire_blood_small.lua")
AddCSLuaFile("entities/ent_vampire_blood_medium.lua")
AddCSLuaFile("entities/ent_vampire_blood_large.lua")
AddCSLuaFile("entities/ent_vampire_cure.lua")
AddCSLuaFile("libs/imgui.lua")

include("vampire_config.lua")
include("vampire_system.lua")
include("vampire_commands.lua")
include("vampire_utils.lua")
include("vampire_perk_config.lua")

if CLIENT then
    include("cl_vampire_hud.lua")
    include("cl_vampire_perk_menu.lua")
    include("cl_vampire_perk_admin.lua")
end

if SERVER then
    include("sv_vampire_perk_positions.lua")
    util.AddNetworkString("UpdateVampireHUD")
    util.AddNetworkString("SyncVampireData")
    util.AddNetworkString("OpenVampirePerkMenu")
    util.AddNetworkString("BuyVampirePerk")
    util.AddNetworkString("UpdateVampirePerks")
end

scripted_ents.Register({
    Type = "anim",
    Base = "base_gmodentity",
    PrintName = "Small Vampire Blood",
    Author = "Your Name",
    Spawnable = true,
    AdminSpawnable = true,
    Initialize = function(self)
        self:SetModel("models/props_junk/PopCan01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
        end
    end,
    Use = function(self, activator, caller)
        if activator:IsPlayer() then
            AddBlood(activator, 2500) -- Give 50 blood
            self:Remove()
        end
    end
}, "ent_vampire_blood_small")

scripted_ents.Register({
    Type = "anim",
    Base = "base_gmodentity",
    PrintName = "Medium Vampire Blood",
    Author = "Your Name",
    Spawnable = true,
    AdminSpawnable = true,
    Initialize = function(self)
        self:SetModel("models/props_junk/PopCan01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
        end
    end,
    Use = function(self, activator, caller)
        if activator:IsPlayer() then
            AddBlood(activator, 5000) -- Give 100 blood
            self:Remove()
        end
    end
}, "ent_vampire_blood_medium")

scripted_ents.Register({
    Type = "anim",
    Base = "base_gmodentity",
    PrintName = "Large Vampire Blood",
    Author = "Your Name",
    Spawnable = true,
    AdminSpawnable = true,
    Initialize = function(self)
        self:SetModel("models/props_junk/PopCan01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
        end
    end,
    Use = function(self, activator, caller)
        if activator:IsPlayer() then
            AddBlood(activator, 10000) -- Give 200 blood
            self:Remove()
        end
    end
}, "ent_vampire_blood_large")

scripted_ents.Register({
    Type = "anim",
    Base = "base_gmodentity",
    PrintName = "Vampire Cure",
    Author = "Your Name",
    Spawnable = true,
    AdminSpawnable = true,
    Initialize = function(self)
        self:SetModel("models/props_junk/watermelon01.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
        end
    end,
    Use = function(self, activator, caller)
        if activator:IsPlayer() and IsVampire(activator) then
            RemoveVampire(activator)
            activator:Kill()
            self:Remove()
        end
    end
}, "ent_vampire_cure")

print("Vampire System addon initialized.")
