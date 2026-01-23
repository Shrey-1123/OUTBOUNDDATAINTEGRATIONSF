public with sharing class LeadOutboundStagingBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    
    public Iterable<Lead_Staging__b> start(Database.BatchableContext BC) {
        // INSERT lead integration batch record
        
        return new LeadBigObjectIterable();
    }
    
    public void execute(Database.BatchableContext BC, List<Lead_Staging__b> scope) {
        List<Lead_Outbound_Staging__c> stages = new List<Lead_Outbound_Staging__c>();
        List<String> sourcesystemids = new List<String>();
        for(Lead_Staging__b lead : scope) {
            sourcesystemids.add(lead.SourceSystemId1__c);
        }
        List<Lead_Outbound_Staging__c> existingStages = [SELECT Source_Lead_Id__c FROM Lead_Outbound_Staging__c WHERE Source_Lead_Id__c IN :sourcesystemids];
        Set<String> existingSourceIds = new Set<String>();
        for(Lead_Outbound_Staging__c stage : existingStages) {
            existingSourceIds.add(stage.Source_Lead_Id__c);
        }
        // Implement your processing logic here
        for(Lead_Staging__b lead : scope) {
            if(existingSourceIds.contains(lead.SourceSystemId1__c)) {
                continue; // Skip if already exists
            }
            LeadStagingDTO leadDTO = new LeadStagingDTO();
            leadDTO.Company = lead.Company__c;
            leadDTO.Description = lead.Description__c;
            leadDTO.Email = lead.Email__c;
            leadDTO.FirstName = lead.FirstName__c;
            leadDTO.LastName = lead.LastName__c;
            leadDTO.Phone = lead.Phone__c;
            leadDTO.Lead_Referrer = lead.Lead_Referrer__c;
            leadDTO.SourceSystemId = lead.SourceSystemId1__c;
            leadDTO.Website = lead.Website__c;
            leadDTO.Month_Key = lead.Month_Key1__c;
            
            Lead_Outbound_Staging__c outboundStage = new Lead_Outbound_Staging__c();
            outboundStage.Source_Lead_Id__c = leadDTO.SourceSystemId;
            outboundStage.BatchId__c = BC.getJobId();
            outboundStage.Status__c = 'NEW';
            outboundStage.Payload_JSON__c = JSON.serialize(leadDTO);
            stages.add(outboundStage);
        }
        
        if(!stages.isEmpty()) {
            insert stages;
            System.debug('Inserted ' + stages.size() + ' Lead_Outbound_Staging__c records.');
        }
      
    }
    
    public void finish(Database.BatchableContext BC) {
        // Post-processing logic if needed
        
        insert new Lead_Integration_Batch__c(Name = 'Lead Outbound Batch ' + Datetime.now().format(),Status__c = 'IN_PROGRESS',Batch_Id__c = BC.getJobId());
        System.debug('LeadOutboundStagingBatch finished with Job ID: ' + BC.getJobId());
        System.enqueueJob(new LeadChunkDispatcher(BC.getJobId()));
    }

}