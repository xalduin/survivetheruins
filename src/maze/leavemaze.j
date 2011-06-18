scope ToFreedom initializer Init


private function Main takes nothing returns nothing
 local player owner = GetOwningPlayer(GetTriggerUnit())
 
 	call RemoveUnit(GetTriggerUnit())
 	call RevivePlayer(owner)
 	call FogModifierStop(udg_UnderworldVis[GetPlayerId(owner) + 1])
  set owner = null
endfunction

private function Conditions takes nothing returns boolean
	return GetUnitTypeId(GetTriggerUnit()) == 'h016'
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 
 	call TriggerRegisterEnterRectSimple(t, gg_rct_ToFreedom)
 	call TriggerAddCondition(t, Condition(function Conditions))
 	call TriggerAddAction(t, function Main)

endfunction


endscope