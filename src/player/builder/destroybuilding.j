scope DestroyBuilding initializer Init


globals
    private constant integer abilityId = 'A010'
endglobals

private function Main takes nothing returns nothing
    call KillUnit(GetTriggerUnit())
endfunction

private function OnEnterMap takes unit whichUnit returns nothing
    if IsUnitType(whichUnit, UNIT_TYPE_STRUCTURE) == true and GetPlayerId(GetOwningPlayer(whichUnit)) < 10 then
        call UnitAddAbility(whichUnit, abilityId)
        call UnitMakeAbilityPermanent(whichUnit, true, abilityId)
    endif
endfunction

private function Init takes nothing returns nothing
    call Ability_OnEffect(abilityId, function Main)
    call OnUnitIndexed(OnEnterMap)
endfunction


endscope