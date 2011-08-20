// Buff system used by the map
// Public functions:
// function UnitApplyBuff takes unit caster, unit target, BuffType buffType, integer level, real duration returns nothing
// function UnitRemoveBuff takes unit whichUnit, integer buffKey returns boolean
//
// Also make sure to look at the BuffData and BuffType structs

library BuffCore initializer Init requires DamageEvent, Table, AutoIndex


globals
    // How often the periodic event is called on structs
    public constant real UPDATE_INTERVAL = .1
    
    private BuffList buffList
    private HandleTable buffTable
    
    private boolean inEvent = false
    private boolean destroyBuff = false
endglobals

//==================================================
// Structs used in the system
//==================================================

// This data is passed to each custom buff for events
struct BuffData
    unit caster
    unit target
    integer level
    real duration
    BuffType buffType   // Nothing outside the system should mess with this value
    
    boolean permanent = false
    real updateInterval = .1
    real updateCount = 0.
    integer buffKey
    
    method setUpdateInterval takes real seconds returns nothing
        set .updateInterval = seconds
    endmethod
    
    method getUpdateInterval takes nothing returns real
        return .updateInterval
    endmethod
    
    // Shouldn't be called outside of this library
    method update takes nothing returns nothing
        set .updateCount = .updateCount + UPDATE_INTERVAL
        if .updateCount >= .updateInterval then
            set .updateCount = 0.
            call .buffType.onUpdate(this)
        endif
    endmethod
    
    method removeBuff takes nothing returns nothing
     local BuffList list

        if inEvent then
            set destroyBuff = true
        else
    
            set list = buffTable[this.target]
            call list.remove(this)
            call buffList.remove(this)
            call this.destroy()

        endif
    endmethod
    
    // Only this library should destroy the buff
    method onDestroy takes nothing returns nothing
        call this.buffType.cleanup(this)
        call this.buffType.destroy()
    endmethod
endstruct

// All custom buffs should extend from this interface
interface BuffType

    // Should return a new BuffType that is essentially
    // A clone of itself, not required but is used by various
    // Add-on libraries
    method clone takes nothing returns BuffType defaults -1
    
    // Each buff needs to have its own unique key in order to
    // Differentiate it from others
    // See various other buffs to see how this is implemented
    method getKey takes nothing returns integer

    // Called when the buff is added to a unit
    method onCreate takes BuffData data returns nothing defaults nothing
    
    // Called every UPDATE_INTERVAL seconds (.10 seconds by default)
    method onUpdate takes BuffData data returns nothing defaults nothing
    
    // Called when the buff expires
    method onFinish takes BuffData data returns nothing defaults nothing
    
    // Called when the buff finishes, is destroyed, etc.
    // It is the last method called in a chain, example:
    // cleanup is called after onFinish if the buff
    // expires
    method cleanup takes BuffData data returns nothing defaults nothing
    
    // When the buff is cast on a unit that already has the buff
    // It is up to the buff to adjust the caster, level, and duration as needed
    // This is to allow more flexibility
    method onRecast takes BuffData data, unit caster, integer level, real newDuration returns nothing defaults nothing
    
    // When the unit with the buff takes damage
    method recieveDamage takes BuffData data, DamagePacket packet returns nothing defaults nothing

    // When the unit deals damage to an enemy
    method dealDamage takes BuffData data, DamagePacket packet returns nothing defaults nothing
    
    // When the unit dies
    method onDeath takes BuffData data, unit attacker returns nothing defaults nothing
    
    // When the unit kills another unit
    method onKill takes BuffData data, unit killed returns nothing defaults nothing
endinterface

// Don't access this outside of system
struct BuffList

    BuffData data = 0
    BuffList next = 0

    // Adds the data to the beginning of the list
    method add takes BuffData data returns nothing
     local BuffList list = .create()

        set list.data = data
        set list.next = this.next
        set this.next = list
    endmethod

    // No point in this method atm, but if I ever make the list doubly linked, it'll help
    method removeNode takes BuffList list returns boolean
     local BuffList trail = this
     local BuffList next
     
        loop
            set next = trail.next
            exitwhen next == 0 or next == list
            set trail = next
        endloop
        
        if next != 0 then
            set trail.next = next.next
            
            // So the .destroy() call won't recursively destroy the list
            set next.next = 0
            call next.destroy()
            
            return true
        endif

        return false
    endmethod
    
    // Removes data from the list
    // Returns true if the list contained data
    // Does NOT call .destroy() on the BuffData
    method remove takes BuffData data returns boolean
     local BuffList trail = this
     local BuffList next
     
        loop
            set next = trail.next
            exitwhen next == 0 or next.data == data
            set trail = next
        endloop
        
        if next != 0 then
            set trail.next = next.next
            
            // So the .destroy() call won't recursively destroy the list
            set next.next = 0
            call next.destroy()
            
            return true
        endif

        return false
    endmethod
    
    method contains takes BuffData data returns boolean
     local BuffList temp = this.next
     
        loop
            exitwhen temp == 0
            if temp.data == data then
                return true
            endif
            set temp = temp.next
        endloop
        
        return false
    endmethod
    
    // Recursively destroys the list
    method onDestroy takes nothing returns nothing
     local BuffList next = this.next
     
        if next != 0 then
            call next.destroy()
        endif
    endmethod

endstruct

//=======================
// End structs
//=======================

private function GetUnitBuff takes unit whichUnit, integer buffKey returns BuffData
 local BuffList list = buffTable[whichUnit]

    if list == 0 then
        return 0
    endif
    
    loop
        set list = list.next
        exitwhen list == 0
        
        if list.data.buffKey == buffKey then
            return list.data
        endif
    endloop

    return 0
endfunction

function UnitApplyBuff takes unit caster, unit target, BuffType buffType, integer level, real duration returns BuffData
 local BuffList list
 local BuffData data = GetUnitBuff(target, buffType.getKey())

    if IsUnitType(target, UNIT_TYPE_DEAD) == true then
        call buffType.destroy()
        return 0
    endif

    if buffType <= 0 then
        debug call BJDebugMsg("BuffType <= 0")
        call buffType.destroy()
        return 0
    endif

    if data == 0 then
        set data = BuffData.create()
        set list = buffTable[target]
        
        if list == 0 then
            set list = BuffList.create()
            set buffTable[target] = list
        endif
    
        set data.caster = caster
        set data.target = target
        set data.buffType = buffType
        set data.level = level
        set data.duration = duration
        set data.buffKey = buffType.getKey()
        
        call list.add(data)     // List of buffs on the unit
        call buffList.add(data) // Global list of all buffs

        call data.buffType.onCreate(data)
    else
        call buffType.destroy()
        call data.buffType.onRecast(data, caster, level, duration)
    endif

	return data
endfunction

// Please do not call from within a buff method
// If calling from within a buff method is needed,
// use the removeBuff method

function UnitRemoveBuff takes unit whichUnit, integer buffKey returns boolean
 local BuffData data = GetUnitBuff(whichUnit, buffKey)
 local BuffList list

    if data == 0 then
        return false
    endif
    
    set list = buffTable[data.target]
    call list.remove(data)
    call buffList.remove(data)
    call data.destroy()

    return true
endfunction

private function OnUpdate takes nothing returns nothing
 local BuffList unitList
 local BuffList current = buffList
 local BuffList trail = current
 local BuffData data
 
    set inEvent = true
    
    // Idiot-proofing
    if destroyBuff then
        set destroyBuff = false
    endif
 
    // Loop through all buffs
    loop
        set current = current.next
        exitwhen current == 0
        set data = current.data
        
        if not data.permanent then
            set data.duration = data.duration - UPDATE_INTERVAL
        endif

        if data.duration > 0. then
            call data.update()
        endif
        
        if (data.duration <= 0. and not data.permanent) or destroyBuff then

            set unitList = buffTable[data.target]
            
            if not destroyBuff then
                call data.buffType.onFinish(data)
            endif
            set destroyBuff = false

            call unitList.remove(data)
            call buffList.remove(data)
            set current = trail    // Set the current element to the previous element in the list

            call data.destroy()
        else
            set trail = current
        endif

    endloop
    
    set inEvent = false
endfunction

private function OnDamage_Start takes DamagePacket packet returns nothing
 local unit attacker = packet.source
 local unit attacked = packet.target
 
 local BuffList unitList = buffTable[attacker]
 local BuffList current = unitList
 local BuffList trail = unitList
 local BuffData data
 
    set inEvent = true
    
    // Idiot-proofing
    if destroyBuff then
        set destroyBuff = false
    endif
 
    if unitList > 0 then
        set current = unitList
        set trail = unitList

        loop
            set current = current.next
            exitwhen current == 0
            set data = current.data
            
            set inEvent = true
            call data.buffType.dealDamage(current.data, packet)
            
            if destroyBuff then
                set destroyBuff = false
            
                call unitList.remove(data)
                call buffList.remove(data)
                call data.destroy()
                
                set current = trail
            else
                set trail = current
            endif

        endloop
    endif
    
    set unitList = buffTable[attacked]
    if unitList > 0 then
    
        set current = unitList
        set trail = unitList
    
        loop
            set current = current.next
            exitwhen current == 0
            set data = current.data
            
            call data.buffType.recieveDamage(current.data, packet)
            
            if destroyBuff then
                set destroyBuff = false
            
                call unitList.remove(data)
                call buffList.remove(data)
                call data.destroy()
                
                set current = trail
            else
                set trail = current
            endif

        endloop
    endif
    
    set inEvent = false
endfunction

private function OnDeath_Start takes nothing returns boolean
 local unit killed = GetTriggerUnit()
 local unit attacker = GetKillingUnit()

 local BuffList unitBuffList = buffTable[attacker]
 local BuffList temp
 local BuffList trail
 local BuffData data
 
    set inEvent = true
    
    // Idiot-proofing
    if destroyBuff then
        set destroyBuff = false
    endif
 
    // Check for buffs on attacker
    if unitBuffList > 0 then
        set temp = unitBuffList
        set trail = temp
    
        // Loop through all the buffs on the unit
        loop
            set temp = temp.next
            exitwhen temp == 0
            set data = temp.data
            
            call data.buffType.onKill(temp.data, killed)
            
            if destroyBuff then
                set destroyBuff = false
            
                call unitBuffList.remove(data)
                call buffList.remove(data)
                call data.destroy()
                
                set temp = trail
            else
                set trail = temp
            endif
            
        endloop
    endif
    
    set unitBuffList = buffTable[killed]
    
    // Check for buffs on killed unit
    if unitBuffList > 0 then
    
        // Loop through all the buffs on the unit
        set temp = unitBuffList
        loop
            set temp = temp.next
            exitwhen temp == 0
            set data = temp.data
            
            // Call onDeath method and destroy buff
            call data.buffType.onDeath(temp.data, attacker)
            call buffList.remove(data) // Remove the buff from the global buff list
            call data.destroy()
        endloop
        
        call unitBuffList.destroy()
        call buffTable.flush(killed)

        // Idiot-proofing
        if destroyBuff then
            set destroyBuff = false
        endif
        
    endif
    
    set inEvent = false

    return false
endfunction

private function OnLeaveMap takes unit u returns nothing
 local BuffList unitBuffList = buffTable[u]
 local BuffList temp
 local BuffData data

    if unitBuffList == 0 then
        return
    endif

    set temp = unitBuffList
    loop
        set temp = temp.next
        exitwhen temp == 0

        set data = temp.data
        call data.destroy()
    endloop

    call unitBuffList.destroy()
    call buffTable.flush(u)
endfunction

private function Init takes nothing returns nothing
 local trigger t
 
    set buffList = buffList.create()
    set buffTable = HandleTable.create()

    // Register callbacks for various events
    
    call TimerStart(CreateTimer(), UPDATE_INTERVAL, true, function OnUpdate)

    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddCondition(t, Condition(function OnDeath_Start))
    
    call DamageEvent_Create(OnDamage_Start, 5)
    call OnUnitDeindexed(OnLeaveMap)
    
 set t = null
endfunction


endlibrary