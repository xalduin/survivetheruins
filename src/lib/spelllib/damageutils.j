// A library for convenient damage functions
// AoE damage, group damage, healing, etc

library DamageFunctions requires TimerStack, DamageEvent


struct SFX
    string model
    real time
    
    method startXY takes real x, real y returns nothing
     local effect e = AddSpecialEffect(this.model, x, y)
        if this.time > 0. then
            call AddEffectTimed(e, this.time)
        else
            call DestroyEffect(e)
        endif
     set e = null
    endmethod
    
    method startTarget takes unit target returns nothing
     local effect e = AddSpecialEffectTarget(this.model, target, "")
        if this.time > 0. then
            call AddEffectTimed(e, this.time)
        else
            call DestroyEffect(e)
        endif
     set e = null
    endmethod

endstruct

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

function DamageAreaSFX takes unit attacker, real damage, real x, real y, real radius, integer damageType, boolexpr filter, string model returns nothing
 local group targets = CreateGroup()
 local unit picked
 
    call GroupEnumUnitsInRange(targets, x, y, radius, filter)
    loop
        set picked = FirstOfGroup(targets)
        exitwhen picked == null

        call DamageTarget(attacker, picked, damage, damageType)
        call DestroyEffect(AddSpecialEffect(model, GetUnitX(picked), GetUnitY(picked)))

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

struct DoTData
 unit caster
 unit target
 real damagePerInterval
 real duration
 real rate
 integer damageType
endstruct

function DamageOverTime_Callback takes nothing returns nothing
 local timer damageTimer = GetExpiredTimer()
 local DoTData dotData = GetTimerData(damageTimer)

    call DamageTarget(dotData.caster, dotData.target, dotData.damagePerInterval, dotData.damageType)
    
    set dotData.duration = dotData.duration - dotData.rate
    if dotData.duration <= 0 or GetWidgetLife(dotData.target) <= .405 then
    
        call dotData.destroy()
        call ReleaseTimer(damageTimer)

    endif
endfunction

function DamageOverTime takes unit caster, unit target, real totalDamage, real duration, real rate, integer damageType returns nothing
 local timer damageTimer = NewTimer()
 local DoTData dotData = DoTData.create()

    set dotData.caster = caster
    set dotData.target = target
    set dotData.damagePerInterval = totalDamage / (duration / rate)
    set dotData.duration = duration
    set dotData.rate = rate

    set dotData.damageType = damageType

    call SetTimerData(damageTimer, dotData)

    call TimerStart(damageTimer, rate, true, function DamageOverTime_Callback)
endfunction

// divided = is the heal amount split between units in area
function HealArea takes real heal, boolean divided, real x, real y, real radius, boolexpr filter, SFX sfx returns nothing
 local group units = CreateGroup()
 local unit picked
 local integer count
 
    call GroupEnumUnitsInRange(units, x, y, radius, filter)
    
    if divided then
        set count = CountUnitsInGroup(units)
        if count > 0 then
            set heal = heal / I2R(count)
        endif
    endif
    
    loop
        set picked = FirstOfGroup(units)
        exitwhen picked == null
        
        if sfx != 0 then
            call sfx.startTarget(picked)
        endif
        
        call SetUnitLifeBJ(picked, GetWidgetLife(picked) + heal)
        
        call GroupRemoveUnit(units, picked)
    endloop

    call DestroyGroup(units)
 set units = null
 set picked = null
endfunction


endlibrary