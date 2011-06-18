scope FrostTowers initializer Init


globals
    private constant integer iceTurretId = 'n009'
    private constant integer frostBlasterId = 'n00A'
    private constant integer hoarfrostCannonId = 'n00N'

    private constant real buffDuration = 5.
endglobals

private function OnAttack takes DamagePacket packet returns nothing
 local integer unitType = GetUnitTypeId(packet.source)
 
    if packet.isAttack and (unitType == iceTurretId or unitType == frostBlasterId or unitType == hoarfrostCannonId) then
        call UnitApplyBuff(packet.source, packet.target, ColdBuff(), 1, buffDuration)
    endif
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope