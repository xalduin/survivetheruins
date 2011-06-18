// Convenience functions for working with buffs

library BuffUtils requires BuffCore, DummyBuff

// Implement this module in a BuffType struct and it'll automatically handle
// the getKey method for you
module BuffKey
    private static key BUFFKEY
    method getKey takes nothing returns integer
        return this.BUFFKEY
    endmethod
endmodule
// Should only be used if there's no buffType-specific data to actually copy
// when cloning the struct
module DefaultClone
    method clone takes nothing returns BuffType
        return thistype.create()
    endmethod
endmodule

function AOEApplyBuff takes unit caster, real x, real y, real radius, boolexpr filter, BuffType buffType, integer level, real duration returns nothing
 local unit picked
 
    call GroupClear(ENUM_GROUP)
    call GroupEnumUnitsInRange(ENUM_GROUP, x, y, radius, filter)
    
    loop
        set picked = FirstOfGroup(ENUM_GROUP)
        exitwhen picked == null
        
        call UnitApplyBuff(caster, picked, buffType.clone(), level, duration)
        
        call GroupRemoveUnit(ENUM_GROUP, picked)
    endloop
    
    call GroupClear(ENUM_GROUP)
    call buffType.destroy()
    
 set picked = null
endfunction

globals
    private unit tempUnit
    private BuffType tempBuff
    private integer tempInt
    private real tempReal
endglobals

private function GroupApplyBuff_Callback takes nothing returns nothing
    call UnitApplyBuff(tempUnit, GetEnumUnit(), tempBuff.clone(), tempInt, tempReal)
endfunction

function GroupApplyBuff takes unit caster, group target, BuffType buffType, integer level, real duration returns nothing
    set tempUnit = caster
    set tempBuff = buffType
    set tempInt = level
    set tempReal = duration
    call ForGroup(target, function GroupApplyBuff_Callback)
    call buffType.destroy()
endfunction
    

endlibrary