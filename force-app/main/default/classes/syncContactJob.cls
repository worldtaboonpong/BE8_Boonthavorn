public class syncContactJob implements Queueable, Database.AllowsCallouts  {

    public static Map<String,String> titleMap = new Map<String,String>{
        'คุณ'=>'0001',
        'นาย'=>'0002',
        'หจก.'=>'0003',
        'บจก.'=>'0004',
        'บมจ.'=>'0005',
        'นาง'=>'0006',
        'นางสาว'=>'0007',
        'Mr.'=>'0008',
        'Mrs.'=>'0009',
        'Miss'=>'0010',
        'นิติบุคคล'=>'0011',
        'หสม.'=>'0012',
        'คณะบุคคล'=>'0013',
        'มูลนิธิ'=>'0014',
        ''=>'0015',
        'โรงเรียน'=>'0016',
        'โรงแรม'=>'0017',
        'วัด'=>'0018',
        'พระสงฆ์'=>'0019',
        'บาทหลวง'=>'0020',
        'หม่อมหลวง'=>'0021',
        'หม่อมราชวงศ์'=>'0022',
        'หม่อมเจ้า'=>'0023',
        'ศ.'=>'0024',
        'ผศ.'=>'0025',
        'รศ.'=>'0026',
        'มหาวิทยาลัย'=>'0027',
        'โรงพยาบาล'=>'0028',
        'สนง.'=>'0029',
        'สถานีตํารวจ'=>'0030',
        'ร้าน'=>'0031'
    };

    private List<Contact> conList;

    public syncContactJob(List<Contact> cons) {
        this.conList = cons;
    }

    public void execute(QueueableContext context) {
        if(!this.conList.isEmpty()) {
            Contact con = this.conList.get(0);
            String title = con.Salutation_TH__c;
            if(titleMap.containsKey(title)) con.Salutation_TH__c = titleMap.get(title);
            else con.Salutation_TH__c = '';

            WSCalloutCreateContactToSAP.response resInsertContact = WSCalloutCreateContactToSAP.callout(con);
            // Integer idx = 0;
            // for(WSCalloutCreateContactToSAP.responsePayload detail : resInsertContact.payload) {
            //     listContact[idx].Contact_ID__c = detail.contactId;
            //     idx++;
            // }
            // update(listContact);
            if(resInsertContact.payload != null && resInsertContact.payload != null) {
                con.Contact_ID__c = resInsertContact.payload.contactId;
            }
            con.Salutation_TH__c = title;
            update(con);
            this.conList.remove(0);

            if(this.conList.size() > 0) {
                ID jobID = System.enqueueJob(new syncContactJob(this.conList));
                System.debug('jobID: ' + jobID);
            }
        }
    }
}