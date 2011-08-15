//Requires:
// DamageEvent			(lib/damage/damageevent.j)

library PhysicistShared initializer Init requires DamageEvent


globals
	integer DAMAGE_TYPE_ELECTRIC = -1
endglobals


private function ConvertDamage takes DamagePacket packet returns nothing
	if packet.damageType == DAMAGE_TYPE_ELECTRIC then
		set packet.damageType = DAMAGE_TYPE_MAGICAL
	endif
endfunction

private function Init takes nothing returns nothing
	set DAMAGE_TYPE_ELECTRIC = DamageEvent_NewDamageType()
	call DamageEvent_Create(ConvertDamage, 900)
endfunction


endlibrary