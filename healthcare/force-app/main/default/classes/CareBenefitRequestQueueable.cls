public class CareBenefitRequestQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> requestIds;

    public CareBenefitRequestQueueable(List<CareBenefitVerifyRequest> requests) {
        this.requestIds = new List<Id>();
        for (CareBenefitVerifyRequest req : requests) {
            this.requestIds.add(req.Id);
        }
    }

    public void execute(QueueableContext context) {
        List<CareBenefitVerifyRequest> requestList = [SELECT Id, Payer.FirstName, Payer.LastName, Payer.PersonBirthdate, 
                                						 Payer.PersonGender, MemberPlan.Name, MemberPlan.GroupNumber, 
                                                         MemberPlan.SubscriberId, MemberPlan.Payer.Name, MemberPlan.Plan.PlanNumber, MemberPlan.Plan.ServiceType,
                                                         Provider.FirstName, Provider.LastName, ProviderId, MemberPlan.Plan.EffectiveFrom, MemberPlan.Plan.EffectiveTo  
                                                         FROM CareBenefitVerifyRequest WHERE Id IN:requestIds];

        for (CareBenefitVerifyRequest req : requestList) {
            Map<String, Object> payload = new Map<String, Object>{
                'patient' => new Map<String, Object>{
                    'firstName' => req.Payer.FirstName,
                    'lastName'  => req.Payer.LastName,
                    'dob'       => String.valueOf(req.Payer.PersonBirthdate),
                    'gender'    => req.Payer.PersonGender
                },
                'insurance' => new Map<String, Object>{
                    'providerName' => req.MemberPlan.Payer.Name,
                    'policyNumber' => req.MemberPlan.Plan.PlanNumber,
                    'groupNumber'  => req.MemberPlan.GroupNumber,
                    'subscriberId' => req.MemberPlan.SubscriberId
                },
                'provider' => new Map<String, Object>{
                    'npi'        => req.ProviderId,
                    'firstName'  => req.Provider.FirstName,
                    'lastName'   => req.Provider.LastName
                },
               'service' => new Map<String, Object>{
                    'dateTo'    => req.MemberPlan.Plan.EffectiveTo,
                    'dateFrom'  => req.MemberPlan.Plan.EffectiveFrom,
                    'type'      => req.MemberPlan.Plan.ServiceType
                }
            };

            try {
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint('callout:InfinitusAPI/benefit-verification-request');
                httpReq.setMethod('POST');
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setBody(JSON.serialize(payload));

                Http http = new Http();
                HttpResponse res = http.send(httpReq);

                if (res.getStatusCode() == 200) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    update new CareBenefitVerifyRequest(
                        Id = req.Id,
                        Status = (String) result.get('status'),
                        StatusReason = (String) result.get('statusReason')
                    );
                } else {
                    logError(req.Id, res.getStatus(), null, res.getBody());
                }
            } catch (Exception e) {
                logError(req.Id, 'Exception', e.getMessage(), e.toString());
            }
        }
    }

    private void logError(Id reqId, String code, String message, String exceptionLog) {
        Intigration_Transaction_Error_Log__c errorLog = new Intigration_Transaction_Error_Log__c();
        errorLog.Request_Id__c = reqId;
        errorLog.Log__c = exceptionLog;
        errorLog.Error_Message__c = message;
        errorLog.Code__c = code;
        Insert errorLog;
    }
}