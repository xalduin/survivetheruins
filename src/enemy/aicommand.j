library AICommand initializer Init requires MiscFunctions, NecroSpell, DarkDisciple, GroupUtils, Lich


globals
    boolexpr targetFilter = null
endglobals


function TargetFilter takes nothing returns boolean
 local boolean cond = GetWidgetLife(GetFilterUnit()) > .405
    set cond = cond and IsUnitEnemy(GetFilterUnit(), Player(11))
    set cond = cond and IsUnitType(GetFilterUnit(), UNIT_TYPE_UNDEAD) == false 
    return cond
endfunction

function CheckCurrentOrder takes unit spawn returns boolean
 local integer order = GetUnitCurrentOrder(spawn)
 local boolean result = order != OrderId("attack")
 
    set result = result and order != OrderId("heal")
    set result = result and order != OrderId("replenishlife")
    set result = result and order != OrderId("healingwave")
 
    return result
endfunction

function AquireTarget takes unit whichUnit returns unit
    call GroupClear(ENUM_GROUP)
    call GroupEnumUnitsInRect(ENUM_GROUP, bj_mapInitialPlayableArea, targetFilter)
    
    set bj_lastCreatedUnit = GroupPickRandomUnit(ENUM_GROUP)
    call GroupClear(ENUM_GROUP)
    return bj_lastCreatedUnit
endfunction

function AICommand takes nothing returns nothing
 local unit spawn = GetEnumUnit()
 local integer spawnId = GetUnitId(spawn)
 local SpawnData data = SpawnData[spawnId]
 local unit target = data.target
 local real targetX = data.targetx
 local real targetY = data.targety
 
    if target == null or GetWidgetLife(target) <= .405 then
        set target = AquireTarget(spawn)
        set data.target = target

        set targetX = GetUnitX(target)
        set targetY = GetUnitY(target)
        
        call IssuePointOrder(spawn, "attack", targetX, targetY)
        set data.targetx = targetX
        set data.targety = targetY
        set data.aquired = true
    else
        set data.aquired = false
    endif
    
    if DistanceBetweenCoords(targetX, targetY, GetUnitX(target), GetUnitY(target)) > 1000. or CheckCurrentOrder(spawn) then
        set targetX = GetUnitX(target)
        set targetY = GetUnitY(target)
    
        call IssuePointOrder(spawn, "attack", targetX, targetY)
        set data.targetx = targetX
        set data.targety = targetY
    endif
    
    // Necro-specific order
    if GetUnitTypeId(spawn) == 'u007' then
        call DoNecroSpell(spawn)
    endif
    
    // Dark Disciple-specific order
    if GetUnitTypeId(spawn) == discipleId then
        call DoDiscipleSpell(spawn)
    endif
    
    // Lich specific orders
    if IsUnit(spawn, Lich) then
        call Lich_HandleOrders()
    endif
    
 set spawn = null
 set target = null
endfunction

private function Init takes nothing returns nothing
    set targetFilter = Filter(function TargetFilter)
endfunction


endlibrary