scope Lantern initializer Init


globals
    private constant integer dummyAuraId = 'A002'
    private constant integer dummyBuffId = 'B00P'
    private constant key buffKey
    
    private constant real attackMult = -.15
    private constant real moveMult = -.2

    private constant real AOE = 400.
    private boolexpr targetFilter = null
    private constant real DURATION = 1.
endglobals

private struct LanternBuff extends BuffType
    implement BuffKey
    implement DefaultClone

    method onCreate takes BuffData data returns nothing
        call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitAttackSpeedMult(data.target, attackMult)
        call AddUnitMoveSpeedMult(data.target, moveMult)
        call UnitStats_Update(data.target)

        if IsBuildingDisabled(data.caster) then
            call data.removeBuff()
        endif
    endmethod
    
    method onRecast takes BuffData data, unit caster, integer level, real duration returns nothing
        if IsBuildingDisabled(data.caster) then
            return
        endif
        set data.duration = RMaxBJ(data.duration, duration)
    endmethod
    
    method cleanup takes BuffData data returns nothing
        call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitAttackSpeedMult(data.target, -attackMult)
        call AddUnitMoveSpeedMult(data.target, -moveMult)
        call UnitStats_Update(data.target)
    endmethod
endstruct
    
private function GetAuraBuff takes nothing returns AuraBuff
 local AuraBuff auraBuff = AuraBuff.create(buffKey)
 
    set auraBuff.aoe = AOE
    set auraBuff.filter = targetFilter
    set auraBuff.buffType = LanternBuff.create()
    set auraBuff.duration = DURATION
    set auraBuff.permanent = true
    
    return auraBuff
endfunction

private function ExecuteBuff takes nothing returns boolean
 local unit triggerUnit = GetTriggerUnit()

    if GetUnitTypeId(triggerUnit) != Rawcode_UNIT_MAGICAL_LANTERN then
        set triggerUnit = null
        return false
    endif
    
    call UnitApplyBuff(triggerUnit, triggerUnit, GetAuraBuff(), 1, 10.)

    set triggerUnit = null
    return false
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH)
    call TriggerAddCondition(t, Condition(function ExecuteBuff))
    
    set targetFilter = Filter_IsUnitValidSpellTarget
 set t = null
endfunction


endscope