// Wrapper and convenience functions for knockback


library KnockbackFunctions requires Knockback


function KnockbackUnit takes unit caster, unit target, real angle, real speed, boolean knockAdjacent returns boolean
    return KnockbackTarget(caster, target, angle, speed, speed/3. + speed, false, knockAdjacent, false)
endfunction

function KnockbackArea takes unit source, real targetX, real targetY, real radius, real speed, boolean knockAdj, boolexpr filter returns nothing
 local group targets = CreateGroup()
 local unit picked
 local real angle

    call GroupEnumUnitsInRange(targets, targetX, targetY, radius, filter)

    loop
        set picked = FirstOfGroup(targets)
        exitwhen picked == null

        set angle = bj_RADTODEG * Atan2(GetUnitY(picked) - targetY, GetUnitX(picked) - targetX)
        call KnockbackUnit(source, picked, angle, speed, knockAdj)

        call GroupRemoveUnit(targets, picked)
    endloop

    call DestroyGroup(targets)

 set targets = null
 set picked = null
endfunction


endlibrary