public with sharing class LeadOutboundStagingBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public String query;
    
    public LeadOutboundStagingBatch() {
        this.query = 'SELECT SourceSystemId1__c, Company__c, Description__c, Email__c, FirstName__c, LastName__c, Phone__c, Lead_Referrer__c, Website__c, Month_Key1__c FROM Lead_Staging__b WHERE Month_Key1__c = \'2025-01\' ';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // INSERT lead integration batch record
        insert new Lead_Integration_Batch__c(Name = 'Lead Outbound Batch ' + Datetime.now().format(),Status__c = 'IN_PROGRESS',Batch_Id__c = BC.getJobId());
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead_Staging__b> scope) {
        List<Lead_Outbound_Staging__c> stages = new List<Lead_Outbound_Staging__c>();
        
        // Implement your processing logic here
        for(Lead_Staging__b lead : scope) {
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
        }
      
    }
    
    public void finish(Database.BatchableContext BC) {
        // Post-processing logic if needed
        System.enqueueJob(new LeadChunkDispatcher(BC.getJobId()));
    }

}