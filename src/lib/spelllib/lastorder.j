library LastOrder initializer Init needs UnitIndexingUtils
//******************************************************************************
//* BY: Rising_Dusk
//* 
//* This library has a lot of usefulness for when you want to interface with the
//* last order a unit was given. This can be useful for simulating spell errors
//* and where you'd want to give them back the order they had prior to the spell
//* cast (whereas without this library, they'd just forget their orders).
//* 
//* There are some handy interfacing options for your use here --
//*     function GetLastOrderId takes unit u returns integer
//*     function GetLastOrderString takes unit u returns string
//*     function GetLastOrderType takes unit u returns integer
//*     function GetLastOrderX takes unit u returns real
//*     function GetLastOrderY takes unit u returns real
//*     function GetLastOrderTarget takes unit u returns widget
//*     function AbortOrder takes unit u returns boolean
//*
//* There are also some order commands that can be useful --
//*     function IssueLastOrder takes unit u returns boolean
//*     function IssueSecondLastOrder takes unit u returns boolean
//*     function IsLastOrderFinished takes unit u returns boolean
//* 
//* You can access any information you'd like about the orders for your own
//* order handling needs.
//* 
globals
    //* Storage for last order
    private          integer array Order
    private          integer array Type
    private          widget  array Targ
    private          boolean array Flag
    private          real    array X
    private          real    array Y
    
    //* Storage for second last order
    private          integer array P_Order
    private          integer array P_Type
    private          widget  array P_Targ
    private          boolean array P_Flag
    private          real    array P_X
    private          real    array P_Y
    
    //* Order type variables
            constant integer       ORDER_TYPE_TARGET    = 1
            constant integer       ORDER_TYPE_POINT     = 2
            constant integer       ORDER_TYPE_IMMEDIATE = 3
    
    //* Trigger for the order catching
    private          trigger       OrderTrg             = CreateTrigger()
endglobals

//**********************************************************
function GetLastOrderId takes unit u returns integer
    return Order[GetUnitId(u)]
endfunction
function GetLastOrderString takes unit u returns string
    return OrderId2String(Order[GetUnitId(u)])
endfunction
function GetLastOrderType takes unit u returns integer
    return Type[GetUnitId(u)]
endfunction
function GetLastOrderX takes unit u returns real
    return X[GetUnitId(u)]
endfunction
function GetLastOrderY takes unit u returns real
    return Y[GetUnitId(u)]
endfunction
function GetLastOrderTarget takes unit u returns widget
    return Targ[GetUnitId(u)]
endfunction
//**********************************************************
private function OrderExclusions takes unit u, integer id returns boolean
    //* Excludes specific orders or unit types from registering with the system
    //* 
    //* 851972: stop
    //*         Stop is excluded from the system, but you can change it by
    //*         adding a check for it below. id == 851972
    //* 
    //* 851971: smart
    //* 851986: move
    //* 851983: attack
    //* 851984: attackground
    //* 851990: patrol
    //* 851993: holdposition
    //*         These are the UI orders that are passed to the system.
    //* 
    //* >= 852055, <= 852762
    //*         These are all spell IDs from defend to incineratearrowoff with
    //*         a bit of leeway at the ends for orders with no strings.
    //* 
    return id == 851971 or id == 851986 or id == 851983 or id == 851984 or id == 851990 or id == 851993 or (id >= 852055 and id <= 852762)
endfunction
private function LastOrderFilter takes unit u returns boolean
    //* Some criteria for whether or not a unit's last order should be given
    //* 
    //* INSTANT type orders are excluded because generally, reissuing an instant
    //* order doesn't make sense. You can remove that check below if you'd like,
    //* though.
    //* 
    //* The Type check is really just to ensure that no spell recursion can
    //* occur with IssueLastOrder. The problem with intercepting the spell cast
    //* event is that it happens after the order is 'caught' and registered to
    //* this system. Therefore, to just IssueLastOrder tells it to recast the
    //* spell! That's a problem, so we need a method to eliminate it.
    //* 
    local integer id = GetUnitId(u)
    return u != null and GetWidgetLife(u) > 0.405 and Type[id] != ORDER_TYPE_IMMEDIATE
endfunction
private function SecondLastOrderFilter takes unit u returns boolean
    //* Same as above but with regard to the second last order issued
    local integer id = GetUnitId(u)
    return u != null and GetWidgetLife(u) > 0.405 and P_Type[id] != ORDER_TYPE_IMMEDIATE and P_Order[id] != Order[id]
endfunction
//**********************************************************

function IsLastOrderFinished takes unit u returns boolean
    return (GetUnitCurrentOrder(u) == 0 and Order[GetUnitId(u)] != 851972) or Flag[GetUnitId(u)]
endfunction

function IssueLastOrder takes unit u returns boolean
    local integer id = GetUnitId(u)
    if LastOrderFilter(u) and Order[id] != 0 and not Flag[id] then
        if Type[id] == ORDER_TYPE_TARGET then
            return IssueTargetOrderById(u, Order[id], Targ[id])
        elseif Type[id] == ORDER_TYPE_POINT then
            return IssuePointOrderById(u, Order[id], X[id], Y[id])
        elseif Type[id] == ORDER_TYPE_IMMEDIATE then
            return IssueImmediateOrderById(u, Order[id])
        endif
    endif
    return false
endfunction

function IssueSecondLastOrder takes unit u returns boolean
    //* This function has to exist because of spell recursion
    local integer id = GetUnitId(u)
    if SecondLastOrderFilter(u) and P_Order[id] != 0 and not P_Flag[id] then
        if P_Type[id] == ORDER_TYPE_TARGET then
            return IssueTargetOrderById(u, P_Order[id], P_Targ[id])
        elseif P_Type[id] == ORDER_TYPE_POINT then
            return IssuePointOrderById(u, P_Order[id], P_X[id], P_Y[id])
        elseif P_Type[id] == ORDER_TYPE_IMMEDIATE then
            return IssueImmediateOrderById(u, P_Order[id])
        endif
    endif
    return false
endfunction

function AbortOrder takes unit u returns boolean
    if IsUnitPaused(u) then
        return false
    else
        call PauseUnit(u, true)
        call IssueImmediateOrder(u, "stop")
        call PauseUnit(u, false)
    endif
    return true
endfunction
//**********************************************************

private function Conditions takes nothing returns boolean
    return OrderExclusions(GetTriggerUnit(), GetIssuedOrderId())
endfunction

private function Actions takes nothing returns nothing
    local unit    u  = GetTriggerUnit()
    local integer id = GetUnitId(u)
    
    //* Store second to last order to eliminate spell recursion
    set P_Order[id]  = Order[id]
    set P_Targ[id]   = Targ[id]
    set P_Type[id]   = Type[id]
    set P_Flag[id]   = Flag[id]
    set P_X[id]      = X[id]
    set P_Y[id]      = Y[id]
    
    set Flag[id]     = false
    set Order[id]    = GetIssuedOrderId()
    if GetTriggerEventId() == EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER then
        set Targ[id] = GetOrderTarget()
        set Type[id] = ORDER_TYPE_TARGET
        set X[id]    = GetWidgetX(GetOrderTarget())
        set Y[id]    = GetWidgetY(GetOrderTarget())
    elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER then
        set Targ[id] = null
        set Type[id] = ORDER_TYPE_POINT
        set X[id]    = GetOrderPointX()
        set Y[id]    = GetOrderPointY()
    elseif GetTriggerEventId() == EVENT_PLAYER_UNIT_ISSUED_ORDER then
        set Targ[id] = null
        set Type[id] = ORDER_TYPE_IMMEDIATE
        set X[id]    = GetUnitX(u)
        set Y[id]    = GetUnitY(u)
    debug else
        debug call BJDebugMsg(SCOPE_PREFIX+" Error: Order Doesn't Exist")
    endif
    
    set u = null
endfunction
//**********************************************************

private function SpellActions takes nothing returns nothing
    set Flag[GetUnitId(GetTriggerUnit())] = true
endfunction
//**********************************************************

private function Init takes nothing returns nothing
    local trigger trg = CreateTrigger()
    call TriggerAddAction(OrderTrg, function Actions)
    call TriggerAddCondition(OrderTrg, Condition(function Conditions))
    call TriggerRegisterAnyUnitEventBJ(OrderTrg, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    call TriggerRegisterAnyUnitEventBJ(OrderTrg, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    call TriggerRegisterAnyUnitEventBJ(OrderTrg, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    
    call TriggerAddAction(trg, function SpellActions)
    call TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    
    set trg = null
endfunction
endlibrary