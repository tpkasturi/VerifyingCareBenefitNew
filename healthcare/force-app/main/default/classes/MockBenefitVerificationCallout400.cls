global class MockBenefitVerificationCallout400 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(400);
        res.setBody('{"error":"Missing required fields"}');
        return res;
    }
}