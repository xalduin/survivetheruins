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
    
    call AddBuilding('h000')	// Barricade
    call AddBuilding('h00A')	// Strengthened Barricade
    call AddBuilding('h00I')	// Reinforced Barricade
    call AddBuilding('h013')	// Advanced Barricade
    call AddBuilding('h00F')	// Ultimate Barricade

    call AddBuilding('h005')	// Gold Generator
    call AddBuilding('h00B')	// Fiery Generator
    call AddBuilding('h00O')	// Research Center
    
    // Engineer
    call AddBuilding('h003')	// Magical Lantern
    
    call AddBuilding('n006')	// Fire Cannon
    call AddBuilding('n007')	// Burning Cannon
    call AddBuilding('n00M')	// Blazing Cannon
    call AddBuilding('n009')	// Ice Turret
    call AddBuilding('n00A')	// Frost Blaster
    call AddBuilding('n00N')	// Hoarfrost Cannon
    
    call AddBuilding('h00J')	// Arcane Tower
    call AddBuilding('h00K')	// Advanced Arcane Tower
    
    call AddBuilding('h00N')	// Guard Tower
    call AddBuilding('h00Q')	// Advanced Guard Tower
    
    call AddBuilding('h00M')	// Tank
    call AddBuilding('h010')	// Battle Tank
    call AddBuilding('h00X')	// Assault Tank
    call AddBuilding('h00Z')	// Siege Tank
    call AddBuilding('h00Y')	// Onslaught Tank
    
    // Archaeologist
    call AddBuilding('h00D')	// Magic Rune
    call AddBuilding('h00P')	// Revealing Light
    
    call AddBuilding('h001')	// Simple Torch
    call AddBuilding('h00C')	// Ignited Torch
    call AddBuilding('h00H')	// Enflamed Torch
    
    call AddBuilding('h002')	// Burning Brazier
    call AddBuilding('h009')	// Flaming Brazier
    call AddBuilding('h00G')	// Blazing Brazier
    
    call AddBuilding('h012')	// Mobile War Station
    call AddBuilding('h004')	// Bunker
    
    // Physicist
    call AddBuilding('h00T')	// Electricity Generator
    call AddBuilding('h015')	// Advanced Electricity Generator
    
    call AddBuilding('n004')	// Electric Obelisk
    call AddBuilding('n00J')	// Reinforced Electric Obelisk
    call AddBuilding('n00D')	// Advanced Electric Obelisk
    
    call AddBuilding('h00S')	// Shock Tower
    call AddBuilding('h00V')	// Tesla Tower
    call AddBuilding('h01H')	// Electrocute Tower
    
    call AddBuilding('h00W')	// Lightning Tower
    call AddBuilding('h011')	// Thunder Tower
    
    call AddBuilding('h00U')	// Repair Orb
    call AddBuilding('h014')	// Improved Repair Orb
    call AddBuilding('h01F')	// Advanced Repair Orb
    
    call AddBuilding('h018')	// Capacitor
    call AddBuilding('h017')	// Shield Generator
    call AddBuilding('h01G')	// Electrostatic Tower
    
    //Orc
    call AddBuilding('o000')	// Burrow
    call AddBuilding('o001')	// Reinforced Burrow
    call AddBuilding('o009')	// Advanced Burrow
    
    call AddBuilding('o002')	// Watch Tower
    call AddBuilding('o003')	// Battle Tower
    call AddBuilding('o004')	// Assault Tower
    call AddBuilding('o008')	// War Tower
    
    call AddBuilding('n005')	// Boulder Tower
    call AddBuilding('n008')	// Advanced Boulder Tower
    
    call AddBuilding('o00A')	// Spirit Lodge
    
    call AddBuilding('o005') 	// Demolisher
    call AddBuilding('o007')	// Ultimate Demolisher

    call AddBuilding('h008')	// Healing Ward
endfunction


endscope