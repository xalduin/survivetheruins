scope BuilderArmorUpgrade initializer Init


globals    
    private constant integer upgradeId = 'R002'
    
    private constant real hpMult = 1.
    private constant real armorBonus = 5.
endglobals

private function Main takes nothing returns nothing
 local player owner = GetOwningPlayer(GetTriggerUnit())
 local integer unitType = udg_role[GetPlayerId(owner) + 1]

    call AddUnitTypeHpMult(owner, unitType, hpMult)
    call AddUnitTypeArmorBonus(owner, unitType, armorBonus)
    call UnitStats_PlayerUpdate(owner)
    
 set owner = null
endfunction

//===========================================================================
private function Conditions takes nothing returns boolean
    return GetResearched() == upgradeId
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
endfunction


endscope