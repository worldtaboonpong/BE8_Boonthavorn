public class Utility {
    public static final String RELATIONSPLITTER = '\\.';
    public static String organizationInstanceName;
    public static Map<Id,BrandTemplate> brandTemplateMap;

    public static List<String> getAllSObjectAPINameList(){
        List<String> sObjectAPINameList = new List<String>();

        for ( Schema.SObjectType o : Schema.getGlobalDescribe().values())
        {
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            sObjectAPINameList.add(objResult.getName());
        }

        return sObjectAPINameList;
    }

    public static List<String> getAllFieldFromsObject(String sObjectName){
        SObjectType targetsObject = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> mfields = targetsObject.getDescribe().fields.getMap();

        List<String> fieldListAPIList = new List<String>();
        fieldListAPIList.addAll(mfields.keySet());

        return fieldListAPIList;
    }

    public static String getDefaultValuePicklist(String ObjectApi_name,String Field_name){ 
        String defaultValue = '';
        List<SelectOption> lstPickvals = new List<SelectOption>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry eachValue : pick_list_values) { //for all values in the picklist list
            if (eachValue.isDefaultValue()){
                defaultValue = eachValue.getValue();
            }
        }

        return defaultValue;
    }

    public static List<SelectOption> getPicklistValues(String ObjectApi_name,String Field_name){ 
        List<SelectOption> lstPickvals = new List<SelectOption>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry eachValue : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(new SelectOption(eachValue.getValue(),eachValue.getLabel()));//add the value  to our final list
        }

        return lstPickvals;
    }

    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }

    public static String getLookupValue(SObject record, String fullLookupFieldAPI) {
        if(String.isBlank(fullLookupFieldAPI)) { return null; }
        SObject loopObject = record;
        String lookupValue = '';
        String[] lookupFields = fullLookupFieldAPI.split(RELATIONSPLITTER);
        for(Integer index = 0; index < lookupFields.size(); index++) {
            if(loopObject == null) { return null; }
            if(index == lookupFields.size() - 1) {
                lookupValue = String.valueOf(loopObject.get(lookupFields[index]));
                if(lookupValue == null && isRichText(loopObject, lookupFields[index])) {
                    lookupValue = '';
                }
            } else {
                loopObject = loopObject.getSobject(lookupFields[index]);
            }
        }
        return lookupValue;
    }
    public static String getOrgInst(){
        String orgInst = URL.getSalesforceBaseUrl().getHost();
        orgInst = orgInst.substring(0, orgInst.indexOf('.'));
        if(orgInst.contains('-')){
            orgInst = orgInst.substringAfterLast('-');
        }else{
            orgInst = 'Production';
        }
        return orgInst;
    }

    public static BrandTemplate getBrandTemplate(Id brandTemplateId){
        if(brandTemplateMap != null && brandTemplateMap.containsKey(brandTemplateId)) return brandTemplateMap.get(brandTemplateId);
        List<BrandTemplate> eachBrandTemplateList = new List<BrandTemplate>();
        eachBrandTemplateList = [select id, name, value from BrandTemplate where id =:BrandTemplateId limit 1];
        if(!eachBrandTemplateList.isEmpty()){
            brandTemplateMap = new Map<Id,BrandTemplate>();
            brandTemplateMap.put(eachBrandTemplateList.get(0).Id, eachBrandTemplateList.get(0));
            return brandTemplateMap.get(brandTemplateId);
        }
        return null;
    }

    public static String getOrganization(){
        if(organizationInstanceName != null) return organizationInstanceName;
        Organization targetOrg = [Select InstanceName From Organization Limit 1];      
        organizationInstanceName = targetOrg.InstanceName;
        return  organizationInstanceName;
    }

    public static Boolean isRichText(SObject targetObject, String fieldName) {
        Boolean isRichText = false;
        Map<String, Schema.SObjectField> objFieldMap = targetObject.getSObjectType().getDescribe().fields.getMap();
        Schema.DescribeFieldResult field = objFieldMap.get(fieldName).getDescribe();
        if (field.getType() == Schema.DisplayType.TEXTAREA && field.isHtmlFormatted()) {
            isRichText = true;
        }
        return isRichText;
    }

    public static String setDecToFormatCommaTwoDigits(Decimal numberInput) {
        String minusTxt = '';
        if(numberInput < 0){
            numberInput = numberInput * (-1);
            minusTxt = '-';
        }
        numberInput = numberInput.doubleValue() * 1.00;
        Long numberLong = (Long)numberInput.longValue();
        Decimal numberDigit = numberInput - numberLong;
        return minusTxt + numberLong.format() + String.valueOf(Decimal.valueOf(numberDigit.doubleValue()).setScale(2)).substring(1, 4);

    }

    public static Boolean isPeriodOverlap(Date startDate1, Date endDate1, Date startDate2, Date endDate2) {
        return (startDate1 <= endDate2) && (startDate2 <= endDate1);
    }

    public static String changeDateToStringShortMonthFormat(Date dateInput){
        try {
            String userLocale = UserInfo.getLocale(); // th_TH
            if(dateInput != null){
                Datetime output = dateInput;
                if(userLocale == 'th_TH') output = dateInput.addYears(543);
                return output.format('d MMM yyyy');
            }
            return '';
        } catch (DmlException e) {
            System.debug('changeDateToStringBDEra exception has occurred: ' + e.getMessage());
            throw e;
        }
    }

    public static String changeDateToStringShortMonthNoDayFormat(Date dateInput){
        try {
            String userLocale = UserInfo.getLocale(); // th_TH
            if(dateInput != null){
                Datetime output = dateInput;
                if(userLocale == 'th_TH') output = dateInput.addYears(543);
                return output.format('MMM yyyy');
            }
            return '';
        } catch (DmlException e) {
            System.debug('changeDateToStringBDEra exception has occurred: ' + e.getMessage());
            throw e;
        }
    }

    public static Decimal getMonthBetween(Date startDate, Date endDate){
        Decimal monthDiff = startDate.monthsBetween(endDate);
        Decimal factor = 0;

        if(endDate.day() > startDate.day()) {
            monthDiff = monthDiff + 1;
        }
        
        if(startDate.addMonths((Integer)monthDiff).addDays(-1) == endDate) {
            return monthDiff;
        } else {
            Integer dateDiff = (startDate.addMonths((Integer)monthDiff).addDays(-1)).daysBetween(endDate);
            Integer numberDays = date.daysInMonth(endDate.year(), endDate.month());
            factor = ((Decimal)dateDiff/numberDays);
            return (monthDiff + factor);
        }
    }

    /*public static Boolean isValidateMigrationProfile(Opportunity targetOpportunity){
        Id profileId= userinfo.getProfileId();
        Profile currentUserProfile = [Select Id,Name from Profile where Id =: profileId];
        String profileName = currentUserProfile.Name;
        if (profileName == tms_ProfileMigrationSetting__c.getInstance().tms_ProfileName__c && targetOpportunity.tms_IsMigrate__c) return true;
        return false;
    }*/

    public static Boolean isLastDateOfMonth(Date targetDate){
        Integer year = targetDate.year();
        Integer month = targetDate.month();
        Integer day = targetDate.day();
        Integer numberOfDay = Date.daysInMonth(year, month);
        return day == numberOfDay;
    }

    public static Boolean isFirstDate(Date targetDate){
        Integer day = targetDate.day();
        return day == 1;
    }
    
    public static Boolean isDecimal(String s){
        Boolean returnValue;
        try{
            Decimal.valueOf(s);
            returnValue = true; 
        } catch (Exception e) {
            returnValue = false;
        }
        return returnValue;
    }
}