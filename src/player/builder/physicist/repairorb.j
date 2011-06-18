scope RepairOrb initializer Init
// requires GroupUtils, CommonFilters, MiscFunctions, BuildingMisc


globals
    private constant integer orbId = 'h00U'
    private constant integer orbId2 = 'h014'
    private constant integer orbId3 = 'h01F'
    
    private constant real updateRate = 1.
    private constant real repairRadius = 400.

    private constant integer maxLevel = 3
    
    private boolexpr repairFilter = null
    private boolexpr Filter_IsRepairOrb = null
    
    private group repairBuildings = CreateGroup()
endglobals

private function OrbLevel takes unit orb returns integer
 local integer id = GetUnitTypeId(orb)

    if id == orbId then
        return 1
    elseif id == orbId2 then
        return 2
    elseif id == orbId3 then
        return 3
    endif

    return 0
endfunction

// Library-specific filters

private function IsRepairOrb_Filter takes nothing returns boolean
    return OrbLevel(GetFilterUnit()) > 0 and not IsBuildingDisabled(GetFilterUnit())
endfunction

private function Filter_UnitHurt takes nothing returns boolean
    return GetUnitState(GetFilterUnit(), UNIT_STATE_LIFE) < GetUnitState(GetFilterUnit(), UNIT_STATE_MAX_LIFE)
endfunction

// Heal for 1% * orbLevel of target life unless:
//  if damage < 1% * orbLevel of life then heal damage amount
//  if mana < amount to be healed then heal amount = mana

private function HealAmount takes unit target, unit orb returns real
 local real targetMaxLife = GetUnitState(target, UNIT_STATE_MAX_LIFE)
 local real lifeDifference = targetMaxLife - GetWidgetLife(target)
 local real healAmount = RMinBJ(targetMaxLife * (.01 * I2R(OrbLevel(orb))), lifeDifference)
 
    return RMinBJ(healAmount, GetUnitState(orb, UNIT_STATE_MANA))
endfunction

// Largest possible heal able to be given by any orb
private function MaxPotentialHeal takes unit target returns real
 local real targetMaxLife = GetUnitState(target, UNIT_STATE_MAX_LIFE)
 local real lifeDifference = targetMaxLife - GetWidgetLife(target)
 
    return RMinBJ(targetMaxLife * (.01 * I2R(maxLevel)), lifeDifference)
endfunction

// Gets all damaged buildings near repair orbs and
// Places them in the <repairBuildings> group
private function EnumRepairableBuildings takes nothing returns nothing
 local unit orb = GetEnumUnit()
 local group temp = CreateGroup()

    set filterPlayer = GetOwningPlayer(orb)
    call GroupEnumUnitsInRange(temp, GetUnitX(orb), GetUnitY(orb), repairRadius, repairFilter)
    call GroupAddGroup(temp, repairBuildings)
    
    call DestroyGroup(temp)

 set orb = null
 set temp = null
endfunction

private function RepairBuildings takes nothing returns nothing
 local unit structure = GetEnumUnit()
 local real maxHeal = MaxPotentialHeal(structure)
 
 local unit orb
 local real heal
 
 local unit chosenOrb = null
 local real chosenHeal = 0.

    call GroupClear(ENUM_GROUP)
    call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(structure), GetUnitY(structure), repairRadius, Filter_IsRepairOrb)

    // Basically search for the "best" orb in range to heal the structure
    // "Best" meaning the highest heal amount
    // If the heal amount of a given orb is equal to the max potential heal
    // then we can exit early and use that orb
    loop
        set orb = FirstOfGroup(ENUM_GROUP)
        exitwhen orb == null
        
        set heal = HealAmount(structure, orb)

        if heal >= MaxPotentialHeal(structure) then
            set chosenOrb = orb
            set chosenHeal = heal
            exitwhen true
        endif
        
        if heal > chosenHeal then
            set chosenOrb = orb
            set chosenHeal = heal
        endif
        
        call GroupRemoveUnit(ENUM_GROUP, orb)
    endloop
    
    if chosenHeal > 0. then
        call UnitAddLife(structure, chosenHeal)
        call UnitAddMana(chosenOrb, -chosenHeal)
    endif
    
 set structure = null
 set orb = null
 set chosenOrb = null
endfunction
    
private function RepairMain takes nothing returns nothing
    call GroupClear(repairBuildings)
    call GroupClear(ENUM_GROUP)

    call GroupEnumUnitsInRect(ENUM_GROUP, bj_mapInitialPlayableArea, Filter_IsRepairOrb)
    call ForGroup(ENUM_GROUP, function EnumRepairableBuildings)
    call GroupClear(ENUM_GROUP)
    
    call ForGroup(repairBuildings, function RepairBuildings)
    call GroupClear(repairBuildings)
endfunction

private function Init takes nothing returns nothing
    set repairFilter = And( Filter(function Filter_UnitHurt), Filter_IsUnitStructure )
    set Filter_IsRepairOrb = Filter(function IsRepairOrb_Filter)
    call TimerStart(CreateTimer(), updateRate, true, function RepairMain)
endfunction


endscope