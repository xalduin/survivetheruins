// Requires:
//	Debug	(src/debug/debug.j)

// Disabled for release

static if Debug_Enabled then
scope Research initializer Init


private function AddDurabilityResearch takes nothing returns nothing
	call DoDurabilityUpgrade(Player(0))
endfunction

private function AddCannonResearch takes nothing returns nothing
	call DoCannonUpgrade(Player(0))
endfunction

private function AddTechResearch takes nothing returns nothing
	call SetPlayerTechResearched(Player(0), 'R004', 2)
endfunction

private function EnableResearchCenter takes nothing returns nothing
	call SetPlayerTechMaxAllowed(GetTriggerPlayer(), Rawcode_UNIT_RESEARCH_CENTER, -1)
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 
 	call TriggerRegisterPlayerChatEvent(t, Player(0), "-r:durability", true)
 	call TriggerAddAction(t, function AddDurabilityResearch)
 	
 	set t = CreateTrigger()
 	call TriggerRegisterPlayerChatEvent(t, Player(0), "-r:cannons", true)
 	call TriggerAddAction(t, function AddCannonResearch)
 	
 	set t = CreateTrigger()
 	call TriggerRegisterPlayerChatEvent(t, Player(0), "-r:tech", true)
 	call TriggerAddAction(t, function AddTechResearch)
 	
 	set t = CreateTrigger()
 	call TriggerRegisterPlayerChatEvent(t, Player(0), "-e:research", true)
 	call TriggerAddAction(t, function EnableResearchCenter)
endfunction
 
 
endscope
endif