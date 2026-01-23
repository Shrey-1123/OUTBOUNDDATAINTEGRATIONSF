public with sharing class LeadChunkDispatcher implements Queueable {
    
    private static final Integer CHUNK_SIZE = 3000;
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

            
            for(Integer i = startIndex; i < endIndex; i++){
                Lead_Outbound_Staging__c outboundStage = outboundStages[i];
                outboundStage.Status__c = 'SENT';
                chunkIndex++;
                outboundStage.chunkNumber__c = String.valueOf(chunkIndex);
            }

        }

        if(!outboundStages.isEmpty()) {
            update outboundStages;
            System.enqueueJob(new LeadOutboundCalloutQueue(batchId));
        }

    }

}