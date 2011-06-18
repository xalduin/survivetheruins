scope ShockTower initializer Init


globals
    private constant integer shockId = 'h00S'
    private constant integer teslaId = 'h00V'
    
    private constant string shockSFX = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl"
    private constant string teslaSFX = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl"
endglobals

private function Damage takes integer unitType, integer level returns real
    if unitType == shockId then
        return I2R(10 + level * 3)
    elseif unitType == teslaId then
        return I2R(18 + level * 4)
    endif
    return 0.
endfunction

private function ManaCost takes integer unitType, integer level returns real
    if unitType == shockId then
        return 6.
    elseif unitType == teslaId then
        return 8.
    endif
    return 0.
endfunction

private function DoSFX takes integer unitType, unit target returns nothing
 local string sfx = shockSFX
    if unitType == teslaId then
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
        call SetUnitState(packet.source, UNIT_STATE_MANA, unitMana - manaCost)
        call DoSFX(unitType, packet.target)
    endif
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
endfunction


endscope