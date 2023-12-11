/*
* @description: This class is used to get the Products Hierarchy that were added in the contract line items of the contract
*/
public with sharing class Grid_ContractController {
    public class Node {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<Node> children;
        public Node(String name, String label) {
            this.name = name;
            this.label = label;
            this.children = new List<Node>();
        }
    }
    /**
     * 
     * @description get Product hierarchy level
     * @return Integer
     * */
    @AuraEnabled(cacheable=true)
    public static Integer fetchGridProductHierarchyLevel() {
        Grid_Configuration__mdt config = [
            SELECT Grid_ProductHierarchyLevel__c
            FROM Grid_Configuration__mdt
            LIMIT 1
        ];
        return (config != null) ? Integer.valueOf(config.Grid_ProductHierarchyLevel__c) : null;
    }

    /**
     * this method is used to get the line items of the contract by root id 
     * @param contractId
     * @return List<vlocity_cmt__ContractLineItem__c>
     * */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<vlocity_cmt__ContractLineItem__c>> getLineItemsByRootId(Id contractId) { 
        Map<String, List<vlocity_cmt__ContractLineItem__c>> lineItemsByRootId = new Map<String, List<vlocity_cmt__ContractLineItem__c>>(); 
        for (vlocity_cmt__ContractLineItem__c li : [SELECT id,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__Quantity__c,OpenMeterFormula__c,
                Grid_Remaining_Quantity__c, Grid_Actual_Quantity__c,Grid_RootItemId__c,Grid_ParentItemId__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,
                vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringTotal__c,Recurring_Charge_Yearly__c,Recurring_Total_Yearly__c
                FROM vlocity_cmt__ContractLineItem__c
                WHERE vlocity_cmt__ContractId__c = :contractId]) {     
            if (!lineItemsByRootId.containsKey(li.Grid_RootItemId__c)) {
                lineItemsByRootId.put(li.Grid_RootItemId__c, new List<vlocity_cmt__ContractLineItem__c>());
            }
            lineItemsByRootId.get(li.Grid_RootItemId__c).add(li);
        }
        return lineItemsByRootId;
    }


    /**
     * this method is used to get the product child items by parent id
     * @param contractId
     * @return Map<String, List<vlocity_cmt__ProductChildItem__c>>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<vlocity_cmt__ProductChildItem__c>> getProductChildItemsByParentId(Id contractId) { // Added a parameter for productIds
        Map<String, List<vlocity_cmt__ProductChildItem__c>> productChildItemsByParentId = new Map<String, List<vlocity_cmt__ProductChildItem__c>>();
        List<vlocity_cmt__ProductChildItem__c> productChildItems = new List<vlocity_cmt__ProductChildItem__c>();
        Set<Id> productIds = getProductIdsFromLineItems(contractId);
        productChildItems = [
            SELECT id,vlocity_cmt__ParentProductId__c,
                vlocity_cmt__ParentProductName__c,vlocity_cmt__ChildProductId__c,
                vlocity_cmt__ChildProductName__c 
                FROM vlocity_cmt__ProductChildItem__c 
                WHERE (vlocity_cmt__ParentProductId__c != null AND vlocity_cmt__ParentProductId__c IN :productIds)
                OR (vlocity_cmt__ChildProductId__c != null AND vlocity_cmt__ChildProductId__c IN :productIds)
            ];
        for (vlocity_cmt__ProductChildItem__c pci : productChildItems) {
            if (!productChildItemsByParentId.containsKey(pci.vlocity_cmt__ParentProductId__c)) {
                productChildItemsByParentId.put(pci.vlocity_cmt__ParentProductId__c, new List<vlocity_cmt__ProductChildItem__c>());
            }
            if (productIds.contains(pci.vlocity_cmt__ChildProductId__c)) {
                productChildItemsByParentId.get(pci.vlocity_cmt__ParentProductId__c).add(pci);
            }
        }
        return productChildItemsByParentId;
    }

    /**
     * this method is used to get the product ids from the line items
     * @param contractId
     * @return Set<Id>
     */
    private static Set<Id> getProductIdsFromLineItems(Id contractId) {
        List<vlocity_cmt__ContractLineItem__c> productIdsFromLineItems = [SELECT id,vlocity_cmt__Product2Id__c 
                                FROM vlocity_cmt__ContractLineItem__c 
                                WHERE vlocity_cmt__ContractId__c = :contractId];
        Set<Id> productIds = new Set<Id>();
        for (vlocity_cmt__ContractLineItem__c li : productIdsFromLineItems) {
            productIds.add(li.vlocity_cmt__Product2Id__c);
        }
        return productIds;
    }
}