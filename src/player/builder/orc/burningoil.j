scope BurningOil initializer Init


globals
	constant integer BUFF_BURNING_OIL = 'Bbof'
	constant integer BUFF_BURNING_OIL_TWO = 'B000'
	private constant real DAMAGE_PER_SECOND = 20.
	
	private boolexpr buffFilter = null
endglobals

private function Damage takes integer level returns real
	return 20. * I2R(level)
endfunction

private function BurningOilLevel takes unit whichUnit returns integer
	if GetUnitAbilityLevel(whichUnit, BUFF_BURNING_OIL_TWO) > 0 then
		return 2
	elseif GetUnitAbilityLevel(whichUnit, BUFF_BURNING_OIL) > 0 then
		return 1
	endif
	return 0
endfunction

private function BurningOilBuffFilter takes nothing returns boolean
	return BurningOilLevel(GetFilterUnit()) > 0
endfunction

private function OilDamageUnit takes nothing returns nothing
 local unit picked = GetEnumUnit()

	call DamageTarget(picked, picked, Damage(BurningOilLevel(picked)), DAMAGE_TYPE_MAGICAL)

 set picked = null
endfunction

private function Main takes nothing returns nothing
	call GroupEnumUnitsInRect(ENUM_GROUP, bj_mapInitialPlayableArea, buffFilter)
	call ForGroup(ENUM_GROUP, function OilDamageUnit)
	call GroupClear(ENUM_GROUP)
endfunction

private function Init takes nothing returns nothing
	set buffFilter = Filter(function BurningOilBuffFilter)
	call TimerStart(CreateTimer(), .5, true, function Main)
endfunction


endscope