scope ArcaneTower initializer Init


globals
	private constant integer ABILITY_MANA_BURN = 'A00S'
	private constant integer ABILITY_MANA_BURN_TWO = 'A00U'
endglobals

private function ManaBurnAmount takes integer level returns real
	return I2R(5 * level)
endfunction

private function DamageBonus takes real burn, integer level returns real
	return burn * 5.
endfunction

private function AbilityLevel takes unit u returns integer
	if GetUnitAbilityLevel(u, ABILITY_MANA_BURN_TWO) > 0 then
		return 2
	elseif GetUnitAbilityLevel(u, ABILITY_MANA_BURN) > 0 then
		return 1
	endif
	return 0
endfunction

private function Main takes DamagePacket packet returns nothing
 local integer level = AbilityLevel(packet.source)
 local real mana = GetUnitState(packet.target, UNIT_STATE_MANA)
 local real burn
 
 	if level > 0 and mana > 0. then
 		set burn = ManaBurnAmount(level)
 		call UnitAddMana(packet.source, -burn)
 		
 		if burn > mana then
 			set burn = mana
 		endif
 		
		call DamageTarget(packet.source, packet.target, burn, DAMAGE_TYPE_EXTRA)
	endif

endfunction


private function Init takes nothing returns nothing
	call DamageEvent_Create(Main, 10)
endfunction


endscope