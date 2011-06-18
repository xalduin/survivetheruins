library SelectRole initializer Init requires Table, SetResearch, AbilityOnEffect


globals
	integer array playerRole

    private integer array currentSelection
    private constant integer abilityId = 'A00I'
    private constant integer randomAbilityId = 'A027'
    private Table RoleTable
    
    private boolexpr pickFilter = null
    
    private constant integer soulId = 'e000'
    private constant integer saveSoulAbilityId = 'A003'
endglobals

private struct RoleInfo
    string role
    string description
endstruct

private function DisplayRoleInfo takes player who, unit target, integer unitType returns nothing
 local RoleInfo info = RoleTable[unitType]

    static if DEBUG_MODE then
        if not RoleTable.exists(unitType) then
            call Error("DisplayRoleInfo", "Unit type not found!")
            return
        endif
    endif
    
    if GetLocalPlayer() == who then
        call ClearTextMessages()
    endif
    call DisplayTextToPlayer(who, 0., 0., "|cffffcc00Name:|r " + GetUnitName(target))
    call DisplayTextToPlayer(who, 0., 0., "|cffffcc00Role:|r " + info.role)
    call DisplayTextToPlayer(who, 0., 0., "|cffffcc00Info:|r " + info.description)
endfunction

private function Main takes nothing returns nothing
 local unit target = GetSpellTargetUnit()
 local integer targetId = GetUnitTypeId(target)
 local unit caster
 local player owner
 
    if GetOwningPlayer(target) != Player(15) then
        set target = null
        return
    endif
    
    set caster = GetTriggerUnit()
    set owner = GetOwningPlayer(caster)

    if targetId == currentSelection[GetPlayerId(owner)] then
        set target = CreateUnit(owner, GetUnitTypeId(target), GetUnitX(caster), GetUnitY(caster), 270.)
        call RemoveUnit(caster)
        
        set udg_role[GetPlayerId(owner) + 1] = GetUnitTypeId(target)  //Deprecated as of now
        set playerRole[GetPlayerId(owner)] = GetUnitTypeId(target)

        if GetLocalPlayer() == owner then
            call SelectUnit(target, true)
        endif

        call BuilderSetResearch(target)
        call GroupAddUnit(enemies, target)
    else
        set currentSelection[GetPlayerId(owner)] = targetId
        call DisplayRoleInfo(owner, target, targetId)
    endif

 set target = null
 set caster = null
 set owner = null
endfunction

//============
// Random pick
//============

function RandomHero takes nothing returns integer
 local group temp = CreateGroup()
 
    call GroupEnumUnitsInRect(temp, bj_mapInitialPlayableArea, pickFilter)
    set bj_lastCreatedUnit = GroupPickRandomUnit(temp)

    call DestroyGroup(temp)
    set temp = null
    return GetUnitTypeId(bj_lastCreatedUnit)
endfunction

function DoRandomHero takes unit soul returns nothing
 local player owner = GetOwningPlayer(soul)
 local integer unitId = RandomHero()
 local real x = GetUnitX(soul)
 local real y = GetUnitY(soul)
 local unit hero = CreateUnit(owner, unitId, x, y, 90.)
 
 	set udg_role[GetPlayerId(owner) + 1] = unitId	//Deprecated
 	set playerRole[GetPlayerId(owner)] = unitId
 	
 	if GetLocalPlayer() == owner then
 		call SelectUnit(hero, true)
 		call PanCameraTo(x, y)
 	endif
 
 	call GroupAddUnit(enemies, hero)
 	call BuilderSetResearch(hero)
 	call RemoveUnit(soul)
 
  set owner = null
  set hero = null
endfunction

private function RandomMain takes nothing returns nothing
 	call DoRandomHero(GetTriggerUnit())
endfunction

//=======
//Start
//=======

private function CreateSelectionUnits takes nothing returns nothing
 local player owner = GetEnumPlayer()
 local real x = GetRectCenterX(gg_rct_PickingWispSpawn)
 local real y = GetRectCenterY(gg_rct_PickingWispSpawn)
 local unit picker = CreateUnit(owner, 'e000', x, y, 0.)
 
 	call ResetResearch(owner)
 	call SetTechAllowed(owner)
 	if GetLocalPlayer() == owner then
 		call PanCameraToTimed(x, y, 0.)
 		call SelectUnit(picker, true)
 	endif
 	
  set owner = null
  set picker = null
endfunction
 	

private function PlayingFilter takes nothing returns boolean
 local boolean result = GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING
 	return result and GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER
 endfunction

function SelectionStart takes nothing returns nothing
 local force temp = CreateForce()
 	call ForceEnumPlayers(temp, Filter(function PlayingFilter))
	call ForForce(temp, function CreateSelectionUnits)
	call DestroyForce(temp)
 set temp = null
endfunction

//=================
// Cleanup
//=================

//============
// No hero left behind
//============

private function PickRandomHero takes nothing returns nothing
	call DoRandomHero(GetEnumUnit())
endfunction

private function SoulFilter takes nothing returns boolean
	return GetUnitTypeId(GetFilterUnit()) == soulId
endfunction

//========
// Moving heroes
//========

private function MoveHeroes takes nothing returns nothing
	call SetUnitX(GetEnumUnit(), GetRectCenterX(gg_rct_EnterRuins))
	call SetUnitY(GetEnumUnit(), GetRectCenterY(gg_rct_EnterRuins))
endfunction

private function HeroFilter takes nothing returns boolean
	return GetUnitAbilityLevel(GetFilterUnit(), saveSoulAbilityId) > 0
endfunction

//=============
// Remove leftovers
//=============

private function RemoveUnits takes nothing returns nothing
	call RemoveUnit(GetEnumUnit())
endfunction
	
function CleanupSelectionArea takes nothing returns nothing
 local group temp = CreateGroup()
 local boolexpr filter = Filter(function SoulFilter)

	call GroupEnumUnitsInRect(temp, gg_rct_PickingArea, filter)
	call ForGroup(temp, function PickRandomHero)
	call GroupClear(temp)
	call DestroyBoolExpr(filter)
	
	set filter = Filter(function HeroFilter)
	
	call GroupEnumUnitsInRect(temp, gg_rct_PickingArea, filter)
	call ForGroup(temp, function MoveHeroes)
	call GroupClear(temp)
	call DestroyBoolExpr(filter)
	
	call GroupEnumUnitsInRect(temp, gg_rct_PickingArea, pickFilter)
	call ForGroup(temp, function RemoveUnits)
	call DestroyGroup(temp)
	call DestroyBoolExpr(pickFilter)
	
 set temp = null
 set pickFilter = null
 set filter = null
endfunction

//=======

private function AddRoleInfo takes integer unitType, string role, string description returns nothing
 local RoleInfo info = RoleInfo.create()
 
    set info.role = role
    set info.description = description
    
    static if DEBUG_MODE then
        if RoleTable.exists(unitType) then
            call Error("AddRoleInfo", "Role already in table!")
        endif
    endif
    
    set RoleTable[unitType] = info
endfunction

private function PickFilter takes nothing returns boolean
    return GetOwningPlayer(GetFilterUnit()) == Player(15) and GetUnitAbilityLevel(GetFilterUnit(), saveSoulAbilityId) > 0
endfunction

private function Init takes nothing returns nothing
    call Ability_OnEffect(abilityId, function Main)
    call Ability_OnEffect(randomAbilityId, function RandomMain)
    set RoleTable = Table.create()
    set pickFilter = Filter(function PickFilter)
    
    call AddRoleInfo('h006', "Builder", "Excels in dealing damage to large amounts of enemies, but lacks a solid source of physical damage.")
    call AddRoleInfo('h00L', "Builder", "All around good builder with buildings to suit every purpose.")
    call AddRoleInfo('h00R', "Builder", "Strong offensive structures, but buildings require a power supply to function.")
	call AddRoleInfo('o006', "Builder", "Strong all around builder, but lacks magic damage.")
endfunction


endlibrary