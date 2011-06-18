scope GameInit initializer Init


globals
	boolean gameStarted = false

	timer gameTimer = null
	timerdialog timerDialog = null
endglobals

private function EnableResearch takes nothing returns nothing
	call SetPlayerTechMaxAllowed(GetEnumPlayer(), 'h00O', -1)
endfunction

private function StartGame takes nothing returns nothing
	call PauseTimer(gameTimer)
	
	set gameStarted = true
	set udg_started = true	//Depreciating this now
	
	call SetTimeOfDay(18.)
	call SetTimeOfDayScale(.1333)
	call ForForce(bj_FORCE_ALL_PLAYERS, function EnableResearch)
	
	call CleanupSelectionArea()
	call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., "You hear movement from deep within the ruins slowly approaching...")

	call TimerStart(gameTimer, 1800., false, function EndGame_Victory)
	call TimerDialogSetTitle(timerDialog, "Until Day:")
endfunction
	

private function Main takes nothing returns nothing
	call PauseTimer(gameTimer)

	call SetTimeOfDay(18.)
	call SetTimeOfDayScale(0.)
	call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., "|cffffcc00Notice:|r If you do not select a role before the game starts, you will be assigned a random role.")
	call SelectionStart()
	
	call TimerStart(gameTimer, 180., false,function StartGame)
	
	set timerDialog = CreateTimerDialog(gameTimer)
	call TimerDialogSetTitle(timerDialog, "Until night:")
	call TimerDialogDisplay(timerDialog, true)
	
	call JailRescue_Init(udg_JailRegion)
endfunction

private function Init takes nothing returns nothing
    set gameTimer = CreateTimer()
	call TimerStart(gameTimer, 1., false, function Main)
endfunction


endscope