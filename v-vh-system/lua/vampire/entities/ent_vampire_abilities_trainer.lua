

AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Vampire Abilities Trainer"
ENT.Author = "Charlie"
ENT.Category = "Vampire System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    self:SetModel("models/props_c17/FurnitureShelf001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if not activator:IsPlayer() then return end

    if not IsVampire(activator) then
        activator:ChatPrint("This is useless to you as you aren't a Vampire.")
        return
    end

    if self.NextUse and self.NextUse > CurTime() then return end
    self.NextUse = CurTime() + 1 
    net.Start("OpenVampireAbilitiesMenu")
    net.WriteTable(VampireAbilities)
    net.Send(activator)
end

scripted_ents.Register(ENT, "ent_vampire_abilities_trainer")
