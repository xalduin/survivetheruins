scope UnitInfo initializer Init


private function Main takes nothing returns nothing
    call UpdateUnitStatsBoard(GetTriggerPlayer(), GetTriggerUnit())
endfunction

//===========================================================================
private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 local integer i = 0
 
 	loop
 		exitwhen i >= 10
 		call TriggerRegisterPlayerSelectionEventBJ(t, Player(i), true)
 		set i = i + 1
 	endloop
 	
 	call TriggerAddAction(t, function Main)
endfunction


endscope