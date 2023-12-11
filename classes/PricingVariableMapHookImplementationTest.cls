@isTest
private class PricingVariableMapHookImplementationTest {
    @isTest
    static void testCalculatePreInvoke() {
        PricingVariableMapHookImplementation context = new PricingVariableMapHookImplementation();
        Map<String, Object> input = new Map<String, Object>{'pricingVariableMap' => null, 'pricingLogDataMap' => null};
        
        Test.startTest();
        Boolean toReturn = context.invokeMethod('calculate.PreInvoke', input, null, null);
        Test.stopTest();
    
        System.assertEquals(toReturn, true);
    }
    
    @isTest
    static void testCalculatePostInvoke() {
        PricingVariableMapHookImplementation context = new PricingVariableMapHookImplementation();
        
        Map<String, Object> pricingVariableMap = new Map<String, Object>{'LINE_QUANTITY' => 0, 'REC_YEAR_STD_PRC' => 0, 'ROLLUP_REC_YEAR_STD_PRC_TOTAL' => 0, 'REC_YEAR_STD_CST' => 0,'ROLLUP_REC_YEAR_STD_CST_TOTAL' => 0, 'REC_YEAR_STD_CST_TOTAL' =>0};
        Map<String, Object> input = new Map<String, Object>{'isRoot' => true};
        Map<String, Object> output = new Map<String, Object>{'pricingVariableMap' => pricingVariableMap, 'pricingLogDataMap' => new Map<String, Object>()};
        
        Test.startTest();
        Boolean toReturn = context.invokeMethod('calculate.PostInvoke', input, output, null);
        Test.stopTest();
    
        System.assertEquals(toReturn, true);
    }
}