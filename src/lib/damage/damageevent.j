library DamageEvent initializer Init requires LinkedList


globals
    constant integer DAMAGE_TYPE_EXTRA = 0

    private List EventList = 0
    private integer damageTypeCount = 0
endglobals

// Returns a unique integer used for damage types
public function NewDamageType takes nothing returns integer
	set damageTypeCount = damageTypeCount + 1
	return damageTypeCount
endfunction

function interface DamageResponse takes DamagePacket packet returns nothing

private struct DamageEvent
    DamageResponse func
    integer priority
    
    static method create takes DamageResponse func, integer priority returns DamageEvent
     local DamageEvent this = DamageEvent.allocate()

        set this.func = func
        set this.priority = priority
        return this
    endmethod
    
    // Should hopefully not need to be called
    method onDestroy takes nothing returns nothing
        call BJDebugMsg("onDestroy called for DamageEvent!")
    endmethod
endstruct

struct DamagePacket
    unit source
    unit target
    private real startingDamage
    private boolean isAnAttack
    real currentDamage
    integer damageType
    boolean skipRemaining
    
    method operator originalDamage takes nothing returns real
        return this.startingDamage
    endmethod
    
    method operator isAttack takes nothing returns boolean
        return this.isAnAttack
    endmethod

    static method create takes unit source, unit target, real damage, integer damageType, boolean isAttack returns DamagePacket
     local DamagePacket this = DamagePacket.allocate()
        set this.source = source
        set this.target = target
        set this.startingDamage = damage
        set this.currentDamage = damage
        set this.damageType = damageType
        set this.skipRemaining = false
        set this.isAnAttack = isAttack
        return this
    endmethod

endstruct

private keyword HandleDamage
function DamageTarget takes unit source, unit target, real damage, integer damageType returns nothing
 local DamagePacket packet = DamagePacket.create(source, target, damage, damageType, false)

    if damageType < 0 or damageType > damageTypeCount then
        call packet.destroy()
        return
    endif

    call HandleDamage.execute(packet)
endfunction

public function Create takes DamageResponse response, integer priority returns nothing
 local DamageEvent data = DamageEvent.create(response, priority)
 local Link link = EventList.first
 
    loop
        exitwhen link == 0 or DamageEvent(link.data).priority >= priority
        set link = link.next
    endloop

    if link == 0 then
        call Link.createLast(EventList, data)
    else
        call link.insertBefore(data)
    endif
endfunction

//=====================
// Private
//=====================
function DamageTarget_Attack takes unit source, unit target, real damage, integer damageType returns nothing
 local DamagePacket packet = DamagePacket.create(source, target, damage, damageType, true)

    if damageType < 1 or damageType > 3 then
        call packet.destroy()
        return
    endif

    call HandleDamage.execute(packet)
endfunction

private function HandleDamage takes DamagePacket packet returns nothing
 local Link link = EventList.first
 local DamageEvent damageEvent
 
    loop
        exitwhen link == 0 or packet.skipRemaining == true
        
        set damageEvent = link.data
        call damageEvent.func.evaluate(packet)
        
        set link = link.next
    endloop

    call packet.destroy()
endfunction

private function Init takes nothing returns nothing
    set EventList = List.create()
endfunction


endlibrary