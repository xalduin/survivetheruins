library CancelWarStation initializer Init requires MiscFunctions, Rawcode


globals
    private constant integer goldRefund = 30
    private constant integer cancelOrderId = 851976
endglobals

private function Main takes nothing returns nothing
    call RemoveUnit_Safe(GetTriggerUnit())
    call AdjustPlayerStateSimpleBJ(GetOwningPlayer(GetTriggerUnit()), PLAYER_STATE_RESOURCE_GOLD, goldRefund)
endfunction

private function Conditions takes nothing returns boolean
 	return GetIssuedOrderId() == cancelOrderId and GetUnitTypeId(GetTriggerUnit()) == Rawcode_UNIT_MOBILE_WAR_STATION
 endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)

 set t = null
endfunction


endlibrary