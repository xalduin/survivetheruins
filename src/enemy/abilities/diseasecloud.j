scope DiseaseCloud initializer Init
//requires BuffCore, DummyBuff, DamageEvent, CommonFilters, PreloadAbility


globals
    private constant integer diseaseCloudId = 'uplg'
    
    private constant integer dummyAuraId = 'A02Z'
    private constant integer dummyBuffId = 'B00A'
    
    private constant real cloudRadius = 250.
    private constant real damageDuration = 20.
    private constant real cloudDamage = 5.
endglobals

struct DiseaseCloudBuff extends BuffType
    static key buffKey
    
    method getKey takes nothing returns integer
        return buffKey
    endmethod

    public method onCreate takes BuffData data returns nothing
        call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call data.setUpdateInterval(1.)
    endmethod
    
    method onRecast takes BuffData oldData, unit caster, integer level, real newDuration returns nothing
        set oldData.duration = RMaxBJ(oldData.duration, newDuration)
    endmethod
    
    method onUpdate takes BuffData data returns nothing
        call DamageTarget(data.target, data.target, cloudDamage, DAMAGE_TYPE_EXTRA)
    endmethod
    
    public method cleanup takes BuffData data returns nothing
        call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
    endmethod
endstruct

private function ApplyDisease takes nothing returns nothing
 local unit cloud = GetEnumUnit()
 local group tempGroup = CreateGroup()
 local unit picked
 
    set filterPlayer = GetOwningPlayer(cloud)
    call GroupEnumUnitsInRange(tempGroup, GetUnitX(cloud), GetUnitY(cloud), cloudRadius, Filter_IsUnitValidOrganicTarget)
    
    loop
        set picked = FirstOfGroup(tempGroup)
        exitwhen picked == null
        
        call UnitApplyBuff(cloud, picked, DiseaseCloudBuff.create(), 1, damageDuration)
        
        call GroupRemoveUnit(tempGroup, picked)
    endloop
    
    call DestroyGroup(tempGroup)
    
 set cloud = null
 set tempGroup = null
 set picked = null
endfunction
    

private function Main takes nothing returns nothing
 local group tempGroup = GetUnitsOfPlayerAndTypeId(Player(11), diseaseCloudId)

    call ForGroup(tempGroup, function ApplyDisease)
    call DestroyGroup(tempGroup)

 set tempGroup = null
endfunction

private function Init takes nothing returns nothing
    call PreloadAbility(dummyAuraId)

    call TimerStart(CreateTimer(), .1, true, function Main)
endfunction


endscope