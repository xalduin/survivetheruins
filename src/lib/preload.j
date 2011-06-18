// Used to use my own personal preloading library
library PreloadAbility requires xepreload
    function PreloadAbility takes integer abilityId returns nothing
        call XE_PreloadAbility(abilityId)
    endfunction
endlibrary
// Wrapper for AbilityPreload -> xepreload
library AbilityPreload requires xepreload
    function AbilityPreload takes integer abilityId returns nothing
        call XE_PreloadAbility(abilityId)
    endfunction
endlibrary

library Preload requires AbilityPreload

function PreloadUnit takes integer unitId returns nothing
    call RemoveUnit(CreateUnit(Player(15), unitId, 0, 0, 0))
endfunction

function PreloadItem takes integer itemId returns nothing
    call RemoveItem(CreateItem(itemId, 0., 0.))
endfunction

function PreloadItemRange takes integer start, integer end returns nothing
    loop
        exitwhen start > end
        call PreloadItem(end)
        set end = end - 1
    endloop
endfunction


endlibrary