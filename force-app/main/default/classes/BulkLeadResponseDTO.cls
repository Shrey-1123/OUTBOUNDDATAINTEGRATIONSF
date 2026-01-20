public class BulkLeadResponseDTO {
//     Explanation:

// Returned from the receiver REST API.

// Lets sender know whether chunk was accepted or skipped.

    public String batchId;
    public Integer chunkNumber;
    public String chunkStatus; // NEW, INFLIGHT, COMPLETED, FAILED
    public Integer processedRecords;
    public Integer failedRecords;
    public List<String> errorMessages;
    public LeadSummaryDTO leadsummary;
    public List<LeadResultDTO> leadresults;   
}