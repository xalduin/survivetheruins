library TankUpgrades initializer Init requires Rawcode, TankMisc


private function Main takes nothing returns nothing
 local integer tech = GetResearched()
 local player owner = GetOwningPlayer(GetTriggerUnit())
 local integer level = GetPlayerTechCount(owner, tech, true)
 
 	if tech == Rawcode_RESEARCH_SIEGE_TANK then
 		if level == 1 then
 			call SetPlayerTechMaxAllowed(owner, Rawcode_UNIT_TANK, 0)
 			//call SetPlayerMaxTechAllowed(owner, UNIT_SIEGE_TANK, 1)
 		elseif level == 2 then
 			call SetPlayerTechMaxAllowed(owner, Rawcode_UNIT_SIEGE_TANK, 0)
 			//call SetPlayerMaxTechAllowed(owner, UNIT_ONSLAUGHT_TANK, 1)
 		endif

 		call EnableTank(owner)

 	elseif tech == Rawcode_RESEARCH_BATTLE_TANK then
 		if level == 1 then
 			call SetPlayerTechMaxAllowed(owner, Rawcode_UNIT_TANK, 0)
 			//call SetPlayerMaxTechAllowed(owner, UNIT_BATTLE_TANK, 1)
 		elseif level == 2 then
 			call SetPlayerTechMaxAllowed(owner, Rawcode_UNIT_BATTLE_TANK, 0)
 			//call SetPlayerMaxTechAllowed(owner, UNIT_ASSAULT_TANK, 1)
 		endif
 		
 		call EnableTank(owner)
 	endif

 set owner = null
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH)
 	call TriggerAddAction(t, function Main)
endfunction


endlibrary