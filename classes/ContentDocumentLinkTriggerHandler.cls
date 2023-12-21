/**
 * Class to implement the trigger handler for attachement files in Objects
 *
 * @Author  Salesforce
 *
 */
public class ContentDocumentLinkTriggerHandler extends TriggerHandler {
    List<ContentDocumentLink> allFiles = new List<ContentDocumentLink>();
    List<ContentDocumentLink> contractFiles = new List<ContentDocumentLink>();

    public ContentDocumentLinkTriggerHandler() {
        this.allFiles = (List<ContentDocumentLink>) Trigger.new;
    }
    public override void afterInsert() {
        system.debug(Trigger.new);
        for (ContentDocumentLink cdl : (List<ContentDocumentLink>)Trigger.new) {
            // Check if the file is linked to a contract 
            if(cdl.LinkedEntityId!=null && cdl.linkedEntityId.getSObjectType().getDescribe().getName() == 'Contract') {
                contractFiles.add(cdl);
            }
          }
          if(!contractFiles.isEmpty()){
            Grid_ContentDocumentServiceClass.sendNotifications(contractFiles);

          }
    }
}