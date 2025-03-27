-- Hunter Supply Entity

AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Hunter Supply"
ENT.Author = "Charlie"
ENT.Category = "Hunter System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    self:SetModel("models/props_junk/wood_crate001a.mdl")
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
        activator:GiveAmmo(10, "XBowBolt", true)
        self:Remove()
    end
end

scripted_ents.Register(ENT, "ent_hunter_supply")
