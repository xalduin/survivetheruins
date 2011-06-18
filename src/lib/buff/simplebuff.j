// A library of simple buffs so that common buffTypes don't have to be recreated

library SimpleBuff initializer Init requires DummyBuff, UnitStats, PreloadAbility, BuffUtils


globals
    private constant integer frostAura = 'A03Q'
    private constant integer frostBuff = 'B00I'
    
    // Mimics the "frost" debuff from Wc3
    private constant real attackSpeedReduction = -.1
    private constant real moveSpeedReduction = -.25
    private constant key frostKey
endglobals

// A buff that does nothing more than show a dummy buff
// Be sure to set auraId and buffId before applying it
struct SimpleBuff extends BuffType
    integer auraId = 0
    integer buffId = 0
    private integer key
    
    method getKey takes nothing returns integer
        return this.key
    endmethod
    
    method clone takes nothing returns BuffType
     local thistype clone = thistype.create(key)
        set clone.auraId = this.auraId
        set clone.buffId = this.buffId
        return clone
    endmethod
    
    static method create takes integer key returns thistype
     local thistype this = thistype.allocate()
        set this.key = key
        return this
    endmethod
    
    method onCreate takes BuffData data returns nothing
        if auraId != 0 and buffId != 0 then
            call UnitAddDummyBuff(data.target, auraId, buffId)
        endif
    endmethod
    
    method onRecast takes BuffData oldData, unit caster, integer level, real newDuration returns nothing
        set oldData.duration = RMaxBJ(oldData.duration, newDuration)
        set oldData.level = IMaxBJ(oldData.level, level)
        set oldData.caster = caster
    endmethod

    method cleanup takes BuffData data returns nothing
        if auraId != 0 and buffId != 0 then
            call UnitRemoveDummyBuff(data.target, auraId, buffId)
        endif
    endmethod
endstruct

// SimpleBuff + attack/move slowing
// Cannot change the attack/movement slow on the fly
struct SpeedBuff extends BuffType
    integer auraId = 0
    integer buffId = 0
    private real attackSlow = 0.
    private real movementSlow = 0.
    private boolean active = false
    private integer key
    
    method getKey takes nothing returns integer
        return this.key
    endmethod
    
    method clone takes nothing returns BuffType
     local thistype clone = thistype.create(key)
        set clone.auraId = this.auraId
        set clone.buffId = this.buffId
        set clone.attackSlow = this.attackSlow
        set clone.movementSlow = this.movementSlow
        return clone
    endmethod
    
    static method create takes integer key returns thistype
     local thistype this = thistype.allocate()
        set this.key = key
        return this
    endmethod
    
    method operator attackMultiplier= takes real value returns boolean
        if not active then
            set attackSlow = value
            return true
        endif
        return false
    endmethod

    method operator movementMultiplier= takes real value returns boolean
        if not active then
            set movementSlow = value
            return true
        endif
        return false
    endmethod

    method onCreate takes BuffData data returns nothing
        set active = true
        if auraId != 0 and buffId != 0 then
            call UnitAddDummyBuff(data.target, auraId, buffId)
        endif

        if attackSlow != 0. or movementSlow != 0. then
            if attackSlow != 0. then
                call AddUnitAttackSpeedMult(data.target, attackSlow)
            endif
            if movementSlow != 0. then
                call AddUnitMoveSpeedMult(data.target, movementSlow)
            endif
            call UnitStats_Update(data.target)
        endif
    endmethod
    
    method onRecast takes BuffData oldData, unit caster, integer level, real newDuration returns nothing
        set oldData.duration = RMaxBJ(oldData.duration, newDuration)
        set oldData.level = IMaxBJ(oldData.level, level)
        set oldData.caster = caster
    endmethod
    
    method cleanup takes BuffData data returns nothing
        if auraId != 0 and buffId != 0 then
            call UnitRemoveDummyBuff(data.target, auraId, buffId)
        endif

        if attackSlow != 0. or movementSlow != 0. then
            if attackSlow != 0. then
                call AddUnitAttackSpeedMult(data.target, -attackSlow)
            endif
            if movementSlow != 0. then
                call AddUnitMoveSpeedMult(data.target, -movementSlow)
            endif
            call UnitStats_Update(data.target)
        endif
    endmethod
endstruct

// Returns a SpeedBuff with a predefined frost dummy buff
function FrostBuff takes integer key, real atkSlow, real movSlow returns SpeedBuff
 local SpeedBuff this = SpeedBuff.create(key)
    set this.auraId = frostAura
    set this.buffId = frostBuff
    set this.attackMultiplier = atkSlow
    set this.movementMultiplier = movSlow
    return this
endfunction

// Meant to replace the frost attack slowing in Wc3
function ColdBuff takes nothing returns SpeedBuff
    return FrostBuff(frostKey, attackSpeedReduction, moveSpeedReduction)
endfunction

private function Init takes nothing returns nothing
    call PreloadAbility(frostAura)
endfunction


endlibrary