// Separating out code so the Command library isn't as packed full of stuff

library NecroSpell initializer Init requires GroupUtils


globals
    private boolexpr antiMagicFilter = null
    private constant integer shieldSpell = 'A028'
    private constant integer shieldBuff = 'Bams'
    
    private constant integer manaCost = 10.
endglobals

private function AntiMagic_Filter takes nothing returns boolean
    return GetOwningPlayer(GetFilterUnit()) == Player(11) and GetUnitAbilityLevel(GetFilterUnit(), shieldBuff) != 1
endfunction

private function Necromancer_AcquireTarget takes real x, real y returns unit
    call GroupEnumUnitsInRange(ENUM_GROUP, x, y, 800., antiMagicFilter)
    set bj_lastCreatedUnit = FirstOfGroup(ENUM_GROUP)
    call GroupClear(ENUM_GROUP)

    return bj_lastCreatedUnit
endfunction

function DoNecroSpell takes unit spawn returns nothing
 local unit target
 
    if GetUnitState(spawn, UNIT_STATE_MANA) >= manaCost and GetUnitAbilityLevel(spawn, 'BNsi') != 1 then
        set target = Necromancer_AcquireTarget(GetUnitX(spawn), GetUnitY(spawn))
        
        if target != null then
            call SetUnitState(spawn, UNIT_STATE_MANA, GetUnitState(spawn, UNIT_STATE_MANA) - manaCost)
            set spawn = CreateUnit(Player(11), 'u008', GetUnitX(spawn), GetUnitY(spawn), 0.)

            call UnitAddAbility(spawn, shieldSpell)
            call UnitApplyTimedLife(spawn, 'BTLF', 3.)
            
            call IssueTargetOrder(spawn, "antimagicshell", target)
        endif
    endif

 set target = null
endfunction

private function Init takes nothing returns nothing
    set antiMagicFilter = Filter(function AntiMagic_Filter)
endfunction


endlibrary