library BuildingMisc initializer Init requires Table, AutoIndex


globals
    private constant integer freezingBreathBuffId = 'Bfrz'
    HandleTable buildingTable = 0
endglobals

// Disabled = under construction or frozen by something (frost wyrm)

function IsBuildingDisabled takes unit building returns boolean
    return (not buildingTable.exists(building)) or GetUnitAbilityLevel(building, freezingBreathBuffId) > 0
endfunction

//============================================================================
// "Enables" building, basically means it's not under construction in some way
//============================================================================

private function EnableBuilding takes unit whichUnit returns nothing
	set buildingTable[whichUnit] = 1
endfunction

private function EnableBuilding_Constructed takes nothing returns nothing
	call EnableBuilding(GetConstructedStructure())
endfunction
private function EnableBuilding_Upgraded takes nothing returns nothing
	call EnableBuilding(GetTriggerUnit())
endfunction

//==================================================
// "Disables", upgrading, being constructed, or dead
//==================================================

private function DisableBuilding takes unit whichUnit returns nothing
	call buildingTable.flush(whichUnit)
endfunction

private function DisableBuilding_Upgrade takes nothing returns nothing
	call DisableBuilding(GetTriggerUnit())
endfunction

//=====================================================

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH)
 	call TriggerAddAction(t, function EnableBuilding_Constructed)
 	
 	set t = CreateTrigger()
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_CANCEL)
 	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH)
	call TriggerAddAction(t, function EnableBuilding_Upgraded)
	
	
	//===
	
	set t = CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_START)
	call TriggerAddAction(t, function DisableBuilding_Upgrade)

	call OnUnitDeindexed(DisableBuilding)

	//====
	
	set buildingTable = HandleTable.create()
endfunction


endlibrary