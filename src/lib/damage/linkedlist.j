//==============================================================================
//  LinkedList script by Ammorth - Version 1.2b - February 2, 2010
//==============================================================================
//
//  Purpose:
//      - Adds linked list functionality to vJass.
//
//  about:
//      - Stores data in a doubly-linked list, allowing one to add and remove 
//      data easily anywhere within the list.
//       
//  Usage:
//      - Create a new empty list with List.create()
//      - Add new data to the front of the list with Link.create(list, data)
//      - Add new data to the back of the list with Link.createLast(list, data)
//      - Insert new data before a link with link.insertBefore(data)
//      - Insert new data after a link with link.insert(data)
//      - Get the next and previous links with link.next and link.prev
//      - Get the list a link belongs to with link.parent
//      - Get the first or last link in a list with list.first or list.last
//      - Get the size of a list with list.size
//      - Get the link which contains data with list.Search(data)
//      - Remove a link with link.destroy()
//      - Destroy the entire list (including links) with list.destroy()      
//
//  Notes:
//      - If you find you are creating large lists, or that you are using them
//      to store long-term data, you can increase the number of links avaliable,
//      with a slight hit to performance (default is 8190).
//      - The number of lists avaliable is set at 8190.  If you need more, you
//      need a better approach at managing data.
//      - Except for the data, all variables are read-only (don't try and use 
//      the 'x' versions).
//
//  Requirements:
//      - JassHelper version 0.9.E.0 or newer (older versions may still work).
//
//  Installation:
//      - Create a new trigger called LinkedList.
//      - Convert it to custom text and replace all the code with this code.
//
//  Special Thanks:
//      - Rising_Dusk: helping me with the 1.1 code and idea
//      - Vexorian: giving me some hints about JassHelper
//      - Anitarf: convincing me that simpler is better
//
//==============================================================================
library LinkedList
globals
//==============================================================================
// Change this value here to increase the number of avaliable links (see notes).
    private constant integer LINK_SIZE = 8190 // defualt 8190
//==============================================================================
endglobals
private keyword xnext
private keyword xprev
private keyword xparent
private keyword xfirst
private keyword xlast

struct Link[LINK_SIZE]
    integer data
    Link xnext
    Link xprev
    List xparent
    
    method operator next takes nothing returns Link
        return this.xnext
    endmethod
    method operator prev takes nothing returns Link
        return this.xprev
    endmethod
    method operator parent takes nothing returns List
        return this.xparent
    endmethod
    
    private static method createEmpty takes List parent, integer data returns Link
        local Link new = Link.allocate()
        set new.data = data
        set new.xparent = parent
        return new
    endmethod
    
    method insert takes integer data returns Link
        local Link new = Link.createEmpty(this.xparent, data)
        set new.xprev = this
        set new.xnext = this.xnext
        if this.xnext == 0 then
            set this.xparent.xlast = new
        else
            set this.xnext.xprev = new
        endif
        set this.xnext = new
        return new
    endmethod

     method insertBefore takes integer data returns Link
        local Link new = Link.createEmpty(this.xparent, data)
        set new.xprev = this.xprev
        set new.xnext = this
        if this.xprev == 0 then
            set this.xparent.xfirst = new
        else
            set this.xprev.xnext = new
        endif
        set this.xprev = new
        return new
    endmethod
    
    static method create takes List l, integer data returns Link
        local Link new
        if l == 0 then
            debug call BJDebugMsg("Error: Cannot create Link for null List in Link.create()")
            return 0
        endif
        if l.xfirst == 0 then
            set new = Link.createEmpty(l, data)
            set l.xfirst = new
            set l.xlast = new
            set new.xnext = 0
            set new.xprev = 0
            return new
        else
            return l.xfirst.insertBefore(data)
        endif
    endmethod
    
    static method createLast takes List l, integer data returns Link
        if l == 0 then
            debug call BJDebugMsg("Error: Cannot create Link for null List in Link.createLast()")
            return 0
        endif
        if l.xlast == 0 then
            return Link.create(l, data)
        else
            return l.xlast.insert(data)
        endif
    endmethod
    
    method onDestroy takes nothing returns nothing
        if this.xparent == 0 then
            if this.xnext != 0 then
                set this.xnext.xparent = 0
                call this.xnext.destroy()
            endif
        else
            if this.xprev == 0 then
                set this.xparent.xfirst = this.xnext
            else
                set this.xprev.xnext = this.xnext
            endif
            if this.xnext == 0 then
                set this.xparent.xlast = this.xprev
            else
                set this.xnext.xprev = this.xprev
            endif
        endif
        set this.xnext = 0
        set this.xprev = 0
        set this.data = 0
    endmethod
endstruct

struct List
    Link xfirst
    Link xlast
    
    static method create takes nothing returns List
        local List new = List.allocate()
        set new.xfirst = 0
        set new.xlast = 0
        return new
    endmethod
    
    method operator first takes nothing returns Link
        return this.xfirst
    endmethod
    method operator last takes nothing returns Link
        return this.xlast
    endmethod
    method operator size takes nothing returns integer
        local Link n = this.xfirst
        local integer out = 0
        loop
            exitwhen n == 0
            set n = n.xnext
            set out = out + 1
        endloop
        return out
    endmethod
    
    method onDestroy takes nothing returns nothing
        if this.xfirst != 0 then
            set this.xfirst.xparent = 0
            call this.xfirst.destroy()
        endif
        set this.xfirst = 0
        set this.xlast = 0
    endmethod
    
    method search takes integer data returns Link
        local Link temp = this.xfirst
        loop
            exitwhen temp == 0
            if temp.data == data then
                return temp
            endif
            set temp = temp.xnext
        endloop
        return 0
    endmethod
endstruct

endlibrary
//==============================================================================
//  End of LinkedList script
//==============================================================================