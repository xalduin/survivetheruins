library SpawnType initializer Init requires Preload

globals
    private hashtable spawnTable            // Holds spawn type data
    private integer tierCount = 0
    private constant integer classCount = -11
    
    private constant boolean DEBUG_SPAWN = false
endglobals

type int_array extends integer array[10]

private struct SpawnType
    private int_array unitTypes
    private integer unitCount
    integer tier
    integer class
    
    method addType takes integer id returns nothing
        set this.unitTypes[this.unitCount] = id
        set this.unitCount = this.unitCount + 1
    endmethod
    
    method getRandomType takes nothing returns integer
        return this.unitTypes[GetRandomInt(0, this.unitCount - 1)]
    endmethod
    
    method count takes nothing returns integer
        return this.unitCount
    endmethod
    
    static method create takes integer tier, integer class returns thistype
     local SpawnType this = SpawnType.allocate()
     
        set this.unitTypes = int_array.create()
        set this.unitCount = 0
        set this.tier = tier
        set this.class = class

        return this
    endmethod
endstruct

function AddSpawnType takes integer tier, integer class, integer id returns nothing
 local SpawnType spawnType
 local integer count

    call PreloadUnit(id)
 
    if HaveSavedInteger(spawnTable, tier, class) then
        set spawnType = LoadInteger(spawnTable, tier, class)
        
        static if DEBUG_MODE then
            if spawnType.tier != tier then
                call BJDebugMsg("ASIncorrect tier! " + I2S(tier) + " " + I2S(class) + I2S(spawnType.tier) + I2S(spawnType.class))
            endif
        
            if spawnType.class != class then
                call BJDebugMsg("ASIncorrect class! " + I2S(tier) + " " + I2S(class) + I2S(spawnType.tier) + I2S(spawnType.class))
            endif
        endif
        
    else
        set spawnType = SpawnType.create(tier, class)
        call SaveInteger(spawnTable, tier, class, spawnType)
        
        if not HaveSavedInteger(spawnTable, tier, classCount) then
            set tierCount = tierCount + 1
        endif
        
        set count = LoadInteger(spawnTable, tier, classCount)
        call SaveInteger(spawnTable, tier, classCount, count + 1)
    endif
    
    call spawnType.addType(id)
endfunction

function GetRandomSpawn takes integer tier returns integer
 local integer class
 
    set class = LoadInteger(spawnTable, tier, classCount)
 
    static if DEBUG_MODE then
        if not HaveSavedInteger(spawnTable, tier, class) then
            call Error("RandomSpawn", "No entry for (" + I2S(tier) + ", " + I2S(class) + ")")
            return -1
        elseif DEBUG_SPAWN then
            call BJDebugMsg("Spawning (" + I2S(tier) + ", " + I2S(class) + ")")
        endif
    endif
    
    return LoadInteger(spawnTable, tier, GetRandomInt(1, class))
endfunction

private function SetupSpawnTypes takes nothing returns nothing
    call AddSpawnType(1, 1, 'u002')
    call AddSpawnType(1, 1, 'n00V')
    call AddSpawnType(1, 2, 'n003')
    call AddSpawnType(1, 2, 'n00W')
    call AddSpawnType(1, 3, 'u009')
    
    call AddSpawnType(2, 1, 'u001')
    call AddSpawnType(2, 1, 'n00Q')
    call AddSpawnType(2, 1, 'n00Z')
    call AddSpawnType(2, 2, 'u00A')
    call AddSpawnType(2, 2, 'n00R')
    call AddSpawnType(2, 2, 'n00X')
    call AddSpawnType(2, 3, 'n00G')
    call AddSpawnType(2, 3, 'n00S')
    call AddSpawnType(2, 4, 'n00K')
    
    call AddSpawnType(3, 1, 'n00H')
    call AddSpawnType(3, 1, 'n00T')
    call AddSpawnType(3, 2, 'u005')
    call AddSpawnType(3, 2, 'n00U')
    call AddSpawnType(3, 3, 'u007')
    call AddSpawnType(3, 3, 'n00Y')
    
    call AddSpawnType(4, 1, 'n000')
    call AddSpawnType(4, 1, 'u00F')
    call AddSpawnType(4, 2, 'n001')
    call AddSpawnType(4, 3, 'n002')
    
    call AddSpawnType(5, 1, 'u003')
    call AddSpawnType(5, 2, 'u004')
    call AddSpawnType(5, 3, 'u00B')
    call AddSpawnType(5, 4, 'u006')
    call AddSpawnType(5, 5, 'n00L')
endfunction

private function SelectSpawnTypes takes nothing returns nothing
 local integer tier = 1
 local integer class
 local SpawnType spawnType
 local integer temp
 
    loop
        exitwhen tier > tierCount
        
        set class = LoadInteger(spawnTable, tier, classCount)
        loop
            exitwhen class <= 0
            
            set spawnType = LoadInteger(spawnTable, tier, class)
            
            static if DEBUG_MODE then
                if spawnType.tier != tier then
                    call BJDebugMsg("SSIncorrect tier! " + I2S(tier) + " " + I2S(class) + I2S(spawnType.tier) + I2S(spawnType.class))
                endif
                if spawnType.class != class then
                    call BJDebugMsg("SSIncorrect class! " + I2S(tier) + " " + I2S(class) + I2S(spawnType.tier) + I2S(spawnType.class))
                endif
            endif
            
            set temp = spawnType.getRandomType()
            call spawnType.destroy()
            call SaveInteger(spawnTable, tier, class, temp)
            
            set class = class - 1
        endloop
        
        set tier = tier + 1
    endloop
    
endfunction

private function Init takes nothing returns nothing
    set spawnTable = InitHashtable()
    call SetupSpawnTypes()
    call SelectSpawnTypes()
endfunction


endlibrary