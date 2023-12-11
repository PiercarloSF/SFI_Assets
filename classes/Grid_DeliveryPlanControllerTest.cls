@isTest
public class Grid_DeliveryPlanControllerTest {
    @IsTest
    static void getDeliveryPlans() {
        System.runAs(TestDataFactory.createGridspertiseUser()) {
            Test.startTest();
            List<Deliveryplan__c> dlpList = new List<Deliveryplan__c>();
            Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
                'Opportunity',
                new Map<String, Object>{ 'StageName' => 'Internal Review' },
                true
            );
            vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
                'vlocity_cmt__PriceList__c',
                new Map<String, Object>{
                    'CurrencyIsoCode' => 'EUR',
                        'vlocity_cmt__Code__c' => 'PL_ITALY_EUR'
                        },
                true
            );
            Id pricebookId = Test.getStandardPricebookId();
            Product2 p2 =  (Product2) TestDataFactory.createSObject(
                'Product2',
                new Map<String, Object>{ 'name' => 'y','Grid_Category__c' => 'Hardware' },
                true
            );
            Quote qte = (Quote) TestDataFactory.createSObject(
                'Quote',
                new Map<String, Object>{
                    'OpportunityId' => oppo.Id,
                        'Pricebook2Id' => pricebookId
                        },
                true
            );
            List<Quotelineitem> qlis = TestDataFactory.createQuoteLineItem(qte, 2);
            Contract c = (Contract) TestDataFactory.createSObject(
                'Contract',
                new Map<String, Object>{
                    'Status' => 'Draft',
                        'vlocity_cmt__OpportunityId__c' => oppo.Id,
                        'vlocity_cmt__QuoteId__c' => qte.Id,
                        'Contract_Signature_Date__c' => System.today(),
                        'startDatee__c' => System.today(),
                        'Enddatee__c' => System.today() + 6
                        },
                true
            );
            List<vlocity_cmt__ContractLineItem__c> clilist = new list <vlocity_cmt__ContractLineItem__c>();
             Map<String, Object> fieldsToUpdate= new Map<String, Object>{
                        //'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 3,
                        'Grid_ScheduleFrequency__c' => 'Monthly',
                        'Grid_EndDate__c'=>System.today()+3,
                        'Grid_Version__c'=>1,
                        'Grid_Start_Month__c'=>'May'
                        };
            DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                        'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 3,
                        'Grid_ScheduleFrequency__c' => 'Monthly',
                        'Grid_EndDate__c'=>System.today()+3,
                        'Grid_Version__c'=>1,
                        'Grid_Start_Month__c'=>'May'
                        },
                false
            );
            insert deliveryPlan;
           
            List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
            deliveryPlanList.add(deliveryPlan);
            system.debug('list deliveryPlanList test class : '+deliveryPlanList);
            system.debug('list contractId test class : '+c.Id);

            Grid_DeliveryPlanController.getDeliveryPlans(deliveryPlan.Grid_Contract__c,1);
            Grid_DeliveryPlanController.updateDeliveryPlan(deliveryPlan.Id,fieldsToUpdate); 
            Test.stopTest();
        }
    }

}