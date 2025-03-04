-- Vampire SWEP

SWEP.PrintName = "Vampire Drain"
SWEP.Author = "Your Name"
SWEP.Instructions = "Left click to drain blood from NPCs or players."
SWEP.Category = "Vampire System"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""

function SWEP:Initialize()
    self:SetHoldType("fist")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.8)

    if SERVER then
        local tr = self.Owner:GetEyeTrace()
        if tr.Hit and tr.HitPos:Distance(self.Owner:GetPos()) <= 75 then
            local dmg = DamageInfo()
            dmg:SetDamage(10)
            dmg:SetAttacker(self.Owner)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_SLASH)
            tr.Entity:TakeDamageInfo(dmg)
        end
    end

    if not IsVampire(self.Owner) then return end

    local tr = self.Owner:GetEyeTrace()
    local target = tr.Entity

    if not IsValid(target) or (not target:IsPlayer() and not target:IsNPC()) then return end

    DrainBlood(self.Owner, target)
end

function SWEP:SecondaryAttack()
    -- No secondary attack
end
