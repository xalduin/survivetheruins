library UnitStatStorage requires AutoIndex, ExportedUnitData


// cooldown, base damage, dice, sides per die,   |^|
// armor,hpregen,mpregen,attacktype, hp, mp, atk type
//##! LoadUnitData fields=ua1c,ua1b,ua1d,ua1s,udef,uhpr,umpr,ua1t,uhpm,umpm


//! textmacro CreateKey takes NAME
    constant key $NAME$_KEY
    constant key $NAME$_BONUS_BASE_KEY
    constant key $NAME$_BONUS_MULT_KEY
//! endtextmacro

globals
    hashtable UnitCurrentStatsTable = InitHashtable()
    
    constant integer ATTACK_TYPE_PHYSICAL = 1
    constant integer ATTACK_TYPE_MAGICAL = 2
    constant integer ATTACK_TYPE_OTHER = 0

    constant key HERO_LEVEL_KEY
    //! runtextmacro CreateKey("HP")
    //! runtextmacro CreateKey("MP")
    //! runtextmacro CreateKey("HP_REGEN")
    //! runtextmacro CreateKey("MP_REGEN")
    //! runtextmacro CreateKey("DAMAGE")
    //! runtextmacro CreateKey("ATTACK_SPEED")
    //! runtextmacro CreateKey("MOVESPEED")
    //! runtextmacro CreateKey("ARMOR")
    //! runtextmacro CreateKey("RESISTANCE")
    constant key DAMAGE_BONUS_PERMANENT_KEY
    
endglobals

function GetUnitTypeAttackType takes integer unitType returns integer
 local string attackType = GetUnitTypeAttackType1(unitType)
 
    if attackType == "normal" then
        return ATTACK_TYPE_PHYSICAL
    elseif attackType == "magic" then
        return ATTACK_TYPE_MAGICAL
    endif
    return ATTACK_TYPE_OTHER
endfunction

function GetUnitTypeAverageDice takes integer unitType returns real
 local integer dice = GetUnitTypeDamageNumberOfDice1(unitType)
 local integer sides = GetUnitTypeDamageSidesPerDie1(unitType)
 
    return I2R(dice) * I2R(sides + 1) / 2.
endfunction

function GetUnitTypeAverageDamageBase takes integer unitType returns real
    return GetUnitTypeAverageDice(unitType) + GetUnitTypeDamageBase1(unitType)
endfunction

function GetUnitIdBaseDamageBonus takes integer unitId returns real
    return LoadReal(UnitCurrentStatsTable, unitId, DAMAGE_BONUS_PERMANENT_KEY)
endfunction

function SetUnitIdBaseDamageBonus takes integer unitId, real value returns nothing
    call SaveReal(UnitCurrentStatsTable, unitId, DAMAGE_BONUS_PERMANENT_KEY, value)
endfunction
function AddUnitIdBaseDamageBonus takes integer unitId, real value returns nothing
    static if DEBUG_MODE then
        if value <= 0. then
            return
        endif
    endif

    call SetUnitIdBaseDamageBonus(unitId, GetUnitIdBaseDamageBonus(unitId) + value)
endfunction

//! textmacro GetUnitBonus takes NAME, KEY, TYPE, LOADTYPE
function GetUnitId$NAME$ takes integer unitId returns $TYPE$
    return Load$LOADTYPE$(UnitCurrentStatsTable, unitId, $KEY$_KEY)
endfunction
function GetUnitId$NAME$Bonus takes integer unitId returns $TYPE$
    return Load$LOADTYPE$(UnitCurrentStatsTable, unitId, $KEY$_BONUS_BASE_KEY)
endfunction
function GetUnitId$NAME$Mult takes integer unitId returns $TYPE$
    return Load$LOADTYPE$(UnitCurrentStatsTable, unitId, $KEY$_BONUS_MULT_KEY)
endfunction
function SetUnitId$NAME$ takes integer unitId, $TYPE$ value returns nothing
    call Save$LOADTYPE$(UnitCurrentStatsTable, unitId, $KEY$_KEY, value)
endfunction
function SetUnitId$NAME$Bonus takes integer unitId, $TYPE$ value returns nothing
    call Save$LOADTYPE$(UnitCurrentStatsTable, unitId, $KEY$_BONUS_BASE_KEY, value)
endfunction
function SetUnitId$NAME$Mult takes integer unitId, $TYPE$ value returns nothing
    call Save$LOADTYPE$(UnitCurrentStatsTable, unitId, $KEY$_BONUS_MULT_KEY, value)
endfunction
function AddUnitId$NAME$Bonus takes integer unitId, $TYPE$ value returns nothing
    call SetUnitId$NAME$Bonus(unitId, GetUnitId$NAME$Bonus(unitId) + value)
endfunction
function AddUnitId$NAME$Mult takes integer unitId, $TYPE$ value returns nothing
    call SetUnitId$NAME$Mult(unitId, GetUnitId$NAME$Mult(unitId) + value)
endfunction
function GetUnit$NAME$ takes unit u returns $TYPE$
    return Load$LOADTYPE$(UnitCurrentStatsTable, GetUnitId(u), $KEY$_KEY)
endfunction
function GetUnit$NAME$Bonus takes unit u returns $TYPE$
    return Load$LOADTYPE$(UnitCurrentStatsTable, GetUnitId(u), $KEY$_BONUS_BASE_KEY)
endfunction
function GetUnit$NAME$Mult takes unit u returns $TYPE$
    return Load$LOADTYPE$(UnitCurrentStatsTable, GetUnitId(u), $KEY$_BONUS_MULT_KEY)
endfunction
function SetUnit$NAME$ takes unit u, $TYPE$ value returns nothing
    call Save$LOADTYPE$(UnitCurrentStatsTable, GetUnitId(u), $KEY$_KEY, value)
endfunction
function SetUnit$NAME$Bonus takes unit u, $TYPE$ value returns nothing
    call Save$LOADTYPE$(UnitCurrentStatsTable, GetUnitId(u), $KEY$_BONUS_BASE_KEY, value)
endfunction
function SetUnit$NAME$Mult takes unit u, $TYPE$ value returns nothing
    call Save$LOADTYPE$(UnitCurrentStatsTable, GetUnitId(u), $KEY$_BONUS_MULT_KEY, value)
endfunction
function AddUnit$NAME$Bonus takes unit u, $TYPE$ value returns nothing
    call SetUnit$NAME$Bonus(u, GetUnit$NAME$Bonus(u) + value)
endfunction
function AddUnit$NAME$Mult takes unit u, $TYPE$ value returns nothing
    call SetUnit$NAME$Mult(u, GetUnit$NAME$Mult(u) + value)
endfunction
//! endtextmacro
function GetUnitIdMoveSpeed takes integer unitId returns real
    return LoadReal(UnitCurrentStatsTable, unitId, MOVESPEED_KEY)
endfunction
function GetUnitIdMoveSpeedBonus takes integer unitId returns real
    return LoadReal(UnitCurrentStatsTable, unitId, MOVESPEED_BONUS_BASE_KEY)
endfunction
function GetUnitIdMoveSpeedMult takes integer unitId returns real
    return LoadReal(UnitCurrentStatsTable, unitId, MOVESPEED_BONUS_MULT_KEY)
endfunction
function SetUnitIdMoveSpeed takes integer unitId, real value returns nothing
    call SaveReal(UnitCurrentStatsTable, unitId, MOVESPEED_KEY, value)
endfunction
function SetUnitIdMoveSpeedBonus takes integer unitId, real value returns nothing
    call SaveReal(UnitCurrentStatsTable, unitId, MOVESPEED_BONUS_BASE_KEY, value)
endfunction
function SetUnitIdMoveSpeedMult takes integer unitId, real value returns nothing
    call SaveReal(UnitCurrentStatsTable, unitId, MOVESPEED_BONUS_MULT_KEY, value)
endfunction
function AddUnitIdMoveSpeedBonus takes integer unitId, real value returns nothing
    call SetUnitIdMoveSpeedBonus(unitId, GetUnitIdMoveSpeedBonus(unitId) + value)
endfunction
function AddUnitIdMoveSpeedMult takes integer unitId, real value returns nothing
    call SetUnitIdMoveSpeedMult(unitId, GetUnitIdMoveSpeedMult(unitId) + value)
endfunction
function GetUnitMoveSpeedBonus takes unit u returns real
    return LoadReal(UnitCurrentStatsTable, GetUnitId(u), MOVESPEED_BONUS_BASE_KEY)
endfunction
function GetUnitMoveSpeedMult takes unit u returns real
    return LoadReal(UnitCurrentStatsTable, GetUnitId(u), MOVESPEED_BONUS_MULT_KEY)
endfunction
function SetUnitMoveSpeedBonus takes unit u, real value returns nothing
    call SaveReal(UnitCurrentStatsTable, GetUnitId(u), MOVESPEED_BONUS_BASE_KEY, value)
endfunction
function SetUnitMoveSpeedMult takes unit u, real value returns nothing
    call SaveReal(UnitCurrentStatsTable, GetUnitId(u), MOVESPEED_BONUS_MULT_KEY, value)
endfunction
function AddUnitMoveSpeedBonus takes unit u, real value returns nothing
    call SetUnitMoveSpeedBonus(u, GetUnitMoveSpeedBonus(u) + value)
endfunction
function AddUnitMoveSpeedMult takes unit u, real value returns nothing
    call SetUnitMoveSpeedMult(u, GetUnitMoveSpeedMult(u) + value)
endfunction

function GetUnitTypeResistance takes integer unitType returns integer
    return GetUnitPointValueByType(unitType)
endfunction

//! runtextmacro GetUnitBonus("Hp","HP","real","Real")
//! runtextmacro GetUnitBonus("Mana","MP","real","Real")
//! runtextmacro GetUnitBonus("HpRegen","HP_REGEN","real","Real")
//! runtextmacro GetUnitBonus("ManaRegen","MP_REGEN","real","Real")
//! runtextmacro GetUnitBonus("Damage","DAMAGE","real","Real")
//! runtextmacro GetUnitBonus("Armor","ARMOR","real","Real")
//! runtextmacro GetUnitBonus("Resistance","RESISTANCE","real","Real")
//! runtextmacro GetUnitBonus("AttackSpeed","ATTACK_SPEED","real","Real")


endlibrary