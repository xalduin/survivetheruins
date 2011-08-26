library TankMisc initializer Init requires MiscFunctions, Rawcode


globals
    private constant integer goldRefund = 30
    private constant integer cancelOrderId = 851976
endglobals

function IsUnitTank takes unit whichUnit returns boolean
 local integer id = GetUnitTypeId(whichUnit)
	return id == Rawcode_UNIT_TANK or				/*
 	*/	   id == Rawcode_UNIT_BATTLE_TANK or		/*
 	*/	   id == Rawcode_UNIT_SIEGE_TANK or			/*
 	*/	   id == Rawcode_UNIT_ASSAULT_TANK or		/*
 	*/	   id == Rawcode_UNIT_ONSLAUGHT_TANK
endfunction

private function TankFilter takes nothing returns boolean
	return IsUnitTank(GetFilterUnit()) and IsUnitAliveBJ(GetFilterUnit())
endfunction

// Sets the correct tanks allowed to be built
// If a tank is already on the map, do nothing

function EnableTank takes player whichPlayer returns nothing
 local unit tank
 local integer siegeTankLevel
 local integer battleTankLevel

	call GroupEnumUnitsOfPlayer(ENUM_GROUP, whichPlayer, Filter(function TankFilter))
	
	if CountUnitsInGroup(ENUM_GROUP) > 1 then
		call Debug_Message("tank", I2S(CountUnitsInGroup(ENUM_GROUP)) + " tanks found for: " + GetPlayerName(whichPlayer))
	endif
	
	set tank = FirstOfGroup(ENUM_GROUP)
	call GroupClear(ENUM_GROUP)
	
	if tank != null then
		set tank = null
		return
	endif

	set siegeTankLevel = GetPlayerTechCount(whichPlayer, Rawcode_RESEARCH_SIEGE_TANK, true)
	set battleTankLevel = GetPlayerTechCount(whichPlayer, Rawcode_RESEARCH_BATTLE_TANK, true)
	
	if siegeTankLevel > battleTankLevel then
		if siegeTankLevel == 2 then
			call SetPlayerTechMaxAllowed(whichPlayer, Rawcode_UNIT_ONSLAUGHT_TANK, 1)
		else
			call SetPlayerTechMaxAllowed(whichPlayer, Rawcode_UNIT_SIEGE_TANK, 1)
		endif
	else
		if battleTankLevel == 2 then
			call SetPlayerTechMaxAllowed(whichPlayer, Rawcode_UNIT_ASSAULT_TANK, 1)
		elseif battleTankLevel == 1 then
			call SetPlayerTechMaxAllowed(whichPlayer, Rawcode_UNIT_BATTLE_TANK, 1)
		else
			call SetPlayerTechMaxAllowed(whichPlayer, Rawcode_UNIT_TANK, 1)
		endif
	endif
endfunction

//=======================================
// Tank cancelled while building
//=======================================

private function Cancel_Main takes nothing returns nothing
    call RemoveUnit_Safe(GetTriggerUnit())
    call AdjustPlayerStateSimpleBJ(GetOwningPlayer(GetTriggerUnit()), PLAYER_STATE_RESOURCE_GOLD, goldRefund)
endfunction

private function Cancel_Condition takes nothing returns boolean
 	return GetIssuedOrderId() == cancelOrderId and IsUnitTank(GetTriggerUnit())
endfunction

//========================================

private function EnableTank_OnDeath takes nothing returns nothing
	call EnableTank(GetOwningPlayer(GetTriggerUnit()))
endfunction

private function IsUnitTank_Condition takes nothing returns boolean
	return IsUnitTank(GetTriggerUnit())
endfunction

//=========================================

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    call TriggerAddCondition(t, Condition(function Cancel_Condition))
    call TriggerAddAction(t, function Cancel_Main)
    
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddCondition(t, Condition(function IsUnitTank_Condition))
    call TriggerAddAction(t, function EnableTank_OnDeath)

 set t = null
endfunction


endlibrary