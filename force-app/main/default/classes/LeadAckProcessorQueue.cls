public with sharing class LeadAckProcessorQueue implements Queueable,Database.AllowsCallouts {
    
    BulkLeadResponseDTO responseDTO;

    public LeadAckProcessorQueue(){}
    public LeadAckProcessorQueue(BulkLeadResponseDTO responseDTO){
        this.responseDTO = responseDTO;
    }

    public void execute(QueueableContext context){
        Set<String> sourceLeadIds = new Set<String>();
        for(LeadResultDTO result : responseDTO.leadresults){
            sourceLeadIds.add(result.SourceSystemId);
        }
        List<Lead_Outbound_Staging__c> stagesToUpdate = [SELECT 
            Id, 
            Status__c,
            BatchId__c,
            Source_Lead_Id__c
            FROM Lead_Outbound_Staging__c 
            WHERE BatchId__c = :responseDTO.batchId 
            AND ( Status__c = 'SENT' OR Status__c = 'NEW' )
            AND Source_Lead_Id__c IN :sourceLeadIds];

        Map<String,LeadResultDTO> resultMap = new Map<String,LeadResultDTO>();
        for(LeadResultDTO result : responseDTO.leadresults){
            resultMap.put(result.SourceSystemId, result);
        }

        for(Lead_Outbound_Staging__c stage : stagesToUpdate){
            LeadResultDTO result = resultMap.get(stage.Source_Lead_Id__c);
            if(result != null){
                if(result.Status == 'SUCCESS'){
                    stage.Status__c = 'ACKED';
                } else {
                    stage.Status__c = 'FAILED';
                }
            }
        }

        update stagesToUpdate;

        
    }
}