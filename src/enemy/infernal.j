// Requires:
//	Immolation Buff			(/lib/buff/immolationbuff.j)
//  DamageFunctions			(/lib/spellib/damageutils.j)

library Infernal initializer Init requires DamageFunctions


globals
	private unit infernalUnit = null
	
	// For Immolation Buff
	private constant real      	 immolationAOE        = 300.
	private constant real      	 immolationDamage     = 5.
	private constant integer   	 immolationDamageType = DAMAGE_TYPE_MAGICAL
	private			 boolexpr	 immolationFilter	  = null
	
	private constant key    immolationKey
	
	// Explosion Damage Configuration
	private constant real     warningDuration     = 4.
	private constant real  	  explosionAOE        = 600.
	private constant real     explosionDamage     = 150.
	private constant integer  explosionDamageType = DAMAGE_TYPE_EXTRA
	private 		 boolexpr explosionFilter	  = null
	
	// Explosion SFX Configuration
	private constant string  explosionSFX = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"
	private constant string  warningSFX   = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl"
	private constant real    sfxRadius 	  = 150.
	private constant integer sfxCount     = 4	// Number of explosions coming out from center. 1 at center, 3 more at each angle
	private constant integer sfxRotations = 8	// Number of lines of explosions to make
	
	// Temporary use
	private real explosionX = 0.
	private real explosionY = 0.
endglobals

private function DoExplosionSFX takes real centerX, real centerY, string sfx, real duration returns nothing
 local real angleIncrement = (bj_PI * 2.) / I2R(sfxRotations)
 local real angle = 0.
 local integer circleCount = 0
 local integer lineCount = 0

 local real x = centerX
 local real y = centerY
 
 	call AddEffectTimed(AddSpecialEffect(sfx, x, y), duration)
 
 	loop
 		exitwhen circleCount == sfxRotations

 		loop
 			exitwhen lineCount == sfxCount
 			
 			set x = x + sfxRadius * Cos(angle)
 			set y = y + sfxRadius * Sin(angle)
 			
 			call AddEffectTimed(AddSpecialEffect(sfx, x, y), duration)
 			
 			set lineCount = lineCount + 1
 		endloop

 		set lineCount = 0
 		set x = centerX
 		set y = centerY
 		
 		set angle = angle + angleIncrement
 		set circleCount = circleCount + 1
 	endloop
endfunction

private function StartExplosion takes nothing returns nothing
	call DestroyTimer(GetExpiredTimer())

	set filterPlayer = GetOwningPlayer(infernalUnit)
	call DamageArea(infernalUnit, explosionDamage, explosionX, explosionY, explosionAOE, explosionDamageType, null)
	call DoExplosionSFX(explosionX, explosionY, explosionSFX, 0.)
endfunction

private function OnInfernalDeath takes nothing returns nothing
	set explosionX = GetUnitX(infernalUnit)
	set explosionY = GetUnitY(infernalUnit)

	call DoExplosionSFX(explosionX, explosionY, warningSFX, 2.)
	call TimerStart(CreateTimer(), warningDuration, false, function StartExplosion)

	set infernalUnit = null
endfunction

function StartInfernal takes unit infernal returns nothing
 local ImmolationBuff immolationBuff = ImmolationBuff.create(immolationAOE, immolationDamage, immolationDamageType, immolationFilter, immolationKey)
 local BuffData data
 
 local trigger onDeath = CreateTrigger()

	set infernalUnit = infernal
	set data = UnitApplyBuff(infernal, infernal, immolationBuff, 1, 5.)
	set data.permanent = true
	
	call TriggerRegisterUnitEvent(onDeath, infernal, EVENT_UNIT_DEATH)
	call TriggerAddAction(onDeath, function OnInfernalDeath)
	
 set onDeath = null
endfunction

private function Init takes nothing returns nothing
	set immolationFilter = Filter_IsUnitAnyValidSpellTarget
	set explosionFilter = Filter_NotIsUnitInvulnerable
endfunction


endlibrary