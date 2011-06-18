library Lich requires LichFreeze, Blizzard


globals
    private constant integer frostWyrmId = 'u00H'
    private unit frostWyrm = null
    private constant integer silenceBuff = 'BNsi'
    
    private constant real COOLDOWN_BLIZZARD = 10.
    private boolean blizzardCooldown = false
endglobals

private function EnableBlizzard takes nothing returns nothing
	call DestroyTimer(GetExpiredTimer())
	set blizzardCooldown = false
endfunction

private function BlizzardCooldown takes nothing returns nothing
	set blizzardCooldown = true
	call TimerStart(CreateTimer(), COOLDOWN_BLIZZARD, false, function EnableBlizzard)
endfunction

private function EndLich takes nothing returns nothing
    call RemoveUnit_Safe(frostWyrm)
    set frostWyrm = null
endfunction

private function CastBlizzard takes unit caster returns nothing
 local group temp = CreateGroup()
 local unit picked

 local real x = GetUnitX(caster)
 local real y = GetUnitY(caster)
 
 local real angle
 local real tx
 local real ty
 
    call GroupClear(ENUM_GROUP)
    set filterPlayer = GetOwningPlayer(caster)
    call GroupEnumUnitsInRange(ENUM_GROUP, x, y, 900., Filter_IsUnitAnyValidSpellTarget)
    
    loop
        set picked = FirstOfGroup(ENUM_GROUP)
        exitwhen picked == null
        
        set angle = AngleBetweenUnits(caster, picked) * bj_DEGTORAD
        set tx = x + 900. * Cos(angle)
        set ty = y + 900. * Sin(angle)
    
        call GroupEnumUnitsInRangeOfSegment(temp, x, y, tx, ty, Blizzard_damageAOE, Filter_IsUnitValidSpellTarget)

        if CountUnitsInGroup(temp) >= 2 and not blizzardCooldown then
            call Blizzard_Main(caster, tx, ty)
            call UnitAddMana(caster, -50.)
            call BlizzardCooldown()
            exitwhen true
        endif
        
        call GroupClear(temp)
        call GroupRemoveUnit(ENUM_GROUP, picked)
    endloop
    
    call DestroyGroup(temp)
    call GroupClear(ENUM_GROUP)
    
 set temp = null
 set picked = null
endfunction

public function HandleOrders takes nothing returns nothing
    if GetUnitAbilityLevel(Lich, silenceBuff) > 0 then
        call UnitRemoveAbility(Lich, silenceBuff)
    endif

    if GetUnitState(Lich, UNIT_STATE_MANA) >= 50 then
        call CastBlizzard(Lich)
    endif
endfunction

function StartLich takes nothing returns nothing
 local trigger temp = CreateTrigger()

    call TriggerRegisterUnitEvent(temp, Lich, EVENT_UNIT_DEATH)
    call TriggerAddAction(temp, function EndLich)

    set frostWyrm = CreateUnit(GetOwningPlayer(Lich), frostWyrmId, GetUnitX(Lich), GetUnitY(Lich), 0.)
    call IssueTargetOrder(frostWyrm, "smart", Lich)
    
    call LichFreeze_Start()
endfunction


endlibrary