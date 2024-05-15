public class AccountTriggerHandler implements ITrigger{
    
    static Boolean TriggerDisabled = false;
    static Boolean onlyOnce = false;

/**
* @description   Method to fetch from the custom setting, if the trigger is disabled.
* @param  None
* @return   Boolean
**/
    public Boolean isDisabled(){
        if(TriggerSetting__c.getInstance().IsActive__c == false){
            return true; 
        }
        else{
            return TriggerDisabled;
        }
    }
    /**
* @description   Method to perform the before insert operations
* @param  List of new Account
* @return   void
**/
    public Static void beforeInsert(List < SObject > newItemsList)
    {

    }
    
    
    
    
    /**
* @description   Method to perform the before update operations
* @param  Map of new Account
* @param  Map of old Account
* @return   void
**/
    public static void beforeUpdate(Map <Id,SObject> newItemsMap, Map <Id,SObject> oldItemsMap)
    {
    }
    
    /**
* @description   Method to perform the before delete operations
* @param  Map of old Account updateAccountNumberAfterInsert
* @return   void
**/
    public static void beforeDelete(Map < Id, SObject > oldItems) {
        
    } 
    /**
* @description   Method to perform the after insert operations
* @param  Map of new Account 
* @return   void
**/
    public static void afterInsert(Map < Id, SObject > newItemsMap)
    {

    }
    /**
* @description   Method to perform the after update operations
* @param  Map of new Account and old Account 
* @return   void
**/
    public static void afterUpdate(Map < Id, SObject > newItemsMap, Map < Id, SObject > oldItemsMap) {
        Map <Id, Account> oldAccountMap = (Map<Id,Account>)oldItemsMap;
        
    } 
    /**
* @description   Method to perform the after delete operations
* @param  Map of old Account 
* @return   void
**/
    public static void afterDelete(Map < Id, SObject > oldItems) {
        
    }
    /**
* @description   Method to perform the after undelete operations
* @param  Map of old Account 
* @return   void
**/ 
    public static void afterUndelete(Map < Id, SObject > oldItems) {
        
    } 
}