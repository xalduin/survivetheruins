scope DurabilityUpgrade initializer Init


globals
    private integer array buildingIds
    private integer buildingCount = 0
    
    private constant integer upgradeId = 'Rhac'
    
    private constant real hpMult = .2
    private constant real armorBonus = 5.
endglobals

private function Main takes nothing returns nothing
 local player owner = GetOwningPlayer(GetTriggerUnit())
 local integer i = 0
 
    loop
        exitwhen i >= buildingCount
        call AddUnitTypeHpMult(owner, buildingIds[i], hpMult)
        call AddUnitTypeArmorBonus(owner, buildingIds[i], armorBonus)
        set i = i + 1
    endloop
    
    call UnitStats_PlayerUpdate(owner)
 set owner = null
endfunction

//===========================================================================
private function Conditions takes nothing returns boolean
    return GetResearched() == upgradeId
endfunction

private function AddBuilding takes integer unitType returns nothing
    set buildingIds[buildingCount] = unitType
    set buildingCount = buildingCount + 1
endfunction

private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_RESEARCH_FINISH)
    call TriggerAddCondition(t, Condition(function Conditions))
    call TriggerAddAction(t, function Main)
    
    call AddBuilding('h010')
    call AddBuilding('h012')
    call AddBuilding('h00Z')
    call AddBuilding('h00M')
    call AddBuilding('h013')
    call AddBuilding('h015')
    call AddBuilding('h01F')
    call AddBuilding('h000')
    call AddBuilding('h00G')
    call AddBuilding('h004')
    call AddBuilding('h002')
    call AddBuilding('h00T')
    call AddBuilding('h00H')
    call AddBuilding('h00B')
    call AddBuilding('h009')
    call AddBuilding('h005')
    call AddBuilding('h00C')
    call AddBuilding('h00D')
    call AddBuilding('h014')
    call AddBuilding('h003')
    call AddBuilding('h00I')
    call AddBuilding('h00U')
    call AddBuilding('h00O')
    call AddBuilding('h00P')
    call AddBuilding('h001')
    call AddBuilding('h00W')
    call AddBuilding('h00S')
    call AddBuilding('h00V')
    call AddBuilding('h011')
    call AddBuilding('n004')
    call AddBuilding('n00J')
    call AddBuilding('n00M')
    call AddBuilding('n007')
    call AddBuilding('n006')
    call AddBuilding('n00A')
    call AddBuilding('n00N')
    call AddBuilding('n009')
    
    //Orc
    call AddBuilding('o000')	// Burrow
    call AddBuilding('o001')	// Reinforced Burrow
    call AddBuilding('o002')	// Watch Tower
    call AddBuilding('o003')	// Battle Tower
    call AddBuilding('o004')	// War Tower
    call AddBuilding('o005') 	// Demolisher
    call AddBuilding('h008')	// Healing Ward
endfunction


endscope