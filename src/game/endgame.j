library EndGame requires TimerStack, CommandAI


globals
	private constant string undeadKillSFX = "Abilities\\Spells\\Other\\Awaken\\Awaken.mdl"
	boolean gameOver = false
endglobals

private struct Data
    group spawns
endstruct

function DestroyUndead_Callback takes nothing returns nothing
 local timer expiredTimer = GetExpiredTimer()
 local Data data = GetTimerData(expiredTimer)
 local group spawns = data.spawns
 local unit randomSpawn = FirstOfGroup(spawns)
 
    if randomSpawn != null then
        call DestroyEffect(AddSpecialEffect(undeadKillSFX, GetUnitX(randomSpawn), GetUnitY(randomSpawn)))
        call KillUnit(randomSpawn)
        call GroupRemoveUnit(spawns, randomSpawn)
    else
        call data.destroy()
        call DestroyGroup(spawns)
        call ReleaseTimer(expiredTimer)
    endif

 set expiredTimer = null
 set spawns = null
 set randomSpawn = null
endfunction

function RevealArea takes nothing returns nothing
    call CreateFogModifierRectBJ(true, GetEnumPlayer(), FOG_OF_WAR_VISIBLE, udg_VisibilityRegion)
endfunction

function DestroyUndead takes nothing returns nothing
 local group spawns = CreateGroup()
 local timer t = NewTimerStart(.25, true, function DestroyUndead_Callback)
 local Data data = Data.create()
 
    call GroupEnumUnitsOfPlayer(spawns, Player(11), Filter(function SpawnFilter))
    set data.spawns = spawns
    call SetTimerData(t, data)
    
    // Reveal the map so players can see undead
    call ForForce(bj_FORCE_ALL_PLAYERS, function RevealArea)
     
 set spawns = null
endfunction

function EndGame_Callback takes nothing returns nothing
    call ReleaseTimer(GetExpiredTimer())
    call EndGame(true)
endfunction       

function Defeat takes boolean archaeologists returns nothing
    if not udg_gameOver then
    
    	call DestroyTimer(gameTimer)
		call DestroyTimerDialog(timerDialog)

        call PauseAllUnitsBJ( true )

        if archaeologists then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "|cffffcc00Defeat:|r The explorers have failed to live through the night! Game ends in 2 minutes." )
            call CinematicFadeBJ( bj_CINEFADETYPE_FADEOUT, 5., "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0 )
        else
        
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "|cffffcc00Victory:|r It is day at last! The Undead cannot stand the light of day. Game will end in 2 minutes.")
            call DestroyUndead()
        endif
        
        set udg_gameOver = true
        set gameOver = true
        call NewTimerStart(120., false, function EndGame_Callback)

    endif
endfunction

function EndGame_Victory takes nothing returns nothing
	call Defeat(false)
endfunction

function CheckDefeat takes nothing returns nothing
 local integer count = CountUnitsInGroup(enemies)
 	if not gameOver and count == 0 then
 		call Defeat(true)
 	endif
 endfunction


endlibrary