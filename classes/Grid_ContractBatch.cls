/**
 * Class to implement the Contract Batch to create a task reminder if the scheda 231 status is Open
 *
 * @Author  Salesforce
 *
 */
global class Grid_ContractBatch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, Scheda_231_status__c,Grid_Scheda231DeliveryStatus__c, Owner.Id,Grid_Scheda231NextCheckpointAuditDate__c,Grid_Scheda231DeliveryNextCheckpoint__c
        FROM Contract
        WHERE Scheda_231_status__c = 'Open' OR Grid_Scheda231DeliveryStatus__c = 'Open (red)'
      ]
    ); 
  }
  global void execute(Database.BatchableContext bc, List<Contract> contracts) {
    List<Contract> contractsToUpdate = new List<Contract>();
    for (Contract c : contracts) {
      Map<String, Object> inputs = new Map<String, Object>();
      Date todaysDate = system.today();
      Date marchDate = Date.newInstance(todaysDate.year(), 3, 31);
      Date septembreDate = Date.newInstance(todaysDate.year(), 9, 30);
      Date deadLineDate;
      if (todaysDate < marchDate) {
        deadLineDate = marchDate;
      } else if (todaysDate > marchDate && todaysDate < septembreDate) {
        deadLineDate = septembreDate;
      } else if (todaysDate > septembreDate) {
        deadLineDate = marchDate.addYears(1);
      }
      if(c.Scheda_231_status__c=='Open'){
        c.Grid_Scheda231NextCheckpointAuditDate__c = deadLineDate;
        inputs.put('subject', Label.Grid_ContractSchedaReminderSubject);
        inputs.put('body', Label.Grid_ContractSchedaReminderBody);
        inputs.put('isReminder', true);
        inputs.put('dueDate', deadLineDate);
        inputs.put('contract', c);
        inputs.put('reminderDate', system.now());
        Flow.Interview.Create_Reminder_Task myFlow = new Flow.Interview.Create_Reminder_Task(
          inputs
        );
        myFlow.start();
      } 
      if(c.Grid_Scheda231DeliveryStatus__c=='Open (red)'){
        c.Grid_Scheda231DeliveryNextCheckpoint__c = deadLineDate;
        inputs.put('subject', Label.Grid_ContractSchedaDeliveryReminderSubject);
        inputs.put('body', Label.Grid_ContractSchedaDeliveryReminderBody);
        inputs.put('isReminder', true);
        inputs.put('dueDate', deadLineDate);
        inputs.put('contract', c);
        inputs.put('reminderDate', system.now());
        Flow.Interview.Create_Reminder_Task myFlow = new Flow.Interview.Create_Reminder_Task(
          inputs
        );
        myFlow.start();
      }
      contractsToUpdate.add(c);
    }
    if(!contractsToUpdate.isEmpty()){
      Database.update(contractsToUpdate);
    }
  }
  global void finish(Database.BatchableContext bc) {
    System.debug('Batch done!');
  }
}