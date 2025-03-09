-- Register the Vampire Blood entity

scripted_ents.Register({
    Type = "anim",
    Base = "base_gmodentity",
    PrintName = "Vampire Blood",
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
            MakeVampire(activator)
            self:Remove()
        end
    end
}, "ent_vampire_blood")

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
