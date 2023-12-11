/**
 * Class to implement the selected value of non mandetory checklist
 *
 * @Author  Salesforce
 *
 */
public with sharing class Grid_NonMandatoryChecklist {
    @AuraEnabled
    public static void updateChecklist(Id recordId, List<String> selectedItems) {

        Contract fieldToUpdate = [SELECT Id, Grid_Profit_Loss__c, Grid_Technical_offer__c, Grid_Economic_offer__c, 
                                  Grid_Signed_contract_and_attachments__c, Grid_Guarantees__c, Grid_Various_supplier_offers__c
                                  FROM Contract WHERE Id = :recordId];

        // Check if the record exists
        if (fieldToUpdate != null) {
            // Update the fields based on the checklist values
            // Iterate through the checklist and update the fields accordingly
            for (String item : selectedItems) {
                if (item.equalsIgnoreCase('profitLoss')) {
                    fieldToUpdate.Grid_Profit_Loss__c = true;
                } else if (item.equalsIgnoreCase('technicalOffer')) {
                    fieldToUpdate.Grid_Technical_offer__c = true;
                } else if (item.equalsIgnoreCase('economicOffer')) {
                    fieldToUpdate.Grid_Economic_offer__c = true;
                } else if (item.equalsIgnoreCase('signedContract')) {
                    fieldToUpdate.Grid_Signed_contract_and_attachments__c = true;
                } else if (item.equalsIgnoreCase('guarantees')) {
                    fieldToUpdate.Grid_Guarantees__c = true;
                } else if (item.equalsIgnoreCase('variousOffers')) {
                    fieldToUpdate.Grid_Various_supplier_offers__c = true;
                }
            }

            // Update the record with the new field values
            update fieldToUpdate;
        }
    }
}