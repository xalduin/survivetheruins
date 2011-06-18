scope Bloodlust initializer Init


globals
    private constant integer abilityId = 'A013'
    
    //private constant integer dummyAuraId
    //private constant integer dummyBuffId
    
    private constant real attackMult = .5
    private constant real moveMult = .25
    private constant real spellDuration = 30.
    
    private constant key buffKey
endglobals

private function GetBuff takes nothing returns BuffType
 local SpeedBuff speedBuff = SpeedBuff.create(buffKey)

    set speedBuff.attackMultiplier = attackMult
    set speedBuff.movementMultiplier = moveMult
    return speedBuff
endfunction

private function Main takes nothing returns nothing
    call UnitApplyBuff(GetTriggerUnit(), GetSpellTargetUnit(), GetBuff(), 1, spellDuration)
endfunction

private function Init takes nothing returns nothing
    call Ability_OnEffect(abilityId, function Main)
endfunction


endscope