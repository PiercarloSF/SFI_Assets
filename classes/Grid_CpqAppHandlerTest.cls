/**
* This class is a test class for Grid_CpqAppHandler
*  
* @author	
* @version	1.0
*
*/
@isTest
private class Grid_CpqAppHandlerTest {

    @IsTest
    private static void ApplyAdjustmentCustomTest(){
        Map<String,Object> input = new Map<String, Object>{ 'id' => 'xxxxxxxx:ss:ss:88:Discount:12:A:99' ,'cartId' => 'XXXXXXXX'};
        Grid_CpqAppHandler remoteActionClass = new Grid_CpqAppHandler();
        Test.StartTest(); 
        remoteActionClass.invokeMethod('ApplyAdjustmentCustom',input, new Map<String,Object>(), new Map<String,Object>());
        Test.StopTest(); 
    } 

}