scope PlayerDeath initializer Init


private function Main takes nothing returns nothing
 local player owner = GetOwningPlayer(GetTriggerUnit())
 local real x = GetRectCenterX(gg_rct_UnderworldStart)
 local real y = GetRectCenterY(gg_rct_UnderworldStart)
 local unit soul = CreateUnit(owner, SOUL_MAZE_ID, x, y, 0.)

	call GroupRemoveUnit(enemies, GetTriggerUnit())
	call RemoveUnit(GetTriggerUnit())

	call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., "|cffffcc00Death:|r " + GetPlayerName(owner) + " has been killed!")
	call PlayerStats_AddDeath(owner)

	
	if GetLocalPlayer() == owner then
		call SelectUnit(soul, true)
		call PanCameraToTimed(x, y, 0.)
	endif
	call FogModifierStart(udg_UnderworldVis[GetPlayerId(owner)+1])
	call CheckDefeat()
	
 set owner = null
 set soul = null
endfunction

private function Conditions takes nothing returns boolean
	return GetUnitAbilityLevel(GetTriggerUnit(), REVIVE_ABILITY_ID) > 0
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
 	call TriggerAddCondition(t, Condition(function Conditions))
 	call TriggerAddAction(t, function Main)
 endfunction


endscope