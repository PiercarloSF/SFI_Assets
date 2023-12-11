/*
 * Class to generate a JWT Token for use with APIs
 *
 */

 global with sharing class Grid_Integration implements vlocity_cmt.VlocityOpenInterface {

    /*
     * Standard entrypoint for VlocityOpenInterface.
     */
    global Boolean InvokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try {
            if (methodName.equals('getToken')) {
                authWithEpic(methodName, input, output, options);
                return true;
            }
        } catch (Exception e) {
            output.put('Error', e.getMessage()); 
        }
        return false;
    }

    /* This is the main function where we call the various objects */

    public Static string authWithEpic(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {

        Grid_SAP_token__mdt tokenMeta = Grid_SAP_token__mdt.getInstance('SAPTokenRecord');
  
        String clientId = tokenMeta?.Grid_Client_Id__c;
        String clientSecret = tokenMeta?.Grid_Client_Secret__c;
        String username = tokenMeta?.Grid_Username__c;
        String password = tokenMeta?.Grid_Password__c;
        String defaultUrl = tokenMeta?.Grid_Default_URL__c;
        
        String errorMessage = '';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        String access_token = null;
        Http httpObj = new Http();

        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint(defaultUrl);
        req.setMethod('POST');
        req.setBody('grant_type=password' + '&username='+username +'&password='+password);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Basic '+base64URLencode(Blob.valueOf(clientId+':'+clientSecret)));
        
        res = httpObj.send(req);
        System.debug(res.getBody());

        
        try {
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                access_token = (String) responseMap.get('access_token');
                output.put('Token', access_token);
                System.debug('access token: ' +access_token);
            } else {
                System.debug(' Error Occurred ' + res.getBody());
            }
        } catch (Exception ex) {
            output.put('Token', null);
            System.debug(' Error Occurred ' + res.getBody());
        }

        System.debug('YES. We have a access token: ' + access_token);
        return access_token;
    }

    public static String base64URLencode(Blob input) {
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {  
            output = output.subString(0, output.length() - 1);
        }
        return output;
    }
}