@isTest
private class Grid_ContentDocumentServiceClassTest {
    // Helper method to create a contract with the given owner and status
    private static Contract createContract(Id ownerId, String status) {
        Account account = (Account) TestDataFactory.createSObject('Account', true);
        Contract contract = (Contract) TestDataFactory.createSObject('Contract', 
            new Map<String, Object>{ 'OwnerId' => ownerId, 'Status' => status,'AccountId'=>account.Id }, true
            );
        return contract;
    }

    // Helper method to create a content document link with the given linked entity and content document
    private static ContentDocumentLink createContentDocumentLink(Id linkedEntityId, Id contentDocumentId) {        
        ContentDocumentLink cdl = (ContentDocumentLink) TestDataFactory.createSObject('ContentDocumentLink', 
            new Map<String, Object>{ 
                'LinkedEntityId' => linkedEntityId, 
                'ContentDocumentId' => contentDocumentId,
                'ShareType'=>'V' }, 
                true
        );
        return cdl;
    }

    // Helper method to create a contract team member with the given contract and user
    private static Grid_ContractTeamMember__c createContractTeamMember(Id contractId, Id userId) {
        Grid_ContractTeamMember__c contractTeamMember = (Grid_ContractTeamMember__c) TestDataFactory.createSObject('Grid_ContractTeamMember__c', 
            new Map<String, Object>{ 'Grid_Contract__c' => contractId, 'Grid_User__c' => userId,'Grid_TeamRole__c'=>'Account Executives' }, true
        );
        return contractTeamMember;
    }

    // Test method to verify that notifications are sent when a file is uploaded by a non-owner to an activated contract
    @isTest(SeeAllData=true)
    static void testSendNotifications() {
        // Create two users: one for the contract owner and one for the file uploader
        User owner = new User(Id = UserInfo.getUserId());
        User uploader = new User(Id = UserInfo.getUserId());
        // Create an activated contract with the owner as the owner
        // soql query to get the one contract where the status is activated
        Contract contract = [SELECT Id, OwnerId, Status FROM Contract WHERE Status = 'Activated' LIMIT 1];

        // Create a content document with the uploader as the owner
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'Test Document.pdf';
        cv.VersionData = Blob.valueOf('Test Document');
        insert cv;

        // Create a content document link between the contract and the content document
        ContentDocumentLink cdl = createContentDocumentLink(contract.Id, [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId);

        // Create a contract team member with the uploader as the user
        Grid_ContractTeamMember__c ctm = createContractTeamMember(contract.Id, uploader.Id);

        // Run the test method in a separate context
        Test.startTest();

        // Call the sendNotifications method with the content document link as the input
        Grid_ContentDocumentServiceClass.sendNotifications(new List<ContentDocumentLink>{cdl});

        // Stop the test context
        Test.stopTest();


    }

}