//Requires:
//	DamageEvent			(lib/damage/damageevent.j)
//	PhysicistShared		(shared.j)

scope ShockTower initializer Init


globals
    private constant integer shockId = 'h00S'
    private constant integer teslaId = 'h00V'
    private constant integer electroId = 'h01H'
    
    private constant string shockSFX = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl"
    private constant string teslaSFX = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl"
endglobals

private function Damage takes integer unitType, integer level returns real
    if unitType == shockId then
        return I2R(10 + level * 3)
    elseif unitType == teslaId then
        return I2R(18 + level * 4)
    elseif unitType == electroId then
    	return I2R(30 + level * 5)
    endif
    return 0.
endfunction

private function ManaCost takes integer unitType, integer level returns real
    if unitType == shockId then
        return 6.
    elseif unitType == teslaId then
        return 8.
    elseif unitType == electroId then
    	return 10.
    endif
    return 0.
endfunction

private function DoSFX takes integer unitType, unit target returns nothing
 local string sfx = shockSFX
    if unitType == teslaId or unitType == electroId then
        set sfx = teslaSFX
    endif
 
    call DestroyEffect(AddSpecialEffectTarget(sfx, target, "origin"))
endfunction
    
private function OnAttack takes DamagePacket packet returns nothing
 local integer level = GetPlayerTechCount(GetOwningPlayer(packet.source), 'R005', true) + 1
 local integer unitType = GetUnitTypeId(packet.source)
 local real damage = Damage(unitType, level)
 local real manaCost = ManaCost(unitType, level)
 local real unitMana = GetUnitState(packet.source, UNIT_STATE_MANA)
 
    if packet.isAttack and damage > 0. and manaCost > 0. and unitMana >= manaCost then
        set packet.currentDamage = damage
        set packet.damageType = DAMAGE_TYPE_ELECTRIC
        call SetUnitState(packet.source, UNIT_STATE_MANA, unitMana - manaCost)
        call DoSFX(unitType, packet.target)
    endif
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 4)
endfunction


endscope