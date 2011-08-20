library ExTextTag initializer Init //requires Gx

globals

texttag Gxs_texttag

endglobals

//  Profile based Text Tag Creator.
//  v2.0
//
//  PURPOUSE:
//  > Emulation of ingame texttags (like mana burn or critical strike).
//  
//  CREDITS:
//  > Blizzard for miscdata.txt, vJass creators for extended syntax.
//
//  HOW TO IMPORT:
//  > Copy&Paste entire code to any trigger or map header
//
//  NOTE:
//  > You will need vJass editor for globals and library declaration.

//This is database functions block.
struct Params

 integer R
 integer G
 integer B
 real    V
 integer L
 integer F
 static integer COUNT = 0
 
endstruct

function LoadParams takes integer r,integer g,integer b,real v,integer l,integer f returns nothing
  local Params A = Params.COUNT
  set A.R = r
  set A.G = g
  set A.B = b
  set A.V = v
  set A.L = l
  set A.F = f
  set Params.COUNT = Params.COUNT + 1
endfunction

//! textmacro AddProfile takes NAME,R,G,B,V,I,F
globals
    
   integer $NAME$
    
endglobals

set $NAME$ = Params.COUNT
call LoadParams($R$,$G$,$B$,$V$,$I$,$F$)
//! endtextmacro

//    call CreateTextTagEx("HAHA",0.0,0.0,true,GOLD)

function CreateTextTagEx takes string Text,real X,real Y,boolean Vision, integer Profile returns nothing
    //Generic
    local Params A = 0
    
    if Profile < Params.COUNT and Profile >= 0 then
    set A = Profile
    endif
    
    set Gxs_texttag         = CreateTextTag()
    call SetTextTagText      (Gxs_texttag, Text, 0.024)
    call SetTextTagPos       (Gxs_texttag, X, Y, 0.0  )
    call SetTextTagVisibility(Gxs_texttag, Vision     )
    call SetTextTagPermanent (Gxs_texttag, false      )
    
    call SetTextTagColor     (Gxs_texttag,A.R,A.G,A.B,255)
    call SetTextTagVelocity  (Gxs_texttag,0,A.V)
    call SetTextTagLifespan  (Gxs_texttag,A.L)
    call SetTextTagFadepoint (Gxs_texttag,A.F)
    
endfunction

private function Init takes nothing returns nothing

    ////! runtextmacro AddProfile("NULL","255","255","255","0.04","3","2")
    ////! runtextmacro AddProfile("GOLD","225","220","0","0.03","2","1")
    ////! runtextmacro AddProfile("LUMBER","0","200","80","0.03","2","1")
    //##! runtextmacro AddProfile("BOUNTY","225","220","0","0.03","3","2")
    ////! runtextmacro AddProfile("MISS","255","0","0","0.03","3","1")
    ////! runtextmacro AddProfile("SS","160","255","0","0.04","5","2")
    //! runtextmacro AddProfile("CRITICAL","255","0","0","0.04","5","2")
    //! runtextmacro AddProfile("MB","82","82","255","0.04","5","2")

endfunction

endlibrary