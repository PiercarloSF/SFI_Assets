/**
 * Class to test the opportunity batch scheduler class 'Grid_OpportunityBatchScheduler'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class Grid_OpportunityBatchSchedulerTest {
  @IsTest
  static void oppBatchMarchScheduleTest() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Grid_OpportunityBatchScheduler oppBSched = new Grid_OpportunityBatchScheduler();
      String schedule = '0 0 12 10 3 ? *';
      System.schedule('Opportunity batch march test', schedule, oppBSched);
      Test.stopTest();
    }
  }
  @isTest
  static void oppBatchSeptemberScheduleTest() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Grid_OpportunityBatchScheduler oppBSched = new Grid_OpportunityBatchScheduler();
      String schedule = '0 0 12 10 9 ? *';
      System.schedule('Opportunity batch september test', schedule, oppBSched);
      Test.stopTest();
    }
  }
  @isTest
  static void oppBatchScheduleTest() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Grid_OpportunityBatchScheduler.schedule('test');
      Test.stopTest();
    }
  }
}