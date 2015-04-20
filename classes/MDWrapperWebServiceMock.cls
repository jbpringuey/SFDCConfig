@isTest                        
global class MDWrapperWebServiceMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           if(responseType == 'MetadataService.listMetadataResponse_element'){
               response.put('response_x', new MetadataService.listMetadataResponse_element()); 
           }
           
           if(responseType == 'MetadataService.updateMetadataResponse_element'){
               response.put('response_x', new MetadataService.updateMetadataResponse_element()); 
           }
   }
}