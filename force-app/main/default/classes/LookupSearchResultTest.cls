@isTest
private class LookupSearchResultTest {
    
    @isTest static void test_GetFunction() {
        Id id = null;
        String sObjectType = 'sObjectType'; 
        String icon = 'icon'; 
        String title = 'title'; 
        String subtitle = 'subtitle'; 

        Test.startTest();
            LookupSearchResult targetResult = new LookupSearchResult(id, sObjectType, icon, title, subtitle) ;

            System.assertEquals(null, targetResult.getId());
            System.assertEquals(sObjectType, targetResult.getSObjectType());
            System.assertEquals(icon, targetResult.getIcon());
            System.assertEquals(title, targetResult.getTitle());
            System.assertEquals(subtitle, targetResult.getSubtitle());
        Test.stopTest();
    }

    @isTest static void test_CompareTo() {
        Id id = null;
        String sObjectType = 'sObjectType'; 
        String icon = 'icon'; 
        String title = 'title'; 
        String subtitle = 'subtitle'; 

        Test.startTest();
            LookupSearchResult targetResult = new LookupSearchResult(id, sObjectType, icon, title, subtitle) ;
            LookupSearchResult targetResult2 = new LookupSearchResult(id, sObjectType, icon, 'title2', subtitle) ;

            System.assertEquals(1, targetResult2.compareTo(targetResult));
        Test.stopTest();
    }

    @isTest static void test_CompareTo2() {
        Id id = null;
        String sObjectType = 'sObjectType'; 
        String icon = 'icon'; 
        String title = null; 
        String subtitle = 'subtitle'; 

        Test.startTest();
            LookupSearchResult targetResult = new LookupSearchResult(id, sObjectType, icon, title, subtitle) ;
            LookupSearchResult targetResult2 = new LookupSearchResult(id, sObjectType, icon, 'title2', subtitle) ;

            System.assertEquals(-1, targetResult2.compareTo(targetResult));
        Test.stopTest();
    }

}