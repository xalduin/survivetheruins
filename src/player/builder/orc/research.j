scope OrcResearch initializer Init


globals
	constant integer UPGRADE_BONUS_REINFORCED_BURROW = 7
endglobals


private function Main takes nothing returns nothing
 local integer research = GetResearched()
 local player owner = GetOwningPlayer(GetResearchingUnit())
 
 	if research == Rawcode_RESEARCH_REINFORCED_DEFENSES then
 		call AddUnitTypeArmorBonus(owner, Rawcode_UNIT_BURROW, 			  UPGRADE_BONUS_REINFORCED_BURROW)
 		call AddUnitTypeArmorBonus(owner, Rawcode_UNIT_REINFORCED_BURROW, UPGRADE_BONUS_REINFORCED_BURROW)
 		call AddUnitTypeArmorBonus(owner, Rawcode_UNIT_ADVANCED_BURROW,   UPGRADE_BONUS_REINFORCED_BURROW)
 		call UnitStats_PlayerUpdate(owner)
 	endif
 	
  set owner = null
 endfunction

//=================================================

private function Conditions takes nothing returns boolean
	return GetUnitTypeId(GetResearchingUnit()) != Rawcode_UNIT_RESEARCH_CENTER and playerRole[GetPlayerId(GetOwningPlayer(GetResearchingUnit()))] == orcId	// See researchallowed.j
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
endfunction


endscope