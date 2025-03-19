-- Vampire Claws and Leap SWEP

SWEP = {}
SWEP.Base = "weapon_base"
SWEP.PrintName = "Vampire Claws and Leap"
SWEP.Author = "Your Name"
SWEP.Instructions = "Left click to attack with claws, right click to leap and deal AOE damage on landing."
SWEP.Category = "Vampire System"
SWEP.ClassName = "weapon_vampire_claws_leap"
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
    if not IsFirstTimePredicted() then return end

    self:SetNextPrimaryFire(CurTime() + 0.5)
    if SERVER then
        local ply = self.Owner
        if not IsValid(ply) then return end

        local tr = ply:GetEyeTrace()
        if tr.Hit and tr.HitPos:Distance(ply:GetPos()) <= 75 then
            local dmg = DamageInfo()
            dmg:SetDamage(25)
            dmg:SetAttacker(ply)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_SLASH)
            if IsValid(tr.Entity) then
                tr.Entity:TakeDamageInfo(dmg)
            end
            ply:EmitSound("npc/fast_zombie/claw_strike1.wav")
        end
    end
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end

    local ply = self.Owner
    if not IsValid(ply) then return end

    ply:SetVelocity(ply:GetUp() * 500 + ply:GetForward() * 300)
    ply:EmitSound("npc/fast_zombie/leap1.wav")

    self.LeapInProgress = true
    self:SetNextSecondaryFire(CurTime() + 5)
end

function SWEP:Think()
    if SERVER then
        local ply = self.Owner
        if not IsValid(ply) then return end

        if self.LeapInProgress and ply:IsOnGround() then
            self.LeapInProgress = false

            local effectData = EffectData()
            effectData:SetOrigin(ply:GetPos())

            local dmg = DamageInfo()
            dmg:SetAttacker(ply)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_BLAST)
            dmg:SetDamage(50)

            for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 200)) do
                if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) and ent ~= ply then
                    ent:TakeDamageInfo(dmg)
                end
            end

        end
    end
end

hook.Add("OnPlayerHitGround", "NoFallDamageForVampireLeap", function(ply, inWater, onFloater, speed)
    if IsValid(ply) and ply:Alive() and ply:GetActiveWeapon():GetClass() == "weapon_vampire_claws_leap" and ply:GetActiveWeapon().LeapInProgress then
        ply:GetActiveWeapon().LeapInProgress = false
        return true -- Prevent fall damage
    end
end)

weapons.Register(SWEP, "weapon_vampire_claws_leap")
