/**
* This class is a Mock for HTTP body
*  
* @author  Salesforce
* @version	1.0
*
*/
public class Grid_Mock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        
        // You could assert the request content here
        String FAKE_RESPONSE_JSON = 'xxxx';
        HTTPResponse res = new HTTPResponse();
        res.setBody(FAKE_RESPONSE_JSON);
        res.setStatusCode(200);
        return res;
    }
    
}