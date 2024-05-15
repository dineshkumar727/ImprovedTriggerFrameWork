public class CaseTriggerHandler extends TriggerHandler {

  private List<Case> newRecords;
  private List<Case> oldRecords;
  private Map<Id, Case> newRecordsMap;
  private Map<Id, Case> oldRecordsMap;

    public CaseTriggerHandler() {
      super('CaseTriggerHandler');
      this.setMaxLoopCount(2);
      TriggerHandler.showLimits(true);
      TriggerHandler.showDebug(true);
      this.newRecords = Trigger.new;
      this.oldRecords = Trigger.old;
      this.newRecordsMap = (Map<Id, Case>) Trigger.newMap;
      this.oldRecordsMap = (Map<Id, Case>) Trigger.oldMap;
    }

    
    public override void afterUpdate() {
      System.debug('After update');
      List<Case> cases = [SELECT Id,Status FROM Case WHERE Id IN : this.newRecordsMap.keySet()];
      System.debug('status :'+ cases[0].Status);
        if(cases[0].Status == 'New'){
          cases[0].Status = 'Working';
          update cases; // this will throw after this update
        }
     
    }
  
  }