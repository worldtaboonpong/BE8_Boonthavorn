public without sharing class PDFContentSelector {
    
    public static List<PDF_Content__c> getPDFContentMasterByObject(String objectAPIName, Id recordTypeId, String language, String rentalType, Set<Decimal> existedSequence) {
        List<PDF_Content__c> pdfContentList = new List<PDF_Content__c>();
        List<PDF_Content__c> ret = new List<PDF_Content__c>();
        pdfContentList = [SELECT Id, Sequence__c, Is_Show_Sequence__c, Content__c, Expression_Criteria__c, Language__c, Continue_From_Above__c, Rental_Type__c
                          FROM PDF_Content__c
                          WHERE Is_Active__c =: true AND Object__c =: objectAPIName AND Language__c =: language AND RecordTypeId =: recordTypeId AND Rental_Type__C =: rentalType
                          ORDER BY Sequence__c ASC];
        System.debug(pdfContentList);
        //return only deleted sequence
        for (PDF_Content__c content: pdfContentList){
            if(!existedSequence.contains(content.Sequence__c)){
                System.debug(content.Sequence__c);
                ret.add(content);
            }
        }

        if(ret.isEmpty()){
            return pdfContentList;
        }

        System.debug(ret);
        return ret;
    }

    public static List<PDF_Content__c> getPDFContentIdByCondition(String condition) {
        List<PDF_Content__c> pdfContentList = null;
        if(!String.isBlank(condition)) {
            try {
                String query = 'SELECT Id FROM PDF_Content__c WHERE ' + condition;
                pdfContentList = Database.query(query);
            } catch(QueryException e) {
                System.debug('Error : ' + e.getMessage());
            }
        }
        return pdfContentList;
    }

    public static List<SObject> getRecordValue(Set<String> fieldAPISet, String objectAPIName, String condition) {
        String fieldAPIString = null;
        List<SObject> records = null;
        if(!fieldAPISet.isEmpty()) {
            List<String> fieldAPIList = new List<String>(fieldAPISet);
            fieldAPIString = String.join(fieldAPIList, ',');
        }
        if(!String.isBlank(fieldAPIString) && !String.isBlank(objectAPIName) && !String.isBlank(condition)) {
            try {
                String query = 'SELECT ' + fieldAPIString + ' FROM ' + objectAPIName + ' WHERE ' + condition;
                System.debug('Query : ' + query);
                records = Database.query(query);
            } catch(QueryException e) {
                String errorMessage = 'Error : ' + e.getMessage();
                throw new CustomException(errorMessage);
            }
        }
        return records;
    }

    public static List<ContentVersion> getContentVersionByObject(String objectAPIName, Set<String> fileNameSet) {
        List<ContentDocumentLink> records = null;
        List<ContentVersion> contentVersionRecords = null;
        if(!String.isBlank(objectAPIName)) {
            try {
                String query = 'SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension FROM ContentDocumentLink where LinkedEntityId in (SELECT Id FROM ' + objectAPIName + ')';
                System.debug('Query : ' + query);
                records = Database.query(query);
                if(records != null && records.size() > 0) {
                    Set<Id> contentDocumentIdSet = new Set<Id>();
                    for(ContentDocumentLink contentDoc : records) {
                        String fileName = contentDoc.ContentDocument.Title + '.' + contentDoc.ContentDocument.FileExtension;
                        // System.debug(fileNameSet);
                        // System.debug(fileName);
                        if(fileNameSet.contains(fileName)) {
                            contentDocumentIdSet.add(contentDoc.ContentDocumentId);
                        }
                    }
                    contentVersionRecords = [SELECT Id, ContentBodyId, PathOnClient, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIdSet];
                }
            } catch(QueryException e) {
                String errorMessage = 'Error : ' + e.getMessage();
                throw new CustomException(errorMessage);
            }
        }
        System.debug(contentVersionRecords);
        return contentVersionRecords;
    }
}