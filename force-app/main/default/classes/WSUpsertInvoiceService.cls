@RestResource(urlMapping='/upsertinvoice')
global with sharing class WSUpsertInvoiceService {
    @HttpPost
    global static WSInvoiceModel.InvoiceInfoResponse upsertInvoice() {
        Datetime timeStamp = System.now();
        String requestBody = RestContext.request.requestBody.toString();
        try{
            List<WSInvoiceModel.InvoiceInfoRequest> requestModel = WSInvoiceModel.parse(requestBody);
            WSInvoiceModel.InvoiceInfoResponse responseModel = WSUpsertInvoiceController.processRequest(requestModel);
            if (responseModel.timeStamp==null){
                responseModel.timeStamp = timeStamp.formatGmt('yyyy-MM-dd')+'T'+timeStamp.formatGmt('HH:mm:ss');
            }
            return responseModel;
        } catch(Exception e){
            WSInvoiceModel.InvoiceInfoResponse responseModel = new WSInvoiceModel.InvoiceInfoResponse();
            responseModel.message = 'Upsert Invoice failed due to exception: '+Util.getErrorMessage(e);
            responseModel.statuscode = '1000';
            responseModel.result = new List<WSInvoiceModel.InvoiceInfoResponseResultItem>();
            if (responseModel.timeStamp==null){
                responseModel.timeStamp = timeStamp.formatGmt('yyyy-MM-dd')+'T'+timeStamp.formatGmt('HH:mm:ss');
            }
            System.debug('requestBody: '+String.valueOf(requestBody));
            System.debug('responseModel: '+String.valueOf(responseModel));
            ApplicationLogUtils.createFailIntegrationLogUtils('WSUpsertInvoiceService', Constant.APP_LOG_INBOUND_TYPE, requestBody, JSON.serialize(responseModel), responseModel.message);
            return responseModel;
        }
    }
}