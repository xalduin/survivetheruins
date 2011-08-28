library Blizzard initializer Init requires Projectile, TimerStack, AbilityOnEffect, DamageFunctions, BuffUtils, SimpleBuff


globals
    //private constant integer dummyAuraId = 'A045'
    //private constant integer dummyBuffId = 'B00I'

    private constant real unitDamage = 100.
    private constant real buildingDamage = 100.
    public constant real damageAOE = 175.
    private constant real slowDuration = 5.
    
    private constant real attackMult = -.2
    private constant real moveMult = -.25
    
    // How far from the caster the Blizzard will travel
    private constant real spellDistance = 1000.
    // How long the spell takes to travel spellDistance
    private constant real spellTime = 3.

    private constant string blizzardSFX = "SnowyBlizzardTarget.mdx"
    private constant integer shardsPerWave = 6
    
    private constant key buffKey
endglobals

private struct Data
    unit caster
    group damagedEnemies
endstruct

private function BlizzardBuff takes nothing returns BuffType
    return FrostBuff(buffKey, attackMult, moveMult)
endfunction

private function BlizzardEffect takes real x, real y returns nothing
 local integer i = 0
 local real angle
 local real targetX
 local real targetY
 
    loop
        exitwhen i >= shardsPerWave
        
        set angle = GetRandomReal(0, 2. * bj_PI)
        set targetX = x + damageAOE * Cos(angle)
        set targetY = y + damageAOE * Sin(angle)
        
        call AddEffectTimed(AddSpecialEffect(blizzardSFX, targetX, targetY), 3.)
        
        set i = i + 1
    endloop
endfunction

private function Blizzard_TrailEffect takes unit missle, integer structData returns nothing
 local group temp = CreateGroup()
 local real x = GetUnitX(missle)
 local real y = GetUnitY(missle)
 local Data data = Data(structData)
 
    call BlizzardEffect(x, y)

    set filterPlayer = GetOwningPlayer(data.caster)
    call GroupEnumUnitsInRange(temp, x, y, damageAOE, Filter_IsUnitAnyValidSpellTarget)
    
    // Remove units that have already been damaged, then
    // Add enemies that will be damaged to the group
    call GroupRemoveGroup(data.damagedEnemies, temp)
    call GroupAddGroup(temp, data.damagedEnemies)

    call DamageGroup(data.caster, unitDamage, temp, DAMAGE_TYPE_MAGICAL)
    call GroupApplyBuff(data.caster, temp, BlizzardBuff(), 1, slowDuration)

    call DestroyGroup(temp)
    
 set temp = null
endfunction

private function Blizzard_Finish takes unit dummy, integer structData returns nothing
 local Data data = Data( structData )
    call DestroyGroup(data.damagedEnemies)
    call data.destroy()
endfunction

private function Blizzard_AddTrail takes SimpleProjectile proj, unit caster returns nothing
 local Data data = Data.create()
 local unit dummy = proj.getDummy()

    set data.caster = caster
    set data.damagedEnemies = CreateGroup()
    
    call proj.periodic(data, .25, Blizzard_TrailEffect, Blizzard_Finish)

 set dummy = null
endfunction

public function Main takes unit caster, real targetX, real targetY returns nothing
 local real casterX = GetUnitX(caster)
 local real casterY = GetUnitY(caster)
 local real angle = Atan2(targetY - casterY, targetX - casterX)
 local SimpleProjectile projectile

    set targetX = casterX + spellDistance * Cos(angle)
    set targetY = casterY + spellDistance * Sin(angle)
 
    set projectile = SimpleProjectile.create(casterX, casterY, targetX, targetY, 0., spellDistance / spellTime)
    call Blizzard_AddTrail(projectile, caster)
endfunction

private function Init takes nothing returns nothing
    call Preload(blizzardSFX)
    //call PreloadAbility(dummyAuraId)
endfunction


endlibrary