/**
 * Class to test the contract service class 'Grid_ContractServiceClass'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class Grid_ContractServiceClassTest {
  @isTest
  private static void updateContractWhenSignedTest() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Opportunity opp = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        new Map<String, Object>{ 'StageName' => 'Negotiation' },
        true
      );
      vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'testcode'
        },
        true
      );
      Quote q = (Quote) TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{
          'Status' => 'Approved',
          'OpportunityId' => opp.Id
        },
        true
      );
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{
          'Status' => 'Draft',
          'vlocity_cmt__OpportunityId__c' => opp.Id,
          'vlocity_cmt__QuoteId__c' => q.Id,
          'Contract_Signature_Date__c' => System.today(),
          'startDatee__c' => System.today(),
          'Enddatee__c' => System.today() + 5
        },
        true
      );

      Test.startTest();
      c.Status = 'Contract Signed';
      update c;
      List<Contract> contracts = new List<Contract>();
      contracts.add(c);
      Grid_ContractServiceClass.updateContract(contracts);
      Test.stopTest();
      List<Contract> myContract = [
        SELECT
          vlocity_cmt__QuoteId__r.Status,
          vlocity_cmt__OpportunityId__r.Grid_StartContractDate__c,
          vlocity_cmt__OpportunityId__r.Grid_EndContractDate__c
        FROM Contract
        WHERE Id = :c.Id
      ];
      System.assertEquals(
        'Finalized',
        myContract[0].vlocity_cmt__QuoteId__r.Status
      );
      System.assertEquals(
        System.today(),
        myContract[0].vlocity_cmt__OpportunityId__r.Grid_StartContractDate__c
      );
      System.assertEquals(
        System.today() + 5,
        myContract[0].vlocity_cmt__OpportunityId__r.Grid_EndContractDate__c
      );
    }
  }

  @isTest
  private static void updateContractWhenRejectedTest() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Opportunity opp = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        new Map<String, Object>{ 'StageName' => 'Negotiation' },
        true
      );
      vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'testcode'
        },
        true
      );
      Quote q = (Quote) TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{
          'Status' => 'Approved',
          'OpportunityId' => opp.Id
        },
        true
      );
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{
          'Status' => 'Draft',
          'vlocity_cmt__OpportunityId__c' => opp.Id,
          'vlocity_cmt__QuoteId__c' => q.Id,
          'startDatee__c' => System.today(),
          'Enddatee__c' => System.today() + 5
        },
        true
      );

      Test.startTest();
      c.Status = 'Contract Rejected';
      update c;
      List<Contract> contracts = new List<Contract>();
      contracts.add(c);
      Grid_ContractServiceClass.updateContract(contracts);
      Test.stopTest();
      List<Contract> myContract = [
        SELECT
          vlocity_cmt__QuoteId__r.Status,
          vlocity_cmt__OpportunityId__r.Grid_StartContractDate__c,
          vlocity_cmt__OpportunityId__r.Grid_EndContractDate__c
        FROM Contract
        WHERE Id = :c.Id
      ];
      System.assertEquals(
        'Rejected',
        myContract[0].vlocity_cmt__QuoteId__r.Status
      );
    }
  }

  @IsTest
  private static void nextCheckPointAuditDate() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{ 'Status' => 'Draft','Grid_Scheda231DeliveryStatus__c'=>'Open (red)' },
        true
      );
      c.Status = 'Internal Review';
      update c;
      List<Contract> contracts = new List<Contract>();
      contracts.add(c);
      Grid_ContractServiceClass.updateContract(contracts);
      Test.stopTest();

      Date todaysDate = system.today();
      if (todaysDate.month() <= 9 && todaysDate.month() > 3) {
        System.assertEquals(
          9,
          contracts[0].Grid_Scheda231NextCheckpointAuditDate__c.month(),
          'Wrong next check point audit date'
        );
        System.assertEquals(
          30,
          contracts[0].Grid_Scheda231NextCheckpointAuditDate__c.day(),
          'Wrong next check point audit date'
        );
      } else {
        System.assertEquals(
          3,
          contracts[0].Grid_Scheda231NextCheckpointAuditDate__c.month(),
          'Wrong next check point audit date'
        );
        System.assertEquals(
          31,
          contracts[0].Grid_Scheda231NextCheckpointAuditDate__c.day(),
          'Wrong next check point audit date'
        );
      }
    }
  }


  @IsTest(seeAllData=true)
  private static void setScheda231DeliveryNextCheckPointAuditDate(){
    System.runAs(TestDataFactory.createClientManagerUser()) {
      Test.startTest();
      Contract c = [SELECT Id, Status,OwnerId, Grid_Scheda231DeliveryNextCheckpoint__c, Grid_Scheda231DeliveryStatus__c FROM Contract WHERE Status = 'Activated' LIMIT 1];
      List<Contract> contracts = new List<Contract>();
      contracts.add(c);
      Grid_ContractServiceClass.updateContract(contracts);
      Test.stopTest();
      Date todaysDate = system.today();
      if (todaysDate.month() <= 9 && todaysDate.month() > 3) {
        System.assertEquals(
          9,
          contracts[0].Grid_Scheda231DeliveryNextCheckpoint__c.month(),
          'Wrong next check point audit date'
        );
        System.assertEquals(
          30,
          contracts[0].Grid_Scheda231DeliveryNextCheckpoint__c.day(),
          'Wrong next check point audit date'
        );
      } else {
        System.assertEquals(
          3,
          contracts[0].Grid_Scheda231DeliveryNextCheckpoint__c.month(),
          'Wrong next check point audit date'
        );
        System.assertEquals(
          31,
          contracts[0].Grid_Scheda231DeliveryNextCheckpoint__c.day(),
          'Wrong next check point audit date'
        );
      }
    }
  }



  @IsTest
  private static void testCreateTaskReminderWhenStatusOpen() {
    User u = TestDataFactory.createGridspertiseUser();
    System.runAs(u) {
      Test.startTest();
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{
          'Status' => 'Draft',
          'Scheda_231_status__c' => 'Open',
          'ownerId' => u.Id
        },
        true
      );
      c.Status = 'Internal Review';
      update c;
      List<Contract> contracts = new List<Contract>();
      contracts.add(c);
      Grid_ContractServiceClass.updateContract(contracts);
      Task t = [
        SELECT Id, Subject, Description, IsReminderSet
        FROM Task
        WHERE WhatId = :contracts[0].Id
        LIMIT 1
      ];
      Test.stopTest();

      System.assertEquals(
        'Remind to Upload Scheda 231',
        t.Subject,
        'Wrong task reminder were created'
      );
      System.assertEquals(
        'Remind to Upload Scheda 231',
        t.Description,
        'Wrong task reminder were created'
      );
      System.assertEquals(
        true,
        t.IsReminderSet,
        'Wrong task reminder were created'
      );
    }
  }
  @IsTest
  private static void testCreateTaskReminderWhenStatusClosed() {
    User u = TestDataFactory.createGridspertiseUser();
    System.runAs(u) {
      Test.startTest();
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{
          'Status' => 'Draft',
          'Scheda_231_status__c' => 'Closed',
          'ownerId' => u.Id
        },
        true
      );
      c.Status = 'Internal Review';
      update c;
      List<Contract> contracts = new List<Contract>();
      contracts.add(c);
      Grid_ContractServiceClass.updateContract(contracts);

      Test.stopTest();

      System.assertEquals(
        0,
        [
            SELECT Id, Subject, Description, IsReminderSet
            FROM Task
            WHERE
              WhatId = :contracts[0].Id
              AND Subject = 'Remind to Upload Scheda 231'
          ]
          .size(),
        'No task should be created'
      );
    }
  }
  @IsTest
  private static void testCreateTaskReminderContractExpired() {
    User u = TestDataFactory.createGridspertiseUser();
    System.runAs(u) {
      Test.startTest();
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{
          'Status' => 'Draft',
          'Contract_Sending_Date__c' => system.today() - 10,
          'Offer_Validity__c' => 5,
          'ownerId' => u.Id
        },
        true
      );
      List<Contract> contracts = [
        SELECT Id, Deal_Expires_on__c, ownerId
        FROM Contract
        WHERE Id = :c.Id
        LIMIT 1
      ];
      Grid_ContractServiceClass.updateInsertContract(contracts);
      List<Task> tasks = [
        SELECT Id, Subject, Description, IsReminderSet
        FROM Task
        WHERE WhatId = :contracts[0].Id
        LIMIT 1
      ];
      Test.stopTest();

      System.assertEquals(
        'Offer Expired',
        tasks[0].Subject,
        'Wrong task reminder were created'
      );
      System.assertEquals(
        'This offer has expired because is no longer valid',
        tasks[0].Description,
        'Wrong task reminder were created'
      );
      System.assertEquals(
        true,
        tasks[0].IsReminderSet,
        'Wrong task reminder were created'
      );
    }
  }
  @IsTest
  private static void testCreateTaskReminderWhenContractNotExpired() {
    User u = TestDataFactory.createGridspertiseUser();
    System.runAs(u) {
      Test.startTest();
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{
          'Status' => 'Draft',
          'Contract_Sending_Date__c' => system.today() + 10,
          'Offer_Validity__c' => 5,
          'ownerId' => u.Id
        },
        true
      );
      List<Contract> contracts = [
        SELECT Id, Deal_Expires_on__c, ownerId
        FROM Contract
        WHERE Id = :c.Id
        LIMIT 1
      ];
      Grid_ContractServiceClass.updateInsertContract(contracts);

      Test.stopTest();

      System.assertEquals(
        0,
        [
            SELECT Id, Subject, Description, IsReminderSet
            FROM Task
            WHERE WhatId = :contracts[0].Id
          ]
          .size(),
        'No task should be created'
      );
    }
  }

  @isTest
  private static void updateAccountTeamTest() {
    User u = TestDataFactory.createGridspertiseUser();
    System.runAs(u) {
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{
          'Status' => 'Draft',
          'Contract_Signature_Date__c' => System.today(),
          'startDatee__c' => System.today(),
          'Enddatee__c' => System.today() + 5,
          'ownerId' => u.Id
        },
        true
      );

      Test.startTest();
      List<Contract> contracts = new List<Contract>();
      contracts.add(c);
      Grid_ContractServiceClass.updateAccountTeam(contracts);
      Test.stopTest();
    }
  }

  @IsTest
  static void testNotifyContractTeamMembers() {
    Test.startTest();
    List<Contract> contracts = new List<Contract>();
    Contract ct = (Contract) TestDataFactory.createSObject(
      'Contract',
      new Map<String, Object>{ 'Status' => 'Draft','OwnerId'=>System.UserInfo.getUserId() },
      true
    );
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
    for (Integer i = 0; i < 2; i++) {
      // add the current date to the uniqueUsername in order to avoid the error of duplicate username(use timestamp)
      String uniqueUsername = 'test'+System.now().millisecond()+i+System.now().second()+'@eneltest.com';
      User u = (User) TestDataFactory.createSObject('User', new Map<String, Object>{ 
        'FirstName' => 'Test', 'LastName' => 'User','ProfileId'=>p.Id,'Email'=> 'test'+i+'@test.com','Username'=> uniqueUsername,
        'CommunityNickname'=> 'enel'+i+'test'
          }, true);
      Grid_ContractTeamMember__c ctm = (Grid_ContractTeamMember__c) TestDataFactory.createSObject(
        'Grid_ContractTeamMember__c',
        new Map<String, Object>{ 'Grid_Contract__c' => ct.Id,'Grid_User__c' => u.Id },
        true
      );
    }

    contracts.add(ct);
    Grid_ContractServiceClass.notifyContractTeamMembers(contracts);
    Test.stopTest();
  }


  @IsTest
  static void testNotifyNewOwner() {
    Test.startTest();
    List<Contract> contracts = new List<Contract>();
    Contract ct = (Contract) TestDataFactory.createSObject(
      'Contract',
      new Map<String, Object>{ 'Status' => 'Draft',
      'OwnerId'=>System.UserInfo.getUserId(),
      'Grid_Condition_Terms__c'=>'30 days from the date of receipt of the invoice'
      },
      true
    );
    ct.status = 'Handover';
    update ct;
    contracts.add(ct);
    Grid_ContractServiceClass.notifyNewOwner(contracts);
    Test.stopTest();
  }

  @IsTest
  static void testUpdateContractStatus() {
    List<Contract> contracts = new List<Contract>();
    Contract ct = (Contract) TestDataFactory.createSObject(
      'Contract',
      new Map<String, Object>{ 'Status' => 'Draft','OwnerId'=>System.UserInfo.getUserId()
    },
      true
    );
    vlocity_cmt__ContractLineItem__c contractLine = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
      'vlocity_cmt__ContractLineItem__c',
      new Map<String, Object>{
          'vlocity_cmt__ContractId__c' => ct.Id,
          'Grid_Actual_Quantity__c' => 120,
          'Grid_Planned_Quantity__c' => 120
      },
      true
  );
    contracts.add(ct);
    Test.startTest();
    Grid_ContractServiceClass.updateContractStatus(contracts);
    Test.stopTest();
    Contract con = [SELECT Id,Status FROM Contract WHERE Id = :ct.Id LIMIT 1];
    System.assertEquals('Closed/under warranty', ct.Status,'Wrong status');
  }

  @IsTest
  static void testCreateRevenueSchedulesHardwareVersion2(){
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        new Map<String, Object>{
           'StageName' => 'Internal Review',
           'Grid_StartContractDate__c' => System.today(),
           'Grid_EndContractDate__c' => Date.newInstance(         
             System.today().year()+3,
             System.today().month(),
             System.today().day()
             )
          },
        true
      );
      vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'testcode'
        },
        true
      );
      Id pricebookId = Test.getStandardPricebookId();
      Quote qte = (Quote) TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{
          'OpportunityId' => oppo.Id,
          'Pricebook2Id' => pricebookId
        },
        true
      );
      Product2 prod = (Product2) TestDataFactory.createSObject(
        'Product2',
        new Map<String, Object>{
          'Name' => 'Testing Product',
          'Grid_Category__c' => 'Hardware',
          'Grid_IsChild__c' => true
        },
        true
      );
      PricebookEntry priceBook = (PricebookEntry) TestDataFactory.createSObject(
        'PricebookEntry',
        new Map<String, Object>{
          'Pricebook2Id' => pricebookId,
          'Product2Id' => prod.Id,
          'Product2' => prod,
          'IsActive' => true,
          'UnitPrice' => 0
        },
        true
      );
      Contract c = (Contract) TestDataFactory.createSObject(
        'Contract',
        new Map<String, Object>{
          'Status' => 'Draft',
          'vlocity_cmt__OpportunityId__c' => oppo.Id,
          'vlocity_cmt__QuoteId__c' => qte.Id,
          'Contract_Signature_Date__c' => System.today(),
          'startDatee__c' => System.today(),
          'Enddatee__c' => System.today() + 5
        },
        true
      );
      Quotelineitem qli = (Quotelineitem) TestDataFactory.createSObject(
        'Quotelineitem',
        new Map<String, Object>{
          'QuoteId' => qte.Id,
          'Quantity' => 3,
          'Product2' => prod,
          'PricebookEntryId' => priceBook.Id
        },
        true
      );
      vlocity_cmt__ContractLineItem__c cli = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
          'vlocity_cmt__ContractLineItem__c',
          new Map<String, Object>{
              'vlocity_cmt__ContractId__c' => c.Id,
              'vlocity_cmt__Product2Id__c' => prod.id,
                  'vlocity_cmt__QuoteLineItem__c'=>qli.id,
                  'OpenMeterFormula__c' => null,
                    'vlocity_cmt__OneTimeTotal__c'=>10,
                    'Grid_RecurringTotalYearly__c'=>20,
                  'vlocity_cmt__RecurringTotal__c'=>20,
                  'CurrencyIsoCode'=>'EUR',
                  'Grid_ParentItemId__c'=>'3e8729ac-1351-6078-9683-5a623bd5cf06',
                  'vlocity_cmt__Quantity__c'=>3
          },
          true
      );
      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_Contract__c' => c.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 3,
          'Grid_ScheduleFrequency__c' => 'Yearly',
              'Grid_Version__c'=>2
              },
        true
      );
         DeliveryPlan__c deliveryPlan1 = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_Contract__c' => c.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 3,
          'Grid_ScheduleFrequency__c' => 'Monthly',
              'Grid_Version__c'=>2
              },
        true
      );
         DeliveryPlan__c deliveryPlan2 = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_Contract__c' => c.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 3,
          'Grid_ScheduleFrequency__c' => 'One Time',
              'Grid_Version__c'=>2
              },
        true
      );
      ProductSchedule__c prodSched1 = (ProductSchedule__c) TestDataFactory.createSObject(
        'ProductSchedule__c',
        new Map<String, Object>{
          'Grid_ContractLine__c' => cli.Id,
                              'Grid_QuoteLineItem__c' => qli.Id,
          'Name' => DateTime.newInstance(         
            System.today().year(),
            System.today().month(),
            System.today().day()
            ).format('YYYY'),
          'Grid_Version__c' => 2,
          'Grid_Delivery_Plan__c' => deliveryPlan1.Id,
          'Grid_SalesPric__c' => 100,
               //'Grid_PlannedAmn__c'=>130,
          'Grid_PlannedQuantity__c' => 2,
              'Grid_EndDate__c'=>System.today(),
              'Grid_EndDate__c'=>System.today()+3
        },
        true
      );
      ProductSchedule__c prodSched2 = (ProductSchedule__c) TestDataFactory.createSObject(
        'ProductSchedule__c',
        new Map<String, Object>{
          'Grid_ContractLine__c' => cli.Id,
                              'Grid_QuoteLineItem__c' => qli.Id,
          'Name' => DateTime.newInstance(         
            System.today().year()+1,
            System.today().month(),
            System.today().day()
            ).format('YYYY'),
          'Grid_Version__c' => 2,
          'Grid_Delivery_Plan__c' => deliveryPlan2.Id,
          'Grid_SalesPric__c' => 100,
               //'Grid_PlannedAmn__c'=>130,
          'Grid_PlannedQuantity__c' => 2,
                'Grid_EndDate__c'=>System.today(),
              'Grid_EndDate__c'=>System.today()+3
        },
        true
      );
      ProductSchedule__c prodSched3 = (ProductSchedule__c) TestDataFactory.createSObject(
        'ProductSchedule__c',
        new Map<String, Object>{
          'Grid_ContractLine__c' => cli.Id,
                'Grid_QuoteLineItem__c' => qli.Id,
          'Name' => DateTime.newInstance(         
            System.today().year()+2,
            System.today().month(),
            System.today().day()
            ).format('YYYY'),
          'Grid_Version__c' => 2,
          'Grid_Delivery_Plan__c' => deliveryPlan.Id,
          'Grid_SalesPric__c' => 100,
          'Grid_PlannedQuantity__c' => 2,
                'Grid_EndDate__c'=>System.today(),
              'Grid_EndDate__c'=>System.today()+3
               //'Grid_PlannedAmn__c'=>130
        },
        true
      );
      Revenue__c revenue = (Revenue__c) TestDataFactory.createSObject(
        'Revenue__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
              'Grid_Contract__c'=>c.Id,
          'Grid_Version__c' => 2
        },
        true
      );
       Grid_RevenueSchedule__c testRS = (Grid_RevenueSchedule__c) TestDataFactory.createSObject(
            'Grid_RevenueSchedule__c',
            new Map<String, Object>{ 
                'Grid_Metric__c' => 'One Time',
                'Grid_QuoteLineItem__c' => qli.Id,
                'Grid_PlannedAmount__c' => 100,
                'Grid_ActualAmount__c' => 90,
                'Grid_Revenue__c' => revenue.Id,
                'Grid_Version__c' => 1,
                'Grid_ContractLine__c' => cli.Id,
                    'Grid_Category__c'=>'Hardware'
            },
            true
        );

      DeliveryPlan__c deliveryPlanWithAllFields = [
        SELECT Id, Grid_Quote__c,Grid_Contract__c, Grid_Version__c, Grid_StartDate__c, Grid_EndDate__c, Grid_ScheduleCount__c, Grid_ScheduleFrequency__c
        FROM DeliveryPlan__c
        WHERE Id = :deliveryPlan.Id
      ];
      List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
      deliveryPlanList.add(deliveryPlanWithAllFields);

      Revenue__c revenueWithAllFields = [
        SELECT Id, Grid_Quote__c,Grid_Contract__c, Grid_Version__c, Grid_StartDate__c, Grid_EndDate__c, Grid_Count__c
        FROM Revenue__c
        WHERE Id = :revenue.Id
      ];

      List<Revenue__c> revenueList = new List<Revenue__c>();
      revenueList.add(revenueWithAllFields);
      Set<Id> contractIds = new Set<Id>();
      contractIds.add(c.Id);

      Grid_ContractServiceClass.createHWRevenueScheduleVersion2(revenueList, contractIds);
      Test.stopTest();

      List<Grid_RevenueSchedule__c> revenueSchedules = [
        SELECT Id, Grid_ContractLine__c, Name
        FROM Grid_RevenueSchedule__c
        WHERE Grid_ContractLine__c = :cli.Id
      ];
      /*System.assertEquals(
        4,
        revenueSchedules.size(),
        'No revenue schedules were created'
      );*/
    }
  }
}