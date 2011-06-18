library LichFreeze initializer Init requires BuffCore, AbilityPreload, GroupUtils


globals
    private constant real freezeDuration = 2.
    private constant real freezeRadius = 600.
    
    private constant real movementSlow = -1.
    private constant real attackSlow = -1.
    
    private constant integer dummyAuraId = 'A042'
    private constant integer dummyBuffId = 'B001'
    
    private constant key buffKey
endglobals

private function FreezeBuff takes nothing returns BuffType
 local SpeedBuff buffType = SpeedBuff.create(buffKey)

    set buffType.auraId = dummyAuraId
    set buffType.buffId = dummyBuffId
    set buffType.attackMultiplier = attackSlow
    set buffType.movementMultiplier = movementSlow

    return buffType
endfunction

private function Main takes nothing returns nothing
 local timer expired = GetExpiredTimer()
 local unit lich = Lich
 local unit picked
 
    if not spawnedLich then
        return
    endif
 
    if lich == null then
        call DestroyTimer(expired)
        set expired = null
        set lich = null
        return
    endif
    
    call GroupClear(ENUM_GROUP)
    set filterPlayer = GetOwningPlayer(lich)
    call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(lich), GetUnitY(lich), freezeRadius, Filter_IsUnitValidSpellTarget)
    
    set picked = FirstOfGroup(ENUM_GROUP)
    if picked != null then
        call UnitApplyBuff(lich, picked, FreezeBuff(), 1, freezeDuration)
    endif
    
    call GroupClear(ENUM_GROUP)
    
 set expired = null
 set lich = null
 set picked = null
endfunction

public function Start takes nothing returns nothing
    call TimerStart(CreateTimer(), 10., true, function Main)
endfunction

private function Init takes nothing returns nothing
    call PreloadAbility(dummyAuraId)
endfunction


endlibrary