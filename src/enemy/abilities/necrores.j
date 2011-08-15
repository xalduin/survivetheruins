scope NecroRes initializer Init


globals
    private constant integer necroId = 'u007'
    private constant integer skeletonId = 'u00I'
    
    private constant real reviveRadius = 600.
    private constant real manaCost = 75.
    private constant string reviveSFX = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
    
    private boolexpr Filter_IsNecroWithMana = null
endglobals

private function IsNecroWithMana_Filter takes nothing returns boolean
    set bj_lastCreatedUnit = GetFilterUnit()
 
    if GetUnitTypeId(bj_lastCreatedUnit) != necroId then
        return false
    elseif GetUnitState(bj_lastCreatedUnit, UNIT_STATE_MANA) < manaCost then
        return false
    elseif GetWidgetLife(bj_lastCreatedUnit) <= 0 then
        return false
    endif
    
    return not IsUnitSilenced(bj_lastCreatedUnit)
endfunction

private function Main takes nothing returns nothing
 local unit killed = GetTriggerUnit()
 local unit necro
 local real x = GetUnitX(killed)
 local real y = GetUnitY(killed)
 
    call GroupClear(ENUM_GROUP)
    call GroupEnumUnitsInRange(ENUM_GROUP, x, y, reviveRadius, Filter_IsNecroWithMana)
    
    set necro = FirstOfGroup(ENUM_GROUP)
    if necro != null then
        call UnitAddMana(necro, -manaCost)
        call CreateUnit(GetOwningPlayer(necro), skeletonId, x, y, 0.)
        call DestroyEffect(AddSpecialEffect(reviveSFX, x, y))
    endif
    
    call GroupClear(ENUM_GROUP)
    
 set killed = null
 set necro = null
endfunction

private function Conditions takes nothing returns boolean
 local integer unitType = GetUnitTypeId(GetTriggerUnit())
    return GetOwningPlayer(GetTriggerUnit()) == Player(11) and unitType != skeletonId and unitType != XE_DUMMY_UNITID
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
    
    call Preload(reviveSFX)
    set Filter_IsNecroWithMana = Filter(function IsNecroWithMana_Filter)
    
 set t = null
endfunction


endscope