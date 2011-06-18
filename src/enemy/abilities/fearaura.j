scope FearAura initializer Init


globals
    private constant integer cryptLordId = 'u000'
    private constant integer dummyAuraId = 'A00E'
    private constant integer dummyBuffId = 'B00Q'
    private constant key buffKey
    
    private constant real armorMult = -.5

    private constant real AOE = 900.
    private boolexpr targetFilter = null
    private constant real DURATION = 1.
endglobals

private struct FearBuff extends BuffType
    implement BuffKey
    implement DefaultClone

    method onCreate takes BuffData data returns nothing
        call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitArmorMult(data.target, armorMult)
        call UnitStats_Update(data.target)
    endmethod
    
    method onRecast takes BuffData data, unit caster, integer level, real duration returns nothing
        set data.duration = RMaxBJ(data.duration, duration)
    endmethod
    
    method cleanup takes BuffData data returns nothing
        call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitArmorMult(data.target, -armorMult)
        call UnitStats_Update(data.target)
    endmethod
endstruct
    
private function GetAuraBuff takes nothing returns AuraBuff
 local AuraBuff auraBuff = AuraBuff.create(buffKey)
 
    set auraBuff.aoe = AOE
    set auraBuff.filter = targetFilter
    set auraBuff.buffType = FearBuff.create()
    set auraBuff.duration = DURATION
    set auraBuff.permanent = true
    
    return auraBuff
endfunction

private function Main takes nothing returns nothing
 local unit triggerUnit = GetTriggerUnit()

    call UnitApplyBuff(triggerUnit, triggerUnit, GetAuraBuff(), 1, 10.)

 set triggerUnit = null
endfunction

//===========================================================================
private function Conditions takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit()) == cryptLordId
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

    call TriggerRegisterEnterRectSimple(t, bj_mapInitialPlayableArea)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
    
    set targetFilter = Filter_IsUnitValidSpellTarget
 set t = null
endfunction


endscope