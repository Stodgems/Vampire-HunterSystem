-- Hunter SWEP

SWEP = {}
SWEP.PrintName = "Hunter Crossbow"
SWEP.Author = "Your Name"
SWEP.Instructions = "Left click to shoot a bolt."
SWEP.Category = "Hunter System"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary = {
    ClipSize = 1,
    DefaultClip = 1,
    Automatic = false,
    Ammo = "XBowBolt"
}

SWEP.Secondary = {
    ClipSize = -1,
    DefaultClip = -1,
    Automatic = false,
    Ammo = "none"
}

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"

function SWEP:Initialize()
    self:SetHoldType("crossbow")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1.5)

    if SERVER then
        local bolt = ents.Create("crossbow_bolt")
        if not IsValid(bolt) then return end

        bolt:SetPos(self.Owner:GetShootPos())
        bolt:SetAngles(self.Owner:EyeAngles())
        bolt:SetOwner(self.Owner)
        bolt:Spawn()
        bolt:Activate()

        local phys = bolt:GetPhysicsObject()
        if not IsValid(phys) then return end

        phys:SetVelocity(self.Owner:GetAimVector() * 2000)
    end

    self:EmitSound("Weapon_Crossbow.Single")
    self:TakePrimaryAmmo(1)
end

function SWEP:SecondaryAttack()
    -- No secondary attack
end

weapons.Register(SWEP, "weapon_hunter")
