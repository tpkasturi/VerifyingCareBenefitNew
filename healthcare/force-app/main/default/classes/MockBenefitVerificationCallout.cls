@IsTest
global class MockBenefitVerificationCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "Acknowledged","statusReason": "Care Benefit Verification Request successfully sent to Benefits Verification Provider."}');
        res.setStatusCode(200);
        return res;
    }
}