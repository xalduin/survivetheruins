library TimerUtils requires TimerStack
endlibrary

library TimerStack initializer InitStack


globals
	// Additional debug switch for more verbose output
    private constant boolean DEBUG_STACK = false
    constant integer maxTimers = 511

    private timer array timerStack
    private integer timerCount = 0
    private integer baseIndex
    
    integer array timerData
endglobals

private function HandleToInt takes handle h returns integer
    return GetHandleId(h) // requires 1.23b+
endfunction

private function InitStack takes nothing returns nothing
 local integer i = 1

    set timerStack[0] = CreateTimer()
    set baseIndex = HandleToInt(timerStack[0])
    loop
        exitwhen i >= maxTimers

        set timerStack[i] = CreateTimer()

        set i = i + 1
    endloop

    set timerCount = i - 1
endfunction

function NewTimer takes nothing returns timer
    set timerCount = timerCount - 1

    static if Debug_Enabled then
        if timerCount < 0 then
            call Debug_Message("timerstack", "|cffff0000Critical Error:|r Reached timer stack limit!")
        endif
    endif
    
    static if DEBUG_STACK then
        call BJDebugMsg("New Timer # " + I2S(timerCount+1))
    endif
    
    return timerStack[timerCount + 1]
endfunction

function ReleaseTimer takes timer t returns nothing
    call PauseTimer(t)

    set timerCount = timerCount + 1
    
    static if Debug_Enabled then
        if timerCount > maxTimers then
            call Debug_Message("timerstack", "|cffff0000Critical Error:|r Timer Stack overflow")
        endif
    endif
    
    static if DEBUG_STACK then
        call BJDebugMsg("Release Timer # " + I2S(timerCount))
    endif

    set timerStack[timerCount] = t
endfunction

function SetTimerData takes timer t, integer value returns nothing
    set timerData[HandleToInt(t) - baseIndex] = value
endfunction

function GetTimerData takes timer t returns integer
    return timerData[HandleToInt(t) - baseIndex]
endfunction

function NewTimerStart takes real timeout, boolean periodic, code callback returns timer
 local timer t = NewTimer()
    call TimerStart(t, timeout, periodic, callback)
    return t
endfunction


endlibrary