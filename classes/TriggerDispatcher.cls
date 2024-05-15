
public class TriggerDispatcher {
/**
* @Description    Call this method from your trigger, passing in an instance of a trigger handler which implements ITriggerHandler.
* @Params         handler 
* @Return         void
**/
public static void run(ITrigger handler, string triggerName){
         
    //Check if the trigger is disabled
    if (handler.IsDisabled()){
        return;
    }
     
    //Get the trigger active information from custom settings by trigger name
  Boolean isActive = Trigger_Setting__mdt.getInstance(triggerName).Is_Active__c;
        // Detect the current trigger context and fire the relevant methods on the trigger handler:
        //Before trigger logic
    if(isActive){
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                handler.beforeInsert(trigger.new);
            }
            if (Trigger.isUpdate){
                handler.beforeUpdate(trigger.newMap, trigger.oldMap);
            } 
            if (Trigger.isDelete){
                handler.beforeDelete(trigger.oldMap);
            } 
        }
        //After trigger logic
        if (Trigger.isAfter) {
            if (Trigger.isInsert){
               handler.afterInsert(Trigger.newMap); 
            } 
            if (Trigger.isUpdate){
                handler.afterUpdate(trigger.newMap, trigger.oldMap);
            }
            if (trigger.isDelete){
                handler.afterDelete(trigger.oldMap);
            }
            if (trigger.isUndelete){
               handler.afterUndelete(trigger.oldMap); 
            } 
        }
     }
    }
}