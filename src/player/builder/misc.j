library BuildingMisc


globals
    private constant integer freezingBreathBuffId = 'Bfrz'
endglobals

function IsBuildingDisabled takes unit building returns boolean
    return GetUnitAbilityLevel(building, freezingBreathBuffId) > 0
endfunction


endlibrary