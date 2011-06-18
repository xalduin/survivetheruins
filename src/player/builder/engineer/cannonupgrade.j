scope ImprovedCannonsUpgrade initializer Init


globals
    private integer array fireTowers
    private integer array iceTowers
    private constant integer towerCount = 3
    
    private constant integer tankId = 'h00M'
    private constant real tankBonus = 5.
    
    private constant integer siegeId = 'h00Z'
    private constant real siegeBonus = 10.
    
    private constant integer battleId = 'h010'
    private constant real battleBonus = 7.
    
    private constant integer upgradeId = 'R001'
endglobals

private function FireBonusDamage takes integer level returns real
    return I2R(level + 3)
endfunction
private function IceBonusDamage takes integer level returns real
    return I2R(level + 4 + level/2)
endfunction

private function ArcaneBonusDamage takes integer level returns real
	return I2R(level + 1) * 7.5
endfunction
private function GuardBonusDamage takes integer level returns real
	//25, 40
	return I2R(10 + 15 * level)
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