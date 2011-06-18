library UnitStats initializer Init requires AutoIndex, BonusMod, UnitMaxState, UnitStatStorage, UpgradeStats


globals
    private timer RegenTimer = CreateTimer()
    private constant real REGEN_INTERVAL = .5
    private integer array UnitStats_Array
    private group enumGroup = CreateGroup()
endglobals

// Public functions

public function GetRandomAttackDamage takes unit whichUnit returns real
 local integer unitType = GetUnitTypeId(whichUnit)
 local integer id = GetUnitId(whichUnit)
 local integer dice = GetUnitTypeDamageNumberOfDice1(unitType)
 local integer sides = GetUnitTypeDamageSidesPerDie1(unitType)
 local real damage = GetUnitTypeDamageBase1(unitType) + GetUnitIdDamageBonus(id)
 
    loop
        exitwhen dice <= 0
        set damage = damage + I2R(GetRandomInt(1, sides))
        set dice = dice - 1
    endloop
    
    return damage * GetUnitIdDamageMult(id)
endfunction

// Private functions

//! textmacro GetBonus takes NAME, KEY, UPGRADENAME
    set temp = (GetUnitType$NAME$(unitType)                               +  /*
            */  LoadReal(UnitCurrentStatsTable, id, $KEY$_BONUS_BASE_KEY) +  /*
            */  GetUnitType$UPGRADENAME$Bonus(owner, unitType))           *  /*
            */( LoadReal(UnitCurrentStatsTable, id, $KEY$_BONUS_MULT_KEY) +  /*
            */  GetUnitType$UPGRADENAME$Mult(owner, unitType))  
//! endtextmacro


//if temp > 1. then
        //    //set temp = -(1. - 1./temp)
        //    set temp = 1./temp - 1.
        //elseif temp < 1. then
        //    set temp = 1./temp - 1.
        //else
        //    set temp = 0.
        //endif
globals
    private constant real MAX_ATTACK_SPEED_BONUS = 5.11
endglobals

private function UpdateAttackSpeed takes unit whichUnit, integer unitType, integer id returns nothing
 local player owner = GetOwningPlayer(whichUnit)
 local real base = GetUnitTypeCooldown1(unitType)
 local real bonus = GetUnitIdAttackSpeedBonus(id) + GetUnitTypeAttackSpeedBonus(owner, unitType)
 local real mult = GetUnitIdAttackSpeedMult(id) + GetUnitTypeAttackSpeedMult(owner, unitType)
 local real targetMult = base + bonus
 
    // If the target cooldown is 0. (infinite speed boost) then apply max possible bonus
    if targetMult == 0. then
        set targetMult = MAX_ATTACK_SPEED_BONUS
    else
        set targetMult = base / targetMult - 1.
        set targetMult = targetMult + mult
    endif
    
    // Game doesn't allow less than a -100% bonus in-game
    if targetMult <= -1. then
        set targetMult = -1.
    endif
    
    call SetUnitBonus(whichUnit, BONUS_ATTACK_SPEED, R2I(100. * targetMult))
    
    set bonus = base / (targetMult + 1.)
    call SetUnitIdAttackSpeed(id, bonus)
    
 set owner = null
endfunction

private function UpdateDamage takes unit whichUnit, integer unitId, integer unitType returns nothing
 local player owner = GetOwningPlayer(whichUnit)
 local real base = GetUnitTypeAverageDamageBase(unitType)
 local real temp = GetUnitPermanentDamageBonus(whichUnit)
 local real baseBonus = GetUnitIdBaseDamageBonus(unitId) + GetUnitTypeDamageBonus(owner, unitType)
 
    if baseBonus - temp >= 1. then
        call UnitAddPermanentDamage(whichUnit, R2I(baseBonus - temp))
    endif
    
    set temp = base + baseBonus + GetUnitIdDamageBonus(unitId)
    set temp = temp * (GetUnitIdDamageMult(unitId) + GetUnitTypeDamageMult(owner, unitType))
    call SetUnitIdDamage(unitId, temp)

    set temp = temp - (base + baseBonus)
    call SetUnitBonus(whichUnit, BONUS_DAMAGE, R2I(temp))
endfunction

private function UpdateStats takes unit whichUnit, boolean heroUpdate returns nothing
 local player owner = GetOwningPlayer(whichUnit)
 local integer unitType = GetUnitTypeId(whichUnit)
 local integer id = GetUnitId(whichUnit)
 local integer integerTemp
 local real temp
 local real currentValue
 local integer bonusApplied
    
    //! runtextmacro GetBonus("HitPointsMaximum","HP","Hp")
    set currentValue = GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)
    if temp != GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE) then
        call AddUnitMaxState(whichUnit, UNIT_STATE_MAX_LIFE, temp - currentValue + .5)
    endif
    
    //! runtextmacro GetBonus("ManaMaximum","MP","Mana")
    set currentValue = GetUnitState(whichUnit, UNIT_STATE_MAX_MANA)
    if temp != GetUnitState(whichUnit, UNIT_STATE_MAX_MANA) then
        call AddUnitMaxState(whichUnit, UNIT_STATE_MAX_MANA, temp - currentValue + .5)
    endif

    call UpdateDamage(whichUnit, id, unitType)
    call UpdateAttackSpeed(whichUnit, unitType, id)

    set temp = (GetUnitDefaultMoveSpeed(whichUnit) + GetUnitIdMoveSpeedBonus(id)) * GetUnitIdMoveSpeedMult(id)
    call SetUnitMoveSpeed(whichUnit, I2R(R2I(temp + .5)))

    //! runtextmacro GetBonus("DefenseBase","ARMOR","Armor")
    set currentValue = GetUnitIdArmor(id)
    if temp != currentValue or heroUpdate then
        call SetUnitIdArmor(id, temp)

        set temp = temp - GetUnitTypeDefenseBase(unitType)
        call SetUnitBonus(whichUnit, BONUS_ARMOR, R2I(temp))
    endif
    
    //! runtextmacro GetBonus("Resistance", "RESISTANCE","Resistance")
    set currentValue = GetUnitIdResistance(id)
    if temp != currentValue or heroUpdate then
        call SetUnitIdResistance(id, temp)
    endif
    
    //! runtextmacro GetBonus("HitPointsRegeneration", "HP_REGEN", "HpRegen")
    call SetUnitIdHpRegen(id, RMaxBJ(temp, 0.))
    //! runtextmacro GetBonus("ManaRegeneration", "MP_REGEN", "ManaRegen")
    call SetUnitIdManaRegen(id, RMaxBJ(temp, 0.))

 set owner = null
endfunction

public function Update takes unit whichUnit returns nothing
    call UpdateStats(whichUnit, false)
endfunction

public function PlayerUpdate takes player owner returns nothing
 local unit picked
    call GroupEnumUnitsOfPlayer(enumGroup, owner, null)
    
    loop
        set picked = FirstOfGroup(enumGroup)
        exitwhen picked == null
        call UnitStats_Update(picked)
        call GroupRemoveUnit(enumGroup, picked)
    endloop

    call GroupClear(enumGroup)
 set picked = null
endfunction

private function DoRegen takes nothing returns nothing
 local unit picked = GetEnumUnit()
 local integer id = GetUnitId(picked)
 local real temp

    set temp = GetUnitIdHpRegen(id) - GetUnitTypeHitPointsRegeneration(GetUnitTypeId(picked))
    call SetWidgetLife(picked, GetWidgetLife(picked) + temp * REGEN_INTERVAL)
    
    set temp = GetUnitIdManaRegen(id) - GetUnitTypeManaRegeneration(GetUnitTypeId(picked))
    call SetUnitState(picked, UNIT_STATE_MANA, GetUnitState(picked, UNIT_STATE_MANA) + temp * REGEN_INTERVAL)

 set picked = null
endfunction

private function HandleRegen takes nothing returns nothing
    call GroupEnumUnitsInRect(enumGroup, bj_mapInitialPlayableArea, null)
    call ForGroup(enumGroup, function DoRegen)
    call GroupClear(enumGroup)
endfunction

//! textmacro SetDefaultValue takes KEY, NAME
    call SaveReal(UnitCurrentStatsTable, id, $KEY$_KEY, GetUnitType$NAME$(unitType))
    call SaveReal(UnitCurrentStatsTable, id, $KEY$_BONUS_MULT_KEY, 1.)
//! endtextmacro

private function OnEnterMap takes unit u returns nothing
 local integer id = GetUnitId(u)
 local integer unitType = GetUnitTypeId(u)
 local player owner = GetOwningPlayer(u)
 
    if owner == Player(10) or unitType == XE_DUMMY_UNITID then
        return
    endif

    //! runtextmacro SetDefaultValue("HP_REGEN","HitPointsRegeneration")
    //! runtextmacro SetDefaultValue("MP_REGEN","ManaRegeneration")
    //! runtextmacro SetDefaultValue("ATTACK_SPEED","Cooldown1")
    //! runtextmacro SetDefaultValue("ARMOR","DefenseBase")
    //! runtextmacro SetDefaultValue("RESISTANCE", "Resistance")
    
    // Attack speed is handled a bit differently
    call SetUnitIdAttackSpeedMult(id, 0.)

    call SetUnitIdDamage(id, GetUnitTypeAverageDamageBase(unitType))
    call SetUnitIdDamageMult(id, 1.)

    call SetUnitIdMoveSpeedBonus(id, 0.)
    call SetUnitIdMoveSpeedMult(id, 1.)

    call SaveReal(UnitCurrentStatsTable, id, HP_KEY, GetUnitState(u, UNIT_STATE_MAX_LIFE))
    call SetUnitIdHpMult(id, 1.)
    call SaveReal(UnitCurrentStatsTable, id, MP_KEY, GetUnitState(u, UNIT_STATE_MANA))
    call SetUnitIdManaMult(id, 1.)

    call UpdateStats(u, true)
endfunction

private function OnLeaveMap takes unit u returns nothing
    call FlushChildHashtable(UnitCurrentStatsTable, GetUnitId(u))
endfunction

private function Init takes nothing returns nothing
    call OnUnitIndexed(OnEnterMap)
    call OnUnitDeindexed(OnLeaveMap)
    call TimerStart(RegenTimer, REGEN_INTERVAL, true, function HandleRegen)
endfunction

endlibrary