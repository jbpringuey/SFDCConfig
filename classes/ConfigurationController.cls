/**
 * Generic controller class to handle custom metadata records used for configurations.
 */

public class ConfigurationController {
  
    MetadataService.MetadataPort service;
    
    //Configurations currently rendered indexed by TabIndex__c rendered in the UI
    public Map<String,SObject> configurations {get;set;}
    
    //Configuration name indexed by tab
    public Map<String,String>  configurationNameByTab {get;set;}

    //Map of available configurations in the applications that will be rendered in VF indexed by the QualifiedApiName
    public Map<string,Set<string>> customMetadata;

    //Maps of available options based on configurations displayed
    public Map<string,List<SelectOption>> selectLists {get;set;}
    
    public static String QUALIFIED_API_NAME_ATTRIBUTE= 'QualifiedApiName';
    public static String MASTER_LABEL_ATTRIBUTE= 'MasterLabel';
    
    public ConfigurationController() {
    	//Initializing the metadata service api
        service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
     
        configurations = new Map<string,SObject>();
        customMetadata = new Map<string,Set<string>>();
        configurationNameByTab = new Map<string,string>();
        selectLists = new Map<string,List<SelectOption>>();
        
        //loading all custom metadata available in the system
        loadCustomMetadataMetadata();

        //Adding select lists. Replace the code below by your configuration with picklist values
        ConfigurationCustomMetadata.addSelectLists(selectLists);

        //loading values the db
        loadCustomMetadataValues();
        
        idPanelCurrent = '0';
    }
    
/**
  * Dynamic SOQL to query custom metadata values for each custom metadata
  */
    private void loadCustomMetadataValues(){    
    	for (String entityName : customMetadata.keySet()){
	        String configurationQuery = 'select ';
	        Boolean isFirstLoop = true; 
	        for (String fieldName : customMetadata.get(entityName)) {
	            if(isFirstLoop){
	                isFirstLoop = false;    
	            }else{
	                configurationQuery = configurationQuery+',';    
	            }
	            configurationQuery = configurationQuery+fieldName;
	        }
            configurationQuery = configurationQuery+' from '+ entityName;
            Sobject configuration = Database.query(configurationQuery);
            //workaround to number formatting
            string tabIndex = String.valueOf(integer.valueof(String.valueOf(configuration.get('TabIndex__c'))));
            configurations.put(tabIndex,configuration);
            configurationNameByTab.put(tabIndex,entityName);
    	}
    }

/**
  * Queries to find all custom metadata metadata of the application and make it available to the VF page
  */
    private void loadCustomMetadataMetadata(){
        List<SObject> entityDefinitions =[select QualifiedApiName from EntityDefinition where IsCustomizable =true];
        for(SObject entityDefinition : entityDefinitions){
            string entityQualifiedApiName = (string)entityDefinition.get(QUALIFIED_API_NAME_ATTRIBUTE);
            if(entityQualifiedApiName.endsWith('__mdt')){
                List<SObject> fieldDefinitions =[select QualifiedApiName from FieldDefinition where EntityDefinition.QualifiedApiName =:entityQualifiedApiName];
                Set<string> attributes = new Set<string>();
                for(SObject fieldDefinition : fieldDefinitions){
                    string fieldQualifiedApiName = (string)fieldDefinition.get(QUALIFIED_API_NAME_ATTRIBUTE);
                    if(fieldQualifiedApiName.endsWith('__c')){
                        attributes.add(fieldQualifiedApiName);
                    }
                }
                attributes.add(QUALIFIED_API_NAME_ATTRIBUTE);
                attributes.add(MASTER_LABEL_ATTRIBUTE);
                customMetadata.put(entityQualifiedApiName,attributes);
            }
        }
    }
        
    public PageReference save() {
        ApexPages.getMessages().clear();
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] {
                 transformToCustomMetadata(
                 configurationNameByTab.get(idPanelCurrent).replace('__mdt','.')+(string)configurations.get(idPanelCurrent).get(QUALIFIED_API_NAME_ATTRIBUTE),
                 configurations.get(idPanelCurrent),
                 customMetadata.get(configurationNameByTab.get(idPanelCurrent))) 
        });
        if(results!=null){
            for(MetadataService.SaveResult saveResult : results){
                if(saveResult==null || saveResult.success){
                     continue;
                }
                // Construct error message and throw an exception
                if(saveResult.errors!=null){
                    List<String> messages = new List<String>();
                    messages.add(
                        (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 
                            'occured processing component ' + saveResult.fullName + '.');
                    for(MetadataService.Error error : saveResult.errors){
                        messages.add(error.message + ' (' + error.statusCode + ').' + ( error.fields!=null && error.fields.size()>0 ? ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
                    }
                    if(messages.size()>0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.join(messages, ' ')));
                    }
                }
                if(!saveResult.success){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Request failed with no specified error.'));
                }
            }
        }

        return null;
    }
    
/*
 * Transformation utility to turn the configuration values into custom metadata values
 * This method to modify Metadata is only approved for Custom Metadata Records. Note that the number of custom metadata 
 * values which can be passed in one update has been increased to 200 values (just for custom metadata)
 * We recommend to create new type if more fields are needed.
 * Using https://github.com/financialforcedev/apex-mdapi
 */
    private MetadataService.CustomMetadata transformToCustomMetadata(String name, SObject config,Set<String> fieldNames){
        MetadataService.CustomMetadata  customMetadata = new MetadataService.CustomMetadata();
        customMetadata.label = (String)config.get(MASTER_LABEL_ATTRIBUTE);
        customMetadata.fullName = name;
        MetadataService.CustomMetadataValue[] customMetadataValues = new List<MetadataService.CustomMetadataValue>();
        if(fieldNames!=null){
	        for (String fieldName : fieldNames) {
	            if(!QUALIFIED_API_NAME_ATTRIBUTE.equals(fieldName) && !MASTER_LABEL_ATTRIBUTE.equals(fieldName)){
	                MetadataService.CustomMetadataValue cmRecordValue = new MetadataService.CustomMetadataValue();
	                cmRecordValue.field=fieldName;
	                cmRecordValue.value= String.valueOf(config.get(fieldName));
	                customMetadataValues.add(cmRecordValue);
	            }
	        }
        }
        customMetadata.values = customMetadataValues;
        return customMetadata;
    }


/**
* Used to remember what panel is selected on the client side so that the right pane is rendered after save
*/
    
    public string idPanelCurrent { get; set; }
    
    public void setPanelCurrent(){
    	idPanelCurrent = Apexpages.currentPage().getParameters().get('idPanel');
    }
    

/**
* Helper to handle adding remote site programatically the first time the admin user navigate to the screen inspired from 
* http://andyinthecloud.com/2014/07/29/post-install-apex-metadata-api-configuration-solved/ 
*/

    public String Host {get;set;}
    
    public String MetadataResponse {get;set;}
 
    public Boolean MetadataConnectionWarning {get;set;}
        
    public PageReference checkMetadataAPIConnection(){
        Host = ApexPages.currentPage().getHeaders().get('Host');
        MetadataConnectionWarning = false;
        try {
            List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
            remoteSites.type_x = 'RemoteSiteSetting';
            queries.add(remoteSites);
            service.listMetadata(queries, 34);
        } catch (System.CalloutException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to connect to the Salesforce Metadata API.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'A Remote Site Setting must be created in your org before you can use this tool.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Press the Create Remote Site Setting button to perform this step or refer to the post install step below to perform this manually.'));

            MetadataConnectionWarning = true;
        }
        return null;
    }
    
    public PageReference displayMetadataResponse(){
            if(metadataResponse !=null && metadataResponse.length()==0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Remote Site Setting config_mdapi has been created.' ));
                MetadataConnectionWarning = false;
            }else if( metadataResponse !=null ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, metadataResponse));
                MetadataConnectionWarning = true;
            }
            return null;
    } 
    
}