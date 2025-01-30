virtual public class OppPDFSubPageController {

    public final List<String> GPTypeList = new List<String>{'Long-Term GP Rent','Short-Term GP Rent','Extra-Long-Term GP Rent'};

    public Id recordId{get;set;}
    public String rentalType{get;set;}
    public String oppId{get;set;}

    public List<String> oppPeriodId{get;set;}
    public List<Opportunity> oppRecord{get;set;}
    public List<Contract__c> contractRecord{get;set;}
    public List<OpportunityPeriod__c> oppPeriod {get;set;}
    public List<OpportunityPrice__c> oppPriceList {get;set;}
    public List<OpportunityPrice__c> oppPriceOtherList{get;set;}
    public List<OpportunityDepositExpense__C> oppDepositExpenseList{get;set;}

    public Map<String,List<OpportunityGradingModel.Data>> GPByOppPeriod{get;set;}

    public EventOppData eventOppData;
    public BillBoardQuotationData billBoardQuotationData;
    public BillBoardContractData billBoardContractData;
    public ContractFeePeriod_Space contractFeePeriod_Space;
    public QuotationAdditionalFee quotationAdditionalFee;
    public CamFee camFee;

    public String calculationMethod {get;set;}
    public Boolean contractTypeGP{get;set;}
    public String GPType{get;set;}
    public Decimal decoInsurance{get;set;}
    public Decimal decoInsuranceDiscount{get;set;}
    public Decimal contractInsurance{get;set;}
    
    public String oppGP{get;set;}
    public Decimal GPPercentage{get;set;}
    public Decimal GPPriceEnd{get;set;}

    public class EventOppData{
        public Decimal quantity {get;set;}
        public String unit {get;set;}
        public List<String> unitList {get;set;}
        public List<Decimal> unitSize {get;set;}
        public List<Decimal> price{get;set;}
        public List<Decimal> totalAmountPerUnitCost{get;set;}
        public List<String> minType{get;set;}
        public List<Decimal> totalAmount{get;set;}
        public List<Decimal> pricePerUnit{get;set;}
        public Decimal total{get;set;}
        public Decimal vat{get;set;}
        public Decimal grandTotal{get;set;}
        public String grandTotalText{get;set;}

        
        public String waterFeeType{get;set;}
        public Decimal waterRate{get;set;}
        public Decimal waterPrice{get;set;}
        public Decimal totalWater{get;set;}
        public Decimal elecRate{get;set;}
        public Decimal elecPrice{get;set;}
        public Decimal totalElec{get;set;}
        public String elecFeeType{get;set;}
        public Decimal additionalFee{get;set;}
        public String additionalRemark{get;set;}
        public List<Decimal> otherFee{get;set;}
        public List<String> otherRemark{get;set;}

        public Boolean containExpenseList {get;set;}
        public final List<String> typeGroup = new List<String>{'Other','Expense'};

        public List<String> DepositExpenseType{get;set;}
        public List<Decimal> DepositExpensePrice{get;set;}

        public String Other_expense_String{get;set;}

        public eventOppData(){
            this.quantity = 0;
            this.unit = 'Month';
            this.unitList = new List<String>();
            this.unitSize = new List<Decimal>();
            this.price = new List<Decimal>();
            this.totalAmountPerUnitCost = new List<Decimal>();
            this.minType = new List<String>();
            this.totalAmount = new List<Decimal>();
            this.pricePerUnit = new List<Decimal>();
            this.total = 0;
            this.DepositExpenseType = new List<String>();
            this.DepositExpensePrice = new List<Decimal>();
            this.otherFee = new List<Decimal>();
            this.otherRemark = new List<String>();
            Decimal totalDepositexpense = 0;
            this.containExpenseList = true;
            this.additionalFee = 0;
            this.waterPrice = 0;
            this.elecPrice = 0;
        }

        public EventOppData(List<OpportunityPrice__c> oppPriceList){
            String oppId = oppPriceList[0].Opportunity__c;
            this.quantity = this.getMonthsQuantity(oppPriceList[0].From__c, oppPriceList[0].To__c);
            this.unit = 'Month';
            this.unitList = new List<String>();
            this.unitSize = new List<Decimal>();
            this.price = new List<Decimal>();
            this.totalAmountPerUnitCost = new List<Decimal>();
            this.minType = new List<String>();
            this.totalAmount = new List<Decimal>();
            this.pricePerUnit = new List<Decimal>();
            this.total = 0;
            Decimal ppu;

            for(OpportunityPrice__c record: oppPriceList){
                this.unitList.add(record.Unit__r.Name);
                this.unitSize.add(record.MeasurementAmount__c);
                this.price.add(record.Price__c);
                if(record.Price__c != null && record.MeasurementAmount__c != null){
                    ppu = record.TotalPrice__c / record.MeasurementAmount__c;
                    this.pricePerUnit.add(ppu.setScale(2));
                }
                this.totalAmountPerUnitCost.add(record.TotalPrice__c);
                this.minType.add(record.OpportunityPeriod__r.MinType__c);
            }
            System.Debug(this.quantity);
            System.debug(this.unitList.size() !=0);
            System.debug('size: ' + this.unitSize);
            System.debug('list: ' + this.unitList);
            System.debug('size: ' + this.unitSize.size());
            System.debug('list: ' + this.unitList.size());

            for(Decimal unit: this.totalAmountPerUnitCost){
                Decimal x = unit * quantity;
                this.totalAmount.add(unit * quantity);
                this.total = this.total + x;
            }
            
            List<OpportunityPrice__c> depositExpensList = new List<OpportunityPrice__c>();
            SOQLBuilder queryDepositExpense = new SOQLBuilder('OpportunityPrice__c');
            queryDepositExpense.addCondition('WHERE Opportunity__c =: oppId AND TypeGroup__c IN :typeGroup');
            depositExpensList = Database.query(queryDepositExpense.getQueryString());
            System.debug('depositExpensList: ' + depositExpensList);

            if(depositExpensList != null){
                this.DepositExpenseType = new List<String>();
                this.DepositExpensePrice = new List<Decimal>();
                this.otherFee = new List<Decimal>();
                this.otherRemark = new List<String>();
                Decimal totalDepositexpense = 0;
                this.containExpenseList = true;
                //process additional data
                for(OpportunityPrice__c rec: depositExpensList){
                    if(rec.DepositExpenseType__c == 'Electric'){
                        if(rec.SubType__c == 'Fixed Price') {
                            this.elecPrice = rec.Price__c;
                            this.elecFeeType = rec.SubType__c;
                            this.containExpenseList =true;
                        }
                        if(rec.SubType__c != 'Fixed Price'){
                            this.elecRate = rec.Rate__c;
                            this.elecFeeType = rec.SubType__c;
                            this.containExpenseList =true;
                        }
                    }else if(rec.DepositExpenseType__c == 'Water'){
                        if(rec.SubType__c == 'Fixed Price') {
                            this.waterPrice = rec.Price__c;
                            this.waterFeeType = rec.SubType__c;
                            this.containExpenseList =true;
                        }
                        if(rec.SubType__c != 'Fixed Price'){
                            this.waterRate = rec.Rate__c;
                            this.waterFeeType = rec.SubType__c;
                            this.containExpenseList =true;
                        }
                    }else if(rec.DepositExpenseType__c == 'Additional Request') {
                        this.additionalRemark = this.getAdditionalRemark(rec.Opportunity__c, 'Additional Request');
                        this.additionalFee = rec.Price__c;
                        this.containExpenseList =true;
                    }
                    else{
                        System.debug(rec.DepositExpenseType__c);
                        String temp = this.getAdditionalRemark(rec.Opportunity__c, rec.DepositExpenseType__c);
                        this.DepositExpenseType.add(temp);
                        this.DepositExpensePrice.add(rec.Price__c);
                        totalDepositexpense = totalDepositexpense + rec.Price__c;
                        this.containExpenseList =true;
                        if(this.Other_expense_String == null){
                            this.Other_expense_String = temp;
                        }else{
                            this.Other_expense_String = this.Other_expense_String + 'และ' + temp;
                        }
                    }
                }
                this.totalWater = (this.waterPrice!=null)?this.waterPrice * this.quantity.round(System.RoundingMode.CEILING):0;
                this.totalElec = (this.elecPrice!=null)?this.elecPrice * this.quantity.round(System.RoundingMode.CEILING):0;
                this.additionalFee = (this.additionalFee!=null)?this.additionalFee * this.quantity.round(System.RoundingMode.CEILING) :0;
                this.total = this.total + totalDepositexpense + this.additionalFee + this.totalWater + this.totalElec;
                

                System.debug(this.total);
            }
            System.debug('waterType: ' + this.waterFeeType);
            System.debug('elecFee: ' + this.elecPrice);
            System.debug('elecType: ' + this.elecFeeType);
            System.debug('additionalFee: ' + this.additionalFee);
            System.debug('DepositExpenseType: ' + this.DepositExpenseType);
            System.debug('DepositExpensePrice: ' + this.DepositExpensePrice);
            System.debug('Other_expense_String: ' + this.Other_expense_String);
        }

        private Decimal getMonthsQuantity(Date start, Date due){

            return OpportunityController.getMonthBetween(start, due);
        }

        private String getAdditionalRemark(String opp, String additionalRequest){
            // String type = 'Additional Request';
            System.debug(additionalRequest);
            List<OpportunityDepositExpense__c> recordList = new List<OpportunityDepositExpense__c>();
            SOQLBuilder oppDepositExpenseQuery = new SOQLBuilder('OpportunityDepositExpense__C');
            oppDepositExpenseQuery.addCondition('WHERE Opportunity__c =: opp AND Type__c =:additionalRequest');
            recordList = Database.query(oppDepositExpenseQuery.getQueryString());
            if(recordList[0].Remark__c == null){
                return additionalRequest;
            }else{
            return recordList[0].Remark__c;
            }
        }

        

    }

    //data for Billboard Opportunity

    public class BillBoardQuotationData{
        public List<Id> unitList {get;set;}
        public Map<Id,String> unitName{get;set;}
        public Map<Id,Decimal> unitMonth{get;set;}
        public Map<Id,Decimal> unitTotalRentalPrice{get;set;}
        public Map<Id,Decimal> unitAvgRentalPrice{get;set;}
        public Map<Id,List<Decimal>> unitPriceList{get;set;}

        public Decimal totalRentalPrice{get;set;}
        public Decimal avgRentalPrice{get;set;}
        public Decimal installmentFee{get;set;}
        public Decimal signCreatationFee{get;set;}
        public Decimal elecRate{get;set;}
        public Decimal elecPrice{get;set;}
        public String subTypeElec{get;set;}
        public Decimal additionalFee{get;set;}
        public String additionalRemark{get;set;}
        public Decimal totalElecPrice{get;set;}
        public Decimal allTotal{get;set;}
        public Decimal totalRentalMonth{get;set;}
        //List of billboard measurement
        public List<String> bannerSizeList{get;set;}

        public Decimal vat{get;set;}
        public Decimal grandTotal{get;set;}
        public String grandTotalText{get;set;}
        
        public BillBoardQuotationData(){
            this.unitList = new List<Id>(); 
            this.unitName = new Map<Id,String>(); 
            this.unitMonth = new Map<Id,Decimal>(); 
            this.unitTotalRentalPrice = new Map<Id,Decimal>(); 
            this.unitAvgRentalPrice = new Map<Id,Decimal>(); 
            this.unitPriceList = new Map<Id,List<Decimal>>(); 
            this.bannerSizeList = new List<String>(); 

            List<Decimal> totalPriceList = new List<Decimal>(); 
            Map<Id, Integer> avgDivider = new Map<Id,Integer>(); 
            List<Decimal> priceList = new List<Decimal>(); 
            this.totalRentalPrice = 0; 
            this.avgRentalPrice = 0;
            this.totalRentalMonth = 0;
            this.installmentFee = 0;
            this.signCreatationFee = 0;
            this.totalElecPrice =  0;
            this.additionalFee = 0;
            this.allTotal =0;
        }
        public BillBoardQuotationData(List<OpportunityPrice__c> records, List<OpportunityPrice__c> additionalRecord){

            this.unitList = new List<Id>(); 
            this.unitName = new Map<Id,String>(); 
            this.unitMonth = new Map<Id,Decimal>(); 
            this.unitTotalRentalPrice = new Map<Id,Decimal>(); 
            this.unitAvgRentalPrice = new Map<Id,Decimal>(); 
            this.unitPriceList = new Map<Id,List<Decimal>>(); 
            this.bannerSizeList = new List<String>(); 

            List<Decimal> totalPriceList = new List<Decimal>(); 
            Map<Id, Integer> avgDivider = new Map<Id,Integer>(); 
            List<Decimal> priceList = new List<Decimal>(); 
            this.totalRentalPrice = 0; 


            for(OpportunityPrice__c rec: records){
                if(!unitList.contains(rec.Unit__c)){
                    this.unitList.add(rec.Unit__c);
                    this.unitName.put(rec.Unit__c,rec.Unit__r.Name);
                    this.unitMonth.put(rec.Unit__c, this.getMonthsQuantity(rec.From__c, rec.To__c));
                    this.unitTotalRentalPrice.put(rec.Unit__c,rec.TotalPriceVAT__c * this.getMonthsQuantity(rec.From__c, rec.To__c));
                    this.unitPriceList.put(rec.Unit__c, new List<Decimal>{rec.TotalPriceVAT__c});
                    this.bannerSizeList.add(rec.Unit__r.Banner_Size__c);
                    avgDivider.put(rec.Unit__c, 1);
                    totalPriceList.add(rec.TotalPriceVAT__c);
                }else{
                    this.unitMonth.put(rec.Unit__c, this.unitMonth.get(rec.Unit__c) + this.getMonthsQuantity(rec.From__c, rec.To__c));
                    this.unitTotalRentalPrice.put(rec.Unit__c, this.unitTotalRentalPrice.get(rec.Unit__c) + (rec.TotalPriceVAT__c* this.getMonthsQuantity(rec.From__c, rec.To__c))); 

                    priceList = this.unitPriceList.get(rec.Unit__c);
                    priceList.add(rec.TotalPriceVAT__c);
                    this.unitPriceList.put(rec.Unit__c,priceList);
                    avgDivider.put(rec.Unit__c, avgDivider.get(rec.Unit__c) + 1);
                    totalPriceList.add(rec.TotalPriceVAT__c);
                }
            }

            Decimal tempAvgUnit ;
            this.avgRentalPrice = 0;
            this.totalRentalMonth = 0;
            // get avg price of each unit 
            if(this.unitList!=null){
                for(Id unit: unitList){
                    //getList of price of that unit
                    tempAvgUnit=0;
                    for(Decimal price:this.unitPriceList.get(unit)){
                        tempAvgUnit = tempAvgUnit + price;
                    }
                    System.debug('unitPriceList: '+this.unitPriceList);
                    //avg price for each unit
                    this.unitAvgRentalPrice.put(unit, tempAvgUnit/avgDivider.get(unit));
                    System.debug('unit average price: '+this.unitAvgRentalPrice);

                    //total rental price of all unit
                    this.totalRentalPrice = this.totalRentalPrice + this.unitTotalRentalPrice.get(unit);
                }
                this.totalRentalMonth = this.unitMonth.get(unitList[0]);
            }

            //avg rental price in opp 
            for(Decimal price: totalPriceList){
                this.avgRentalPrice = this.avgRentalPrice + price;
            }
            this.avgRentalPrice = this.avgRentalPrice/totalPriceList.size();

            //get additional info
            System.debug(additionalRecord);
            for(OpportunityPrice__c rec: additionalRecord){
                System.debug(rec.DepositExpenseType__c);
                if(rec.TypeGroup__c == 'Expense'){
                    if(rec.DepositExpenseType__c == 'ค่าติดตั้งป้าย'){this.installmentFee = rec.TotalPrice__c;}
                    else if(rec.DepositExpenseType__c == 'ค่าผลิตป้าย'){ this.signCreatationFee = rec.TotalPrice__c;}
                }else if(rec.TypeGroup__c == 'Other'){
                    if(rec.DepositExpenseType__c == 'Electric'){
                        this.subTypeElec = rec.SubType__c;
                        if(rec.SubType__c == 'Actual') this.elecRate = rec.Rate__c;
                        if(rec.SubType__c == 'Fixed Price') this.elecPrice = rec.Price__c;
                    }else if(rec.DepositExpenseType__c == 'Additional Request'){
                        this.additionalFee = rec.Price__c;
                        this.additionalRemark = this.getAdditionalRemark(rec.Opportunity__c);
                    }
                }
            }
            
            System.debug(this.subTypeElec);
            System.debug('electPrice: ' + this.elecPrice);
            System.debug('elecrate: ' + this.elecRate);
            System.debug(this.signCreatationFee);

            this.installmentFee = (this.installmentFee!=null)?this.installmentFee:0;
            this.signCreatationFee = (this.signCreatationFee!=null)?this.signCreatationFee:0;
            this.totalElecPrice = (this.elecPrice!=null)?this.elecPrice * this.totalRentalMonth: 0;
            this.additionalFee = (this.additionalFee!=null)?this.additionalFee:0;
            this.allTotal = this.totalElecPrice + this.totalRentalPrice + this.signCreatationFee + this.installmentFee + this.additionalFee;
            this.vat = this.allTotal * OpportunitySetting__c.getInstance().Tax__c/100;
            this.grandTotal = this.allTotal + this.vat;
            this.grandTotalText = numberToWord.numberToWordTH(this.grandTotal,false);
            System.debug('electPrice: ' + this.totalElecPrice);
            System.debug('rent: ' + this.totalRentalPrice);
            System.debug('sign: ' + this.signCreatationFee);
            System.debug('installment: ' + this.installmentFee);
            System.debug('alltotal: ' + this.allTotal);
        }
        private Decimal getMonthsQuantity(Date start, Date due){
            return OpportunityController.getMonthBetween(start, due);
        }

        private String getAdditionalRemark(String opp){
            String type = 'Additional Request';
            List<OpportunityDepositExpense__c> recordList = new List<OpportunityDepositExpense__c>();
            SOQLBuilder oppDepositExpenseQuery = new SOQLBuilder('OpportunityDepositExpense__C');
            oppDepositExpenseQuery.addCondition('WHERE Opportunity__c =: opp AND Type__c =:type ');
            recordList = Database.query(oppDepositExpenseQuery.getQueryString());
            return recordList[0].Remark__c;
        }
    }

    public class BillBoardContractData{
        public List<String> unitCodeList{get;set;}
        public Map<String,String> bannerLabelList{get;set;}
        public Map<String,String> bannerSizeList{get;set;}
        public Map<String,Decimal> rentPeriod{get;set;}
        

        public BillBoardContractData(List<OpportunityPrice__c> oppPriceList){
            this.unitCodeList = new List<String>();
            this.bannerLabelList = new Map<String,String>();
            this.bannerSizeList = new Map<String,String>();
            this.rentPeriod = new Map<String,Decimal>();
            Decimal updateValue;

            for(OpportunityPrice__c rec: oppPriceList){
                if(!this.unitCodeList.contains(rec.Unit__r.Name)){
                this.unitCodeList.add(rec.Unit__r.Name);
                this.bannerLabelList.put(rec.Unit__r.Name,rec.Unit__r.Category__c);
                if(rec.Unit__r.Banner_Size__c != null){
                this.bannerSizeList.put(rec.Unit__r.Name,rec.Unit__r.Banner_Size__c);
                }else{
                    this.bannerSizeList.put(rec.Unit__r.Name,'');
                }
                this.rentPeriod.put(rec.Unit__r.Name,this.getMonthsQuantity(rec.From__c,rec.To__c));
                }else{
                    updateValue = this.rentPeriod.get(rec.Unit__r.Name);
                    updateValue = updateValue + this.getMonthsQuantity(rec.From__c,rec.To__c);
                    this.rentPeriod.put(rec.Unit__r.Name, updateValue);
                }
            }
            System.debug(this.unitCodeList);
            System.debug(this.bannerLabelList);
            System.debug(this.bannerSizeList);
            System.debug(this.rentPeriod);
        }
        
        private Decimal getMonthsQuantity(Date start, Date due){
            return OpportunityController.getMonthBetween(start, due);
        }

    }

    public class ContractFeePeriod_Space{
        public List<String> rentalUnit{get;set;}
        public Integer unitListSize{get;set;}
        public Double totalLeasableArea{get;set;}
        public Map<String,Map<String,Decimal>> leasableServiceMonth{get;set;}
        public Map<String,Map<String,Decimal>> leasableRentalMonth{get;set;}
        
        //map room and oppPeriod
        public Map<String, List<OpportunityPeriod__c>> unitDataWithPeriod {get;set;}
        public Map<String, Map<String,String>> totalRentText{get;set;}
        public Map<String, Map<String,String>> totalServiceText{get;set;} 
        public Map<String, Map<String,String>> rentFeePerSQMText{get;set;}
        public Map<String, Map<String,String>> serviceFeePerSQMText{get;set;}
        public Map<String, Decimal> measurementArea{get;set;}
        public Map<String, String> measurementType{get;set;}
        public Map<String, String> periodYear{get;set;}
        public Map<String,Map<String,Decimal>> rentFeePerSQM{get;set;}
        public Map<String,Map<String,Decimal>> serviceFeePerSQM{get;set;}
        public Map<String, Map<String,String>> fixedTotalRentText{get;set;}
        public Map<String, Map<String,String>> fixedTotalServicedText{get;set;}
        public Map<String, Map<String,Decimal>> fixedTotalRent{get;set;}
        public Map<String, Map<String,Decimal>> fixedTotalServiced{get;set;}
        public List<String> periodList{get;set;}
        public Map<String, Boolean> unitIsFOC{get;set;}
        public Decimal firstYearMonthlyFee{get;set;}
        
        public ContractFeePeriod_Space(){
            this.rentalUnit = new List<String>();
            this.unitDataWithPeriod = new Map<String, List<OpportunityPeriod__c>>();
            this.totalRentText = new Map<String, Map<String,String>>();
            this.unitListSize = 0;
            this.measurementType = new Map<String, String>();
            this.measurementArea = new Map<String, Decimal>();
            this.periodYear = new Map<String, String>();
            this.totalLeasableArea = 0;
        }
        public ContractFeePeriod_Space(List<OpportunityPeriod__c> oppPeriodList){
            this.unitDataWithPeriod = new Map<String, List<OpportunityPeriod__c>>();
            this.totalRentText = new Map<String, Map<String,String>>();
            this.totalServiceText = new Map<String, Map<String,String>>();
            this.rentFeePerSQMText = new Map<String, Map<String,String>>();
            this.serviceFeePerSQMText = new Map<String, Map<String,String>>();
            this.measurementType = new Map<String, String>();
            this.measurementArea = new Map<String, Decimal>();
            this.periodYear = new Map<String, String>();
            this.totalLeasableArea = 0;

            this.rentFeePerSQM = new Map<String, Map<String,Decimal>>();
            this.serviceFeePerSQM = new Map<String,Map<String,Decimal>>();
            this.fixedTotalRentText = new Map<String, Map<String,String>>();
            this.fixedTotalServicedText = new Map<String, Map<String,String>>();
            this.fixedTotalRent = new Map<String, Map<String,Decimal>>();
            this.fixedTotalServiced = new Map<String, Map<String,Decimal>>();
            this.leasableServiceMonth = new Map<String, Map<String,Decimal>>();
            this.leasableRentalMonth = new Map<String, Map<String,Decimal>>();
            this.unitIsFOC = new Map<String,Boolean>();
            this.periodList = new List<String>();
            this.rentalUnit = new List<String>();
            this.unitListSize = 0;
            this.firstYearMonthlyFee = 0;

            if(!oppPeriodList.isEmpty()){
                String oppId = oppPeriodList[0].Opportunity__c;
                String calculationMethod = oppPeriodList[0].CalculationMethod__c;
                String periodYearText;
                Map<String, Date> unitInitialPeriod = new Map<String, Date>();

                List<Opportunity> oppQuery = [Select RoomNumber__c, Building__c FROM Opportunity WHERE Id =: oppId];
                String building = oppQuery[0].Building__c;
                List<String> unitNameList = oppQuery[0].RoomNumber__c.split(',');

                System.debug(unitNameList);

                List<Units__c> unitList = [Select Id, Name FROM Units__c Where Building__c =:building AND Name IN :unitNameList];
                Map<String,String> unitNameToId = new Map<String,String>();
                for(Units__c rec: unitList){
                    unitNameToId.put(rec.Name,rec.Id);
                    this.unitIsFOC.put(rec.Name,this.getIsFOC(rec.Id));
                }

                System.debug(unitNameList);
                System.debug(unitNameToId);

                Double leaseableArea;
                for(OpportunityPeriod__c rec: oppPeriodList){
                    this.periodList.add(rec.Id);
                        if(unitList != null && !unitList.isEmpty()){
                            for(String room: unitNameList){
                                if(this.unitIsFOC.get(room) ){
                                    if(!this.unitDataWithPeriod.containsKey(room)){
                                        unitInitialPeriod.put(room, rec.PeriodFrom__c);
                                        leaseableArea = this.getMeasurementArea(unitNameToId.get(room),true);
                                        this.rentalUnit.add(room);
                                        this.unitDataWithPeriod.put(room,new List<OpportunityPeriod__c>{rec});
                                        this.measurementArea.put(room,leaseableArea);
                                        this.totalLeasableArea = this.totalLeasableArea + leaseableArea;
                                        periodYearText = this.getPeriodYear(unitInitialPeriod.get(room),rec.PeriodFrom__c, rec.PeriodTo__c);
                                        this.periodYear.put(rec.id, periodYearText);
                                    }
                                    continue;
                                }
                                if(!this.unitDataWithPeriod.containsKey(room)){
                                    if(!unitInitialPeriod.containsKey(room)){
                                        unitInitialPeriod.put(room, rec.PeriodFrom__c);
                                    }
                                    this.unitDataWithPeriod.put(room,new List<OpportunityPeriod__c>{rec});
                                    this.rentalUnit.add(room);
                                    leaseableArea = this.getMeasurementArea(unitNameToId.get(room),false);
                                    // leaseableArea = (this.unitIsFOC.get(room))? 0 : this.getMeasurementArea(unitNameToId.get(room));
                                    this.measurementArea.put(room,leaseableArea);
                                    this.totalLeasableArea = this.totalLeasableArea + leaseableArea;
                                    periodYearText = this.getPeriodYear(unitInitialPeriod.get(room),rec.PeriodFrom__c, rec.PeriodTo__c);
                                    this.periodYear.put(rec.id, periodYearText);
                                }else{
                                    List<OpportunityPeriod__c> temp = unitDataWithPeriod.get(room);
                                    temp.add(rec);
                                    unitDataWithPeriod.put(room, temp);
                                    periodYearText = this.getPeriodYear(unitInitialPeriod.get(room),rec.PeriodFrom__c, rec.PeriodTo__c);
                                    this.periodYear.put(rec.id, periodYearText);
                                    leaseableArea = this.measurementArea.get(room);
                                // }
                                }


                            Map<String,String> mapTemp = new Map<String,String>();
                            String temp;
                            Double leasableFee;
                            Double rentSqmMonth ;
                            Double serviceSqmMonth ;
                            String unitId = unitNameToId.get(room);
                            System.debug(rec.RentPercent__c);
                            System.debug(rec.ServicePercent__c);
                            if(rec.CalculationMethod__c != 'GP no Min' && rec.CalculationMethod__c != 'GP with Min'){
                                if( rec.RentMonth__c != null){
                                    if( rec.RentSqmMonth__c != null && rec.MinType__c == 'Measurement'){
                                        rentSqmMonth = this.getRentServiceValue(unitId, rec.RentPercent__c, rec.Id , rec.Opportunity__c);
                                        System.debug(rentSqmMonth);
                                        leasableFee = leaseableArea * rentSqmMonth;
                                        temp = numberToWord.numberToWordTH(leasableFee,false);

                                        if(!this.leasableRentalMonth.containsKey(room)){
                                            this.leasableRentalMonth.put(room, new Map<String,Decimal>{rec.Id => leasableFee});
                                            this.totalRentText.put(room, new Map<String,String>{rec.Id => temp});
                                        }else{
                                            Map<String,Decimal> feeTemp = this.leasableRentalMonth.get(room);
                                            feeTemp.put(rec.Id, leasableFee);
                                            this.leasableRentalMonth.put(room,feeTemp);
                                            Map<String,String> textTemp = this.totalRentText.get(room);
                                            textTemp.put(rec.Id, temp);
                                            this.totalRentText.put(room, textTemp);
                                            
                                        }

                                        temp = numberToWord.numberToWordTH(rentSqmMonth,false);
                                        if(!this.rentFeePerSQM.containsKey(room)){
                                            this.rentFeePerSQM.put(room, new Map<String,Decimal>{rec.Id => rentSqmMonth});
                                            this.rentFeePerSQMText.put(room, new Map<String,String>{rec.Id => temp});
                                        }else{
                                            Map<String,Decimal> feeTemp = this.rentFeePerSQM.get(room);
                                            feeTemp.put(rec.Id, rentSqmMonth);
                                            this.rentFeePerSQM.put(room,feeTemp);
                                            Map<String,String> textTemp = this.rentFeePerSQMText.get(room);
                                            textTemp.put(rec.Id, temp);
                                            this.rentFeePerSQMText.put(room, textTemp);
                                        }

                                    }else if(rec.RentSqmMonth__c == 0 && rec.MinType__c == 'Fixed'){
                                        System.debug('596');
                                        //เหมาจ่าย
                                        if(rec.LeasableArea__c != null && rec.LeasableArea__c != 0 && this.totalLeasableArea != 0){
                                            //SQM section
                                            System.debug('600');
                                            Double fixedSqMRent = rec.RentMonth__c / this.totalLeasableArea;
                                            temp = numberToWord.numberToWordTH(fixedSqMRent,false);

                                            if(!this.fixedTotalRentText.containsKey(room)){
                                                System.debug('605');
                                                Decimal Fee = fixedSqMRent * this.measurementArea.get(room);
                                                this.fixedTotalRent.put(room, new Map<String,Decimal>{rec.Id => Fee});
                                                String stringTemp = numberToWord.numberToWordTH(this.fixedTotalRent.get(room).get(rec.Id),false);
                                                this.fixedTotalRentText.put(room, new Map<String,String>{rec.Id => stringTemp});
                                            }else{
                                                //add value
                                                System.debug('612');
                                                Map<String,Decimal> tempMap =  this.fixedTotalRent.get(room);
                                                tempMap.put(rec.Id, fixedSqMRent * this.measurementArea.get(room));
                                                this.fixedTotalRent.put(room, tempMap);
                                                //add text
                                                Map<String,String> tempMap2 =  this.fixedTotalRentText.get(room);
                                                String stringTemp2 = numberToWord.numberToWordTH(this.fixedTotalRent.get(room).get(rec.Id),false);
                                                tempMap2.put(rec.Id, stringTemp2);
                                                this.fixedTotalRentText.put(room, tempMap2);
                                            }

                                            if(!this.rentFeePerSQM.containsKey(room)){
                                                this.rentFeePerSQM.put(room, new Map<String,Decimal>{rec.Id => fixedSqMRent});
                                                this.rentFeePerSQMText.put(room,new Map<String,String>{rec.Id => temp});
                                            }else{
                                                Map<String,Decimal> feeTemp = this.rentFeePerSQM.get(room);
                                                feeTemp.put(rec.Id, fixedSqMRent);
                                                this.rentFeePerSQM.put(room,feeTemp);
                                                Map<String,String> textTemp = this.rentFeePerSQMText.get(room);
                                                textTemp.put(rec.Id, temp);
                                                this.rentFeePerSQMText.put(room, textTemp);
                                            }
                                        }else{
                                            this.rentFeePerSQMText.put(room, new Map<String,String>{rec.Id =>'ศูยน์'});
                                        }
                                    }
                                }
                                System.debug(leaseableArea);
                                System.debug(rec.ServiceSqmMonth__c);
                                System.debug(leaseableArea * rec.ServiceSqmMonth__c);
                                if( rec.ServiceMonth__c != null){
                                    System.debug('not a GP');
                                    if( rec.ServiceSqmMonth__c != null && rec.ServiceSqmMonth__c != 0){
                                        
                                        serviceSqmMonth = this.getRentServiceValue(unitId, rec.ServicePercent__c, rec.Id , rec.Opportunity__c);
                                        leasableFee = leaseableArea * ServiceSqmMonth;
                                        temp = numberToWord.numberToWordTH(leasableFee,false);
                                        System.debug(serviceSqmMonth);
                                        if(!this.leasableServiceMonth.containsKey(room)){
                                        this.leasableServiceMonth.put(room, new Map<String,Decimal>{rec.Id => leasableFee});
                                        this.totalServiceText.put(room, new Map<String,String>{rec.Id => temp});

                                        }else{
                                            Map<String,Decimal> feeTemp = this.leasableServiceMonth.get(room);
                                            feeTemp.put(rec.Id, leasableFee);
                                            this.leasableServiceMonth.put(room,feeTemp);
                                            Map<String,String> textTemp = this.totalServiceText.get(room);
                                            textTemp.put(rec.Id, temp);
                                            this.totalServiceText.put(room, textTemp);
                                        }

                                        temp = numberToWord.numberToWordTH(serviceSqmMonth,false);

                                        if(!this.serviceFeePerSQM.containsKey(room)){
                                            this.serviceFeePerSQM.put(room, new Map<String,Decimal>{rec.Id => serviceSqmMonth});
                                            this.serviceFeePerSQMText.put(room, new Map<String,String>{rec.Id => temp});
                                            }else{
                                                Map<String,Decimal> feeTemp = this.serviceFeePerSQM.get(room);
                                                feeTemp.put(rec.Id, serviceSqmMonth);
                                                this.serviceFeePerSQM.put(room,feeTemp);
                                                Map<String,String> textTemp = this.serviceFeePerSQMText.get(room);
                                                textTemp.put(rec.Id, temp);
                                                this.serviceFeePerSQMText.put(room, textTemp);
                                            }

                                    }else if(rec.ServiceSqmMonth__c == 0 && rec.MinType__c == 'Fixed'){
                                        //เหมาจ่าย
                                        if(rec.LeasableArea__c != null && rec.LeasableArea__c != 0 && this.totalLeasableArea != 0){
                                            //SQM section
                                            System.debug(rec.ServiceMonth__c);
                                            Double fixedSqMService = rec.ServiceMonth__c / this.totalLeasableArea;
                                            temp = numberToWord.numberToWordTH(fixedSqMService,false);
                                            
                                            //all area of unit
                                            
                                                if(!this.fixedTotalServicedText.containsKey(room)){
                                                    Decimal Fee = fixedSqMService * this.measurementArea.get(room);
                                                    this.fixedTotalServiced.put(room, new Map<String,Decimal>{rec.Id => Fee});
                                                    String stringTemp = numberToWord.numberToWordTH(this.fixedTotalServiced.get(room).get(rec.Id),false);
                                                    this.fixedTotalServicedText.put(room, new Map<String,String>{rec.Id => stringTemp});
                                                }else{
                                                    Map<String,Decimal> tempMap =  this.fixedTotalServiced.get(room);
                                                    tempMap.put(rec.Id, fixedSqMService * this.measurementArea.get(room));
                                                    this.fixedTotalServiced.put(room, tempMap);

                                                    Map<String,String> tempMap2 =  this.fixedTotalServicedText.get(room);
                                                    String stringTemp2 = numberToWord.numberToWordTH(this.fixedTotalServiced.get(room).get(rec.Id),false);
                                                    tempMap2.put(rec.Id, stringTemp2);
                                                    this.fixedTotalServicedText.put(room, tempMap2);
                                                }

                                                if(!this.serviceFeePerSQM.containsKey(room)){
                                                    this.serviceFeePerSQM.put(room, new Map<String,Decimal>{rec.Id => fixedSqMService});
                                                    this.serviceFeePerSQMText.put(room, new Map<String,String>{rec.Id => temp});
                                                    }else{
                                                        Map<String,Decimal> feeTemp = this.serviceFeePerSQM.get(room);
                                                        feeTemp.put(rec.Id, fixedSqMService);
                                                        this.serviceFeePerSQM.put(room,feeTemp);
                                                        Map<String,String> textTemp = this.serviceFeePerSQMText.get(room);
                                                        textTemp.put(rec.Id, temp);
                                                        this.serviceFeePerSQMText.put(room, textTemp);
                                                    }
                                        }else{
                                            this.rentFeePerSQMText.put(room, new Map<String,String>{rec.Id => 'ศูยน์'});
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                System.debug('rent sqm: ' + this.rentFeePerSQM);
                System.debug('service sqm: ' + this.serviceFeePerSQM);

                this.unitListSize = this.rentalUnit.size();
                    System.debug(this.unitDataWithPeriod);
                    System.debug(this.rentalUnit);
                    // // get first year ยอดชำระค่าบริการ
                    OpportunityPeriod__c firstPeriod = oppPeriodList[0];
                    System.debug(unitNameList);
                    if(firstPeriod.CalculationMethod__c != 'GP no Min' && firstPeriod.CalculationMethod__c != 'GP with Min'){
                        for(String room: unitNameList){
                            System.debug(this.unitDataWithPeriod.get(room));
                            if(this.unitIsFOC.get(room)){
                                continue;
                            }
                            // System.debug(room);
                            // System.debug(this.leasableRentalMonth);
                            // System.debug(this.fixedTotalRent);
                            // System.debug(this.leasableRentalMonth.get(room));
                            // System.debug(this.leasableServiceMonth.get(room).get(firstPeriod.Id));
                            // System.debug(this.leasableRentalMonth.get(room).get(firstPeriod.Id));
                            if(firstPeriod.MinType__c == 'Measurement'){
                                this.firstYearMonthlyFee = this.firstYearMonthlyFee + this.leasableRentalMonth.get(room).get(firstPeriod.Id) + this.leasableServiceMonth.get(room).get(firstPeriod.Id);
                            }else if(firstPeriod.MinType__c == 'Fixed'){
                                this.firstYearMonthlyFee = this.firstYearMonthlyFee + this.fixedTotalRent.get(room).get(firstPeriod.Id) + this.fixedTotalServiced.get(room).get(firstPeriod.Id);
                            }
                        }
                    }
            }
            System.debug(this.leasableRentalMonth);
            System.debug(this.totalRentText);
            System.debug(this.leasableServiceMonth);
            System.debug(this.unitDataWithPeriod);
            System.debug(this.rentalUnit);
            System.debug(this.unitIsFOC);
            System.debug(this.unitListSize);
        }

        private String getPeriodYear(Date initial,Date currentPeriodStartDate, Date currentPeriodEndDate){
            Decimal startMonths = OpportunityController.getMonthBetween(initial, currentPeriodStartDate);
            Long startYear = (startMonths/12).round(System.RoundingMode.CEILING);
            Decimal endMonths = OpportunityController.getMonthBetween(initial, currentPeriodEndDate);
            Long endYear = (endMonths/12).round(System.RoundingMode.CEILING);
            if(startYear == endYear){
                return String.valueOf(startYear);
            }else{
                return String.valueOf(startYear) + ' - ' + String.valueOf(endYear);
            }
        }
        private String getMeasurementText(String unit){
            List<Measurement__c> rec = [SELECT Type__c FROM Measurement__c WHERE Unit_No__c =:unit];
            List<String> stringList = new List<String>();
            String ret;
            for(Measurement__c x: rec){
                stringList.add(x.Type__c);
            }
            ret = String.join(stringList, ',');
            return ret;
        }
        private Decimal getMeasurementArea(String unit, Boolean isFOC){
            Units__c rec = [SELECT LeasableArea__c,TotalArea__c  FROM Units__c WHERE Id =: unit];
            if(isFOC){
                return rec.TotalArea__c;
            }
            return rec.LeasableArea__c;
        }
        private Double getRentServiceValue(String unit, Decimal percent, Id oppPeriod, Id opp){
            System.debug(unit);
            System.debug(percent);
            System.debug(oppPeriod);
            System.debug(opp);
            OpportunityPrice__c oppPrice = [SELECT Price__c FROM OpportunityPrice__c WHERE Opportunity__c =: opp AND OpportunityPeriod__c =: oppPeriod AND Unit__c =: unit Limit 1];
            System.debug('oppPRice: ' + oppPrice.Price__c);
            Double ret = (oppPrice.Price__c * percent)/100;
            System.debug('762: ' + ret + ' percent: ' + percent);
            return ret;
        }
        private boolean getIsFOC(String unitId){
            List<Measurement__c> measurementList = [SELECT IsFOC__c FROM Measurement__c WHERE Unit_No__c =: unitId];
            for(Measurement__c rec: measurementList){
                if(!rec.IsFOC__c){
                    return false;
                }
            }
            return true;
        }
    }

    public class QuotationAdditionalFee{
        public Decimal additionalFee{get;set;}
        public String additionalRemark{get;set;}
        public Decimal exhaustSystemFee{get;set;}
        public Decimal totalAdditionalFee{get;set;}
        public List<String> otherRemark{get;set;}
        public List<Decimal> otherFee{get;set;}

        public QuotationAdditionalFee(){
            this.totalAdditionalFee = 0;
            this.otherFee = new List<Decimal>();
            this.otherRemark = new List<String>();
            this.additionalFee = 0;
            this.exhaustSystemFee = 0;
            System.debug('no data');
        }

        public QuotationAdditionalFee(List<OpportunityDepositExpense__C> oppDepositExpenseList){
            System.debug('data');
            this.totalAdditionalFee = 0;
            this.otherFee = new List<Decimal>();
            this.otherRemark = new List<String>();
            for(OpportunityDepositExpense__C rec: oppDepositExpenseList){
                totalAdditionalFee = totalAdditionalFee + rec.Price__c;
                if(rec.Type__c == 'Additional Request'){
                    this.additionalFee = rec.Price__c;
                    this.additionalRemark = rec.Remark__c;
                }else if(rec.Type__c == 'Exhaust System') {this.exhaustSystemFee = rec.Price__c;}
                else if (rec.Type__c == 'อื่นๆ (เหมาจ่าย)'){
                    this.otherFee.add(rec.Price__c);
                    if(rec.Remark__c == null){
                        this.otherRemark.add('อื่นๆ (เหมาจ่าย)');
                    }else{
                        this.otherRemark.add(rec.Remark__c);
                    }
                }else if (rec.Type__c == 'ค่าที่จอดรถ'){
                    this.otherFee.add(rec.Price__c);
                    if(rec.Remark__c == null){
                        this.otherRemark.add('ค่าที่จอดรถ');
                    }else{
                        this.otherRemark.add(rec.Remark__c);
                    }
                }
            }
            System.debug(this.totalAdditionalFee);
            System.debug(this.otherFee);
            System.debug(this.otherRemark);
            System.debug(this.additionalFee);
            System.debug(this.additionalRemark);
        }
    }

    public class CamFee{
        public List<String> periodList{get;set;}
        public Map<String, Decimal> camFeePeriod{get;set;}
        public Map<String, Decimal> totalCamFeePeriod{get;set;}
        public Map<String, String> camFeePeriodText{get;set;}
        public Map<String, String> totalCamFeePeriodText{get;set;}
        // public List<String> totalPeriodSet{get;set;}

        public CamFee(List<OpportunityPeriod__c> oppPeriodList){
            
            this.periodList = new List<String>();
            this.camFeePeriod = new Map<String, Decimal>();
            this.totalCamFeePeriod = new Map<String, Decimal>();
            this.camFeePeriodText = new Map<String, String>();
            this.totalCamFeePeriodText = new Map<String, String>();
            // this.totalPeriodSet = new List<String>();
            // Set<String> tempList = new Set<String>();
            String temp;
            for(OpportunityPeriod__c rec: oppPeriodList){
                this.periodList.add(rec.Id);
                this.camFeePeriod.put(rec.Id,rec.CAMSqmMonth__c);
                this.totalCamFeePeriod.put(rec.Id,rec.Total__c	);
                this.camFeePeriodText.put(rec.Id,numberToWord.numberToWordTH(rec.CAMSqmMonth__c,false));
                this.totalCamFeePeriodText.put(rec.Id,numberToWord.numberToWordTH(rec.Total__c,false));
                // tempList.add(rec.OpportunityPeriod__c);
            }
            
            // this.totalPeriodSet.addAll(tempList);

            System.debug(this.periodList);
            System.debug(this.camFeePeriod);
            System.debug(this.totalCamFeePeriod);
            // System.debug(tempList);
            // System.debug(this.totalPeriodSet);
            // System.debug(this.totalPeriodSet.size());
        }
    }


    

    public OppPDFSubPageController(ApexPages.StandardController stdController) {
        
        this.recordId = stdController.getId();
        String currentObject = String.valueOf(this.recordId .getSobjectType());
        // System.debug(this.recordId);

        if(currentObject == 'Opportunity'){
            this.oppId = this.recordId;
            SOQLBuilder queryOpp = new SOQLBuilder('Opportunity');
            queryOpp.addCondition('WHERE Id =:recordId');

            this.oppRecord = Database.query(queryOpp.getQueryString());
            this.rentalType = this.oppRecord[0].Rental_Type__c;
            this.calculationMethod = this.oppRecord[0].Calculation_Method__c;
            if(this.GPTypeList.contains(this.oppRecord[0].Contract_Type__c)){
                this.processGPData();
            }
            
            this.contractInsurance = (this.oppRecord[0].Deposit_Amount_for_Event__c != null)?this.oppRecord[0].Deposit_Amount_for_Event__c: 0;
            this.decoInsurance = this.oppRecord[0].Decoration_Insurance_Amount__c;
            this.decoInsuranceDiscount = (this.oppRecord[0].Decoration_Insurance_Discount__c != null)?this.oppRecord[0].Decoration_Insurance_Discount__c: 0;
            

            List<String> oppPeriodField = new List<String>{'Id','PeriodFrom__c','PeriodTo__c','CalculationMethod__c','MinType__c'};
            SOQLBuilder queryPeriod = new SOQLBuilder('OpportunityPeriod__c');
            queryPeriod.addCondition('WHERE Opportunity__c =: recordId AND CalculationMethod__c =:calculationMethod');
            this.oppPeriod = Database.query(queryPeriod.getQueryString());
            System.debug(this.oppPeriod);
            this.oppPeriodId = new List<String>();
            for(OpportunityPeriod__c record: this.oppPeriod){
                this.oppPeriodId.add(record.Id);
                System.debug(record.Id);
            }
            System.debug(this.oppPeriodId);

        }else if(currentObject == 'Contract__c'){
            SOQLBuilder queryContract = new SOQLBuilder('Contract__c');
            queryContract.addCondition('Where Id =:recordId');

            this.contractRecord = Database.query(queryContract.getQueryString());
            this.oppId = this.contractRecord[0].Opportunity_Name__c;

            SOQLBuilder queryOpp = new SOQLBuilder('Opportunity');
            queryOpp.addCondition('WHERE Id =:oppId');
            this.oppRecord = Database.query(queryOpp.getQueryString());
            this.calculationMethod = this.oppRecord[0].Calculation_Method__c;

            if(this.GPTypeList.contains(this.oppRecord[0].Contract_Type__c)){
                this.processGPData();
            }

            SOQLBuilder queryPeriod = new SOQLBuilder('OpportunityPeriod__c');
            queryPeriod.addCondition('WHERE Opportunity__c =: oppId AND CalculationMethod__c =:calculationMethod ORDER BY PeriodFrom__c	ASC');
            this.oppPeriod = Database.query(queryPeriod.getQueryString());
            System.debug('oppPeriod: ' + this.oppPeriod);
            this.oppPeriodId = new List<String>();
            for(OpportunityPeriod__c record: this.oppPeriod){
                this.oppPeriodId.add(record.Id);
                System.debug(record.Id);
            }
        }
    }
    public CamFee getCamFee(){
        String cam = 'CAM';
        SOQLBuilder queryOppPrice = new SOQLBuilder('OpportunityPeriod__c');
        queryOppPrice.addCondition('WHERE Opportunity__c =: oppId AND CalculationMethod__c =:cam');
        this.oppPeriod = Database.query(queryOppPrice.getQueryString());
        this.camfee = new CamFee(this.oppPeriod);
        return this.camFee;
    }

    public QuotationAdditionalFee getQuotationAdditionalFee(){
        if(oppDepositExpenseList == null){
            List<String> additionalType = new List<String>{'Additional Request','Exhaust System','อื่นๆ (เหมาจ่าย)','ค่าที่จอดรถ'};
            SOQLBuilder queryAdditional = new SOQLBuilder('OpportunityDepositExpense__c');
            queryAdditional.addCondition('WHERE Opportunity__c =:recordId AND Type__c IN :additionalType');
            this.oppDepositExpenseList = Database.query(queryAdditional.getQueryString());
            System.debug(additionalType);
            System.debug(this.oppDepositExpenseList);
            System.debug(this.oppDepositExpenseList.size());
            if(this.oppDepositExpenseList.isEmpty()){
                this.quotationAdditionalFee = new QuotationAdditionalFee();
            }else{
                this.quotationAdditionalFee = new QuotationAdditionalFee(this.oppDepositExpenseList);
            }
            
        }
        return this.quotationAdditionalFee;
    }

    public ContractFeePeriod_Space getContractFeePeriod_Space(){

        if(this.oppPeriod.isEmpty()){
            this.contractFeePeriod_Space = new ContractFeePeriod_Space();
        }else{
            this.contractFeePeriod_Space = new ContractFeePeriod_Space(this.oppPeriod);
        }
        
        return this.contractFeePeriod_Space;
    }

    public BillBoardContractData getBillBoardContractData(){
        SOQLBuilder queryOppPrice = new SOQLBuilder('OpportunityPrice__c');
        queryOppPrice.addCondition('WHERE Opportunity__c =: oppId AND CalculationMethod__c =:calculationMethod AND OpportunityPeriod__c IN :oppPeriodId AND SubType__c = null');
        queryOppPrice.addAllFieldFromRelation('Unit__r', 'Units__c');
        this.oppPriceList = Database.query(queryOppPrice.getQueryString());

        this.billBoardContractData = new BillBoardContractData(this.oppPriceList);
        return this.billBoardContractData;
    }

    public EventOppData getEventOppData(){
        if(this.oppPriceList ==null){
            SOQLBuilder queryOppPrice = new SOQLBuilder('OpportunityPrice__c');
            System.debug(this.recordId);
            queryOppPrice.addCondition('WHERE Opportunity__c =: recordId AND CalculationMethod__c =:calculationMethod AND OpportunityPeriod__c IN :oppPeriodId AND SubType__c = null');
            queryOppPrice.addField('Unit__r.Name');
            queryOppPrice.addField('OpportunityPeriod__r.MinType__c');
            this.oppPriceList = Database.query(queryOppPrice.getQueryString());
            System.debug(this.oppPriceList);
            System.debug(this.oppPriceList.isEmpty());
            if(this.oppPriceList.isEmpty()){
                this.eventOppData = new EventOppData();
            }else{
            this.eventOppData = new EventOppData(this.oppPriceList);
            }
            this.updatingGrandTotal(this.eventOppData,this.contractInsurance , this.decoInsurance, this.decoInsuranceDiscount);
        }
        return this.eventOppData;
    }

    public BillBoardQuotationData getBillBoardQuotationData(){
        //query for the main records
        String installment = 'Installment';
        if(this.oppPriceList ==null){
            SOQLBuilder queryOppPrice = new SOQLBuilder('OpportunityPrice__c');
            System.debug(this.recordId);
            queryOppPrice.addCondition('WHERE Opportunity__c =: recordId AND CalculationMethod__c =:calculationMethod AND OpportunityPeriod__c IN :oppPeriodId AND SubType__c = null');
            queryOppPrice.addField('Unit__r.Name');
            queryOppPrice.addField('Unit__r.Banner_Size__c');
            queryOppPrice.addField('OpportunityPeriod__r.MinType__c');
            this.oppPriceList = Database.query(queryOppPrice.getQueryString());

            //query for additional cost
            SOQLBuilder queryOppPrice2 = new SOQLBuilder('OpportunityPrice__c');
            System.debug(this.recordId);
            queryOppPrice2.addCondition('WHERE Opportunity__c =: recordId AND TypeGroup__c != null');
            this.oppPriceOtherList = Database.query(queryOppPrice2.getQueryString());

            if(this.oppPriceList.isEmpty()){
                this.billBoardQuotationData = new BillBoardQuotationData();
            }else{
                this.billBoardQuotationData = new BillBoardQuotationData(this.oppPriceList, this.oppPriceOtherList);
            }
        }
        return this.billBoardQuotationData;
    }




    public void updatingGrandTotal(EventOppData eventOppData,Decimal contractInsurance, Decimal decoInsurance, Decimal decoInsuranceDiscount){
        Opportunity updateOpp = new Opportunity();
        eventOppData.total = eventOppData.total + contractInsurance + decoInsurance - decoInsuranceDiscount;
        eventOppData.vat = eventOppData.total * OpportunitySetting__c.getInstance().Tax__c/100;
        eventOppData.grandTotal = eventOppData.total + eventOppData.vat;
        eventOppData.grandTotalText = numberToWord.numberToWordTH(eventOppData.grandTotal,false);
    }


    public void updatedData(){
        System.debug('Updating Data');
        Opportunity updateOpp = new Opportunity();
        updateOpp.Id = this.recordId;
        if(this.rentalType == 'Event_Rental'){
            EventOppData event = this.getEventOppData();
            updateOpp.Additional_Expense__c = event.additionalFee;
            updateOpp.Other_Expense_Type__c = event.Other_expense_String;
            update updateOpp;
        }else if(this.rentalType == 'Billboard_Rental'){
            BillBoardQuotationData billBoard = this.getBillBoardQuotationData();
            updateOpp.Additional_Expense__c = billBoard.additionalFee;
            update updateOpp;
        }else{
            QuotationAdditionalFee quotationAdditionalFee = this.getQuotationAdditionalFee();
            updateOpp.Additional_Expense__c = quotationAdditionalFee.totalAdditionalFee;
            update updateOpp;
        }
        System.debug('Updated Data');
    }

    private void processGPData(){
        this.contractTypeGP = true;
                this.GPType = this.oppRecord[0].Contract_Type__c;
                this.oppGP = this.oppRecord[0].OpportunityGrading__c;
                System.debug(this.oppGP);
                if(this.oppGP != '[]' && this.oppGP != null){
                    List<OpportunityGradingModel.Data> GPData = OpportunityGradingModel.parse(this.oppGP);
                    System.debug(GPData);
                    System.debug(GPData.size());
                    if(GPData.size() == 1){ 
                        this.GPPercentage = GPData[0].GP;
                        this.GPPriceEnd = GPData[0].ToR;
                        System.debug(this.GPPercentage);
                        System.debug(this.GPPriceEnd);
                    }else{
                        this.GPByOppPeriod = new Map<String,List<OpportunityGradingModel.Data>>();
                        for(OpportunityGradingModel.Data rec: GPData){
                            if(!this.GPByOppPeriod.containsKey(rec.OpportunityPeriodId)){
                                this.GPByOppPeriod.put(rec.OpportunityPeriodId,new List<OpportunityGradingModel.Data>{rec});
                            }else{
                                List<OpportunityGradingModel.Data> temp = this.GPByOppPeriod.get(rec.OpportunityPeriodId);
                                temp.add(rec);
                                this.GPByOppPeriod.put(rec.OpportunityPeriodId, temp);
                            }
                        }
                        System.debug(GPByOppPeriod);
                        System.debug(GPByOppPeriod.keySet());
                    }
                }else{
                    this.GPPercentage = 0;
                    this.GPPriceEnd = 0;
                }
    }

    
}