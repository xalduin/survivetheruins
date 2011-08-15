//Requires:
//	Physicist_Shared (shared.j)
//  BuffCore		 (lib/buff/buffcore.j)
//  DummyBuff		 (lib/buff/dummybuff.j)
//  UnitUtils		 (lib/unitutils.j)

scope Electrostatic initializer Init


globals
	public constant integer TOWER_ID = 'h01G'
	
	private constant real ATTACK_DAMAGE = 65.
	private constant real ATTACK_MANA_COST = 20.
	private constant string ATTACK_SFX = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl"
	
	//===============
	// Buff Constants
	//===============

	private constant integer dummyAuraId = 'A00X'
	private constant integer dummyBuffId = 'B002'
	
	private constant integer STATIC_MAX_LEVEL = 10
	private constant real BUFF_DURATION = 5.
endglobals

struct Static extends BuffType
	implement BuffKey
	
	method onCreate takes BuffData data returns nothing
		call UnitAddDummyBuff(data.target, dummyAuraId, dummyBuffId)
	endmethod
	
	method onRecast takes BuffData data, unit caster, integer level, real duration returns nothing
		set data.level = IMaxBJ(data.level + 1, STATIC_MAX_LEVEL)
		set data.duration = RMaxBJ(data.duration, duration)
	endmethod
	
	method cleanup takes BuffData data returns nothing
		call UnitRemoveDummyBuff(data.target, dummyAuraId, dummyBuffId)
	endmethod
	
	method receiveDamage takes BuffData data, DamagePacket packet returns nothing
		if packet.damageType != DAMAGE_TYPE_ELECTRIC then
			return
		endif
		
		set packet.currentDamage = packet.currentDamage * I2R(100 + data.level) / 100.
	endmethod
endstruct

private function OnAttack takes DamagePacket packet returns nothing
	if GetUnitTypeId(packet.source) != TOWER_ID or GetUnitState(packet.source, UNIT_STATE_MANA) < ATTACK_MANA_COST then
		return
	endif

	call UnitAddMana(packet.source, -ATTACK_MANA_COST)
	set packet.currentDamage = ATTACK_DAMAGE
	set packet.damageType = DAMAGE_TYPE_ELECTRIC
	call DestroyEffect(AddSpecialEffectTarget(ATTACK_SFX, packet.target, "origin"))

	call UnitApplyBuff(packet.source, packet.target, Static.create(), 1, BUFF_DURATION)
endfunction

private function Init takes nothing returns nothing
	call DamageEvent_Create(OnAttack, 4)
endfunction


endscope