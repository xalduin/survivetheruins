library SetResearch requires Rawcode


globals
    integer archId = 'h006'
    integer engId  = 'h00L'
    integer phyId  = 'h00R'
    integer orcId  = 'o006'
endglobals

function BuilderSetResearch takes unit u returns nothing
 local integer unitId = GetUnitTypeId(u)
 local player p = GetOwningPlayer(u)
 
    if unitId == archId then
        call SetPlayerTechMaxAllowed(p, 'R000', 4)	// Blazing Heat
        call SetPlayerTechMaxAllowed(p, 'R009', 1)	// Mobile War Station
        
    elseif unitId == engId then
        call SetPlayerTechMaxAllowed(p, 'R001', 3)	// Improved Cannons
        call SetPlayerTechMaxAllowed(p, 'R007', 2)	// Siege Tank
        call SetPlayerTechMaxAllowed(p, 'R008', 2)	// Battle Tank

    elseif unitId == phyId then
        call SetPlayerTechMaxAllowed(p, 'R005', 3)	// Electrified Towers
        call SetPlayerTechMaxAllowed(p, 'R006', 1) 	// Thunder Tower
        
    elseif unitId == orcId then
    	call SetPlayerTechMaxAllowed(p, 'R003', 1)	//	Demolisher
    endif
    
 set p = null
endfunction

// Clears all unique (builder specific) entries from research center
function ResetResearch takes player p returns nothing
    call SetPlayerTechMaxAllowed(p, Rawcode_RESEARCH_BLAZING_HEAT, 0)
    call SetPlayerTechMaxAllowed(p, Rawcode_RESEARCH_IMPROVED_CANNONS, 0)
    call SetPlayerTechMaxAllowed(p, Rawcode_RESEARCH_DEMOLISHER, 0)
    call SetPlayerTechMaxAllowed(p, Rawcode_RESEARCH_ELECTRIFIED_TOWERS, 0)
    call SetPlayerTechMaxAllowed(p, Rawcode_RESEARCH_THUNDER_TOWER, 0)
    call SetPlayerTechMaxAllowed(p, Rawcode_RESEARCH_SIEGE_TANK, 0)
    call SetPlayerTechMaxAllowed(p, Rawcode_RESEARCH_BATTLE_TANK, 0)
    call SetPlayerTechMaxAllowed(p, Rawcode_RESEARCH_MOBILE_WAR_MACHINE, 0)
endfunction

function SetTechAllowed takes player p returns nothing
	call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_BUNKER, 1)	// Bunker
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_TANK, 1)	// Tank
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_LIGHTNING_TOWER, 1)	// Lightning Tower
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_THUNDER_TOWER, 0)	// Thunder Tower
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_MOBILE_WAR_STATION, 1)	// Mobile War Station
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_BATTLE_TANK, 0)	// Battle Tank
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_SIEGE_TANK, 0)	// Siege Tank
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_RESEARCH_CENTER, 0)	// Research Center	(starts disabled)
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_DEMOLISHER, 1)	// Demolisher
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_ASSAULT_TANK, 0)	// Assault Tank
    call SetPlayerTechMaxAllowed(p, Rawcode_UNIT_ONSLAUGHT_TANK, 0)	// Onslaught Tank
endfunction


endlibrary