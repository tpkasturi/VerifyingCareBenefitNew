public class CareBenefitVerifyRequestTriggerHandler {
    public static void handleAfterInsert(List<CareBenefitVerifyRequest> requests) {
        System.enqueueJob(new CareBenefitRequestQueueable(requests));
    }
}