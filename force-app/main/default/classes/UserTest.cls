@isTest
public class UserTest {


    public static User mockUserAdminWithRole() {
        User adminWithRole = new User(Id = UserInfo.getUserId());
        if(UserInfo.getUserRoleId() == null) {
            UserRole mockUserRole = new UserRole(Name = 'TestAdminUserRole');
            insert mockUserRole;
            adminWithRole.UserRoleID = mockUserRole.Id;
        } else {
            adminWithRole.UserRoleID = UserInfo.getUserRoleId();
        }

        System.runAs(adminWithRole) {
            update adminWithRole;
        }
        return adminWithRole;
    }

    public static User mockUser(String profileName) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        return mockUser(profile.Id);
    }

    public static User mockUser(Id profileId) {
        
        return mockUser('firstName', 'lastName', profileId);
    }

    public static User mockUser(String firstName, String lastName, Id profielId) {
        User mockUser = new User();
        mockUser.FirstName = firstName;
        mockUser.LastName = lastName;
        mockUser.ProfileId = profielId;
        mockUser.Username = firstName + '@spwg.com';
        mockUser.Email = firstName + '@mock.com';
        mockUser.EmailEncodingKey = 'UTF-8';
        mockUser.Alias = firstName.left(5);
        mockUser.CommunityNickname = firstname.left(5);
        mockUser.TimeZoneSidKey = 'Asia/Bangkok';
        mockUser.LanguageLocaleKey = 'en_US';
        mockUser.LocaleSidKey = 'en_GB';
        mockUser.Signature__c = 'signature';
        return mockUser;
    }

    @TestSetup
    static void preparedData(){
        TriggerActivation__c triggerActication = new TriggerActivation__c();
        // triggerActication.UserTrigger__c = true; // don't have User trigger yet
        insert triggerActication;
    }

    @isTest
    static void createAdminUser() {
        Test.startTest();
        User newAdminWithRole = mockUser('firstName', 'lastName', UserInfo.getProfileId());
        System.debug(newAdminWithRole);
        insert newAdminWithRole;
        Test.stopTest();
    }

    @isTest
    static void test_updateAdminUser() {
        Test.startTest();
        User adminWithRole = UserTest.mockUserAdminWithRole();
        Test.stopTest();
    }
}