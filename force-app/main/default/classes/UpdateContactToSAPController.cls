public without sharing class UpdateContactToSAPController {

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

    @AuraEnabled
    public static SyncResponse calloutAndUpdateContact(Contact contact, String contactId){  
        try{
            System.debug('contact : ' + contact);
            contact.Id = contactId;
            Boolean isSuccess = false;
            Object res;
            String resMessage;
            if(contact.AccountId != null) {
                Account acc = [SELECT Id, Customer_ID__c FROM Account WHERE Id =: contact.AccountId limit 1];
                contact.Account = acc;
            }
            String title = contact.Salutation_TH__c;

            if(titleMap.containsKey(title)) contact.Salutation_TH__c = titleMap.get(title);
            else contact.Salutation_TH__c = '';
            if(contact.Contact_ID__c != null) {
                WSCalloutUpdateContactToSAP.response resUpdateContact = WSCalloutUpdateContactToSAP.callout(contact);
                isSuccess = resUpdateContact.isSuccess;
                resMessage = resUpdateContact.message;
                res = resUpdateContact;
            } else {
                // WSCalloutCreateContactToSAP.response resInsertContact = WSCalloutCreateContactToSAP.callout(new List<Contact>{contact});
                WSCalloutCreateContactToSAP.response resInsertContact = WSCalloutCreateContactToSAP.callout(contact);
                isSuccess = resInsertContact.isSuccess;
                resMessage = resInsertContact.message;
                // if(resInsertContact.payload != null && resInsertContact.payload.size() > 0) {
                //     contact.Contact_ID__c = resInsertContact.payload.get(0).contactId;
                // }
                if(resInsertContact.payload != null && resInsertContact.payload != null) {
                    contact.Contact_ID__c = resInsertContact.payload.contactId;
                }
                res = resInsertContact;
            }

            contact.Salutation_TH__c = title;
            if(isSuccess){
                Database.SaveResult SR = Database.update(contact, false);
                if(!SR.isSuccess()){
                    for(Database.Error error : SR.getErrors()){
                        return new SyncResponse('Error',null,'Update Error: ' + error.getMessage());
                    }    
                }
            } else {
                String message = 'API Callout Error: ';
                String errorMessage = resMessage != null ? resMessage : String.valueOf(res);
                return new SyncResponse('Error',null, message + errorMessage);
            }
            return new SyncResponse('Success',new List<Contact>{contact},'');
        }catch(Exception e){
            // return 'Error';
            System.debug(e);
            return new SyncResponse('Error',null,'API Callout Error: '+e);
        }   
    }

    public class SyncResponse{

        @AuraEnabled public String status;
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String remark;
        
        public SyncResponse (){}

        public SyncResponse(String inputStatus, List<Object> inputData, String inputRemark){
            status = inputStatus;
            data = inputData;
            remark = inputRemark;
        }
    }

}