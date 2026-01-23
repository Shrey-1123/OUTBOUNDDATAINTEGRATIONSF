public with sharing class LeadBigObjectIterable implements Iterable<Lead_Staging__b> {
    
    public Iterator<Lead_Staging__b> iterator() {
        return new LeadBigObjectIterator();
    }
}