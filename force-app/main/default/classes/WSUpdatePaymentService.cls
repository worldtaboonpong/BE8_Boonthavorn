@RestResource(urlMapping='/updatepayment')
global with sharing class WSUpdatePaymentService {
    @HttpPost
    global static WSPaymentModel.PaymentInfoResponse updatePayment() {
        Datetime timeStamp = System.now();
        String requestBody = RestContext.request.requestBody.toString();
        try{
            List<WSPaymentModel.PaymentInfoRequest> requestModel = WSPaymentModel.parse(requestBody);
            WSPaymentModel.PaymentInfoResponse responseModel = WSUpdatePaymentController.processRequest(requestModel);
            if (responseModel.timeStamp==null){
                responseModel.timeStamp = timeStamp.formatGmt('yyyy-MM-dd')+'T'+timeStamp.formatGmt('HH:mm:ss');
            }
            return responseModel;
        } catch(Exception e){
            WSPaymentModel.PaymentInfoResponse responseModel = new WSPaymentModel.PaymentInfoResponse();
            responseModel.message = 'Update Payment failed due to exception: '+Util.getErrorMessage(e);
            responseModel.statuscode = '1000';
            responseModel.result = new List<WSPaymentModel.PaymentInfoResponseResultItem>();
            if (responseModel.timeStamp==null){
                responseModel.timeStamp = timeStamp.formatGmt('yyyy-MM-dd')+'T'+timeStamp.formatGmt('HH:mm:ss');
            }
            System.debug('requestBody: '+String.valueOf(requestBody));
            System.debug('responseModel: '+String.valueOf(responseModel));
            ApplicationLogUtils.createFailIntegrationLogUtils('WSUpdatePaymentService', Constant.APP_LOG_INBOUND_TYPE, requestBody, JSON.serialize(responseModel), responseModel.message);
            return responseModel;
        }
    }
}