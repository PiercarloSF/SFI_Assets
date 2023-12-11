/**
 * Class to test the auto number util class 'Grid_AutoNumberUtil'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class Grid_AutoNumberUtilTest {
  @IsTest
  static void testOpportunityAutoNumberSameYear() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        3,
        false
      );
      Test.startTest();
      Grid_AutoNumberUtil.handleOpportunityAutoNumber(opportunities);
      Test.stopTest();

      System.assertEquals(
        opportunities[0].Grid_OpportunityAutoNumber__c,
        1,
        'Incorrect auto number'
      );
      System.assertEquals(
        opportunities[1].Grid_OpportunityAutoNumber__c,
        2,
        'Incorrect auto number'
      );
      System.assertEquals(
        opportunities[2].Grid_OpportunityAutoNumber__c,
        3,
        'Incorrect auto number'
      );
    }
  }

  @IsTest
  static void testOpportunityAutoNumberDifferentYear() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Opportunity opp1 = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        true
      );
      Opportunity opp2 = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        true
      );
      Integer year = System.today().year();
      DateTime dateInLastYear = DateTime.newInstance(
        year - 1,
        12,
        31,
        7,
        8,
        16
      );
      Test.setCreatedDate(opp1.Id, dateInLastYear);
      Test.setCreatedDate(opp2.Id, dateInLastYear);
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        2,
        false
      );
      Test.startTest();

      Grid_AutoNumberUtil.handleOpportunityAutoNumber(opportunities);
      Test.stopTest();

      Id lastYearOppsId1 = opp1.Id;
      System.assertEquals(
        [
          SELECT Id, Grid_OpportunityAutoNumber__c
          FROM Opportunity
          WHERE Id = :lastYearOppsId1
          LIMIT 1
        ]
        .Grid_OpportunityAutoNumber__c,
        1,
        'Incorrect auto number'
      );
      System.assertEquals(
        opportunities[0].Grid_OpportunityAutoNumber__c,
        1,
        'Incorrect auto number'
      );
      System.assertEquals(
        opportunities[1].Grid_OpportunityAutoNumber__c,
        2,
        'Incorrect auto number'
      );
    }
  }
  @IsTest
  static void testContractAutoNumberSameYear() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      List<Contract> contracts = (List<Contract>) TestDataFactory.createSObjectList(
        'Contract',
        3,
        false
      );
      Test.startTest();
      Grid_AutoNumberUtil.handleContractAutoNumber(contracts);
      Test.stopTest();
      System.assertEquals(
        contracts[0].Grid_ContractAutoNumber__c,
        1,
        'Incorrect auto number'
      );
      System.assertEquals(
        contracts[1].Grid_ContractAutoNumber__c,
        2,
        'Incorrect auto number'
      );
      System.assertEquals(
        contracts[2].Grid_ContractAutoNumber__c,
        3,
        'Incorrect auto number'
      );
    }
  }

  @IsTest
  static void testContractAutoNumberDifferentYear() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Contract contract1 = (Contract) TestDataFactory.createSObject(
        'Contract',
        true
      );
      Contract contract2 = (Contract) TestDataFactory.createSObject(
        'Contract',
        true
      );
      Integer year = System.today().year();
      DateTime dateInLastYear = DateTime.newInstance(
        year - 1,
        12,
        31,
        7,
        8,
        16
      );
      Test.setCreatedDate(contract1.Id, dateInLastYear);
      Test.setCreatedDate(contract2.Id, dateInLastYear);
      List<Contract> contracts = (List<Contract>) TestDataFactory.createSObjectList(
        'Contract',
        2,
        false
      );
      Test.startTest();
      Grid_AutoNumberUtil.handleContractAutoNumber(contracts);
      Test.stopTest();

      Id lastYearContractId = contract1.Id;
      System.assertEquals(
        [
          SELECT Id, Grid_ContractAutoNumber__c
          FROM Contract
          WHERE Id = :lastYearContractId
          LIMIT 1
        ]
        .Grid_ContractAutoNumber__c,
        1,
        'Incorrect auto number'
      );
      System.assertEquals(
        contracts[0].Grid_ContractAutoNumber__c,
        1,
        'Incorrect auto number'
      );
      System.assertEquals(
        contracts[1].Grid_ContractAutoNumber__c,
        2,
        'Incorrect auto number'
      );
    }
  }
}