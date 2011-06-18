scope PlayerLeaves initializer Init


private function RemoveUnits takes nothing returns nothing
	if GetUnitAbilityLevel(GetEnumUnit(), 'A003') > 0 then
		call GroupRemoveUnit(enemies, GetEnumUnit())
	endif
	
	call RemoveUnit(GetEnumUnit())
endfunction

private function Main takes nothing returns nothing
 local player p = GetTriggerPlayer()
 local integer count = 0
 
	call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., "|cffffcc00LeavingPlayer:|r " + GetPlayerName(p) + " has left the game!")
	
	call GroupEnumUnitsOfPlayer(ENUM_GROUP, p, Filter_NotIsUnitStructure)
	call ForGroup(ENUM_GROUP, function RemoveUnits)
	call GroupClear(ENUM_GROUP)
	
	set count = CountUnitsInGroup(enemies)
	if count == 0 and gameStarted and not gameOver then
		call Defeat(true)
	endif
	
 set p = null
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 local integer i = 0
 
 	loop
 		exitwhen i >= 12
 		call TriggerRegisterPlayerEventLeave(t, Player(i))
 		set i = i + 1
 	endloop
 	
 	call TriggerAddAction(t, function Main)
 endfunction
 
 
 endscope