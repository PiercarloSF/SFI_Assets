/**
 * Class to implement the scheduler of the contract batch
 *
 * @Author  Salesforce
 *
 */
global class Grid_ContractBatchScheduler implements Schedulable {
  private static String cronMarch = '0 0 12 10 3 ? *';
  private static String cronSeptember = '0 0 12 10 9 ? *';

  global static void schedule(String batchName) {
    Grid_ContractBatchScheduler sc = new Grid_ContractBatchScheduler();
    System.schedule(batchName + ' march', cronMarch, sc);
    System.schedule(batchName + ' september', cronSeptember, sc);
  }

  global void execute(SchedulableContext sc) {
    Grid_ContractBatch b1 = new Grid_ContractBatch();
    ID batchprocessid = Database.executeBatch(b1, 50);
  }
}