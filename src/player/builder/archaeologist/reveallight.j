scope RevealingLight initializer Init


globals
    private constant integer lightId = 'h00P'
    private constant integer dummyAuraId = 'A00A'
    private constant integer dummyBuffId = 'B00L'
    private constant key buffKey
    
    private constant real armorMult = -.2

    private constant real AOE = 600.
    private boolexpr targetFilter = null
    private constant real DURATION = 1.
endglobals

private struct LightBuff extends BuffType
    implement BuffKey
    implement DefaultClone

    method onCreate takes BuffData data returns nothing
        call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitArmorMult(data.target, armorMult)
        call UnitStats_Update(data.target)

        if IsBuildingDisabled(data.caster) then
            call data.removeBuff()
        endif
    endmethod
    
    method onRecast takes BuffData data, unit caster, integer level, real duration returns nothing
        if IsBuildingDisabled(caster) then
            return
        endif
        set data.duration = RMaxBJ(data.duration, duration)
    endmethod
    
    method cleanup takes BuffData data returns nothing
        call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitArmorMult(data.target, -armorMult)
        call UnitStats_Update(data.target)
    endmethod
endstruct
    
private function GetAuraBuff takes nothing returns BuffType
 local AuraBuff auraBuff = AuraBuff.create(buffKey)
 
    set auraBuff.aoe = AOE
    set auraBuff.filter = targetFilter
    set auraBuff.buffType = LightBuff.create()
    set auraBuff.duration = DURATION
    set auraBuff.permanent = true
    
    return auraBuff
endfunction

private function Main takes nothing returns nothing
 local unit triggerUnit = GetTriggerUnit()
 local AuraBuff auraBuff = GetAuraBuff()
 local BuffType buffType = auraBuff

    call UnitApplyBuff(triggerUnit, triggerUnit, GetAuraBuff(), 1, 10.)

 set triggerUnit = null
endfunction

//===========================================================================
private function Conditions takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit()) == lightId
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_UPGRADE_FINISH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
    
    set targetFilter = Filter_IsUnitValidSpellTarget
 set t = null
endfunction


endscope