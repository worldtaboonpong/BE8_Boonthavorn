trigger PDFContentTrigger on PDF_Content__c (after update) {

    TriggerActivation setting = TriggerActivation.getInstance('PDF_Content__c');
    if(!setting.isActiveTrigger() || !CacheTrigger.isRunningPDFContentTrigger) return;

    PDFContentController pdfContentController = new PDFContentController();
    pdfContentController.processRunningContent(Trigger.oldMap, Trigger.newMap);
}