library RevivePlayer


// Revive at udg_ReviveRegion
function RevivePlayer takes player whichPlayer returns nothing
 local real x = GetRectCenterX(udg_ReviveRegion)
 local real y = GetRectCenterY(udg_ReviveRegion)
 local unit spawn = CreateUnit(whichPlayer, playerRole[GetPlayerId(whichPlayer)], x, y, 0.)
 
 	call GroupAddUnit(enemies, spawn)
 
 	if GetLocalPlayer() == whichPlayer then
 		call SelectUnit(spawn, true)
 		call PanCameraToTimed(x, y, 0.)
 	endif

 set spawn = null
endfunction



endlibrary