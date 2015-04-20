/**
* SeeAllData=true is a workaround for seeing data in EntityDefinition. 
* If you only need to read Custom Metadata, you would not need this.
**/

@IsTest(SeeAllData=true)
public class ConfigurationControllerTest {

    public static testmethod void testDisplay() {
        
        Test.setMock(WebServiceMock.class, new MDWrapperWebServiceMock());
        Test.setCurrentPage(Page.Configuration);
        ConfigurationController controller = new ConfigurationController();
        System.assert(controller.configurations.get('0').get('Vertical__c')!=null);
        controller.checkMetadataAPIConnection();
        controller.displayMetadataResponse();
        controller.save();
    }
}