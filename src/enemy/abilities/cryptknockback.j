scope CryptLord initializer Init
// requires DamageEvent, KnockbackFunctions


globals
    private constant integer cryptLordId = 'u000'
endglobals

private function OnAttack takes DamagePacket packet returns nothing
 local unit target = packet.target
 local unit attacker = packet.source
 
    if packet.isAttack and GetUnitTypeId(attacker) == cryptLordId and IsUnitType(target, UNIT_TYPE_STRUCTURE) == false then
        call KnockbackUnit(attacker, target, AngleBetweenUnits(attacker, target), 300., true)
    endif

 set target = null
 set attacker = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope