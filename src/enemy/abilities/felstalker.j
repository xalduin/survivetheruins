scope FelstalkerPoison initializer Init
//requires BuffCore, DummyBuff, DamageEvent, TimedEffects


globals
    private constant integer felId = 'n00L'

    private constant integer dummyAuraId = 'A02Y'
    private constant integer dummyBuffId = 'B009'
    
    private constant real atkSlow = -.1
    private constant real moveSlow = -.3
    
    private constant string poisonSFX = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl"
    private constant real poisonDuration = 5.
    private constant real poisonDamage = 5.
endglobals

struct SlowPoisonBuff extends BuffType
    static key buffKey
    
    method getKey takes nothing returns integer
        return buffKey
    endmethod

    public method onCreate takes BuffData data returns nothing
        call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call data.setUpdateInterval(1.)
        call AddUnitAttackSpeedMult(data.target, atkSlow)
        call AddUnitMoveSpeedMult(data.target, moveSlow)
        call UnitStats_Update(data.target)
    endmethod
    
    method onRecast takes BuffData oldData, unit caster, integer level, real newDuration returns nothing
        set oldData.duration = RMaxBJ(oldData.duration, newDuration)
    endmethod
    
    method onUpdate takes BuffData data returns nothing
        call DamageTarget(data.target, data.target, poisonDamage, DAMAGE_TYPE_EXTRA)
        call AddEffectTimed(AddSpecialEffectTarget(poisonSFX, data.target, "chest"), 1.5)
    endmethod
    
    public method cleanup takes BuffData data returns nothing
        call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitAttackSpeedMult(data.target, -atkSlow)
        call AddUnitMoveSpeedMult(data.target, -moveSlow)
        call UnitStats_Update(data.target)
    endmethod
endstruct

private function OnAttack takes DamagePacket packet returns nothing
 local unit target = packet.target
 local unit attacker = packet.source
 
    if packet.isAttack and GetUnitTypeId(attacker) == felId and IsUnitType(target, UNIT_TYPE_MECHANICAL) == false then
        call UnitApplyBuff(attacker, target, SlowPoisonBuff.create(), 1, poisonDuration)
    endif

 set target = null
 set attacker = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
    call Preload(poisonSFX)
    call PreloadAbility(dummyAuraId)
endfunction


endscope