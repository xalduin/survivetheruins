library SetResearch


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
        call SetPlayerTechMaxAllowed(p, 'R006', 1) // Thunder Tower
        
    elseif unitId == orcId then
    	call SetPlayerTechMaxAllowed(p, 'R003', 1)	//	Demolisher
    endif
    
 set p = null
endfunction

// Clears all unique (builder specific) entries from research center
function ResetResearch takes player p returns nothing
    call SetPlayerTechMaxAllowed(p, 'R000', 0)
    call SetPlayerTechMaxAllowed(p, 'R001', 0)
    call SetPlayerTechMaxAllowed(p, 'R003', 0)
    call SetPlayerTechMaxAllowed(p, 'R005', 0)
    call SetPlayerTechMaxAllowed(p, 'R006', 0)
    call SetPlayerTechMaxAllowed(p, 'R007', 0)
    call SetPlayerTechMaxAllowed(p, 'R008', 0)
    call SetPlayerTechMaxAllowed(p, 'R009', 0)
endfunction

function SetTechAllowed takes player p returns nothing
	call SetPlayerTechMaxAllowed(p, 'h004', 1)	// Bunker
    call SetPlayerTechMaxAllowed(p, 'h00M', 1)	// Tank
    call SetPlayerTechMaxAllowed(p, 'h00W', 1)	// Lightning Tower
    call SetPlayerTechMaxAllowed(p, 'h011', 0)	// Thunder Tower
    call SetPlayerTechMaxAllowed(p, 'h012', 1)	// Mobile War Station
    call SetPlayerTechMaxAllowed(p, 'h010', 0)	// Battle Tank
    call SetPlayerTechMaxAllowed(p, 'h00Z', 0)	// Siege Tank
    call SetPlayerTechMaxAllowed(p, 'h00O', 0)	// Research Center	(starts disabled)
    call SetPlayerTechMaxAllowed(p, 'o005', 1)	// Demolisher
    call SetPlayerTechMaxAllowed(p, 'h00X', 0)	// Assault Tank
    call SetPlayerTechMaxAllowed(p, 'h00Y', 0)	// Onslaught Tank
endfunction


endlibrary