SWEP.PrintName = "Werewolf Claws"
SWEP.Author = "VampireSystem"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to slash, right click for heavy attack, R to howl"

SWEP.Category = "Werewolf"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 62
SWEP.UseHands = true

SWEP.Primary.Damage = 40
SWEP.Primary.Force = 5
SWEP.Primary.Delay = 1.0

SWEP.Secondary.Damage = 80
SWEP.Secondary.Force = 10
SWEP.Secondary.Delay = 2.0

function SWEP:Initialize()
    self:SetWeaponHoldType("fist")
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    return true
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    
    local damage = self.Primary.Damage
    
    
    if IsWerewolf(owner) then
        local werewolf = werewolves[owner:SteamID()]
        local moonPhase = WerewolfConfig.MoonPhases[CurrentMoonPhase]
        
        
        if moonPhase then
            damage = damage * moonPhase.multiplier
        end
        
        
        if werewolf and werewolf.transformed then
            damage = damage * 1.5
            
            
            if CLIENT then
                util.ScreenShake(owner:GetPos(), 2, 2, 0.5, 100)
            end
        end
        
        
        if owner.werewolfPack then
            local packBonus = ApplyPackTransformationBonus(owner)
            damage = damage + (packBonus or 0)
        end
    end
    
    
    local trace = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 80,
        filter = owner,
        mask = MASK_SHOT_HULL
    })
    
    if trace.Hit and IsValid(trace.Entity) then
        local ent = trace.Entity
        
        if ent:IsPlayer() or ent:IsNPC() then
            
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(damage)
            dmgInfo:SetAttacker(owner)
            dmgInfo:SetInflictor(self)
            dmgInfo:SetDamageType(DMG_SLASH)
            dmgInfo:SetDamageForce(owner:GetAimVector() * self.Primary.Force * 1000)
            
            ent:TakeDamageInfo(dmgInfo)
            
            
            if SERVER and IsWerewolf(owner) then
                AddRage(owner, 5)
            end
            
            
            if CLIENT then
                local effectData = EffectData()
                effectData:SetOrigin(trace.HitPos)
                effectData:SetNormal(trace.HitNormal)
                util.Effect("BloodImpact", effectData)
            end
        else
            
            if CLIENT then
                local effectData = EffectData()
                effectData:SetOrigin(trace.HitPos)
                effectData:SetNormal(trace.HitNormal)
                util.Effect("cball_explode", effectData)
            end
        end
    end
    
    
    owner:EmitSound("npc/zombie/claw_strike" .. math.random(1, 3) .. ".wav", 75, math.random(90, 110))
    
    
    owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_HITCENTER)
    
    if SERVER then
        owner:LagCompensation(true)
        owner:LagCompensation(false)
    end
end

function SWEP:SecondaryAttack()
    if not self:CanSecondaryAttack() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
    
    local damage = self.Secondary.Damage
    
    
    if IsWerewolf(owner) then
        local werewolf = werewolves[owner:SteamID()]
        local moonPhase = WerewolfConfig.MoonPhases[CurrentMoonPhase]
        
        
        if moonPhase then
            damage = damage * moonPhase.multiplier
        end
        
        
        if werewolf and werewolf.transformed then
            damage = damage * 2.0 
            
            
            if CLIENT then
                util.ScreenShake(owner:GetPos(), 5, 5, 1.0, 150)
            end
        end
        
        
        if owner.werewolfPack then
            local packBonus = ApplyPackTransformationBonus(owner)
            damage = damage + (packBonus or 0) * 2
        end
    end
    
    
    local trace = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 100,
        filter = owner,
        mask = MASK_SHOT_HULL
    })
    
    if trace.Hit and IsValid(trace.Entity) then
        local ent = trace.Entity
        
        if ent:IsPlayer() or ent:IsNPC() then
            
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(damage)
            dmgInfo:SetAttacker(owner)
            dmgInfo:SetInflictor(self)
            dmgInfo:SetDamageType(DMG_SLASH)
            dmgInfo:SetDamageForce(owner:GetAimVector() * self.Secondary.Force * 1500)
            
            ent:TakeDamageInfo(dmgInfo)
            
            
            if SERVER and IsWerewolf(owner) then
                AddRage(owner, 10)
            end
            
            
            if CLIENT then
                local effectData = EffectData()
                effectData:SetOrigin(trace.HitPos)
                effectData:SetNormal(trace.HitNormal)
                util.Effect("BloodImpact", effectData)
            end
        else
            
            if CLIENT then
                local effectData = EffectData()
                effectData:SetOrigin(trace.HitPos)
                effectData:SetNormal(trace.HitNormal)
                util.Effect("Explosion", effectData)
            end
        end
    end
    
    
    owner:EmitSound("npc/zombie/claw_strike1.wav", 100, 70)
    owner:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 14) .. ".wav", 75, math.random(80, 90))
    
    
    owner:SetAnimation(PLAYER_ATTACK2)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    
    if SERVER then
        owner:LagCompensation(true)
        owner:LagCompensation(false)
    end
end

function SWEP:Reload()
    if not IsWerewolf(self:GetOwner()) then return end
    
    local owner = self:GetOwner()
    self:SetNextPrimaryFire(CurTime() + 3)
    self:SetNextSecondaryFire(CurTime() + 3)
    
    
    if SERVER then
        local werewolf = werewolves[owner:SteamID()]
        if werewolf and werewolf.transformed then
            
            owner:EmitSound("ambient/creatures/town_child_scream1.wav", 100, 60)
            
            
            for _, ply in ipairs(player.GetAll()) do
                if ply ~= owner and ply:GetPos():Distance(owner:GetPos()) < 500 then
                    if not IsWerewolf(ply) then
                        
                        ply:SetRunSpeed(ply:GetRunSpeed() * 0.5)
                        ply:ChatPrint("The werewolf's howl fills you with terror!")
                        
                        timer.Simple(5, function()
                            if IsValid(ply) then
                                ply:SetRunSpeed(250) 
                            end
                        end)
                    end
                end
            end
        else
            
            owner:EmitSound("ambient/creatures/town_child_scream1.wav", 75, 80)
        end
        
        
        AddRage(owner, 3)
    end
end

function SWEP:CanPrimaryAttack()
    return true
end

function SWEP:CanSecondaryAttack()
    return true
end

if CLIENT then
    function SWEP:DrawHUD()
        if not IsWerewolf(LocalPlayer()) then return end
        
        local werewolf = werewolves[LocalPlayer():SteamID()]
        if not werewolf then return end
        
        
        local x, y = ScrW() / 2, ScrH() - 100
        
        if werewolf.transformed then
            draw.SimpleText("🌕 BEAST MODE 🌕", "DermaLarge", x, y, Color(255, 0, 0), TEXT_ALIGN_CENTER)
        end
        
        
        local moonPhase = WerewolfConfig.MoonPhases[CurrentMoonPhase]
        if moonPhase then
            local bonusText = string.format("Moon Bonus: %.0f%%", moonPhase.multiplier * 100)
            draw.SimpleText(bonusText, "DermaDefault", x, y + 30, Color(200, 200, 255), TEXT_ALIGN_CENTER)
        end
    end
    
    function SWEP:DrawWorldModel()
        
        return
    end
end