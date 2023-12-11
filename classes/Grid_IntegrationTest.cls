/**
* This class is a test class for Grid_Integration Class
*  
* @author  Salesforce
* @version	1.0
*
*/
@isTest
public class Grid_IntegrationTest {
    
    @IsTest
    private static void getTokenTest(){
        Map<String,Object> input = new Map<String, Object>();
        Grid_Integration remoteActionClass = new Grid_Integration();
        Test.setMock(HttpCalloutMock.class, new Grid_Mock());  
        Test.StartTest(); 
        Boolean access_token = remoteActionClass.InvokeMethod('getToken',new Map<String, Object>(),new Map<String, Object>(), new Map<String, Object>());
        Assert.areEqual(access_token, false);
        Test.StopTest(); 
    }
}