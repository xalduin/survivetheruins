scope UpgradeTowers initializer Init


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

private function BrazierUpgrade_Callback takes nothing returns nothing
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

private function BrazierUpgrade takes nothing returns nothing
    call ForForce(bj_FORCE_ALL_PLAYERS, function BrazierUpgrade_Callback) 
endfunction

//===========================================================================
private function UpdateBuildingStats takes nothing returns nothing
	call UnitStats_Update(GetTriggerUnit())
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH)
 	call TriggerAddAction(t, function UpdateBuildingStats)

    call TimerStart(CreateTimer(), 5., true, function BrazierUpgrade)
endfunction


endscope