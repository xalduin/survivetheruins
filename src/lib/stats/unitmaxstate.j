library UnitMaxState initializer Initialize requires optional xepreload
//==============================================================================
// UnitMaxState v2.1
//==============================================================================
// Credits:
//------------------------------------------------------------------------------
// Written By:
//     Earth-Fury
// 
// Original System By:
//     Blade.dk
// 
// Intermittent Version By:
//     Deaod
//
// With Thanks To:
//     - weaaddar for BonusMod and thus inspiration
//     - PitzerMike for the ObjectMerger
//     - Vexorian for vJass and Jass Helper
//     - PipeDream for Grimoire
//     - SFilip for TESH
//     - MindWorX for maintaining NewGen
//------------------------------------------------------------------------------
// If you use this library in your map, please at least give credit to Blade.dk.
// Without him, this library would not exist.
//==============================================================================
// Introduction:
//------------------------------------------------------------------------------
// UnitMaxState is a library which allows you to modify a unit's maximum life,
// or maximum mana. To achieve this, the library abuses a bug with the AIlf and
// AImz abilities, which is too complex to explain here.
// 
// I do believe it was indeed Blade.dk who initially found this bug. If not,
// it's still his system I stole and rewrote. Further, let me thank Deaod for
// writing up his version of this system, which inspired both the reality of
// this rewrite, and the method abilities are handled within it.
// 
//==============================================================================
// Requirements:
//------------------------------------------------------------------------------
// UnitMaxState is written in vJass and requires the NewGen editor, or
// Jass Helper with PitzerMike's Object Merger configured for it.
// 
// UnitMaxState requires the latest version of Jass Helper.
// 
// Preloading of abilities requires either AbilityPreload or xepreload. Neither
// are required for the library to function; however, having one or the other
// will remove the slight delay the first time a unit's max state is changed.
// 
//==============================================================================
// Using UnitMaxState:
//------------------------------------------------------------------------------
// UnitMaxState comes with two useful functions:
// 
// nothing SetUnitMaxState(unit <target>, unitstate <state>, real <value>)
//     Changes <target>'s unitstate <state> to be equal to <value>.
//
// nothing AddUnitMaxState(unit <target>, unitstate <state>, real <value>)
//     Adds <value> to <target>'s <state> unitstate. Note that you can use
//     negative values with this function.
//
// Both of these functions accept unitstate's other than UNIT_STATE_MAX_LIFE and
// UNIT_STATE_MAX_MANA. There is a small performance penalty in using these over
// direct usage of SetUnitState.
// 
// You must not use life/mana boosting upgrades in combination with this system.
// 
// Attempting to set a unit's maximum life below 1, or mana below 0 will do
// nothing. A debug message will be output if the script is compiled in
// debug mode.
//==============================================================================



//==============================================================================
// Configuration:
//------------------------------------------------------------------------------
// The below textmacro call is an all-in-one configuration line.
//------------------------------------------------------------------------------
// The first parameter is a boolean.
// 
// If true, the abilities used by this system will be created on save. This adds
// a slight delay to saving your map. You only ever have to create the abilities
// the first time this library is added to your map, or if you modify any of
// the other configuration options.
// 
// Note that to make the ability creation permanent, you must save with ability
// creation enabled, close your map, and reopen it in the editor. You can then
// disable ability creation, as the abilities will be permanently in your map.
//------------------------------------------------------------------------------
// The second parameter is an integer.
// 
// This is the number of abilities this system will use for adding/removing
// life/mana. Note that this system uses four sets of abilities, so the actual
// number of abilities generated and used will be the value you pass here,
// multiplied by 4.
// 
// The higher this number, the faster large bonuses will be added. This number
// should never have to go above 13. Between 3 and 5 will work fine for most
// maps.
//------------------------------------------------------------------------------
// The fourth and fifth parameters are 3 character prefixes for rawcodes.
//
// The first one is for the life-modifying abilities, while the second is for
// the mana-modifying abilities.
// 
// Please, make sure your map has no abilities whose rawcodes begin with either
// of these prefixes before saving! Otherwise, those abilities will be
// overwritten. You can change these to any 3 character combination, if your
// map does already contain abilities whose rawcodes begin with these prefixes.
//------------------------------------------------------------------------------

//! runtextmacro UnitMaxState_Configuration("true", "3", "ZxL", "ZxM")

//------------------------------------------------------------------------------
// End of configuration
//------------------------------------------------------------------------------

//! textmacro UnitMaxState_Configuration takes LOAD_ABILITIES, ABILITY_COUNT, LIFE_PREFIX, MANA_PREFIX
    /*
    //! externalblock extension=lua ObjectMerger $FILENAME$
    //! i function CreateAbilities(baseAbility, rawcodePrefix, field, name, icon)
    //! i     k = 0
    //! i     for sign = -1, 1, 2 do
    //! i         signStr = "+"
    //! i         if sign < 0 then
    //! i             signStr = "-"
    //! i         end
    //! i         j = 0
    //! i         for i = 0, (abilityCount - 1) * 3, 3 do
    //! i             j = j + 1
    //! i             createobject(baseAbility, rawcodePrefix .. string.sub(Chars, k + 1, k + 1))
    //! i             makechange(current, "anam", "UnitMaxState - " .. name)
    //! i             makechange(current, "ansf", "(" .. signStr .. tostring(j) .. ")")
    //! i             makechange(current, "aart", "ReplaceableTextures\\CommandButtons\\" .. icon)
    //! i             makechange(current, "aite", 0)
    //! i             makechange(current, "alev", 4)
    //! i             makechange(current, field, 1, 0)
    //! i             makechange(current, field, 2, 2^(i + 0) * sign)
    //! i             makechange(current, field, 3, 2^(i + 1) * sign)
    //! i             makechange(current, field, 4, 2^(i + 2) * sign)
    //! i             k = k + 1
    //! i         end
    //! i     end
    //! i end
    //! i if $LOAD_ABILITIES$ then
    //! i     setobjecttype("abilities")
    //! i     abilityCount = $ABILITY_COUNT$
    //! i     Chars = "abcdefghijklmnopqrstuvwxyz"
    //! i     CreateAbilities("AIlf", "$LIFE_PREFIX$", "Ilif", "Life", "BTNHealthStone.blp")
    //! i     CreateAbilities("AImz", "$MANA_PREFIX$", "Iman", "Mana", "BTNManaStone.blp")
    //! i end
    //! endexternalblock
    */ 
    
    globals
        private constant integer RAWCODE_LIFE = '$LIFE_PREFIX$a'
        private constant integer RAWCODE_MANA = '$MANA_PREFIX$a'
        
        public constant integer ABILITY_COUNT = $ABILITY_COUNT$
    endglobals
//! endtextmacro
globals
    private constant boolean PRELOAD_ABILITIES = true
    
    private integer array POWERS_OF_2
endglobals

private function DebugIdInteger2IdString takes integer value returns string
     local string charMap = ".................................!.#$%&'()*+,-./0123456789:;<=>.@ABCDEFGHIJKLMNOPQRSTUVWXYZ[.]^_`abcdefghijklmnopqrstuvwxyz{|}~................................................................................................................................."
     local string result = ""
     local integer remainingValue = value
     local integer charValue
     local integer byteno

     set byteno = 0
     loop
         set charValue = ModuloInteger(remainingValue, 256)
         set remainingValue = remainingValue / 256
         set result = SubString(charMap, charValue, charValue + 1) + result
 
         set byteno = byteno + 1
         exitwhen byteno == 4
     endloop
     return result
    endfunction

private function ErrorMsg takes string s returns nothing
    debug call BJDebugMsg("SetUnitMaxState: " + s)
endfunction

function SetUnitMaxState takes unit target, unitstate state, real targetValue returns nothing
    local integer difference
    local integer rawcode
    
    local integer abilityId
    local integer abilityLevel
    
    local integer currentAbility
    
    if state == UNIT_STATE_MAX_LIFE then
        set rawcode = RAWCODE_LIFE
        
        if targetValue < 1 then
            call ErrorMsg("You can not set a unit's max life to below 1 UnitType: " + DebugIdInteger2IdString(GetUnitTypeId(target)))
            return
        endif
    elseif state == UNIT_STATE_MAX_MANA then
        set rawcode = RAWCODE_MANA
        
        if targetValue < 0 then
            call ErrorMsg("You can not set a unit's max mana to below 0")
            return
        endif
    else
        call SetUnitState(target, state, targetValue)
        return
    endif
    
    set difference = R2I(targetValue) - R2I(GetUnitState(target, state))
    
    if difference < 0 then
        set difference = -difference
        set rawcode = rawcode + ABILITY_COUNT
    endif
    
    set abilityId = ABILITY_COUNT - 1
    set abilityLevel = 4
    set currentAbility = rawcode + abilityId
    loop
        exitwhen difference == 0
        
        if difference >= POWERS_OF_2[abilityId * 3 + (abilityLevel - 2)] then
            call UnitAddAbility(target, currentAbility)
            call SetUnitAbilityLevel(target, currentAbility, abilityLevel)
            call UnitRemoveAbility(target, currentAbility)
            
            set difference = difference - POWERS_OF_2[abilityId * 3 + (abilityLevel - 2)]
        else
            set abilityLevel = abilityLevel - 1
            if abilityLevel <= 1 then
                set abilityId = abilityId - 1
                set abilityLevel = 4
                set currentAbility = rawcode + abilityId
            endif
        endif
    endloop
endfunction

function AddUnitMaxState takes unit target, unitstate state, real additionalValue returns nothing
    call SetUnitMaxState(target, state, GetUnitState(target, state) + additionalValue)
endfunction

//! textmacro UnitMaxState_Preload takes RAWCODE
    set i = 0
    loop
        exitwhen i == ABILITY_COUNT * 2 - 1
        
        static if LIBRARY_AbilityPreload then
            call AbilityPreload($RAWCODE$ + i)
        elseif LIBRARY_xepreload then
            call XE_PreloadAbility($RAWCODE$ + i)
        endif
        
        set i = i + 1
    endloop
//! endtextmacro

private function Initialize takes nothing returns nothing
    local integer i
    local integer k
    
    set i = 1
    set POWERS_OF_2[0] = 1
    loop
        exitwhen i == ABILITY_COUNT * 2 * 2 * 3 + 1
        
        set POWERS_OF_2[i] = POWERS_OF_2[i - 1] * 2
        set i = i + 1
    endloop
    
    static if DEBUG_MODE and PRELOAD_ABILITIES and not LIBRARY_AbilityPreload and not LIBRARY_xepreload then
        call ErrorMsg("Ability preloading was enabled, but neither of the supported preload libraries are present")
    elseif PRELOAD_ABILITIES then
        //! runtextmacro UnitMaxState_Preload("RAWCODE_LIFE")
        //! runtextmacro UnitMaxState_Preload("RAWCODE_MANA")
    endif
endfunction
endlibrary