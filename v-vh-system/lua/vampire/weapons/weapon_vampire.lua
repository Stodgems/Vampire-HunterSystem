

SWEP = {}
SWEP.Base = "weapon_base"
SWEP.PrintName = "Vampire Drain"
SWEP.Author = "Charlie"
SWEP.Instructions = "Left click to drain blood from NPCs or players."
SWEP.Category = "Vampire System"
SWEP.ClassName = "weapon_vampire"
SWEP.Slot = 1

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary = {
    ClipSize = -1,
    DefaultClip = -1,
    Automatic = true,
    Ammo = "none"
}

SWEP.Secondary = {
    ClipSize = -1,
    DefaultClip = -1,
    Automatic = false,
    Ammo = "none"
}

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""

function SWEP:Initialize()
    self:SetHoldType("fist")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.8)

    local owner = self.Owner
    if not IsValid(owner) then return end

    local tr = owner:GetEyeTrace()
    local target = tr.Entity

    if SERVER then
        if tr.Hit and tr.HitPos:Distance(owner:GetPos()) <= 75 then
            
            if IsValid(target) then
                local dmg = DamageInfo()
                dmg:SetDamage(10)
                dmg:SetAttacker(owner)
                dmg:SetInflictor(self)
                dmg:SetDamageType(DMG_SLASH)
                target:TakeDamageInfo(dmg)
            end
        end

        
        if IsVampire(owner) and IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
            AddBlood(owner, 50)
        end
    end
end

function SWEP:SecondaryAttack()
end


weapons.Register(SWEP, "weapon_vampire")
