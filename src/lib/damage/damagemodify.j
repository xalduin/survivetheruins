// Converts attack damage to system damage
library DamageModify initializer Init requires LightLeaklessDamageDetect, DamageEvent, UnitStats, TimerUtils, xepreload


globals
	integer DAMAGE_TYPE_PHYSICAL = -1
    integer DAMAGE_TYPE_MAGICAL = -1

    private boolean ignoreEvent = false
    
    private constant integer LIFE_BONUS_SPELL_ID   = 'A02K'
    private constant real    LIFE_BONUS            = 10000
endglobals

private struct DamageData
    // For restoring life
    real life

    // For applying triggered damage
    unit source
    unit target
    real damage
endstruct

// Don't block damage from Player 15 (maze enemies)
private function ValidUnit takes unit whichUnit returns boolean
    return GetOwningPlayer(whichUnit) != Player(14) and GetUnitTypeId(whichUnit) != XE_DUMMY_UNITID
endfunction

private function ConvertDamage_Callback takes nothing returns nothing
 local timer expired = GetExpiredTimer()
 local DamageData data = GetTimerData(expired)
 local integer attackType = GetUnitTypeAttackType(GetUnitTypeId(data.source))

    if GetUnitAbilityLevel(data.target, LIFE_BONUS_SPELL_ID) > 0 then
        call UnitRemoveAbility(data.target, LIFE_BONUS_SPELL_ID)
        call SetWidgetLife(data.target, data.life)
    endif

    call ReleaseTimer(expired)
    call data.destroy()

    call DamageTarget_Attack(data.source, data.target, data.damage, attackType)
endfunction

private function ConvertDamage takes nothing returns boolean
 local timer t
 local DamageData data
 local unit source = GetEventDamageSource()
 local unit target = GetTriggerUnit()
 local real damage = GetEventDamage()
 
 local real life = GetWidgetLife(target)
 local real maxLife = GetUnitState(target, UNIT_STATE_MAX_LIFE)
 
    if damage <= 0. or ignoreEvent or not ValidUnit(source) then
        set source = null
        set target = null
        return false
    endif
    
    set t = NewTimer()
    set data = DamageData.create()
    call SetTimerData(t, data)

    set data.source = source
    set data.target = target
    set data.damage = damage
    set data.life = life
    
    if life + damage > maxLife then
        call UnitAddAbility(target, LIFE_BONUS_SPELL_ID)
        call SetWidgetLife(target, (life / maxLife) * (LIFE_BONUS + maxLife) + damage)
    else
        call SetWidgetLife(target, life + damage)
    endif
    
    call TimerStart(t, 0., false, function ConvertDamage_Callback)
        
 set source = null
 set target = null
    
    return false
endfunction

private function DealDamage takes DamagePacket packet returns nothing
 local real reduction = 0.
 local real damage = packet.currentDamage
 local integer id = GetUnitId(packet.target)

    if damage <= 0. then
        return
    endif
    
    if packet.damageType == DAMAGE_TYPE_PHYSICAL then
        set reduction = GetUnitIdArmor(id) / 100.
    elseif packet.damageType == DAMAGE_TYPE_MAGICAL then
        set reduction = GetUnitIdResistance(id) / 100.
    endif

    set damage = damage * (1. - reduction)

    set ignoreEvent = true
    call UnitDamageTarget(packet.source, packet.target, damage, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
    set ignoreEvent = false
endfunction

private function Init takes nothing returns nothing
	set DAMAGE_TYPE_PHYSICAL = DamageEvent_NewDamageType()
	set DAMAGE_TYPE_MAGICAL = DamageEvent_NewDamageType()

    call AddOnDamageFunc(Condition(function ConvertDamage))
    call DamageEvent_Create(DealDamage, 1000)
    call XE_PreloadAbility(LIFE_BONUS_SPELL_ID)
endfunction


endlibrary