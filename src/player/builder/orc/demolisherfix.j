scope DemolisherFix initializer Init


//====================
// Condition Functions
//====================

private function IsUnitUltimateDemolisher takes nothing returns boolean
	return GetUnitTypeId(GetTriggerUnit()) == Rawcode_UNIT_ULTIMATE_DEMOLISHER
endfunction

private function IsUnitDemolisher takes nothing returns boolean
	return GetUnitTypeId(GetTriggerUnit()) == Rawcode_UNIT_DEMOLISHER
endfunction

//==================

private function LimitDemolisher takes nothing returns nothing
	call SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), Rawcode_UNIT_DEMOLISHER, 0)
endfunction

private function EnableDemolisher takes nothing returns nothing
	call SetPlayerTechMaxAllowed(GetOwningPlayer(GetTriggerUnit()), Rawcode_UNIT_DEMOLISHER, 1)
endfunction

//===================

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_START)
	call TriggerAddCondition(t, Condition(function IsUnitUltimateDemolisher))
	call TriggerAddAction(t, function LimitDemolisher)
	
	set t = CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(t, Condition(function IsUnitUltimateDemolisher))
	call TriggerAddAction(t, function EnableDemolisher)
	
	set t = CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_CANCEL)
	call TriggerAddCondition(t, Condition(function IsUnitDemolisher))
	call TriggerAddAction(t, function EnableDemolisher)
	
 set t = null
endfunction


endscope