library JailRescue requires RevivePlayer, StatsBoards


globals
	constant integer SOUL_ID = 'h007'
	private boolexpr SOUL_FILTER = null
	private constant string SAVE_SFX = ""
endglobals

private function SoulFilter takes nothing returns boolean
	return GetUnitTypeId(GetFilterUnit()) == 'h007'
endfunction

private function Main takes nothing returns nothing
 local group temp = CreateGroup()
 local unit picked = null
 local integer saveCount = 0

 	call GroupEnumUnitsInRect(temp, udg_SaveRegion, SOUL_FILTER)
 
 	loop
 		set picked = FirstOfGroup(temp)
 		exitwhen picked == null
 		
 		set saveCount = saveCount + 1
 		
 		call RevivePlayer(GetOwningPlayer(picked))
 		call GroupRemoveUnit(temp, picked)
 		call RemoveUnit(picked)
 	endloop
 	
 	if saveCount > 0 then
 		call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., "|cffffcc00Rescue:|r The captured souls have been freed!")
 		call DestroyEffect(AddSpecialEffect(SAVE_SFX, GetRectCenterX(udg_SaveRegion), GetRectCenterY(udg_SaveRegion)))
 		
 		set picked = GetTriggerUnit()
 		call PlayerStats_AddSaves(GetOwningPlayer(picked), saveCount)
 		call SetUnitX(picked, GetRectCenterX(udg_ReviveRegion))
 		call SetUnitY(picked, GetRectCenterY(udg_ReviveRegion))
 	endif
 	
  	call DestroyGroup(temp)
  	
   set picked = null
   set temp = null
endfunction


private function Conditions takes nothing returns boolean
	return GetUnitAbilityLevel(GetTriggerUnit(), REVIVE_ABILITY_ID) > 0
endfunction

public function Init takes rect whichRect returns nothing
 local trigger t = CreateTrigger()
 
 	call TriggerRegisterEnterRectSimple(t, whichRect)
 	call TriggerAddCondition(t, Condition(function Conditions))
 	call TriggerAddAction(t, function Main)
 	
 	set SOUL_FILTER = Filter(function SoulFilter)
endfunction


endlibrary