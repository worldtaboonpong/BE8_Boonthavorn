public with sharing class WSUpdatePaymentController {
    public static WSPaymentModel.PaymentInfoResponse processRequest(List<WSPaymentModel.PaymentInfoRequest> request) {
        Datetime timeStamp = System.now();
        WSPaymentModel.PaymentInfoResponse response = new WSPaymentModel.PaymentInfoResponse();
        response.timeStamp = timeStamp.formatGmt('yyyy-MM-dd')+'T'+timeStamp.formatGmt('HH:mm:ss');
        List<WSPaymentModel.PaymentInfoResponseResultItem> result = new List<WSPaymentModel.PaymentInfoResponseResultItem>();
        Boolean isAllSuccess = true;
        Boolean isSomeSuccess = false;

        Set<String> invoiceName = new Set<String>();
        for (WSPaymentModel.PaymentInfoRequest eachPaymentData : request) {
            invoiceName.add(eachPaymentData.invoiceId);
        }

        List<Invoice__c> listInvoice = [SELECT Id, Name, Paid_Date__c, Total_Paid_Amount__c FROM Invoice__c WHERE Name IN :invoiceName];
        Map<String, Invoice__c> mapInvoiceByName = new Map<String, Invoice__c>();
        for(Invoice__c invoice : listInvoice) {
            mapInvoiceByName.put(invoice.Name, invoice);
        }

        List<Invoice__c> listUpdateInvoice = new List<Invoice__c>();
        String missingField;
        for (WSPaymentModel.PaymentInfoRequest eachPaymentData : request) {
            missingField = validateField(eachPaymentData);
            if(missingField == null) {
                
                if(mapInvoiceByName.containsKey(eachPaymentData.invoiceId)) {
                    Invoice__c invoice = mapInvoiceByName.get(eachPaymentData.invoiceId);
                    invoice.Paid_Date__c = getDate(eachPaymentData.paidDate);
                    invoice.Total_Paid_Amount__c = eachPaymentData.totalPaidAmount;
                    invoice.Status__c = 'Already Paid';
                    listUpdateInvoice.add(invoice);
                } else {
                    //Not Found Invoice
                    isAllSuccess = false;
                    result.add(getResult(eachPaymentData, 'Not Found Invoice '+eachPaymentData.invoiceId));
                }
            } else {
                //Missing Required Field
                isAllSuccess = false;
                result.add(getResult(eachPaymentData, 'Missing required fields: '+missingField));
            }
        }

        if(!listUpdateInvoice.isEmpty()) {
            System.debug('listUpdateInvoice : ' + json.serialize(listUpdateInvoice));
            List<Database.SaveResult> updateInvoiceResult = Database.update(listUpdateInvoice, false);
            for (Integer i=0; i<updateInvoiceResult.size(); i++) {
                Database.SaveResult eachUpdateResult = updateInvoiceResult[i];
                Invoice__c invoice = listUpdateInvoice[i];
                WSPaymentModel.PaymentInfoResponseResultItem resultItem = new WSPaymentModel.PaymentInfoResponseResultItem();
                resultItem.invoiceId = mapInvoiceByName.get(invoice.Name).Name;
                if(eachUpdateResult.isSuccess()) {
                    isSomeSuccess = true;
                    resultItem.isSuccess = true;
                    resultItem.errorMessage = null;
                } else {
                    isAllSuccess = false;
                    resultItem.isSuccess = false;
                    resultItem.errorMessage = Util.getResponseResultItemErrorMessage(eachUpdateResult);
                }
                result.add(resultItem);
            }
        }

        System.debug('result: '+String.valueOf(result));
        response.result = result;
        if (isAllSuccess){
            response.statuscode = '0000';
            response.message = 'Success';
        } else {
            response.statuscode = '1000';
            if (isSomeSuccess){
                response.message = 'Update data partial complete.';
            } else {
                response.message = 'Fail';
            }
        }

        if (response.statuscode=='0000'){
            ApplicationLogUtils.createSuccessIntegrationLogUtils('WSUpdatePaymentService', Constant.APP_LOG_INBOUND_TYPE, JSON.serialize(request), JSON.serialize(response));
        } else {
            ApplicationLogUtils.createFailIntegrationLogUtils('WSUpdatePaymentService', Constant.APP_LOG_INBOUND_TYPE, JSON.serialize(request), JSON.serialize(response), response.message);
        }
        System.debug('response: '+String.valueOf(response));
        return response;
    }

    private static WSPaymentModel.PaymentInfoResponseResultItem getResult(WSPaymentModel.PaymentInfoRequest req, String errorMsg) {
        WSPaymentModel.PaymentInfoResponseResultItem resultItem = new WSPaymentModel.PaymentInfoResponseResultItem();
        resultItem.invoiceId = req.invoiceId;
        if(errorMsg != null) {
            resultItem.isSuccess = false;
            resultItem.errorMessage = errorMsg;
        } else {
            resultItem.isSuccess = true;
        }
        return resultItem;
    }

    private static String validateField(WSPaymentModel.PaymentInfoRequest req) {
        List<String> listMissingFields = new List<String>();
        if(req.invoiceId == null || req.invoiceId == '') listMissingFields.add('invoiceId');
        if(req.paidDate == null) listMissingFields.add('paidDate');
        if(req.totalPaidAmount == null) listMissingFields.add('totalPaidAmount');

        if(!listMissingFields.isEmpty()) {
            return String.join(listMissingFields, ', ');
        }
        
        return null;
    }

    private static Date getDate(String dateString) {
        List<String> splitDate = dateString.split('-');
        String formatDate = splitDate[2] + '-' + splitDate[1] + '-' + splitDate[0];
        return Date.valueOf(formatDate);
    }
}