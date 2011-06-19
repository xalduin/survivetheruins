scope UpgradeTowers initializer Init

//=======================================================================
// This scope accomplishes two tasks
// 1. Periodically checks and updates the ability levels on braziers and shock/tesla towers so that they reflect the current research
// 2. Whenever a tower is constructed or upgraded, after a short delay (to accomodate unit with the chaos ability and such)
//    this will update the stats on the building so that they're accurate with research and such
//=======================================================================

globals
    private group braziers = CreateGroup()
endglobals

private function SetAbilityLevelForUnits takes player whichPlayer, integer unitId, integer abilityId, integer level returns nothing
 local unit picked
 
    call GroupEnumUnitsOfPlayer(braziers, whichPlayer, Filter_Null)
    loop
        set picked = FirstOfGroup(braziers)
        exitwhen picked == null
        
        if GetUnitTypeId(picked) == unitId and GetUnitAbilityLevel(picked, abilityId) != level then
            call SetUnitAbilityLevel(picked, abilityId, level)
        endif
            
        call GroupRemoveUnit(braziers, picked)
    endloop
    call GroupClear(braziers)

 set picked = null
endfunction

private function AbilityUpgrade_Callback takes nothing returns nothing
 local player enumPlayer = GetEnumPlayer()
 local integer level = GetPlayerTechCount(enumPlayer, 'R000', true) + 1
 
    // Brazier second attack
    call SetAbilityLevelForUnits(enumPlayer, 'h002', 'A016', level) 
    call SetAbilityLevelForUnits(enumPlayer, 'h009', 'A01A', level)
    call SetAbilityLevelForUnits(enumPlayer, 'h00G', 'A01B', level)
    
    set level = GetPlayerTechCount(enumPlayer, 'R005', true) + 1
    
    // Shock/Tesla Towers
    call SetAbilityLevelForUnits(enumPlayer, 'h00S', 'A009', level)
    call SetAbilityLevelForUnits(enumPlayer, 'h00V', 'A00T', level)

 set enumPlayer = null
endfunction

private function AbilityUpgrade takes nothing returns nothing
    call ForForce(bj_FORCE_ALL_PLAYERS, function AbilityUpgrade_Callback) 
endfunction

//===========================================================================
// Tower stats updating
//========================================

private struct UnitData
    unit u
endstruct

private function UpdateTowerStats takes nothing returns nothing
 local timer expired = GetExpiredTimer()
 local UnitData data = GetTimerData(expired)
 
    call UnitStats_Update(data.u)
    call data.destroy()
    call ReleaseTimer(expired)
    
 set expired = null
endfunction

private function UpdateBuildingStats takes nothing returns nothing
 local timer t = NewTimerStart(.25, false, function UpdateTowerStats)
 local UnitData data = UnitData.create()

    set data.u = GetConstructedStructure()
    call SetTimerData(t, data)

 set t = null
endfunction

//=================================

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH)
 	call TriggerAddAction(t, function UpdateBuildingStats)

    call TimerStart(CreateTimer(), 5., true, function AbilityUpgrade)
endfunction


endscope