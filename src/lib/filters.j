library CommonFilters initializer InitCommonFilters


globals
    player filterPlayer
    unit filterUnit
    
    boolexpr Filter_Null
    boolexpr Filter_IsUnitPlayerUnit
    boolexpr Filter_IsUnitEnemy
    boolexpr Filter_IsUnitAlly
    boolexpr Filter_IsUnitHero
    boolexpr Filter_IsUnitStructure
    boolexpr Filter_IsUnitAlive
    boolexpr Filter_IsUnitMagicImmune
    boolexpr Filter_IsUnitDamaged
    boolexpr Filter_IsUnitGround
    boolexpr Filter_IsUnitAncient
    boolexpr Filter_IsUnitMechanical
    boolexpr Filter_IsUnitInvulnerable
    
    boolexpr Filter_NotIsUnitStructure
    boolexpr Filter_NotIsUnitMagicImmune
    boolexpr Filter_NotIsUnitInvulnerable
    boolexpr Filter_IsUnitOrganic
    
    boolexpr Filter_NotIsUnitSapper
    boolexpr Filter_NotIsUnitHero
    boolexpr Filter_NotIsUnitAncient
    boolexpr Filter_NotIsUnitSelf
    boolexpr Filter_IsUnitAir
    
    // Valid == non spell immune
    
    boolexpr Filter_IsUnitEnemyHero
    boolexpr Filter_IsUnitAlliedHero
    boolexpr Filter_IsUnitValidTarget
    boolexpr Filter_IsUnitValidSpellTarget
    boolexpr Filter_IsUnitValidOrganicTarget
    boolexpr Filter_IsUnitValidOrganicSpellTarget
    boolexpr Filter_IsUnitOrganicTarget
    boolexpr Filter_IsUnitNotHero
    boolexpr Filter_IsUnitHealTarget
    boolexpr Filter_IsUnitGroundTarget
    boolexpr Filter_IsUnitStructureTarget
    boolexpr Filter_IsUnitValidBuffTarget
    boolexpr Filter_IsUnitAnyValidTarget  // Building, unit, non spell immune, etc
    boolexpr Filter_IsUnitAnyValidSpellTarget
endglobals

function Null_Filter takes nothing returns boolean
    return true
endfunction

function IsUnitPlayerUnit_Filter takes nothing returns boolean
    return GetOwningPlayer(GetFilterUnit()) == filterPlayer
endfunction

function IsUnitEnemy_Filter takes nothing returns boolean
    return IsUnitEnemy(GetFilterUnit(), filterPlayer)
endfunction

function IsUnitAlly_Filter takes nothing returns boolean
    return IsUnitAlly(GetFilterUnit(), filterPlayer)
endfunction

function IsUnitHero_Filter takes nothing returns boolean
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) == true
endfunction

function IsUnitStructure_Filter takes nothing returns boolean
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == true
endfunction

function IsUnitAlive_Filter takes nothing returns boolean
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) == false
endfunction

function IsUnitMagicImmune_Filter takes nothing returns boolean
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) == true
endfunction

function IsUnitDamaged_Filter takes nothing returns boolean
    return GetWidgetLife(GetFilterUnit()) < GetUnitState(GetFilterUnit(), UNIT_STATE_MAX_LIFE)
endfunction

function IsUnitGround_Filter takes nothing returns boolean
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_GROUND) == true
endfunction

function IsUnitAncient_Filter takes nothing returns boolean
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_ANCIENT) == false
endfunction

function IsUnitMechanical_Filter takes nothing returns boolean
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL) == true
endfunction

function IsUnitInvulnerable_Filter takes nothing returns boolean
    return GetUnitAbilityLevel(GetFilterUnit(), 'Avul') > 0 or GetUnitAbilityLevel(GetFilterUnit(), 'Bvul') > 0
endfunction

function NotIsUnitSapper_Filter takes nothing returns boolean
    return IsUnitType(GetFilterUnit(), UNIT_TYPE_SAPPER) == false
endfunction

function NotIsUnitSelf_Filter takes nothing returns boolean
    return GetFilterUnit() != filterUnit
endfunction

private function InitCommonFilters takes nothing returns nothing
    set Filter_Null = Filter(function Null_Filter)
    set Filter_IsUnitPlayerUnit = Filter(function IsUnitPlayerUnit_Filter)
    set Filter_IsUnitEnemy = Filter(function IsUnitEnemy_Filter)
    set Filter_IsUnitAlly = Filter(function IsUnitAlly_Filter)
    set Filter_IsUnitHero = Filter(function IsUnitHero_Filter)
    set Filter_IsUnitStructure = Filter(function IsUnitStructure_Filter)
    set Filter_IsUnitAlive = Filter(function IsUnitAlive_Filter)
    set Filter_IsUnitMagicImmune = Filter(function IsUnitMagicImmune_Filter)
    set Filter_IsUnitDamaged = Filter(function IsUnitDamaged_Filter)
    set Filter_IsUnitGround = Filter(function IsUnitGround_Filter)
    set Filter_IsUnitAncient = Filter(function IsUnitAncient_Filter)
    set Filter_IsUnitMechanical = Filter(function IsUnitMechanical_Filter)
    set Filter_IsUnitInvulnerable = Filter(function IsUnitInvulnerable_Filter)

    set Filter_NotIsUnitStructure = Not(Filter_IsUnitStructure)
    set Filter_NotIsUnitMagicImmune = Not(Filter_IsUnitMagicImmune)
    set Filter_NotIsUnitInvulnerable = Not(Filter_IsUnitInvulnerable)
    set Filter_IsUnitOrganic = Not(Filter_IsUnitMechanical)
    
    set Filter_NotIsUnitSelf = Filter(function NotIsUnitSelf_Filter)
    set Filter_NotIsUnitHero = Not(Filter_IsUnitHero)
    set Filter_NotIsUnitAncient = Not(Filter_IsUnitAncient)
    set Filter_NotIsUnitSapper = Filter(function NotIsUnitSapper_Filter)
    set Filter_IsUnitAir = Not(Filter_IsUnitGround)
    
    set Filter_IsUnitEnemyHero = And(Filter_IsUnitEnemy, Filter_IsUnitHero)
    set Filter_IsUnitAlliedHero = And(Filter_IsUnitAlly, Filter_IsUnitHero)
    set Filter_IsUnitAnyValidTarget = And(Filter_IsUnitAlive, And(Filter_IsUnitEnemy, Filter_NotIsUnitInvulnerable))
    set Filter_IsUnitAnyValidSpellTarget = And(Filter_IsUnitAnyValidTarget, Filter_NotIsUnitMagicImmune)
    set Filter_IsUnitValidTarget = And(Filter_IsUnitAnyValidTarget, Filter_NotIsUnitStructure)
    set Filter_IsUnitValidSpellTarget = And(Filter_IsUnitValidTarget, Filter_NotIsUnitMagicImmune)
    set Filter_IsUnitValidOrganicTarget = And(Filter_IsUnitValidTarget, Filter_IsUnitOrganic)
    set Filter_IsUnitValidOrganicSpellTarget = And(Filter_IsUnitValidOrganicTarget, Filter_NotIsUnitMagicImmune)
    set Filter_IsUnitOrganicTarget = And( Filter_IsUnitOrganic, And(Filter_IsUnitEnemy, Filter_IsUnitAlive) )
    set Filter_IsUnitNotHero = Not(Filter_IsUnitHero)
    set Filter_IsUnitHealTarget = And(And(Filter_IsUnitAlly, Filter_IsUnitAlive), And(Filter_IsUnitDamaged, Filter_IsUnitOrganic))
    set Filter_IsUnitGroundTarget = And(Filter_IsUnitValidTarget, Filter_IsUnitGround)
    set Filter_IsUnitStructureTarget = And( Filter_IsUnitEnemy, And(Filter_IsUnitAlive, Filter_IsUnitStructure) )
    set Filter_IsUnitValidBuffTarget = And(Filter_IsUnitAlly, Filter_IsUnitAlive)
endfunction


endlibrary