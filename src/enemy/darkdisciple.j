// Separating out code so the Command library isn't as packed full of stuff

library DarkDisciple initializer Init requires GroupUtils


globals
    private boolexpr healingWaveFilter = null
    private constant string orderString = "healingwave"
    constant integer discipleId = 'n00Y'
    
    private constant real manaCost = 30.
    private constant real healAmount = 300.
endglobals

// Only want to use healing wave if there are >= 3 units
// that have lost at least <healAmount> life

private function HealingWave_Filter takes nothing returns boolean
 local boolean result = GetOwningPlayer(GetFilterUnit()) == Player(11)
    set result = result and GetUnitState(GetFilterUnit(), UNIT_STATE_MAX_LIFE) - GetWidgetLife(GetFilterUnit()) >= healAmount

    return result
endfunction

private function AcquireTarget takes real x, real y returns unit
    call GroupEnumUnitsInRange(ENUM_GROUP, x, y, 600., healingWaveFilter)
    
    if CountUnitsInGroup(ENUM_GROUP) > 2 then
        set bj_lastCreatedUnit = FirstOfGroup(ENUM_GROUP)
    else
        set bj_lastCreatedUnit = null
    endif

    call GroupClear(ENUM_GROUP)

    return bj_lastCreatedUnit
endfunction

function DoDiscipleSpell takes unit spawn returns nothing
 local unit target
 
    if GetUnitState(spawn, UNIT_STATE_MANA) >= manaCost then
        set target = AcquireTarget(GetUnitX(spawn), GetUnitY(spawn))
        
        if target != null then
            call IssueTargetOrder(spawn, orderString, target)
        endif
    endif

 set target = null
endfunction

private function Init takes nothing returns nothing
    set healingWaveFilter = Filter(function HealingWave_Filter)
endfunction


endlibrary