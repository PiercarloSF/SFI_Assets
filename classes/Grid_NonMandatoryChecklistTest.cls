/**
* Class to test the Non Mandatory Checklist Class
*
* @Author  Salesforce
*
*/
@isTest
private class Grid_NonMandatoryChecklistTest {
    
    
    @TestSetup
    private static void prepareData() {
        Id pricebookId = Test.getStandardPricebookId(); 
        Opportunity opp = (Opportunity) TestDataFactory.createSObject(
            'Opportunity',
            new Map<String, Object>{ 'StageName' => 'Negotiation' },
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
        
    }
     
    @isTest
    private static void updateChecklistTest() {
        Test.startTest();
        Contract contractTpUpdate = [Select Id From Contract];
        List<String> selectedItems = new List<String>{'profitLoss','signedContract','variousOffers','technicalOffer'};
        Grid_NonMandatoryChecklist.updateChecklist(contractTpUpdate.id, selectedItems);
        Test.stopTest();
    }
}