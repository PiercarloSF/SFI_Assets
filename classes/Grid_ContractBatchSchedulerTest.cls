/**
 * Class to test the contract batch scheduler class 'Grid_ContractBatchScheduler'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class Grid_ContractBatchSchedulerTest {
  @IsTest
  static void contractBatchMarchScheduleTest() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Grid_ContractBatchScheduler oppBSched = new Grid_ContractBatchScheduler();
      String schedule = '0 0 12 10 3 ? *';
      System.schedule('Contract batch march test', schedule, oppBSched);
      Test.stopTest();
    }
  }
  @isTest
  static void contractBatchSeptemberScheduleTest() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Grid_ContractBatchScheduler oppBSched = new Grid_ContractBatchScheduler();
      String schedule = '0 0 12 10 9 ? *';
      System.schedule('Contract batch september test', schedule, oppBSched);
      Test.stopTest();
    }
  }
  @isTest
  static void contractBatchScheduleTest() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Grid_ContractBatchScheduler.schedule('test');
      Test.stopTest();
    }
  }
}