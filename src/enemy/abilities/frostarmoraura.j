scope FrostArmorAura initializer Init


globals
    private constant integer lichId = 'u00G'
    private constant integer dummyAuraId = 'A005'
    private constant integer dummyBuffId = 'B00O'
    private constant key buffKey
    
    private constant real armorBonus = 3.

    private constant real AOE = 900.
    private boolexpr targetFilter = null
    private constant real DURATION = 1.
endglobals

private struct FrostArmorBuff extends BuffType
    implement BuffKey
    implement DefaultClone

    method onCreate takes BuffData data returns nothing
        call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitArmorBonus(data.target, armorBonus)
        call UnitStats_Update(data.target)
    endmethod
    
    method onRecast takes BuffData data, unit caster, integer level, real duration returns nothing
        set data.duration = RMaxBJ(data.duration, duration)
    endmethod
    
    method cleanup takes BuffData data returns nothing
        call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitArmorBonus(data.target, -armorBonus)
        call UnitStats_Update(data.target)
    endmethod
endstruct
    
private function GetAuraBuff takes nothing returns AuraBuff
 local AuraBuff auraBuff = AuraBuff.create(buffKey)
 
    set auraBuff.aoe = AOE
    set auraBuff.filter = targetFilter
    set auraBuff.buffType = FrostArmorBuff.create()
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
    return GetUnitTypeId(GetTriggerUnit()) == lichId
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

    call TriggerRegisterEnterRectSimple(t, bj_mapInitialPlayableArea)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
    
    set targetFilter = Filter_IsUnitValidBuffTarget
 set t = null
endfunction


endscope