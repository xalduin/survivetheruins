scope OrcPoisonArrow initializer Init


globals

    private constant integer dummyAuraId = 'A02Y'
    private constant integer dummyBuffId = 'B009'
    
    private constant string poisonSFX = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl"
endglobals

private function DamagePerSecond takes integer level returns real
	return 5. + I2R(level * 5)
endfunction

private constant function AttackSlow takes integer level returns real
	return 0.
endfunction

private function MovementSlow takes integer level returns real
	if level == 3 then
		return .15
	endif
	return 0.
endfunction

private constant function Duration takes integer level returns real
	return 10.
endfunction

// End config
//=======================================================

private struct PoisonArrowBuff extends BuffType
    static key buffKey
    
    method getKey takes nothing returns integer
        return buffKey
    endmethod

    public method onCreate takes BuffData data returns nothing
        call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call data.setUpdateInterval(1.)
        call AddUnitAttackSpeedMult(data.target, -AttackSlow(data.level))
        call AddUnitMoveSpeedMult(data.target, -MovementSlow(data.level))
        call UnitStats_Update(data.target)
        
        call this.onUpdate(data)
    endmethod
    
    method onRecast takes BuffData data, unit caster, integer level, real newDuration returns nothing
    	if level > data.level then
    		call AddUnitAttackSpeedMult(data.target, -AttackSlow(data.level))
    		call AddUnitMoveSpeedMult(data.target, -MovementSlow(data.level))
    		
    		call AddUnitAttackSpeedMult(data.target, AttackSlow(level))
    		call AddUnitMoveSpeedMult(data.target, MovementSlow(level))
    		
    		call UnitStats_Update(data.target)
    		set data.level = level
    	endif

        set data.duration = RMaxBJ(data.duration, newDuration)
    endmethod
    
    method onUpdate takes BuffData data returns nothing
        call DamageTarget(data.target, data.target, DamagePerSecond(data.level), DAMAGE_TYPE_EXTRA)
        call AddEffectTimed(AddSpecialEffectTarget(poisonSFX, data.target, "chest"), 1.5)
    endmethod
    
    public method cleanup takes BuffData data returns nothing
        call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
        call AddUnitAttackSpeedMult(data.target, -AttackSlow(data.level))
        call AddUnitMoveSpeedMult(data.target, -MovementSlow(data.level))
        call UnitStats_Update(data.target)
    endmethod
endstruct

private function OnAttack takes DamagePacket packet returns nothing
 local unit target = packet.target
 local unit attacker = packet.source
 local integer unitType = GetUnitTypeId(attacker)
 local boolean correctUnit = unitType == Rawcode_UNIT_BATTLE_TOWER or unitType == Rawcode_UNIT_WAR_TOWER or unitType == Rawcode_UNIT_ASSAULT_TOWER
 local integer level = GetPlayerTechCount(GetOwningPlayer(attacker), Rawcode_RESEARCH_POISON_ARROWS, true)
 
    if packet.isAttack and level > 0 and correctUnit and IsUnitType(target, UNIT_TYPE_MECHANICAL) == false then
        call UnitApplyBuff(attacker, target, PoisonArrowBuff.create(), level, Duration(level))
    endif

 set target = null
 set attacker = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
    call Preload(poisonSFX)
    call PreloadAbility(dummyAuraId)
endfunction


endscope