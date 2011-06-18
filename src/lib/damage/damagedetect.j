//By CaptainGriffen

library LightLeaklessDamageDetect initializer Init
    
    // Creating threads off of this that last longer than the timeout below will likely cause issues, like everything blowing up (handle stack corruption)
    // It seems that threads created by timers, rather than executefunc / .evaluate / .execute are not affected. Any threads created from the timer thread are fine.
    // This being safe with even the usage laid out above isn't guarenteed. Use at own risk.
    // If you start getting random bugs, see if commenting out the timer line below (see comments) helps
    // If it does, report it in the thread for this script at [url]www.wc3campaigns.net[/url]
    
    globals
        private constant real SWAP_TIMEOUT = 600. // keep high; 600 should be about the right balance.
    endglobals
    
    globals
        private conditionfunc array func
        private integer funcNext = 0
        private trigger current = null
        private trigger toDestroy = null
        private group swapGroup
        private rect mapRect
    endglobals
    
    // One of the only accessible functions. Use it to add a condition. Must return boolean type, and then have return false at the end.
    // Note that it's technically a condition, so if you put a wait in there, it'll die. But waits are lame anyway.
    function AddOnDamageFunc takes conditionfunc cf returns nothing
        call TriggerAddCondition(current, cf)
        set func[funcNext] = cf
        set funcNext = funcNext + 1
    endfunction
    
    // These inline. For avoiding feedback loops. Feel free to make your own wrapper function for damage functions using this.
    function DisableDamageDetect takes nothing returns nothing
        call DisableTrigger(current)
    endfunction
    function EnableDamageDetect takes nothing returns nothing
        call EnableTrigger(current)
    endfunction
    
    // no more accessible functions, folks.
    
    //! textmacro CGLeaklessDamageDetectAddFilter takes UNIT
        
        // add here any conditions to add the unit to the trigger, example below, commented out:
        // if GetUnitTypeId($UNIT$) != 'h000' then // where 'h000' is a dummy unit
        call TriggerRegisterUnitEvent(current, $UNIT$, EVENT_UNIT_DAMAGED)
        // endif
        
    //! endtextmacro
    
    private function AddEx takes nothing returns boolean
        //! runtextmacro CGLeaklessDamageDetectAddFilter("GetFilterUnit()")
        return false
    endfunction

    private function Enters takes nothing returns boolean
        //! runtextmacro CGLeaklessDamageDetectAddFilter("GetTriggerUnit()")
        return false
    endfunction
    
    private function Swap takes nothing returns nothing
        local integer i = 0
        local boolean b = IsTriggerEnabled(current)
        
        call DisableTrigger(current)
        if toDestroy != null then
            call DestroyTrigger(toDestroy)
        endif
        set toDestroy = current
        set current = CreateTrigger()
        
        if not(b) then
            call DisableTrigger(current)
        endif
        
        call GroupEnumUnitsInRect(swapGroup, mapRect, Filter(function AddEx))
        
        loop
            exitwhen i >= funcNext
            call TriggerAddCondition(current, func[i])
            set i = i + 1
        endloop
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local region r = CreateRegion()
        local integer i = 0
        set mapRect = GetWorldBounds()
        call RegionAddRect(r, mapRect)
        call TriggerRegisterEnterRegion(t, r, null)
        call TriggerAddCondition(t, Condition(function Enters))
        
        set swapGroup = CreateGroup()
        
        set current = CreateTrigger()
        loop
            exitwhen i >= funcNext
            call TriggerAddCondition(current, func[i])
            set i = i + 1
        endloop
        
        call GroupEnumUnitsInRect(swapGroup, GetWorldBounds(), Filter(function AddEx))
        
        // Commenting out the next line will make the system leak indexes and events, but should make it safer.
        call TimerStart(CreateTimer(), SWAP_TIMEOUT, true, function Swap)
    endfunction
    
endlibrary