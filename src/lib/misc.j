library MiscFunctions requires UnitUtils, xebasic


globals
    constant integer dummyCasterId = XE_DUMMY_UNITID
    constant integer REVIVE_ABILITY_ID = 'A003'
endglobals

function AngleDifference takes real a1, real a2 returns real
 local real x
    set a1=ModuloReal(a1,360)
    set a2=ModuloReal(a2,360)
    if a1>a2 then
        set x=a1
        set a1=a2
        set a2=x
    endif
    set x=a2-360
    if a2-a1 > a1-x then
        set a2=x
    endif
 return RAbsBJ(a1-a2)
endfunction

function DistanceBetweenCoords takes real x1, real y1, real x2, real y2 returns real
 local real x = x1 - x2
 local real y = y1 - y2
 
    return SquareRoot(x*x + y*y)
endfunction

function Error takes string category, string description returns nothing
    call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., "|cffff0000" + category + ":|r " + description)
endfunction

private struct PlayerStruct
    player p
    real duration = 0.
endstruct

// Fades to black
function CameraFadeOut takes player whichPlayer, real duration returns nothing
 local integer startTrans = 0
    if duration == 0 then
        set startTrans = 255
    endif

    if GetLocalPlayer() == whichPlayer then
        call EnableUserUI(false)
        call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\Black_mask.blp")
        call SetCineFilterBlendMode(BLEND_MODE_BLEND)
        call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
        call SetCineFilterStartUV(0, 0, 1, 1)
        call SetCineFilterEndUV(0, 0, 1, 1)
        call SetCineFilterStartColor(255, 255, 255, startTrans)
        call SetCineFilterEndColor(0, 0, 0, 255)
        call SetCineFilterDuration(duration)
        call DisplayCineFilter(true)
    endif
endfunction

private function CameraFadeInFinish takes nothing returns nothing
 local timer expired = GetExpiredTimer()
 local PlayerStruct data = GetTimerData(expired)
 
    if GetLocalPlayer() == data.p then
        call EnableUserUI(true)
        call DisplayCineFilter(false)
    endif
    call data.destroy()
    call ReleaseTimer(expired)

 set expired = null
endfunction

// Fades from black to regular
function CameraFadeIn takes player whichPlayer, real duration returns nothing
 local timer t = NewTimerStart(duration, false, function CameraFadeInFinish)
 local PlayerStruct data = PlayerStruct.create()

 local integer startTrans = 255
    if duration == 0 then
        set startTrans = 0
    endif

    if GetLocalPlayer() == whichPlayer then
        call EnableUserUI(false)
        call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\Black_mask.blp")
        call SetCineFilterBlendMode(BLEND_MODE_BLEND)
        call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
        call SetCineFilterStartUV(0, 0, 1, 1)
        call SetCineFilterEndUV(0, 0, 1, 1)
        call SetCineFilterStartColor(255, 255, 255, startTrans)
        call SetCineFilterEndColor(0, 0, 0, 0)
        call SetCineFilterDuration(duration)
        call DisplayCineFilter(true)
    endif
    
    set data.p = whichPlayer
    call SetTimerData(t, data)

 set t = null
endfunction

private function CameraFade_Callback takes nothing returns nothing
 local timer expired = GetExpiredTimer()
 local PlayerStruct data = GetTimerData(expired)
 
    call CameraFadeIn(data.p, data.duration)

    call data.destroy()
    call ReleaseTimer(expired)

 set expired = null
endfunction

function CameraFade takes player whichPlayer, real fadeOutDuration, real fadeInDuration returns nothing
 local timer t = NewTimerStart(fadeOutDuration, false, function CameraFade_Callback)
 local PlayerStruct data = PlayerStruct.create()
 
    call CameraFadeOut(whichPlayer, fadeOutDuration)
    set data.p = whichPlayer
    set data.duration = fadeInDuration
    call SetTimerData(t, data)
    
 set t = null
endfunction


endlibrary