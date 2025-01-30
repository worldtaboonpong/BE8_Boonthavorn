global with sharing class WSPaymentModel {

    public static List<WSPaymentModel.PaymentInfoRequest> parse(String json){
        return (List<WSPaymentModel.PaymentInfoRequest>)System.JSON.deserialize(json, List<WSPaymentModel.PaymentInfoRequest>.class);
    }

    global class PaymentInfoResponse {
        public String statuscode { get; set; }
        public String message { get; set; }
        public String timeStamp { get; set; }
        public List<PaymentInfoResponseResultItem> result { get; set; }
    }

    global class PaymentInfoResponseResultItem {
        public String invoiceId { get; set; }
        public Boolean isSuccess { get; set; }
        public String errorMessage { get; set; }
    }

    global class PaymentInfoRequest {
        public String invoiceId;
        public String paidDate;
        public Decimal totalPaidAmount;
    }
}