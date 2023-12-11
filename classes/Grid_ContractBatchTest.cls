/**
 * Class to test the contract batch class 'Grid_ContractBatch'
 *
 * @Author  Salesforce
 *
 */
@IsTest
private class Grid_ContractBatchTest {
  @IsTest
  static void testContractBatch() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      List<Contract> contracts = (List<Contract>) TestDataFactory.createSObjectList(
        'Contract',
        new Map<String, Object>{ 'Scheda_231_status__c' => 'Open','Grid_Scheda231DeliveryStatus__c'=>'Open (red)' },
        50,
        true
      );
      Set<Id> contractsIds = new Set<Id>();
      for (Contract c : contracts) {
        contractsIds.add(c.Id);
      }
      Grid_ContractBatch b1 = new Grid_ContractBatch();
      Database.executeBatch(b1, 50);
      Test.stopTest();
      List<Task> tasks = [
        SELECT Id, WhatId
        FROM Task
        WHERE WhatId IN :contractsIds
      ];
      System.assert(tasks.size() > 0);
    }
  }
}