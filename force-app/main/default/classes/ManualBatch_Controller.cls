public with sharing class ManualBatch_Controller {
    public with sharing class ScheduleJob {
        public Id jobId {get; set;}
        public String jobName {get; set;}
        public String jobStatus {get;set;}
        public String createdTime {get; set;}
        public String nextFireTime {get; set;}
        public String previousFireTime {get; set;}
        public String endTime {get; set;}

        public ScheduleJob(){
            this.jobId = null;
            this.jobName = '';
            this.jobStatus = '';
            this.createdTime = null;
            this.nextFireTime = null;
            this.previousFireTime = null;
            this.endTime = null;
        }
    }

    public with sharing class BatchJob  {
        public Id batchId {get; set;}
        public String batchName {get; set;}
        public String jobStatus {get; set;}
        public Integer JobTotal {get; set;}
        public Integer jobErrors {get; set;}
        public String createdDate {get; set;}
        public String completedDate {get; set;}
        public Integer jobItemsProcessed {get; set;}

        public BatchJob(){
            this.batchId = null;
            this.batchName = '';
            this.jobStatus = '';
            this.jobTotal = 0;
            this.jobErrors = 0;
            this.createdDate = null;
            this.completedDate = null;
            this.jobItemsProcessed = null;
        }
    }

    public static final Integer BATCH_MAX_SIZE = 2000;

    private Map<Id, ApexClass> apexClassMap;
    private Map<String, ScheduleJob> scheduleMapByBatchName = new Map<String, ScheduleJob>();

    public List<BatchJob> batchJobs {get; set;}
    public List<ScheduleJob> scheduleJobs {get;set;}
    public List<SelectOption> selectOptionList;
    public List<SelectOption> selectTypeList;
    public List<SelectOption> hourList = new List<SelectOption>();
    public List<SelectOption> minuteList = new List<SelectOption>();
    public Integer batchSize {get; set;}
    public String oneTimeValue {get; set;}
    public String batchName {get; set;}
    public String runType {get; set;}
    public String scheduleType {get; set;}
    public String dailyType {get; set;}
    public List<String> weeklyType {get; set;}
    public String monthlyType {get; set;}
    public String hoursInput {get; set;}
    public String minInput {get; set;}
    public Id deleteJobId {get; set;}
    public Map<String, String> displayClassWithNameMap = new Map<String, String>();

    public ManualBatch_Controller() {
        this.initial();
        this.assignBatchNameFromBatchConfiguration();
        this.refreshBatchJob();
        this.refreshScheduleJob();
        this.getScheduleTypeValue();
        this.getTypeValue();
        this.setUpSelectOptionList();
    }

    public void setUpSelectOptionList() {
        for(String eachBatch : displayClassWithNameMap.keySet()){
            selectOptionList.add(new SelectOption(eachBatch,displayClassWithNameMap.get(eachBatch)));
        }
    }
    
    public PageReference runBatch() {
        String messageDisplay = this.checkBatchName();
        if(messageDisplay != ''){ this.showError(messageDisplay); return null;}
        try{
            Type t = Type.forName(this.batchName);
            Database.executeBatch((Database.Batchable<SObject>) t.newInstance(), batchSize);
            this.showConfirm('Complet Run Batch ' + this.batchName);
        } catch(Exception e){
            this.showError('Exception : ' + this.batchName +e.getMessage() + e.getLineNumber() + e.getStackTraceString());
            return null;
        }
        refreshBatchJob();
        return null;
    }

    public PageReference runSchedule() {
        String messageDisplay = this.checkBatchName();
        if(messageDisplay != ''){ this.showError(messageDisplay); return null;}
        String todayYear = '*';
        String scheduleTime = '0 ' + Integer.valueOf(minInput) + ' ' + Integer.valueOf(hoursInput);
        if (this.scheduleType == 'Daily') {
            scheduleTime = this.runDaily(todayYear, scheduleTime);
        } else if (this.scheduleType == 'Weekly') {
            scheduleTime = this.runWeekly(todayYear, scheduleTime);
        } else if (this.scheduleType == 'Monthyly') {
            scheduleTime = this.runMonthly(todayYear, scheduleTime);
        } else if (this.scheduleType == 'One Time') {
            scheduleTime = this.runOneTime(todayYear, scheduleTime);
        } else {
            scheduleTime = null;
            this.showError('Exception : Please Select Schedule Type');
        }

        try {
            System.debug('this.batchName : '+this.batchName);
            String scheduleNameDisplayWithTime = ', ' + this.scheduleType + '_' + convertDateTimeToString(Datetime.now());
            if(scheduleTime == null) return null;
            Type eachType = Type.forName(this.batchName);
            System.debug('eachType : ' + eachType);
            if (this.batchName.contains('Batch')) {
                System.schedule(this.batchName + scheduleNameDisplayWithTime , scheduleTime, new SchedulableService(this.batchName, batchSize));
            } else if (this.batchName.contains('Schedule')) {
                System.schedule(this.batchName + scheduleNameDisplayWithTime , scheduleTime, (Schedulable) eachType.newInstance());
            } else {
                this.showError('Schedule Type does not match with Criteria'); return null;
            }
        } catch (Exception e) {
            this.showError('Exception : ' + e.getMessage());
            return null;
        }

        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Confirm,'Completed Running Schedule Job: ' + this.batchName + ', ' + this.scheduleType);
        ApexPages.addMessage(msg);
        refreshScheduleJob();
        return null;
    }

    public String checkBatchName(){
        String messageDisplay = '';
        if (this.batchSize == null || this.batchSize <= 0 || this.batchSize > BATCH_MAX_SIZE) {messageDisplay = 'Batch Size is invalid';}
        if (this.batchName.contains('-------') || this.batchName.contains('Topic :')) {messageDisplay = 'Please Select Batch Name';}
        return messageDisplay;
    }


    //========== Start of Action Schedule Type ==========
    public String runDaily(String todayYear, String scheduleTime){
        if (this.dailyType == 'EVERY_DAY') { scheduleTime += ' * * ? ' + todayYear;}
        else if (this.dailyType == 'EVERY_WEEKDAY') {scheduleTime += ' ? * MON-FRI ' + todayYear;}
        else { this.showError('Exception : Please select daily type.'); return null;}
        return scheduleTime;
    }

    public String runWeekly(String todayYear, String scheduleTime){
        if (this.weeklyType == null || this.weeklyType.size() == 0) {
            this.showError('Exception : Please select day of week.'); return null;
        }
        scheduleTime += ' ? * ' + String.join(this.weeklyType, ',') + ' ' + todayYear;
        return scheduleTime;
    }

    public String runMonthly(String todayYear, String scheduleTime){
        if (this.monthlyType == 'Last') {scheduleTime += ' L * ? ' + todayYear;}
        else {scheduleTime += ' ' + this.monthlyType + ' * ? ' + todayYear;}
        return scheduleTime;
    }

    public String runOneTime(String todayYear, String scheduleTime){
        Date dateFromInput;
        try {
            dateFromInput = Date.parse(this.oneTimeValue);
        } catch(Exception e) {
            try {
                dateFromInput = Date.valueOf(this.oneTimeValue);
            } catch (Exception ex) {
                this.showError('Exception : Invalid date.');
                return null;
            }
        }

        Time inputTime = Time.newInstance(Integer.valueOf(this.hoursInput), Integer.valueOf(this.minInput) + 10, 0, 0);
        if (dateFromInput != null && dateFromInput < System.today() || ( dateFromInput == System.today() && inputTime < System.now().time())) {
            this.showError('Exception : Date and time must be current time +10 min.');
            return null;
        }
        DateTime dateTimeInput = DateTime.newInstance(dateFromInput.year(), dateFromInput.month(), dateFromInput.day());
        String[] splitDate = dateTimeInput.format('d/MM/yyyy').split('/');
        scheduleTime += ' ' + splitDate[0] + ' ' + splitDate[1] + ' ? ' + splitDate[2];
        return scheduleTime;
    }
    //========== End of Action Schedule Type ==========

    //========== Start of Refresh ==========
    public void refreshBatchJob() {
        Map<String, BatchJob> jobMapByBatchName = new Map<String, BatchJob>();
        List<AsyncApexJob> listApexJob = [SELECT ApexClassId, ApexClass.Name, TotalJobItems, Status, NumberOfErrors, JobItemsProcessed, CreatedDate, CompletedDate FROM AsyncApexJob WHERE ApexClassId IN :apexClassMap.keySet() AND JobType = 'BatchApex' AND CreatedDate = TODAY ORDER BY CreatedDate DESC];
        BatchJob batchjob;
        for(AsyncApexJob eachApexJob : listApexJob) {
            if (!jobMapByBatchName.containsKey(eachApexJob.ApexClass.Name)) {
                batchJob = new BatchJob();
                batchJob.batchId = eachApexJob.ApexClassId;
                batchJob.batchName = eachApexJob.ApexClass.Name;
                batchJob.jobStatus = eachApexJob.Status;
                batchJob.jobTotal = eachApexJob.TotalJobItems;
                batchJob.jobItemsProcessed = eachApexJob.JobItemsProcessed;
                batchJob.jobErrors = eachApexJob.NumberOfErrors;
                batchJob.createdDate = getTimeZoneValue(eachApexJob.CreatedDate);
                batchJob.completedDate = getTimeZoneValue(eachApexJob.CompletedDate);
                jobMapByBatchName.put(eachApexJob.ApexClass.Name, batchJob);
            }
        }
        batchJobs = jobMapByBatchName.values();
    }

    private Boolean isManualScheduleJob(CronTrigger scheduleJob){
        String jobName = scheduleJob.CronJobDetail.Name;
        Boolean isManual;
        if (!String.isBlank(jobName)) {
            String apexClassName = jobName.split(',')[0];
            isManual = this.displayClassWithNameMap.keySet().contains(apexClassName);
        } else {
            isManual = false;
        }
        return isManual;
    }

    public void refreshScheduleJob() {
        this.scheduleJobs.clear();
        List<CronTrigger> listScheduleJob = [SELECT Id, CronJobDetail.Name, State, CreatedDate, NextFireTime, PreviousFireTime, EndTime FROM CronTrigger ORDER BY CreatedDate DESC];
        for (CronTrigger eachSchedule : listScheduleJob) {
            if (this.isManualScheduleJob(eachSchedule)) {
                ScheduleJob scheduleJob = new ScheduleJob();
                scheduleJob.jobId = eachSchedule.Id;
                scheduleJob.jobName = eachSchedule.CronJobDetail.Name;
                scheduleJob.jobStatus = eachSchedule.State;
                scheduleJob.createdTime = getTimeZoneValue(eachSchedule.CreatedDate);
                scheduleJob.nextFireTime = getTimeZoneValue(eachSchedule.NextFireTime);
                scheduleJob.previousFireTime = getTimeZoneValue(eachSchedule.PreviousFireTime);
                scheduleJob.endTime = getTimeZoneValue(eachSchedule.EndTime);
                this.scheduleJobs.add(scheduleJob);
            }
        }
    }   
    //========== End of Refresh ==========

    //========== Start of Setup ==========
    public void initial() {
        this.weeklyType = new List<String>();
        this.batchSize = 200;
        this.batchJobs = new List<BatchJob>();
        this.scheduleJobs = new List<ScheduleJob>();
        this.selectOptionList = new List<SelectOption>();
        this.scheduleType = 'Daily';
        this.runType = 'Manual';
    }

    public void assignBatchNameFromBatchConfiguration() {
        List<Batch_Configuration__mdt> getAllBatchConfigurationList = this.getAllBatchConfigurationmdt();
        if(!getAllBatchConfigurationList.isEmpty()){
            String topicName = '';
            for(Batch_Configuration__mdt eachBatch : getAllBatchConfigurationList){
                if(topicName != eachBatch.Topic__c){
                    topicName = eachBatch.Topic__c;
                    String topicValue = 'Topic : ' + topicName;
                    String topicLine = '---------------------------------------------------------------';
                    displayClassWithNameMap.put(topicLine+topicName,topicLine);
                    displayClassWithNameMap.put(topicValue,topicValue);
                }
                displayClassWithNameMap.put(eachBatch.Batch_Name__c, ' - ' + eachBatch.MasterLabel);
            }
            apexClassMap = new Map<Id, ApexClass>([SELECT id, Name FROM ApexClass WHERE ApexClass.Name in: displayClassWithNameMap.keySet() ORDER BY Name ASC]);
        } else {
            apexClassMap = new Map<Id, ApexClass>();
        }
    }

    public List<Batch_Configuration__mdt> getAllBatchConfigurationmdt(){
        List<Batch_Configuration__mdt> batchConfigurationmdt = new List<Batch_Configuration__mdt>();
        batchConfigurationmdt = [ SELECT Id, Batch_Name__c, DeveloperName, MasterLabel, Topic__c
                                  FROM Batch_Configuration__mdt ORDER BY Topic__c];
        return batchConfigurationmdt;
    }

    public Pagereference deleteSchedule() {
        System.abortJob(deleteJobId);
        refreshScheduleJob();
        return null;
    }

    public void showError(String errorMsg) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(msg);
    }

    public void showInfo(String msgLog) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, msgLog);
        ApexPages.addMessage(msg);
    }

    public void showConfirm (String msgLog) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, msgLog);
        ApexPages.addMessage(msg);
    }
    
    public List<SelectOption> getHourList() {
        hourList.clear();
        for (Integer i = 0 ; i < 24 ; i++) {
            hourList.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return hourList;
    }

    public List<SelectOption> getMinuteList() {
        minuteList.clear();
        String min;
        for (Integer i = 0 ; i < 60 ; i = i + 5) {
            min = (String.valueOf(i).length() < 2) ? '0' + String.valueOf(i) : String.valueOf(i);
            minuteList.add(new SelectOption(min, min));
        }
        return minuteList;
    }

    public List<SelectOption> getFieldValue() {
        return this.selectOptionList;
    }

    public List<SelectOption> getTypeValue() {
        this.selectTypeList = new List<SelectOption>();
        this.selectTypeList.add(new SelectOption('Manual', 'Manual'));
        this.selectTypeList.add(new SelectOption('Schedule', 'Schedule'));
        return this.selectTypeList;
    }

    public List<SelectOption> getScheduleTypeValue() {
        this.selectTypeList = new List<SelectOption>();
        this.selectTypeList.add(new SelectOption('Daily', 'Daily'));
        this.selectTypeList.add(new SelectOption('Weekly', 'Weekly'));
        this.selectTypeList.add(new SelectOption('Monthly', 'Monthly'));
        this.selectTypeList.add(new SelectOption('One Time', 'One Time'));
        return this.selectTypeList;
    }

    public List<SelectOption> getDailyTypeValue() {
        List<SelectOption> listOptions = new List<SelectOption>();
        listOptions.add(new SelectOption('EVERY_WEEKDAY', 'Every weekday'));
        listOptions.add(new SelectOption('EVERY_DAY', 'Every day'));
        return listOptions;
    }

    public List<SelectOption> getDayList() {
        List<SelectOption> listOptions = new List<SelectOption>();
        for (Integer i = 1; i < 32 ; i++) {
            listOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        listOptions.add(new SelectOption('Last','Last'));
        return listOptions;
    }

    public List<SelectOption> getWeeklyValue() {
        List<SelectOption> listOptions = new List<SelectOption>();
        listOptions.add(new SelectOption('SUN', 'Sunday'));
        listOptions.add(new SelectOption('MON', 'Monday'));
        listOptions.add(new SelectOption('TUE', 'Tuesday'));
        listOptions.add(new SelectOption('WED', 'Wednesday'));
        listOptions.add(new SelectOption('THU', 'Thursday'));
        listOptions.add(new SelectOption('FRI', 'Friday'));
        listOptions.add(new SelectOption('SAT', 'Saturday'));
        return listOptions;
    }

    public String getNextScheduleTime() {
        DateTime currentDateTime = System.now().addSeconds(15);                            
        String nextScheduleTime = String.valueof(currentDateTime.second()) +' '+String.valueof(currentDateTime.minute())+' '+
                                    String.valueof(currentDateTime.hour())+' '+String.valueof(currentDateTime.day())+' '+
                                    String.valueof(currentDateTime.month())+' ? '+ System.now().format('y');
        System.debug('nextScheduleTime : ' + nextScheduleTime);
        return nextScheduleTime;
    }
    //============== End of Setup =====================
 
    /**@description Indicates if a custom message is present*/
    public boolean hasMessages {
        get {
             return ApexPages.hasMessages();
        }
    }
 
    /**@description The custom error message */
    public String errorMessage {
        get {
            if (hasMessages) {
                return ApexPages.getMessages()[0].getDetail();
            }
            return null;
        }
    }
 
    /**@description The type of message: 'error' or 'success' */
    public string alertType {
        get {
            if (hasMessages) {
                return ApexPages.getMessages()[0].getSeverity() == ApexPages.Severity.ERROR ? 'error' : 'success';
            }
            return 'success';
        }
        private set;
    }

    public static String convertDateTimeToString(DateTime targetDateTime) {
        // yyyyMMdd_HHmmssSSS
        if(targetDateTime == null) return '';
        DateTime dateToday = targetDateTime;
        //date
        String month = String.valueOf(dateToday.month());
        String day = String.valueOf(dateToday.day());
        if(month.length()==1) month = '0' + month;
        if(day.length()==1) day = '0' + day;
        String currentDate = String.valueOf(dateToday.year()) + month + day;
        //time
        String hour = String.valueOf(dateToday.hour());
        String minute = String.valueOf(dateToday.minute());
        String second = String.valueOf(dateToday.second());
        String millisecond = String.valueOf(dateToday.millisecond());
        if(hour.length()==1) hour = '0' + hour;
        if(minute.length()==1) minute = '0' + minute;
        if(second.length()==1) second = '0' + second;
        if(millisecond.length()==1) millisecond = '00' + millisecond;
        else if(millisecond.length()==2) millisecond = '0' + millisecond;
        String currentTime = hour + minute + second + millisecond;
        return currentDate + '_' + currentTime;
    }

    //returns the properly formatted datetime value
    public static String getTimeZoneValue(DateTime dateTimeInput) {
        if (dateTimeInput == null) return '';
        Map<String, String> mappedValues = getLocaleDateMap(); //populate the map with all the locale specific datetime formats
        String userLocale = UserInfo.getLocale(); //grab the locale of the user
        String dateTimeWithFormat = 'M/d/yyyy h:mm a'; //variable for the datetime format defaulted to the US format
        if (mappedValues.containsKey(userLocale)) { //if the map contains the correct datetime format
            dateTimeWithFormat = mappedValues.get(userLocale); //grab the datetime format for the locale
        }
        return dateTimeInput.format(dateTimeWithFormat);
    }
    
    public static  Map<String, String> getLocaleDateMap() {
        Map<String, String> locale_map = new Map<String, String>();
        locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
        locale_map.put('bg_BG', 'yyyy-M-d H:mm');
        locale_map.put('ca', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('cs', 'd.M.yyyy H:mm');
        locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
        locale_map.put('da', 'dd-MM-yyyy HH:mm');
        locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
        locale_map.put('de', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('el_GR', 'd/M/yyyy h:mm a');
        locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
        locale_map.put('en_B', 'M/d/yyyy h:mm a');
        locale_map.put('en_BM', 'M/d/yyyy h:mm a');
        locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
        locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_GH', 'M/d/yyyy h:mm a');
        locale_map.put('en_ID', 'M/d/yyyy h:mm a');
        locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
        locale_map.put('en_SG', 'M/d/yyyy h:mm a');
        locale_map.put('en_US', 'M/d/yyyy h:mm a');
        locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
        locale_map.put('es', 'd/MM/yyyy H:mm');
        locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
        locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_ES', 'd/MM/yyyy H:mm');
        locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
        locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('et_EE', 'd.MM.yyyy H:mm');
        locale_map.put('fi', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
        locale_map.put('fr', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
        locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
        locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
        locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
        locale_map.put('hu', 'yyyy.MM.dd. H:mm');
        locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
        locale_map.put('is_IS', 'd.M.yyyy HH:mm');
        locale_map.put('it', 'dd/MM/yyyy H.mm');
        locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
        locale_map.put('iw', 'HH:mm dd/MM/yyyy');
        locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
        locale_map.put('ja', 'yyyy/MM/dd H:mm');
        locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
        locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
        locale_map.put('km_KH', 'M/d/yyyy h:mm a');
        locale_map.put('ko', 'yyyy. M. d a h:mm');
        locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
        locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
        locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
        locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
        locale_map.put('nl', 'd-M-yyyy H:mm');
        locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
        locale_map.put('nl_NL', 'd-M-yyyy H:mm');
        locale_map.put('nl_SR', 'd-M-yyyy H:mm');
        locale_map.put('no', 'dd.MM.yyyy HH:mm');
        locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
        locale_map.put('pl', 'yyyy-MM-dd HH:mm');
        locale_map.put('pt', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
        locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
        locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
        locale_map.put('ru', 'dd.MM.yyyy H:mm');
        locale_map.put('sk_SK', 'd.M.yyyy H:mm');
        locale_map.put('sl_SI', 'd.M.y H:mm');
        locale_map.put('sv', 'yyyy-MM-dd HH:mm');
        locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
        locale_map.put('th', 'M/d/yyyy h:mm a');
        locale_map.put('th_TH', 'd/M/yyyy, H:mm');
        locale_map.put('tr', 'dd.MM.yyyy HH:mm');
        locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
        locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
        locale_map.put('zh', 'yyyy-M-d ah:mm');
        locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
        locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
        locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
        return locale_map;
    }

}