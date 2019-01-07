@isTest
private class ProjectRESTServiceTest {

    private static final String NEW_PROJECT_EXT_REF = 'anotherProjectTestRef';
    private static final String NEW_PROJECT_NAME = 'New test Project';
    private static final String PREDEFINED_PROJECT_REF = 'extTestId';
    private static final String PREDEFINED_PROJECT_NAME = 'Just a test project';
    private static final String PROJECT_STATUS = 'Running';

  @TestSetup
  static void setup() {
    Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
    );
    insert opp;

    Project__c project = new Project__c();
      project.ProjectRef__c = PREDEFINED_PROJECT_REF;
      project.Name = PREDEFINED_PROJECT_NAME;
      project.Opportunity__c = opp.Id;
    insert project;
  }

  @isTest
  static void testPost() {
      Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
      Test.startTest();
            //create test project
            String response = ProjectRESTService.postProjectData(NEW_PROJECT_EXT_REF, NEW_PROJECT_NAME, opp.Id, Date.today(),
                                                                  Date.today().addDays(1), 1000, PROJECT_STATUS);
            System.assertEquals('OK', response);

            //update test project
            response = ProjectRESTService.postProjectData(PREDEFINED_PROJECT_REF, PREDEFINED_PROJECT_NAME, opp.Id, Date.today(),
                                                            Date.today().addDays(1), 1000, PROJECT_STATUS);
            System.assertEquals('OK', response);

            //fault
            response = ProjectRESTService.postProjectData(PREDEFINED_PROJECT_REF, PREDEFINED_PROJECT_NAME, '006000000012345', Date.today(),
                  Date.today().addDays(1), 1000, PROJECT_STATUS);
      
            System.assertNotEquals('OK', response);
      Test.stopTest();
  }
}