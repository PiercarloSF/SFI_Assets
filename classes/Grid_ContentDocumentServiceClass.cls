public with sharing class Grid_ContentDocumentServiceClass {

  /**
     * @description sends notifications to contract owners when a file is uploaded by a non-owner
     * @param files attachements added to the contract object 
     * @return void
    **/
    public static void sendNotifications(List<ContentDocumentLink> files){
        Set<Id> contractIds = new Set<Id>();
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        Map<String, Object> inputs = new Map<String, Object>();
  
          // Collect the ContractIds for all of the linked entities
        for (ContentDocumentLink cdl : files) {
              contractIds.add(cdl.LinkedEntityId);
        }
        // Fill a contract Map that takes the ID as a key
        List<Contract> contracts = [SELECT Id, OwnerId FROM Contract WHERE Id IN :contractIds];
          for (Contract contract : contracts) {
            contractMap.put(contract.Id, contract);
        }
        // browse all existing contracts files and check if the file owner is different from the contract owner to send a notification
        for (ContentDocumentLink cdl : files) {
          if(cdl.LinkedEntityId!=null && UserInfo.getUserId() != contractMap.get(cdl.LinkedEntityId).OwnerId) {
            String title = Label.file_insert_notification_title;
            String body  = Label.file_insert_notification_body + UserInfo.getName();
            List<Id> userIDs = new List<Id>{contractMap.get(cdl.LinkedEntityId).OwnerId};
  
            inputs.put('title', title);
            inputs.put('body', body);
            inputs.put('userIDs', userIDs);
            inputs.put('recordId',cdl.LinkedEntityId);
            Flow.Interview.Send_Notification_To_Users flow = new Flow.Interview.Send_Notification_To_Users(inputs);
  
            // Start the flow
            flow.start();
          
        }
    }
        }  
}