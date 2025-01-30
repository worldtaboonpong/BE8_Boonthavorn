public with sharing class WSUpsertInvoiceController {
    public static WSInvoiceModel.InvoiceInfoResponse processRequest(List<WSInvoiceModel.InvoiceInfoRequest> request) {
        Datetime timeStamp = System.now();
        WSInvoiceModel.InvoiceInfoResponse response = new WSInvoiceModel.InvoiceInfoResponse();
        response.timeStamp = timeStamp.formatGmt('yyyy-MM-dd')+'T'+timeStamp.formatGmt('HH:mm:ss');
        List<WSInvoiceModel.InvoiceInfoResponseResultItem> result = new List<WSInvoiceModel.InvoiceInfoResponseResultItem>();
        Boolean isAllSuccess = true;
        Boolean isSomeSuccess = false;

        Set<String> invoiceName = new Set<String>();
        Set<String> customerId = new Set<String>();
        Set<String> contactId = new Set<String>();
        Set<String> contractID = new Set<String>();
        for (WSInvoiceModel.InvoiceInfoRequest eachInvoiceData : request) {
            invoiceName.add(eachInvoiceData.invoiceId);
            customerId.add(eachInvoiceData.customerId);
            contactId.add(eachInvoiceData.contact);
            if(eachInvoiceData.contractID != '') contractID.add(eachInvoiceData.contractID);
            if(eachInvoiceData.contractID2 != '') contractID.add(eachInvoiceData.contractID2);
            if(eachInvoiceData.contractID3 != '') contractID.add(eachInvoiceData.contractID3);
        }

        List<Invoice__c> listInvoice = [SELECT Id, Name, Invoice_Date__c, Account_Name__c, Status__c FROM Invoice__c WHERE Name IN :invoiceName];
        List<Account> listCustomer = [SELECT Id, Customer_ID__c FROM Account WHERE Customer_ID__c IN :customerId];
        List<Contact> listContact = [SELECT Id, Contact_ID__c FROM Contact WHERE Contact_ID__c IN: contactId];
        List<Contract__c> listContract = [SELECT Id, Contract_Number__c, CreatedDate FROM Contract__c WHERE Contract_Number__c IN :contractID];
        Map<String, Invoice__c> mapInvoiceByName = new Map<String, Invoice__c>();
        Map<String, Account> mapAccountByCustomerId = new Map<String, Account>();
        Map<String, Contact> mapContactByContactId = new Map<String, Contact>();
        Map<String, Contract__c> mapContractByContractNo = new Map<String, Contract__c>();
    
        for(Invoice__c invoice : listInvoice) {
            mapInvoiceByName.put(invoice.Name, invoice);
        }
        for(Account customer : listCustomer) {
            mapAccountByCustomerId.put(customer.Customer_ID__c, customer);
        }
        for(Contact con : listContact) {
            mapContactByContactId.put(con.Contact_ID__c, con);
        }
        for(Contract__c contract : listContract) {
            mapContractByContractNo.put(contract.Contract_Number__c, contract);
        }

        List<Invoice__c> listUpsertInvoice = new List<Invoice__c>();
        String missingField;
        for (WSInvoiceModel.InvoiceInfoRequest eachInvoiceData : request) {
            missingField = validateField(eachInvoiceData);
            if(missingField == null) {
                // if(mapInvoiceByName.containsKey(eachInvoiceData.invoiceId)) {
                    Invoice__c invoice = mapInvoiceByName.containsKey(eachInvoiceData.invoiceId) ? mapInvoiceByName.get(eachInvoiceData.invoiceId) : new Invoice__c();
                    if(invoice.Id == null) invoice.name = eachInvoiceData.invoiceId;
                    if(invoice.Status__c == null) invoice.Status__c = 'Pending';
                    invoice.Invoice_Date__c = getDate(eachInvoiceData.invoiceDate);
                    invoice.Account_Name__c = getCustomerId(eachInvoiceData.customerId, mapAccountByCustomerId);
                    invoice.Tax_ID__c = eachInvoiceData.taxId;
                    invoice.Address__c = eachInvoiceData.address;
                    invoice.Phone__c = eachInvoiceData.phone;
                    invoice.Fax__c = eachInvoiceData.fax;
                    invoice.Contact__c = getContactId(eachInvoiceData.contact, mapContactByContactId);
                    invoice.Amount__c = eachInvoiceData.invoiceAmount;
                    invoice.Vat__c = eachInvoiceData.vat;
                    invoice.Total_Amount__c = eachInvoiceData.totalValue;
                    invoice.Term__c = eachInvoiceData.term;
                    invoice.Contract_Number__c = getContract(eachInvoiceData, mapContractByContractNo);
                    invoice.Note__c = eachInvoiceData.note;
                    listUpsertInvoice.add(invoice);
                // } else {
                //     //Not Found Invoice
                //     isAllSuccess = false;
                //     result.add(getResult(eachInvoiceData, 'Not Found Invoice '+eachInvoiceData.invoiceId));
                // }
            } else {
                //Missing Required Field
                isAllSuccess = false;
                result.add(getResult(eachInvoiceData, 'Missing required fields: '+missingField));
            }
        }

        if(!listUpsertInvoice.isEmpty()) {
            System.debug('listUpsertInvoice : ' + json.serialize(listUpsertInvoice));
            List<Database.UpsertResult> upsertInvoiceResult = Database.upsert(listUpsertInvoice, false);
            for (Integer i=0; i<upsertInvoiceResult.size(); i++) {
                Database.UpsertResult eachUpsertResult = upsertInvoiceResult[i];
                Invoice__c invoice = listUpsertInvoice[i];
                System.debug('invoice upsert : ' + invoice);
                WSInvoiceModel.InvoiceInfoResponseResultItem resultItem = new WSInvoiceModel.InvoiceInfoResponseResultItem();
                resultItem.invoiceId = invoice.Name;
                if(eachUpsertResult.isSuccess()) {
                    isSomeSuccess = true;
                    resultItem.isSuccess = true;
                    resultItem.errorMessage = null;
                } else {
                    isAllSuccess = false;
                    resultItem.isSuccess = false;
                    resultItem.errorMessage = Util.getResponseResultItemErrorMessage(eachUpsertResult);
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
                response.message = 'Create/Update data partial complete.';
            } else {
                response.message = 'Fail';
            }
        }

        if (response.statuscode=='0000'){
            ApplicationLogUtils.createSuccessIntegrationLogUtils('WSUpsertInvoiceService', Constant.APP_LOG_INBOUND_TYPE, JSON.serialize(request), JSON.serialize(response));
        } else {
            ApplicationLogUtils.createFailIntegrationLogUtils('WSUpsertInvoiceService', Constant.APP_LOG_INBOUND_TYPE, JSON.serialize(request), JSON.serialize(response), response.message);
        }
        System.debug('response: '+String.valueOf(response));
        return response;
    }

    private static WSInvoiceModel.InvoiceInfoResponseResultItem getResult(WSInvoiceModel.InvoiceInfoRequest req, String errorMsg) {
        WSInvoiceModel.InvoiceInfoResponseResultItem resultItem = new WSInvoiceModel.InvoiceInfoResponseResultItem();
        resultItem.invoiceId = req.invoiceId;
        if(errorMsg != null) {
            resultItem.isSuccess = false;
            resultItem.errorMessage = errorMsg;
        } else {
            resultItem.isSuccess = true;
        }
        return resultItem;
    }

    private static String validateField(WSInvoiceModel.InvoiceInfoRequest req) {
        List<String> listMissingFields = new List<String>();
        if(req.invoiceId == null || req.invoiceId == '') listMissingFields.add('invoiceId');
        if(req.invoiceDate == null) listMissingFields.add('invoiceDate');
        if(req.customerId == null || req.customerId == '') listMissingFields.add('customerId');
        if(req.invoiceAmount == null) listMissingFields.add('invoiceAmount');
        if(req.totalValue == null) listMissingFields.add('totalValue');

        if(!listMissingFields.isEmpty()) {
            return String.join(listMissingFields, ', ');
        }
        
        return null;
    }

    private static Date getDate(String dateString) {
        List<String> splitDate = dateString.split('-');
        String formatDateStr = splitDate[2] + '-' + splitDate[1] + '-' + splitDate[0];
        return Date.valueOf(formatDateStr);
    }

    private static String getCustomerId(String customerId, Map<String, Account> mapAccountByCustomerId) {
        String accId;
        if(mapAccountByCustomerId.containsKey(customerId)){
            accId = mapAccountByCustomerId.get(customerId).Id;
        }
        return accId;
    }

    private static String getContactId(String contactId, Map<String, Contact> mapContactByContactId) {
        String conId;
        if(mapContactByContactId.containsKey(contactId)){
            conId = mapContactByContactId.get(contactId).Id;
        }
        return conId;
    }

    private static String getContract(WSInvoiceModel.InvoiceInfoRequest req, Map<String, Contract__c> mapContractByContractNo) {
        //get latest contract
        Contract__c latestContract;
        if(req.contractID != null && mapContractByContractNo.containsKey(req.contractID)) {
            latestContract = mapContractByContractNo.get(req.contractID);
        }
        if(req.contractID2 != null && mapContractByContractNo.containsKey(req.contractID2)) {
            Contract__c contract2 = mapContractByContractNo.get(req.contractID2);
            if(latestContract == null || (latestContract != null && contract2.CreatedDate > latestContract.CreatedDate)) latestContract = contract2;
        }
        if(req.contractID3 != null && mapContractByContractNo.containsKey(req.contractID3)) {
            Contract__c contract3 = mapContractByContractNo.get(req.contractID3);
            if(latestContract == null || (latestContract != null && contract3.CreatedDate > latestContract.CreatedDate)) latestContract = contract3;
        }
        return latestContract != null ? latestContract.Id : null;
    }
}