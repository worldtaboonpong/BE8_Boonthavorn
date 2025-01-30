global with sharing class WSInvoiceModel {
    public static List<WSInvoiceModel.InvoiceInfoRequest> parse(String json){
        return (List<WSInvoiceModel.InvoiceInfoRequest>)System.JSON.deserialize(json, List<WSInvoiceModel.InvoiceInfoRequest>.class);
    }

    global class InvoiceInfoResponse {
        public String statuscode { get; set; }
        public String message { get; set; }
        public String timeStamp { get; set; }
        public List<InvoiceInfoResponseResultItem> result { get; set; }
    }

    global class InvoiceInfoResponseResultItem {
        public String invoiceId { get; set; }
        public Boolean isSuccess { get; set; }
        public String errorMessage { get; set; }
    }

    global class InvoiceInfoRequest {
        public String invoiceId;
        public String invoiceDate;
        public String customerId;
        public String taxId;
        public String address;
        public String phone;
        public String fax;
        public String contact;
        public Decimal invoiceAmount;
        public Decimal vat;
        public Decimal totalValue;
        public String term;
        public String contractID;
        public String contractID2;
        public String contractID3;
        public String note;
    }
}