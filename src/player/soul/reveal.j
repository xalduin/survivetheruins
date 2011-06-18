library Reveal initializer Init requires AbilityOnEffect, MiscFunctions


globals
    private integer abilityId = 'A006'
    private integer revealSpell = 'A00L'
    private real revealRadius = 800.
endglobals

private function Main takes nothing returns nothing
 local unit caster = GetTriggerUnit()
 local unit dummy
 //local location target = GetSpellTargetLoc()
 local real x = GetSpellTargetX()
 local real y = GetSpellTargetY()
 
    if x < GetRectMinX(udg_VisibilityRegion) + revealRadius or x > GetRectMaxX(udg_VisibilityRegion) - revealRadius then
        call UnitRemoveAbility(caster, abilityId)
        call UnitAddAbility(caster, abilityId)

    elseif y < GetRectMinY(udg_VisibilityRegion) + revealRadius or y > GetRectMaxY(udg_VisibilityRegion) - revealRadius then
        call UnitRemoveAbility(caster, abilityId)
        call UnitAddAbility(caster, abilityId)
    
    else
        set dummy = CreateUnit(GetOwningPlayer(caster), XE_DUMMY_UNITID, x,y, 0.)
        call UnitAddAbility(dummy, revealSpell)
        call IssuePointOrder(dummy, "farsight", x, y)
        call UnitApplyTimedLife(dummy, 'BTLF', 3.)
    endif
    
    //call RemoveLocation(target)
    
 set caster = null
 //set target = null
 set dummy = null
endfunction

private function Init takes nothing returns nothing
    call Ability_OnEffect(abilityId, function Main)
    call PreloadAbility(revealSpell)
endfunction


endlibrary