//Requires:
//	PhysicistMisc			(shared.j)
//	DamageFunctions			(lib/spelllib/damageutils.j)
//	BuildingMisc			(player/builder/misc.j)


scope ObeliskShock initializer Init
//requires DamageEvent, DamageFunctions, BuildingMisc


globals
    private constant integer shock1 = 'A00N'
    private constant integer shock2 = 'A00O'
    private constant string shockSFX = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
endglobals

// How much damage is dealt
private function Damage takes integer level, real damage returns real
    return damage * I2R(level + 1)
endfunction

private function ShockRadius takes integer level returns real
    return 200. + 100. * level
endfunction

private function ShockChance takes integer level returns integer
    return 5 + 10 * level
endfunction

private function GetShockLevel takes unit whichUnit returns integer
    if GetUnitAbilityLevel(whichUnit, shock1) > 0 then
        return 1
    elseif GetUnitAbilityLevel(whichUnit, shock2) > 0 then
        return 2
    endif

    return 0
endfunction

private function OnAttack takes DamagePacket packet returns nothing
 local unit attacker = packet.source
 local unit target = packet.target
 local integer level = GetShockLevel(target)
 local integer totalDamage = R2I( Damage(level, packet.currentDamage) + .5 )
 local real x = GetUnitX(target)
 local real y = GetUnitY(target)
 
    if packet.isAttack and level > 0 and GetRandomInt(1, 100) <= ShockChance(level) and not IsBuildingDisabled(target) then
        set filterPlayer = GetOwningPlayer(target)
        call DamageArea(target, totalDamage, x, y, ShockRadius(level), DAMAGE_TYPE_ELECTRIC, Filter_IsUnitValidSpellTarget)
        
        call DestroyEffect(AddSpecialEffect(shockSFX, x, y))
    endif
    
 set attacker = null
 set target = null
endfunction

private function Init takes nothing returns nothing
    call DamageEvent_Create(OnAttack, 10)
    call Preload(shockSFX)
endfunction


endscope