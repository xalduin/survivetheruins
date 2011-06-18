library SetResearch


globals
    integer archId = 'h006'
    integer engId = 'h00L'
    integer phyId = 'h00R'
    integer orcId = 'o006'
endglobals

function BuilderSetResearch takes unit u returns nothing
 local integer unitId = GetUnitTypeId(u)
 local player p = GetOwningPlayer(u)
 
    if unitId == archId then
        call SetPlayerTechMaxAllowed(p, 'R000', 3)
        call SetPlayerTechMaxAllowed(p, 'R009', 1)
        
    elseif unitId == engId then
        call SetPlayerTechMaxAllowed(p, 'R001', 3)
        call SetPlayerTechMaxAllowed(p, 'R007', 1)
        call SetPlayerTechMaxAllowed(p, 'R008', 1)

    elseif unitId == phyId then
        call SetPlayerTechMaxAllowed(p, 'R005', 3)
        call SetPlayerTechMaxAllowed(p, 'R006', 1)
        
    elseif unitId == orcId then
    	call SetPlayerTechMaxAllowed(p, 'R003', 1)
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
	call SetPlayerTechMaxAllowedSwap('h004', 1, p)
    call SetPlayerTechMaxAllowedSwap('h00M', 1, p)
    call SetPlayerTechMaxAllowedSwap('h00W', 1, p)
    call SetPlayerTechMaxAllowedSwap('h011', 0, p)
    call SetPlayerTechMaxAllowedSwap('h012', 1, p)
    call SetPlayerTechMaxAllowedSwap('h010', 0, p)
    call SetPlayerTechMaxAllowedSwap('h00Z', 0, p)
    call SetPlayerTechMaxAllowedSwap('h00O', 0, p)
    call SetPlayerTechMaxAllowedSwap('o005', 1, p)	// Demolisher
endfunction


endlibrary