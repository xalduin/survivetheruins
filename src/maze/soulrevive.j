scope SoulRevive initializer Init


globals
	constant integer SOUL_MAZE_ID = 'h016'
endglobals

struct SoulData
    player owner
    integer revivePoint
endstruct


private function Conditions takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit()) == SOUL_MAZE_ID
endfunction

private function ReviveSoul takes nothing returns nothing
 local timer t = GetExpiredTimer()
 local SoulData data = GetTimerData(t)
 local player owner = data.owner
 local unit temp
 local rect reviveRect
 
    if GetPlayerSlotState(owner) != PLAYER_SLOT_STATE_PLAYING then
        call ReleaseTimer(t)
        call data.destroy()
        set t = null
        set owner = null
        return
    endif

    if data.revivePoint == 1 then
        set reviveRect = gg_rct_UnderworldAppear1
    else
        set reviveRect = gg_rct_UnderworldStart
    endif
 
    set temp = CreateUnit(owner, 'h016', GetRectCenterX(reviveRect), GetRectCenterY(reviveRect), 0.)
    
    if data.revivePoint == 1 then
        call UnitAddAbility(temp, 'A03A')
    endif
    
    if GetLocalPlayer() == owner then
        call ClearSelection()
        call SelectUnit(temp, true)
    endif
    
    call data.destroy()
    call ReleaseTimer(t)
    
 set t = null
 set owner = null
 set temp = null
 set reviveRect = null
endfunction

private function Main takes nothing returns nothing
 local timer t = NewTimerStart(5.0, false, function ReviveSoul)
 local SoulData data = SoulData.create()
 local player owner = GetOwningPlayer(GetTriggerUnit())
 local rect reviveRect
 
    set data.owner = owner
    set data.revivePoint = GetUnitAbilityLevel(GetTriggerUnit(), 'A03A')
    
    if data.revivePoint == 1 then
        set reviveRect = gg_rct_UnderworldAppear1
    else
        set reviveRect = gg_rct_UnderworldStart
    endif
    
    call SetTimerData(t, data)
    call PanCameraToTimedForPlayer(owner, GetRectCenterX(reviveRect), GetRectCenterY(reviveRect), 5.0)
 
 set t = null
 set owner = null
 set reviveRect = null
endfunction

//===========================================================================
private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
endfunction


endscope