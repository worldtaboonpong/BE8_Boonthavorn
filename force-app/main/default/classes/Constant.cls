public class Constant {
    //Application Log Type
    public static final String APP_LOG_BATCH_TYPE = 'Batch';
    public static final String APP_LOG_SYSTEM_TYPE = 'System';
    public static final String APP_LOG_WEBSERVICE_TYPE = 'Webservice';

    public static final String APP_LOG_INBOUND_TYPE = 'Inbound';
    public static final String APP_LOG_OUTBOUND_TYPE = 'Outbound';

    public static final String APP_LOG_RECORDTYPE_INTEGRATION = 'Log_Integration';
    public static final String APP_LOG_RECORDTYPE_SYSTEM = 'Log_System';
    public static final String APP_LOG_RECORDTYPE_BATCH = 'Log_Batch';

    public static final String APP_LOG_INSERT = 'Insert';
    public static final String APP_LOG_UPDATEM = 'Update';
    public static final String APP_LOG_DELETE = 'Delete';

    //Service Name for Web service
    public static final String APP_LOG_WEBSERVICE_ERROR = 'Webservice Error';

    //Application Log Type System Error
    public static final String APP_LOG_SYSTEM_ERROR = 'System Error';

    //Application Log Type Batch Error
    public static final String APP_LOG_BATCH_ERROR = 'Batch Error';
    public static final String APP_LOG_BATCH_UPDATE_QUEUE = 'BatchUpdateQueue';
    public static final String APP_LOG_BATCH_CALCULATE_REBATE_PACKAGE = 'BatchCalculateRebatePackage';
    public static final String APP_LOG_BATCH_CALCULATE_REBATE_AMOUNT = 'BatchCalculateRebateAmount';
    public static final String APP_LOG_BATCH_ROLLUP_INVOICE_TO_CAMPAIGN = 'BatchRollupInvoiceToCampaign';
    public static final String APP_LOG_BATCH_ROLLUP_INVOICE_SALE = 'BatchRollupInvoiceSale';

    //Use for Log File --> Attachment
    public static final String CREATE_LOG_ATTACHMENT = 'Create Log with Attachment file.';

    public static final String STATUS_SUCCESS = 'SUCCESS';
    public static final String STATUS_FAIL = 'FAIL';
    public static final String STATUS_ERROR = 'ERROR';

    public static final Date        TODAY       = System.Today();
    public static final Date        YESTERDAY   = System.Today().addDays(-1);
    public static final DateTime    NOW         = System.Now();

    public static Map<String,Integer> MONTHTOINTMAP = new Map<String,Integer>{
        'January'=>1,
        'February'=>2,
        'March'=>3,
        'April'=>4,
        'May'=>5,
        'June'=>6,
        'July'=>7,
        'August'=>8,
        'September'=>9,
        'October'=>10,
        'November'=>11,
        'December'=>12
    };

    public static Map<Integer,String> INTTOMONTHMAP = new Map<Integer,String>{
        1=>'January',
        2=>'February',
        3=>'March',
        4=>'April',
        5=>'May',
        6=>'June',
        7=>'July',
        8=>'August',
        9=>'September',
        10=>'October',
        11=>'November',
        12=>'December'
    };

    public static final String OPP_STAGE_APPROVED = 'Contract Approved';
    public static final String OPP_STAGE_QUOTATIONPREPARATION = 'Quotation Preparation';
    public static final String OPP_STAGE_CONTRACTAPPROVE = 'Contract Approved';
    public static final String OPP_STAGE_CONTRACTCREATE = 'Contract Created';
    public static final String OPP_STAGE_PENDING_QUOT_APPROVAL ='Pending for Quotation Approval';
    public static final String OPP_STAGE_QUOT_APPROVED ='Quotation Approved';
    public static final String OPP_STAGE_NEGOTIATE_IN_PROGRESS ='Negotiation in Progress';
    public static final String OPP_STAGE_CANCELLED ='Cancelled';
    public static final String OPP_STAGE_REJECTED ='Rejected';
    public static final String OPP_STAGE_PENDING_CONTRACT_CREATEION_APPROVAL ='Pending for Contract Creation Approval';
    public static final String OPP_PRICING_TYPE_GP = 'GP';
    public static final String OPP_CONTRACT_TYPE_LONGLEASE_FIXED = 'Z100';
    public static final String OPP_CONTRACT_TYPE_LONGLEASE_GP = 'Z110';
    public static final String OPP_CONTRACT_TYPE_SHORTLEASE_FIXED = 'Z200';
    public static final String OPP_CONTRACT_TYPE_SHORTLEASE_GP = 'Z220';

    public static final String REQUEST_STATUS_DRAFT = 'Draft';
    public static final String REQUEST_STATUS_SUBMITTED = 'Submitted';
    public static final String REQUEST_STATUS_APPROVED = 'Approved';
    public static final String REQUEST_STATUS_REJECTED = 'Rejected';
    public static final String REQUEST_STATUS_RECALLED = 'Recalled';
    public static final String REQUEST_STATUS_PENDING_FOR_LEASING = 'Pending for Leasing';
    public static final String REQUEST_STATUS_RECALLED_FOR_LEASING = 'Recalled by Leasing';
    public static final String REQUEST_STATUS_PENDING_FOR_LEASING_MANAGER = 'Pending for Leasing Manager';
    public static final String REQUEST_STATUS_APPROVED_BY_LEASING_MANAGER = 'Approved by Leasing Manager';
    public static final String REQUEST_STATUS_REJECTED_BY_LEASING_MANAGER = 'Rejected by Leasing Manager';
    public static final String REQUEST_STATUS_REJECTED_BY_BUILDING_MANAGER = 'Rejected by Building Manager';
    public static final String REQUEST_STATUS_PENDING_FOR_BUILDING_MANAGER = 'Pending for Building Manager';
    public static final String REQUEST_STATUS_APPROVED_BY_BUILDING_MANAGER = 'Approved by Building Manager';
    public static final String REQUEST_STATUS_REJECTED_BY_LEGAL_MANAGER = 'Rejected by Legal Manager';
    public static final String REQUEST_STATUS_PENDING_FOR_AR = 'Pending for AR';
    public static final String REQUEST_STATUS_RECALLED_FOR_AR = 'Recalled by AR';
    public static final String REQUEST_STATUS_REJECTED_BY_AR_MANAGER = 'Rejected by AR Manager';
    public static final String REQUEST_STATUS_PENDING_FOR_AR_MANAGER = 'Pending for AR Manager';
    public static final String REQUEST_STATUS_APPROVED_BY_AR_MANAGER = 'Approved by AR Manager';
    public static final String REQUEST_STATUS_PENDING_FOR_LEGAL = 'Pending for Legal';
    public static final String REQUEST_STATUS_RECALLED_BY_LEGAL = 'Recalled by Legal';

    public static final String CONTRACT_STAGE_CONTRACTSIGNING = 'Contract Signing and Pending Handover Processing';
    public static final String CONTRACT_STAGE_ACTIVATED = 'Activated';
    public static final String CONTRACT_STAGE_RENEWALINPROGRESS = 'Renewal in Progress';
    public static final String CONTRACT_STAGE_RENEWED = 'Renewed';
    public static final String CONTRACT_STAGE_TERMINATIONINPROGRESS = 'Termination in Progress';
    public static final String CONTRACT_STAGE_TERMINATED = 'Terminated';

    public static final Set<String> CONTRACT_IS_ACTIVE_SET = new Set<String>{
        CONTRACT_STAGE_CONTRACTSIGNING,
        CONTRACT_STAGE_ACTIVATED,
        CONTRACT_STAGE_RENEWALINPROGRESS,
        CONTRACT_STAGE_RENEWED,
        CONTRACT_STAGE_TERMINATIONINPROGRESS};

    public static final String CONTRACT_DETAIL_NEW_LET = 'New Let';

    public static final String CONTRACT_END_STATUS = 'Approved';
    
    public static final String CAL_METHOD_FIXED_PRICE = 'Fixed Price';
    public static final String CAL_METHOD_FIXED_RO = 'Fixed Rental Object';
    public static final String CAL_METHOD_FIXED_MEAS = 'Fixed Measurement';
    public static final String CAL_METHOD_GP_NOMIN = 'GP no Min';
    public static final String CAL_METHOD_GP_WITHMIN = 'GP with Min';
    public static final String CAL_METHOD_GP_ONTOP = 'GP on Top';
    public static final String CAL_METHOD_CAM = 'CAM';
    public static final String CAL_METHOD_AIR = 'Air Service';
    public static final String CAL_METHOD_RENT_SERVICE = 'Rent and Service Escalation';
    public static final String SALESRULE_TYPE = 'Sales Rule';
    public static final String REPORTINGRULE_TYPE = 'Reporting Rule';
    public static final String RENT_SERVICE_ADVANCE = 'Advance';
    public static final String RENT_SERVICE_ESCALATION = '% Escalation';
    
    public static final String MIN_TYPE_FIXED = 'Fixed';


    public static final String DEP_EXP_TYPE_ELECTRIC = 'Electric';
    public static final String DEP_EXP_TYPE_WATER = 'Water';
    public static final String DEP_EXP_TYPE_GAS = 'Gas';
    public static final String DEP_EXP_TYPE_CASHIER = 'Cashier';
    public static final String DEP_EXP_TYPE_FURNITURE = 'Furniture';
    public static final String DEP_EXP_TYPE_FURNITURE_DEPOSIT = 'Furniture Deposit';
    public static final String DEP_EXP_TYPE_ADDITIONAL_REQUEST = 'Additional Request';
    public static final String DEP_EXP_TYPE_ADDITIONAL_AIR_SERVICE = 'Additional Air Service';
    public static final String DEP_EXP_TYPE_GROUP_OTHER = 'Other';
    public static final String DEP_EXP_TYPE_FIRST_ENTRY_FEE = 'First Entry Fee';
    public static final String DEP_EXP_TYPE_CONSTRUCTION_SUPPORT_FEE = 'เงินช่วยค่าก่อสร้าง';
    public static final String DEP_EXP_TYPE_LEASEHOLD = 'สิทธิการเช่า';
    public static final String DEP_EXP_TYPE_LEASEHOLD_FEE = 'ค่าสิทธิการเช่า';
    public static final String DEP_EXP_TYPE_LEASEHOLD_FOOTPRINT = 'ค่าสิทธิการเช่า Footprint';
    public static final String DEP_EXP_TYPE_LEASEHOLD_MEZZANINE = 'ค่าสิทธิการเช่า Mezzanine';
    public static final String DEP_EXP_TYPE_LEASEHOLD_KITCHEN = 'ค่าสิทธิการเช่า Kitchen';
    public static final String DEP_EXP_TYPE_LEASEHOLD_TERRACE_OUTDOOR = 'ค่าสิทธิการเช่า Terrace/Outdoor';
    public static final String DEP_EXP_TYPE_LEASEHOLD_SUMMARY = 'Summary สิทธิการเช่า';
    public static final String DEP_EXP_TYPE_EXHAUST_SYSTEM = 'Exhaust System';
    public static final String DEP_EXP_TYPE_CONSTRUCTION_ASSIST_FEE  = 'เงินช่วยค่าก่อสร้าง';
    public static final String DEP_EXP_TYPE_OPERATION_FEE = 'ค่าธรรมเนียมการดำเนินการ';
    public static final String DEP_EXP_SUBTYPE_INSTALLMENT = 'Installment';
    public static final String DEP_EXP_SUBTYPE_ADDITIONAL = 'Additional';
    public static final String DEP_EXP_SUBTYPE_NONE_CHARGE = 'None Charge';
    public static final String DEP_EXP_SUBTYPE_ACTUAL = 'Actual';
    
    public static final String TMS_TYPE_MASTER = 'Master';
    public static final String TMS_TYPE_DRAFT = 'Draft';
    public static final String TMS_TYPE_CANCELLED = 'Cancelled';

    public static final Set<String> TMS_OPP_STAGE_DISPLAY_ON_MASTERPLAN_SET = new Set<String>{
                                                                                        OPP_STAGE_QUOTATIONPREPARATION,
                                                                                        OPP_STAGE_PENDING_QUOT_APPROVAL,
                                                                                        OPP_STAGE_QUOT_APPROVED,
                                                                                        OPP_STAGE_NEGOTIATE_IN_PROGRESS,
                                                                                        OPP_STAGE_PENDING_CONTRACT_CREATEION_APPROVAL,
                                                                                        OPP_STAGE_APPROVED};

    public static final Set<String> TMS_METHOD = new Set<String>{
                                                                    CAL_METHOD_FIXED_PRICE,
                                                                    CAL_METHOD_FIXED_RO,
                                                                    CAL_METHOD_FIXED_MEAS,
                                                                    CAL_METHOD_GP_NOMIN,
                                                                    CAL_METHOD_GP_WITHMIN,
                                                                    CAL_METHOD_GP_ONTOP};

    public static final Set<String> TMS_METHOD_GP = new Set<String>{
                                                                    CAL_METHOD_GP_NOMIN,
                                                                    CAL_METHOD_GP_WITHMIN,
                                                                    CAL_METHOD_GP_ONTOP};

    public static final Set<String> TMS_METHOD_WITH_CAM_AIR = new Set<String>{
                                                                CAL_METHOD_FIXED_PRICE,
                                                                CAL_METHOD_FIXED_RO,
                                                                CAL_METHOD_FIXED_MEAS,
                                                                CAL_METHOD_GP_NOMIN,
                                                                CAL_METHOD_GP_WITHMIN,
                                                                CAL_METHOD_GP_ONTOP,
                                                                CAL_METHOD_CAM,
                                                                CAL_METHOD_AIR};

    public static final Set<String> TMS_CONTRACT_TYPE_LONGLEASE = new Set<String>{
                                                                    OPP_CONTRACT_TYPE_LONGLEASE_FIXED,
                                                                    OPP_CONTRACT_TYPE_LONGLEASE_GP};

    public static final Set<String> TMS_CONTRACT_TYPE_SHORTLEASE = new Set<String>{
                                                                    OPP_CONTRACT_TYPE_SHORTLEASE_FIXED,
                                                                    OPP_CONTRACT_TYPE_SHORTLEASE_GP};

    public static final String PAGE_MASTER_FORMAT_FIXED = 'Fixed';
    public static final String PAGE_MASTER_FORMAT_RATE_AND_AREA = 'Rate and Area';

    public static final String OPP_PRICE_CONDITION_PURPOSE_STATISICAL = 'Statistical';
    public static final String OPP_PRICE_CALCULATION_FORMULAR_A = 'A';
    public static final String OPP_PRICE_CALCULATION_FORMULAR_D = 'D';
    public static final String OPP_PRICE_CALCULATION_FORMULAR_E1 = 'E1';

    public static final String OPP_PRICE_CONDITION_PURPOSE_I = 'I';
    public static final String CONDITION_PURPOSE_DISCOUNT = 'ZD';

    public static final String OPP_PRICE_CONDITION_TYPE_INIT_SBR = 'Z303';
    public static final String OPP_PRICE_CONDITION_TYPE_VIZCARD = 'D221';
    public static final String OPP_PRICE_CONDITION_TYPE_DUTYSTAMP = 'A020';
    public static final String OPP_PRICE_CONDITION_TYPE_DUTYSTAMPGP = 'A021';
    public static final String OPP_PRICE_CONDITION_TYPE_CREDITCARDSBR = 'Z901';
    public static final String OPP_PRICE_CONDITION_TYPE_DAMAGEDEPOSIT = 'D110';

    public static final String CONDITION_TYPE_RENTDEPOSIT = 'D210';
    public static final String CONDITION_TYPE_SERVICESDEPOSIT = 'D211';
    public static final String CONDITION_TYPE_CAMDEPOSIT = 'D212';

    public static final String CONDITIONTYPE_DISCOUNT_RENT = 'Y110';
    public static final String CONDITIONTYPE_DISCOUNT_SERVICES = 'Y120';
    public static final String CONDITIONTYPE_DISCOUNT_CAM = 'Y140';
    public static final String CONDITIONTYPE_DISCOUNT_AIRSERVICES = 'Y130';
    public static final String MAINTYPE_DISCOUNT = 'Discount';
    public static final List<String> CONDITIONTYPE_FOR_DISCOUNT = new List<String>{
        'Y110','Y120','Y113','Y123','Y112','Y122','Y116','Y125','Y140','Y141','Y142','Y130','Y131','Y133'};

    public static final String TYPE_RENT = 'Rent';
    public static final String TYPE_SERVICE = 'Service';
    public static final String TYPE_CAM = 'CAM';
    public static final String TYPE_RENT_DISCOUNT = 'Rent Discount';
    public static final String TYPE_SERVICE_DISCOUNT = 'Service Discount';
    public static final String TYPE_CAM_DISCOUNT = 'CAM Discount';
    public static final String TYPE_AIR = 'Air Service';
    public static final String TYPE_CAM_OR_AIRSERVICE = 'CAM/AS';
    public static final String TYPE_DEPOSIT = 'Deposit';
    public static final String TYPE_SECURITY_DEPOSIT = 'Security Deposit';
    public static final String TYPE_CN_SECURITY_DEPOSIT = 'CN Security Deposit';
    public static final String TYPE_CARRIED_DEPOSIT = 'Carried Deposit';
    public static final String TYPE_OTHER_DEPOSIT = 'Other Deposit';
    public static final String TYPE_EXPENSE = 'Expense';
    public static final String TYPE_OTHER = 'Other';
    public static final String TYPE_EXPENSEANDFEE = 'Expense and Fee';
    public static final String TYPE_NEW_GP_RATE = 'New GP Rate';
    public static final List<String> TYPE_RSCA = new List<String>{TYPE_RENT, TYPE_SERVICE, TYPE_CAM, TYPE_AIR};
    
    
    public static final String POSITION_CODE_LEASING = '0001';
    

    public static final String PRICE_TYPE_TRANSFER_FEE = 'ค่าธรรมเนียมการโอนสิทธิ';

    public static final String PAYMENT_TYPE_CASH = 'Cash';
    public static final String PAYMENT_TYPE_BANK_GURANTEE = 'Bank Gurantee';
    
    public static final String ENDCONTRACT_DESICION_EARLYTERMINATE = 'ลูกค้าจบสัญญาก่อนเวลา';
    public static final String REVISE_ENDCONTRACT = 'ยกเลิกการจบสัญญา (เพื่อไปทำการ Renew Contract)';

    public static final String CONDITION_MAPPING_LONGLEASE = 'Long-Term';
    public static final String CONDITION_MAPPING_SHORTLEASE = 'Short-Term';
    
    public static final String CONDITION_MAPPING_ALL = 'All';
    public static final String CONDITION_MAPPING_SETTLEMENT_PERIOD = '11';
    public static final String CONDITION_MAPPING_FIRSTOFMONTH = 'First of Month';
    public static final String CONDITION_MAPPING_NOTFIRSTOFMONTH = 'Not First of Month';
    public static final String CONDITION_MAPPING_EQUAL15 = 'Equal 15';
    public static final String CONDITION_MAPPING_BEFORE15 = 'Less than 15';
    public static final String CONDITION_MAPPING_LESSTHANOREQUAL15 = 'Less than or equal 15';
    public static final String CONDITION_MAPPING_AFTER15 = 'Greater than 15';
    public static final String CONDITION_MAPPING_ENDOFMONTH = 'End of Month';
    public static final String TIME_YEAR = '31536000000';
    public static final String TIME_MONTH = '2678400000';

    public static final String TMS_MASTERPLAN_STATUS_GREEN = 'Contract Activated';
    public static final String TMS_MASTERPLAN_STATUS_ORANGE = 'Negotiation in Progress';
    public static final String TMS_MASTERPLAN_STATUS_RED = 'Available for Sales';

    public static final String SAPMAPPING_TYPE_AUTOGEN = 'Auto-Generated';

    public static final String USAGETYPE_FOR_ATM = '40';    

    public static final String MEASUREMENT = 'Measurement';
    public static final String RENTAL_OBJECT = 'Rental Object';

    public static final String CONTRACT_PROCESS_TYPE_LEASING = 'Leasing Process';
    public static final String CONTRACT_PROCESS_TYPE_RETAILZONE = 'Retail Zone Process';

    public static final String REQUEST_RECORDTYPE_CHANGEMEASUREMENT = 'tms_ChangeMeasurement_In_Contract';
    public static final String REQUEST_RECORDTYPE_DISCOUNT = 'tms_Discount';
    public static final String REQUEST_RECORDTYPE_CHANGEOWNER = 'tms_ChangeOwner';
    public static final String REQUEST_RECORDTYPE_SUBLEASE = 'tms_Sublease';

    public static final String DEPOSIT_OPTION_NEW_DEPOSIT_CONTRACT = 'คิดเงินประกันตามสัญญาใหม่';
    public static final String DEPOSIT_OPTION_REMAIN_DEPOSIT_CONTRACT = 'คงเงินประกันเดิม';

    
    public static final String PROPORTION_IDENTIFICATION_SUBCATEGORY = 'Sub category';
    public static final String PROPORTION_IDENTIFICATION_USAGETYPE = 'Usage type'; 

    public static final String DISCOUNT_METHOD_PERCENT = 'Percent'; 
    public static final String DISCOUNT_METHOD_AMOUNT = 'Amount'; 

    public static final String PROFILE_SPWG_LEASING = 'SPWG - Leasing'; 
    public static final String PROFILE_SPWG_LEASING_ADMINISTRATOR = 'SPWG - Leasing Administrator'; 
    public static final String PROFILE_SPWG_LEASING_BUILDING_MANAGER = 'SPWG - Leasing Building Manager'; 
    public static final String PROFILE_SPWG_LEASING_CATEGORY_MANAGER = 'SPWG - Leasing Category Manager';
    public static final String PROFILE_SPWG_LEASING_MANAGER = 'SPWG - Leasing Manager';
    public static final String PROFILE_SPWG_SALES_CO = 'SPWG - Sales Co.';
    public static final String PROFILE_SPWG_IT_APPLICATION_PRD_SUPPORT = 'SPWG - IT Application & Production Support';
    public static final String PROFILE_SPWG_IT_INTEGRATION = 'SPWG - IT Integration';
    public static final String PROFILE_SPWG_IT_SECURITY = 'SPWG - IT Security';
    public static final String PROFILE_SPWG_IT_SYSTEM = 'SPWG - IT System';
    public static final String PROFILE_SPWG_IT_SYSTEM_ADMIN_FULL_ACCESS = 'SPWG - IT System Administrator (Full Access)';
    public static final String PROFILE_SPWG_LEGAL = 'SPWG - Legal';
    public static final String PROFILE_SPWG_LEGAL_MANAGER = 'SPWG - Legal Manager';
    public static final String PROFILE_SPWG_AR = 'SPWG - AR';
    public static final String PROFILE_SPWG_AR_MANAGER = 'SPWG - AR Manager';

    public static final String RECORD_TYPE_BUILDING = 'Building';
    public static final String RECORD_TYPE_BUILDING_FLOOR = 'Building Floor';
    public static final String RECORD_TYPE_CATEGORY = 'Category';

    public static final String TERMS_OF_PAYMENT_FULL_AMOUNT = 'เก็บเต็มจำนวน';
    public static final String TERMS_OF_PAYMENT_SOME_AMOUNT = 'เก็บบางส่วน';

    public static final String FORECAST_TENANT_TYPE_NEW_LEASE = 'New lease';
    public static final String FORECAST_TENANT_TYPE_EXISTING_TENANT = 'Existing tenant';


    public static final String GRADING_TIER_OPTION = 'Monthly คำนวณ GP ทุกเดือน';
    
    public static final Date SYSTEM_FIRSTDAY = Date.newInstance(1700, 1, 1);

    public static final String SINGLE_DISCOUNT = 'Single Discount';

    public static Map<String,String> OPPORUTNITY_GRADING_TIER = new Map<String,String>{
        'Monthly คำนวณ GP ทุกเดือน'=>'Monthly คำนวณ GP ทุกเดือน',
        'Yearly คำนวณ GP เมื่อยอดขายเกิน'=>'Yearly คำนวณ GP เมื่อยอดขายเกิน'
    };

    public static final String EVENT_RECORDTYPE_NAME = 'Event';
    public static final String EVENT_SPECIAL_HOLIDAY_RECORDTYPE_NAME = 'Special_Holiday';

    public static final String CONTRACT_STATUS_NEW = 'New';
    public static final String CONTRACT_STATUS_PENDING_APPROVE = 'Pending Approve';
    public static final String CONTRACT_STATUS_APPROVED = 'Approved Contract';
    public static final String CONTRACT_STATUS_PENDING_ACCOUNTING = 'Pending Accounting';
    public static final String CONTRACT_STATUS_PENDING_TENANT = 'Pending Tenant';
    public static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    public static final String CONTRACT_STATUS_CLOSED = 'Closed';
    public static final String CONTRACT_STATUS_TERMINATED = 'Terminated';
    public static final String CONTRACT_STATUS_RENEW = 'Renew';

}