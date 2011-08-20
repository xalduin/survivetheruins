library CryptLord


globals
	private unit cryptLord = null
	
	private constant integer BEETLE_LARGE = 'u008'
	private constant integer BEETLE_LARGE_COUNT = 3
	
	private constant integer BEETLE_SMALL = 'u00C'
	private constant integer BEETLE_SMALL_COUNT = 2
endglobals

private function OnBeetleDeath takes nothing returns nothing
 local integer i = 0
 local real x = GetUnitX(GetTriggerUnit())
 local real y = GetUnitY(GetTriggerUnit())
 
 	loop
 		exitwhen i == BEETLE_SMALL_COUNT
 		call CreateUnit(Player(11), BEETLE_SMALL, x, y, 0.)
 		set i = i + 1
 	endloop
 endfunction

private function OnCryptLordDeath takes nothing returns nothing
 local trigger onDeath = CreateTrigger()

 local real x = GetUnitX(cryptLord)
 local real y = GetUnitY(cryptLord)

 local integer i = 0
 local unit temp = null
 
 	set cryptLord = null
 
 	loop
 		exitwhen i == BEETLE_LARGE_COUNT

 		set temp = CreateUnit(Player(11), BEETLE_LARGE, x, y, 0.)
 		call TriggerRegisterUnitEvent(onDeath, temp, EVENT_UNIT_DEATH)

 		set i = i + 1
 	endloop
 	
 	call TriggerAddAction(onDeath, function OnBeetleDeath)
 	
  set temp = null
  set onDeath = null
endfunction

function StartCryptLord takes unit boss returns nothing
 local trigger onDeath = CreateTrigger()
	
	set cryptLord = boss
	
	call TriggerRegisterUnitEvent(onDeath, boss, EVENT_UNIT_DEATH)
	call TriggerAddAction(onDeath, function OnCryptLordDeath)
	
 set onDeath = null
endfunction


endlibrary