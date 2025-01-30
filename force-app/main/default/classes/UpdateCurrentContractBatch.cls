global class UpdateCurrentContractBatch implements Database.Batchable<sObject> {

	global UpdateCurrentContractBatch() {
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		Date todayDate = system.today();
		Date firstDateOfMonth = getFirstDateOfMonth(todayDate);
		Date lastDateOfMonth = getLastDateOfMonth(todayDate);
		String queryString = 'SELECT '+'Id, name, Contract__c, Unit__c, Contract__r.Contract_End_Date__c, Contract__r.Contract_Start_Date__c, '+
										'Contract__r.CreatedDate '+
							'FROM ContractLineItem__c '+
							'WHERE Contract__r.Contract_Start_Date__c <= '+String.valueOf(lastDateOfMonth)+
								' AND '+
								'('+
									' ('+
										'Contract__r.EndContractDecision__c = '+'\''+ 'ลูกค้าจบสัญญาก่อนเวลา' +'\''+' AND Contract__r.Termination_Date__c >= '+String.valueOf(firstDateOfMonth)+
									  ') '+
									'OR '+
										'('+
											'('+
												'Contract__r.EndContractDecision__c != '+'\''+ 'ลูกค้าจบสัญญาก่อนเวลา' +'\''+' OR Contract__r.Termination_Date__c = null'+
											') '+
											'AND Contract__r.Contract_End_Date__c >= '+String.valueOf(firstDateOfMonth)+
										')'+
								') ORDER BY Unit__c';
		system.debug('queryString : '+queryString);
		return Database.getQueryLocator(queryString);
	}

	global void execute(Database.BatchableContext BC, List<ContractLineItem__c> scope) {
		updateCurrentContractForUnit(scope);
	}

	global void finish(Database.BatchableContext BC) {
		
	}

	public void updateCurrentContractForUnit(List<ContractLineItem__c> targetContractLineItem){
		Map<String, ContractLineItem__c> targetContractLineItemMap = new Map<String, ContractLineItem__c>();
		Set<String> rentalObjectIdSet = new Set<String>();
		List<Units__c> updateRoList = new List<Units__c>();
		system.debug('targetContractLineItem : '+targetContractLineItem);
		for (ContractLineItem__c eachContractLineItem : targetContractLineItem) {
			system.debug('eachContractLineItem : '+eachContractLineItem);
			rentalObjectIdSet.add(eachContractLineItem.Unit__c);
			// get contract line by unit
			ContractLineItem__c currentContractLineInMap = targetContractLineItemMap.get(eachContractLineItem.Unit__c);
			// check if map has value
			if (currentContractLineInMap != null) {
				// if current contract line startdate < each contract line startdate
				if (currentContractLineInMap.Contract__r.Contract_Start_Date__c < eachContractLineItem.Contract__r.Contract_Start_Date__c) {
					targetContractLineItemMap.put(eachContractLineItem.Unit__c, eachContractLineItem);
				}
				else if (currentContractLineInMap.Contract__r.Contract_Start_Date__c == eachContractLineItem.Contract__r.Contract_Start_Date__c) {
					if (currentContractLineInMap.Contract__r.CreatedDate < eachContractLineItem.Contract__r.CreatedDate) {
						targetContractLineItemMap.put(eachContractLineItem.Unit__c, eachContractLineItem);
					}
				}
			}
			else{
				// add contract line in map
				targetContractLineItemMap.put(eachContractLineItem.Unit__c, eachContractLineItem);
			}
		}
		List<Units__c> targetRentalObjectList = [SELECT id, name, CurrentContract__c FROM Units__c where Id IN: rentalObjectIdSet];
		List<Units__c> clearRentalObjectCurrentContractList = [SELECT id, name, CurrentContract__c FROM Units__c where Id NOT IN: rentalObjectIdSet AND CurrentContract__c != null];
		// set current contract.
		for (Units__c eachRO : targetRentalObjectList) {
			system.debug('ro : '+eachRO);
			ContractLineItem__c currentContractLine = targetContractLineItemMap.get(eachRO.Id);
			system.debug('con line : '+currentContractLine);
			if (currentContractLine.Contract__c != eachRO.CurrentContract__c) {
				eachRO.LastContract__c = eachRO.CurrentContract__c;
				eachRO.CurrentContract__c = currentContractLine.Contract__c;
				updateRoList.add(eachRO);
			}
		}
		// clear current contract if unit is not related with any contract line.
		for (Units__c eachRO : clearRentalObjectCurrentContractList) {
			system.debug('ro : '+eachRO);
			eachRO.CurrentContract__c = null;
			updateRoList.add(eachRO);
		}
		system.debug('updateRoList : '+updateRoList);
		// update unit
		if (!updateRoList.isEmpty()) {
			Database.update(updateRoList, false);
		}
	}


    public static Date getFirstDateOfMonth(Date targetDate){
        return targetDate.toStartOfMonth();
    }

    public static Date getLastDateOfMonth(Date targetDate){
        return targetDate.toStartOfMonth().addMonths(1).addDays(-1);
    }
}