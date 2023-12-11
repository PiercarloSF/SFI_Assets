/**
 * Class to test the opportunity batch class 'Grid_OpportunityBatch'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class Grid_OpportunityBatchTest {
  @IsTest
  static void testOpportunityBatch() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        new Map<String, Object>{ 'Grid_Scheda231Status__c' => 'Open' },
        50,
        true
      );
      Set<Id> opportunitiesIds = new Set<Id>();
      for (Opportunity opp : opportunities) {
        opportunitiesIds.add(opp.Id);
      }
      Grid_OpportunityBatch b1 = new Grid_OpportunityBatch();
      Database.executeBatch(b1, 50);
      Test.stopTest();
      List<Task> tasks = [
        SELECT Id, WhatId
        FROM Task
        WHERE WhatId IN :opportunitiesIds
      ];
      System.assert(tasks.size() > 0);
    }
  }
}