scope ShieldGenerator initializer Init


globals
	private constant integer SHIELD_ID = 'h017'
	private constant real DAMAGE_REDUCTION = .10
	private constant real AREA_OF_EFFECT = 400.
	
	private unit bestShield = null
endglobals

// Returns false is the picked unit isn't the shield generator
// Also returns false is the picked shield isn't as good as the "best shield"

private function IsUnitTypeShield takes nothing returns boolean
	if IsUnitEnemy(GetFilterUnit(), filterPlayer) then
		return false

	elseif GetUnitTypeId(GetFilterUnit()) != SHIELD_ID then
		return false
		
	// A shield isn't as good as the best shield if it has less mana
	elseif bestShield != null and GetUnitState(GetFilterUnit(), UNIT_STATE_MANA) <= GetUnitState(bestShield, UNIT_STATE_MANA) then
		return false
	elseif IsBuildingDisabled(GetFilterUnit()) then
		return false
	endif
 
	set bestShield = GetFilterUnit()
	return false
endfunction

private function OnAttack takes DamagePacket packet returns nothing
 local group shields = CreateGroup()
 local real blockedDamage = packet.currentDamage * DAMAGE_REDUCTION
 
	set bestShield = null
	set filterPlayer = GetOwningPlayer(packet.target)
	call GroupEnumUnitsInRange(shields, GetUnitX(packet.target), GetUnitY(packet.target), AREA_OF_EFFECT, Filter(function IsUnitTypeShield))

	call DestroyGroup(shields)
	set shields = null
	
	if bestShield == null then
		return
	endif
	
	set blockedDamage = RMinBJ(blockedDamage, GetUnitState(bestShield, UNIT_STATE_MANA))
	set packet.currentDamage = packet.currentDamage - blockedDamage
	call UnitAddMana(bestShield, -blockedDamage)
endfunction

private function Init takes nothing returns nothing
	call DamageEvent_Create(OnAttack, 5)
endfunction


endscope