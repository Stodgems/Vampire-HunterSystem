SWEP.PrintName = "Hybrid Claws"
SWEP.Author = "VampireSystem"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to slash, right click for blood drain/rage attack, R for dual howl"

SWEP.Category = "Hybrid"

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

SWEP.Primary.Damage = 50
SWEP.Primary.Force = 6
SWEP.Primary.Delay = 1.0

SWEP.Secondary.Damage = 70
SWEP.Secondary.Force = 8
SWEP.Secondary.Delay = 1.5

function SWEP:Initialize()
    self:SetWeaponHoldType("fist")
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    return true
end

function SWEP:GetHybridDamageMultiplier(owner)
    if not IsHybrid(owner) then return 1.0 end
    
    local hybrid = hybrids[owner:SteamID()]
    local multiplier = 1.0
    
    
    local balance = hybrid.balance
    local balanceType = GetHybridBalanceType(balance)
    
    if balanceType == "vampire" then
        multiplier = multiplier * 1.2
    elseif balanceType == "werewolf" then
        multiplier = multiplier * 1.3
    else 
        multiplier = multiplier * 1.4 
    end
    
    
    if hybrid.transformed then
        if hybrid.currentForm == "vampireForm" then
            multiplier = multiplier * 1.5
        elseif hybrid.currentForm == "werewolfForm" then
            multiplier = multiplier * 1.6
        elseif hybrid.currentForm == "eclipseForm" then
            multiplier = multiplier * 2.5
        end
    end
    
    
    if hybrid.eclipseBoost then
        multiplier = multiplier * 1.8
    end
    
    return multiplier
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    
    local damage = self.Primary.Damage
    
    
    if IsHybrid(owner) then
        damage = damage * self:GetHybridDamageMultiplier(owner)
    end
    
    
    local trace = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 85,
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
            dmgInfo:SetDamageForce(owner:GetAimVector() * self.Primary.Force * 1200)
            
            ent:TakeDamageInfo(dmgInfo)
            
            
            if SERVER and IsHybrid(owner) then
                local hybrid = hybrids[owner:SteamID()]
                local balanceType = GetHybridBalanceType(hybrid.balance)
                
                
                if balanceType == "vampire" then
                    
                    local bloodGain = math.random(15, 25)
                    AddBloodToHybrid(owner, bloodGain)
                    owner:ChatPrint("You drain " .. bloodGain .. " blood!")
                elseif balanceType == "werewolf" then
                    
                    local rageGain = math.random(8, 12)
                    AddRageToHybrid(owner, rageGain)
                    owner:ChatPrint("You gain " .. rageGain .. " rage!")
                else
                    
                    local bloodGain = math.random(8, 15)
                    local rageGain = math.random(5, 8)
                    AddBloodToHybrid(owner, bloodGain)
                    AddRageToHybrid(owner, rageGain)
                    owner:ChatPrint("You gain " .. bloodGain .. " blood and " .. rageGain .. " rage!")
                end
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
    
    
    local soundFile = "npc/zombie/claw_strike" .. math.random(1, 3) .. ".wav"
    local pitch = math.random(90, 110)
    
    if IsHybrid(owner) then
        local hybrid = hybrids[owner:SteamID()]
        if hybrid.transformed then
            if hybrid.currentForm == "vampireForm" then
                pitch = math.random(120, 140) 
            elseif hybrid.currentForm == "werewolfForm" then
                pitch = math.random(70, 90) 
            elseif hybrid.currentForm == "eclipseForm" then
                
                owner:EmitSound(soundFile, 75, 120)
                owner:EmitSound(soundFile, 75, 80)
                return
            end
        end
    end
    
    owner:EmitSound(soundFile, 75, pitch)
    
    
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
    
    
    if IsHybrid(owner) then
        damage = damage * self:GetHybridDamageMultiplier(owner)
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
            dmgInfo:SetDamageForce(owner:GetAimVector() * self.Secondary.Force * 1800)
            
            ent:TakeDamageInfo(dmgInfo)
            
            
            if SERVER and IsHybrid(owner) then
                local hybrid = hybrids[owner:SteamID()]
                local balanceType = GetHybridBalanceType(hybrid.balance)
                
                if balanceType == "vampire" then
                    
                    local bloodGain = math.random(30, 50)
                    AddBloodToHybrid(owner, bloodGain)
                    owner:ChatPrint("Devastating drain: +" .. bloodGain .. " blood!")
                    
                    
                    owner:SetHealth(math.min(owner:GetMaxHealth(), owner:Health() + 20))
                elseif balanceType == "werewolf" then
                    
                    local rageGain = math.random(15, 25)
                    AddRageToHybrid(owner, rageGain)
                    owner:ChatPrint("Primal fury: +" .. rageGain .. " rage!")
                    
                    
                    for _, ply in ipairs(player.GetAll()) do
                        if ply ~= owner and ply:GetPos():Distance(owner:GetPos()) < 300 then
                            if not IsHybrid(ply) then
                                ply:ChatPrint("The hybrid's roar fills you with dread!")
                            end
                        end
                    end
                else
                    
                    local bloodGain = math.random(20, 30)
                    local rageGain = math.random(10, 15)
                    AddBloodToHybrid(owner, bloodGain)
                    AddRageToHybrid(owner, rageGain)
                    
                    
                    hybrid.dualEssence = math.min(HybridConfig.Resources.dualEssence.maxAmount, 
                                                  hybrid.dualEssence + 2)
                    
                    owner:ChatPrint("Dual strike: +" .. bloodGain .. " blood, +" .. rageGain .. " rage, +2 essence!")
                end
            end
            
            
            if CLIENT then
                local effectData = EffectData()
                effectData:SetOrigin(trace.HitPos)
                effectData:SetNormal(trace.HitNormal)
                util.Effect("BloodImpact", effectData)
                
                
                for i = 1, 3 do
                    local particleEffect = EffectData()
                    particleEffect:SetOrigin(trace.HitPos + VectorRand() * 10)
                    particleEffect:SetMagnitude(1)
                    util.Effect("balloon_pop", particleEffect)
                end
            end
        else
            
            if CLIENT then
                local effectData = EffectData()
                effectData:SetOrigin(trace.HitPos)
                effectData:SetNormal(trace.HitNormal)
                effectData:SetMagnitude(2)
                util.Effect("Explosion", effectData)
            end
        end
    end
    
    
    owner:EmitSound("npc/zombie/claw_strike1.wav", 100, 60)
    owner:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 14) .. ".wav", 75, math.random(70, 90))
    
    
    owner:SetAnimation(PLAYER_ATTACK2)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    
    if SERVER then
        owner:LagCompensation(true)
        owner:LagCompensation(false)
    end
end

function SWEP:Reload()
    if not IsHybrid(self:GetOwner()) then return end
    
    local owner = self:GetOwner()
    self:SetNextPrimaryFire(CurTime() + 3)
    self:SetNextSecondaryFire(CurTime() + 3)
    
    
    if SERVER then
        local hybrid = hybrids[owner:SteamID()]
        local balanceType = GetHybridBalanceType(hybrid.balance)
        
        if hybrid.transformed then
            
            if hybrid.currentForm == "vampireForm" then
                owner:EmitSound("ambient/creatures/town_child_scream1.wav", 100, 120)
                
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= owner and ply:GetPos():Distance(owner:GetPos()) < 400 then
                        if not IsHybrid(ply) and not IsVampire(ply) then
                            ply:SetRunSpeed(ply:GetRunSpeed() * 0.6)
                            ply:ChatPrint("The vampire's shriek chills your blood!")
                            
                            timer.Simple(8, function()
                                if IsValid(ply) then
                                    ply:SetRunSpeed(250)
                                end
                            end)
                        end
                    end
                end
            elseif hybrid.currentForm == "werewolfForm" then
                owner:EmitSound("ambient/creatures/town_child_scream1.wav", 100, 70)
                
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= owner and ply:GetPos():Distance(owner:GetPos()) < 500 then
                        if not IsHybrid(ply) and not IsWerewolf(ply) then
                            ply:ChatPrint("The werewolf's howl strikes terror into your heart!")
                            
                            ply:ConCommand("pp_mat_overlay effects/strider_bulge_dudv")
                            timer.Simple(3, function()
                                if IsValid(ply) then
                                    ply:ConCommand("pp_mat_overlay ''")
                                end
                            end)
                        end
                    end
                end
            elseif hybrid.currentForm == "eclipseForm" then
                
                owner:EmitSound("ambient/creatures/town_child_scream1.wav", 120, 95)
                owner:EmitSound("ambient/levels/citadel/strange_talk9.wav", 100, 50)
                
                
                for _, ply in ipairs(player.GetAll()) do
                    if ply ~= owner and ply:GetPos():Distance(owner:GetPos()) < 800 then
                        if not IsHybrid(ply) then
                            ply:SetRunSpeed(ply:GetRunSpeed() * 0.3)
                            ply:ChatPrint("The eclipse hybrid's otherworldly roar paralyzes you with fear!")
                            
                            
                            ply:ConCommand("pp_mat_overlay effects/tp_eyefx/tp_eyefx")
                            
                            timer.Simple(5, function()
                                if IsValid(ply) then
                                    ply:SetRunSpeed(250)
                                    ply:ConCommand("pp_mat_overlay ''")
                                end
                            end)
                        end
                    end
                end
            end
        else
            
            owner:EmitSound("ambient/creatures/town_child_scream1.wav", 80, 90)
            
            for _, ply in ipairs(player.GetAll()) do
                if ply ~= owner and ply:GetPos():Distance(owner:GetPos()) < 300 then
                    if not IsHybrid(ply) then
                        ply:ChatPrint("The hybrid's haunting call disturbs you...")
                    end
                end
            end
        end
        
        
        AddBloodToHybrid(owner, 5)
        AddRageToHybrid(owner, 5)
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
        if not IsHybrid(LocalPlayer()) then return end
        
        local hybrid = hybrids[LocalPlayer():SteamID()]
        if not hybrid then return end
        
        
        local x, y = ScrW() / 2, ScrH() - 120
        
        if hybrid.transformed then
            local formName = hybrid.currentForm:gsub("Form", "")
            local formColor = Color(255, 0, 0)
            
            if hybrid.currentForm == "werewolfForm" then
                formColor = Color(139, 69, 19)
            elseif hybrid.currentForm == "eclipseForm" then
                formColor = Color(128, 0, 128)
            end
            
            draw.SimpleText("HYBRID " .. string.upper(formName) .. " FORM", "DermaLarge", x, y, formColor, TEXT_ALIGN_CENTER)
        end
        
        
        local balanceColor, balanceType = GetBalanceInfo(hybrid.balance)
        draw.SimpleText("Balance: " .. balanceType, "DermaDefault", x, y + 30, balanceColor, TEXT_ALIGN_CENTER)
        
        
        local multiplier = self:GetHybridDamageMultiplier(LocalPlayer())
        draw.SimpleText(string.format("Damage: %.1fx", multiplier), "DermaDefault", x, y + 50, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end
    
    function SWEP:DrawWorldModel()
        
        return
    end
end