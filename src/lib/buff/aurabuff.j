// Immitates an aura
// Make sure to set all proper values before applying

struct AuraBuff extends BuffType
    integer auraId = 0              // Dummy Aura Id
    integer buffId = 0              // Dummy Buff Id
    real aoe = 0.                   // AoE of the aura
    boolexpr filter = null          // Filter for what units to apply buff to
    BuffType buffType = 0           // BuffType to apply to units in AoE
    integer level = 0               // Level of BuffType to apply
    real duration = 0.              // How long buff lasts once out of range of aura
                                    // While in range, note that the buff is constantly re-added
    boolean permanent = false       // Should the AuraBuff ignore the duration that it is assigned?
    private integer key
    
    method getKey takes nothing returns integer
        return this.key
    endmethod
    
    method clone takes nothing returns BuffType
     local thistype clone = thistype.create(key)
        set clone.auraId = this.auraId
        set clone.buffId = this.buffId
        set clone.aoe = this.aoe
        set clone.filter = this.filter
        set clone.buffType = this.buffType.clone()
        set clone.level = this.level
        set clone.duration = this.duration
        set clone.permanent = this.permanent

        return clone
    endmethod
    
    static method create takes integer key returns thistype
     local thistype this = thistype.allocate()
        set this.key = key
        return this
    endmethod
    
    public method onCreate takes BuffData data returns nothing
        if auraId != 0 and buffId != 0 then
            call UnitAddDummyBuff(data.target, auraId, buffId)
        endif
        set data.permanent = this.permanent
        call data.setUpdateInterval(.5)
    endmethod
    
    method onUpdate takes BuffData data returns nothing
        if buffType <= 0 or duration <= 0. or aoe <= 0. or filter == null then
            return
        endif

        set filterPlayer = GetOwningPlayer(data.target)
        call AOEApplyBuff(data.target, GetUnitX(data.target), GetUnitY(data.target), aoe, filter, buffType.clone(), level, duration)
    endmethod

    method onRecast takes BuffData oldData, unit caster, integer level, real newDuration returns nothing
        set oldData.duration = RMaxBJ(oldData.duration, newDuration)
        set oldData.level = IMaxBJ(oldData.level, level)
        set oldData.caster = caster
    endmethod

    public method cleanup takes BuffData data returns nothing
        if auraId != 0 and buffId != 0 then
            call UnitRemoveDummyBuff(data.target, auraId, buffId)
        endif
        if this.buffType > 0 then
            call buffType.destroy()
        endif
    endmethod
endstruct