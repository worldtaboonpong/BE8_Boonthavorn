@isTest
public with sharing class PDFContentTrigger_Test {

    public static Id recordTypeIdForPDFMaster = RecordTypeUtility.getRecordTypeId('PDF_Content__c','Content');

    @TestSetup
    static void makeData(){
       PDF_Content__c pdfContentMaster = new PDF_Content__c(
            Sequence__c = 0,
            Content__c = '<p>ทดสอบการใส่ sequence</p><p> </p><p>{VF:PDFSpace_OPQuotationtable}</p><p> </p><p style="text-align: center;">{LOOPRELATEDOBJ:OpportunityLineItem__c;LOOKUPFIELD:Opportunity__c;FIELDS:Unit__r.Building__r.Building_Abbreviated__c, Unit__r.Floor__r.Floor_Short_Name__c, Unit__r.Name} </p><p style="text-align: center;">[SOURCE:ROImage_{FIELDS:Unit__r.Building__r.Building_Abbreviated__c}_{FIELDS:Unit__r.Floor__r.Floor_Short_Name__c}_{FIELDS:Unit__r.Name}.jpg]</p><p style="text-align: center;">{ENDLOOPRELATEDOBJ} </p><p> </p><p> </p><p><span style="color: rgb(0,0,0);">{FIELD:Building__r.Name}</span></p><p><span style="color: rgb(0,0,0);">{FIELD:Name}</span></p><p> </p><p> </p><p> </p><p> </p>',
            Is_Active__c = true,
            Is_Show_Sequence__c = true,
            Is_Optional__c = true,
            Object__c = 'Opportunity',
            Language__c = 'Thai',
            Continue_From_Above__c = true,
            RecordTypeId = recordTypeIdForPDFMaster,
            Rental_Type__c = 'Space_Rental'
        );
        insert pdfContentMaster;

    }

    @isTest
    static void testPDFContentTrigger(){
        TriggerActivation__c triggerFieldValueSetting = new TriggerActivation__c();
        triggerFieldValueSetting.PDFContentTrigger__c = true;
        insert triggerFieldValueSetting;

        PDF_Content__c pdfContent = [SELECT Id, Content__c FROM PDF_Content__c WHERE RecordType.DeveloperName = 'Content' LIMIT 1];
        pdfContent.Content__c = 'Testing Update';
        update pdfContent;
    }
}