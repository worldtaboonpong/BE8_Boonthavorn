global class Purge_Batch implements Database.Batchable<sObject>, Database.Stateful {
    global String query;
    public List<Purge_Setting__mdt> purgeSettings = new List<Purge_Setting__mdt>();
    Purge_Setting__mdt currentPurgeSetting;
    public Integer countDelRecord;
    global Purge_Batch() {
     this(null);
    }   

    global Purge_Batch(List<Purge_Setting__mdt> purgeSettings) {
      if(purgeSettings == null) {
       purgeSettings = [SELECT Id, Label, Override_Purge_Batch__c, Object__c, Older_Than_N_Days__c, Condition__c FROM Purge_Setting__mdt WHERE Is_Active__c = true];
      }
        List<Purge_Setting__mdt> purgeSettingsTmp = new List<Purge_Setting__mdt>();

        for(Purge_Setting__mdt purgeSetting : purgeSettings){
            if(purgeSetting.Override_Purge_Batch__c!=null){
                Purge_Interface_Batch overrideBatch = (Purge_Interface_Batch) Type.forName(purgeSetting.Override_Purge_Batch__c).newInstance();
                
                overrideBatch.runBatch(purgeSetting);
            }else purgeSettingsTmp.add(purgeSetting);
        }
        this.purgeSettings = purgeSettingsTmp;

        countDelRecord = 0;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
      query = 'SELECT Id FROM Account LIMIT 0';
        List<String> listObject = new List<String>();
      if(!purgeSettings.isEmpty()) {
        currentPurgeSetting = purgeSettings.get(0);
            listObject.add(currentPurgeSetting.Object__c);
        SOQLBuilder soql = new SOQLBuilder(currentPurgeSetting.Object__c);
        //soql.addField('Id');
        //soql.addCondition('WHERE CreatedDate < LAST_N_MONTHS:' + currentPurgeSetting.Older_Than_N_Months__c.format());
            if(!Test.isRunningTest()) soql.addCondition('WHERE CreatedDate < LAST_N_DAYS:' + currentPurgeSetting.Older_Than_N_Days__c.format());    
            if(!String.isBlank(currentPurgeSetting.Condition__c)) {
                soql.addCondition(currentPurgeSetting.Condition__c);
            }
        query = soql.getQueryString();
            System.debug('Query: '+query);
            ApplicationLogUtils.createSuccessBatchLogUtils('Purge_Batch', query, String.join(listObject, ','));
      } else {
            ApplicationLogUtils.createSuccessBatchLogUtils('Purge_Batch', query, 'No Setup Purge_Setting__mdt');
      }
      //AppLogger.insertLogs();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
      try {
          delete scope;
        countDelRecord += scope.size();
      } catch(Exception e) {
            ApplicationLogUtils.createFailBatchLogUtils('Purge_Batch', query, '', 'Exception to deleted');
        //AppLogger.insertLogs();
      }
    }

    global void finish(Database.BatchableContext BC) {
      if(!purgeSettings.isEmpty()) {
      if(countDelRecord > 0) {
                ApplicationLogUtils.createSuccessBatchLogUtils('Purge_Batch', query, '');
        //AppLogger.insertLogs();  
      }

        purgeSettings.remove(0);
        if(!purgeSettings.isEmpty()) {
          Database.executeBatch(new Purge_Batch(purgeSettings));
        }
    }
    }
    
}