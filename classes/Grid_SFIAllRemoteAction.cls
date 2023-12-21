/**
* This class provides utilities to use as remote actions
*  
* @author	AES
* @version	1.0
*
*
*/

global class Grid_SFIAllRemoteAction implements vlocity_cmt.VlocityOpenInterface2 {
    
    
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        
        try {      
            if (methodName == 'createContractLItems') return createContractLItems(input, output, options); 
            if (methodName == 'doCloneWithLineItems') return doCloneWithLineItems(input, output, options);          
            if (methodName == 'checkSumOfOrderProductQuantities') return checkSumOfOrderProductQuantities(input, output, options);   
            if (methodName == 'refreshContractRecordPage') return refreshContractRecordPage(input, output, options);          
        }
        catch (Exception e) {                       
            output.put('error', e.getMessage() + ':' + e.getStackTraceString());
        }
        return false;
    }


    private Boolean refreshContractRecordPage(Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        Grid_RefreshContractRecrodPage__e event = new Grid_RefreshContractRecrodPage__e();
        EventBus.publish(event);
        return true;
    }
    
    /**
     * This method will check the total quantities of all the order product with the quantity in the contract line item 
     * @param input   The input data provided in the call to this method
     * @param output  The output object where any results will be stored
     * 
     */
    private Boolean checkSumOfOrderProductQuantities(Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        String message = 'You have exceeded the quantity of the following products: ';
        // Retrieve order id from input
        Id orderId  = (Id) input.get('orderId');
        if(orderId == null) {
            output.put('quantityChecked', false);
            return false;
        }

        // Get the Order Item to Contract Line Item map
        Map<Id, vlocity_cmt__ContractLineItem__c> orderItemToContractLineItemMap = new Map<Id, vlocity_cmt__ContractLineItem__c>();
        orderItemToContractLineItemMap = Grid_OrderServiceClass.getOrderItemToContractLineItemMap(orderId);

        // Get all Order Items related to the input Order Id
        List<OrderItem> inputOrderItems = [
            SELECT Id, Product2Id, Quantity,Grid_IsChild__c,Product2.Name,Grid_MeterModel__c
            FROM OrderItem
            WHERE OrderId = :orderId AND Grid_IsChild__c = true
        ];

        // Iterate through the input Order Items and compare the quantities
        for (OrderItem oi : inputOrderItems) {
            vlocity_cmt__ContractLineItem__c cli = orderItemToContractLineItemMap.get(oi.Id);
            if (cli==null) {
                message = Label.wrong_smart_meters_config;
                output.put('quantityChecked', false);
                break;
            }else if (cli.Grid_Remaining_Quantity__c !=null && oi.Quantity > cli.Grid_Remaining_Quantity__c) {
                Integer quantityDifference = (Integer) (oi.Quantity - cli.Grid_Remaining_Quantity__c);
                message += oi.Product2.Name + (oi.Grid_MeterModel__c != null ? ' (Model : ' + oi.Grid_MeterModel__c + ')' : '') + ' by ' + quantityDifference + ' units. ';
                output.put('quantityChecked', false);
            }
        }
        // if the output does contain the key 'quantityChecked' and the value of the key is false
        // then we will add the exception message to the output
        // otherwise we will add the key 'quantityChecked' to the output and set it to true (all the quantities are correct)
        if(output.containsKey('quantityChecked') && output.get('quantityChecked') == false){
            output.put('exception', message);
            return false;
        } else {
            output.put('quantityChecked', true);
            Order order = [SELECT Id, Status FROM Order WHERE Id = :orderId];
            order.Status = 'Submitted';
            update order;
            return true;
        }
    }
    
    /**
* Create Contract line items from quote line items after we generate a frame agreement from a quote
* The method will link the Quote product schedule with this active contract
* @param input   The input data provided in the call to this method
* @param output  The output object where any results will be stored
* @param options Any options to aid in the execution of this class
* 
* @return true if the function completed successfully, false otherwise
*/
    private Boolean createContractLItems(Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
            
        String methodName;
        
        
        List<vlocity_cmt__ContractLineItem__c> contractLIList = new List<vlocity_cmt__ContractLineItem__c>();
        List<ProductSchedule__c> productSchedules = new List<ProductSchedule__c>();
        // Validate the input
        Id quoteId      = (Id)input.get('quoteId');
        Id contractId  = (Id)input.get('contractId');
        //Id deliveryPlanId  = (Id)input.get('deliveryPlanId');
        
        if(quoteId != null){
            List<quotelineitem> ListQuotelineitem1 = [select Id,(SELECT id FROM Product_Schedules__r),vlocity_cmt__Product2Id__c,QuoteId,Quantity,Product2.Name,
                                                    vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__OneTimeCost__c,vlocity_cmt__OneTimeCostTotal__c,
                                                    Grid_OneTimeMargin__c,Grid_RecurringChargeYearly__c,Grid_RecurringTotalYearly__c,Grid_Recurring_Cost_Yearly__c,
                                                    Grid_Recurring_Cost_Total_Yearly__c,Grid_RecurringMarginYearly__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringTotal__c,
                                                    vlocity_cmt__RecurringCost__c,vlocity_cmt__RecurringCostTotal__c,Grid_RecurringMargin__c,
                                                    PricebookEntryId,CurrencyIsoCode,vlocity_cmt__AttributeSelectedValues__c,
                                                    OpenMeterFormula__c, Grid_ID_SKU__c,vlocity_cmt__RootItemId__c,vlocity_cmt__ParentItemId__c FROM quotelineitem 
                                                    WHERE QuoteId=:quoteId];
            
            for(quotelineitem qli : ListQuotelineitem1){
                vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
                cli.Name = qli.product2.Name;
                cli.vlocity_cmt__ContractId__c = contractId;
                cli.vlocity_cmt__QuoteLineItem__c=qli.Id;
                cli.vlocity_cmt__Quantity__c=qli.Quantity;
                cli.vlocity_cmt__OneTimeCharge__c=qli.vlocity_cmt__OneTimeCharge__c;
                cli.vlocity_cmt__OneTimeTotal__c=qli.vlocity_cmt__OneTimeTotal__c;
                cli.Grid_OneTimeCost__c=qli.vlocity_cmt__OneTimeCost__c;
                cli.Grid_OneTimeCostTotal__c=qli.vlocity_cmt__OneTimeCostTotal__c;
                cli.Grid_OneTimeMargin__c=qli.Grid_OneTimeMargin__c;
                cli.Recurring_Charge_Yearly__c=qli.Grid_RecurringChargeYearly__c;
                cli.Grid_RecurringChargeYearly__c=qli.Grid_RecurringChargeYearly__c;
                cli.Recurring_Total_Yearly__c=qli.Grid_RecurringTotalYearly__c;
                cli.Grid_Recurring_Cost_Yearly__c=qli.Grid_Recurring_Cost_Yearly__c;
                cli.Grid_Recurring_Cost_Total_Yearly__c=qli.Grid_Recurring_Cost_Total_Yearly__c;
                cli.Grid_Recurring_Margin_Yearly__c=qli.Grid_RecurringMarginYearly__c;
                cli.vlocity_cmt__RecurringCharge__c=qli.vlocity_cmt__RecurringCharge__c;
                cli.vlocity_cmt__AttributeSelectedValues__c=qli.vlocity_cmt__AttributeSelectedValues__c;
                cli.vlocity_cmt__RecurringTotal__c=qli.vlocity_cmt__RecurringTotal__c;
                cli.Grid_RecurringCost__c=qli.vlocity_cmt__RecurringCost__c;
                cli.Grid_RecurringCostTotal__c=qli.vlocity_cmt__RecurringCostTotal__c;                
                cli.Grid_RecurringMargin__c=qli.Grid_RecurringMargin__c;
                cli.vlocity_cmt__Product2Id__c=qli.Product2Id;
                cli.vlocity_cmt__PricebookEntryId__c=qli.PricebookEntryId;
                cli.CurrencyIsoCode=qli.CurrencyIsoCode;
                cli.OpenMeterFormula__c=qli.OpenMeterFormula__c;
                cli.Grid_ID_SKU__c =qli.Grid_ID_SKU__c;
                cli.Grid_RootItemId__c =qli.vlocity_cmt__RootItemId__c;
                cli.Grid_ParentItemId__c =qli.vlocity_cmt__ParentItemId__c;
                contractLIList.add(cli);
                    
            }
            insert contractLIList;
            Map<Id,Id> mapContractLI= new Map<Id,Id>();
            for(vlocity_cmt__ContractLineItem__c cli : contractLIList){
                mapContractLI.put(cli.vlocity_cmt__QuoteLineItem__c,cli.Id);
            }
            
            for(quotelineitem cli : ListQuotelineitem1){
                for(ProductSchedule__c prodSched : cli.Product_Schedules__r){
                    
                    prodSched.Grid_ContractLine__c=mapContractLI.get(cli.id);
                    
                    productSchedules.add(prodSched);
                    
                }}
        }
        try{ 
            
            update productSchedules;
        }catch(DMLException e){
            output.put('Exception', e.getMessage() ); 
        }
        
        List<contract> ListQuotelineitem = [select Id FROM contract
                                            WHERE vlocity_cmt__QuoteId__c=:quoteId];
        List<DeliveryPlan__c> ListDeliv2=new List<DeliveryPlan__c>();
        List<DeliveryPlan__c> ListDeliv = [select id,Grid_Contract__c FROM DeliveryPlan__c
                                        WHERE Grid_Quote__c=:quoteId AND Grid_Version__c = 1];
        for(contract ctr:ListQuotelineitem){
            for(DeliveryPlan__c dlp:ListDeliv){
                dlp.Grid_Contract__c=ctr.Id;
                ListDeliv2.add(dlp);
            }
        }
        update ListDeliv2;
        return true;
    }
    private Boolean doCloneWithLineItems(Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        String methodName;
        Id recId;
        Quote q2;
        Id recordId= (Id)input.get('recordId');
        system.debug('QZahra'+recordId);
        if (recordId == null || (Id)recordId != recordId) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, 'QuoteId must be supplied.'));
            system.debug('QuoteId must be supplied'+recordId);
        }
        try {
            //List<Contract> ListQuotelineitem1 = [select id,vlocity_cmt__QuoteId__c,Status from Contract where vlocity_cmt__QuoteId__c=:recordId];
            String query = 'select AccountId, BillingAddress, BillingName, ContactId, ContractId, Description, Discount, Email, ExpirationDate, Fax, GrandTotal, OpportunityId, Phone, Name, QuoteToAddress, QuoteToName, ShippingHandling, ShippingAddress, ShippingName, Status, IsSyncing, Tax ';
            // get all of the custom, writeable fields
            Map<String, Schema.SObjectField> fieldMap = Quote.getSObjectTypE().getDescribe().fields.getMap();
            for (String key : fieldMap.keySet()) {
                Schema.SObjectField field = fieldMap.get(key);
                Schema.DescribeFieldResult result = field.getDescribe();
                if (result.isCustom() && !result.isCalculated()) {
                    query += ' ,'+result.getName();
                }
            }
            query += ' from Quote where Id = :recordId';
            Quote ql = Database.query(query);
            q2 = ql.clone();
            //q2.Status='Draft';
            q2.Status='Draft';
            insert q2;

        } catch(DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        if(q2 != null){
            recId = q2.Id;
            output.put('newId',recId);
        }
        if (recordId == null || (Id)recordId != recordId) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, 'QuoteId must be supplied.'));
            system.debug('QuoteId must be supplied.');
        }
        String query = 'select Quoteid, PricebookEntryId, Quantity, UnitPrice, Discount, Description, ServiceDate, ListPrice, Subtotal, TotalPrice ';
        // get all of the custom, writeable fields
        Map<String, Schema.SObjectField> fieldMap = QuoteLineItem.getSObjectTypE().getDescribe().fields.getMap();
        for (String key : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(key);
            Schema.DescribeFieldResult result = field.getDescribe();
            if (result.isCustom() && !result.isCalculated()) {
                query += ' ,'+result.getName();
            }
        }
        query += ' from QuoteLineItem where QuoteId = :recordId';
        system.debug('query'+query);
        List<QuoteLineItem> qlist = Database.query(query);
        List<QuoteLineItem> ql2 = new List<QuoteLineItem>();
        for(QuoteLineItem ql : qlist){
            QuoteLineItem ql1 = ql.clone();
            ql1.QuoteId = recId;
            ql2.add(ql1);
        }
        insert ql2;

        String query1 = 'select id,Grid_StartDate__c,Grid_Contract__c, Grid_EndDate__c,Grid_ScheduleCount__c,Grid_ScheduleFrequency__c,Grid_Quote__c,Grid_IsCloned__c';
        query1 += ' from DeliveryPlan__c where Grid_Quote__c = :recordId AND Grid_Version__c = 1';
        DeliveryPlan__c dlp = Database.query(query1);
        DeliveryPlan__c dlp2 = dlp.clone();
        dlp2.Grid_Quote__c = recId;
        dlp2.Grid_Contract__c = null;   
        dlp2.Grid_IsCloned__c = false;
        insert dlp2;
        
        return true;
    }
}