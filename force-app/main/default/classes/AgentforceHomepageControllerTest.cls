@isTest
public class AgentforceHomepageControllerTest {
    @testSetup
    static void setupData() {
        // Insert a test document that will be found by the controller
        Document doc = new Document(
            Name = 'agentforceHomepageBanner1',
            Body = Blob.valueOf('Test body'),
            ContentType = 'image/png',
            Type = 'png',
            FolderId = UserInfo.getUserId(), // User's default folder for documents
            IsPublic = true
        );
        insert doc;
    }
    
    @isTest
    static void testGetAgentforceBannerUrl_Found() {
        // Test the scenario where the Document is found
        Test.startTest();
        String result = AgentforceHomepageController.getAgentforceBannerUrl(1);
        Test.stopTest();
        System.assertNotEquals(null, result, 'URL should be returned when document is found');
        System.assert(result.contains('/servlet/servlet.ImageServer'), 'URL should use servlet.ImageServer path');
    }
    
    @isTest
    static void testGetAgentforceBannerUrl_NotFound() {
        // Test the scenario where the Document is not found
        Test.startTest();
        String result = AgentforceHomepageController.getAgentforceBannerUrl(999); // unlikely index
        Test.stopTest();
        System.assertEquals(null, result, 'Should return null if Document is not found');
    }

    @isTest
    static void testGetAgentforceBannerUrl_ZeroIndex() {
        // Also covers index==0 (should use name without number suffix)
        Document doc = new Document(
            Name = 'agentforceHomepageBanner',
            Body = Blob.valueOf('Test body'),
            ContentType = 'image/png',
            Type = 'png',
            FolderId = UserInfo.getUserId(),
            IsPublic = true
        );
        insert doc;
        
        Test.startTest();
        String result = AgentforceHomepageController.getAgentforceBannerUrl(0);
        Test.stopTest();
        System.assertNotEquals(null, result, 'URL should be returned for index 0 if Document exists');
    }

}
