library AISpawn initializer Init requires UnitId, SpawnType


globals
    constant integer upgradeLimit = 40  // Max level of upgrades in object editor

    integer maxTier = 5               // How many waves of spawns
    integer currentTier = 1           // Current spawn wave
    //integer array spawnType         // Holds all the spawn unitIds
    //integer array spawnLevelStart   // Used to indicating which indexes each wave starts/ends
    //integer array spawnLevelEnd

    integer spawnsPerInterval = 5   // When undead are spawned, number that are spawned
    real updateTypeInterval = 300.  // Interval at which the wave is upgraded
    real spawnInterval = 45.        // How often undead are spawned
    real upgradeInterval = 140.     // Interval at which unit upgrades are applied
    real spawnCountInterval = 280.  // How often the spawn count is upgraded
    integer maxUpgrades = 30        // Maximum amount of undead upgrades to be applied
    integer upgradeLevel = 0        // Keeps track of the current upgrade level
    real difficultyScale = 0.
    
    real nextIncrease = 0.          // Increased every 5 minutes to be 5 minutes more

    boolexpr spawnFilter = null
    constant string spawnSFX = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
    constant integer maxSpawns = 50 // Don't allow more spawns than this at once
endglobals


struct SpawnData extends array
    unit target
    real targetx
    real targety
    boolean aquired

    method reset takes nothing returns nothing
        set this.target = null
        set this.targetx = 0.
        set this.targety = 0.
        set this.aquired = false
    endmethod
endstruct

function SpawnFilter takes nothing returns boolean
    return GetWidgetLife(GetFilterUnit()) > .405 and GetUnitTypeId(GetFilterUnit()) != 'u008' and GetUnitTypeId(GetFilterUnit()) != 'u00H'
endfunction

function GetSpawnAmount takes nothing returns integer
 local integer result
 
    call GroupClear(ENUM_GROUP)
    call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(11), spawnFilter)
    set result = CountUnitsInGroup(ENUM_GROUP)
    call GroupClear(ENUM_GROUP)

    return result
endfunction

globals
    // If all enemies are killed before next wave spawned, is increased
    // Used as a way to track how well players are doing
    private integer clearWaveCount = 0
endglobals

// Returns: Extra number of enemies to spawn
// The function also adjusts spawnsPerInterval if deemed necessary

function AdjustDifficulty takes nothing returns integer
 local integer spawnCount = GetSpawnAmount()
 local integer result = 0
 
    if spawnCount <= spawnsPerInterval / 3 then
        set clearWaveCount = clearWaveCount + 1
    elseif clearWaveCount > 0 then
        //set clearWaveCount = clearWaveCount - 1
    endif
    
    //if totalTime > nextIncrease then
    //    set spawnsPerInterval = spawnsPerInterval + 1
    //    set nextIncrease = nextIncrease + spawnCountInterval
    //    return 0
    //endif

    if clearWaveCount > 1 then
        set spawnsPerInterval = spawnsPerInterval + 1
        
        // Already increased the spawnsPerInterval and still all killed off!
        //if clearWaveCount > 3 then
        //    set result = R2I(I2R(spawnsPerInterval) / 2. + .5)
        //else
            set result = R2I(I2R(spawnsPerInterval) / 3. + .5)
        //endif
        
        set clearWaveCount = 0
        
        return result
    endif
    
    return 0
endfunction

function CreateSpawn takes integer unitType returns unit
 local real x = GetRandomReal(GetRectMinX(udg_SpawnRegion), GetRectMaxX(udg_SpawnRegion))
 local real y = GetRandomReal(GetRectMinY(udg_SpawnRegion), GetRectMaxY(udg_SpawnRegion))
 local unit spawn = CreateUnit(Player(11), unitType, x, y, 0)
 
    call SpawnData[GetUnitId(spawn)].reset()
    call DestroyEffect( AddSpecialEffect(spawnSFX, GetUnitX(spawn), GetUnitY(spawn)) )
   
    set bj_lastCreatedUnit = spawn
    set spawn = null

    return bj_lastCreatedUnit
endfunction

function SpawnUnits takes real totalTime returns nothing
 local unit spawn
 local integer i = 0
 local integer unitType
 local integer spawnIncrease = 0
 local real x
 local real y

    if not udg_started then
        return
    endif
    
    set spawnIncrease = AdjustDifficulty()

    loop
        exitwhen i >= spawnsPerInterval + spawnIncrease
        set unitType = GetRandomSpawn(currentTier)
        call CreateSpawn(unitType)
        set i = i + 1
    endloop
    
 set spawn = null
endfunction

private function Init takes nothing returns nothing
    set spawnFilter = Filter(function SpawnFilter)
endfunction


endlibrary