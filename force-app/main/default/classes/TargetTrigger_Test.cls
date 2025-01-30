@isTest
public with sharing class TargetTrigger_Test {
    @TestSetup
    static void setupData(){
        TriggerActivation__c customSetting = new TriggerActivation__c(TargetTrigger__c = true);
        insert(customSetting);

        Datetime todayDate = Datetime.now();
        String month = todayDate.formatGmt('MMM').toUpperCase();
        String year = todayDate.formatGmt('yyyy');

        Branch__c branch = new Branch__c (
        	Name = 'Design Village บางนา',
            Branch_Code__c = 'DVB'
        );
        insert branch;

        Building__c building = new Building__c (
            Name = 'Design Village - บางนา_A',
            Building_Name_TH__c = 'ดีไซน์ วิลเลจ บางนา',
            Building_Abbreviated__c = 'A',
            Active__c = false,
            Branch__c = branch.Id
        );
        insert building;

        String category;
        Map<String, sObjectField> objectResult = Schema.getGlobalDescribe().get('Target__c').getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = objectResult.get('Category__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if (ple.size() > 0) {
            category = ple.get(0).getValue();
        }

        String branchPrefix;
        String buildingPrefix;
        String categoryPrefix;
        String categoryBuildingPrefix;
        List<Roll_up_by_Branch__mdt> rollUpBranchMdt = Roll_up_by_Branch__mdt.getAll().values();
        for (Roll_up_by_Branch__mdt rollUpByBranchItem : rollUpBranchMdt) {
            if (branch.Name == rollUpByBranchItem.Branch_Name__c && building.Name == rollUpByBranchItem.Building_Name__c && rollUpByBranchItem.Is_Active__c == true) {
                branchPrefix = rollUpByBranchItem.Prefix_Branch__c;
                buildingPrefix = rollUpByBranchItem.Prefix_Branch_Building__c;
            }
        }

        List<Roll_up_by_Category__mdt> rollUpCategoryMdt = Roll_up_by_Category__mdt.getAll().values();
        for (Roll_up_by_Category__mdt rollUpCategoryItem : rollUpCategoryMdt) {
            if (category == rollUpCategoryItem.Category__c && rollUpCategoryItem.Is_Active__c == true) {
                categoryPrefix = rollUpCategoryItem.Prefix_Category__c;
            }
            if (category == rollUpCategoryItem.Category__c && branch.Name == rollUpCategoryItem.Branch_Name__c && rollUpCategoryItem.Is_Active__c == true) {
                categoryBuildingPrefix = rollUpCategoryItem.Prefix_Branch_Category__c;
            }
        }

        String branchExt = branchPrefix+month+'_'+year;
        Roll_up_Area_Branch__c rollupBranch = new Roll_up_Area_Branch__c();
        rollupBranch.Month__c = month;
        rollupBranch.Year__c = year;
        rollupBranch.Name = branchExt;
        rollupBranch.External_Id__c = branchExt;
        rollupBranch.Branch__c = branch.Id;
        insert(rollupBranch);

        String buildingExt = buildingPrefix+month+'_'+year;
        Roll_up_Area_Building__c rollupBuilding = new  Roll_up_Area_Building__c();
        rollupBuilding.Month__c = month;
        rollupBuilding.Year__c = year;
        rollupBuilding.Name = buildingExt;
        rollupBuilding.External_Id__c = buildingExt;
        rollupBuilding.Branch__c = building.Branch__c;
        rollupBuilding.Building__c = building.Id;
        rollupBuilding.Roll_up_Area_Branch__c = rollupBranch.Id;
        insert(rollupBuilding);

        String categoryExt = categoryPrefix+month+'_'+year;
        Roll_up_Category__c rollupCategory = new Roll_up_Category__c();
        rollupCategory.Month__c = month;
        rollupCategory.Year__c = year;
        rollupCategory.Name = categoryExt;
        rollupCategory.External_Id__c = categoryExt;
        rollupCategory.Category__c = category;
        insert(rollupCategory);

        String categoryBranchExt = categoryBuildingPrefix+month+'_'+year;
        Roll_up_Category_and_Branch__c rollupCategoryBranch = new Roll_up_Category_and_Branch__c();
        rollupCategoryBranch.Month__c = month;
        rollupCategoryBranch.Year__c = year;
        rollupCategoryBranch.Name = categoryExt;
        rollupCategoryBranch.External_Id__c = categoryBranchExt;
        rollupCategoryBranch.Category__c = category;
        rollupCategoryBranch.Branch__c = branch.Id;
        rollupCategoryBranch.Roll_up_Category__c = rollupCategory.Id;
        insert(rollupCategoryBranch);

    }

    @isTest
    public static void test_targetTrigger() {
        
        Branch__c branch = [SELECT Id FROM Branch__c LIMIT 1];

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];

        Datetime todayDate = Datetime.now();
        String month = todayDate.formatGmt('MMM').toUpperCase();
        String year = todayDate.formatGmt('yyyy');
        List<Target__c> targetList = new List<Target__c>();

        Target__c targetBranch = new Target__c();
        targetBranch.RecordTypeId = Schema.SObjectType.Target__c.getRecordTypeInfosByDeveloperName().get('Target_by_Branch').getRecordTypeId();
        targetBranch.Branch__c = branch.Id;
        targetBranch.Month__c = month;
        targetBranch.Year__c = year;
        targetList.add(targetBranch);

        Target__c isDeleteTrue = new Target__c();
        isDeleteTrue.RecordTypeId = Schema.SObjectType.Target__c.getRecordTypeInfosByDeveloperName().get('Target_by_Branch').getRecordTypeId();
        isDeleteTrue.Branch__c = branch.Id;
        isDeleteTrue.Month__c = month;
        isDeleteTrue.Year__c = year;
        isDeleteTrue.Is_Delete__c = true;
        targetList.add(isDeleteTrue);

        Target__c targetBuilding = new Target__c();
        targetBuilding.RecordTypeId = Schema.SObjectType.Target__c.getRecordTypeInfosByDeveloperName().get('Target_by_Building').getRecordTypeId();
        targetBuilding.Branch__c = branch.Id;
        targetBuilding.Building__c = building.Id;
        targetBuilding.Month__c = month;
        targetBuilding.Year__c = year;
        targetList.add(targetBuilding);

        Target__c targetCategoryBranch = new Target__c();
        targetCategoryBranch.RecordTypeId = Schema.SObjectType.Target__c.getRecordTypeInfosByDeveloperName().get('Target_by_Category').getRecordTypeId();
        targetCategoryBranch.Category__c = Utility.getPicklistValues('Target__c', 'Category__c').get(0).getValue();
        targetCategoryBranch.Branch__c = branch.Id;
        targetCategoryBranch.Month__c = month;
        targetCategoryBranch.Year__c = year;
        targetList.add(targetCategoryBranch);

        Test.startTest();
        Insert targetList;
        Test.stopTest();

        List<Target__c> results = [SELECT Id, Name, Roll_up_Area_Branch__c, Roll_up_Area__c, Roll_up_Category__c, Roll_up_Category_and_Branch__c FROM Target__c];
        Roll_up_Category_and_Branch__c expectCategoryBranch = [SELECT Id FROM Roll_up_Category_and_Branch__c LIMIT 1];
        Roll_up_Area_Branch__c expectBranch = [SELECT Id FROM Roll_up_Area_Branch__c LIMIT 1];
        Roll_up_Area_Building__c expectBuilding = [SELECT Id FROM Roll_up_Area_Building__c LIMIT 1];
        Map<Id, Target__c> resultsMap = new Map<Id, Target__c>(results);
        System.debug('Roll_up_Category_and_Branch__c '+resultsMap.get(targetCategoryBranch.Id).Roll_up_Category_and_Branch__c);
        System.assertEquals(expectCategoryBranch.Id, resultsMap.get(targetCategoryBranch.Id).Roll_up_Category_and_Branch__c, 'Roll_up_Category_and_Branch__c Incorrect');
        System.debug('Roll_up_Category__c '+resultsMap.get(targetBranch.Id).Roll_up_Area_Branch__c);
        System.assertEquals(expectBranch.Id, resultsMap.get(targetBranch.Id).Roll_up_Area_Branch__c, 'Roll_up_Area_Branch__c Incorrect');
        System.debug('Roll_up_Area__c '+resultsMap.get(targetBuilding.Id).Roll_up_Area__c);
        System.assertEquals(expectBuilding.Id, resultsMap.get(targetBuilding.Id).Roll_up_Area__c, 'Roll_up_Area__c Incorrect');
    }
}