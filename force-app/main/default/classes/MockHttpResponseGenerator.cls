@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockHttpResponseGenerator() {
        this.code = 200;
        this.status = 'OK';
        this.body = '{"example":"test"}';
        this.responseHeaders = new Map<String, String>{'Content-Type'=>'application/json'};
    }
    
    public MockHttpResponseGenerator(String body) {
        this.code = 200;
        this.status = 'OK';
        this.body = body;
        this.responseHeaders = new Map<String, String>{'Content-Type'=>'application/json'};
    }

    // (200, 'OK', 'I found it!', new Map<String,String>()
    public MockHttpResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}