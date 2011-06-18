library CommandAI initializer InitCommand requires TimerStack, GroupUtils, AICommand, AISpawn, Lich


globals
    private group commandGroup = CreateGroup()
    group enemies   // Holds players' units
    boolean firstWave = true
    
    boolean spawnedCryptLord = false
    boolean spawnedLich = false
    
    unit CryptLord = null
    unit Lich = null
endglobals

private struct TimerData
    real elapsed
    real totalTime
endstruct

private function Command takes nothing returns nothing
 local TimerData data = GetTimerData(GetExpiredTimer())
 local real elapsed = data.elapsed + 5.
 local real totalTime = data.totalTime + 5.
 local real x
 local real y

    if (not udg_started) or udg_gameOver then
        return
    endif
    
    // Unit spawning
    if elapsed >= spawnInterval then

        set elapsed = elapsed - spawnInterval
        call SpawnUnits(totalTime)
        
    elseif GetSpawnAmount() == 0 then
    
        call SpawnUnits(totalTime)

    endif

    if firstWave then
        set firstWave = false
        set elapsed = 0
    endif
    
    // Unit tier changing
    if totalTime > updateTypeInterval * currentTier and currentTier < maxTier then
        set currentTier = currentTier + 1
    endif
    
    // Lich - 12 minutes remaining
    if totalTime >= 1080. and not spawnedLich then
        set spawnedLich = true
        set Lich = CreateSpawn('u00G')
        call StartLich()
        call ClearTextMessages()
        call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., "A sudden chill spreads through the ruins...")
    endif
    
    // Crypt Lord - 5 minutes remaining
    if totalTime >= 1500. and not spawnedCryptLord then
        set spawnedCryptLord = true
        set CryptLord = CreateSpawn('u000')
        call ClearTextMessages()
        call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., "A roar is heard from deep within the ruins!")
    endif

    set data.elapsed = elapsed
    set data.totalTime = totalTime

    call GroupClear(commandGroup)
    call GroupEnumUnitsOfPlayer(commandGroup, Player(11), spawnFilter)

    call ForGroup(commandGroup, function AICommand)
endfunction

private function InitCommand takes nothing returns nothing
 local timer commandTimer = NewTimerStart(5., true, function Command)
 local TimerData data = TimerData.create()

    set enemies = CreateGroup()
    set data.elapsed = 0.
    set data.totalTime = 0.
    call SetTimerData(commandTimer, data)
endfunction


endlibrary