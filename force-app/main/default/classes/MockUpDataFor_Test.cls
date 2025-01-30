@isTest
public with sharing class MockUpDataFor_Test {

    private static String OPP_NAME = 'test opportunity';
    public static final String Acc_CorporateCustomerProspect = 'Corporate';
    public static final String Acc_IndividualCustomerProspect = 'Individual';
    public static final String Opp_LeasingProcess = 'Rent_Space';

    public static Id recordTypeIdForCoperateCustomerProspect = RecordTypeUtility.getRecordTypeId('Account', Acc_CorporateCustomerProspect);
    public static Id recordTypeIdForIndividualProspect = RecordTypeUtility.getRecordTypeId('Account', Acc_IndividualCustomerProspect);
    public static Id recordTypeIdForLeasingProcess = RecordTypeUtility.getRecordTypeId('Opportunity', Opp_LeasingProcess);

    public static List<Contract__c> getContractList(Integer listSize) {
        List<Contract__c> contractList = new List<Contract__c>();
        // insert Account For Contract
        Account account = MockUpDataFor_Test.createIndividualAccount();

        Building__c building = MockUpDataFor_Test.createBuildingPack();

        if(listSize >= 1){
            Date todayDate = System.Date.today();
            for (Integer i = 1; i <= listSize; i++) {
                Contract__c contract = new Contract__c();
                contract.Name = 'contract ' + i;
                contract.Account_Name__c = account.Id;
                contract.Building__c = building.Id;
                contract.Billing_Start_Date__c = todayDate;
                contract.Contract_Start_Date__c = todayDate;
                contract.Contract_End_Date__c = todayDate;
                contract.Grace_Month__c = 1;
                contract.Grace_Day__c = 1;
                contract.Shop_Opening_Date__c = todayDate;

                contractList.add(contract);
            }
        }
        return contractList;
    }
    
    public static List<String> getObjectiveofChangeChangeDateTC(String objectApiName, String fieldApiName){
        // ถ้ามีเวลากลับมาทำ mock up ที่ call available picklist value
        List<String> pickListValuesList= new List<String>();
        Map<String, sObjectField> objectResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = objectResult.get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }

        return pickListValuesList;
    }

    //--------------------- insert data ------------------------- //
    public static Account createCoperateAccount(){
        Account targetAccount = MockUpDataFor_Test.createCoperateAccount('test account', 'test account', '1102903049021');
        insert targetAccount;

        return targetAccount;
    }

    public static Account createCoperateAccount(String accountName, String accountNameTH, String taxOrCitizenId){
        Account targetAccount = new Account(
            RecordTypeId = recordTypeIdForCoperateCustomerProspect,
            Name = accountName,
            Tax_Number__c = taxOrCitizenId,
            Phone = '02-2222222',
            Account_Name_TH__c = accountNameTH
        );
        return targetAccount;
    }

    public static Account createIndividualAccount() {
        Account targetAccount = MockUpDataFor_Test.createIndividualAccount('test', 'เทส', 'account', 'แอคเค้า', '1102903049021');
        insert targetAccount;

        return targetAccount;
    }

    public static Account createIndividualAccount(String firstNameEN, String firstNameTH, String lastNameEN, String lastNameTH, String taxOrCitizenId){
        Account targetAccount = new Account(
            RecordTypeId = recordTypeIdForIndividualProspect,
            //FirstNameEN__c = firstNameEN,
            First_Name_TH__c = firstNameTH,
            //LastNameEN__c = lastNameEN,
            Last_Name_TH__c = lastNameTH,
            name = firstNameEN+' '+lastNameEN,
            Tax_Number__c = taxOrCitizenId,
            Phone = '02-2222222'
        );
        return targetAccount;
    }

    public static Contact createContactPerson(String accId){
        Contact targetContactPerson = new Contact(
            AccountId = accId,
            LastName = 'TestLastName',
            Birthdate = Date.newInstance(Date.today().year()-25, Date.today().month(), Date.today().day()),
            Email = 'test@test.com',
            FirstName = 'TestFirstNam',
            Gender__c = 'Male',
            MobilePhone = '0800000000',
            Salutation_TH__c = 'นาย'
            );

        return targetContactPerson;
    }

    public static Building__c createBuilding(Branch__c branch, String buildingName, String buildingNameTH, String buildingNameABBR, String buildingCode){
        Building__c building = new Building__c(
            Name = buildingName,
            Branch__c = branch.Id,
            Building_Name_TH__c = buildingNameTH,
            Building_ExtID__c = buildingCode,
            Building_Abbreviated__c = buildingNameABBR,
            Active__c = true
        );
        return building;
    }
    
    public static List<Building__c> createDefaultBuildingList(){
        List<Building__c> result = new List<Building__c>();

        Branch__c br = new Branch__c(Name='Test');
        insert(br);

        List<String> buildingNameList = new List<String> {'ICON Building 1', 'Siam Center', 'Siam Discovery', 'Siam Paragon', 'Siam Piwat Tower'};
        for (Integer i = 0; i < buildingNameList.size(); i++) {
            String code = (i + 1) < 10 ? '0' + (i + 1) : '' + (i + 1);
            Building__c building = createBuilding(br, buildingNameList.get(i),
                                                    buildingNameList.get(i),
                                                    'B0' + code,
                                                    '50' + code); 
            result.add(building);
        }
        return result;
    }

    public static Floor__c createBuildingFloor(Building__c targetBuilding, String floorCode, String floorShortName, String floorName){
        Floor__c buildingFloor = new Floor__c(
            Name = floorName,
            Building__c = targetBuilding.Id,
            Floor_Code__c = floorCode,
            Floor_Short_Name__c = floorShortName,
            Floor_ExtID__c = floorCode,
            Is_Active__c = true
        );
        return buildingFloor;
    }

    public static Units__c createRentalObject(Building__c building, Floor__c buildingFloor, String usageType){
        Units__c rentalObject = new Units__c(
            Name = 'rental object name',
            ValidFrom__c=System.today(), 
            ValidTo__c=System.today().addYears(10), 
            Usage_Type__c=usageType, 
            Building__c=building.Id, 
            Floor__c=buildingFloor.Id,
            TotalArea__c = 500,
            LeasableArea__c = 300,
            Available_for_Sales__c = true
        );

        return rentalObject;
    }

    public static Measurement__c createROMeasurement (Units__c ro, String measurement, Decimal measuementAmt){
        Measurement__c roMeasurement = new Measurement__c(
            Unit_No__c=ro.Id,
            Measurement_Area_Sqm__c=measuementAmt, 
            Type__c=measurement,
            Valid_From_Date__c = Date.today().addYears(-1),
            Valid_To_Date__c = Date.today().addYears(10)
        );

        return roMeasurement;
    }

    public static Opportunity createOpp(String oppName, String usageType, Account account, Units__c rentalObject, Contact contactPerson){
        system.debug(account);
        Opportunity opp = new Opportunity(
                                            Name = oppName, 
                                            Usage_Type__c = usageType,
                                            CloseDate = System.today() + 1,
                                            //RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LeasingProcess').getRecordTypeId(),                                    
                                            StageName = OpportunityController.STAGE_QUOTEPREPARE,
                                            AccountId = account.Id,
                                            Building__c = rentalObject.Building__c,
                                            Rental_Period_Year__c = 2,
                                            Contact_Name__c = contactPerson.Id,
                                            Estimated_Contract_Start_Date__c = system.today(),
                                            Estimated_Contract_End_Date__c = system.today().addYears(2));
        system.debug('create opp: '+opp);
        return opp;
    }

    public static Opportunity createOppRetailZone(String oppName, String usageType, Account account, Units__c rentalObject, Contact contactPerson){
        system.debug(account);
        Opportunity opp = new Opportunity(
                                            Name = oppName, 
                                            Usage_Type__c = usageType,
                                            CloseDate = System.today() + 1,
                                            //RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RetailZoneProcess').getRecordTypeId(),                                    
                                            StageName = OpportunityController.STAGE_QUOTEPREPARE,
                                            AccountId = account.Id,
                                            Building__c = rentalObject.Building__c,
                                            Rental_Period_Year__c = 2,
                                            Contact_Name__c = contactPerson.Id,
                                            Estimated_Contract_Start_Date__c = system.today(),
                                            Estimated_Contract_End_Date__c = system.today().addYears(2));
        system.debug('create opp: '+opp);
        return opp;
    }


    public static OpportunityLineItem__c createOppLineItem(Opportunity opp, Units__c ro){
        OpportunityLineItem__c oppLine = new OpportunityLineItem__c(Opportunity__c=opp.Id, Unit__c=ro.Id);

        return oppLine;
    } 

    public static OpportunityPeriod__c createOppPeriod(Opportunity opp, Integer sequence, String calculationMethod){
        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(Opportunity__c=opp.Id,
                                                                            PeriodFrom__c=System.today(), 
                                                                            PeriodTo__c=System.today(), 
                                                                            Sequence__c= sequence,
                                                                            CalculationMethod__c=calculationMethod);

        return oppPeriod;
    }
    
    public static Contract__c createContract(Account account) {
        Contract__c contract = new Contract__c();
        Date todayDate = System.Date.today();
        contract.Name = 'contract Name';
        contract.Account_Name__c = account.Id;
        contract.Billing_Start_Date__c = todayDate;
        contract.Contract_Start_Date__c = todayDate;
        contract.Contract_End_Date__c = todayDate;
        contract.Grace_Month__c = 1;
        contract.Grace_Day__c = 1;
        contract.Shop_Opening_Date__c = todayDate;
        return contract;
    }

    public static ContractPeriod__c createContractPeriod(Contract__c contract, Integer sequence, String calculationMethod){
        ContractPeriod__c contractPeriod = new ContractPeriod__c(Contract__c=contract.Id,
                                                                            PeriodFrom__c=System.today(), 
                                                                            PeriodTo__c=System.today(), 
                                                                            Sequence__c= sequence,
                                                                            CalculationMethod__c=calculationMethod);

        return contractPeriod;
    }

    public static OpportunityDepositExpense__c createOppDepositExpense(Opportunity opp){
        OpportunityDepositExpense__c oppDepositExpense = new OpportunityDepositExpense__c(
            Opportunity__c=opp.Id,
            HasRemark__c=false,
            Subtype__c='Actual',
            Type__c='Water',
            TypeGroup__c='Other',
            Price__c=0
        );
        return oppDepositExpense;
    }

    public static OpportunityDepositExpense__c createOppDepositExpenseSD(Opportunity opp){
        OpportunityDepositExpense__c oppDepositExpense = new OpportunityDepositExpense__c(
            Opportunity__c=opp.Id,
            HasRemark__c=false,
            Type__c=Constant.TYPE_SECURITY_DEPOSIT,
            TypeGroup__c=Constant.TYPE_DEPOSIT,
            Price__c=100000
        );
        return oppDepositExpense;
    }

    public static OpportunityPrice__c createOppPrice(Opportunity opp, OpportunityPeriod__c oppPeriod){
        OpportunityPrice__c oppPrice = new OpportunityPrice__c(Opportunity__c=opp.Id,
                                                                        OpportunityPeriod__c=oppPeriod.Id,
                                                                        From__c=System.today(), 
                                                                        To__c=System.today(),  
                                                                        Price__c=100);

        return oppPrice;
    }

    public static OpportunityPrice__c createOppPrice(Opportunity opp, OpportunityPeriod__c oppPeriod, String measurment, String calCulationMethod){
        OpportunityPrice__c oppPrice = new OpportunityPrice__c(Opportunity__c=opp.Id,
                                                                        OpportunityPeriod__c=oppPeriod.Id,
                                                                        From__c=System.today(), 
                                                                        To__c=System.today(),  
                                                                        Price__c=100,
                                                                        PriceItem__c = measurment,
                                                                        MeasurementType__c = measurment,
                                                                        CalculationMethod__c = calCulationMethod,
                                                                        MeasurementAmount__c = 100
                                                                        );

        return oppPrice;
    }

    public static OpportunityPrice__c createOppPriceWithProportion(Opportunity opp, OpportunityPeriod__c oppPeriod, Integer proportion, String subType){
        OpportunityPrice__c oppPrice = new OpportunityPrice__c(Opportunity__c=opp.Id,
                                                                        OpportunityPeriod__c=oppPeriod.Id,
                                                                        From__c=System.today(), 
                                                                        To__c=System.today(),  
                                                                        Price__c=100,
                                                                        ConditionPurpose__c = (subType == 'Rent')?'Z110':(subType == 'Service')?'Z120':null,
                                                                        ProportionPercent__c=proportion,
                                                                        Subtype__c=subType);

        return oppPrice;
    }

    public static OpportunityPrice__c createOppPriceDeposit(Opportunity opp, OpportunityDepositExpense__c deposit, String subType){
        OpportunityPrice__c oppPrice = new OpportunityPrice__c(Opportunity__c=opp.Id,
                                                                        From__c=System.today(), 
                                                                        To__c=System.today(),  
                                                                        Price__c=100,
                                                                        OpportunityDepositExpense__c = deposit.Id,
                                                                        Subtype__c=subType);

        return oppPrice;
    }

    public static OpportunityGradingModel.Data createOppGrading(Opportunity opp, OpportunityPeriod__c oppPeriod, Integer gradingFrom, Integer gradingTo){
        OpportunityGradingModel.Data oppGrading = new OpportunityGradingModel.Data();
        oppGrading.IsGrading = true;
        oppGrading.IsIncludeCAM = false;
        oppGrading.ReportingRule = 'Z010';
        oppGrading.FromR = gradingFrom;
        oppGrading.ToR = gradingTo;
        oppGrading.GradingPeriodForm = system.today();
        oppGrading.GradingPeriodTo = system.today().addYears(2);
        oppGrading.GPRangeNo = '0';
        oppGrading.OpportunityId = opp.Id;
        oppGrading.OpportunityPeriodId = oppPeriod.Id;
        oppGrading.GP = 10;
        return oppGrading;
    }

    public static ContractGradingModel.Data createContractGrading(Contract__c contract, ContractPeriod__c contractPeriod, Integer gradingFrom, Integer gradingTo){
        ContractGradingModel.Data contractGrading = new ContractGradingModel.Data();
        contractGrading.IsGrading = true;
        contractGrading.IsIncludeCAM = false;
        contractGrading.ReportingRule = 'Z010';
        contractGrading.FromR = gradingFrom;
        contractGrading.ToR = gradingTo;
        contractGrading.GradingPeriodForm = system.today();
        contractGrading.GradingPeriodTo = system.today().addYears(2);
        contractGrading.GPRangeNo = '0';
        contractGrading.ContractId = contract.Id;
        contractGrading.ContractPeriodId = contractPeriod.Id;
        contractGrading.GP = 10;
        return contractGrading;
    }

    public static Decimal getConvertPriceFromContractDefaultValue(String contractDefaultValue, Contract__c contract){
        if(String.isBlank(contractDefaultValue)) return 0;
        if(Utility.isDecimal(contractDefaultValue)){
            return Decimal.valueOf(contractDefaultValue);
        }
        return contract.get(contractDefaultValue) == null ? 0 : (Decimal) contract.get(contractDefaultValue);
    }

    public static User createUser(String profileName, String userName) {
        Profile profile = [SELECT Id,Name FROM Profile WHERE Name =: profileName];
        // String username = Utility.generateRandomString(10) + '@testorg.com';
        User user = new User(Alias = userName, 
                            Email=userName+'@siampiwat.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName=userName, 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', 
                            ProfileId = profile.Id, 
                            IsActive = true,
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            UserName = userName+'@siampiwat.com.dev');
        return user;

    }

    public static TriggerActivation__c mockupCustomSettingTrigger(String objectName) {
        TriggerActivation__c customSettingTrigger = new TriggerActivation__c();
        List<String> objectList = objectName.split(',');
        for(String eachObject : objectList){
            if(String.isBlank(eachObject)) continue;
            if(eachObject.trim() == 'Contract__c') customSettingTrigger.ContractTrigger__c = true;
            if(eachObject.trim() == 'Opportunity') customSettingTrigger.OpportunityTrigger__c = true;
            if(eachObject.trim() == 'PDF_Content__c') customSettingTrigger.PDFContentTrigger__c = true;
        }
        return customSettingTrigger;
    }

    public static Units__c createBuildingRentalObjectPack(){
        Branch__c br = new Branch__c(Name='Test');
        insert(br);

        Building__c testBuilding = MockUpDataFor_Test.createBuilding(br, 'buildingName',
                                                                    'buildingNameTH',
                                                                    'abbr',
                                                                    'bCode');
        insert testBuilding;
        //System.debug('testBuilding:'+testBuilding);

        Floor__c testBuildingFloor = MockUpDataFor_Test.createBuildingFloor(testBuilding, 'Fl0', 'Fl000', 'Test Floor Name');
        insert testBuildingFloor;

        Units__c testRentalObject = MockUpDataFor_Test.createRentalObject(testBuilding, testBuildingFloor, 'Retail Shop');
        insert testRentalObject;

        List<Measurement__c> rentalObjectMeaurementList = new List<Measurement__c>();
        List<String> measurementMap = new List<String>{'Footprint Area'};
        for (String eachMeasurement : measurementMap) {
            rentalObjectMeaurementList.add(MockUpDataFor_Test.createROMeasurement(testRentalObject, eachMeasurement, 100));
        }
        insert rentalObjectMeaurementList;

        return testRentalObject;
    }

    public static Units__c createBuildingRentalObjectPackWhenSeeAllData(){
        Branch__c br = new Branch__c(Name='Test');
        insert(br);

        Building__c testBuilding = MockUpDataFor_Test.createBuilding(br, 'buildingName',
                                                                    'buildingNameTH',
                                                                    'abbr',
                                                                    'bCode');
        insert testBuilding;

        Floor__c testBuildingFloor = MockUpDataFor_Test.createBuildingFloor(testBuilding, 'Fl0', 'Fl000', 'Test Floor Name');
        insert testBuildingFloor;

        Units__c testRentalObject = MockUpDataFor_Test.createRentalObject(testBuilding, testBuildingFloor, 'Retail Shop');
        insert testRentalObject;

        List<Measurement__c> rentalObjectMeaurementList = new List<Measurement__c>();
        List<String> measurementMap = new List<String>{'Footprint Area'};
        for (String eachMeasurement : measurementMap) {
            rentalObjectMeaurementList.add(MockUpDataFor_Test.createROMeasurement(testRentalObject, eachMeasurement, 100));
        }
        insert rentalObjectMeaurementList;

        return testRentalObject;
    }

    public static Building__c createBuildingPack(){
        Branch__c br = new Branch__c(Name='Test');
        insert(br);

        Building__c testBuilding = MockUpDataFor_Test.createBuilding(br, 'Building Pack',
                                                                    'Building Pack TH',
                                                                    'BU01',
                                                                    '00001');
        upsert testBuilding Building_ExtID__c;
        return testBuilding;
    }

    public static void generateOppSetting(){
        OpportunitySetting__c oppSetting = new OpportunitySetting__c(
                                                    CAMEscalation__c = 5,
                                                    RentandServiceEscalation__c = 3,
                                                    RentProportion__c = 40,
                                                    ServiceProportion__c = 60,
                                                    Tax__c = 7,
                                                    UsageTypeRentWithVAT__c = 'Billboard',
                                                    QuotationExpiryDate__c = 2
                                                );
        insert  oppSetting;        
    }

    public static Account createIndividualAccountPackWhenSeeAllData(){
        Account account = MockUpDataFor_Test.createIndividualAccount('test', 'เทส', 'account', 'แอคเค้า', '1102903049021');
        insert account;
        system.debug('account mock 1489 : '+account);
        return account;

    }

    public static Opportunity createOpportunityPackWhenSeeAllData(){
        Account account = createIndividualAccountPackWhenSeeAllData();

        Contact contactPerson = MockUpDataFor_Test.createContactPerson(account.Id);
        insert contactPerson;

        Units__c rentalObject = createBuildingRentalObjectPackWhenSeeAllData();

        User mockUser = UserTest.mockUser('SPWG - Leasing Manager');
        insert mockUser;

        Opportunity opp = MockUpDataFor_Test.createOpp(OPP_NAME, 'Retail Shop', account, rentalObject, contactPerson);
        insert opp;

        return opp;
    }

    public static Opportunity createOpportunityRetailZonePack(){
        Account account = MockUpDataFor_Test.createIndividualAccount();

        Contact contactPerson = MockUpDataFor_Test.createContactPerson(account.Id);
        insert contactPerson;

        Units__c rentalObject = createBuildingRentalObjectPack();

        User mockUser = UserTest.mockUser('SPWG - Leasing Manager');
        insert mockUser;

        Opportunity opp = MockUpDataFor_Test.createOppRetailZone(OPP_NAME, 'Retail Shop', account, rentalObject, contactPerson);
        insert opp;

        return opp;
    }

    public static Opportunity createOpportunityPack(){
        Account account = MockUpDataFor_Test.createIndividualAccount();

        Contact contactPerson = MockUpDataFor_Test.createContactPerson(account.Id);
        insert contactPerson;

        Units__c rentalObject = createBuildingRentalObjectPack();

        User mockUser = UserTest.mockUser('Sales and Leasing');
        insert mockUser;

        Opportunity opp = MockUpDataFor_Test.createOpp(OPP_NAME, 'Retail Shop', account, rentalObject, contactPerson);
        insert opp;

        return opp;
    }

    public static OpportunityDepositExpense__c createOppDepositExpense(Opportunity opp, String subType, String type, String typeGroup){
        OpportunityDepositExpense__c oppDepositExpense = new OpportunityDepositExpense__c(
            Opportunity__c=opp.Id,
            HasRemark__c=false,
            Subtype__c= subType,
            Type__c= type,
            TypeGroup__c= typeGroup,
            Price__c=0
        );
        return oppDepositExpense;
    }

    public static void createShortLeaseGPOpp(Opportunity opp, String calculationMethod, Id buildingId){

        opp.Estimated_Contract_Start_Date__c = Date.today();
        opp.Estimated_Contract_End_Date__c = Date.today().addYears(3);
        opp.Contract_Type__c = Constant.OPP_CONTRACT_TYPE_SHORTLEASE_GP;
        opp.Calculation_Method__c = calculationMethod;
        opp.Deposit_Month__c = 6;
        opp.OptionToRenewYear__c = 3;
        opp.OptionToRenewwithPricing__c = true;
        opp.Building__c = buildingId;
        opp.Rental_Period_Year__c = 3;
        opp.Rental_Period_Month__c = 0;
        opp.Rental_Period_Day__c = 0;
        opp.Revenue_Collected_By__c = 'ผู้เช่าเก็บเงิน';
        opp.RentAndServiceEscalationRate__c = 5;
        opp.RentAndServiceEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationRate__c = 5;
    }

    public static void createLongLeaseFixOpp(Opportunity opp, String calculationMethod, Id buildingId){

        opp.Estimated_Contract_Start_Date__c = Date.today();
        opp.Estimated_Contract_End_Date__c = Date.today().addYears(3);
        opp.Contract_Type__c = Constant.OPP_CONTRACT_TYPE_LONGLEASE_FIXED;
        opp.Calculation_Method__c = calculationMethod;
        opp.Deposit_Month__c = 6;
        opp.OptionToRenewwithPricing__c = false;
        opp.Building__c = buildingId;
        opp.Rental_Period_Year__c = 3;
        opp.Rental_Period_Month__c = 0;
        opp.Rental_Period_Day__c = 0;
        opp.RentAndServiceEscalationRate__c = 5;
        opp.RentAndServiceEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationRate__c = 5;

    }

    public static void createQuotationPricingLongLeaseFixedPack(String calCulationMethod, String minType){
        Opportunity opp =  MockUpDataFor_Test.createOpportunityPack();
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        
        createLongLeaseFixOpp(opp, calCulationMethod, building.Id);
        update opp;

        Units__c testRentalObject = [SELECT Id FROM Units__c WHERE Name  = 'rental object name' LIMIT 1];
        OpportunityLineItem__c oppLineItem = MockUpDataFor_Test.createOppLineItem(opp, testRentalObject);
        insert oppLineItem;

        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        List<OpportunityDepositExpense__c> oppExpenseList = new List<OpportunityDepositExpense__c>();
        List<OpportunityPeriod__c> oppPeriodList = new List<OpportunityPeriod__c>();

        OpportunityPeriod__c oppPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, calCulationMethod);
        oppPeriod.Total__c = 100;
        oppPeriod.TotalArea__c = 100;
        oppPeriod.LeasableArea__c = 100;
        oppPeriod.RentMonth__c = 60;
        oppPeriod.ServiceMonth__c = 40;
        oppPeriod.IsIncludeCAM__c = false;
        oppPeriod.PeriodFrom__c = Date.today();
        oppPeriod.PeriodTo__c = Date.newInstance(Date.today().year()+1 , Date.today().month(), Date.today().day()-1);
        oppPeriod.MinType__c = minType;

        oppPeriodList.add(oppPeriod);


        OpportunityPeriod__c campPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_CAM);
        campPeriod.Total__c = 100;
        campPeriod.TotalArea__c = 100;
        campPeriod.LeasableArea__c = 100;
        campPeriod.IsIncludeCAM__c = false;
        
        oppPeriodList.add(campPeriod);

        OpportunityPeriod__c rentAndServicePeriod = MockUpDataFor_Test.createOppPeriod(opp, 0, Constant.CAL_METHOD_RENT_SERVICE);
        rentAndServicePeriod.Total__c = 100;
        rentAndServicePeriod.TotalArea__c = 100;
        rentAndServicePeriod.LeasableArea__c = 100;
        rentAndServicePeriod.IsIncludeCAM__c = false;
        
        oppPeriodList.add(rentAndServicePeriod);

        insert oppPeriodList;

        System.debug('oppPeriodList' + oppPeriodList);


        OpportunityPrice__c oppPriceForCAM;
        OpportunityPrice__c oppPriceForRentAndService;
        OpportunityPrice__c oppPriceForCalculationMethod;
        OpportunityPrice__c oppPriceForCalculationMethodProportion;
        Set<String> calculationMethodSet  = new Set<String>{
            Constant.CAL_METHOD_FIXED_PRICE,
            Constant.CAL_METHOD_FIXED_RO,
            Constant.CAL_METHOD_FIXED_MEAS
        };

        List<String> measurementList = new List<String>{'Footprint Area'};
        for (OpportunityPeriod__c eachOppPeriod : oppPeriodList) {
            
            if (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_RO) {
                    
                oppPriceForCalculationMethod = MockUpDataFor_Test.createOppPrice(opp, eachOppPeriod);
                oppPriceForCalculationMethod.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
                oppPriceForCalculationMethod.CalculationFormula__c = 'A';
                oppPriceForCalculationMethod.TotalPrice__c = 200;
                oppPriceForCalculationMethod.Price__c = 100;
                oppPriceForCalculationMethod.Unit__c = (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_RO) ? testRentalObject.Id : null;
                oppPriceList.add(oppPriceForCalculationMethod);

                oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Rent');
                oppPriceForCalculationMethod.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
                oppPriceForCalculationMethod.CalculationFormula__c = 'E1';
                oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                oppPriceForCalculationMethodProportion.Price__c = 100;
                oppPriceList.add(oppPriceForCalculationMethodProportion);

                oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Service');
                oppPriceForCalculationMethod.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
                oppPriceForCalculationMethod.CalculationFormula__c = 'E1';
                oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                oppPriceForCalculationMethodProportion.Price__c = 100;
                oppPriceList.add(oppPriceForCalculationMethodProportion);
            }

            for (String eachMeasruement : measurementList ) {


                if (calculationMethodSet.contains(eachOppPeriod.CalculationMethod__c)) {

                    if (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_PRICE || eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_MEAS) {
                        
                        oppPriceForCalculationMethod = MockUpDataFor_Test.createOppPrice(opp,eachOppPeriod, eachMeasruement, eachOppPeriod.CalculationMethod__c);
                        oppPriceForCalculationMethod.CalculationFormula__c = 'D';
                        oppPriceForCalculationMethod.TotalPrice__c = 200;
                        oppPriceForCalculationMethod.Price__c = 100;
                        oppPriceForCalculationMethod.MeasurementAmount__c = 100;
                        oppPriceList.add(oppPriceForCalculationMethod);

                        oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Rent');
                        oppPriceForCalculationMethodProportion.CalculationMethod__c = eachOppPeriod.CalculationMethod__c;
                        oppPriceForCalculationMethodProportion.CalculationFormula__c = 'E1';
                        oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                        oppPriceForCalculationMethodProportion.Price__c = 100;
                        oppPriceForCalculationMethodProportion.MeasurementAmount__c = 100;
                        oppPriceList.add(oppPriceForCalculationMethodProportion);

                        oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Service');
                        oppPriceForCalculationMethodProportion.CalculationMethod__c = eachOppPeriod.CalculationMethod__c;
                        oppPriceForCalculationMethodProportion.CalculationFormula__c = 'E1';
                        oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                        oppPriceForCalculationMethodProportion.Price__c = 100;
                        oppPriceForCalculationMethodProportion.MeasurementAmount__c = 100;
                        oppPriceList.add(oppPriceForCalculationMethodProportion);
                    }
                    
                }else{

                    if (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_CAM) {

                        oppPriceForCAM = MockUpDataFor_Test.createOppPrice(opp, campPeriod, eachMeasruement, Constant.CAL_METHOD_CAM);
                        oppPriceForCAM.SubType__c  = Constant.CAL_METHOD_CAM;
                        oppPriceForCAM.CalculationFormula__c = 'D';
                        oppPriceForCAM.TotalPrice__c = 200;
                        oppPriceForCAM.MeasurementAmount__c = 100;
                        oppPriceForCAM.Price__c = 100;
                        
                        oppPriceList.add(oppPriceForCAM);
                    }else if(eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_RENT_SERVICE){
                        oppPriceForRentAndService = MockUpDataFor_Test.createOppPrice(opp, rentAndServicePeriod, eachMeasruement, Constant.CAL_METHOD_RENT_SERVICE);
                        oppPriceForRentAndService.SubType__c  = Constant.CAL_METHOD_RENT_SERVICE;
                        oppPriceForRentAndService.TotalPrice__c = 200;
                        oppPriceForRentAndService.MeasurementAmount__c = 100;
                        oppPriceForRentAndService.Price__c = 100;
                        
                        oppPriceList.add(oppPriceForRentAndService);            

                    }
                }

            }
        }

        OpportunityDepositExpense__c securityDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Security Deposit', Constant.TYPE_DEPOSIT);
        securityDeposit.Price__c = 1000;
        securityDeposit.NumberOfInstallment__c = 1;
        securityDeposit.Remark__c = 'Test';
        securityDeposit.NumberOfMonth__c = 6;
        securityDeposit.DepositInputMethod__c = 'System Calculation';
        securityDeposit.CarriedDepositRent__c = 1000; 
        securityDeposit.CarriedDepositService__c = 1000; 
        securityDeposit.CarriedDepositCAM__c = 1000;
        securityDeposit.RentDeposit__c = 1000;
        securityDeposit.ServiceDeposit__c = 1000;
        securityDeposit.CAMDeposit__c = 1000;

        oppExpenseList.add(securityDeposit);

        OpportunityDepositExpense__c securityOtherDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Furniture Deposit', Constant.TYPE_DEPOSIT);
        securityOtherDeposit.Price__c = 1000;
        securityOtherDeposit.NumberOfInstallment__c = 1;
        oppExpenseList.add(securityOtherDeposit);

        OpportunityDepositExpense__c expenseDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'First Entry Fee', Constant.TYPE_EXPENSE);
        expenseDeposit.Price__c = 1000;
        expenseDeposit.NumberOfInstallment__c = 1;
        oppExpenseList.add(expenseDeposit);

        OpportunityDepositExpense__c otherDepositCahier = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Cashier', Constant.TYPE_OTHER);
        otherDepositCahier.Price__c = 1000;
        oppExpenseList.add(otherDepositCahier);

        OpportunityDepositExpense__c otherDepositElectric = MockUpDataFor_Test.createOppDepositExpense(opp, 'Fixed Price' , 'Electric', Constant.TYPE_OTHER);
        otherDepositElectric.Price__c = 1000;
        oppExpenseList.add(otherDepositElectric);

        insert oppExpenseList;

        List<String> depositSubType  = new List<String>{'Rent','Service','CAM'};
        for (OpportunityDepositExpense__c eachOppExpense : oppExpenseList) {
            
            if (eachOppExpense.TypeGroup__c == Constant.TYPE_DEPOSIT) {
                
                for (String eachSubType : depositSubType) {
                    oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = eachSubType,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
                
                }
            }else if(eachOppExpense.TypeGroup__c == Constant.TYPE_EXPENSE){
                for (Integer i = 0; i < eachOppExpense.NumberOfInstallment__c ; i ++ ) {
                    
                    oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = Constant.DEP_EXP_SUBTYPE_INSTALLMENT,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
                }
            }else if(eachOppExpense.TypeGroup__c == Constant.TYPE_OTHER){
                oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = eachOppExpense.SubType__c,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
            }
        }


        insert oppPriceList;

    }
    
    public static void createQuotationPricingPack(String calCulationMethod, String minType){
        Opportunity opp =  MockUpDataFor_Test.createOpportunityPack();
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];

        if (calCulationMethod == Constant.CAL_METHOD_GP_NOMIN || calCulationMethod == Constant.CAL_METHOD_GP_WITHMIN ||  calCulationMethod == Constant.CAL_METHOD_GP_ONTOP){
            createShortLeaseGPOpp(opp, calCulationMethod, building.Id);
        }else{
            createShortLeaseFixOpp(opp, calCulationMethod, building.Id);
        }
        update opp;

        Units__c testRentalObject = [SELECT Id FROM Units__c WHERE Name  = 'rental object name' LIMIT 1];
        OpportunityLineItem__c oppLineItem = MockUpDataFor_Test.createOppLineItem(opp, testRentalObject);
        insert oppLineItem;

        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        List<OpportunityGradingModel.Data> oppGradingList = new List<OpportunityGradingModel.Data>();
        List<OpportunityDepositExpense__c> oppExpenseList = new List<OpportunityDepositExpense__c>();
        List<OpportunityPeriod__c> oppPeriodList = new List<OpportunityPeriod__c>();

        OpportunityPeriod__c oppPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, calCulationMethod);
        oppPeriod.Total__c = 100;
        oppPeriod.TotalArea__c = 100;
        oppPeriod.LeasableArea__c = 100;
        oppPeriod.RentMonth__c = 60;
        oppPeriod.ServiceMonth__c = 40;
        oppPeriod.RentPercent__c = 60;
        oppPeriod.ServicePercent__c = 40;
        oppPeriod.IsIncludeCAM__c = false;
        oppPeriod.PeriodFrom__c = Date.today();
        oppPeriod.PeriodTo__c = Date.newInstance(Date.today().year()+1 , Date.today().month(), Date.today().day()-1);
        oppPeriod.MinType__c = minType;

        oppPeriodList.add(oppPeriod);

        OpportunityPeriod__c oppPeriod2 = MockUpDataFor_Test.createOppPeriod(opp, 2, calCulationMethod);
        oppPeriod2.Total__c = 100;
        oppPeriod2.TotalArea__c = 100;
        oppPeriod2.LeasableArea__c = 100;
        oppPeriod2.RentMonth__c = 60;
        oppPeriod2.ServiceMonth__c = 40;
        oppPeriod2.RentPercent__c = 60;
        oppPeriod2.ServicePercent__c = 40;
        oppPeriod2.IsIncludeCAM__c = false;
        oppPeriod2.PeriodFrom__c = oppPeriod.PeriodTo__c.addDays(1);
        oppPeriod2.PeriodTo__c = Date.newInstance(oppPeriod2.PeriodFrom__c.year()+1 , oppPeriod2.PeriodFrom__c.month(), oppPeriod2.PeriodFrom__c.day()-1);
        oppPeriod2.MinType__c = minType;

        oppPeriodList.add(oppPeriod2);

        OpportunityPeriod__c campPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_CAM);
        campPeriod.Total__c = 100;
        campPeriod.TotalArea__c = 100;
        campPeriod.LeasableArea__c = 100;
        campPeriod.IsIncludeCAM__c = false;
        
        oppPeriodList.add(campPeriod);

        OpportunityPeriod__c rentAndServicePeriod = MockUpDataFor_Test.createOppPeriod(opp, 0, Constant.CAL_METHOD_RENT_SERVICE);
        rentAndServicePeriod.Total__c = 100;
        rentAndServicePeriod.TotalArea__c = 100;
        rentAndServicePeriod.LeasableArea__c = 100;
        rentAndServicePeriod.IsIncludeCAM__c = false;
        
        oppPeriodList.add(rentAndServicePeriod);

        insert oppPeriodList;

        System.debug('oppPeriodList' + oppPeriodList);


        OpportunityPrice__c oppPriceForCAM;
        OpportunityPrice__c oppPriceForRentAndService;
        OpportunityPrice__c oppPriceForCalculationMethod;
        OpportunityPrice__c oppPriceForCalculationMethodProportion;
        Set<String> calculationMethodSet  = new Set<String>{
            Constant.CAL_METHOD_FIXED_PRICE,
            Constant.CAL_METHOD_FIXED_RO,
            Constant.CAL_METHOD_FIXED_MEAS,
            Constant.CAL_METHOD_GP_NOMIN,
            Constant.CAL_METHOD_GP_WITHMIN,
            Constant.CAL_METHOD_GP_ONTOP
        };

        List<String> measurementList = new List<String>{'Footprint Area'};
        for (OpportunityPeriod__c eachOppPeriod : oppPeriodList) {
            
            if (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_RO || eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_NOMIN || (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_WITHMIN && minType == Constant.PAGE_MASTER_FORMAT_FIXED)  || (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_ONTOP && minType == Constant.PAGE_MASTER_FORMAT_FIXED)) {
                    
                oppPriceForCalculationMethod = MockUpDataFor_Test.createOppPrice(opp, eachOppPeriod);
                oppPriceForCalculationMethod.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
                oppPriceForCalculationMethod.CalculationFormula__c = 'A';
                oppPriceForCalculationMethod.TotalPrice__c = 200;
                oppPriceForCalculationMethod.Price__c = 100;
                oppPriceForCalculationMethod.Unit__c = (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_RO) ? testRentalObject.Id : null;
                oppPriceList.add(oppPriceForCalculationMethod);

                oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Rent');
                oppPriceForCalculationMethod.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
                oppPriceForCalculationMethod.CalculationFormula__c = 'E1';
                oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                oppPriceForCalculationMethodProportion.Price__c = 100;
                oppPriceList.add(oppPriceForCalculationMethodProportion);

                oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Service');
                oppPriceForCalculationMethod.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
                oppPriceForCalculationMethod.CalculationFormula__c = 'E1';
                oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                oppPriceForCalculationMethodProportion.Price__c = 100;
                oppPriceList.add(oppPriceForCalculationMethodProportion);
            }

            if (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_NOMIN || eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_WITHMIN ||  eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_ONTOP) {

                OpportunityGradingModel.Data oppGrading = MockUpDataFor_Test.createOppGrading(opp, eachOppPeriod, 0, 10);
                oppGradingList.add(oppGrading);
            }

            for (String eachMeasruement : measurementList ) {


                if (calculationMethodSet.contains(eachOppPeriod.CalculationMethod__c)) {

                    if (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_PRICE || eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_MEAS || (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_WITHMIN && minType == Constant.MEASUREMENT)  || (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_ONTOP && minType == Constant.MEASUREMENT)) {
                        
                        oppPriceForCalculationMethod = MockUpDataFor_Test.createOppPrice(opp,eachOppPeriod, eachMeasruement, eachOppPeriod.CalculationMethod__c);
                        oppPriceForCalculationMethod.CalculationFormula__c = 'D';
                        oppPriceForCalculationMethod.TotalPrice__c = 200;
                        oppPriceForCalculationMethod.Price__c = 100;
                        oppPriceForCalculationMethod.MeasurementAmount__c = 100;
                        oppPriceList.add(oppPriceForCalculationMethod);

                        oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Rent');
                        oppPriceForCalculationMethodProportion.CalculationMethod__c = eachOppPeriod.CalculationMethod__c;
                        oppPriceForCalculationMethodProportion.CalculationFormula__c = 'E1';
                        oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                        oppPriceForCalculationMethodProportion.Price__c = 100;
                        oppPriceForCalculationMethodProportion.MeasurementAmount__c = 100;
                        oppPriceList.add(oppPriceForCalculationMethodProportion);

                        oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Service');
                        oppPriceForCalculationMethodProportion.CalculationMethod__c = eachOppPeriod.CalculationMethod__c;
                        oppPriceForCalculationMethodProportion.CalculationFormula__c = 'E1';
                        oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                        oppPriceForCalculationMethodProportion.Price__c = 100;
                        oppPriceForCalculationMethodProportion.MeasurementAmount__c = 100;
                        oppPriceList.add(oppPriceForCalculationMethodProportion);
                    }
                    
                }else{

                    if (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_CAM) {

                        oppPriceForCAM = MockUpDataFor_Test.createOppPrice(opp, campPeriod, eachMeasruement, Constant.CAL_METHOD_CAM);
                        oppPriceForCAM.SubType__c  = Constant.CAL_METHOD_CAM;
                        oppPriceForCAM.CalculationFormula__c = 'D';
                        oppPriceForCAM.TotalPrice__c = 200;
                        oppPriceForCAM.MeasurementAmount__c = 100;
                        oppPriceForCAM.Price__c = 100;
                        
                        oppPriceList.add(oppPriceForCAM);
                    }else if(eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_RENT_SERVICE){
                        oppPriceForRentAndService = MockUpDataFor_Test.createOppPrice(opp, rentAndServicePeriod, eachMeasruement, Constant.CAL_METHOD_RENT_SERVICE);
                        oppPriceForRentAndService.SubType__c  = Constant.CAL_METHOD_RENT_SERVICE;
                        oppPriceForRentAndService.TotalPrice__c = 200;
                        oppPriceForRentAndService.MeasurementAmount__c = 100;
                        oppPriceForRentAndService.Price__c = 100;
                        
                        oppPriceList.add(oppPriceForRentAndService);            

                    }
                }

            }
        }

        OpportunityDepositExpense__c securityDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Security Deposit', Constant.TYPE_DEPOSIT);
        securityDeposit.Price__c = 1000;
        securityDeposit.NumberOfInstallment__c = 1;
        securityDeposit.Remark__c = 'Test';
        securityDeposit.NumberOfMonth__c = 6;
        securityDeposit.DepositInputMethod__c = 'System Calculation';
        securityDeposit.CarriedDepositRent__c = 1000; 
        securityDeposit.CarriedDepositService__c = 1000; 
        securityDeposit.CarriedDepositCAM__c = 1000;
        securityDeposit.RentDeposit__c = 1000;
        securityDeposit.ServiceDeposit__c = 1000;
        securityDeposit.CAMDeposit__c = 1000;

        oppExpenseList.add(securityDeposit);

        OpportunityDepositExpense__c securityOtherDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Furniture Deposit', Constant.TYPE_DEPOSIT);
        securityOtherDeposit.Price__c = 1000;
        securityOtherDeposit.NumberOfInstallment__c = 1;
        oppExpenseList.add(securityOtherDeposit);

        OpportunityDepositExpense__c expenseDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'First Entry Fee', Constant.TYPE_EXPENSE);
        expenseDeposit.Price__c = 1000;
        expenseDeposit.NumberOfInstallment__c = 1;
        oppExpenseList.add(expenseDeposit);

        OpportunityDepositExpense__c otherDepositCahier = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Cashier', Constant.TYPE_OTHER);
        otherDepositCahier.Price__c = 1000;
        oppExpenseList.add(otherDepositCahier);

        OpportunityDepositExpense__c otherDepositElectric = MockUpDataFor_Test.createOppDepositExpense(opp, 'Fixed Price' , 'Electric', Constant.TYPE_OTHER);
        otherDepositElectric.Price__c = 1000;
        oppExpenseList.add(otherDepositElectric);

        insert oppExpenseList;

        List<String> depositSubType  = new List<String>{'Rent','Service','CAM'};
        for (OpportunityDepositExpense__c eachOppExpense : oppExpenseList) {
            
            if (eachOppExpense.TypeGroup__c == Constant.TYPE_DEPOSIT) {
                
                for (String eachSubType : depositSubType) {
                    oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = eachSubType,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
                
                }
            }else if(eachOppExpense.TypeGroup__c == Constant.TYPE_EXPENSE){
                for (Integer i = 0; i < eachOppExpense.NumberOfInstallment__c ; i ++ ) {
                    
                    oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = Constant.DEP_EXP_SUBTYPE_INSTALLMENT,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
                }
            }else if(eachOppExpense.TypeGroup__c == Constant.TYPE_OTHER){
                oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = eachOppExpense.SubType__c,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
            }
        }


        insert oppPriceList;
        opp.OpportunityGrading__c = OpportunityGradingModel.toString(oppGradingList);
        update(opp);

    }

    public static void createQuotationPricingPack(){
        Opportunity opp =  MockUpDataFor_Test.createOpportunityPack();
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];

        createShortLeaseFixOpp(opp, Constant.CAL_METHOD_FIXED_PRICE, building.Id);
        update opp;

        Units__c testRentalObject = [SELECT Id FROM Units__c LIMIT 1];
        OpportunityLineItem__c oppLineItem = MockUpDataFor_Test.createOppLineItem(opp, testRentalObject);
        insert oppLineItem;

        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        List<OpportunityDepositExpense__c> oppExpenseList = new List<OpportunityDepositExpense__c>();
        List<OpportunityGradingModel.Data> oppGradingList = new List<OpportunityGradingModel.Data>();
        List<OpportunityPeriod__c> oppPeriodList = new List<OpportunityPeriod__c>();

        OpportunityPeriod__c oppPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_FIXED_PRICE);
        oppPeriod.Total__c = 100;
        oppPeriod.TotalArea__c = 100;
        oppPeriod.LeasableArea__c = 100;
        oppPeriod.RentMonth__c = 60;
        oppPeriod.ServiceMonth__c = 40;
        oppPeriod.RentPercent__c = 60;
        oppPeriod.ServicePercent__c = 40;
        oppPeriod.IsIncludeCAM__c = false;
        oppPeriod.PeriodFrom__c = Date.today();
        oppPeriod.PeriodTo__c = Date.newInstance(Date.today().year()+1 , Date.today().month(), Date.today().day()-1);
        oppPeriod.MinType__c = Constant.MEASUREMENT;

        oppPeriodList.add(oppPeriod);

        OpportunityPeriod__c oppPeriod2 = MockUpDataFor_Test.createOppPeriod(opp, 2, Constant.CAL_METHOD_FIXED_PRICE);
        oppPeriod2.Total__c = 100;
        oppPeriod2.TotalArea__c = 100;
        oppPeriod2.LeasableArea__c = 100;
        oppPeriod2.RentMonth__c = 60;
        oppPeriod2.ServiceMonth__c = 40;
        oppPeriod2.RentPercent__c = 60;
        oppPeriod2.ServicePercent__c = 40;
        oppPeriod2.IsIncludeCAM__c = false;
        oppPeriod2.PeriodFrom__c = oppPeriod.PeriodTo__c.addDays(1);
        oppPeriod2.PeriodTo__c = Date.newInstance(oppPeriod2.PeriodFrom__c.year()+1 , oppPeriod2.PeriodFrom__c.month(), oppPeriod2.PeriodFrom__c.day()-1);
        oppPeriod2.MinType__c = Constant.MEASUREMENT;

        oppPeriodList.add(oppPeriod2);

        OpportunityPeriod__c campPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_CAM);
        campPeriod.Total__c = 100;
        campPeriod.TotalArea__c = 100;
        campPeriod.LeasableArea__c = 100;
        campPeriod.IsIncludeCAM__c = false;
        
        oppPeriodList.add(campPeriod);

        OpportunityPeriod__c rentAndServicePeriod = MockUpDataFor_Test.createOppPeriod(opp, 0, Constant.CAL_METHOD_RENT_SERVICE);
        rentAndServicePeriod.Total__c = 100;
        rentAndServicePeriod.TotalArea__c = 100;
        rentAndServicePeriod.LeasableArea__c = 100;
        rentAndServicePeriod.IsIncludeCAM__c = false;
        
        oppPeriodList.add(rentAndServicePeriod);

        insert oppPeriodList;

        OpportunityPrice__c oppPriceForCAM;
        OpportunityPrice__c oppPriceForRentAndService;
        OpportunityPrice__c oppPriceForCalculationMethod;
        OpportunityPrice__c oppPriceForCalculationMethodProportion;
        Set<String> calculationMethodSet  = new Set<String>{
            Constant.CAL_METHOD_FIXED_PRICE,
            Constant.CAL_METHOD_FIXED_RO,
            Constant.CAL_METHOD_FIXED_MEAS,
            Constant.CAL_METHOD_GP_NOMIN,
            Constant.CAL_METHOD_GP_WITHMIN,
            Constant.CAL_METHOD_GP_ONTOP
        };

        List<String> measurementList = new List<String>{'Footprint Area'};
        for (OpportunityPeriod__c eachOppPeriod : oppPeriodList) {
            
            for (String eachMeasruement : measurementList ) {

                if (calculationMethodSet.contains(eachOppPeriod.CalculationMethod__c)) {
                    
                    oppPriceForCalculationMethod = MockUpDataFor_Test.createOppPrice(opp,eachOppPeriod, eachMeasruement, eachOppPeriod.CalculationMethod__c);
                    oppPriceForCalculationMethod.CalculationFormula__c = 'D';
                    oppPriceForCalculationMethod.TotalPrice__c = 200;
                    oppPriceForCalculationMethod.MeasurementAmount__c = 200;
                    oppPriceForCalculationMethod.Price__c = 100;
                    oppPriceList.add(oppPriceForCalculationMethod);

                    oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Rent');
                    oppPriceForCalculationMethodProportion.CalculationFormula__c = 'E1';
                    oppPriceForCalculationMethodProportion.TotalPrice__c = 200; 
                    oppPriceForCalculationMethodProportion.Price__c = 100;
                    oppPriceForCalculationMethodProportion.MeasurementAmount__c = 200;
                    oppPriceList.add(oppPriceForCalculationMethodProportion);

                    oppPriceForCalculationMethodProportion = MockUpDataFor_Test.createOppPriceWithProportion(opp,eachOppPeriod,50,'Service');
                    oppPriceForCalculationMethodProportion.CalculationFormula__c = 'E1';
                    oppPriceForCalculationMethodProportion.TotalPrice__c = 200;
                    oppPriceForCalculationMethodProportion.Price__c = 100;
                    oppPriceForCalculationMethodProportion.MeasurementAmount__c = 200;
                    oppPriceList.add(oppPriceForCalculationMethodProportion);
                }else{

                    if (eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_CAM) {

                        oppPriceForCAM = MockUpDataFor_Test.createOppPrice(opp, campPeriod, eachMeasruement, Constant.CAL_METHOD_CAM);
                        oppPriceForCAM.SubType__c  = Constant.CAL_METHOD_CAM;
                        oppPriceForCAM.CalculationFormula__c = 'D';
                        oppPriceForCAM.TotalPrice__c = 200;
                        oppPriceForCAM.Price__c = 100;
                        
                        oppPriceList.add(oppPriceForCAM);
                    }else if(eachOppPeriod.CalculationMethod__c == Constant.CAL_METHOD_RENT_SERVICE){
                        oppPriceForRentAndService = MockUpDataFor_Test.createOppPrice(opp, rentAndServicePeriod, eachMeasruement, Constant.CAL_METHOD_RENT_SERVICE);
                        oppPriceForRentAndService.SubType__c  = Constant.CAL_METHOD_RENT_SERVICE;
                        oppPriceForRentAndService.TotalPrice__c = 200;
                        oppPriceForRentAndService.Price__c = 100;
                        
                        oppPriceList.add(oppPriceForRentAndService);            

                    }
                }

            }
        }

        OpportunityDepositExpense__c securityDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Security Deposit', Constant.TYPE_DEPOSIT);
        securityDeposit.Price__c = 1000;
        securityDeposit.NumberOfInstallment__c = 1;
        securityDeposit.Remark__c = 'Test';
        securityDeposit.NumberOfMonth__c = 6;
        securityDeposit.DepositInputMethod__c = 'System Calculation';
        securityDeposit.CarriedDepositRent__c = 1000; 
        securityDeposit.CarriedDepositService__c = 1000; 
        securityDeposit.CarriedDepositCAM__c = 1000;
        securityDeposit.RentDeposit__c = 1000;
        securityDeposit.ServiceDeposit__c = 1000;
        securityDeposit.CAMDeposit__c = 1000;

        oppExpenseList.add(securityDeposit);

        OpportunityDepositExpense__c securityOtherDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Furniture Deposit', Constant.TYPE_DEPOSIT);
        securityOtherDeposit.Price__c = 1000;
        securityOtherDeposit.NumberOfInstallment__c = 1;
        oppExpenseList.add(securityOtherDeposit);

        OpportunityDepositExpense__c expenseDeposit = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'First Entry Fee', Constant.TYPE_EXPENSE);
        expenseDeposit.Price__c = 1000;
        expenseDeposit.NumberOfInstallment__c = 1;
        oppExpenseList.add(expenseDeposit);

        OpportunityDepositExpense__c otherDepositCahier = MockUpDataFor_Test.createOppDepositExpense(opp, '' , 'Cashier', Constant.TYPE_OTHER);
        otherDepositCahier.Price__c = 1000;
        oppExpenseList.add(otherDepositCahier);

        OpportunityDepositExpense__c otherDepositElectric = MockUpDataFor_Test.createOppDepositExpense(opp, 'Fixed Price' , 'Electric', Constant.TYPE_OTHER);
        otherDepositElectric.Price__c = 1000;
        oppExpenseList.add(otherDepositElectric);

        insert oppExpenseList;

        List<String> depositSubType  = new List<String>{'Rent','Service','CAM'};
        for (OpportunityDepositExpense__c eachOppExpense : oppExpenseList) {
            
            if (eachOppExpense.TypeGroup__c == Constant.TYPE_DEPOSIT) {
                
                for (String eachSubType : depositSubType) {
                    oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = eachSubType,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
                
                }
            }else if(eachOppExpense.TypeGroup__c == Constant.TYPE_EXPENSE){
                for (Integer i = 0; i < eachOppExpense.NumberOfInstallment__c ; i ++ ) {
                    
                    oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = Constant.DEP_EXP_SUBTYPE_INSTALLMENT,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
                }
            }else if(eachOppExpense.TypeGroup__c == Constant.TYPE_OTHER){
                oppPriceList.add(new OpportunityPrice__c(
                        SubType__c = eachOppExpense.SubType__c,
                        TotalPriceVAT__c = 1000,
                        Price__c = 100000,
                        TotalPrice__c = 10000,
                        OpportunityDepositExpense__c = eachOppExpense.Id,
                        From__c = Date.today(),
                        To__c = Date.today(),
                        Opportunity__c = opp.Id
                        ));
            }
        }

        insert oppPriceList;


        OpportunityGradingModel.Data oppGrading = MockUpDataFor_Test.createOppGrading(opp, oppPeriod, 0, 10);
        oppGradingList.add(oppGrading);

        OpportunityGradingModel.Data oppGrading2 = MockUpDataFor_Test.createOppGrading(opp, oppPeriod2, 10, 20);
        oppGradingList.add(oppGrading2);

    }

    public static void createQuotationPricingRetailZonePack(){
        Opportunity opp =  MockUpDataFor_Test.createOpportunityRetailZonePack();
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_WITHMIN);
        update opp;
        Units__c testRentalObject = [SELECT Id FROM Units__c LIMIT 1];
        OpportunityLineItem__c oppLineItem = MockUpDataFor_Test.createOppLineItem(opp, testRentalObject);
        insert oppLineItem;

        OpportunityPeriod__c oppPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_FIXED_PRICE);
        oppPeriod.Total__c = 100;
        oppPeriod.TotalArea__c = 100;
        oppPeriod.LeasableArea__c = 100;
        oppPeriod.RentMonth__c = 60;
        oppPeriod.ServiceMonth__c = 40;
        oppPeriod.RentPercent__c = 60;
        oppPeriod.ServicePercent__c = 40;
        oppPeriod.IsIncludeCAM__c = false;
        oppPeriod.PeriodFrom__c = Date.today();
        oppPeriod.PeriodTo__c = Date.newInstance(Date.today().year()+1 , Date.today().month(), Date.today().day()-1);

        insert oppPeriod;

        OpportunityPeriod__c campPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_CAM);
        campPeriod.Total__c = 100;
        campPeriod.TotalArea__c = 100;
        campPeriod.LeasableArea__c = 100;
        campPeriod.IsIncludeCAM__c = false;
        
        insert campPeriod;

        OpportunityDepositExpense__c depositExpense = MockUpDataFor_Test.createOppDepositExpense(opp);
        insert depositExpense;

        OpportunityPrice__c oppPrice = MockUpDataFor_Test.createOppPriceWithProportion(opp,oppPeriod,50,'Rent');
        insert oppPrice;

        OpportunityPrice__c oppPrice2 = MockUpDataFor_Test.createOppPriceWithProportion(opp,oppPeriod,50,'Service');
        insert oppPrice2;

        List<OpportunityGradingModel.Data> gradingList = new List<OpportunityGradingModel.Data>();
        OpportunityGradingModel.Data oppGrading = MockUpDataFor_Test.createOppGrading(opp, oppPeriod, 0, 10);
        gradingList.add(oppGrading);

        OpportunityGradingModel.Data oppGrading2 = MockUpDataFor_Test.createOppGrading(opp, oppPeriod, 0, 0);
        gradingList.add(oppGrading2);
        opp.OpportunityGrading__c = OpportunityGradingModel.toString(gradingList);
        update(opp);
    }

    public static void createQuotationPricingPack2Pricing(){
        Opportunity opp =  MockUpDataFor_Test.createOpportunityPack();
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_WITHMIN);
        update opp;
        Units__c testRentalObject = [SELECT Id FROM Units__c LIMIT 1];
        OpportunityLineItem__c oppLineItem = MockUpDataFor_Test.createOppLineItem(opp, testRentalObject);
        insert oppLineItem;

        OpportunityPeriod__c oppPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_FIXED_PRICE);
        oppPeriod.Total__c = 100;
        oppPeriod.TotalArea__c = 100;
        oppPeriod.LeasableArea__c = 100;
        oppPeriod.RentMonth__c = 60;
        oppPeriod.ServiceMonth__c = 40;
        oppPeriod.RentPercent__c = 60;
        oppPeriod.ServicePercent__c = 40;
        oppPeriod.IsIncludeCAM__c = false;
        oppPeriod.PeriodFrom__c = Date.today();
        oppPeriod.PeriodTo__c = Date.newInstance(Date.today().year()+1 , Date.today().month(), Date.today().day()-1);

        OpportunityPeriod__c campPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_CAM);
        campPeriod.Total__c = 100;
        campPeriod.TotalArea__c = 100;
        campPeriod.LeasableArea__c = 100;
        campPeriod.IsIncludeCAM__c = false;
    
        List<OpportunityPeriod__c> oppPeriodList = new List<OpportunityPeriod__c>{oppPeriod, campPeriod};
        insert oppPeriodList;

        OpportunityDepositExpense__c depositExpense = MockUpDataFor_Test.createOppDepositExpense(opp);
        OpportunityDepositExpense__c depositExpenseSD = MockUpDataFor_Test.createOppDepositExpenseSD(opp);
        OpportunityDepositExpense__c depositExpenseRentRight = MockUpDataFor_Test.createOppDepositExpenseSD(opp);
        depositExpenseRentRight.Type__c = Constant.DEP_EXP_TYPE_LEASEHOLD_FOOTPRINT;
        depositExpenseRentRight.TypeGroup__c = Constant.TYPE_EXPENSE;
        List<OpportunityDepositExpense__c> oppDepositList = new List<OpportunityDepositExpense__c>{depositExpense, depositExpenseSD, depositExpenseRentRight};
        insert oppDepositList;

        OpportunityPrice__c oppPrice = MockUpDataFor_Test.createOppPriceWithProportion(opp,oppPeriod,50,'Rent');

        OpportunityPrice__c oppPrice2 = MockUpDataFor_Test.createOppPriceWithProportion(opp,oppPeriod,50,'Service');

        OpportunityPrice__c oppPrice3 = MockUpDataFor_Test.createOppPriceDeposit(opp, depositExpenseSD, 'Rent');

        OpportunityPrice__c oppPriceRentFTInstallment = MockUpDataFor_Test.createOppPriceDeposit(opp, depositExpenseRentRight, 'Installment');
        OpportunityPrice__c oppPriceRentFTFull = MockUpDataFor_Test.createOppPriceDeposit(opp, depositExpenseRentRight, null);

        List<OpportunityGradingModel.Data> gradingList = new List<OpportunityGradingModel.Data>();
        OpportunityGradingModel.Data oppGrading = MockUpDataFor_Test.createOppGrading(opp, oppPeriod, 0, 10);
        gradingList.add(oppGrading);
        OpportunityGradingModel.Data oppGrading2 = MockUpDataFor_Test.createOppGrading(opp, oppPeriod, 0, 0);
        gradingList.add(oppGrading2);
        
        List<SObject> relatedOppList = new List<SObject>{oppPrice, oppPrice2, oppPrice3, oppPriceRentFTInstallment, oppPriceRentFTFull};
        insert relatedOppList;

        opp.OpportunityGrading__c = OpportunityGradingModel.toString(gradingList);
        update(opp);
    }

    public static void createQuotationPricingPack2Pricing(Opportunity opp, Units__c rentalObject){
        /*Opportunity opp =  MockUpDataFor_Test.createOpportunityPack();*/
        OpportunityLineItem__c oppLineItem = MockUpDataFor_Test.createOppLineItem(opp, rentalObject);
        insert oppLineItem;

        OpportunityPeriod__c oppPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_FIXED_PRICE);
        oppPeriod.Total__c = 100;
        oppPeriod.TotalArea__c = 100;
        oppPeriod.LeasableArea__c = 100;
        oppPeriod.RentMonth__c = 60;
        oppPeriod.ServiceMonth__c = 40;
        oppPeriod.RentPercent__c = 60;
        oppPeriod.ServicePercent__c = 40;
        oppPeriod.IsIncludeCAM__c = false;
        oppPeriod.PeriodFrom__c = Date.today();
        oppPeriod.PeriodTo__c = Date.newInstance(Date.today().year()+1 , Date.today().month(), Date.today().day()-1);

        insert oppPeriod;

        OpportunityPeriod__c campPeriod = MockUpDataFor_Test.createOppPeriod(opp, 1, Constant.CAL_METHOD_CAM);
        campPeriod.Total__c = 100;
        campPeriod.TotalArea__c = 100;
        campPeriod.LeasableArea__c = 100;
        campPeriod.IsIncludeCAM__c = false;
        
        insert campPeriod;

        OpportunityDepositExpense__c depositExpense = MockUpDataFor_Test.createOppDepositExpense(opp);
        insert depositExpense;

        OpportunityPrice__c oppPrice = MockUpDataFor_Test.createOppPriceWithProportion(opp,oppPeriod,50,'Rent');
        insert oppPrice;

        OpportunityPrice__c oppPrice2 = MockUpDataFor_Test.createOppPriceWithProportion(opp,oppPeriod,50,'Service');
        insert oppPrice2;

        List<OpportunityGradingModel.Data> gradingList = new List<OpportunityGradingModel.Data>();
        OpportunityGradingModel.Data oppGrading = MockUpDataFor_Test.createOppGrading(opp, oppPeriod, 0, 10);
        gradingList.add(oppGrading);
        OpportunityGradingModel.Data oppGrading2 = MockUpDataFor_Test.createOppGrading(opp, oppPeriod, 0, 0);
        gradingList.add(oppGrading2);
        opp.OpportunityGrading__c = OpportunityGradingModel.toString(gradingList);
        update(opp);
    }

    public static ContractLineItem__c createContractLineItem(Contract__c contract, Units__c ro){
        ContractLineItem__c contractLine = new ContractLineItem__c(Contract__c=contract.Id,
                                                                            Unit__c=ro.Id,
                                                                            RoomNo__c=ro.Name);

        return contractLine;
    }

    public static void createShortLeaseGPOpp(Opportunity opp, String calculationMethod){
        opp.Estimated_Contract_Start_Date__c = Date.today();
        opp.Estimated_Contract_End_Date__c = Date.today().addYears(2);
        opp.Contract_Type__c = Constant.OPP_CONTRACT_TYPE_SHORTLEASE_GP;
        opp.Calculation_Method__c = calculationMethod;
        opp.Deposit_Month__c = 6;
        opp.OptionToRenewYear__c = 0;
        opp.OptionToRenewwithPricing__c = true;
        opp.Rental_Period_Year__c = 2;
        opp.Rental_Period_Month__c = 0;
        opp.Rental_Period_Day__c = 0;
        opp.RentAndServiceEscalationRate__c = 5;
        opp.RentAndServiceEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.Revenue_Collected_By__c = 'ผู้เช่าเก็บเงิน';
    }
    public static void createShortLeaseFixOpp(Opportunity opp, String calculationMethod, Id buildingId){
        opp.Estimated_Contract_Start_Date__c = Date.today();
        opp.Estimated_Contract_End_Date__c = Date.today().addYears(3);
        opp.Contract_Type__c = Constant.OPP_CONTRACT_TYPE_SHORTLEASE_FIXED;
        opp.Calculation_Method__c = calculationMethod;
        opp.Deposit_Month__c = 6;
        opp.OptionToRenewYear__c = 3;
        opp.OptionToRenewwithPricing__c = true;
        opp.Building__c = buildingId;
        opp.Rental_Period_Year__c = 3;
        opp.Rental_Period_Month__c = 0;
        opp.Rental_Period_Day__c = 0;
        opp.RentAndServiceEscalationRate__c = 5;
        opp.RentAndServiceEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationRate__c = 5;
    }

    public static void createQuotationPreparationScreenPack(){
        List<QuotationPreparationScreenMaster__c> setupList = new List<QuotationPreparationScreenMaster__c>();

        setupList.add(new QuotationPreparationScreenMaster__c(
            ScreentoDisplay__c = 'Expense and Fee',
            Type__c = 'Electric',
            Format__c = 'Rate and Area',
            ContractType__c = 'Long-Term Fixed Rent',
            IsActive__c = true,
            Subtype__c = 'None Charge',
            RentalType__c = 'Space_Rental'
        ));
        setupList.add(new QuotationPreparationScreenMaster__c(
            ScreentoDisplay__c = 'Expense and Fee',
            Type__c = 'Electric',
            Format__c = 'Rate and Area',
            ContractType__c = 'Long-Term Fixed Rent',
            IsActive__c = true,
            Subtype__c = 'Fixed Price',
            RentalType__c = 'Space_Rental'
        ));
        setupList.add(new QuotationPreparationScreenMaster__c(
            ScreentoDisplay__c = 'Expense and Fee',
            Type__c = 'Electric',
            Format__c = 'Rate and Area',
            ContractType__c = 'Long-Term Fixed Rent',
            IsActive__c = true,
            Subtype__c = 'Additional',
            RentalType__c = 'Space_Rental'
        ));
        setupList.add(new QuotationPreparationScreenMaster__c(
            ScreentoDisplay__c = 'Expense and Fee',
            Type__c = 'Electric',
            Format__c = 'Rate and Area',
            ContractType__c = 'Long-Term Fixed Rent',
            IsActive__c = true,
            Subtype__c = 'Actual',
            RentalType__c = 'Space_Rental'
        ));
        setupList.add(new QuotationPreparationScreenMaster__c(
            ScreentoDisplay__c = 'Expense and Fee',
            Type__c = 'Additional Air Service',
            Format__c = 'Fixed',
            ContractType__c = 'Long-Term Fixed Rent',
            IsActive__c = true,
            RentalType__c = 'Space_Rental'
        ));
        setupList.add(new QuotationPreparationScreenMaster__c(
            ScreentoDisplay__c = Constant.TYPE_OTHER,
            Type__c = 'อื่นๆ (เหมาจ่าย)',
            Format__c = Constant.DEP_EXP_TYPE_LEASEHOLD,
            ContractType__c = 'Long-Term Fixed Rent',
            IsActive__c = true,
            RentalType__c = 'Space_Rental'
            //SpecificMeasurement__c = 'Footprint Area'
        ));

        insert setupList;
    } 

    public static QuotationPreparationScreenMaster__c createQuotationPreparationScreenMaster(String type, String subType, 
                                                                                                Boolean isAllowChange, String ScreenToDisplay,
                                                                                                Decimal sequence, String contractDefaultValue, 
                                                                                                String remark, String contractType){
        QuotationPreparationScreenMaster__c result = new QuotationPreparationScreenMaster__c();
        result.Type__c = type;
        result.Subtype__c = subType;
        result.IsAllowChange__c = isAllowChange;
        result.ScreentoDisplay__c = ScreenToDisplay;
        result.Sequence__c = sequence;
        result.ContractDefaultValue__c = contractDefaultValue;
        result.Remark__c = remark;
        result.IsActive__c = true;
        result.ContractType__c = contractType;
        return result;
    } 

    public static List<QuotationPreparationScreenMaster__c> createQuoPrepScreenMasterListForSublease(){
        List<QuotationPreparationScreenMaster__c> result = new List<QuotationPreparationScreenMaster__c>();
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการให้เช่าช่วง', '2,000 บาท/ตร.ม.', false, 'Request Sublease',
                                                            1, 'DefaultFeeby2000perSqm__c', null, null));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการให้เช่าช่วง', '1 เดือนของค่าเช่า (เช่าช่วง)', true, 'Request Sublease',
                                                            2, '0', null, null));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการให้เช่าช่วง', 'อื่นๆ (เหมาจ่าย)', true, 'Request Sublease',
                                                            3, '0', null, null));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการดำเนินการ', null, true, 'Request Sublease',
                                                            null, '10000', null, null));
        return result;
    } 

    public static List<QuotationPreparationScreenMaster__c> createQuoPrepScreenMasterListForChangeOwner(){
        List<QuotationPreparationScreenMaster__c> result = new List<QuotationPreparationScreenMaster__c>();
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการโอนสิทธิ', '2,000 บาท/ตร.ม.', false, 
                                                        'Request Change Owner Long Lease', 1, 'DefaultFeeby2000perSqm__c', 
                                                        null, Constant.OPP_CONTRACT_TYPE_LONGLEASE_FIXED));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการโอนสิทธิ', 'อื่นๆ (เหมาจ่าย)', true, 
                                                        'Request Change Owner Long Lease', 2, '0', 
                                                        null, Constant.OPP_CONTRACT_TYPE_LONGLEASE_FIXED));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการดำเนินการ', null, true, 
                                                        'Request Change Owner Long Lease', null, '10000', 
                                                        null, Constant.OPP_CONTRACT_TYPE_LONGLEASE_FIXED));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการโอนสิทธิ', '2,000 บาท/ตร.ม.', false, 
                                                        'Request Change Owner Long Lease', 1, 'DefaultFeeby2000perSqm__c', 
                                                        null, Constant.OPP_CONTRACT_TYPE_LONGLEASE_GP));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการโอนสิทธิ', 'อื่นๆ (เหมาจ่าย)', true, 
                                                        'Request Change Owner Long Lease', 2, '0', 
                                                        null, Constant.OPP_CONTRACT_TYPE_LONGLEASE_GP));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการดำเนินการ', null, true, 
                                                        'Request Change Owner Long Lease', null, '10000', 
                                                        null, Constant.OPP_CONTRACT_TYPE_LONGLEASE_GP));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการโอนสิทธิ', '2,000 บาท/ตร.ม.', true, 
                                                        'Request Change Owner Long Lease', 1, 'DefaultFeeby2000perSqm__c', 
                                                        'มูลค่าตามสัญญา', Constant.OPP_CONTRACT_TYPE_SHORTLEASE_FIXED));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการดำเนินการ', null, true, 
                                                        'Request Change Owner Long Lease', 2, '10000', 
                                                        'มูลค่าตามสัญญา', Constant.OPP_CONTRACT_TYPE_SHORTLEASE_FIXED));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการโอนสิทธิ', '2,000 บาท/ตร.ม.', true, 
                                                        'Request Change Owner Long Lease', 1, 'DefaultFeeby2000perSqm__c', 
                                                        'มูลค่าตามสัญญา', Constant.OPP_CONTRACT_TYPE_SHORTLEASE_GP));
        result.add(createQuotationPreparationScreenMaster('ค่าธรรมเนียมการดำเนินการ', null, true, 
                                                        'Request Change Owner Long Lease', 2, '10000', 
                                                        'มูลค่าตามสัญญา', Constant.OPP_CONTRACT_TYPE_SHORTLEASE_GP));
        return result;
    } 

    public static PDF_Content__c createPDFContent(Opportunity opp){
        PDF_Content__c pdfContent = new PDF_Content__c(
            Sequence__c = 1,
            Content__c = '000000',
            Expression_Criteria__c = '',
            Is_Active__c = true,
            Is_Show_Sequence__c = false,
            Is_Optional__c = false,
            Opportunity__c = opp.Id,
            Master_Content__c = null,
            Content_Description__c = null,
            Object__c = null,
            Language__c = 'Thai',
            Continue_From_Above__c = false
        );
        return pdfContent;
    }

    public static PDF_Content__c createPDFContent(){
        return new PDF_Content__c(
            Content__c = '<p>ผู้ให้เช่ามีความยินดีจะเสนอพื้นที่เช่าในศูนย์การค้า ไอคอนสยาม โดยมีรายละเอียดและเงื่อนไขดังนี้:</p>'
        );
    }

    public static List<Traffic__c> createTraffics(Date startDate, Date endDate, Id branchId){
        List<Traffic__c> traffics = new List<Traffic__c>();
        while(startDate <= endDate){
            Traffic__c traffic = new Traffic__c();
            traffic.Date__c = startDate;
            traffic.Branch__c = branchId;
            traffic.Type__c = 'PEOPLE';
            traffic.CCTV_Name__c = 'A. Building 1F. Pharmax D1';
            traffic.Object_Entering__c = 123;
            traffic.Object_Leaving__c = 110;
            traffic.Event__c = false;
            traffics.add(traffic);
            startDate = startDate.addDays(1);
        }
       
        return traffics;
    }

    public static List<Roll_up_Traffic__c> createRollUpTraffic(Date trafficDateStart, Date trafficDateEnd, Id branchId){
        List<Roll_up_Traffic__c> rollTraffics = new List<Roll_up_Traffic__c>();
        while(trafficDateStart <= trafficDateEnd){
            Roll_up_Traffic__c rollTraffic = new Roll_up_Traffic__c();
            rollTraffic.Branch__c = branchId;
            rollTraffic.Date__c = trafficDateStart;
            rollTraffic.Type__c = 'PEOPLE';
            rollTraffic.External_ID__c = branchId + '_P_' + trafficDateStart;
            rollTraffics.add(rollTraffic);
            trafficDateStart = trafficDateStart.addDays(1);
        }
       
        insert rollTraffics;
        return rollTraffics;
    }

    public static Event_and_Special_Holiday__c createEvent(Date eventStartDate, Date eventEndDate, Id branchId){
        Event_and_Special_Holiday__c event = new Event_and_Special_Holiday__c();
        event.Event_Start_Date__c = eventStartDate;
        event.Event_End_Date__c = eventEndDate;
        event.Branch__c = branchId;
        event.Event_Name__c = 'Event Name';
        event.RecordTypeId = RecordTypeUtility.getRecordTypeId('Event_and_Special_Holiday__c', Constant.EVENT_RECORDTYPE_NAME);
        return event;
    }

    public static Event_and_Special_Holiday__c createSpecialHoliday(Date holidayDate){
        Event_and_Special_Holiday__c event = new Event_and_Special_Holiday__c();
        event.Special_Holiday_Description__c = 'Holiday';
        event.Special_Holiday_Date__c  = holidayDate;
        event.RecordTypeId = RecordTypeUtility.getRecordTypeId('Event_and_Special_Holiday__c', Constant.EVENT_SPECIAL_HOLIDAY_RECORDTYPE_NAME);
        return event;
    }
}