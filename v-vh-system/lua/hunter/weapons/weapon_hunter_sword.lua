-- Hunter Sword SWEP

SWEP = {}
SWEP.Base = "weapon_base"
SWEP.PrintName = "Hunter Sword"
SWEP.Author = "Your Name"
SWEP.Instructions = "Left click to slash."
SWEP.Category = "Hunter System"
SWEP.ClassName = "weapon_hunter_sword"
SWEP.Slot = 2

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary = {
    ClipSize = -1,
    DefaultClip = -1,
    Automatic = false,
    Ammo = "none"
}

SWEP.Secondary = {
    ClipSize = -1,
    DefaultClip = -1,
    Automatic = false,
    Ammo = "none"
}

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

function SWEP:Initialize()
    self:SetHoldType("melee")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)

    local tr = self.Owner:GetEyeTrace()
    if not tr.Hit then return end

    local target = tr.Entity
    if not IsValid(target) or not target:IsPlayer() then return end

    if SERVER then
        local dmg = DamageInfo()
        dmg:SetAttacker(self.Owner)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_SLASH)
        dmg:SetDamage(25) -- Consistent damage for a normal sword

        target:TakeDamageInfo(dmg)
    end

    self:EmitSound("Weapon_Crowbar.Single")
end

function SWEP:SecondaryAttack()
    -- No secondary attack
end

weapons.Register(SWEP, "weapon_hunter_sword")
