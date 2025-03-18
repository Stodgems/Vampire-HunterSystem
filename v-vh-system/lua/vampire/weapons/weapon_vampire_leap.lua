-- Vampire Leap SWEP

SWEP = {}
SWEP.Base = "weapon_base"
SWEP.PrintName = "Vampire Leap"
SWEP.Author = "Your Name"
SWEP.Instructions = "Left click to leap and deal AOE damage on landing."
SWEP.Category = "Vampire System"
SWEP.ClassName = "weapon_vampire_leap"
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
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end

    local ply = self.Owner
    if not IsValid(ply) then return end

    ply:SetVelocity(ply:GetUp() * 500 + ply:GetForward() * 300)
    ply:EmitSound("npc/fast_zombie/leap1.wav")

    timer.Simple(0.5, function()
        if not IsValid(ply) then return end

        local effectData = EffectData()
        effectData:SetOrigin(ply:GetPos())
        util.Effect("HelicopterMegaBomb", effectData)

        local dmg = DamageInfo()
        dmg:SetAttacker(ply)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_BLAST)
        dmg:SetDamage(50)

        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 200)) do
            if ent:IsPlayer() or ent:IsNPC() then
                ent:TakeDamageInfo(dmg)
            end
        end

        ply:EmitSound("ambient/explosions/explode_4.wav")
    end)

    self:SetNextPrimaryFire(CurTime() + 5)
end

function SWEP:SecondaryAttack()
    -- No secondary attack
end

weapons.Register(SWEP, "weapon_vampire_leap")
