public with sharing class PDFContentController {
    public PDFContentController() {

    }

    public void processRunningContent(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> conIdSet = new Set<Id>();
        for(Id key : newMap.keySet()) {

            PDF_Content__c newPDFContent = (PDF_Content__c)newMap.get(key);
            PDF_Content__c oldPDFContent = (PDF_Content__c)oldMap?.get(key);
            
            if(isUpdateSequenceChange(oldPDFContent, newPDFContent)) {
                if(newPDFContent.Opportunity__c != null) oppIdSet.add(newPDFContent.Opportunity__c);
                if(newPDFContent.Contract__c != null) conIdSet.add(newPDFContent.Contract__c);
            }
        }
        System.debug(oppIdSet);
        updateRunningSequence(newMap, oppIdSet, conIdSet);
    }

    private void updateRunningSequence(Map<Id, SObject> newMap, Set<Id> opportunityIdSet, Set<Id> contractIdSet) {
        if(opportunityIdSet == null) { return; }

        List<PDF_Content__c> pdfContentList = [SELECT Id, Opportunity__c, Sequence__c, Display_Content__c, Content__c, 
                                                         Is_Show_Sequence__c, Is_Active__c, Continue_From_Above__c, 
                                                         Master_Content__r.Sequence__c, Contract__c
                                                  FROM PDF_Content__c
                                                  WHERE Opportunity__c IN: opportunityIdSet OR Contract__c IN: contractIdSet
                                                  ORDER BY Master_Content__r.Sequence__c];

        Map<Id, List<PDF_Content__c>> pdfContentMap = new Map<Id, List<PDF_Content__c>>();
        
        for(PDF_Content__c pdfContent : pdfContentList) {
            if(pdfContent.Opportunity__c == null && pdfContent.Contract__c == null) continue;
            String key;
            if(pdfContent.Opportunity__c != null) key = pdfContent.Opportunity__c;
            else key = pdfContent.Contract__c;
            if(!pdfContentMap.containsKey(key)) {
                pdfContentMap.put(key, new List<PDF_Content__c>{pdfContent});
            } else {
                pdfContentMap.get(key).add(pdfContent);
            }
        }
        System.debug(pdfContentMap);

        List<PDF_Content__c> updatePDFContentList = new List<PDF_Content__c>();
        for(Id key : pdfContentMap.keySet()) {
            Integer runningSequence = 0;
            for(PDF_Content__c eachPDFContent : pdfContentMap.get(key)) {
                if(newMap.containsKey(eachPDFContent.Id)) {
                    eachPDFContent.Content__c = ((PDF_Content__c)newMap.get(eachPDFContent.Id)).Content__c;
                    System.debug(((PDF_Content__c)newMap.get(eachPDFContent.Id)).Is_Active__c);
                    eachPDFContent.Is_Active__c = ((PDF_Content__c)newMap.get(eachPDFContent.Id)).Is_Active__c;
                    eachPDFContent.Continue_From_Above__c = ((PDF_Content__c)newMap.get(eachPDFContent.Id)).Continue_From_Above__c;
                }

                if(eachPDFContent.Is_Active__c && eachPDFContent.Is_Show_Sequence__c && !eachPDFContent.Continue_From_Above__c || runningSequence == 1) {
                    runningSequence = runningSequence + 1;
                }
                PDF_Content__c updatePDFContent = new PDF_Content__c();
                updatePDFContent.Id = eachPDFContent.Id;
                updatePDFContent.Sequence__c = !eachPDFContent.Is_Active__c? null : runningSequence;
                updatePDFContent.Display_Content__c = !eachPDFContent.Is_Active__c? eachPDFContent.Content__c : eachPDFContent.Content__c.replace(PDFContentUtility.SEQTAG, String.valueOf(runningSequence));
                updatePDFContentList.add(updatePDFContent);
            }
        }

        System.debug('updatePDFContentList : ' + updatePDFContentList);
        CacheTrigger.isRunningPDFContentTrigger = false;
        update updatePDFContentList;
        CacheTrigger.isRunningPDFContentTrigger = true;
    }

    private Boolean isUpdateSequenceChange(PDF_Content__c oldPDFContent, PDF_Content__c newPDFContent) {
        return oldPDFContent.Is_Active__c != newPDFContent.Is_Active__c
                || oldPDFContent.Content__c != newPDFContent.Content__c;
    }
}