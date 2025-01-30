public without sharing class TriggerActivation {

    private static Map<String, String> mapField = new Map<String, String> {
                                                'Opportunity' => 'OpportunityTrigger__c',
                                                'Contract__c' => 'ContractTrigger__c',
                                                'PDF_Content__c' => 'PDFContentTrigger__c',
                                                'Target__c' => 'TargetTrigger__c',
                                                'Traffic__c' => 'TrafficTrigger__c'
                                            };
    private String field;
    private String sObj;
    private static TriggerActivation instance = null;
    private Boolean isActiveTrigger = false;

    public static TriggerActivation getInstance(String Obj) {
        instance = new TriggerActivation(Obj);
        return instance;
    }

    public TriggerActivation (String Obj) {
        this.sObj = Obj;
        this.field = mapField.get(Obj);
    }

    public Boolean isActiveTrigger() {
        TriggerActivation__c meta = TriggerActivation__c.getInstance();

        this.isActiveTrigger = meta != null && (meta.get(this.field) != null ? (Boolean)meta.get(this.field) : false);
        return this.isActiveTrigger;
    }
}