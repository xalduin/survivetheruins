// Instead of creating a trigger for every spell, all spell triggers are registered here
// It's expected that multiple triggers will NOT use the same ability

library AbilityOnEffect initializer Init requires MiscFunctions


//======================
// Patch-dependent code
//======================

globals
    private hashtable table
endglobals

private function StoreTrigger takes integer id, trigger t returns nothing
    call SaveTriggerHandle(table, id, 0, t)
endfunction

private function GetTrigger takes integer id returns trigger
    return LoadTriggerHandle(table, id, 0)
endfunction

//===========================
//Mainly independent of patch
//===========================

private function OnEffect_Execute takes nothing returns nothing
 local trigger trig = GetTrigger(GetSpellAbilityId())

    if trig != null then
        call TriggerExecute(trig)
    endif

 set trig = null
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

    set table = InitHashtable()
 
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(t, function OnEffect_Execute)

 set t = null
endfunction

function Ability_OnEffect takes integer abilId, code func returns nothing
 local trigger t = CreateTrigger()
 
    call TriggerAddAction(t, func)
    call StoreTrigger(abilId, t)

 set t = null
endfunction


endlibrary