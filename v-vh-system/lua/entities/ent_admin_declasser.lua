-- Admin Declasser Entity
-- This is slightly redudant as you can remove people from vampire or hunter from the admin menu but I will let it remain for now

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Admin Declasser"
ENT.Author = "Charlie"
ENT.Category = "Admin Tools"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01b.mdl")
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
        if IsHunter(activator) then
            RemoveHunter(activator)
            activator:ChatPrint("You have been removed from the hunter system!")
        elseif IsVampire(activator) then
            RemoveVampire(activator)
            activator:ChatPrint("You have been cured of vampirism!")
        else
            activator:ChatPrint("You are neither a hunter nor a vampire.")
        end
        self:Remove()
    end
end

scripted_ents.Register(ENT, "ent_admin_declasser")
