public class SOQLBuilder {
    @TestVisible
    private String sObjectAPI;
    @TestVisible
    private List<String> allFieldsInObject;
    @TestVisible
    private String condition;
    public SOQLBuilder(String fromObject) {
        this.sObjectAPI = fromObject;
        this.condition  = '';
        this.setAllFieldInObject();
    }
    public SOQLBuilder(String fromObject,Boolean lightmode){
        this.sObjectAPI = fromObject;
        this.condition  = '';
        if(lightmode){
            this.allFieldsInObject = new List<String>();
        }else{
            this.setAllFieldInObject();     
        }
    }
    public void excludeField(List<String> fields){
        for(String fieldToExclude : fields){
            if(allFieldsInObject.indexOf(fieldToExclude)!=-1){
                this.allFieldsInObject.remove(allFieldsInObject.indexOf(fieldToExclude));
            }   
        }
    }
    private void setAllFieldInObject(){
        this.allFieldsInObject = SObjectUtils.getAllFieldInObject(this.sObjectAPI);
    }
    /**
     * [addField description]
     * @param additionalField [description] field to be query as string
     */
    public void addField(String additionalField){
        this.allFieldsInObject.add(additionalField);
    }
    public void overrideMainSObject(String override_SObjectAPI){
        this.sObjectAPI = override_SObjectAPI;
    }
    /**
     * [addAllFieldFromRelation description]
     * @param referenceField [description] like Parent , CIF__r 
     * @param parentObject   [description] like Account, Deposit__c
     */
    public void addAllFieldFromRelation(String referenceField,String parentObject){
        List<String> parentObjectFields = SObjectUtils.getAllFieldInObject(parentObject);   
        for(String eachField :parentObjectFields){
            this.allFieldsInObject.add(referenceField+'.'+eachField);
        }
    }
    public void addAllFieldFromRelation(String referenceField,SOQLBuilder parentBuilder){
        for(String eachField :parentBuilder.allFieldsInObject){
            this.allFieldsInObject.add(referenceField+'.'+eachField);
        }
    }
    public void addAllChildField(String referenceField,String childObject,String childCondition){
        List<String> childObjectFields = SObjectUtils.getAllFieldInObject(childObject);
        String soql = '( Select '+String.join(childObjectFields, ', ')+' From '+referenceField+' '+childCondition+') ';
        this.allFieldsInObject.add(soql);
    }
    public void addAllChildField(String referenceField, SOQLBuilder childBuilder){
        childBuilder.overrideMainSObject(referenceField);
        this.allFieldsInObject.add('( '+childBuilder.getQueryString()+' )');    
    }

    public void addCondition(String criteria){
        this.condition = criteria;
    }
    public String getQueryString(){
        String soql = 'Select ';
        if(!allFieldsInObject.isEmpty()){
            soql += String.join(allFieldsInObject, ', ')+' From '+sObjectAPI+' '+condition;
        }
        System.debug('SOQL : '+soql);
        return soql;
    }
}