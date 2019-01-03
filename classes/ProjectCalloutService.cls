public class ProjectCalloutService {

    @InvocableMethod
	public static void postOpportunityToPMS(List<Id> oppIds){
        if (!oppIds.isEmpty()) {
            postOpportunitiesToPMS(oppIds);
        }
    }

    @future(callout=true)
    public static void postOpportunitiesToPMS(List<Id> oppIds) {
        Opportunity opp = [
                SELECT Id, Name, Account.Name, CloseDate, Amount
                FROM Opportunity
                WHERE Id IN :oppIds
                LIMIT 1
        ];
        if(opp == null) return ;

        HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ProjectService');
            request.setMethod('POST');
            request.setHeader('token', ServiceTokens__c.getInstance('ProjectServiceToken').Token__c);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(JSON.serialize(new OppModel(opp)));

        HttpResponse response = new Http().send(request);
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