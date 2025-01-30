trigger TargetTrigger on Target__c (before insert, before update) {
    TriggerActivation setting = TriggerActivation.getInstance('Target__c');
    if (!setting.isActiveTrigger() || !CacheTrigger.isRunningContractTrigger) { return; }
    if (Trigger.isInsert || Trigger.isUpdate) {
        if (Trigger.isBefore) {
            System.debug('::: Target Trigger Before Insert / Update :::');
            
            Id targetRecordTypeBranch = RecordTypeUtility.getRecordTypeId('Target__c', 'Target_by_Branch');
            Id targetRecordTypeBuilding = RecordTypeUtility.getRecordTypeId('Target__c', 'Target_by_Building');
            Id targetRecordTypeCategory = RecordTypeUtility.getRecordTypeId('Target__c', 'Target_by_Category');

            List<Roll_up_by_Branch__mdt> rollupAreaMdt = Roll_up_by_Branch__mdt.getAll().values();
            Map<String, String> areaBranchMdtMap = new Map<String, String>();
            Map<String, String> areaBuildingMdtMap = new Map<String, String>();
            for (Roll_up_by_Branch__mdt rollupBranch : rollupAreaMdt) {
                if (rollupBranch.Is_Active__c) {
                    if (!areaBranchMdtMap.containsKey(rollupBranch.Branch_Name__c)) {
                        areaBranchMdtMap.put(rollupBranch.Branch_Name__c, rollupBranch.Prefix_Branch__c);
                    }
                    if (!areaBuildingMdtMap.containsKey(rollupBranch.Building_Name__c)) {
                        areaBuildingMdtMap.put(rollupBranch.Building_Name__c, rollupBranch.Prefix_Branch_Building__c);
                    }
                }
            }
            
            List<Roll_up_by_Category__mdt> rollupCategoryMdt = Roll_up_by_Category__mdt.getAll().values();
            // Map<String, String> categoryMdtMap = new Map<String, String>();
            Map<String, String> categoryBranchMdtMap = new Map<String, String>();
            for (Roll_up_by_Category__mdt rollupCategory : rollupCategoryMdt) {
                if (rollupCategory.Is_Active__c) {
                    // if (!categoryMdtMap.containsKey(rollupCategory.Category__c)) {
                    //     categoryMdtMap.put(rollupCategory.Category__c, rollupCategory.Prefix_Category__c);
                    // }
                    String keyString = rollupCategory.Category__c+'_'+rollupCategory.Branch_Name__c;
                    if (!categoryBranchMdtMap.containsKey(keyString)) {
                        categoryBranchMdtMap.put(keyString, rollupCategory.Prefix_Branch_Category__c);
                    }
                }
            }

            Map<Id, String> targetIdMapBranchExternalId = new Map<Id, String>();
            Map<Id, String> targetIdMapBuildingExternalId = new Map<Id, String>();
            // Map<Id, String> targetIdMapCategoryExternalId = new Map<Id, String>();
            Map<Id, String> targetIdMapCategoryBranchExternalId = new Map<Id, String>();

            for (Target__c target : Trigger.new) {
                if (String.isEmpty(target.Month__c) || String.isEmpty(target.Year__c) || target.Is_Delete__c) {
                    continue;
                }
                if (target.recordTypeId == targetRecordTypeBranch) {
                    String prefixBranch = areaBranchMdtMap.get(target.Branch_Name__c);
                    if (String.isBlank(prefixBranch)) {
                        continue;
                    }
                    String searchParamBranch = prefixBranch+target.Month__c+'_'+target.Year__c;
                    System.debug('searchParamBranch: '+searchParamBranch);
                    targetIdMapBranchExternalId.put(target.Id, searchParamBranch);
                } else if (target.recordTypeId == targetRecordTypeBuilding) {
                    String prefixBuilding = areaBuildingMdtMap.get(target.Building_Name__c);
                    if (String.isBlank(prefixBuilding)) {
                        continue;
                    }
                    String searchParamBuilding = prefixBuilding+target.Month__c+'_'+target.Year__c;
                    System.debug('searchParamBuilding: '+searchParamBuilding);
                    targetIdMapBuildingExternalId.put(target.Id, searchParamBuilding);
                } else if (target.recordTypeId == targetRecordTypeCategory) {
                    // String prefixCategory = categoryMdtMap.get(target.Category__c);
                    // if (String.isBlank(prefixCategory)) {
                    //     continue;
                    // }
                    // String searchParamCategory = prefixCategory+target.Month__c+'_'+target.Year__c;
                    // targetIdMapCategoryExternalId.put(target.Id, searchParamCategory);

                    String keyString = target.Category__c+'_'+target.Branch_Name__c;
                    String prefixCategoryBranch = categoryBranchMdtMap.get(keyString);
                    if (String.isBlank(prefixCategoryBranch)) {
                        continue;
                    }
                    String searchParamCategoryBranch = prefixCategoryBranch+target.Month__c+'_'+target.Year__c;
                    System.debug('searchParamCategoryBranch: '+searchParamCategoryBranch);
                    targetIdMapCategoryBranchExternalId.put(target.Id, searchParamCategoryBranch);
                }
            }

            List<Roll_up_Area_Branch__c> mRevenueBranchList = new List<Roll_up_Area_Branch__c>();
            Map<String, Roll_up_Area_Branch__c> mRevenueBranchMap = new Map<String, Roll_up_Area_Branch__c>(); 
            if (!targetIdMapBranchExternalId.isEmpty()) {
                mRevenueBranchList = [
                    SELECT Id, External_ID__c 
                    FROM Roll_up_Area_Branch__c 
                    WHERE External_ID__c IN :targetIdMapBranchExternalId.values()
                ];
            }
            if (!mRevenueBranchList.isEmpty()) {
                for (Roll_up_Area_Branch__c mRevenueBranch : mRevenueBranchList) {
                    if (!mRevenueBranchMap.containsKey(mRevenueBranch.External_ID__c)) {
                        mRevenueBranchMap.put(mRevenueBranch.External_ID__c, mRevenueBranch);
                    }
                }
            }
            System.debug('mRevenueBranchMap >>> '+mRevenueBranchMap);
            
            List<Roll_up_Area_Building__c> mRevenueBuildingList = new List<Roll_up_Area_Building__c>();
            Map<String, Roll_up_Area_Building__c> mRevenueBuildingMap = new Map<String, Roll_up_Area_Building__c>();
            if (!targetIdMapBuildingExternalId.isEmpty()) {
                mRevenueBuildingList = [
                    SELECT Id, External_ID__c 
                    FROM Roll_up_Area_Building__c 
                    WHERE External_ID__c IN :targetIdMapBuildingExternalId.values()
                ];
            }
            if (!mRevenueBuildingList.isEmpty()) {
                for (Roll_up_Area_Building__c mRevenueBuilding : mRevenueBuildingList) {
                    if (!mRevenueBuildingMap.containsKey(mRevenueBuilding.External_ID__c)) {
                        mRevenueBuildingMap.put(mRevenueBuilding.External_ID__c, mRevenueBuilding);
                    }
                }
            }
            System.debug('mRevenueBuildingMap >>> '+mRevenueBuildingMap);

            // List<Roll_up_Category__c> mRevenueCategoryList = new List<Roll_up_Category__c>();
            // Map<String, Roll_up_Category__c> mRevenueCategoryMap = new Map<String, Roll_up_Category__c>();
            // if (!targetIdMapCategoryExternalId.isEmpty()) {
            //     mRevenueCategoryList = [
            //         SELECT Id, External_ID__c 
            //         FROM Roll_up_Category__c 
            //         WHERE External_ID__c IN :targetIdMapCategoryExternalId.values()
            //     ];
            // }
            // if (!mRevenueCategoryList.isEmpty()) {
            //     for (Roll_up_Category__c mRevenueCategory : mRevenueCategoryList) {
            //         if (!mRevenueCategoryMap.containsKey(mRevenueCategory.External_ID__c)) {
            //             mRevenueCategoryMap.put(mRevenueCategory.External_ID__c, mRevenueCategory);
            //         }
            //     }
            // }
            // System.debug('mRevenueCategoryMap >>> '+mRevenueCategoryMap);

            List<Roll_up_Category_and_Branch__c> mRevenueCategoryBranchList = new List<Roll_up_Category_and_Branch__c>();
            Map<String, Roll_up_Category_and_Branch__c> mRevenueCategoryBranchMap = new Map<String, Roll_up_Category_and_Branch__c>();
            if (!targetIdMapCategoryBranchExternalId.isEmpty()) {
                mRevenueCategoryBranchList = [
                    SELECT Id, External_ID__c 
                    FROM Roll_up_Category_and_Branch__c 
                    WHERE External_ID__c IN :targetIdMapCategoryBranchExternalId.values()
                ];
            }
            if (!mRevenueCategoryBranchList.isEmpty()) {
                for (Roll_up_Category_and_Branch__c mRevenueCategoryBranch : mRevenueCategoryBranchList) {
                    if (!mRevenueCategoryBranchMap.containsKey(mRevenueCategoryBranch.External_ID__c)) {
                        mRevenueCategoryBranchMap.put(mRevenueCategoryBranch.External_ID__c, mRevenueCategoryBranch);
                    }
                }
            }
            System.debug('mRevenueCategoryMap >>> '+mRevenueCategoryBranchMap);

            for (Target__c target : Trigger.new) {
                if (String.isEmpty(target.Month__c) || String.isEmpty(target.Year__c) || target.Is_Delete__c) {
                    continue;
                }
                if (target.recordTypeId == targetRecordTypeBranch) {
                    String branchExternalId = targetIdMapBranchExternalId.get(target.Id);
                    Roll_up_Area_Branch__c mRevenueBranchId = mRevenueBranchMap.get(branchExternalId);
                    if (mRevenueBranchId != null) {
                        target.Roll_up_Area_Branch__c = mRevenueBranchId.Id;
                        target.Roll_up_Area__c = null;
                        target.Roll_up_Category__c = null;
                        target.Roll_up_Category_and_Branch__c = null;
                    }

                } else if (target.recordTypeId == targetRecordTypeBuilding) {
                    String buildingExternalId = targetIdMapBuildingExternalId.get(target.Id);
                    Roll_up_Area_Building__c mRevenueBuildingId = mRevenueBuildingMap.get(buildingExternalId);
                    if (mRevenueBuildingId != null) {
                        target.Roll_up_Area_Branch__c = null;
                        target.Roll_up_Area__c = mRevenueBuildingId.Id;
                        target.Roll_up_Category__c = null;
                        target.Roll_up_Category_and_Branch__c = null;
                    }

                } else if (target.recordTypeId == targetRecordTypeCategory) {
                    // String categoryExternalId = targetIdMapCategoryExternalId.get(target.Id);
                    // Roll_up_Category__c mRevenueCategoryId = mRevenueCategoryMap.get(categoryExternalId);
                    // if (mRevenueCategoryId != null) {
                    //     target.Roll_up_Category__c = mRevenueCategoryId.Id;
                    // } else {
                    //     target.Roll_up_Category__c = null;
                    // }

                    String categoryBranchExternalId = targetIdMapCategoryBranchExternalId.get(target.Id);
                    Roll_up_Category_and_Branch__c mRevenueCategoryBranchId = mRevenueCategoryBranchMap.get(categoryBranchExternalId);
                    if (mRevenueCategoryBranchId != null) {
                        target.Roll_up_Area_Branch__c = null;
                        target.Roll_up_Area__c = null;
                        target.Roll_up_Category__c = null;
                        target.Roll_up_Category_and_Branch__c = mRevenueCategoryBranchId.Id;
                    }
                }
            }
        }
    }
}