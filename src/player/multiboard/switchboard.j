scope MultiboardSwitch initializer Init


private function Main takes nothing returns nothing
    call SwitchBoard(GetTriggerPlayer())
endfunction

//===========================================================================
private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()
 local integer i = 0
    
    loop
        exitwhen i >= 10
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-board", true)
        set i = i + 1
    endloop

    call TriggerAddAction(t, function Main)
 set t = null
endfunction


endscope