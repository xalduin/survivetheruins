scope VoidwalkerSpell initializer Init
// requires DamageEvent, TimedEffects, ChainSpell, DamageFunctions, UnitUtils


globals
    private constant integer lesserVoidId = 'n00G'
    private constant integer greaterVoidId = 'n001'
    private constant integer silenceBuffId = 'BNsi'
    private constant integer manaCost = 5
    
    private constant real lightningDelay = .25
    private constant real lightningDuration = .5
    private constant string lightningType = "CLSB"
    private constant string targetSFX = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
    
    private constant real lightningRadius = 400.
    private constant real lightningDamage = 25.
endglobals

private function LightningDamage takes unit caster returns real
    if GetUnitTypeId(caster) == greaterVoidId then
        return 25.
    elseif GetUnitTypeId(caster) == lesserVoidId then
        return 12.
    endif
    return 0.
endfunction

private function ChainLightning_Hit takes unit target, unit previous, ChainSpell data returns nothing
    if previous != null then
        call TimedLightningUnit(previous, target, lightningType, lightningDuration)
    endif

    call AddEffectTimed(AddSpecialEffectTarget(targetSFX, target, "origin"), 1.)
    call DamageTarget(data.caster, target, LightningDamage(data.caster), DAMAGE_TYPE_MAGICAL)
endfunction

private function DoChainLightning takes unit caster, unit target returns nothing
 local ChainSpell spell = ChainSpell.create()
 
    set spell.caster = caster
    set spell.radius = lightningRadius
    set spell.maxHits = 3
    set spell.targetFilter = Filter_IsUnitAnyValidSpellTarget
    set spell.onHit = ChainLightning_Hit
    
    call spell.start(target, lightningDelay)
endfunction

private function OnAttack takes DamagePacket packet returns nothing
 local unit attacker = packet.source
 local unit target = packet.target
 local boolean conditions = GetUnitAbilityLevel(attacker, silenceBuffId) == 0
 
    set conditions = conditions and packet.isAttack
    set conditions = conditions and LightningDamage(attacker) > 0.
    set conditions = conditions and IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) == false
    set conditions = conditions and GetUnitState(attacker, UNIT_STATE_MANA) >= 5.

    if conditions then
        call DoChainLightning(attacker, target)
        call UnitAddMana(attacker, -5)
    endif
    
 set attacker = null
 set target = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope