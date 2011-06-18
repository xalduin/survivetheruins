scope BansheeSlow initializer Init
// requires BuffCore, DummyBuff, DamageEvent, TimedEffects, PreloadAbility


globals
    private constant integer unitId = 'u00F'

    private constant real atkSlow = -.15
    private constant real moveSlow = -.2

    private constant real effectDuration = 5.
    
    private constant key buffKey
endglobals

private function FreezeBuff takes nothing returns BuffType
    return FrostBuff(buffKey, atkSlow, moveSlow)
endfunction

private function OnAttack takes DamagePacket packet returns nothing
 local unit target = packet.target
 local unit attacker = packet.source
 
    if packet.isAttack and GetUnitTypeId(attacker) == unitId and IsUnitType(target, UNIT_TYPE_MECHANICAL) == false then
        call UnitApplyBuff(attacker, target, FreezeBuff(), 1, effectDuration)
    endif

 set target = null
 set attacker = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope