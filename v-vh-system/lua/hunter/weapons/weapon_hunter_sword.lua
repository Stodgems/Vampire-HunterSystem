-- Hunter Sword SWEP
-- Model is currently just set to a crowbar untill I decide to either make a custom model or find one that looks how I want it to look

SWEP = {}
SWEP.Base = "weapon_base"
SWEP.PrintName = "Hunter Sword"
SWEP.Author = "Charlie"
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
    self:SetNextPrimaryFire(CurTime() + 0.8)

    local ply = self.Owner
    if not IsValid(ply) then return end

    ply:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_HITCENTER)

    local tr = ply:GetEyeTrace()
    if not tr.Hit then return end

    if SERVER then
        local target = tr.Entity
        if IsValid(target) and tr.HitPos:Distance(ply:GetPos()) <= 75 then
            local dmg = DamageInfo()
            dmg:SetAttacker(ply)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_SLASH)
            dmg:SetDamage(25)

            target:TakeDamageInfo(dmg)
            ply:EmitSound("npc/fast_zombie/claw_strike2.wav")
        else
            ply:EmitSound("npc/fast_zombie/claw_miss1.wav")
        end
    end
end

function SWEP:SecondaryAttack()
end

weapons.Register(SWEP, "weapon_hunter_sword")
