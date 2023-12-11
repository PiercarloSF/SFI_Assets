@isTest
public class Grid_WithoutSharingServiceClassTest {
/*@IsTest
static void updateAccountTeamTest() {
System.runAs(TestDataFactory.createGridspertiseUser()) {
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
Account acc = (Account) TestDataFactory.createSObject(
'Account',
new Map<String, Object>{
'Name' => 'TestAccount',
'CurrencyIsoCode'=> 'EUR'
},
true
);
Profile p = [SELECT Id FROM Profile WHERE Name = 'Gridspertise User'];
String uniqueUsername = 'test'+System.now().millisecond()+System.now().second()+'@eneltest.com';
    User au = (User) TestDataFactory.createSObject('User', new Map<String, Object>{
        'FirstName' => 'Test', 'LastName' => 'User','ProfileId'=>p.Id,'Email'=> 'test'+'@test.com','Username'=> uniqueUsername,
        'CommunityNickname'=> 'enel'+'test'
          }, true);
Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
'Opportunity',
new Map<String, Object>{
'StageName' => 'Internal Review',
'Grid_OpportunityCurrency__c' => 'EUR',
'Grid_CurrencyCountry__c' => 'Spain',
'Grid_StartContractDate__c ' => System.Today(),
'Grid_EndContractDate__c ' => System.Today()+ 7
},
true
);

Quote qte = (Quote) TestDataFactory.createSObject(
'Quote',
new Map<String, Object>{ 'OpportunityId' => oppo.Id },
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
'Enddatee__c' => System.today() + 5,
'ownerId'=> au.Id,
'AccountId'=>acc.Id
},
true
);

List<Contract> quotes = new List<Contract>{ c };
AccountTeamMember newATM = new AccountTeamMember();
newATM.accountId = c.accountId;
newATM.userId = c.ownerId;
newATM.accountAccessLevel = 'None';
newATM.caseAccessLevel = 'None';
newATM.opportunityAccessLevel = 'None';
insert newATM;


newATM.accountAccessLevel = 'Edit';
Grid_WithoutSharingServiceClass.updateAccountTeam(quotes);
Test.stopTest();
System.assertEquals(
'Negotiation',
[
SELECT Id, Opportunity.StageName
FROM Quote
WHERE Id = :quotes[0].Id
LIMIT 1
]
.Opportunity.StageName,
'Wrong Opportunity Stage Name'
);
}
}*/
    
    @IsTest
    static void testCreateProductSchedules() {
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
                        'Enddatee__c' => System.today() + 5
                        },
                true
            );
            List<vlocity_cmt__ContractLineItem__c> clilist = new list <vlocity_cmt__ContractLineItem__c>();
            vlocity_cmt__ContractLineItem__c contractLine = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
                'vlocity_cmt__ContractLineItem__c',
                new Map<String, Object>{
                    'vlocity_cmt__ContractId__c' => c.Id,
                        'vlocity_cmt__Product2Id__c'=>p2.Id,
                        'OpenMeterFormula__c' => null,
                        'vlocity_cmt__Quantity__c'=>20,
                        'vlocity_cmt__Product2Id__r.Name'=>'AB',
                        'vlocity_cmt__OneTimeCharge__c'=>10,
                        'vlocity_cmt__OneTimeTotal__c'=>20,
                        'vlocity_cmt__Product2Id__r.Grid_Category__c'=> 'Hardware',
                        'vlocity_cmt__QuoteLineItem__c'=>qlis[0].Id
                        },
                true
            );
            clilist.add(contractLine);
            DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 3,
                        'Grid_ScheduleFrequency__c' => 'Monthly'
                        },
                false
            );
            DeliveryPlan__c deliveryPlan1 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 1,
                        'Grid_ScheduleFrequency__c' => 'One time'
                        },
                false
            );
            DeliveryPlan__c deliveryPlan2 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 3,
                        'Grid_ScheduleFrequency__c' => 'Yearly'
                        },
                false
            );
            DeliveryPlan__c deliveryPlan3 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 2,
                        'Grid_ScheduleFrequency__c' => 'Weekly'
                        },
                false
            );
            
            List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
            deliveryPlanList.add(deliveryPlan);
            deliveryPlanList.add(deliveryPlan1);
            deliveryPlanList.add(deliveryPlan2);
            deliveryPlanList.add(deliveryPlan3);
            Set<Id> QuoteIds = new Set<Id>();
            QuoteIds.add(c.Id);
            List<vlocity_cmt__ContractLineItem__c> contractLineItems = [
                SELECT Id,vlocity_cmt__ContractId__c, vlocity_cmt__Quantity__c, vlocity_cmt__QuoteLineItem__r.Product2.Name,vlocity_cmt__QuoteLineItem__r.Product2.Grid_Category__c, vlocity_cmt__OneTimeCharge__c
                FROM vlocity_cmt__ContractLineItem__c 
                WHERE vlocity_cmt__ContractId__c IN :QuoteIds AND vlocity_cmt__QuoteLineItem__r.Product2.Grid_Category__c = 'Hardware'
            ];
            system.debug('list contractline test class : '+contractLineItems);
            Grid_WithoutSharingServiceClass.createProductSchedule(deliveryPlanList, QuoteIds);
            Test.stopTest();
            /*List<ProductSchedule__c> productSchedules = [
SELECT Id, Grid_QuoteLineItem__c, Name
FROM ProductSchedule__c
WHERE Grid_QuoteLineItem__c = :clilist[0].Id];

System.assertEquals(
0,
productSchedules.size(),
'No product schedules were created'
);
System.assertEquals(
DateTime.newInstance(
System.today().year(),
System.today().month(),
System.today().day()
)
.format('MMM') + -+System.today().year(),
productSchedules[0].Name,
'Wrong product schedule name'
);*/
        }
    }
    
    @IsTest
    static void testDeleteProductSchedules() {
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
                        'Enddatee__c' => System.today() + 5
                        },
                true
            );
            List<vlocity_cmt__ContractLineItem__c> clilist = new list <vlocity_cmt__ContractLineItem__c>();
            vlocity_cmt__ContractLineItem__c contractLine = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
                'vlocity_cmt__ContractLineItem__c',
                new Map<String, Object>{
                    'vlocity_cmt__ContractId__c' => c.Id,
                        'vlocity_cmt__Product2Id__c'=>p2.Id,
                        'OpenMeterFormula__c' => null,
                        'vlocity_cmt__Quantity__c'=>20,
                        'vlocity_cmt__Product2Id__r.Name'=>'AB',
                        'vlocity_cmt__OneTimeCharge__c'=>10,
                        'vlocity_cmt__OneTimeTotal__c'=>20,
                        'vlocity_cmt__Product2Id__r.Grid_Category__c'=> 'Hardware',
                        'vlocity_cmt__QuoteLineItem__c'=>qlis[0].Id
                        },
                true
            );
            clilist.add(contractLine);
            DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 3,
                        'Grid_ScheduleFrequency__c' => 'Monthly'
                        },
                false
            );
            DeliveryPlan__c deliveryPlan1 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 1,
                        'Grid_ScheduleFrequency__c' => 'One time'
                        },
                false
            );
            DeliveryPlan__c deliveryPlan2 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 3,
                        'Grid_ScheduleFrequency__c' => 'Yearly'
                        },
                false
            );
            DeliveryPlan__c deliveryPlan3 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 2,
                        'Grid_ScheduleFrequency__c' => 'Weekly'
                        },
                false
            );
            
            List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
            deliveryPlanList.add(deliveryPlan);
            deliveryPlanList.add(deliveryPlan1);
            deliveryPlanList.add(deliveryPlan2);
            deliveryPlanList.add(deliveryPlan3);
            Set<Id> QuoteIds = new Set<Id>();
            QuoteIds.add(c.Id);
            Grid_WithoutSharingServiceClass.createProductSchedule(deliveryPlanList, QuoteIds);
            Grid_WithoutSharingServiceClass.deleteProductSchedule(deliveryPlanList);
            Test.stopTest();
            
            List<ProductSchedule__c> productSchedules = [
                SELECT Id, Grid_QuoteLineItem__c, Name
                FROM ProductSchedule__c
                WHERE Grid_ContractLine__c = :clilist[0].Id
            ];
            System.assertEquals(
                0,
                productSchedules.size(),
                'Product schedules were not deleted'
            );
        }
    }
    
    @IsTest
    static void testCloneDeliveryPlan() {
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
                        'Enddatee__c' => System.today() + 5
                        },
                true
            );
            List<vlocity_cmt__ContractLineItem__c> clilist = new list <vlocity_cmt__ContractLineItem__c>();
            vlocity_cmt__ContractLineItem__c contractLine = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
                'vlocity_cmt__ContractLineItem__c',
                new Map<String, Object>{
                    'vlocity_cmt__ContractId__c' => c.Id,
                        'vlocity_cmt__Product2Id__c'=>p2.Id,
                        'OpenMeterFormula__c' => null,
                        'vlocity_cmt__Quantity__c'=>20,
                        'vlocity_cmt__Product2Id__r.Name'=>'AB',
                        'vlocity_cmt__OneTimeCharge__c'=>10,
                        'vlocity_cmt__OneTimeTotal__c'=>20,
                        'vlocity_cmt__Product2Id__r.Grid_Category__c'=> 'Hardware',
                        'vlocity_cmt__QuoteLineItem__c'=>qlis[0].Id
                        },
                true
            );
            clilist.add(contractLine);
            DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 3,
                        'Grid_ScheduleFrequency__c' => 'Monthly',
                        'Grid_ActivatedDate__c'=>System.today()+1,
                        'CurrencyIsoCode'=>'EUR',
                        'Grid_EndDate__c'=>System.today()+3,
                        'Grid_Version__c'=>1
                        },
                false
            );
            DeliveryPlan__c deliveryPlan1 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 1,
                        'Grid_ScheduleFrequency__c' => 'One time',
                         'Grid_ActivatedDate__c'=>System.today()+1,
                        'CurrencyIsoCode'=>'EUR',
                        'Grid_EndDate__c'=>System.today()+3,
                        'Grid_Version__c'=>1
                        },
                false
            );
            DeliveryPlan__c deliveryPlan2 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 3,
                        'Grid_ScheduleFrequency__c' => 'Yearly',
                         'Grid_ActivatedDate__c'=>System.today()+1,
                        'CurrencyIsoCode'=>'EUR',
                        'Grid_EndDate__c'=>System.today()+3,
                        'Grid_Version__c'=>1
                        },
                false
            );
            DeliveryPlan__c deliveryPlan3 = (DeliveryPlan__c) TestDataFactory.createSObject(
                'DeliveryPlan__c',
                new Map<String, Object>{
                    'Grid_Quote__c' => qte.Id,
                        'Grid_Contract__c' =>c.Id,
                        'Grid_StartDate__c' => System.today(),
                        'Grid_ScheduleCount__c' => 2,
                        'Grid_ScheduleFrequency__c' => 'Weekly',
                         'Grid_ActivatedDate__c'=>System.today()+1,
                        'CurrencyIsoCode'=>'EUR',
                        'Grid_EndDate__c'=>System.today()+3,
                        'Grid_Version__c'=>1
                        },
                false
            );
            
            List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
            deliveryPlanList.add(deliveryPlan);
            deliveryPlanList.add(deliveryPlan1);
            deliveryPlanList.add(deliveryPlan2);
            deliveryPlanList.add(deliveryPlan3);
            Set<Id> QuoteIds = new Set<Id>();
            QuoteIds.add(c.Id);
            Grid_WithoutSharingServiceClass.cloneDeliveryPlan(QuoteIds);
            Test.stopTest();
            
           /* List<ProductSchedule__c> productSchedules = [
                SELECT Id, Grid_QuoteLineItem__c, Name
                FROM ProductSchedule__c
                WHERE Grid_ContractLine__c = :clilist[0].Id
            ];
            System.assertEquals(
                0,
                productSchedules.size(),
                'Product schedules were not deleted'
            );*/
        }
    }
    
}