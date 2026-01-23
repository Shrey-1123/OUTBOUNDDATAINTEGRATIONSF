public with sharing class LeadOutboundCalloutQueue implements Queueable, Database.AllowsCallouts {

    private static final Integer CHUNK_SIZE = 5000;
    private String batchId;
    public LeadOutboundCalloutQueue(String batchId) {
        this.batchId = batchId;
    }

    public void execute(QueueableContext context) {
        List<Lead_Outbound_Staging__c> outboundStages = [SELECT Id, Status__c, Payload_JSON__c FROM Lead_Outbound_Staging__c WHERE BatchId__c = :batchId AND (Status__c = 'NEW' OR Status__c = 'SENT') ORDER BY CreatedDate LIMIT :CHUNK_SIZE];
        System.debug('Outbound Stages size: ' + outboundStages.size());
        List<LeadStagingDTO> leadDTOs = new List<LeadStagingDTO>();
        for(Lead_Outbound_Staging__c stage : outboundStages){
            LeadStagingDTO leadDTO = (LeadStagingDTO)JSON.deserialize(stage.Payload_JSON__c, LeadStagingDTO.class);
            leadDTOs.add(leadDTO);
        }
        System.debug('leadsDTO size: ' + leadDTOs.size());

           BulkLeadRequestDTO bulkRequest = new BulkLeadRequestDTO();
            bulkRequest.batchId = batchId;
            bulkRequest.SourceSystemName = 'Salesforce Org A'; // later replace with domain name of org
            bulkRequest.leads = leadDTOs;
            bulkRequest.totalChunks = (Integer)Math.ceil((Decimal)outboundStages.size() / CHUNK_SIZE);
            String requestBody = JSON.serialize(bulkRequest);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:My_JWT_Service/services/apexrest/lead/bulk'); // Replace with actual endpoint
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);
            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                if(res.getStatusCode() == 200){
                    System.debug('Response'+ res.getStatusCode());
                  //  BulkLeadResponseDTO responseDTO = (BulkLeadResponseDTO)JSON.deserialize(res.getBody(), BulkLeadResponseDTO.class);
                  //  System.debug('Response DTO'+ responseDTO.leadresults.size());
                    //update outboundStages; // NEVER DO DML in same transanction on callout
                   // System.enqueueJob(new LeadAckProcessorQueue(responseDTO));
                } else {
                    // Handle non-200 responses
                    System.debug('Error response: ' + res.getStatusCode());   
                }
            } catch (Exception e) {
                // Handle exceptions
                System.debug('Error: ' + e.getMessage());
            }
    }
}