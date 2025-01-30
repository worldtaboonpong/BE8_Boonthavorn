global with sharing class PDFContentEditorController {
    public PDF_Content__c dataSet{get; set;}
    public Id recordId {get; set;}
    // public Id thisContentd {get; set;}
    public PDFContentEditorController(ApexPages.StandardController controller) {
        this.dataSet = [SELECT Id, Content__c FROM PDF_Content__c WHERE Id =:  ApexPages.currentPage().getParameters().get('id')];
        this.recordId = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(this.dataSet.Content__c)){
            this.dataSet.Content__c = this.dataSet.Content__c.replaceAll('<p><img class="imageCenter"', '<p style="text-align:center"><img class="imageCenter"');
            this.dataSet.Content__c = this.dataSet.Content__c.replaceAll('<p><img class="imageQuotation"', '<p style="text-align:center"><img class="imageQuotation"');
            this.dataSet.Content__c = this.dataSet.Content__c.replaceAll('<table class="tableFormEditor"', '<table border="1" cellpadding="1" cellspacing="1"');
            this.dataSet.Content__c = this.dataSet.Content__c.replaceAll('<p><div', '<div');
            this.dataSet.Content__c = this.dataSet.Content__c.replaceAll('</script></p>', '</script>');
        }
        System.debug('Content__c: ' + this.dataSet.Content__c);
        // this.thisContentd =  controller.getId();
    }


    @RemoteAction
    global static void saveDataCKEditorNew(String htmlData, String recID) {
        System.debug('htmlData'+htmlData);
        String htmlDataUnScape = htmlData.unescapeHtml4();
        PDF_Content__c dataToSave = new PDF_Content__c(Id = recID, Content__c= htmlDataUnScape);
        System.debug('dataToSave' + dataToSave);
        update dataToSave;

    }
}