public class BillingCalloutService {

    @future(callout=true)
    public static void callBillingService(String projectId) {

        List<Project__c> projects = [
                SELECT Id
                FROM Project__c
                WHERE Id = :projectId AND ProjectRef__c <> null AND Billable_Amount__c <> null
        ];
        if (projects.isEmpty()) {
            return;
        }
        Project__c project = projects.get(0);

        BillingServiceProxy.project soapProject = new BillingServiceProxy.project();
            soapProject.projectid = project.ProjectRef__c;
            soapProject.billAmount = project.Billable_Amount__c;
            soapProject.username = ServiceCredentials__c.getinstance('BillingServiceCredential').Username__c;
            soapProject.password = ServiceCredentials__c.getinstance('BillingServiceCredential').Password__c;

        BillingServiceProxy.InvoicesPortSoap11 portSOAP = new BillingServiceProxy.InvoicesPortSoap11();
        String response = portSOAP.billProject(soapProject);

        if (response == 'OK') {
            project.Status__c = 'Billed';
            update project;
        }
    }
}