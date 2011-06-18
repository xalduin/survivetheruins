library TimedEffects requires TimerStack, LocationFunctions, ExportedUnitData


struct EffectData
 effect addedEffect
endstruct

function AddEffectTimed_Callback takes nothing returns nothing
 local timer effectTimer = GetExpiredTimer()
 local EffectData effectData = GetTimerData(effectTimer)

    call DestroyEffect(effectData.addedEffect)
    call effectData.destroy()
    call ReleaseTimer(effectTimer)
endfunction

function AddEffectTimed takes effect e, real duration returns nothing
 local timer effectTimer = NewTimer()
 local EffectData effectData = EffectData.create()

    set effectData.addedEffect = e
    call SetTimerData(effectTimer, effectData)

    call TimerStart(effectTimer, duration, false, function AddEffectTimed_Callback)
endfunction

//===============================================
// Timed Lightning
//===============================================
// Used to help mimic lightning effects from spells
// Will create lightning and update it so it's
// Always between the two specified units

// Loads unit projectile impact Z
//##! LoadUnitData fields=uimz

globals
    private constant real UPDATE_INTERVAL = .05
endglobals

private struct LightningData
    unit s  // Source
    unit t  // Target
    real duration
    lightning bolt
endstruct

private function TimedLightningUnit_Callback takes nothing returns nothing
 local timer expired = GetExpiredTimer()
 local LightningData data = GetTimerData(expired)
 local real sz
 local real tz
 
    set data.duration = data.duration - UPDATE_INTERVAL
    if data.duration <= 0. then

        call ReleaseTimer(expired)
        call DestroyLightning(data.bolt)
        call data.destroy()
        set expired = null

        return
    endif
    
    set sz = GetUnitZ(data.s) + GetUnitTypeProjectileImpactZ(GetUnitTypeId(data.s))
    set tz = GetUnitZ(data.t) + GetUnitTypeProjectileImpactZ(GetUnitTypeId(data.t))
    
    call MoveLightningEx(data.bolt, true, GetUnitX(data.s), GetUnitY(data.s), sz, GetUnitX(data.t), GetUnitY(data.t), tz)

 set expired = null
endfunction

function TimedLightningUnit takes unit source, unit target, string name, real duration returns lightning
 local real sx = GetUnitX(source)
 local real sy = GetUnitY(source)
 local real sz = GetUnitZ(source) + GetUnitTypeProjectileImpactZ(GetUnitTypeId(source))
 local real tx = GetUnitX(target)
 local real ty = GetUnitY(target)
 local real tz = GetUnitZ(target) + GetUnitTypeProjectileImpactZ(GetUnitTypeId(target))
 local lightning light = AddLightningEx(name, true, sx, sy, sz, tx, ty, tz)
 local timer t = NewTimerStart(UPDATE_INTERVAL, true, function TimedLightningUnit_Callback)
 local LightningData data = LightningData.create()
 
    set data.s = source
    set data.t = target
    set data.duration = duration
    set data.bolt = light
    call SetTimerData(t, data)
 
    set bj_lastCreatedLightning = light
    set light = null
    set t = null
 
    return bj_lastCreatedLightning
endfunction


endlibrary