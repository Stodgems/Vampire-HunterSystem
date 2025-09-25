

AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Garlic Serum"
ENT.Author = "Charlie"
ENT.Category = "Hunter System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    self:SetModel("models/props_lab/jar01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if activator:IsPlayer() then
        MakeHunter(activator)
        self:Remove()
    end
end

scripted_ents.Register(ENT, "ent_garlic_serum")
