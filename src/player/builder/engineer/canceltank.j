library CancelTank initializer Init requires MiscFunctions


globals
    private constant integer goldRefund = 30
    private constant integer tankId = 'h00M'
    private constant integer btankId = 'h010'
    private constant integer stankId = 'h00Z'
    private constant integer mobwsId = 'h012'
    private constant integer cancelOrderId = 851976
endglobals

private function Main takes nothing returns nothing
    call RemoveUnit_Safe(GetTriggerUnit())
    call AdjustPlayerStateSimpleBJ(GetOwningPlayer(GetTriggerUnit()), PLAYER_STATE_RESOURCE_GOLD, goldRefund)
endfunction

private function Conditions takes nothing returns boolean
 local integer id = GetUnitTypeId(GetTriggerUnit())
    return GetIssuedOrderId() == cancelOrderId and (id == tankId or id == btankId or id == stankId or id == mobwsId)
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)

 set t = null
endfunction


endlibrary