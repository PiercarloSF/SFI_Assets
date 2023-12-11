global with sharing class ApplyFrameContractPrice implements vlocity_cmt.VlocityOpenInterface {
    
    private static Boolean isLogging                      = false;            // flip to true if you want to see lots of debug information
    private static String  namespacePrefix                = 'vlocity_cmt__';  // Vlocity namespace prefix
    
    static {
        if (getCpqConfigurationSetupValue('PricingPlanHelperLogging') == 'True') isLogging = true;
    }
    
    /**
* Top level call by a Vlocity Price List
*
* @param inputMap   The input provided to the method
* @param outputMap  Any output to be provided back
* @param options    Any options to aid in the execution of this class
*
* @returns true if the method completes successfully, false otherwise
*/    
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        
        try {
            
            if (methodName.equals('priceItems')) return priceItems(input, output, options);
            else output.put('Error', 'Unsupported method name: ' + methodName);
        }
        catch (Exception ex) {
            
            System.debug(LoggingLevel.ERROR, ex);
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output.put('error', ex.getMessage());
        }
        
        return false;
    }
    
    /**
* Applies any frame contract pricing to the items in the order, quote, or opportunity.
*
* @param inputMap    The input provided to the method
* @param outputMap   Any output to be provided back
* @param optionsMap  Any options to aid in the execution of this class
*
* @returns true if the method completes successfully, false otherwise
*/  
    private Boolean priceItems(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        List<SObject> itemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        
        if (isLogging) {
            System.debug('$$$$ in price items method: ' + JSON.serialize(inputMap));
            System.debug('$$$$ outputMap: ' + JSON.serialize(outputMap));
            System.debug('$$$$ parent: ' + JSON.serialize(parent));
            System.debug('$$$$ itemList: ' + JSON.serialize(itemList));   // items in order, quote, or opportunity
        }
        
        // Skip everything if we have no items to process
        if(itemList == null || itemList.isEmpty()) return true;
        
        // Build up the mappings of products and line items
        List<SObject> itemSoList                  = new List<SObject>();           // List of Line Item Item SObjects
        List<Id> productIdList                    = new List<Id>();                // List of Product IDs
        Map<Id, List<SObject>> productIdToSObject = new Map<Id, List<SObject>>();  // Mapping of product IDs to list of Line Item SObjects
        
        for (Integer i=0; i<itemList.size(); i++) {
            
            SObject objectSO = itemList[i];
            
            if (objectSO != null && objectSO.getSObject('PricebookEntry') != null) {
                
                Id productId = (Id)objectSO.getSObject('PricebookEntry').get('Product2Id');
                productIdList.add(productId);
                
                if (productIdToSObject.get(productId) != null) productIdToSObject.get(productId).add(objectSO);                    
                else {
                    
                    itemSoList = new List<SObject>();
                    itemSoList.add(objectSO);
                    productIdToSObject.put(productId, itemSoList);
                }
            }
        }
        
        // Return if we didn't find any products
        if (productIdList == null || productIdList.isEmpty()) return true;
        
        // Set parent details
        String itemObjName = itemList[0].getSObjectType().getDescribe().getName();
        String parentObjName;
        if      (itemObjName == 'OpportunityLineItem') parentObjName='Opportunity';
        else if (itemObjName == 'OrderItem')           parentObjName='Order';
        else if (itemObjName == 'QuoteLineItem')       parentObjName='Quote';
        String modelOrderItem;
        String modelOrderItem1;
        String modelOrderItem2;
        String modelOrderItem3;
        // Get the line items from the frame contract
        List<SObject> listContractLineItems = getFrameContractLineItems(productIdList, (Id)parent.get('Id'), parentObjName);
        if (isLogging) System.debug('$$$$ listContractLineItems :' + JSON.serialize(listContractLineItems));
        
        system.debug('contractlist : '+listContractLineItems);
        // Return if we didn't find any frame contract line items
        if (listContractLineItems == null || listContractLineItems.isEmpty()) return true;
        
        List<SObject> lineItemSObject = new List<SObject>();            // container for updated line items
        Map<String, Object> itemFields = new Map<String, Object>();
        
        // For each contract line item, locate and update the products in the order/quote/opportunity
        for (SObject cline: listContractLineItems) {
            
            System.debug('$$$$ Overriding Pricing for "' + cline.get('Name') + '" from frame contract');
            
            // Get List of Line Items currently on the order/quote/opportunity for this product
            List<SObject> oObjectSOList = productIdToSObject.get((Id)cline.get(namespacePrefix + 'Product2Id__c'));
            if (oObjectSOList != null && !oObjectSOList.isEmpty()){
                
                // For each matching line item, update the pricing  
                for (SObject lineItem: oObjectSOList) {
                    Object selectedValues=lineItem.get('vlocity_cmt__AttributeSelectedValues__c');
                    if(selectedValues!=null)
                    {
                        Map<String,Object> selectedValuesMap=(Map<String,Object>)JSON.deserializeUntyped((String)selectedValues)
                            ;
                        if((String)selectedValuesMap.get('AT_NEXY_MODEL')!=null)
                        {
                            modelOrderItem=(String)selectedValuesMap.get('AT_NEXY_MODEL');
                        }
                        else
                            if((String)selectedValuesMap.get('AT_OM_MODEL')!=null)
                        {
                            modelOrderItem=(String)selectedValuesMap.get('AT_OM_MODEL');
                        }
                        else
                            if((String)selectedValuesMap.get('AT_JOBI_MODEL')!=null)
                        {
                            modelOrderItem=(String)selectedValuesMap.get('AT_JOBI_MODEL');
                        }
                        else
                            if((String)selectedValuesMap.get('ATT_LVM_MODEL')!=null)
                        {
                            modelOrderItem=(String)selectedValuesMap.get('ATT_LVM_MODEL');
                        }
                       
                    }
                     else
                            modelOrderItem=null;
                    
                    if((modelOrderItem == (String)cline.get('OpenMeterFormula__c')) || modelOrderItem ==null)                        
                    {
                        itemFields.put(lineItem.Id, generatePricingUpdates(lineItem, cline));
                        
                        lineItemSObject.add(lineItem);
                        
                    }
                    
                    
                }              
            }                      
        }
        
        if (isLogging) System.debug('lineItemSObject :' + lineItemSObject);
        
        // instead of doing an update DML, we pass it back into the pricing plan so in the "Save Line Items" step it will do one DML
        //update lineItemSObject;
        
        Type t = Type.forName('vlocity_cmt.SetCartItemExternalPriceService');
        if (t != null) {
            
            vlocity_cmt.VlocityOpenInterface externalPriceService = (vlocity_cmt.VlocityOpenInterface)t.newInstance();
            
            Map<String, Object> externalPriceServiceInput = new Map<String, Object>();
            Map<String, Object> externalPriceServiceOutput = new Map<String, Object>();
            Map<String, Object> externalPriceServiceOptions = new Map<String, Object>();
            
            // Field Mappings for the external pricing service
            // Look at getCart response/actions on fields for hints as to what these should be. I've tried to add many of them here even
            // though we don't necessarily use them from the contract line items currently.
            Map<String, String> varCodeToFieldMap = new Map<String, String> {'OT_STD_PRC' => namespacePrefix + 'OneTimeCharge__c',
                'OT_STD_PRC_TOTAL' => namespacePrefix + 'OneTimeTotal__c',
                'Grid_OT_STD_CST' => 'Grid_OneTimeCost__c',
                //'Grid_OT_STD_CST_TOTAL' => 'Grid_OneTimeCostTotal__c',
                'REC_MNTH_STD_PRC' => namespacePrefix + 'RecurringCharge__c',
                'REC_MNTH_STD_PRC_TOTAL' => namespacePrefix + 'RecurringTotal__c',
                'Grid_REC_MNTH_STD_CST' => 'Grid_RecurringCost__c',
                //'Grid_REC_MNTH_STD_CST_TOTAL' => 'Grid_RecurringCostTotal__c',
                'REC_YEAR_STD_PRC' => 'Grid_RecurringChargeYearly__c',
                'REC_YEAR_STD_PRC_TOTAL' => 'Grid_RecurringTotalYearly__c',
                'REC_YEAR_STD_CST' => 'Grid_Recurring_Cost_Yearly__c',
                'REC_YEAR_STD_PRC_TOTAL' => 'Grid_Recurring_Cost_Total_Yearly__c'};
                    
                    /*
Map<String, String> varCodeToFieldMap = new Map<String, String> {'REC_MNTH_STD_PRC' => namespacePrefix + 'RecurringCharge__c',
'REC_MNTH_STD_PRC_TOTAL' => namespacePrefix + 'RecurringTotal__c',
//'REC_MNTH_STD_PRC_CALC' => namespacePrefix + 'RecurringCalculatedPrice__c',
'OT_STD_PRC' => namespacePrefix + 'OneTimeCharge__c',
'OT_STD_PRC_TOTAL' => namespacePrefix + 'OneTimeTotal__c',
'REC_YEAR_STD_CST' => 'Grid_Recurring_Cost_Yearly__c',
'REC_YEAR_STD_CST_TOTAL' => 'Grid_Recurring_Cost_Total_Yearly__c',
'REC_YEAR_STD_PRC' => 'Grid_RecurringChargeYearly__c',
'REC_YEAR_STD_PRC_TOTAL' => 'Grid_RecurringTotalYearly__c',
'REC_MNTH_STD_PRC' => 'vlocity_cmt__RecurringCharge__c',
'REC_MNTH_STD_PRC_TOTAL' => 'vlocity_cmt__RecurringTotal__c',
'OT_STD_CST' => 'Grid_OneTimeCost__c',
'OT_STD_CST_TOTAL' => 'Grid_OneTimeCostTotal__c',

'OT_STD_PRC_CALC' => namespacePrefix + 'OneTimeCalculatedPrice__c'}; */
                    
                    externalPriceServiceInput.put('parent', parent);
            externalPriceServiceInput.put('itemList', lineItemSObject);
            externalPriceServiceInput.put('pricingVariableToFieldMap', varCodeToFieldMap);                          
            externalPriceServiceInput.put('itemFieldsInfo', itemFields);
            
            // skip update to prevent this service from flushing to the database since the pricing plan service
            // will update the itemList anyway, this saves one DML update
            externalPriceServiceOptions.put('SkipUpdate', true);
            
            if (isLogging) System.debug('$$$$ externalPriceServiceInput ' + JSON.serialize(externalPriceServiceInput));
            externalPriceService.invokeMethod('setItemPrices', externalPriceServiceInput, externalPriceServiceOutput, externalPriceServiceOptions);
            if (isLogging) System.debug('$$$$ externalPriceServiceOutput: ' + JSON.serialize(externalPriceServiceOutput));
        }
        else System.debug(LoggingLevel.ERROR, '$$$$ Unable to locate class "vlocity_cmt.SetCartItemExternalPriceService"');
        
        return true;
    }
    
    /**
* Generates pricing updates to send to the external pricing service (vlocity_cmt.SetCartItemExternalPriceService)
*
* @param li  The line item to update (on an order, quote, or opportunity)
* @param cli The contract line item to pull the pricing from
*
* @return Pricing Updatest for the external pricing service
*/
    public Map<String, Object> generatePricingUpdates(SObject li, SObject cli) {
        
        // List of Fields we will override        
        List<String> fields = new List<String> {'vlocity_cmt__OneTimeCharge__c','vlocity_cmt__RecurringCharge__c',
            'Grid_Recurring_Cost_Yearly__c','Grid_Recurring_Cost_Total_Yearly__c','Grid_RecurringTotalYearly__c',
            'Grid_RecurringChargeYearly__c','vlocity_cmt__RecurringCharge__c','vlocity_cmt__RecurringTotal__c',
            'Grid_OneTimeCost__c',
            //'Grid_OneTimeCostTotal__c',
            'Grid_RecurringCost__c'};                                          
                // Track changes
                Map<String, Object> lineItemFields = new Map<String, Object>();                                                                                                          
        
        // For each field, update it
        Iterator<String> fieldIter = fields.iterator();
        while (fieldIter.hasNext()) {
            
            // String field = namespacePrefix + fieldIter.next();
            String field = fieldIter.next();
            
            // Get the Contract Value (if configured)            
            Object contractValue = cli.get(field);
            if (contractValue != null) {
                
                //System.debug('$$$$ Overriding ' + field + ': ' + li.get(field) + ' -> ' + contractValue);
                //li.put(field, contractValue);  // This isn't necessary when using the external pricing service as the update request is generated below
                
                // Generate Update
                Map<String, Object> lineItemFieldValue = new Map<String, Object>();
                lineItemFieldValue.put('detail', 'Price from Frame Agreement');
                lineItemFieldValue.put('value', contractValue);
                
                lineItemFields.put(field, lineItemFieldValue);
            }
        }
        
        return lineItemFields;
    }
    
    /**
* Returns all the 'applicable' Line Items found in the frame contract.  Only line items in the frame
* contract that match products on the current order will be returned.
*
* @param productIdList  The list of product Ids found in the order/quote/opportunity
* @param parentId       The order, quote, or opportunity Id
* @param parentObjName  The name of the order, quote, or opportunity
*
* @return List of matching line items from the frame contract
*/
    private List<SObject> getFrameContractLineItems(List<Id> productIdList, Id parentId, String parentObjName) {
        
        SObjectType contractLineObj = Schema.getGlobalDescribe().get(namespacePrefix + 'ContractLineItem__c');        
        Map<String,Schema.SObjectField> objfields = contractLineObj.getDescribe().fields.getMap();
        
        // Build the SOQL Query
        String query = 'SELECT ';
        Boolean firstField = true;
        
        // Fields
        for (String field: objfields.keySet()) {
            
            if(!firstField) query += ' , ';
            firstField = false;
            
            query += field;
        }
        
        // FROM
        query += ' FROM ' + namespacePrefix + 'ContractLineItem__c';
        
        // WHERE
        query += ' WHERE ' + namespacePrefix + 'Product2Id__c IN :productIdList  AND ' + namespacePrefix + 'ContractId__c IN (select ' + namespacePrefix + 'frameContractId__c FROM ' + parentObjName + ' WHERE Id= \'' + parentId +'\'' + ')';
        if (isLogging) System.debug('$$$$ line item query is ' + query);
        
        //return database.query(query);
        List<vlocity_cmt__ContractLineItem__c> q = new List<vlocity_cmt__ContractLineItem__c> ();
        q=Database.query(query);
        return q;
        
        
        
        
    }
    
    /**
* Pulls the value of a configuration parameter from the org
*
* @param setupName  The configuration parameter to look for
*
* @return The value of the configuration parameter (if found), null otherwise
*/
    private static String getCpqConfigurationSetupValue(String setupName) {
        
        vlocity_cmt__CpqConfigurationSetup__c cpqSetup = vlocity_cmt__CpqConfigurationSetup__c.getInstance(setupName);
        
        // expected condition: there is a Custom Setting
        if (cpqSetup != null && cpqSetup.vlocity_cmt__SetupValue__c != null && cpqSetup.vlocity_cmt__SetupValue__c.length() > 0) return cpqSetup.vlocity_cmt__SetupValue__c;
        
        return null;
    }
}