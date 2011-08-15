scope OrcResearch initializer Init


// Some globals are used in other orc files
globals
	private constant integer researchCenterId = 'h00O'
	
	constant integer RANGED_ATTACK_UPGRADE = 'R00A'

	constant integer REINFORCED_BURROW_UPGRADE = 'R00B'
	constant integer UPGRADE_BONUS_REINFORCED_BURROW = 7
	
	constant integer POISON_ARROW_UPGRADE = 'R00C'
	constant integer BURNING_OIL_UPGRADE = 'R00D'
	
	constant integer UNIT_BURROW 			= 'o000'
	constant integer UNIT_REINFORCED_BURROW = 'o001'
	constant integer UNIT_ADVANCED_BURROW	= 'o009'
endglobals


private function Main takes nothing returns nothing
 local integer research = GetResearched()
 local player owner = GetOwningPlayer(GetResearchingUnit())
 
 	if research == REINFORCED_BURROW_UPGRADE then
 		call AddUnitTypeArmorBonus(owner, UNIT_BURROW, UPGRADE_BONUS_REINFORCED_BURROW)
 		call AddUnitTypeArmorBonus(owner, UNIT_REINFORCED_BURROW, UPGRADE_BONUS_REINFORCED_BURROW)
 		call AddUnitTypeArmorBonus(owner, UNIT_ADVANCED_BURROW, UPGRADE_BONUS_REINFORCED_BURROW)
 		call UnitStats_PlayerUpdate(owner)
 	endif
 	
  set owner = null
 endfunction

//=================================================

private function Conditions takes nothing returns boolean
	return GetUnitTypeId(GetResearchingUnit()) != researchCenterId and playerRole[GetPlayerId(GetOwningPlayer(GetResearchingUnit()))] == orcId	// See researchallowed.j
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
endfunction


endscope