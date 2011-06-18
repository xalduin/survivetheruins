struct ImmolationBuff extends BuffType
    real aoe
    real damage
    integer damageType
    boolexpr filter

    private integer key
    
    method getKey takes nothing returns integer
        return .key
    endmethod
    
    static method create takes real aoe, real damage, integer damageType, boolexpr filter, integer key returns ImmolationBuff
     local ImmolationBuff this = ImmolationBuff.allocate()
     
        set .aoe = aoe
        set .damage = damage
        set .damageType = damageType
        set .filter = filter
        set .key = key
        
        return this
    endmethod
    
    method onCreate takes BuffData data returns nothing
        call data.setUpdateInterval(1.)
    endmethod
    
    method onUpdate takes BuffData data returns nothing
        set filterPlayer = GetOwningPlayer(data.target)
        call DamageArea(data.target, .damage, GetUnitX(data.target), GetUnitY(data.target), .aoe, .damageType, .filter)
    endmethod
endstruct