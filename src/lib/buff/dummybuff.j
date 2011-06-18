// Used for adding dummy buffs to units

library DummyBuff requires Table


// Borrowed from xepreload
static if DEBUG_MODE then
    private function DebugIdInteger2IdString takes integer value returns string
     local string charMap = ".................................!.#$%&'()*+,-./0123456789:;<=>.@ABCDEFGHIJKLMNOPQRSTUVWXYZ[.]^_`abcdefghijklmnopqrstuvwxyz{|}~................................................................................................................................."
     local string result = ""
     local integer remainingValue = value
     local integer charValue
     local integer byteno

     set byteno = 0
     loop
         set charValue = ModuloInteger(remainingValue, 256)
         set remainingValue = remainingValue / 256
         set result = SubString(charMap, charValue, charValue + 1) + result
 
         set byteno = byteno + 1
         exitwhen byteno == 4
     endloop
     return result
    endfunction
endif

struct DummyBuff
    unit target
    integer abilityId
    integer buffId
    
    public static method create takes unit target, integer abilityId, integer buffId returns DummyBuff
     local DummyBuff this = .allocate()
     local string unitkey = I2S(GetHandleId(target))
     
        set this = .allocate()
        set this.target = target
        set this.abilityId = abilityId
        set this.buffId = buffId
        
        set Table[unitkey][abilityId] = Table[unitkey][abilityId] + 1
        
        call UnitAddAbility(target, abilityId)
        
        return this
    endmethod
    
    private method onDestroy takes nothing returns nothing
     local string unitkey = I2S(GetHandleId(this.target))
     local integer count = Table[unitkey][this.abilityId] - 1
    
        if count < 0 then
            debug call BJDebugMsg("|cffff0000Struct DummyBuff Error:|r count value = (" + DebugIdInteger2IdString(count) + ") for abilityId = '" + I2S(abilityId) + "'")
            return
        endif
     
        set Table[unitkey][this.abilityId] = count
     
        if count <= 0 then
            call UnitRemoveAbility(this.target, this.abilityId)
            call UnitRemoveAbility(this.target, this.buffId)
        endif
    endmethod

endstruct

// Non-struct version

function UnitAddDummyBuff takes unit target, integer abilityId, integer buffId returns nothing
 local string unitkey = I2S(GetHandleId(target))

    set Table[unitkey][abilityId] = Table[unitkey][abilityId] + 1

    call UnitAddAbility(target, abilityId)
endfunction

function UnitRemoveDummyBuff takes unit target, integer abilityId, integer buffId returns nothing
 local string unitkey = I2S(GetHandleId(target))
 local integer count = Table[unitkey][abilityId]
 
    if count == 0 then
        debug call BJDebugMsg("|cffff0000DummyBuff Error:|r No Table entry exists for abilityId '" + DebugIdInteger2IdString(abilityId) + "'")
        return
    elseif count < 0 then
        debug call BJDebugMsg("|cffff0000DummyBuff Error:|r count value = (" + I2S(count) + ") for abilityId = '" + DebugIdInteger2IdString(abilityId) + "'")
        return
    else
        set count = count - 1
    endif
     
    set Table[unitkey][abilityId] = count
     
    if count <= 0 then
        call UnitRemoveAbility(target, abilityId)
        call UnitRemoveAbility(target, buffId)
    endif
endfunction


endlibrary