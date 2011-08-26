// Used to add permanent damage bonuses to units (white damage number)
// Once added, the bonus cannot be removed (no -damage bonus allowed)
// No limit to the amount of damage able to be added, but the larger the number,
// the longer it will take to be added

library PermanentDamageBonus initializer Init requires xepreload, Table, Preload, AutoIndex

// Modified from BonusMod by Earth-Fury
/*
    //! externalblock extension=lua ObjectMerger $FILENAME$
    //! i function SetupAbility(suffix, icon)
    //! i     makechange(current, "anam", "BaseDamageBonus")
    //! i     makechange(current, "ansf", "(" .. suffix .. ")")
    //! i     makechange(current, "aart", "ReplaceableTextures\\CommandButtons\\" .. icon)
    //! i     makechange(current, "aite", 1)
    //! i     makechange(current, "acat", ".mdl")
    //! i end

    //! i function SetupItem(suffix, icon, abilityRawcode)
    //! i     makechange(current, "unam", "BaseDamageBonus (" .. suffix .. ")")
    //! i     makechange(current, "iico", "ReplaceableTextures\\CommandButtons\\" .. icon)
    //! i     makechange(current, "iabi", abilityRawcode)
    //! i     makechange(current, "ifil", ".mdl")
    //! i end

    //! i function CreateAbility(sourceAbility, sourceItem, abilPrefix, itemPrefix, field, abilityCount, icon)
    //! i     powOf2 = abilityCount - 1
    //! i     lengthOfMax = string.len(tostring(2^abilityCount))
    //! i     for i = 0, powOf2 do
    //! i         padding = ""
    //! i         for k = 0, lengthOfMax - string.len(tostring(2^i)) - 1 do
    //! i             padding = padding .. "0"
    //! i         end
    //! i         abilityRawcode = abilPrefix .. string.sub(chars, i + 1, i + 1)
    //! i         itemRawcode = itemPrefix .. string.sub(chars, i + 1, i + 1)

    //! i         setobjecttype("abilities")
    //! i         createobject(sourceAbility, abilityRawcode)
    //! i         logf(currentobjecttype(), currentobject())
    //! i         SetupAbility("+" .. padding .. tostring(2 ^ i), icon)
    //! i         makechange(current, field, 1, tostring(2^i))
    
    //! i         setobjecttype("items")
    //! i         createobject(sourceItem, itemRawcode)
    //! i         SetupItem("+" .. padding .. tostring(2 ^ i), icon, abilityRawcode)
    //! i     end
    //! i end
    //! i     chars = "abcdefghijklmnopqrstuvwxyz"
    //! i     CreateAbility("AIaa", "tdex", "(ZZ", "ZZ)", "Iaa1", 8, "BTNTomeRed.blp")
    //! i
    //! endexternalblock
*/
    
// Make sure to change these to correspond with the CreateAbility function in the
// external block
globals
    // Ability rawcodes, for preloading
    private constant integer abilityRawcodeStart = '(ZZa'
    private constant integer abilityRawcodeEnd = '(ZZh'

    // Item Rawcodes
    private constant integer itemRawcodeStart = 'ZZ)a'
    private constant integer itemRawcodeEnd = 'ZZ)h'
    
    // Adding more abilities simply makes adding larger bonuses slightly more efficient
    private constant integer ABILITY_COUNT = 8
    
    private constant integer ABILITY_HERO_INVENTORY = 'AInv'
    
    private HandleTable BonusTable
endglobals

function GetUnitPermanentDamageBonus takes unit whichUnit returns integer
    if not BonusTable.exists(whichUnit) then
        return 0
    endif
    return BonusTable[whichUnit]
endfunction

function UnitAddPermanentDamage takes unit whichUnit, integer bonus returns nothing
 local integer index = ABILITY_COUNT - 1
 local integer pow = R2I(Pow(2., index))
 local boolean removeInventory = false
 
    if bonus <= 0 then
        return
    endif
    
    if not BonusTable.exists(whichUnit) then
        set BonusTable[whichUnit] = 0
    endif
    set BonusTable[whichUnit] = BonusTable[whichUnit] + bonus
 
    if GetUnitAbilityLevel(whichUnit, ABILITY_HERO_INVENTORY) == 0 then
        call UnitAddAbility(whichUnit, ABILITY_HERO_INVENTORY)
        set removeInventory = true
    endif
    
    loop
        exitwhen bonus == 0
        
        if bonus >= pow then
            call UnitAddItemById(whichUnit, itemRawcodeStart + index)
            set bonus = bonus - pow
        else
            set index = index - 1
            set pow = pow / 2
        endif
    endloop
    
    if removeInventory then
        call UnitRemoveAbility(whichUnit, ABILITY_HERO_INVENTORY)
    endif
endfunction


// For use in cases in which the bonuses are removed from a unit
// Ex: Unit upgrade, unit upgrade cancelled, etc
function UnitResetPermanentDamage takes unit whichUnit returns nothing
	if BonusTable.exists(whichUnit) then
		set BonusTable[whichUnit] = 0
	endif
endfunction

private function OnLeaveMap takes unit u returns nothing
    call BonusTable.flush(u)
endfunction

private function Init takes nothing returns nothing
 local integer i = abilityRawcodeStart
 
    loop
        exitwhen i > abilityRawcodeEnd
        call XE_PreloadAbility(i)
        set i = i + 1
    endloop
    
    call PreloadItemRange(itemRawcodeStart, itemRawcodeEnd)
    
    set BonusTable = HandleTable.create()
    call OnUnitDeindexed(OnLeaveMap)
endfunction


endlibrary