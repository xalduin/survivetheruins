library Debug initializer Init


//==================
// Public
//
// public function Message takes... returns nothing
//		string category: A category for the debug message. Specific categories can be turned on/off
//		string message:  Message to be displayed
//==================

globals
	public constant boolean Enabled = false
	
	private hashtable DebugTable = null
	private constant key DISABLE_MESSAGE
endglobals

public function Message takes string category, string message returns nothing
	if HaveSavedBoolean(DebugTable, DISABLE_MESSAGE, StringHash(category)) then
		return
	endif

	set message = "[" + category + "]: " + message
	call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., message)
endfunction

//===================
// Private
//===================

private function DisableMessage takes nothing returns nothing
 local string text = GetEventPlayerChatString()
 
 	set text = SubString(text, 12, StringLength(text))
 	if StringLength(text) > 0 then
 		call SaveBoolean(DebugTable, DISABLE_MESSAGE, StringHash(text), true)
 	endif
endfunction

private function EnableMessage takes nothing returns nothing
 local string text = GetEventPlayerChatString()
 
 	set text = SubString(text, 12, StringLength(text))
 	if StringLength(text) > 0 then
 		call RemoveSavedBoolean(DebugTable, DISABLE_MESSAGE, StringHash(text))
 	endif
endfunction


private function Init takes nothing returns nothing
 local trigger t = CreateTrigger()

 	call TriggerRegisterPlayerChatEvent(t, Player(0), "-d:category:", false)
 	call TriggerAddAction(t, function DisableMessage)
 	
 	set t = CreateTrigger()
 	call TriggerRegisterPlayerChatEvent(t, Player(0), "-e:category:", false)
 	call TriggerAddAction(t, function EnableMessage)
 	
 	set DebugTable = InitHashtable()
 	
 set t = null
endfunction


endlibrary