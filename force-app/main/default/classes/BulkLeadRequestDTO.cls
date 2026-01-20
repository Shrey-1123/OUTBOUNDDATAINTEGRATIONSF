public class BulkLeadRequestDTO {
    public BulkLeadRequestDTO() {

    }

//     Explanation:

// Represents a chunk of up to 200 records.

// The unit of async processing.

// Maintains metadata like requestId and chunkNumber for idempotency.

    public String batchId;
    public String SourceSystemName; // optional: salesforce org name
    public Integer chunkNumber;    // 1..N, just for logging
    public Integer totalChunks;    // Optional: for monitoring
    public List<LeadStagingDTO> leads;  // Max 200 per chunk
}