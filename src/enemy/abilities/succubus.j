scope SuccubusCritical initializer Init
// requires DamageEvent, ExTextTag


globals
    private constant integer unitId = 'n00T'

	private constant real CRITICAL_MULTIPLIER = 2.
    private constant integer CRITICAL_CHANCE  = 30	// 30/100
endglobals

private function OnAttack takes DamagePacket packet returns nothing
 local unit target = packet.target
 local unit attacker = packet.source
 
    if packet.isAttack and GetUnitTypeId(attacker) == unitId and GetRandomInt(1, 100) <= CRITICAL_CHANCE then
    	set packet.currentDamage = packet.currentDamage * CRITICAL_MULTIPLIER
    	call CreateTextTagEx(I2S(R2I(packet.currentDamage + .5)), GetUnitX(attacker), GetUnitY(attacker), true, CRITICAL)
    endif

 set target = null
 set attacker = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope