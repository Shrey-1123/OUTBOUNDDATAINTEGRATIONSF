@RestResource(urlMapping='/lead/ack')
global with sharing class LeadAckInboundService {
    
    @HttpPost
    global static void receiveLeadAck(){
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        System.debug('Received Lead Ack Request Body: ' + requestBody);
        
        BulkLeadResponseDTO responseDTO = (BulkLeadResponseDTO)JSON.deserialize(requestBody, BulkLeadResponseDTO.class);
        System.debug('Deserialized BulkLeadResponseDTO with batchId: ' + responseDTO.batchId);
        
        // Enqueue the processing job
        System.enqueueJob(new LeadAckProcessorQueue(responseDTO));
    }
}