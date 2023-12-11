/**
 * Class to handler Opportunity and Contract Auto Number
 *
 * @Author  Salesforce
 *
 */
public without sharing class Grid_AutoNumberUtil {
  /**
   * @description handle opportunity auto number
   * @param List Opportunity opps
   * @return void
   **/
  public static void handleOpportunityAutoNumber(List<Opportunity> opps) {
    Integer year = System.today().year();
    Integer counter = 1;
    List<Opportunity> latestOpp = [
      SELECT id, CreatedDate, Grid_OpportunityAutoNumber__c
      FROM Opportunity
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    if (
      latestOpp.size() > 0 &&
      latestOpp[0] != null &&
      latestOpp[0].Grid_OpportunityAutoNumber__c != null &&
      latestOpp[0].CreatedDate.year() == year
    ) {
      counter = (Integer) latestOpp[0].Grid_OpportunityAutoNumber__c + 1;
    }
    for (Opportunity opp : opps) {
      opp.Grid_OpportunityAutoNumber__c = counter;
      counter = counter + 1;
    }
  }
  /**
   * @description handle contract auto number
   * @param List Contract contracts
   * @return void
   **/
  public static void handleContractAutoNumber(List<Contract> contracts) {
    Integer year = System.today().year();
    Integer counter = 1;
    List<Contract> latestContract = [
      SELECT id, CreatedDate, Grid_ContractAutoNumber__c
      FROM Contract
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    if (
      latestContract.size() > 0 &&
      latestContract[0] != null &&
      latestContract[0].Grid_ContractAutoNumber__c != null &&
      latestContract[0].CreatedDate.year() == year
    ) {
      counter = (Integer) latestContract[0].Grid_ContractAutoNumber__c + 1;
    }

    for (Contract c : contracts) {
      c.Grid_ContractAutoNumber__c = counter;
      counter = counter + 1;
    }
  }
}