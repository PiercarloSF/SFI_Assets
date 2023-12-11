/**
 * Class to implement the scheduler of the opportunity batch
 *
 * @Author  Salesforce
 *
 */
global class Grid_OpportunityBatchScheduler implements Schedulable {
  private static String cronMarch = '0 0 12 10 3 ? *';
  private static String cronSeptember = '0 0 12 10 9 ? *';
  global static void schedule(String batchName) {
    Grid_OpportunityBatchScheduler sc = new Grid_OpportunityBatchScheduler();
    System.schedule(batchName + ' march', cronMarch, sc);
    System.schedule(batchName + ' september', cronSeptember, sc);
  }

  global void execute(SchedulableContext sc) {
    Grid_OpportunityBatch b1 = new Grid_OpportunityBatch();
    ID batchprocessid = Database.executeBatch(b1, 50);
  }
}