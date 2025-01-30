public with sharing class SchedulableService implements Schedulable {
    private String batchName;
    private Integer batchSize;
    private Database.Batchable<SObject> batchObj;

    public SchedulableService(String batchName) {
        this.batchName = batchName;
    }

    public SchedulableService(String batchName, Integer batchSize) {
        this.batchName = batchName;
        this.batchSize = batchSize;
    }

    public SchedulableService(Database.Batchable<SObject> batchObj, Integer batchSize) {
        this.batchObj = batchObj;
        this.batchSize = batchSize;
    }

    public void execute(SchedulableContext sc) {
        if(batchObj != null){
            if(batchSize == null || batchSize < 1){
                Database.executeBatch(batchObj);
            }else{
                Database.executeBatch(batchObj, batchSize);
            }
        }else{
            Type targetType = Type.forName(batchName);

            if(batchSize == null || batchSize < 1){
                Database.executeBatch((Database.Batchable<SObject>) targetType.newInstance());
            }else{
                Database.executeBatch((Database.Batchable<SObject>) targetType.newInstance(), batchSize);
            }
        }
    }
}