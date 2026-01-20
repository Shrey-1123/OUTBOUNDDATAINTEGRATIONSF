public with sharing class LeadChunkDispatcher implements Queueable, Database.AllowsCallouts {
    
    private static final Integer CHUNK_SIZE = 1000;
    private String batchId;
    
    public LeadChunkDispatcher(String batchId) {
        this.batchId = batchId;
    }
    
    public void execute(QueueableContext context) {
        List<Lead_Outbound_Staging__c> outboundStages = [SELECT Id, Status__c, Payload_JSON__c FROM Lead_Outbound_Staging__c WHERE BatchId__c = :batchId AND Status__c = 'NEW' ORDER BY CreatedDate LIMIT :CHUNK_SIZE];
        Integer totalRecords = outboundStages.size();
        Integer totalChunks = (Integer)Math.ceil(totalRecords/ (Decimal)CHUNK_SIZE);

        for(Integer chunkIndex = 0 ; chunkIndex < totalChunks ;chunkIndex++){
            Integer startIndex = chunkIndex * CHUNK_SIZE;
            Integer endIndex = Math.min(startIndex + CHUNK_SIZE, totalRecords);

            List<LeadStagingDTO> leadDTOs = new List<LeadStagingDTO>();
            for(Integer i = startIndex; i < endIndex; i++){
                Lead_Outbound_Staging__c outboundStage = outboundStages[i];
                LeadStagingDTO leadDTO = (LeadStagingDTO)JSON.deserialize(outboundStage.Payload_JSON__c, LeadStagingDTO.class);
                leadDTOs.add(leadDTO);
                outboundStage.Status__c = 'SENT';
                chunkIndex++;
                outboundStage.chunkNumber__c = String.valueOf(chunkIndex);
            }

            BulkLeadRequestDTO bulkRequest = new BulkLeadRequestDTO();
            bulkRequest.batchId = batchId;
            bulkRequest.SourceSystemName = 'Salesforce Org A'; // later replace with domain name of org
            bulkRequest.leads = leadDTOs;
            String requestBody = JSON.serialize(bulkRequest);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://example.com/api/leads'); // Replace with actual endpoint
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);
            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                if(res.getStatusCode() == 200){
                    update outboundStages; // later optimize to update only processed records because 200 does not mean all fields of this leads were accepted
                } else {
                    // Handle non-200 responses
                    System.debug('Error response: ' + res.getBody());   
                }
            } catch (Exception e) {
                // Handle exceptions
                System.debug('Error: ' + e.getMessage());
            }
        }

    }

}