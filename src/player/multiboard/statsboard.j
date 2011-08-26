library StatsBoards initializer Init requires Board, UnitStatStorage, Debug


globals
	private constant boolean ENABLE_DEBUG = true

    private Board playerStats       // Shared
    private Board array unitStats   // 1 per player
    private integer playerCount = 0
    private integer currentRow = 0
    private integer array playerInfo
    
    private constant integer KILL_COL = 2
    private constant integer DEATH_COL = 3
    private constant integer SAVE_COL = 4
    
    private constant integer ATKSPD_ROW = 0
    private constant integer MOVSPD_ROW = 1
    private constant integer RESIST_ROW = 2
    private constant integer HPREGEN_ROW = 3
    private constant integer MANAREGEN_ROW = 4
endglobals

// Enable enhanced info if debugging is desired
static if Debug_Enabled then
	globals
		private constant integer DAMAGE_ROW = 5
    	private constant integer ARMOR_ROW = 6
    endglobals
endif

private struct PlayerBoardInfo
    integer kills = 0
    integer deaths = 0
    integer saves = 0
    private integer xrow
    
    method operator row takes nothing returns integer
        return xrow
    endmethod
    
    static method create takes integer row returns PlayerBoardInfo
     local thistype this = thistype.allocate()
        set this.xrow = row
        return this
    endmethod
endstruct

private function UpdatePlayerStats takes player whichPlayer returns nothing
 local PlayerBoardInfo info = playerInfo[GetPlayerId(whichPlayer)]
 local BoardRow row = playerStats[info.row]
 
    set playerStats[KILL_COL][info.row].text = I2S(info.kills)
    set playerStats[DEATH_COL][info.row].text = I2S(info.deaths)
    set playerStats[SAVE_COL][info.row].text = I2S(info.saves)
endfunction

function PlayerStats_AddKill takes player whichPlayer returns nothing
 local PlayerBoardInfo info = playerInfo[GetPlayerId(whichPlayer)]
    set info.kills = info.kills + 1
    call UpdatePlayerStats(whichPlayer)
endfunction
function PlayerStats_AddDeath takes player whichPlayer returns nothing
 local PlayerBoardInfo info = playerInfo[GetPlayerId(whichPlayer)]
    set info.deaths = info.deaths + 1
    call UpdatePlayerStats(whichPlayer)
endfunction
function PlayerStats_AddSaves takes player whichPlayer, integer saves returns nothing
 local PlayerBoardInfo info = playerInfo[GetPlayerId(whichPlayer)]
    set info.saves = info.saves + saves
    call UpdatePlayerStats(whichPlayer)
endfunction

// decimalPlaces == max decimal places
// I don't see a point in trailing 0s and I'm lazy
private function FormatReal takes real input, integer decimalPlaces returns string
 local integer whole = R2I(input)
 local integer decimal
 local real pow

    if decimalPlaces <= 0 then
        return I2S(whole)
    endif
    
    set pow = Pow(10, decimalPlaces)
    set decimal = R2I(input * pow - I2R(whole) * pow + .01)
    
    return I2S(whole) + "." + I2S(decimal)
endfunction

function UpdateUnitStatsBoard takes player whichPlayer, unit target returns nothing
 local Board board = unitStats[GetPlayerId(whichPlayer)]
 local real attackSpeed
 local integer whole
 local integer decimal

    if target == null then
        set board.title = "Select a unit"
        set board[1][ATKSPD_ROW].text = ""
        set board[1][MOVSPD_ROW].text = ""
        set board[1][RESIST_ROW].text = ""
        set board[1][HPREGEN_ROW].text = ""
        set board[1][MANAREGEN_ROW].text = ""
        
        static if Debug_Enabled then
        	set board[1][DAMAGE_ROW].text = ""
        	set board[1][ARMOR_ROW].text = ""
        endif
        	
        return
    endif

    set attackSpeed = GetUnitAttackSpeed(target)
    set whole = R2I(attackSpeed)
    set decimal = R2I(attackSpeed * 100.) - whole * 100
    
    set board.title = GetUnitName(target)
    set board[1][ATKSPD_ROW].text = FormatReal(GetUnitAttackSpeed(target), 2)
    set board[1][MOVSPD_ROW].text = I2S(R2I(GetUnitMoveSpeed(target)))
    set board[1][RESIST_ROW].text = I2S(R2I(GetUnitResistance(target)))
    set board[1][HPREGEN_ROW].text = FormatReal(GetUnitHpRegen(target), 2)
    set board[1][MANAREGEN_ROW].text = FormatReal(GetUnitManaRegen(target), 2)
    
    static if Debug_Enabled then
    	set board[1][DAMAGE_ROW].text = FormatReal(GetUnitDamage(target), 2)
    	set board[1][ARMOR_ROW].text = FormatReal(GetUnitArmor(target), 2)
    endif
endfunction

function SwitchBoard takes player p returns nothing
 local boolean showUnitStats = playerStats.visible[p]
 local Board board = unitStats[GetPlayerId(p)]

    if showUnitStats then
        set playerStats.visible[p] = false
        set board.visible[p] = true
        set board.minimized[p] = false
    else
        set board.visible[p] = false
        set playerStats.visible[p] = true
        set playerStats.minimized[p] = false
    endif

endfunction

//===================================

private function CreateUnitStatBoards takes nothing returns nothing
 local player picked = GetEnumPlayer()
 local Board board
 local BoardItem bi
 
    if GetPlayerSlotState(picked) != PLAYER_SLOT_STATE_PLAYING or GetPlayerController(picked) != MAP_CONTROL_USER then
        set picked = null
        return
    endif
    
    // Add player to the player stats board
    set currentRow = currentRow + 1
    set playerInfo[GetPlayerId(picked)] = PlayerBoardInfo.create(currentRow)
    
    set bi = playerStats[0][currentRow]
    set bi.text = GetPlayerName(picked)
    set bi.color = ARGB.fromPlayer(picked)

    call UpdatePlayerStats(picked)
    
    // Setup unit stats board for each player
    
    set board = Board.create()
    set unitStats[GetPlayerId(picked)] = board
    
    set board.title = "(Select a unit)"
    set board.row.count = 4
    set board.col.count = 1
    
    static if Debug_Enabled then
    	set board.row.count = 6
    endif

    set board.col[0].width = .07
    set board.col[1].width = .04
    
    set bi = board[0][ATKSPD_ROW]
    set bi.text = "Attack Speed"
    
    set bi = board[0][MOVSPD_ROW]
    set bi.text = "Move Speed"
    
    set bi = board[0][RESIST_ROW]
    set bi.text = "Resistance"
    
    set bi = board[0][HPREGEN_ROW]
    set bi.text = "HP Regen"
    
    set bi = board[0][MANAREGEN_ROW]
    set bi.text = "Mana Regen"
    
    static if Debug_Enabled then
    	set bi = board[0][DAMAGE_ROW]
    	set bi.text = "Damage"
    
    	set bi = board[0][ARMOR_ROW]
    	set bi.text = "Armor"
    endif

    set board.visible[picked] = true
    set board.minimized[picked] = false
endfunction

private function CountPlayers takes nothing returns nothing
 local player picked = GetEnumPlayer()
    if GetPlayerSlotState(picked) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(picked) == MAP_CONTROL_USER then
        set playerCount = playerCount +1
    endif
 set picked = null
endfunction

private function CreateBoards takes nothing returns nothing
 local BoardItem bi
    call DestroyTimer(GetExpiredTimer())

    call ForForce(bj_FORCE_ALL_PLAYERS, function CountPlayers)

    set playerStats = Board.create()
    set playerStats.title = "Player Stats"
    set playerStats.row.count = playerCount
    set playerStats.col.count = 4   // Name, <space>, kills, deaths, saves
    set playerStats.all.width = .03
    set playerStats.col[1].width = .01  // Spacer
    set playerStats.col[0].width = .06  // Name
    set playerStats.col[3].width = .04  // Deaths
    
    set bi = playerStats[0][0]
    set bi.text = "Name"
    set bi = playerStats[2][0]
    set bi.text = "Kills"
    set bi = playerStats[3][0]
    set bi.text = "Deaths"
    set bi = playerStats[4][0]
    set bi.text = "Saves"
    set playerStats.visible = false
    
    call ForForce(bj_FORCE_ALL_PLAYERS, function CreateUnitStatBoards)
endfunction

private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(), .01, false, function CreateBoards)
endfunction
    

endlibrary