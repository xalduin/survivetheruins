// ==================================================================================
// LineSegment - by Ammorth, Feb 13, 2010 - rev5
// 
// This script, and myself, can be found at wc3c.net
//
// Used to determine certain things about segments, involving units and geometry.
//
// Requirements:
//   - vJass
//   - optional: xebasic - by Vexorian ( [url]http://www.wc3c.net/showthread.php?t=101150[/url] )
//     will use XE_MAX_COLLISION_SIZE if xebasic is present, otherwise it will ignore it.
//
// Installation:
//   - Create a new trigger called LineSegments and convert it to custom text
//   - Copy the code to the new trigger, replacing everything
//
// How To Use:
//   - call GetNearestPointOnSegment(Ax, Ay, Bx, By, Cx, Cy) to get the nearest point on
//     the line segment AB to point C (returns a location)
//   - call GetDistanceFromSegment(Ax, Ay, Bx, By, Cx, Cy) to get the distance from the
//     line segment AB to a given point C
//   - call GroupEnumUnitsInRangeOfSegment(whichgroup, Ax, Ay, Bx, By, distance, filter) to
//     add all of the units within distance of segment AB to whichgroup, according to the filter.
//   - call IsUnitInRangeOfSegment(unit, Ax, Ay, Bx, By, distance) to see if the unit givin is
//     within distance of segment AB
//   - xebasic is no longer required, but if avaliable, will return correct results with
//     GroupEnumUnitsInRangeOfSegment() using XE_MAX_COLLISION_SIZE.
//
// Notes:
//   - All functions have a location version wrappers incase you would rather pass locations
//     They are named as follows:
//         > GetNearestPointOnSegmentLoc()
//         > GetDistanceFromSegmentLoc()
//         > GroupEnumUnitsInRangeOfSegmentLoc()
//         > IsUnitInRangeOfSegmentLoc()
//
// ==================================================================================
library LineSegment requires optional xebasic
globals
    private group udg_LineTempGroup = CreateGroup()
endglobals

// with optionals we can add/improve features if other libraries are present
// this should in-line with an optimizer, since the static if makes it constant
private constant function xebasic_wrapper takes nothing returns real
    static if LIBRARY_xebasic then
        return XE_MAX_COLLISION_SIZE
    else
        return 0.0
    endif
endfunction

function GetNearestPointOnSegment takes real Ax, real Ay, real Bx, real By, real Cx, real Cy returns location
    local real r
    // could use a point struct here if you really wanted, instead of a location.
    local real dx = Bx-Ax
    local real dy = By-Ay
    local real L = ((dx)*(dx) + (dy)*(dy)) // Get quasi length
    if L == 0 then // seg is actually a point so lets return the point
        return Location(Ax, Ay)
    endif
    set r = ((Cx-Ax)*(dx) + (Cy-Ay)*(dy))/(L) // get the ratio
    if r > 1 then // closests point is past seg, so return end point B
        return Location(Bx, By)
    elseif r < 0 then // same as B, but at A instead
        return Location(Ax, Ay)
    endif // In the middle of A and B so use the ratio to find the point
    return Location(Ax+r*(dx), Ay+r*(dy))
endfunction
function GetNearestPointOnSegmentLoc takes location A, location B, location C returns location
    return GetNearestPointOnSegment(GetLocationX(A), GetLocationY(A), GetLocationX(B), GetLocationY(B), GetLocationX(C), GetLocationY(C))
endfunction


function GetDistanceFromSegment takes real Ax, real Ay, real Bx, real By, real Cx, real Cy returns real
    local real r
    local real dx = Bx-Ax
    local real dy = By-Ay
    local real L = ((dx)*(dx) + (dy)*(dy)) // Get quasi length
    if L == 0 then // seg is actually a point so lets return the distance to the point
        return SquareRoot((Cx-Ax)*(Cx-Ax)+(Cy-Ay)*(Cy-Ay))
    endif
    set r = ((Cx-Ax)*(dx) + (Cy-Ay)*(dy))/(L) // get the ratio
    if r > 1 then // closests point is past seg, so return distance to point B
        return SquareRoot((Cx-Bx)*(Cx-Bx)+(Cy-By)*(Cy-By))
    elseif r < 0 then // same as B, but at A instead
        return SquareRoot((Cx-Ax)*(Cx-Ax)+(Cy-Ay)*(Cy-Ay))
    endif // In the middle of A and B so use the ratio to find the point
    set Ax = Ax+r*(dx)
    set Ay = Ay+r*(dy)
    return SquareRoot((Cx-Ax)*(Cx-Ax)+(Cy-Ay)*(Cy-Ay))
endfunction
function GetDistanceFromSegmentLoc takes location A, location B, location C returns real
    return GetDistanceFromSegment(GetLocationX(A), GetLocationY(A), GetLocationX(B), GetLocationY(B), GetLocationX(C), GetLocationY(C))
endfunction

function GroupEnumUnitsInRangeOfSegment takes group whichgroup, real Ax, real Ay, real Bx, real By, real distance, boolexpr filter returns nothing
    local real dx = Bx-Ax
    local real dy = By-Ay
    local real L = ((dx)*(dx) + (dy)*(dy)) // Get quasi length
    local real r = SquareRoot(dx*dx+dy*dy)/2+distance + xebasic_wrapper() // double-purpose for r
    local unit u
    call GroupClear(udg_LineTempGroup)
    call GroupEnumUnitsInRange(udg_LineTempGroup, Ax+(dx/2), Ay+(dy/2), r, filter)
    loop
        set u = FirstOfGroup(udg_LineTempGroup)
        exitwhen u == null
        if L == 0 and IsUnitInRangeXY(u, Ax, Ay, distance) then // seg is actually a point so lets return the point
            call GroupAddUnit(whichgroup, u)
        else
            set r = ((GetUnitX(u)-Ax)*(dx) + (GetUnitY(u)-Ay)*(dy))/(L) // get the ratio
            if r > 1 then // split if/thens so that it exists properly
                if IsUnitInRangeXY(u, Bx, By, distance) then // closests point is past seg, so return end point B
                    call GroupAddUnit(whichgroup, u)
                endif
            elseif r < 0 then
                if IsUnitInRangeXY(u, Ax, Ay, distance) then // same as B, but at A instead
                    call GroupAddUnit(whichgroup, u)
                endif
            elseif IsUnitInRangeXY(u, Ax+r*(dx), Ay+r*(dy), distance) then // In the middle of A and B so use the ratio to find the point
                call GroupAddUnit(whichgroup, u)
            endif
        endif
        call GroupRemoveUnit(udg_LineTempGroup, u)
    endloop
    set u = null    
endfunction
function GroupEnumUnitsInRangeOfSegmentLoc takes group whichgroup, location A, location B, real distance, boolexpr filter returns nothing
    call GroupEnumUnitsInRangeOfSegment(whichgroup, GetLocationX(A), GetLocationY(A), GetLocationX(B), GetLocationY(B), distance, filter)
endfunction

function IsUnitInRangeOfSegment takes unit u, real Ax, real Ay, real Bx, real By, real distance returns boolean
    local real r
    local real dx = Bx-Ax
    local real dy = By-Ay
    local real L = ((dx)*(dx) + (dy)*(dy)) // Get quasi length
    if L == 0 then // seg is actually a point so lets return the point
        return IsUnitInRangeXY(u, Ax, Ay, distance)
    endif
    set r = ((GetUnitX(u)-Ax)*(dx) + (GetUnitY(u)-Ay)*(dy))/(L) // get the ratio
    if r > 1 then // closests point is past seg, so return end point B
        return IsUnitInRangeXY(u, Bx, By, distance)
    elseif r < 0 then // same as B, but at A instead
        return IsUnitInRangeXY(u, Ax, Ay, distance)
    endif // In the middle of A and B so use the ratio to find the point
    return IsUnitInRangeXY(u, Ax+r*(dx), Ay+r*(dy), distance)
endfunction
function IsUnitInRangeOfSegmentLoc takes unit u, location A, location B, real distance returns boolean
    return IsUnitInRangeOfSegment(u, GetLocationX(A), GetLocationY(A), GetLocationX(B), GetLocationY(B), distance)
endfunction

endlibrary