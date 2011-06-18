library SpawnMovement initializer Init requires Table


globals
    private HandleTable MovePoints
endglobals

private function Init takes nothing returns nothing
    set MovePoints = HandleTable.create()
endfunction

function GetMovePoint takes unit whichUnit returns integer
    if MovePoints.exists(whichUnit) then
        return MovePoints[whichUnit]
    else
        return -1
    endif
endfunction

function SetMovePoint takes unit whichUnit, integer point returns nothing
    set MovePoints[whichUnit] = point
endfunction

function ClearMovePoint takes unit whichUnit returns nothing
    if MovePoints.exists(whichUnit) then
        call MovePoints.flush(whichUnit)
    endif
endfunction


endlibrary

// TextMacros for movement setup

//! textmacro MovementStart takes NAME, UNITTYPE
library Movement$NAME$ initializer Setup requires MiscFunctions, SpawnMovement
globals
    private integer RectCount
    private rect array Rects
    private region Region
endglobals

private function MoveConditions takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit())== '$UNITTYPE$'
endfunction

private function UnitMovement takes nothing returns nothing
 local unit spawn = GetTriggerUnit()
 local integer movePoint = GetMovePoint(spawn) + 1
 local rect temp
 
    if movePoint == 0 then
        set movePoint = 1
    endif
 
    // If there are more movepoints, order to move to the next one
    // Else, remove unit
    if movePoint < RectCount then
        call SetMovePoint(spawn, movePoint)

        set temp = Rects[movePoint]
        call IssuePointOrder(spawn, "move", GetRectCenterX(temp), GetRectCenterY(temp))
    else
        call ClearMovePoint(spawn)
        call RemoveUnit_Safe(spawn)
    endif
    
 set spawn = null
 set temp = null
endfunction
        

private function Setup takes nothing returns nothing
 local trigger t = CreateTrigger()
 
    set RectCount = 0
    set Region = CreateRegion()
//! endtextmacro

//! textmacro AddPoint takes REGION
    set Rects[RectCount] = $REGION$
    set RectCount = RectCount + 1
    call RegionAddRect(Region, $REGION$)
//! endtextmacro

//! textmacro MovementEnd
    call TriggerRegisterEnterRegion(t, Region, null)
    call TriggerAddCondition(t, Condition(function MoveConditions))
    call TriggerAddAction(t, function UnitMovement)
endfunction
endlibrary
//! endtextmacro