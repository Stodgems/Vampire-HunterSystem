-- Hunter Merchant Entity

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Hunter Merchant"
ENT.Author = "Charlie"
ENT.Category = "Hunter System"
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

    if not IsHunter(activator) then
        activator:ChatPrint("This is useless to you as you aren't a Hunter.")
        return
    end

    if self.NextUse and self.NextUse > CurTime() then return end
    self.NextUse = CurTime() + 1

    net.Start("OpenHunterMerchantMenu")
    net.WriteTable(HunterMerchantItems)
    net.Send(activator)
end

scripted_ents.Register(ENT, "ent_hunter_merchant")
