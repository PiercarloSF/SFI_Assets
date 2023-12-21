/*
* @author 		Piercarlo Drimaco (pdrimaco@salesforce.com)
* @date 		21/07/2023
* @group 		CLM
* @description 	Class to have available the Contract Document tab
*/
public class ContractDocumentController{ 
    public String recordId { get; set; }

    public PageReference router() 
    { 
        recordId = ApexPages.currentPage().getParameters().get('id');
        String pagereference = '/apex/vlocity_cmt__ContractDocumentNewDisplay?Id=' + recordId;
        //System.debug('****Enter ContractDocumentController.Router: ' + pagereference);
        return new PageReference(pagereference ); 
    } 
}