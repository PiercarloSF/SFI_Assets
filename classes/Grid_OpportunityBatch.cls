/**
 * Class to implement the opportunity batch to create a reminder
 * when the opportunity scheda 231 status is open
 *
 * @Author  Salesforce
 *
 */
global class Grid_OpportunityBatch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, Grid_Scheda231Status__c, Owner.Id
        FROM Opportunity
        WHERE Grid_Scheda231Status__c = 'Open'
      ]
    );
  }
  global void execute(
    Database.BatchableContext bc,
    List<Opportunity> opportunities
  ) {
    for (Opportunity opp : opportunities) {
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
      inputs.put('subject', Label.Grid_OpportunitySchedaReminderSubject);
      inputs.put('body', Label.Grid_OpportunitySchedaReminderBody);
      inputs.put('isReminder', true);
      inputs.put('dueDate', deadLineDate);
      inputs.put('opportunity', opp);
      inputs.put('reminderDate', system.now());
      Flow.Interview.Create_Reminder_Task myFlow = new Flow.Interview.Create_Reminder_Task(
        inputs
      );
      myFlow.start();
    }
  }
  global void finish(Database.BatchableContext bc) {
  }
}