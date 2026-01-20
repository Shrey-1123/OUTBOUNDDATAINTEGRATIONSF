public with sharing class LeadBatchUtil {
   // Returns batch number for the given Batch Id

   public static Integer getBatchNumber(String batchId){
    
     // try to find existing batch record
     List<Lead_Integration_Batch__c> batches = [SELECT Id,Batch_Number__c FROM Lead_Integration_Batch__c WHERE Batch_Id__c = :batchId LIMIT 1];
        if(!batches.isEmpty()){
            return INTEGER.valueOf(batches[0].Batch_Number__c);
        }
    // find last completed batch number and increment by 1
     Integer lastBatchNumber = 0;
     List<Lead_Integration_Batch__c> lastBatches = [SELECT Batch_Number__c FROM Lead_Integration_Batch__c WHERE Status__c = 'COMPLETED' ORDER BY Batch_Number__c DESC LIMIT 1];
        if(!lastBatches.isEmpty()){
            lastBatchNumber = INTEGER.valueOf(lastBatches[0].Batch_Number__c);
        
        }
        Lead_Integration_Batch__c newBatch = new Lead_Integration_Batch__c();
        newBatch.Batch_Id__c = batchId;
        lastBatchNumber++;
        newBatch.Batch_Number__c = String.valueOf(lastBatchNumber);
        newBatch.Status__c = 'IN_PROGRESS';
        insert newBatch;

        return Integer.valueOf(newBatch.Batch_Number__c);
   }

   public static void updateBatchCompleted(String batchId){

    Lead_Integration_Batch__c batch = [SELECT Id,Status__c FROM Lead_Integration_Batch__c WHERE Batch_Id__c = :batchId LIMIT 1];
    batch.Status__c = 'COMPLETED';
    update batch;
   }
}