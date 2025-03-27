-- Wooden Stake SWEP

SWEP = {}
SWEP.Base = "weapon_base"
SWEP.PrintName = "Wooden Stake"
SWEP.Author = "Charlie"
SWEP.Instructions = "Left click to stab."
SWEP.Category = "Hunter System"
SWEP.ClassName = "weapon_stake"
SWEP.Slot = 1

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
    self:SetNextPrimaryFire(CurTime() + 0.8)

    local ply = self.Owner
    if not IsValid(ply) then return end

    ply:SetAnimation(PLAYER_ATTACK1) -- Play attack animation
    self:SendWeaponAnim(ACT_VM_HITCENTER) -- Play weapon animation

    local tr = ply:GetEyeTrace()
    if not tr.Hit then return end

    if SERVER then
        local target = tr.Entity
        if IsValid(target) and tr.HitPos:Distance(ply:GetPos()) <= 75 then
            local dmg = DamageInfo()
            dmg:SetAttacker(ply)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_SLASH)

            if IsVampire(target) then
                dmg:SetDamage(50) -- Higher damage for vampires
            else
                dmg:SetDamage(10) -- Lower damage for others
            end

            target:TakeDamageInfo(dmg)
            ply:EmitSound("npc/fast_zombie/claw_strike1.wav")
        else
            ply:EmitSound("npc/fast_zombie/claw_miss1.wav")
        end
    end
end

function SWEP:SecondaryAttack()
    -- No secondary attack
end

weapons.Register(SWEP, "weapon_stake")
