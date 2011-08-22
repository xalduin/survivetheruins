// A library for convenient damage functions
// AoE damage, group damage, healing, etc

library DamageFunctions requires TimerStack, DamageEvent


function DamageArea takes unit attacker, real damage, real targetX, real targetY, real radius, integer damageType, boolexpr filter returns nothing
 local group targets = CreateGroup()
 local unit picked
 
    call GroupEnumUnitsInRange(targets, targetX, targetY, radius, filter)
    loop
        set picked = FirstOfGroup(targets)
        exitwhen picked == null

        call DamageTarget(attacker, picked, damage, damageType)

        call GroupRemoveUnit(targets, picked)
    endloop

    call DestroyGroup(targets)

 set targets = null
 set picked = null
endfunction

function DamageGroup takes unit attacker, real damage, group target, integer damageType returns nothing
 local group targets = CreateGroup()
 local unit picked

    call GroupAddGroup(target, targets)

    loop
        set picked = FirstOfGroup(targets)
        exitwhen picked == null

        call DamageTarget(attacker, picked, damage, damageType)

        call GroupRemoveUnit(targets, picked)
    endloop

    call DestroyGroup(targets)

 set targets = null
 set picked = null
endfunction


endlibrary