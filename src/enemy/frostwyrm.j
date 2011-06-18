scope FrostWyrmAttack initializer Init


globals
    private constant integer frostWyrmId = 'u00H'

    private constant real buffDuration = 5.
endglobals

private function OnAttack takes DamagePacket packet returns nothing
 local integer unitType = GetUnitTypeId(packet.source)
 
    if packet.isAttack and (unitType == frostWyrmId) and IsUnitType(packet.target, UNIT_TYPE_STRUCTURE) == false then
        call UnitApplyBuff(packet.source, packet.target, ColdBuff(), 1, buffDuration)
    endif
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope