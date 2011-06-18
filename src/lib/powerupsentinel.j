//! zinc
//
//  PowerupSentinel
//  ------------
//    Placing this library in your map will automatically fix all rune/tome
// memory leaks in your map.
//
//    Powerup items don't get removed automatically by the game, they instead
// just leave a small item in the map, this caused memory leaks but - worse -
// it also makes areas of your map where a lot of tomes have been used lag a lot.
//
//
library PowerupSentinel
{
    function onInit(){
        trigger t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DROP_ITEM);
        TriggerAddCondition(t, function()->boolean {
            if (GetWidgetLife(GetManipulatedItem())==0) {
                RemoveItem(GetManipulatedItem());
            }
            return false;
        });
    }
    
}
//! endzinc