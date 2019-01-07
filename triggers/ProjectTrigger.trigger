trigger ProjectTrigger on Project__c (after update) {

    for (Project__c project : Trigger.newMap.values()) {
        if (project.Status__c == 'Billable' && project.Status__c != Trigger.oldMap.get(project.Id).Status__c) {
            BillingCalloutService.callBillingService(project.Id);
        }
    }
}