public class LeadStagingDTO {

public LeadStagingDTO() {

}
//     Explanation:

// Represents one record.

// Serializable to JSON for REST calls.

// Independent of Salesforce object schema — ensures future-proofing.
    public String Company;
    public String Description;
    public String Email;
    public String FirstName;
    public String LastName;
    public String Phone;
    public String Lead_Referrer;
    public String SourceSystemId;
    public String Website;
    public String Month_Key;

}