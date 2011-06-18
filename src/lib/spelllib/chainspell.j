library ChainSpell requires TimerStack, LocationFunctions


globals
    public constant integer STOP = -1
    public constant integer CONTINUE = 1
    
    private group ChainGroup = CreateGroup()
endglobals

function interface ChainCallback takes unit target, unit previous, ChainSpell data returns nothing

struct ChainSpell
    unit caster = null
    private unit previousHit = null

    real centerX = 0.
    real centerY = 0.
    real radius = 0.
    boolexpr targetFilter = null
    
    integer maxHits = -1
    boolean repeat = false
    
    ChainCallback onHit = 0
    ChainCallback onFinish = 0
    
    integer dataStruct = 0
    
    private group hitUnits = null
    
    public static method create takes nothing returns ChainSpell
     local ChainSpell this = ChainSpell.allocate()
     
        /*set this.caster = null
        set this.previousHit = null
        set this.centerX = 0.
        set this.centerY = 0.
        set this.radius = 0.
        set this.targetFilter = null
        set this.onHit = 0
        set this.onFinish = 0
        set this.repeat = false
        set this.maxHits = 0
        set this.dataStruct = 0*/
        set this.hitUnits = CreateGroup()
     
        return this
    endmethod
    
    public method start takes unit target, real delay returns boolean
     local timer t = NewTimerStart(delay, true, function ChainSpell.staticCallback)

        set this.centerX = GetUnitX(target)
        set this.centerY = GetUnitY(target)
     
        if this.onHit <= 0 then
            call ReleaseTimer(t)
            call this.destroy()
            return false
        endif
        
        call this.hit(target, null)
        
        if this.maxHits > 0 then
            call SetTimerData(t, this)
        else
            if this.onFinish > 0 then
                call this.onFinish.execute(null, this.previousHit, this)
            endif
            call ReleaseTimer(t)
        endif

        set t = null
        return true
    endmethod
    
    private method hit takes unit target, unit previous returns nothing
        if target != null then
            call this.onHit.execute(target, previous, this)
            call GroupAddUnit(this.hitUnits, target)
            set this.maxHits = this.maxHits - 1
            set this.previousHit = target
        endif
    endmethod
    
    private method onUpdate takes nothing returns boolean
     local unit picked
     local boolean continue = true
     
        set filterPlayer = GetOwningPlayer(this.caster)
        call GroupEnumUnitsInRange(ChainGroup, this.centerX, this.centerY, this.radius, this.targetFilter)
        
        call GroupRemoveGroup(this.hitUnits, ChainGroup)
        set picked = FirstOfGroup(ChainGroup)

        if picked == null and this.repeat then
            call GroupClear(this.hitUnits)
            call GroupEnumUnitsInRange(ChainGroup, this.centerX, this.centerY, this.radius, this.targetFilter)
            set picked = FirstOfGroup(ChainGroup)
        endif
        
        if picked != null then
            call this.hit(picked, this.previousHit)
            set this.previousHit = picked
            
            if this.maxHits <= 0 then
                set continue = false
            endif
        else
            set continue = false
        endif
        
        call GroupClear(ChainGroup)
        
        if not continue and this.onFinish > 0 then
            call this.onFinish.execute(null, this.previousHit, this)
        endif
    
        set picked = null
        return continue
    endmethod
    
    private static method staticCallback takes nothing returns nothing
     local timer expired = GetExpiredTimer()
     local ChainSpell this = GetTimerData(expired)
     
        if not this.onUpdate() then
            call ReleaseTimer(expired)
            call this.destroy()
        endif
    endmethod
    
    method destroy takes nothing returns nothing
        call DestroyGroup(this.hitUnits)
    endmethod
endstruct


endlibrary