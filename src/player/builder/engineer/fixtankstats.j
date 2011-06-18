scope FixTankStats initializer Init


globals
    private constant integer tankId = 'h00M'
    private constant integer lightningId = 'h00W'
endglobals

private struct UnitData
    unit u
endstruct

private function UpdateTankStats takes nothing returns nothing
 local timer expired = GetExpiredTimer()
 local UnitData data = GetTimerData(expired)
 
    call UnitStats_Update(data.u)
    call data.destroy()
    call ReleaseTimer(expired)
    
 set expired = null
endfunction

private function Main takes nothing returns nothing
 local timer t = NewTimerStart(.25, false, function UpdateTankStats)
 local UnitData data = UnitData.create()

    set data.u = GetConstructedStructure()
    call SetTimerData(t, data)

 set t = null
endfunction

//===========================================================================
private function Conditions takes nothing returns boolean
 local integer unitType = GetUnitTypeId(GetConstructedStructure())
    return unitType == tankId or unitType == lightningId
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH )
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
 set t = null
endfunction


endscope