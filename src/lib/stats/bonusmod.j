library BonusMod initializer OnInit requires optional AbilityPreload, optional xepreload
private keyword AbilityBonus
////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ BonusMod - v3.3.1
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@    Based on the work of:
//@        weaaddar
//@-----------------------------------------------------------------------------
//@ If you use this system, please at least credit weaaddar. Without him, this
//@ system would not exist. I would be happy if you credited me as well.
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library is written in vJass and thus requires JASS Helper in order to
//@ function correctly. This library also uses the ObjectMerger created by
//@ PitzerMike. The ObjectMerger must be configured as an external tool for
//@ JASS Helper.
//@ 
//@ All of these things are present in the NewGen world editor.
//@ 
//@=============================================================================
//@ Introduction:
//@-----------------------------------------------------------------------------
//@ BonusMod is a system for applying reversible bonuses to certain stats, such
//@ as attack speed or mana regen, for specific units. Most of the bonuses
//@ provided by BonusMod show green or red numbers in the command card, exactly
//@ like the bonuses provided by items.
//@
//@ BonusMod has two kinds of bonuses:
//@   1. Ability based bonuses
//@   2. Code based bonuses
//@ 
//@ All of the bonuses in the configuration section for the basic BonusMod
//@ library are ability-based bonuses. Code-based bonuses are provided by
//@ additional libraries.
//@ 
//@ Ability based bonuses have a limit to how much of a bonus they can apply.
//@ The actual limit depends on the number of abilities that type of bonus uses.
//@ See the "Default bonuses" section of this readme for the default limits
//@ of the bonuses that come with BonusMod. For changing the limits of the
//@ default bonuses, or for adding new types of bonuses, see the below
//@ configuration section.
//@ 
//@ Code based bonuses may or may not have a limit to how much of a bonus they
//@ can apply. The limits for code based bonuses depend entirely on how the
//@ bonus is implemented. See their documentation for more information.
//@
//@=============================================================================
//@ Adding BonusMod to your map:
//@-----------------------------------------------------------------------------
//@ First, you must place the BonusMod library in a custom-text trigger in your
//@ map.
//@
//@ You must then save your map with ability generation enabled. After you save
//@ your map with ability generation enabled, you must close your map in the
//@ editor, and reopen it. You can then disable ability generation.
//@ See the configuration section for information on how to enable and disable
//@ ability generation.
//@
//@=============================================================================
//@ Default bonuses:
//@-----------------------------------------------------------------------------
//@ 
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@      | Bonus Type constants:       | Minimum bonus: | Maximum bonus: |
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@      | BONUS_SIGHT_RANGE           |   -2048        |   +2047        |
//@      | BONUS_ATTACK_SPEED          |   -512         |   +511         |
//@      | BONUS_ARMOR                 |   -1024        |   +1023        |
//@      | BONUS_MANA_REGEN_PERCENT    |   -512%        |   +511%        |
//@      | BONUS_LIFE_REGEN            |   -256         |   +255         |
//@      | BONUS_DAMAGE                |   -1024        |   +1023        |
//@      | BONUS_STRENGTH              |   -256         |   +255         |
//@      | BONUS_AGILITY               |   -256         |   +255         |
//@      | BONUS_INTELLIGENCE          |   -256         |   +255         |
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@
//@      Notes:
//@         - The bonuses for stength, agility, and intelligence can only be
//@           applied to heroes. Attempting to add them to normal units will
//@           fail to work completely.
//@         - Using a negative BONUS_STRENGTH bonus can give a unit negative
//@           maximum life. Don't do that. It really messes stuff up.
//@         - Using a negative BONUS_INTELLIGENCE bonus can remove a hero's
//@           mana. This is not a big issue, as mana will return when the
//@           bonus is removed.
//@         - The maximum effective sight range for a unit is 1800.
//@         - There is a maximum attack speed. I have no idea what it is.
//@ 
//@ See the configuration section for information on how to change the range of
//@ bonuses, as well as how to add new ability-based bonuses, and remove unused
//@ ones.
//@ 
//@=============================================================================
//@ Public API / Function list:
//@-----------------------------------------------------------------------------
//@ Note that BonusMod will only output error messages if JASS Helper is set to
//@ compile in debug mode.
//@
//@ Bonus constants such as BONUS_DAMAGE have .min and .max properties which
//@ are the minimum and maximum bonus that type of bonus can apply. Note that
//@ for code based bonuses, these constants may not reflect the minimum or
//@ maximum bonus for a specific unit. Use the IsBonusValid() function to check
//@ if the given bonus value is okay for a given unit.
//@
//@ function SetUnitBonus
//@ takes unit u, Bonus bonusType, integer amount
//@ returns integer
//@ 
//@     This function sets the bonus of the type bonusType for the given unit to
//@     the given amount. The returned integer is the unit's actual current
//@     bonus, after it has been changed. If the given amount is above the
//@     maximum possible bonus for this type, then the maximum possible bonus
//@     is applied to the unit. The same is true if the given value is below
//@     the minimum possible bonus.
//@
//@ function GetUnitBonus
//@ takes unit u, Bonus bonusType
//@ returns integer
//@
//@     Returns the given unit's current bonus of bonusType. A value of 0 means
//@     that the given unit does not have a bonus of the given type.
//@ 
//@ function AddUnitBonus
//@ takes unit u, Bonus bonusType, integer amount
//@ returns integer
//@ 
//@     Increases the unit's bonus by the given amount. You can use a negitive
//@     amount to subtract from the unit's current bonus. Note that the same
//@     rules SetUnitBonus has apply for going over/under the maximum bonus.
//@     The returned value is the unit's actual new bonus.
//@ 
//@ function RemoveUnitBonus
//@ takes unit u, Bonus bonusType
//@ returns nothing
//@ 
//@     Sets the bonus of the type bonusType to 0 for the given unit. This
//@     function is faster then using SetUnitBonus(u, bonusType, 0).
//@
//@ function IsBonusValid
//@ takes unit u, Bonus abstractBonus, integer value
//@ returns boolean
//@
//@     Returns true if the given value is a valid bonus value for the given
//@     unit. This will also return false if the given bonus type is a hero-
//@     only bonus type, and the given unit is not a hero.
//@ 
//@=============================================================================
//@ Writing code-based bonuses:
//@-----------------------------------------------------------------------------
//@ This section of the readme tells you how to create your own bonus types
//@ that apply their bonuses using vJass code instead of abilities. You do not
//@ need to read or understand this to use BonusMod as-is.
//@
//@ Creating a new bonus type is simple. Extend the Bonus struct, implement the
//@ methods provided within it, and create a single instance of your struct
//@ within a variable named BONUS_YOUR_BONUS_TYPES_NAME of the type Bonus.
//@ 
//@ The methods you must implement are:
//@
//@ method setBonus takes unit u, integer amount returns integer
//@     This method sets the given unit's current bonus to amount, returning
//@     the actual bonus that was applied. If the given amount is higher then
//@     the maximum amount your bonus type can apply to a unit, you must apply
//@     the maximum possible bonus, and return that amount. The same holds true
//@     for the minimum bonus.
//@
//@ method getBonus takes unit u returns integer
//@     This method returns the current bonus the given unit has.
//@
//@ method removeBonus takes unit u returns nothing
//@     This method sets the current bonus of the given unit to 0.
//@
//@ method isValueInRange takes integer value returns boolean
//@     This method returns true if the given integer is a valid bonus amount
//@     for this bonus type, and false otherwise.
//@
//@ Note that it is your responsibility to do any clean up in the event a unit
//@ dies or is removed with an active bonus on it. There is no guarantee that
//@ removeBonus() will be called before a unit dies or is removed.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// If the following constant is set to true, the abilities used by this library
// will be preloaded at map initialization. This will slightly increase loading
// time, but will prevent a slight to medium lag spike the first time a bonus
// of a type is applied.
// 
// Note that your map must contain either the xepreload library, or the
// AbilityPreload library for preloading to work.
// 
// It is highly recommended that you do not set this to false.
//------------------------------------------------------------------------------
globals
    private constant boolean PRELOAD_ABILITIES = true
endglobals

//------------------------------------------------------------------------------
// The BonusMod_BeginBonuses macro takes a single boolean type parameter.
// If set to true, bonus abilities will be created (or recreated) on save.
// If set to false, abilities will not be generated.
// 
// If you modify any of the bonus declaration macros, or add new ones, you must
// regenerate abilities.
// 
// Note that if you remove a bonus, the abilities it had created will not be
// automatically removed. This is also true of reducing the number of abilities
// a bonus uses.
// 
// After you generate abilities, you must close your map and reopen it in the
// editor. You can then disable ability generation until the next time you
// modify the bonus types.
//------------------------------------------------------------------------------
//! runtextmacro BonusMod_BeginBonuses("false")
    //--------------------------------------------------------------------------
    // Below are where bonus types are defined.
    // 
    // The first parameter is the name of the bonus type. A constant will be
    // generated for each bonus type, that will take the form: BONUS_NAME
    // 
    // The second parameter is the maximum power of 2 the bonus type can add
    // to a unit. For example, 8 abilities gives a range of -256 to +255.
    // 
    // The third parameter is the base ability. The base ability must give the
    // desired effect when the given field is changed.
    // 
    // The fourth parameter is the rawcode prefix of the bonuses generated
    // abilities. The prefix must be 3 characters long. Your map must not
    // already contain bonuses which start with the given prefix.
    // 
    // The fifth parameter is the object field to modify for each generated
    // ability.
    // 
    // The sixth parameter must be true of the bonus should only work on hero
    // units, and false otherwise.
    // 
    // The final parameter is the icon that will be displayed in the object
    // editor. This has no effect on anything ingame.
    //--------------------------------------------------------------------------
    
    //                                    |     NAME     |ABILITY|SOURCE |PREFIX|FIELD  | HERO   |  ICON
    //                                    |              | COUNT |ABILITY|      |       |  ONLY  |
    //! runtextmacro BonusMod_DeclareBonus("ARMOR",        "8",  "AId1", "(A)", "Idef", "false", "BTNHumanArmorUpOne.blp")
    //! runtextmacro BonusMod_DeclareBonus("DAMAGE",       "8",  "AItg", "(B)", "Iatt", "false", "BTNSteelMelee.blp")
    ///! runtextmacro BonusMod_DeclareBonus("SIGHT_RANGE",  "11",  "AIsi", "(C)", "Isib", "false", "BTNTelescope.blp")
    ////! runtextmacro BonusMod_DeclareBonus("LIFE_REGEN",   "8",   "Arel", "(E)", "Ihpr", "false", "BTNRingSkull.blp")
    ///! runtextmacro BonusMod_DeclareBonus("STRENGTH",     "8",   "AIa1", "(F)", "Istr", "true" , "BTNGoldRing.blp")
    ///! runtextmacro BonusMod_DeclareBonus("AGILITY",      "8",   "AIa1", "(G)", "Iagi", "true" , "BTNGoldRing.blp")
    ///! runtextmacro BonusMod_DeclareBonus("INTELLIGENCE", "8",   "AIa1", "(H)", "Iint", "true" , "BTNGoldRing.blp")
    
    //                                           |     NAME          |ABILITY|SOURCE |PREFIX|FIELD  |HERO   |  ICON
    //                                           |                   | COUNT |ABILITY|      |       | ONLY  |
    //! runtextmacro BonusMod_DeclarePercentBonus("ATTACK_SPEED",       "9", "AIsx",  "(I)", "Isx1", "false", "BTNGlove.blp")
    ////! runtextmacro BonusMod_DeclarePercentBonus("MANA_REGEN_PERCENT", "9", "AIrm",  "(D)", "Imrp", "false", "BTNSobiMask.blp")
    
//! runtextmacro BonusMod_EndBonuses()

//==============================================================================
// End of configuration
//==============================================================================

//! textmacro BonusMod_BeginBonuses takes SHOULD_GENERATE_ABILITIES
    private function Setup takes nothing returns nothing
    
    // The following is a lua script for the ObjectMerger, used to generate abilities
    
    /*
    //! externalblock extension=lua ObjectMerger $FILENAME$
    //! i if "$SHOULD_GENERATE_ABILITIES$" == "true" then
    //! i function FormatName(name)
    //! i     name = string.lower(name)
    //! i     name = string.gsub(name, "_", " ")
    //! i     s = name
    //! i     name = ""
    //! i     for w in string.gmatch(s, "%a%w*") do
    //! i         name = name .. string.upper(string.sub(w, 1, 1)) .. string.sub(w, 2, -1)
    //! i         name = name .. " "
    //! i     end
    //! i     name = string.sub(name, 1, string.len(name) - 1)
    //! i     return name
    //! i end
    //! i function SetupAbility(name, suffix, icon, hero)
    //! i     makechange(current, "anam", "BonusMod - " .. FormatName(name))
    //! i     makechange(current, "ansf", "(" .. suffix .. ")")
    //! i     makechange(current, "aart", "ReplaceableTextures\\CommandButtons\\" .. icon)
    //! i     makechange(current, "aite", 0)
    //! i     if hero then
    //! i         makechange(current, "Iagi", 1, 0)
    //! i         makechange(current, "Iint", 1, 0)
    //! i         makechange(current, "Istr", 1, 0)
    //! i     end
    //! i end
    //! i function CreateAbility(sourceAbility, prefix, field, abilityCount, name, icon)
    //! i     powOf2 = abilityCount - 1
    //! i     lengthOfMax = string.len(tostring(2^abilityCount))
    //! i     for i = 0, powOf2 do
    //! i         padding = ""
    //! i         for k = 0, lengthOfMax - string.len(tostring(2^i)) - 1 do
    //! i             padding = padding .. "0"
    //! i         end
    //! i         createobject(sourceAbility, prefix .. string.sub(chars, i + 1, i + 1))
    //! i         SetupAbility(name, "+" .. padding .. tostring(2 ^ i), icon, true)
    //! i         makechange(current, field, 1, tostring(2^i))
    //! i     end
    //! i     createobject(sourceAbility, prefix .. "-")
    //! i     SetupAbility(name, "-" .. tostring(2 ^ abilityCount), icon, true)
    //! i     makechange(current, field, 1, tostring(-(2^abilityCount)))
    //! i end
    //! i function CreatePercentageAbility(sourceAbility, prefix, field, abilityCount, name, icon)
    //! i     powOf2 = abilityCount - 1
    //! i     lengthOfMax = string.len(tostring(2^abilityCount))
    //! i     for i = 0, powOf2 do
    //! i         padding = ""
    //! i         for k = 0, lengthOfMax - string.len(tostring(2^i)) - 1 do
    //! i             padding = padding .. "0"
    //! i         end
    //! i         createobject(sourceAbility, prefix .. string.sub(chars, i + 1, i + 1))
    //! i         SetupAbility(name, "+" .. padding .. tostring(2 ^ i) .. "%", icon, false)
    //! i         makechange(current, field, 1, tostring((2 ^ i) / 100))
    //! i     end
    //! i     createobject(sourceAbility, prefix .. "-")
    //! i     SetupAbility(name, "-" .. tostring(2 ^ abilityCount) .. "%", icon, false)
    //! i     makechange(current, field, 1, tostring(-((2 ^ abilityCount) / 100)))
    //! i end
    //! i     setobjecttype("abilities")
    //! i     chars = "abcdefghijklmnopqrstuvwxyz"
    //! i 
    */
//! endtextmacro

//! textmacro BonusMod_DeclareBonus takes NAME, ABILITY_COUNT, SOURCE_ABILITY, RAWCODE_PREFIX, FIELD, HERO_ONLY, ICON
    //##! i CreateAbility("$SOURCE_ABILITY$", "$RAWCODE_PREFIX$", "$FIELD$", $ABILITY_COUNT$, "$NAME$", "$ICON$")
    globals
        Bonus BONUS_$NAME$
    endglobals
    set BONUS_$NAME$ = AbilityBonus.create('$RAWCODE_PREFIX$a', $ABILITY_COUNT$, '$RAWCODE_PREFIX$-', $HERO_ONLY$)
//! endtextmacro

//! textmacro BonusMod_DeclarePercentBonus takes NAME, ABILITY_COUNT, SOURCE_ABILITY, RAWCODE_PREFIX, FIELD, HERO_ONLY, ICON
    //##! i CreatePercentageAbility("$SOURCE_ABILITY$", "$RAWCODE_PREFIX$", "$FIELD$", $ABILITY_COUNT$, "$NAME$", "$ICON$")
    globals
        Bonus BONUS_$NAME$
    endglobals
    set BONUS_$NAME$ = AbilityBonus.create('$RAWCODE_PREFIX$a', $ABILITY_COUNT$, '$RAWCODE_PREFIX$-', $HERO_ONLY$)
//! endtextmacro

//! textmacro BonusMod_EndBonuses
    
    //##! i end
    //##! endexternalblock
    
    
    endfunction
//! endtextmacro

// ===
//  Precomputed integer powers of 2
// ===

globals
    private integer array powersOf2
    private integer powersOf2Count = 0
endglobals

// ===
//  Utility functions
// ===

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000BonusMod Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

private function LoadAbility takes integer abilityId returns nothing
    static if PRELOAD_ABILITIES then
        static if LIBRARY_xepreload then
            call XE_PreloadAbility(abilityId)
        else
            static if LIBRARY_AbilityPreload then
                call AbilityPreload(abilityId)
            endif
        endif
    endif
endfunction

// ===
//  Bonus Types
// ===

private interface BonusInterface
    integer minBonus = 0
    integer maxBonus = 0
    private method destroy takes nothing returns nothing defaults nothing
endinterface

private keyword isBonusObject

struct Bonus extends BonusInterface
    boolean isBonusObject = false
    
    public static method create takes nothing returns thistype
        local thistype this = thistype.allocate()
        
        set this.isBonusObject = true
        
        return this
    endmethod
    
    stub method setBonus takes unit u, integer amount returns integer
        debug call ErrorMsg("Bonus.setBonus()", "I have no idea how or why you did this, but don't do it.")
        return 0
    endmethod
    
    stub method getBonus takes unit u returns integer
        debug call ErrorMsg("Bonus.getBonus()", "I have no idea how or why you did this, but don't do it.")
        return 0
    endmethod
    
    stub method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    stub method isValidBonus takes unit u, integer value returns boolean
        return true
    endmethod
    
    method operator min takes nothing returns integer
        return this.minBonus
    endmethod
    
    method operator max takes nothing returns integer
        return this.maxBonus
    endmethod
endstruct

private struct AbilityBonus extends Bonus
    public integer count
    
    public integer rawcode
    public integer negativeRawcode
    
    public integer minBonus = 0
    public integer maxBonus = 0
    
    public boolean heroesOnly
    
    public static method create takes integer rawcode, integer count, integer negativeRawcode, boolean heroesOnly returns thistype
        local thistype bonus = thistype.allocate()
        local integer i
        debug local boolean error = false
        
        // Error messages
        static if DEBUG_MODE then
            if rawcode == 0 then
                call ErrorMsg("AbilityBonus.create()", "Bonus constructed with a rawcode of 0?!")
                call bonus.destroy()
                return 0
            endif
            
            if count < 0 or count == 0 then
                call ErrorMsg("AbilityBonus.create()", "Bonus constructed with an ability count <= 0?!")
                call bonus.destroy()
                return 0
            endif
        endif
        
        // Grow powers of 2
        if powersOf2Count < count then
            set i = powersOf2Count
            loop
                exitwhen i > count
                
                set powersOf2[i] = 2 * powersOf2[i - 1]

                set i = i + 1
            endloop
            set powersOf2Count = count
        endif
        
        // Preload this bonus' abilities
        static if PRELOAD_ABILITIES then
            set i = 0
            loop
                exitwhen i == count
                
                call LoadAbility(rawcode + i)
                
                set i = i + 1
            endloop
            
            if negativeRawcode != 0 then
                call LoadAbility(negativeRawcode)
            endif
        endif
        
        // Set up this bonus object
        set bonus.count = count
        set bonus.negativeRawcode = negativeRawcode
        set bonus.rawcode = rawcode
        set bonus.heroesOnly = heroesOnly
        
        // Calculate the minimum and maximum bonuses
        if negativeRawcode != 0 then
            set bonus.minBonus = -powersOf2[count]
        else
            set bonus.minBonus = 0
        endif
        set bonus.maxBonus = powersOf2[count] - 1
        
        // Return the bonus object
        return bonus
    endmethod
    
    // Interface methods:
    
    method setBonus takes unit u, integer amount returns integer
        return SetUnitBonus.evaluate(u, this, amount)
    endmethod
    
    method getBonus takes unit u returns integer
        return GetUnitBonus.evaluate(u, this)
    endmethod
    
    method removeBonus takes unit u returns nothing
        call RemoveUnitBonus.evaluate(u, this)
    endmethod
    
    public method isValidBonus takes unit u, integer value returns boolean
        return (value >= this.minBonus) and (value <= this.maxBonus)
    endmethod
endstruct

// ===
//  Public API
// ===

function IsBonusValid takes unit u, Bonus abstractBonus, integer value returns boolean
    local AbilityBonus bonus = AbilityBonus(abstractBonus)
    
    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("IsBonusValid()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.min > value or abstractBonus.max < value then
        return false
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.isValidBonus(u, value)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        return false
    endif
    
    return (value >= bonus.minBonus) and (value <= bonus.maxBonus)
endfunction

function RemoveUnitBonus takes unit u, Bonus abstractBonus returns nothing
    local integer i = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)

    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("RemoveUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        call abstractBonus.removeBonus(u)
        return
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("RemoveUnitBonus()", "Trying to remove a hero-only bonus from a non-hero unit")
        return
    endif
    
    call UnitRemoveAbility(u, bonus.negativeRawcode)
    
    loop
        exitwhen i == bonus.count
        
        call UnitRemoveAbility(u, bonus.rawcode + i)

        set i = i + 1
    endloop
endfunction

function SetUnitBonus takes unit u, Bonus abstractBonus, integer amount returns integer
    local integer i
    local integer output = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)
    local boolean applyMinBonus = false
    
    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("SetUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if amount == 0 then
        call RemoveUnitBonus(u, bonus)
        return 0
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.setBonus(u, amount)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("SetUnitBonus()", "Trying to set a hero-only bonus on a non-hero unit")
        return 0
    endif
    
    if amount < bonus.minBonus then
        debug call ErrorMsg("SetUnitBonus()", "Attempting to set a bonus to below its min value")
        set amount = bonus.minBonus
    elseif amount > bonus.maxBonus then
        debug call ErrorMsg("SetUnitBonus()", "Attempting to set a bonus to above its max value")
        set amount = bonus.maxBonus
    endif
    
    if amount < 0 then
        set amount = -(bonus.minBonus - amount)
        set applyMinBonus = true
    endif
    
    call UnitRemoveAbility(u, bonus.negativeRawcode)
    
    set i = bonus.count - 1
    loop
        exitwhen i < 0
        if amount >= powersOf2[i] then
            
            call UnitAddAbility(u, bonus.rawcode + i)
            call UnitMakeAbilityPermanent(u, true, bonus.rawcode + i)
            
            static if DEBUG_MODE then
                if GetUnitAbilityLevel(u, bonus.rawcode + i) <= 0 then
                    call ErrorMsg("SetUnitBonus()", "Failed to give the 2^" + I2S(i) + " ability to the unit!")
                endif
            endif
            
            set amount = amount - powersOf2[i]
            set output = output + powersOf2[i]
        else
            
            call UnitRemoveAbility(u, bonus.rawcode + i)
            static if DEBUG_MODE then
                if GetUnitAbilityLevel(u, bonus.rawcode + i) > 0 then
                    call ErrorMsg("SetUnitBonus()", "Unit still has the 2^" + I2S(i) + " ability after it was removed!")
                endif
            endif
        endif

        set i = i - 1
    endloop
    
    if applyMinBonus then
        call UnitAddAbility(u, bonus.negativeRawcode)
        call UnitMakeAbilityPermanent(u, true, bonus.negativeRawcode)
    else
        call UnitRemoveAbility(u, bonus.negativeRawcode)
    endif
    
    return output
endfunction

function GetUnitBonus takes unit u, Bonus abstractBonus returns integer
    local integer i = 0
    local integer amount = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)

    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("GetUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.getBonus(u)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("GetUnitBonus()", "Trying to get a hero-only bonus from a non-hero unit")
        return 0
    endif
    
    if GetUnitAbilityLevel(u, bonus.negativeRawcode) > 0 then
        set amount = bonus.minBonus
    endif

    loop
        exitwhen i == bonus.count
        
        if GetUnitAbilityLevel(u, bonus.rawcode + i) > 0 then
            set amount = amount + powersOf2[i]
        endif

        set i = i + 1
    endloop

    return amount
endfunction

function AddUnitBonus takes unit u, Bonus bonus, integer amount returns integer
    return SetUnitBonus(u, bonus, GetUnitBonus(u, bonus) + amount)
endfunction

// ===
//  Initialization
// ===

private function OnInit takes nothing returns nothing
    local integer i
    
    // Set up powers of 2
    set powersOf2[0] = 1
    set powersOf2Count = 1
    
    static if DEBUG_MODE and PRELOAD_ABILITIES and not LIBRARY_xepreload and not LIBRARY_AbilityPreload then
        call ErrorMsg("Initialization", "PRELOAD_ABILITIES is set to true, but neither usable preloading library is detected")
    endif
    
    // Setup bonuses
    call Setup()
endfunction
endlibrary