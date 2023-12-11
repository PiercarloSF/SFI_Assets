/**
 * Class to implement the opportunity service
 *
 * @Author  Salesforce
 *
 */
public with sharing class Grid_OpportunityServiceClass {

    private static RecordType standardRecordType;
    private static RecordType tenderRecordType;
  
    /**
     * @description auto populate opportunity data 
     * @param opportunity 
     * @return void
    **/
    public static void updateOpportunity(List<Opportunity> opps) {
  
      List<vlocity_cmt__PriceList__c> prices = new List<vlocity_cmt__PriceList__c>();
      Map<String, Id> priceBooks = Grid_ServiceClass.getPriceBook();
      Map<String, List<vlocity_cmt__PriceList__c>> priceLists = Grid_ServiceClass.getPriceList();
      standardRecordType = Grid_ServiceClass.getRecordType(
        'Opportunity',
        'StandardOpportunity'
      );
      tenderRecordType = Grid_ServiceClass.getRecordType(
        'Opportunity',
        'TenderOpportunity'
      );
      for (Opportunity opp : opps) {
        opp.CurrencyIsoCode = opp.Grid_OpportunityCurrency__c;
        if (opp.CurrencyIsoCode != null) {
          List<vlocity_cmt__PriceList__c> priceListsByCurrency = new List<vlocity_cmt__PriceList__c>();
          if(priceLists.get( opp.CurrencyIsoCode) != null){
            priceListsByCurrency = priceLists.get(opp.CurrencyIsoCode);
          }
          if (priceListsByCurrency.size() == 1) {
            opp.vlocity_cmt__PriceListId__c = priceListsByCurrency.get(0).Id;
          } else if (priceListsByCurrency.size() > 1) {
            for (vlocity_cmt__PriceList__c pr : priceListsByCurrency) {
              if (
                pr.Name != null && pr.Name.contains(opp.Grid_CurrencyCountry__c)
              ) {
                opp.vlocity_cmt__PriceListId__c = pr.Id;
              }
            }
          }
          opp.Pricebook2Id = priceBooks.get('Price Book ' + opp.CurrencyIsoCode);
        }
        setOpportunityRecordType(opp);
        setNextCheckPointAuditDate(opp);
        setCountryIsoCode(opp);
      }
    }
  
    /**
     * @description gets the opp record type ID
     * @param opportunity 
     * @return void
    **/
    private static void setOpportunityRecordType(Opportunity opp) {
      if (opp.Grid_TypeOfOpportunity__c == 'Tender') {
        opp.RecordTypeId = tenderRecordType.Id;
      } else {
        opp.RecordTypeId = standardRecordType.Id;
      }
    }
  
    /**
     * @description calculates the next check point audit date
     * @param opportunity 
     * @return void
    **/
    private static void setNextCheckPointAuditDate(Opportunity opp) {
      if (opp.StageName == 'Internal Review') {
        Date todaysDate = system.today();
        Date marchDate = Date.newInstance(todaysDate.year(), 3, 31);
        Date septembreDate = Date.newInstance(todaysDate.year(), 9, 30);
        Date deadLineDate;
        if (todaysDate <= marchDate) {
          opp.Grid_Scheda231NextCheckpointAuditDate__c = marchDate;
          deadLineDate = marchDate;
        } else if (todaysDate > marchDate && todaysDate <= septembreDate) {
          opp.Grid_Scheda231NextCheckpointAuditDate__c = septembreDate;
          deadLineDate = septembreDate;
        } else if (todaysDate > septembreDate) {
          opp.Grid_Scheda231NextCheckpointAuditDate__c = marchDate.addYears(1);
          deadLineDate = marchDate.addYears(1);
        }
        if (opp.Grid_Scheda231Status__c == 'Open') {
          DateTime reminder25Before = DateTime.newInstance(
            deadLineDate.year(),
            deadLineDate.month(),
            deadLineDate.day() - 25
          );
          Map<String, Object> inputs = new Map<String, Object>();
          inputs.put('subject', Label.Grid_OpportunitySchedaReminderSubject);
          inputs.put('body', Label.Grid_OpportunitySchedaReminderBody);
          inputs.put('isReminder', true);
          inputs.put('dueDate', deadLineDate);
          inputs.put('opportunity', opp);
          if (system.today().daysBetween(deadLineDate) <= 10) {
            inputs.put('reminderDate', system.now());
          } else {
            inputs.put('reminderDate', reminder25Before);
          }
          Flow.Interview.Create_Reminder_Task myFlow = new Flow.Interview.Create_Reminder_Task(
            inputs
          );
          myFlow.start(); //PD
        }
      }
    }
  
    /**
     * @description stores the currency code in the opportunity 
     * @param opportunity 
     * @return void
    **/
    private static void setCountryIsoCode(Opportunity opp) {
      Map<String, Country_Code__mdt> countryCustomMetaData = Country_Code__mdt.getAll();
      Country_Code__mdt oppCountry = countryCustomMetaData.get(
        opp.Grid_Country__c
      );
      if (oppCountry != null) {
        opp.Country_Iso_Code__c = oppCountry.iso_Code__c;
      }
    }
        public static void setOpportunityRenewal(List<Opportunity> opportunities) {
          for (Opportunity opp : opportunities) {
              if (opp.vlocity_cmt__FrameContractId__c != null) {
                opp.Grid_OpportunityBusiness__c = true;                              
              } 
          }
          
      }
  
  }