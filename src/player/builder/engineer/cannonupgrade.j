scope ImprovedCannonsUpgrade initializer Init


globals
    private integer array fireTowers
    private integer array iceTowers
    private constant integer towerCount = 3
    
    constant integer tankId = 'h00M'
    private constant real tankBonus = 5.
    
    constant integer siegeId = 'h00Z'
    private constant real siegeBonus = 10.
	
	constant integer onslaughtId = 'h00Y'
	private constant real onslaughtBonus = 15.
    
    constant integer battleId = 'h010'
    private constant real battleBonus = 7.
	
	constant integer assaultId = 'h00X'
	private constant real assaultBonus = 10.5
    
    private constant integer upgradeId = 'R001'
	
	private constant integer arcaneTowerId = 'h00J'
	private constant real arcaneDamageBonus = 15.
	private constant integer advancedArcaneId = 'h00K'
	private constant real advancedArcaneDamageBonus = 22.5
	
	private constant integer guardTowerId = 'h00N'
	private constant real guardDamageBonus = 25.
	private constant integer advancedGuardId = 'h00Q'
	private constant real advancedGuardDamageBonus = 40.
endglobals

private function FireBonusDamage takes integer level returns real
    return I2R(level + 3)
endfunction
private function IceBonusDamage takes integer level returns real
    return I2R(level + 4 + level/2)
endfunction

private function Main takes nothing returns nothing
 local player owner = GetOwningPlayer(GetTriggerUnit())
 local integer i = 0
 
    loop
        exitwhen i >= towerCount
        call AddUnitTypeDamageBonus(owner, fireTowers[i], FireBonusDamage(i))
        call AddUnitTypeDamageBonus(owner, iceTowers[i], IceBonusDamage(i))
        set i = i + 1
    endloop

    call AddUnitTypeDamageBonus(owner, tankId, tankBonus)
    call AddUnitTypeDamageBonus(owner, siegeId, siegeBonus)
    call AddUnitTypeDamageBonus(owner, battleId, battleBonus)
	call AddUnitTypeDamageBonus(owner, onslaughtId, onslaughtBonus)
	call AddUnitTypeDamageBonus(owner, assaultId, assaultBonus)
    
	call AddUnitTypeDamageBonus(owner, arcaneTowerId, arcaneDamageBonus)
	call AddUnitTypeDamageBonus(owner, advancedArcaneId, advancedArcaneDamageBonus)
	call AddUnitTypeDamageBonus(owner, guardTowerId, guardDamageBonus)
	call AddUnitTypeDamageBonus(owner, advancedGuardId, advancedGuardDamageBonus)
	
    call UnitStats_PlayerUpdate(owner)
 set owner = null
endfunction

//===========================================================================
private function Conditions takes nothing returns boolean
    return GetResearched() == upgradeId
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
    
    set fireTowers[0] = 'n006'
    set fireTowers[1] = 'n007'
    set fireTowers[2] = 'n00M'
    
    set iceTowers[0] = 'n009'
    set iceTowers[1] = 'n00A'
    set iceTowers[2] = 'n00N'
endfunction


endscope