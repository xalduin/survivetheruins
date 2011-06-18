scope SkeletonArcherSlow initializer Init
//requires BuffCore, DummyBuff, DamageEvent, TimedEffects


globals
    private constant integer archerId = 'n00W'
    
    private constant real atkSlow = -.05
    private constant real moveSlow = -.25
    private constant real slowDuration = 1.5
    
    private constant key buffKey
endglobals

private function FrostAttackBuff takes nothing returns BuffType
    return FrostBuff(buffKey, atkSlow, moveSlow)
endfunction

private function OnAttack takes DamagePacket packet returns nothing
 local unit target = packet.target
 local unit attacker = packet.source
 
    if packet.isAttack and GetUnitTypeId(attacker) == archerId and IsUnitType(target, UNIT_TYPE_MECHANICAL) == false then
        call UnitApplyBuff(attacker, target, FrostAttackBuff(), 1, slowDuration)
    endif

 set target = null
 set attacker = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope