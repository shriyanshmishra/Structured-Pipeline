@isTest
private class AgentforceHomepageControllerTest {
    @isTest static void testGetAgentforceBannerUrl() {
        // Optionally create test data here if needed

        // Call the method with a sample index
        String result = AgentforceHomepageController.getAgentforceBannerUrl(1);

        // Assert to verify the return is as expected (or not null)
        System.assertNotEquals(null, result, 'Banner URL should not be null');
    }
}
