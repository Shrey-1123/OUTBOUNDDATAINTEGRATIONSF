public with sharing class LeadBigObjectIterator implements Iterator<Lead_Staging__b>{
    
    private Integer currentIndex = 0;
    private List<Lead_Staging__b> leadRecords;

    public LeadBigObjectIterator(){
        leadRecords = [
            SELECT SourceSystemId1__c, Company__c, Description__c, Email__c, FirstName__c, LastName__c, Phone__c, Lead_Referrer__c, Website__c, Month_Key1__c FROM Lead_Staging__b WHERE Month_Key1__c = '2025-01' LIMIT 3000
        ];
    }

    public Boolean hasNext(){
        return currentIndex < leadRecords.size();
    }

    public Lead_Staging__b next(){
        if(!hasNext()){
            throw new System.NoSuchElementException('No more records to iterate.');
        }
        Lead_Staging__b record = leadRecords[currentIndex];
        currentIndex++;
        return record;
    }
}