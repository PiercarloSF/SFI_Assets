/**
* Class to implement the Platform Event when status is Handover
*
* @Author  Salesforce
*
*/
public without sharing class Grid_ContractPlatformEvent {
    
    public static void callPlatformEvent(List<Contract> contracts){
        
        List<Grid_NotificationEvent__e> caeList = new List<Grid_NotificationEvent__e>();
        
        for (Contract con : contracts) {
            if (con.Status == 'Handover' && con.Grid_Profit_Loss__c != True && con.Grid_Signed_contract_and_attachments__c != True) {
                Grid_NotificationEvent__e cae = new Grid_NotificationEvent__e();
                String message = 'showPopup';
                cae.Message__c = message;
                caeList.add(cae);
            }
        }
        
        try {
            if (caeList.size() > 0) {
                EventBus.publish(caeList);
            }
        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
    
}