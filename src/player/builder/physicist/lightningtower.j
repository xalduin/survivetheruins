scope LightningTower initializer Init
// requires DamageEvent, TimedEffects, ChainSpell, DamageFunctions, UnitUtils


globals
    private constant integer lightningTowerId = 'h00W'
    private constant integer thunderTowerId = 'h011'
    
    private constant real lightningDelay = .25
    private constant real lightningDuration = .5
    private constant string lightningType = "CLSB"
    private constant string targetSFX = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
    
    private constant real lightningRadius = 500.
endglobals

private function LightningDamage takes unit caster returns real
    if GetUnitTypeId(caster) == thunderTowerId then
        return 140.
    elseif GetUnitTypeId(caster) == lightningTowerId then
        return 70.
    endif
    return 0.
endfunction

private function DamageMultiplier takes unit caster returns real
    if GetUnitTypeId(caster) == thunderTowerId then
        return .95
    endif
    return .9
endfunction

private function ManaCost takes unit caster returns real
    if GetUnitTypeId(caster) == thunderTowerId then
        return 75.
    endif
    return 30.  // Lightning Tower
endfunction

private function TargetCount takes unit caster returns integer
    if GetUnitTypeId(caster) == thunderTowerId then
        return 10
    endif
    return 7
endfunction

private struct DamageStruct
    real damage
endstruct

private function ChainLightning_Hit takes unit target, unit previous, ChainSpell data returns nothing
 local DamageStruct damageStruct = data.dataStruct

    if previous != null then
        call TimedLightningUnit(previous, target, lightningType, lightningDuration)
    //else
        //call TimedLightningUnit(data.caster, target, lightningType, lightningDuration)
    endif

    call AddEffectTimed(AddSpecialEffectTarget(targetSFX, target, "origin"), 1.)
    call DamageTarget(data.caster, target, damageStruct.damage, DAMAGE_TYPE_MAGICAL)
    
    set damageStruct.damage = damageStruct.damage * DamageMultiplier(data.caster)
    //call DelayedDamage(data.caster, target, LightningDamage(data.caster), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_SPELL, false)
endfunction

private function ChainLightning_Finish takes unit u, unit p, ChainSpell data returns nothing
    call DamageStruct(data.dataStruct).destroy()
endfunction

private function DoChainLightning takes unit caster, unit target returns nothing
 local ChainSpell spell = ChainSpell.create()
 local DamageStruct data = DamageStruct.create()
 
    set spell.caster = caster
    set spell.radius = lightningRadius
    set spell.maxHits = TargetCount(caster)
    set spell.targetFilter = Filter_IsUnitValidSpellTarget
    set spell.onHit = ChainLightning_Hit
    set spell.onFinish = ChainLightning_Finish
    
    set data.damage = LightningDamage(caster)
    set spell.dataStruct = data
    
    call spell.start(target, lightningDelay)
endfunction

private function OnAttack takes DamagePacket packet returns nothing
 local unit attacker = packet.source
 local unit target = packet.target
 local boolean conditions = packet.isAttack

    set conditions = conditions and LightningDamage(attacker) > 0.
    set conditions = conditions and IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) == false
    set conditions = conditions and IsUnitType(target, UNIT_TYPE_STRUCTURE) == false
    set conditions = conditions and GetUnitState(attacker, UNIT_STATE_MANA) >= ManaCost(attacker)

    if conditions then
        call DoChainLightning(attacker, target)
        call UnitAddMana(attacker, -ManaCost(attacker))
    endif
    
 set attacker = null
 set target = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope