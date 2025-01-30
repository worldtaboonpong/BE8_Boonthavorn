public without sharing class masterPlanController {

	public static final String FLOORIMAGE_PATTERN = 'FloorImage_{0}_{1}';

    @AuraEnabled(Cacheable=true)
  	public static List<LookupSearchResult> searchProject(String searchTerm, List<String> selectedIds) {

		String searchStrig = '%'+searchTerm+'%';
		List<Building__c> buildingToReturn = [SELECT Id, Name FROM Building__c WHERE Name LIKE: searchStrig];
		List<LookupSearchResult> result  = new List<LookupSearchResult>();

		for (Building__c eachBuilding : buildingToReturn ) {
		result.add(new LookupSearchResult(eachBuilding.Id,
												eachBuilding.Id.getSobjectType().getDescribe().getName(),
												'standard:household',
												eachBuilding.Name,
												'Description'));
		}

		return result;
	}				

  	@AuraEnabled(Cacheable=true)
  	public static List<Object> getFloorList(Id buildingId) {
		System.debug(buildingId);
		List<FloorPlanFloorListWrapper.FloorListWrapper> resultMasterPlanList = new List<FloorPlanFloorListWrapper.FloorListWrapper>();
		
		Map<Id, Floor__c> targetFloorByIdMap = getAllFloorListByBuildingId(buildingId);
		System.debug(targetFloorByIdMap);
		if(!targetFloorByIdMap.isEmpty()) {
			Map<Id,String> CVByFloorIdMap = getContentVersionByBuildingID(targetFloorByIdMap.keyset());
			Map<Id, Units__c> targetROByIdMap = getRentalObjectForDisplayOnMasterPlan(targetFloorByIdMap.keyset(), buildingId);
			Map<Id, List<Units__c>> allRetalObjectByFloorMap = assignRentalObjectWithFloorId(targetROByIdMap.values());
			Map<Id, List<OpportunityLineItem__c>> allOppLineByROIdMap = getOppLineByRentalId(targetROByIdMap.keyset());

			FloorPlanFloorListWrapper.FloorListWrapper allBuildingResult;
			for (Floor__c eachFloor : targetFloorByIdMap.values()) {
				String floorName = eachFloor.Name;
				String contentVersion = (CVByFloorIdMap.containsKey(eachFloor.Id))? CVByFloorIdMap.get(eachFloor.Id) : '';

				List<FloorPlanFloorListWrapper.ROListWrapper> allFloorResult = new List<FloorPlanFloorListWrapper.ROListWrapper>();
				if(allRetalObjectByFloorMap.containsKey(eachFloor.Id)){
					for (Units__c eachRO : allRetalObjectByFloorMap.get(eachFloor.Id)) {
						Integer numberOfOppLine = allOppLineByROIdMap.containsKey(eachRO.Id)? allOppLineByROIdMap.get(eachRO.Id).size() : 0;
						//getting OppLineStageList
						List<String> oppLineStageList = new List<String>();
						if (numberOfOppLine > 0){
							for (Integer i=0; i<numberOfOppLine; i++){
								oppLineStageList.add(allOppLineByROIdMap.get(eachRO.Id)[i].Opportunity__r.StageName);
							}
						}
						System.debug(oppLineStageList);
						//end creat oppLineStageList
						String targetROStatus = getROStatusForSetupColor(eachRO, numberOfOppLine, oppLineStageList);
						allFloorResult.add(new FloorPlanFloorListWrapper.ROListWrapper(floorName, numberOfOppLine, eachRO, targetROStatus));
					}
				}
				
				allBuildingResult = new FloorPlanFloorListWrapper.FloorListWrapper( floorName, contentVersion, String.valueOf(eachFloor.Id), allFloorResult);
			resultMasterPlanList.add(allBuildingResult);
			}
		}

		Blob content;
		if (Test.isRunningTest()) content = blob.valueOf('Unit.Test');
		else content = (new PageReference('/resource/testdata_floor')).getContent(); 

		System.debug('resultMasterPlanList'+ resultMasterPlanList);
		return (List<Object>) JSON.deserializeUntyped(System.JSON.serialize(resultMasterPlanList));
	}

  @AuraEnabled
  public static Boolean saveUnitList(String unitObjList) {
    try {
      System.debug('saveUnitList :'+ unitObjList);
      List<FloorPlanFloorListWrapper.ROSaveListWrapper> results = (List<FloorPlanFloorListWrapper.ROSaveListWrapper>)JSON.deserialize(unitObjList, List<FloorPlanFloorListWrapper.ROSaveListWrapper>.class);
      System.debug('results :'+results);

      Set<Id> roIdSet = new Set<Id>();
      Map<Id,FloorPlanFloorListWrapper.ROSaveListWrapper> roResultMap = new Map<Id,FloorPlanFloorListWrapper.ROSaveListWrapper>();
      
      for (FloorPlanFloorListWrapper.ROSaveListWrapper eachResult : results) {
        roResultMap.put(Id.valueOf(eachResult.id), eachResult);
        roIdSet.add(Id.valueOf(eachResult.id));
      }

      List<Units__c> roTosaveList = [SELECT Id, CoordX__c, CoordY__c, PointerSize__c FROM Units__c WHERE Id IN: roIdSet];

      if (!roTosaveList.isEmpty()) {
        
        for (Units__c eachRO : roTosaveList) {
          eachRO.CoordX__c = roResultMap.get(eachRO.Id).coordX;
          eachRO.CoordY__c = roResultMap.get(eachRO.Id).coordY;
          eachRO.PointerSize__c = roResultMap.get(eachRO.Id).pointerSize;
        }

        update roTosaveList;
      }

      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  	@AuraEnabled(Cacheable=true)
	public static Map<String, String> getStatusColorMapping(List<Object> unitObjList) {
		// List<masterPlanStatusColor__mdt> colorList = [  SELECT Status__c, Color__c FROM masterPlanStatusColor__mdt];
		Map<String, String> mapping = new Map<String, String>();
		// for (masterPlanStatusColor__mdt each : colorList) {
		// 	mapping.put(each.Status__c, each.Color__c);
		// }
		mapping.put('Negotiation in Progress', '#FA9F42');
		mapping.put('Available for Sales', '#8AD879');
		mapping.put('Contract Activated', '#F3533A');

		return mapping;
	}

//   public static Map<Id,List<Opportunity>> getOppBelongToRO(List<Units__c> roList, Map<Id,Opportunity> oppMap, List<OpportunityLineItem__c> oppLineList){

//     Map<Id,List<Opportunity>> res = new Map<Id,List<Opportunity>>();
//     for (Units__c eachRo : roList) {
//       res.put(eachRo.Id, new List<Opportunity>());
//     }

//     for (OpportunityLineItem__c eachOppLine: oppLineList) {
//       res.get(eachOppLine.Unit__c).add(oppMap.get(eachOppLine.Opportunity__C));  
//     }

//     return res;

//   }

//   public static Map<Id,List<Units__c>> getROBelongToFloor(List<Floor__c> floorList ,List<Units__c> roList){

//     Map<Id,List<Units__c>> res = new Map<Id,List<Units__c>>();
//     for (Floor__c eachFloor : floorList) {
//       res.put(eachFloor.Id, new List<Units__c>());
//     }

//     for (Units__c eachRo: roList) {
//       res.get(eachRo.Floor__c).add(eachRo);  
//     }

//     return res;

//   }

// Start_OF_TMS_FunctionHelper
	public static Map<Id,Floor__c> getAllFloorListByBuildingId(Id targetBuildingID) {
		return new Map<Id,Floor__c>([SELECT Id, Name FROM Floor__c WHERE Building__c =: targetBuildingID]);
  	}

  	public static Map<Id,String> getContentVersionByBuildingID(Set<Id> buildingIdSet){
		Map<Id,String> floorId_ContentVerId_Map = new Map<Id,String>();
		List<String> fileType = new List<String>{'JPG', 'JPEG', 'PNG', 'jpg', 'jpeg', 'png'};
		List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
		contentDocLinkList = [SELECT ContentDocumentId, ContentDocument.FileType , LinkedEntityId 
								FROM ContentDocumentLink WHERE LinkedEntityId IN: buildingIdSet AND ContentDocument.FileType IN:fileType];

		Set<Id> contentDocLinkListIdSet = new Set<Id>();
		for (ContentDocumentLink eachContentDocLink : contentDocLinkList) {
			contentDocLinkListIdSet.add(eachContentDocLink.ContentDocumentId);
		}

		List<Floor__c> buildingFloorList = [SELECT Id, Building__r.Building_Abbreviated__c, Floor_Short_Name__c FROM Floor__c WHERE Id IN: buildingIdSet];
		Set<String> buildingFloorFileNameSet = new Set<String>();
		for(Floor__c buildingFloor : buildingFloorList) {
			List<Object> parameters = new List<Object> { buildingFloor.Building__r.Building_Abbreviated__c, buildingFloor.Floor_Short_Name__c };
			String formattedText = String.format(FLOORIMAGE_PATTERN, parameters);
			buildingFloorFileNameSet.add(formattedText);
		}

		List<ContentVersion> contentVersionList= new List<ContentVersion> ();
		List<ContentVersion> selectedContentVersionList= new List<ContentVersion> ();
		contentVersionList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocLinkListIdSet];
		for(ContentVersion contentVersion : contentVersionList) {
			if(buildingFloorFileNameSet.contains(contentVersion.Title)) {
				selectedContentVersionList.add(contentVersion);
			}
		}
		System.debug(buildingFloorFileNameSet);
		System.debug(selectedContentVersionList);

		Map<Id,ContentDocumentLink> floor_ContentDocLink_Map = getContentDocumentLinkMapPhase(contentDocLinkList);
		Map<Id,ContentVersion> contentDocLink_contentver_Map = getContentDocumentLinkMapContentVersion(selectedContentVersionList);
		System.debug(floor_ContentDocLink_Map);
		System.debug(contentDocLink_contentver_Map);

		floorId_ContentVerId_Map = getImageURLMap(floor_ContentDocLink_Map,contentDocLink_contentver_Map);
		System.debug('floorId_ContentVerId_Map' + floorId_ContentVerId_Map); 
		return floorId_ContentVerId_Map;
  	}

	public static Map<Id,ContentDocumentLink> getContentDocumentLinkMapPhase(List<ContentDocumentLink> contentDocLinkList){
		Map<Id,ContentDocumentLink> resultMap = new Map<Id,ContentDocumentLink>();
		for (ContentDocumentLink eachContentDocLink :contentDocLinkList) {
			resultMap.put(eachContentDocLink.LinkedEntityId, eachContentDocLink);
		}
		return resultMap;
	}

	public static Map<Id,ContentVersion> getContentDocumentLinkMapContentVersion(List<ContentVersion> contentVersionList){
		Map<Id,ContentVersion> resultMap = new Map<Id,ContentVersion>();
		for (ContentVersion eachContentVersionList :contentVersionList) {
		resultMap.put(eachContentVersionList.ContentDocumentId, eachContentVersionList);
		}
		return resultMap;
	}

	public static Map<Id,String> getImageURLMap(Map<Id,ContentDocumentLink> contentDocumentLinkMapPhase, Map<Id,ContentVersion> contentDocumentLinkMapContentVersion){
		Map<Id,String> resultMap = new Map<Id,String>();
		for (Id eachPhaseId : contentDocumentLinkMapPhase.keySet()) {

			ContentVersion contentVersion = contentDocumentLinkMapContentVersion.get(contentDocumentLinkMapPhase.get(eachPhaseId).ContentDocumentId);
			if(contentVersion == null) continue;

			String targetContentId = String.valueOf(contentDocumentLinkMapContentVersion.get(contentDocumentLinkMapPhase.get(eachPhaseId).ContentDocumentId).Id);
			resultMap.put(eachPhaseId, 
						'/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+targetContentId);
		}
		return resultMap;
	}

	public static Map<Id, List<Units__c>> assignRentalObjectWithFloorId(List<Units__c> targetRentalList) {
		Map<Id, List<Units__c>> allRetalObjectByFloorMap= new Map<Id, List<Units__c>>();
		for(Units__c eachRentalObject : targetRentalList){
		if(allRetalObjectByFloorMap.containsKey(eachRentalObject.Floor__c)){
			allRetalObjectByFloorMap.get(eachRentalObject.Floor__c).add(eachRentalObject);
		}else{
			allRetalObjectByFloorMap.put(eachRentalObject.Floor__c, new List<Units__c>{eachRentalObject});
		}
		}
		return allRetalObjectByFloorMap;
	}

	public static Map<Id, Units__c> getRentalObjectForDisplayOnMasterPlan(Set<Id> targetfloorSetId, Id targetBuildingId) {
		system.debug('targetfloorSetId: '+targetfloorSetId + ', targetBuildingId: '+targetBuildingId);
		return new Map<Id, Units__c>([ SELECT  Id, Name, CoordX__c,CoordY__c, Units_Code__C, 
								Usage_Type__c,Floor__c, PointerSize__c,
								CurrentContract__c
						FROM Units__c
						WHERE Type__c != :Constant.TMS_TYPE_CANCELLED
							AND Floor__c IN: targetfloorSetId AND Building__c =: targetBuildingId
						WITH SECURITY_ENFORCED
					]);
	}

	public static Map<Id, List<OpportunityLineItem__c>> getOppLineByRentalId(Set<Id> rentalObjectIdSet) {
		system.debug('rentalObjectIdSet: '+rentalObjectIdSet);
		List<OpportunityLineItem__c> targetOppLineList = getOpportunityByRentalObjIdSet(rentalObjectIdSet);
		Map<Id, List<OpportunityLineItem__c>> allOppLineByROIdMap = new Map<Id, List<OpportunityLineItem__c>>();
		for(OpportunityLineItem__c eachOppLine: targetOppLineList){
		if(allOppLineByROIdMap.containsKey(eachOppLine.Unit__c)){
			allOppLineByROIdMap.get(eachOppLine.Unit__c).add(eachOppLine);
		}else{
			allOppLineByROIdMap.put(eachOppLine.Unit__c, new List<OpportunityLineItem__c>{eachOppLine});
		}
		}
		return allOppLineByROIdMap;
	}

  	public static String getROStatusForSetupColor(Units__c targetRO, Integer numberOfOpportunities, List<String> oppLineStageList) {
		//adding closing stage keyword
		List<String> closedStageList = new String[]{'Closed Won', 'Closed Lost'};
		String targetROStatus = Constant.TMS_MASTERPLAN_STATUS_RED;
		if(targetRO.CurrentContract__c != null){
			targetROStatus  = Constant.TMS_MASTERPLAN_STATUS_GREEN;
		}else if (numberOfOpportunities > 0){
			targetROStatus  = Constant.TMS_MASTERPLAN_STATUS_ORANGE;
			//checking stage keyword for changeing status
			for(String eachClosedStage: closedStageList){
				if(oppLineStageList.contains(eachClosedStage)){
					targetROStatus = Constant.TMS_MASTERPLAN_STATUS_RED;
				}
			}
			//end checking
		}
		return targetROStatus;
  	}

	@AuraEnabled(Cacheable=true)
	public static Units__c getRentalObjectDetailByRentalObjId(Id rentalObjectId) {
		system.debug('rentalObjectId: '+rentalObjectId);
		Units__c targetRentalObject = new Units__c();
		List<Units__c> rentalList = new List<Units__c>();
		rentalList =  [
						SELECT Id, 
							Building__c, Building__r.Name,  
							Floor__c, Floor__r.Name,
							Units_Code__C, Type__c, UnitType__c,
							Name, //RentalObjectType__c, 
							TotalArea__c, Usage_Type__c,
							LeasableArea__c, //LocationOnFloor__c, LocationOnFloor__r.Name, 
							ValidFrom__c, CurrentContract__c, CurrentContract__r.Name,
							ValidTo__c, CurrentContractAccountName__c,
							IsRetailZone__c, CurrentContractShopName__c,
							/*IsSPWGSublease__c,*/ CurrentContractStartDate__c,
							Available_For_Sales__c, CurrentContractEndDate__c
						FROM Units__c
						WHERE Id = :rentalObjectId AND Type__c != :Constant.TMS_TYPE_CANCELLED
						WITH SECURITY_ENFORCED
					];
		if(!rentalList.isEmpty()) targetRentalObject = rentalList.get(0);
		system.debug('targetRentalObject'+targetRentalObject);    
		return targetRentalObject;
	}

	@AuraEnabled(Cacheable=true)
	public static List<OpportunityLineItem__c> getOpportunityByRentalObjId(Id rentalObjectId) {
		return getOpportunityByRentalObjIdSet(new Set<Id>{rentalObjectId});
	}

	public static List<OpportunityLineItem__c> getOpportunityByRentalObjIdSet(Set<Id> rentalObjectIdSet) {
		system.debug('rentalObjectIdSet: '+rentalObjectIdSet);
		List<OpportunityLineItem__c> allOppLineItem = new List<OpportunityLineItem__c>();
		Date targetToday = Date.today();
		allOppLineItem =  [
						SELECT Id, Name, Opportunity__c, Opportunity__r.Name, Unit__c,
							Opportunity__r.RecordType.Name,
							Opportunity__r.StageName,
							Opportunity__r.AccountId, Opportunity__r.Account.Name,
							Opportunity__r.Shop_Name__c,
							//tms_Opportunity__r.Owner.Name, tms_Opportunity__r.OwnerId,
							Opportunity__r.Estimated_Contract_Start_Date__c,
							Opportunity__r.Estimated_Contract_End_Date__c
							//tms_Opportunity__r.tms_ShopPurpose__c,
						FROM OpportunityLineItem__c
						WHERE Unit__c IN :rentalObjectIdSet AND Opportunity__c != null//AND RentalObject__r.Type__c != :Constant.TMS_TYPE_CANCELLED
							AND (Opportunity__r.StageName IN :Constant.TMS_OPP_STAGE_DISPLAY_ON_MASTERPLAN_SET)
						WITH SECURITY_ENFORCED //ORDER BY Opportunity__r.ContractStartDate__c ASC
					];
		system.debug('allOppLineItem'+allOppLineItem);
		return allOppLineItem;
	}

	@AuraEnabled(Cacheable=true)
	public static List<ContractLineItem__c> getContactByRentalObjId(Id rentalObjectId) {
		system.debug('rentalObjectId'+rentalObjectId);
		List<ContractLineItem__c> allContractLineItem = new List<ContractLineItem__c>();
		Date targetToday = Date.today();
		allContractLineItem =  [
						SELECT Id, Name, Contract__c,
							Contract__r.Name,
							//tms_Contract__r.tms_ContractType__c,
							Contract__r.Status__c,
							Contract__r.Account_Name__c, Contract__r.Account_Name__r.Name,
							Contract__r.ShopName__c,
							//tms_Contract__r.Owner.Name, tms_Contract__r.OwnerId,
							Contract__r.Contract_Start_Date__c,
							Contract__r.Contract_End_Date__c
						FROM ContractLineItem__c
						WHERE Unit__c = :rentalObjectId AND Contract__c != null// AND RentalObject__r.Type__c != :Constant.TMS_TYPE_CANCELLED
						WITH SECURITY_ENFORCED // ORDER BY Contract__r.ContractStartDate__c ASC
					];
		system.debug('allContractLineItem'+allContractLineItem);
		return allContractLineItem;
	}
}