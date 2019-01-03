public class ProjectCalloutService {

    @InvocableMethod
	public static void postOpportunityToPMS(List<Id> oppIds){
        if (!oppIds.isEmpty()) {
            System.enqueueJob(new QueueablePMSCall(oppIds.get(0)));
        }
    }

    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {

        private Id oppId;

        public QueueablePMSCall(Id oppId) {
            this.oppId = oppId;
        }
        public void execute(System.QueueableContext qc) {
            List<Opportunity> opportunities = [
                    SELECT Id, Name, Account.Name, CloseDate, Amount
                    FROM Opportunity
                    WHERE Id = :oppId
            ];
            if(opportunities.isEmpty()) return ;
            Opportunity opp = opportunities.get(0);

            HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:ProjectService');
                request.setMethod('POST');
                request.setHeader('token', ServiceTokens__c.getInstance('ProjectServiceToken').Token__c);
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setBody(JSON.serialize(new OppModel(opp)));

            HttpResponse response = new Http().send(request);

            opp.StageName = response.getStatusCode() == 201 ? 'Submitted Project' : 'Resubmit Project';
            update opp;
        }
    }

    public class OppModel {
        String opportunityId;
        String opportunityName;
        String accountName;
        Date closeDate;
        Decimal amount;

        public OppModel(Opportunity opp) {
            opportunityId   = opp.Id;
            opportunityName = opp.Name;
            accountName     = opp.Account.Name;
            closeDate       = opp.CloseDate;
            amount          = opp.Amount;
        }
    }
}