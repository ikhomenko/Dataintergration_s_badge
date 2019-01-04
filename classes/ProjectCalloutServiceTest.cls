@isTest
private class ProjectCalloutServiceTest {

  @TestSetup
  private static void setup() {
    Opportunity opp = new Opportunity(
            Name = 'Test opp',
            StageName = 'Closed Won',
            CloseDate = Date.today()
    );
    insert opp;
    ServiceTokens__c token = new ServiceTokens__c(
            Name = 'ProjectServiceToken',
            Token__c = 'ProjectServiceTokenForTest'
    );
    insert token;
  }

  @isTest
  private static void testFailure() {
    Opportunity opp = [SELECT Id, Name, StageName, CloseDate FROM Opportunity LIMIT 1];

    Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
      ProjectCalloutService.postOpportunityToPMS(new List<Id>{opp.Id});
    Test.stopTest();
    opp = [SELECT Id, Name, StageName, CloseDate FROM Opportunity LIMIT 1];
    System.assertEquals('Resubmit Project', opp.StageName);
  }

  @isTest
  private static void testSuccess() {
    Opportunity opp = [SELECT Id, Name, StageName, CloseDate FROM Opportunity LIMIT 1];

    Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
      ProjectCalloutService.postOpportunityToPMS(new List<Id>{opp.Id});
    Test.stopTest();
    opp = [SELECT Id, Name, StageName, CloseDate FROM Opportunity LIMIT 1];
    System.assertEquals('Submitted Project', opp.StageName);
  }
}