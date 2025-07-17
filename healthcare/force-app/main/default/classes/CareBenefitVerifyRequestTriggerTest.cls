@IsTest
public class CareBenefitVerifyRequestTriggerTest {
    public static String planId;
    public static String providerId;
    public static String patientId;
    
    @TestSetup
    static void setupData() {        
        Account patient = new Account(
            FirstName = 'John', LastName = 'Doe',
            PersonBirthdate = Date.newInstance(1990, 1, 1),
            PersonGender = 'M'
        );
        insert patient;
        patientId = patient.Id;

        Account provider = new Account(
            FirstName = 'Dr', LastName = 'Smith'
        );
        insert provider;
        providerId = provider.Id;
        
        PurchaserPlan plan = new PurchaserPlan(Name = 'Test Plan', PlanNumber = 'PN12345', ServiceType= 'surgery', PayerId = patient.Id);
        insert plan;

        MemberPlan memberPlan = new MemberPlan(
            PayerId =  patient.Id,
            GroupNumber = 'GR456',
            SubscriberId = provider.Id,
            planId = plan.Id,
            MemberId = patient.Id,
            Name = 'MYPLAN'
        );
        insert memberPlan;
        planId = memberPlan.Id;
    }

    @IsTest
    static void testCalloutWithMock() {
        Test.setMock(HttpCalloutMock.class, new MockBenefitVerificationCallout());
        MemberPlan memberPlan = [SELECT Id FROM MemberPlan LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE LastName = 'Doe' LIMIT 1];
        Account provider = [SELECT Id FROM Account WHERE LastName = 'Smith' LIMIT 1];
        
        Test.startTest();
        CareBenefitVerifyRequest request = new CareBenefitVerifyRequest(
            PayerId = patient.Id,
            ProviderId = provider.Id,
            MemberPlanId = memberPlan.Id
        );
        insert request;
        Test.stopTest();
        
        CareBenefitVerifyRequest updatedReq = [SELECT Id, Status, StatusReason FROM CareBenefitVerifyRequest LIMIT 1];
        System.assertEquals('Acknowledged', updatedReq.Status);
        System.assert(updatedReq.StatusReason.contains('successfully sent'));
    }
    
    @IsTest
    static void testCalloutWithMockBad() {
        Test.setMock(HttpCalloutMock.class, new MockBenefitVerificationCallout400());
        MemberPlan memberPlan = [SELECT Id FROM MemberPlan LIMIT 1];
        Account patient = [SELECT Id FROM Account WHERE LastName = 'Doe' LIMIT 1];
        Account provider = [SELECT Id FROM Account WHERE LastName = 'Smith' LIMIT 1];
        
        Test.startTest();
        CareBenefitVerifyRequest request = new CareBenefitVerifyRequest(
            PayerId = patient.Id,
            ProviderId = provider.Id,
            MemberPlanId = memberPlan.Id
        );
        insert request;
        Test.stopTest();
        
        CareBenefitVerifyRequest updatedReq = [SELECT Id, Status, StatusReason FROM CareBenefitVerifyRequest LIMIT 1];
        System.assertEquals(null, updatedReq.Status);
    }
}