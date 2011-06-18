library LocationFunctions initializer InitMisc

globals
    private location miscLoc
    private rect mapBounds
    real MIN_X
    real MAX_X
    real MIN_Y
    real MAX_Y
endglobals

function GetUnitZ takes unit whichUnit returns real
    call MoveLocation(miscLoc, GetUnitX(whichUnit), GetUnitY(whichUnit))
    return GetLocationZ(miscLoc) + GetUnitFlyHeight(whichUnit)
endfunction

function GetTerrainHeight takes real x, real y returns real
    call MoveLocation(miscLoc, x, y)
    return GetLocationZ(miscLoc)
endfunction

function InitMisc takes nothing returns nothing
    set miscLoc = Location(0.,0.)
    set mapBounds = GetWorldBounds()
    set MIN_X = GetRectMinX(mapBounds)
    set MAX_X = GetRectMaxX(mapBounds)
    set MIN_Y = GetRectMinY(mapBounds)
    set MAX_Y = GetRectMaxY(mapBounds)
endfunction


endlibrary

// Actual system

library Projectile requires TimerStack, LocationFunctions, xebasic

globals
    private constant real updateInterval = .034
    private constant integer dummyId = XE_DUMMY_UNITID
endglobals

function interface projectileFunc takes unit dummy, integer data returns nothing

struct SimpleProjectile
    private unit dummy
    private real cx
    private real cy
    private real dx
    private real dy
    private real updates
    private integer data
    private effect model
    
    private boolean done = false

    private timer projectileTimer = null
    private real timeElapsed = 0.
    private real periodicInterval = 0.
    private projectileFunc periodicFunc = 0
    private projectileFunc endFunc = 0
    
    method getDummy takes nothing returns unit
        return this.dummy
    endmethod
    
    method getStruct takes nothing returns integer
        return this.data
    endmethod

    private static method updateStatic takes nothing returns nothing
     local timer t = GetExpiredTimer()
     local SimpleProjectile data = SimpleProjectile( GetTimerData(t) )

        call data.update(t)
        set t = null
    endmethod
    
    method end takes nothing returns nothing
     local integer temp = data
     local projectileFunc callback = endFunc

        call ReleaseTimer(projectileTimer)
        call this.destroy()

        if callback > 0 and temp > 0 then
            call endFunc.evaluate(dummy, data)
        endif
    endmethod
    
    private method update takes timer t returns nothing
        if updates <= 0 then
            call this.end()
            return
                
        elseif updates < 1.0 then
            set dx = dx * updates
            set dy = dy * updates
        endif

        set cx = cx + dx
        set cy = cy + dy
        
        // If projectile is going out of bounds, end it
        if RMaxBJ(RMinBJ(cx, MAX_X), MIN_X) != cx or RMaxBJ(RMinBJ(cy, MAX_Y), MIN_Y) != cy then
            call this.end()
            return
        endif

        call SetUnitX(dummy, cx)
        call SetUnitY(dummy, cy)
        call SetUnitAnimationByIndex(dummy, 90)
        
        if periodicFunc > 0 and periodicInterval > 0. then
            set timeElapsed = timeElapsed + updateInterval

            if timeElapsed >= periodicInterval then
                call periodicFunc.evaluate(dummy, data)
                set timeElapsed = timeElapsed - periodicInterval
            endif
        endif

        set updates = updates - 1
    endmethod
        
    static method create takes real sx, real sy, real tx, real ty, real height, real speed returns SimpleProjectile
        local SimpleProjectile this = SimpleProjectile.allocate()
        local real angle = Atan2(ty - sy, tx - sx) 
        local real distance = DistanceBetweenCoords(sx, sy, tx, ty)

        set speed = speed * updateInterval
        set this.cx = sx
        set this.cy = sy
        set this.dx = speed * Cos(angle)
        set this.dy = speed * Sin(angle)
        set this.updates = distance / speed
        
        set this.dummy = CreateUnit(Player(15), dummyId, sx, sy, angle * bj_RADTODEG)
        set this.model = null
        
        set this.data = 0
        set this.timeElapsed = 0.
        set this.periodicInterval = 0.
        set this.periodicFunc = 0
        set this.endFunc = 0
        call UnitAddAbility(this.dummy, 'Amrf')
        call SetUnitFlyHeight(this.dummy, height, 1000.)
        
        return this
    endmethod
    
    method start takes integer data, projectileFunc func returns nothing
     local timer t = NewTimer()
        
        set this.data = data
        set this.endFunc = func
        set this.projectileTimer = t
            
        call SetTimerData(t, this)
        call TimerStart(t, updateInterval, true, function SimpleProjectile.updateStatic)
        
        set t = null
    endmethod
    
    method periodic takes integer data, real interval, projectileFunc period, projectileFunc end returns nothing
     local timer t = NewTimer()
        
        set this.data = data
        set this.periodicInterval = RMaxBJ(interval, 0.)
        set this.periodicFunc = period
        set this.endFunc = end
        set this.projectileTimer = t
            
        call SetTimerData(t, this)
        call TimerStart(t, updateInterval, true, function SimpleProjectile.updateStatic)
        
        set t = null
    endmethod
    
    method setModel takes string model returns nothing
        if model != null and model != "" then
            set this.model = AddSpecialEffectTarget(model, this.dummy, "origin")
        endif
    endmethod
    
    method onDestroy takes nothing returns nothing
        if this.model != null then
            call DestroyEffect(this.model)
        endif

        call UnitApplyTimedLife(dummy, 'BTLF', 5.)
    endmethod
endstruct

endlibrary