global class CpqCustomDiscountApprovalService implements vlocity_cmt.VlocityOpenInterface{
    private String NSP = 'vlocity_cmt__';
   	private String customSettingName = 'Cart Level Discount Approval Required';
   	private static String DISCOUNT_APPROVAL_SETTING = 'Cart Level Discount Approval Required';
   	private Boolean isDiscountApprovalRequired = false;

   	public CpqCustomDiscountApprovalService() {}

	global Boolean invokeMethod(	String methodName,
								Map<String, Object> input,
								Map<String, Object> output,
								Map<String, Object> options)
	{
		try {
			if (methodName == 'generateApprovalStatus') {
				generateApprovalStatus(input, output, options);
			}
			return true;
		} catch (Exception ex) {
			output.put('errors', true);
			output.put('errorResult', ex.getMessage());
			return false;
		}
	}

	public void generateApprovalStatus(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
		List<SObject> sObjList = (List<SObject>) input.get('discounts');
		List<SObject> settings = [SELECT Id, Name, vlocity_cmt__SetupValue__c from vlocity_cmt__CpqConfigurationSetup__c where Name = :DISCOUNT_APPROVAL_SETTING LIMIT 1];

		//Get the Value for Custom Setting
		String setupValue = (String)settings[0].get(NSP+'SetupValue__c');
		if(setupValue.equalsIgnoreCase('True')){
			isDiscountApprovalRequired = true;
		}
	}
}