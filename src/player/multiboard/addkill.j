scope AddKill initializer Init


private function Main takes nothing returns nothing
    call PlayerStats_AddKill(GetOwningPlayer(GetKillingUnit()))
endfunction

//===========================================================================
private function Conditions takes nothing returns boolean
    return IsPlayerAlly(GetOwningPlayer(GetKillingUnit()), Player(0)) and IsPlayerEnemy(GetOwningPlayer(GetTriggerUnit()), Player(0))
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
endfunction


endscope