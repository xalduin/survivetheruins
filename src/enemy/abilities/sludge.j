scope SludgeAttack initializer Init
// requires BuffCore, DummyBuff, DamageEvent, TimedEffects, BonusMod


globals
    private constant integer sludgeId = 'n00R'

    private constant integer dummyAuraId = 'A00V'
    private constant integer dummyBuffId = 'B00G'
    
    private constant real atkSlow = -.05
    private constant real moveSlow = -.1

    private constant real sludgeDuration = 5.
    private constant integer armorReduce = -3
endglobals

struct SludgeBuff extends BuffType
    static key buffKey
    
    method getKey takes nothing returns integer
        return buffKey
    endmethod

    public method onCreate takes BuffData data returns nothing
        call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitArmorBonus(data.target, armorReduce)
        call AddUnitAttackSpeedMult(data.target, atkSlow)
        call AddUnitMoveSpeedMult(data.target, moveSlow)
        call UnitStats_Update(data.target)
    endmethod
    
    method onRecast takes BuffData oldData, unit caster, integer level, real newDuration returns nothing
        set oldData.duration = RMaxBJ(oldData.duration, newDuration)
    endmethod
    
    public method cleanup takes BuffData data returns nothing
        call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitArmorBonus(data.target, -armorReduce)
        call AddUnitAttackSpeedMult(data.target, -atkSlow)
        call AddUnitMoveSpeedMult(data.target, -moveSlow)
        call UnitStats_Update(data.target)
    endmethod
endstruct

private function OnAttack takes DamagePacket packet returns nothing
 local unit target = packet.target
 local unit attacker = packet.source
 
    if packet.isAttack and GetUnitTypeId(attacker) == sludgeId and IsUnitType(target, UNIT_TYPE_MECHANICAL) == false then
        call UnitApplyBuff(attacker, target, SludgeBuff.create(), 1, sludgeDuration)
    endif

 set target = null
 set attacker = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
    call PreloadAbility(dummyAuraId)
endfunction


endscope