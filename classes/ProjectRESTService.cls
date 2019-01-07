@RestResource(urlMapping='/project/*')
global class ProjectRESTService {

    @HttpPost
    global static String postProjectData(String projectRef, String projectName, String opportunityId, Date startDate,
                                         Date endDate, Double amount, String status) {

        Opportunity opp = new Opportunity();
            opp.Id = opportunityId;
            opp.DeliveryInstallationStatus__c = 'In Progress';

        List<Project__c> projects = [SELECT Id FROM Project__c WHERE ProjectRef__c = :projectRef];
        Project__c project = projects.size() == 0 ? new Project__c() : projects.get(0);
            project.ProjectRef__c      = projectRef;
            project.Name               = projectName;
            project.Start_Date__c      = startDate;
            project.End_Date__c        = endDate;
            project.Billable_Amount__c = amount;
            project.Status__c          = status;
        if (projects.size() == 0) {
            project.Opportunity__c     = opportunityId;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            update opp;
            upsert project;
            return 'OK';
        } catch (Exception e) {
            Database.rollback(sp);
            return e.getMessage();
        }
    }
}