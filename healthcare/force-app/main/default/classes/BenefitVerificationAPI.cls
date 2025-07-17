@RestResource(urlMapping='/care-benefit-verification-results')
global with sharing class BenefitVerificationAPI {
  @HttpPost
    global static void handleResult() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            Map<String, Object> resultBody = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());

            String requestId = (String) resultBody.get('careBenefitRequestId');
            String status = (String) resultBody.get('status');
            String reason = (String) resultBody.get('statusReason');
            
            if(String.isEmpty(requestId)){
                res.statusCode = 400;
            	res.responseBody = Blob.valueOf('care Benefit Request Id missing');
                return;
            }
            
            if(String.isEmpty(status) || String.isEmpty(reason)){
                res.statusCode = 400;
            	res.responseBody = Blob.valueOf('status or reason is missing');
                return;
            }
            CareBenefitVerifyRequest cbvr = [SELECT Id, planId, PayerId FROM CareBenefitVerifyRequest WHERE Id = :requestId LIMIT 1];
            if(cbvr == null){
                res.statusCode = 400;
            	res.responseBody = Blob.valueOf('Care Benefit Verify Request not present');
                return;
            }

            CoverageBenefit cb = new CoverageBenefit(
                Name = 'Mocked Coverage Benefit',
                MemberPlanId = cbvr.planId,
                MemberId = cbvr.PayerId
            );
            insert cb;
            
            cbvr.CoverageBenefitId = cb.Id;
            update cbvr;

            res.statusCode = 201;
            res.responseBody = Blob.valueOf('Coverage Benefit Created');

        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + ex.getMessage());
        }
    }
}