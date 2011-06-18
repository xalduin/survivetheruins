// Misc functions for dealing with units

library UnitUtils

function CountUnitsInRange takes real x, real y, real range, boolexpr filter returns integer
 local group units = CreateGroup()
 local unit temp
 local integer numUnits = 0

    call GroupEnumUnitsInRange(units, x, y, range, filter)

    loop
        set temp = FirstOfGroup(units)
        exitwhen temp == null

        set numUnits = numUnits + 1

        call GroupRemoveUnit(units, temp)
    endloop

    call DestroyGroup(units)

 set units = null
 set temp = null

    return numUnits
endfunction

function RemoveUnit_Safe takes unit u returns nothing
    call ShowUnit(u, false)
    call SetUnitExploded(u, true)
    call KillUnit(u)
endfunction

function IsUnitDead takes unit u returns boolean
    return GetWidgetLife(u) <= .405
endfunction

function AngleBetweenUnits takes unit source, unit target returns real
    return bj_RADTODEG * Atan2(GetUnitY(target) - GetUnitY(source), GetUnitX(target) - GetUnitX(source))
endfunction

function UnitAddMana takes unit u, real mana returns nothing
 local real maxMana = GetUnitState(u, UNIT_STATE_MAX_MANA)
    call SetUnitState(u, UNIT_STATE_MANA, RMaxBJ(RMinBJ(GetUnitState(u, UNIT_STATE_MANA) + mana, maxMana), 0.))
endfunction

function UnitAddLife takes unit u, real life returns nothing
    call SetWidgetLife(u, RMaxBJ(RMinBJ(GetWidgetLife(u) + life, GetUnitState(u, UNIT_STATE_MAX_LIFE)), 0.))
endfunction

function IsUnitSilenced takes unit u returns boolean
    return GetUnitAbilityLevel(u, 'BNsi') > 0
endfunction

globals
    private unit pickedUnit = null
    private real pickedDistance = -1
    private real pickedX
    private real pickedY
endglobals

private function NearestUnit_Callback takes nothing returns nothing
 local unit picked = GetEnumUnit()
 local real dx = GetUnitX(picked) - pickedX
 local real dy = GetUnitY(picked) - pickedY
 local real distance = SquareRoot(dx*dx + dy*dy)
 
    if distance < pickedDistance or pickedDistance == -1 then
        set pickedDistance = distance
        set pickedUnit = picked
    endif

 set picked = null
endfunction

function GetNearestUnitInGroup takes group g, real x, real y returns unit
    set pickedUnit = null
    set pickedDistance = -1.
    set pickedX = x
    set pickedY = y

    call ForGroup(g, function NearestUnit_Callback)

    return pickedUnit
endfunction


endlibrary