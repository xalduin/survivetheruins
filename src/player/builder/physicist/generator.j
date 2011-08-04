scope ElectricGenerator initializer Init


globals
    private constant integer genId1 = 'h00T'
	private constant integer genOneMaxManaRestore = 30
	
    private constant integer genId2 = 'h015'
	private constant integer genTwoMaxManaRestore = 50
	
	private constant integer capacitorId = 'h018'
    private constant integer capacitorMaxManaRestore = 50
	
    private constant real updateRate = 1.

    private constant real generatorRadius = 900.
	private constant real capacitorRadius = 400.
    
    private boolexpr manaFilter = null
    private boolexpr Filter_IsUnitGenerator = null
    
    private group Structures = CreateGroup()
    private HandleTable manaTable
endglobals

private function Mana takes unit gen returns integer
 local integer id = GetUnitTypeId(gen)

    if id == genId1 then
        return genOneMaxManaRestore
    elseif id == genId2 then
        return genTwoMaxManaRestore
    elseif id == capacitorId then
		return RMinBJ(GetUnitState(gen, UNIT_STATE_MANA), capacitorMaxManaRestore)
	endif

    return 0
endfunction

private function Radius takes unit gen returns real
 local integer id = GetUnitTypeId(gen)
 
	if id == genId1 or id == genId2 then
		return generatorRadius
	elseif id == capacitorId then
		return capacitorRadius
	endif
	
	return 0.
endfunction

private function IsUnitGenerator_Filter takes nothing returns boolean
    return Mana(GetFilterUnit()) > 0 and not IsBuildingDisabled(GetFilterUnit())
endfunction

private function Filter_UnitHasMana takes nothing returns boolean
 local real maxMana = GetUnitState(GetFilterUnit(), UNIT_STATE_MAX_MANA)
    return maxMana > 0 and GetUnitState(GetFilterUnit(), UNIT_STATE_MANA) < maxMana
endfunction

private function GetAddedMana takes unit target, real mana returns integer
 local real maxMana = GetUnitState(target, UNIT_STATE_MAX_MANA)
 local real currentMana = GetUnitState(target, UNIT_STATE_MANA)

    return R2I( RMinBJ(mana, maxMana - currentMana) )
endfunction

private function GeneratorAddMana takes nothing returns nothing
 local unit generator = GetEnumUnit()
 local boolean isCapacitor = GetUnitTypeId(generator) == capacitorId
 
 local group temp = CreateGroup()
 local unit picked

 local integer count
 local real mana
 local integer addedMana

    set filterPlayer = GetOwningPlayer(generator)
    call GroupEnumUnitsInRange(temp, GetUnitX(generator), GetUnitY(generator), Radius(generator), Filter_CanRestoreMana)
    set count = CountUnitsInGroup(temp)
    
    // Amount of mana to be split amongst buildings
    if count > 0 then
        set mana = Mana(generator) / I2R(count)
    else
        set mana = 0
    endif
	
	if mana == 0 then
		call GroupClear(temp)
	endif
    
    loop
        set picked = FirstOfGroup(temp)
        exitwhen picked == null
        
        set addedMana = GetAddedMana(picked, mana)
        call UnitAddMana(picked, mana)

		if isCapacitor then
			call UnitAddMana(generator, -addedMana)
		endif
        
        set count = count - 1
        if addedMana < mana and count > 0 then
            set mana = mana + (mana - I2R(addedMana)) / I2R(count)
        endif
        
        // Add the structure to a group so that we can show the total overall mana given
        if addedMana > 0 then
            call GroupAddUnit(Structures, picked)
            set manaTable[picked] = manaTable[picked] + addedMana
        endif
        
        call GroupRemoveUnit(temp, picked)
    endloop
    
    call DestroyGroup(temp)

 set generator = null
 set picked = null
 set temp = null
endfunction

private function ShowAddedMana takes nothing returns nothing
 local unit picked = GetEnumUnit()
 local integer mana = manaTable[picked]
 
    call CreateTextTagEx("+" + I2S(mana), GetUnitX(picked), GetUnitY(picked), GetLocalPlayer() == GetOwningPlayer(picked), MB)
    call manaTable.flush(picked)
    
 set picked = null
endfunction

private function GeneratorMain takes nothing returns nothing
    call GroupClear(ENUM_GROUP)
    call GroupClear(Structures)

    call GroupEnumUnitsInRect(ENUM_GROUP, bj_mapInitialPlayableArea, Filter_IsUnitGenerator)
    call ForGroup(ENUM_GROUP, function GeneratorAddMana)
    
    call ForGroup(Structures, function ShowAddedMana)
    
    call GroupClear(Structures)
    call GroupClear(ENUM_GROUP)
endfunction

private function Init takes nothing returns nothing
    set manaFilter = And( Filter(function Filter_UnitHasMana), And(Filter_IsUnitStructure, Filter_IsUnitPlayerUnit) )
    set Filter_IsUnitGenerator = Filter(function IsUnitGenerator_Filter)
    
    set manaTable = HandleTable.create()
    
    call TimerStart(CreateTimer(), updateRate, true, function GeneratorMain)
endfunction


endscope