library UpgradeStats


globals
    hashtable UpgradeStatsTable = InitHashtable()
    private group enumGroup = CreateGroup()
endglobals

private struct IdStack
endstruct

//! textmacro UnitTypeBonus takes NAME, KEY
function SetUnitType$NAME$Bonus takes player whichPlayer, integer unitType, real value returns nothing
 local integer playerUnitKey
 
    if not HaveSavedInteger(UpgradeStatsTable, GetPlayerId(whichPlayer), unitType) then
        set playerUnitKey = IdStack.create() + bj_MAX_PLAYER_SLOTS
        call SaveInteger(UpgradeStatsTable, GetPlayerId(whichPlayer), unitType, playerUnitKey)
    else
        set playerUnitKey = LoadInteger(UpgradeStatsTable, GetPlayerId(whichPlayer), unitType)
    endif
    
    call SaveReal(UpgradeStatsTable, playerUnitKey, $KEY$_BONUS_BASE_KEY, value)
endfunction
function GetUnitType$NAME$Bonus takes player whichPlayer, integer unitType returns real
 local integer playerUnitKey = LoadInteger(UpgradeStatsTable, GetPlayerId(whichPlayer), unitType)
    return LoadReal(UpgradeStatsTable, playerUnitKey, $KEY$_BONUS_BASE_KEY)
endfunction
function AddUnitType$NAME$Bonus takes player whichPlayer, integer unitType, real value returns nothing
    call SetUnitType$NAME$Bonus(whichPlayer, unitType, GetUnitType$NAME$Bonus(whichPlayer, unitType) + value)
endfunction
function SetUnitType$NAME$Mult takes player whichPlayer, integer unitType, real value returns nothing
 local integer playerUnitKey

    if not HaveSavedInteger(UpgradeStatsTable, GetPlayerId(whichPlayer), unitType) then
        set playerUnitKey = IdStack.create() + bj_MAX_PLAYER_SLOTS
        call SaveInteger(UpgradeStatsTable, GetPlayerId(whichPlayer), unitType, playerUnitKey)
    else
        set playerUnitKey = LoadInteger(UpgradeStatsTable, GetPlayerId(whichPlayer), unitType)
    endif

    call SaveReal(UpgradeStatsTable, playerUnitKey, $KEY$_BONUS_MULT_KEY, value)
endfunction
function GetUnitType$NAME$Mult takes player whichPlayer, integer unitType returns real
 local integer playerUnitKey = LoadInteger(UpgradeStatsTable, GetPlayerId(whichPlayer), unitType)
    return LoadReal(UpgradeStatsTable, playerUnitKey, $KEY$_BONUS_MULT_KEY)
endfunction
function AddUnitType$NAME$Mult takes player whichPlayer, integer unitType, real value returns nothing
    call SetUnitType$NAME$Mult(whichPlayer, unitType, GetUnitType$NAME$Mult(whichPlayer, unitType) + value)
endfunction
//! endtextmacro

//! runtextmacro UnitTypeBonus("Hp", "HP")
//! runtextmacro UnitTypeBonus("Mana", "MP")
//! runtextmacro UnitTypeBonus("HpRegen", "HP_REGEN")
//! runtextmacro UnitTypeBonus("ManaRegen", "MP_REGEN")
//! runtextmacro UnitTypeBonus("Damage", "DAMAGE")
//! runtextmacro UnitTypeBonus("Armor", "ARMOR")
//! runtextmacro UnitTypeBonus("Resistance", "RESISTANCE")
//! runtextmacro UnitTypeBonus("AttackSpeed", "ATTACK_SPEED")
//! runtextmacro UnitTypeBonus("MoveSpeed", "MOVESPEED")


endlibrary