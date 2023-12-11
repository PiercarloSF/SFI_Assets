/**
 * Class to test the opportunity service class 'Grid_OpportunityServiceClass'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class Grid_OpportunityServiceClassTest {
  @IsTest
  static void recordTypeShouldBeTenderWhenTenderType() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      RecordType tenderRecordType = [
        SELECT Id
        FROM RecordType
        WHERE Name = 'TenderOpportunity' AND SobjectType = 'Opportunity'
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      Test.startTest();
      vlocity_cmt__PriceList__c italyPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'PL_ITALY_EUR',
          'Name' => 'B2B Pricelist Italy'
        },
        true
      );
      vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'PL_SPAIN_EUR',
          'Name' => 'B2B Pricelist Spain'
        },
        true
      );
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        new Map<String, Object>{
          'Grid_TypeOfOpportunity__c' => 'Tender',
          'Grid_OpportunityCurrency__c' => 'EUR',
          'Grid_CurrencyCountry__c' => 'Spain'
        },
        1,
        true
      );
      Grid_OpportunityServiceClass.updateOpportunity(opportunities);
      Test.stopTest();
      System.assertEquals(
        tenderRecordType.Id,
        opportunities[0].RecordTypeId,
        'Wrong record type'
      );
    }
  }

  @IsTest
  static void recordTypeShouldBeStandardWhenNoTenderType() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      RecordType standardRecordType = [
        SELECT Id
        FROM RecordType
        WHERE Name = 'StandardOpportunity' AND SobjectType = 'Opportunity'
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      Test.startTest();
      vlocity_cmt__PriceList__c italyPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'PL_ITALY_EUR',
          'Name' => 'B2B Pricelist Italy'
        },
        true
      );
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        new Map<String, Object>{ 'Grid_OpportunityCurrency__c' => 'EUR' },
        1,
        true
      );
      Grid_OpportunityServiceClass.updateOpportunity(opportunities);
      Test.stopTest();
      System.assertEquals(
        standardRecordType.Id,
        opportunities[0].RecordTypeId,
        'Wrong record type'
      );
    }
  }

  @IsTest
  static void nextCheckPointAuditDate() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        new Map<String, Object>{ 'StageName' => 'Internal Review' },
        1,
        true
      );
      Grid_OpportunityServiceClass.updateOpportunity(opportunities);

      Test.stopTest();
      Date todaysDate = system.today();
      if (todaysDate.month() <= 9 && todaysDate.month() > 3) {
        System.assertEquals(
          9,
          opportunities[0].Grid_Scheda231NextCheckpointAuditDate__c.month(),
          'Wrong next check point audit date'
        );
        System.assertEquals(
          30,
          opportunities[0].Grid_Scheda231NextCheckpointAuditDate__c.day(),
          'Wrong next check point audit date'
        );
      } else {
        System.assertEquals(
          3,
          opportunities[0].Grid_Scheda231NextCheckpointAuditDate__c.month(),
          'Wrong next check point audit date'
        );
        System.assertEquals(
          31,
          opportunities[0].Grid_Scheda231NextCheckpointAuditDate__c.day(),
          'Wrong next check point audit date'
        );
      }
    }
  }

  @IsTest
  static void testCountryIsoCode() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Account acc = (Account) TestDataFactory.createSObject(
        'Account',
        new Map<String, Object>{
          'Grid_MacroGeography__c' => 'EU',
          'Grid_Geography__c' => 'Italy'
        },
        true
      );
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        new Map<String, Object>{ 'AccountId' => acc.Id },
        1,
        true
      );
      Grid_OpportunityServiceClass.updateOpportunity(opportunities);
      Test.stopTest();

      System.assertEquals(
        'ITA',
        [
          SELECT Id, Country_Iso_Code__c
          FROM Opportunity
          WHERE Id = :opportunities[0].Id
          LIMIT 1
        ]
        .Country_Iso_Code__c,
        'Wrong country iso code'
      );
    }
  }
  @IsTest
  static void testCreateTaskReminderWhenStatusOpen() {
    User u = TestDataFactory.createGridspertiseUser();
    System.runAs(u) {
      Test.startTest();
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        new Map<String, Object>{
          'StageName' => 'Internal Review',
          'Grid_Scheda231Status__c' => 'Open',
          'ownerId' => u.Id
        },
        1,
        true
      );
      Grid_OpportunityServiceClass.updateOpportunity(opportunities);

      Test.stopTest();
      Task t = [
        SELECT Id, Subject, Description, IsReminderSet
        FROM Task
        WHERE WhatId = :opportunities[0].Id
        LIMIT 1
      ];
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
  static void testCreateTaskReminderWhenStatusClosed() {
    User u = TestDataFactory.createGridspertiseUser();
    System.runAs(u) {
      Test.startTest();
      List<Opportunity> opportunities = (List<Opportunity>) TestDataFactory.createSObjectList(
        'Opportunity',
        new Map<String, Object>{
          'StageName' => 'Internal Review',
          'Grid_Scheda231Status__c' => 'Closed',
          'ownerId' => u.Id
        },
        1,
        true
      );
      Grid_OpportunityServiceClass.updateOpportunity(opportunities);

      Test.stopTest();

      System.assertEquals(
        0,
        [
            SELECT Id, Subject, Description, IsReminderSet
            FROM Task
            WHERE WhatId = :opportunities[0].Id
          ]
          .size(),
        'No task should be created'
      );
    }
  }
}