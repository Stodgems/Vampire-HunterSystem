-- Vampire Cure Entity

AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Vampire Cure"
ENT.Author = "Charlie"
ENT.Category = "Vampire System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if activator:IsPlayer() and IsVampire(activator) then
        RemoveVampire(activator)
        activator:Kill()
        self:Remove()
    end
end

scripted_ents.Register(ENT, "ent_vampire_cure")
