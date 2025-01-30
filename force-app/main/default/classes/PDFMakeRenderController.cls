public with sharing class PDFMakeRenderController {
    public List<PDF_Content__c> contentList { get; set; }
    public Boolean isDraftRenderred { get; set; }
    public Boolean isContractType {get;set;}
    public String contractNumber{get;set;}
    public String serviceNumber{get;set;}
    public String jsonContentList { get; set; }
    public String base64WaterMask { get; set; }
    public List<String> contractOrigins{get;set;}
    public String buildingLogo{get;set;}
    
    public PDFMakeRenderController() {
        this.contractOrigins = new List<String>{'ต้นฉบับ','คู่ฉบับ'};
        String resourceName = 'DraftWaterMask'; 
        base64WaterMask = getStaticResourceAsBase64(resourceName);
    	Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=Quotation PDF.pdf');
        System.debug(ApexPages.currentPage().getParameters());
        Id oppId =ApexPages.currentPage().getParameters().get('oppId');
        String recordType = String.valueOf(oppId.getSobjectType());
        // System.debug(recordType); contract__c?
        String renderredDraft = ApexPages.currentPage().getParameters().get('renderredDraft');
        System.debug('renderredDraft:' + renderredDraft);
        // * User request to remove draft watermark
        // this.isDraftRenderred = (renderredDraft == 'T')?true:false;
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        System.debug(profileName);
        if(profileName == 'Manager'){
            this.isDraftRenderred = false;
        }else{
            SOQLBuilder queryString = new SOQLBuilder(recordType);
            queryString.addCondition('WHERE Id =:oppId');
            if(recordType == 'Opportunity'){
                Opportunity opp = Database.query(queryString.getQueryString());
                if(opp.Approve_Status__c == 'Approved'){
                    this.isDraftRenderred = false;
                }else{
                    this.isDraftRenderred = true;
                }
            } else if(recordType == 'Contract__c'){
                Contract__c contract = Database.query(queryString.getQueryString());
                if(contract.Approve_Status__c =='Approved'){
                    this.isDraftRenderred = false;
                }else{
                    this.isDraftRenderred = true;
                }
            }
            else{
                this.isDraftRenderred = true;
            }
            
            
        }
        Id recordTypeId = Schema.SObjectType.PDF_Content__c.getRecordTypeInfosByName().get('Content').getRecordTypeId();
        String currentRecordType = String.valueOf(oppId.getSobjectType());
        List<PDF_Content__c> pdfContentList;
        if(oppId == null){
            pdfContentList = new List<PDF_Content__c>();
        }else if(currentRecordType == 'Opportunity'){
            pdfContentList = [SELECT Display_Content__c, Content__c,Sequence__c, Is_Show_Sequence__c FROM PDF_Content__c WHERE Opportunity__c = :oppId AND Is_Active__c =: true AND RecordType.Id =: recordTypeId  ORDER BY Master_Content__r.Sequence__c ASC];
        }else if(currentRecordType == 'Contract__c'){
            pdfContentList = [SELECT Display_Content__c, Content__c,Sequence__c, Is_Show_Sequence__c,Contract__c,Contract__r.Contract_Number__c,Contract__r.Contract_Service_No__c,Master_Content__r.Content_Description__c, Contract__r.Building__r.Building_Logo__c FROM PDF_Content__c WHERE Contract__c = :oppId AND Is_Active__c =: true AND RecordType.Id =: recordTypeId  ORDER BY Master_Content__r.Sequence__c ASC];
            this.buildingLogo = getBase64Content(pdfContentList[0].Contract__r.Building__r.Building_Logo__c);
        }
        for (PDF_Content__c pdfContent : pdfContentList) {
            pdfContent.Content__c = pdfContent.Content__c?.unescapeHtml4();
            pdfContent.Display_Content__c = pdfContent.Display_Content__c?.unescapeHtml4();
            pdfContent.Display_Content__c = replaceSrcWithBase64(pdfContent.Display_Content__c);
        }
        this.contentList = pdfContentList;
        this.jsonContentList = JSON.serialize(this.contentList);
        System.debug('Content List :--> '+this.jsonContentList);
        System.debug(this.buildingLogo);
    }
    public String getBase64Content(String tagUrl){
        Matcher imgMatcher = Pattern.compile( '<img(.+?)>' ).matcher(tagUrl);
        String logoString;
        // iterate each image tag found
        while ( imgMatcher.find() ) {
            // get the image tag html
            String imageTag = imgMatcher.group();
            System.debug( 'imageTag=' + imageTag );

            // get the value of the src attribute
            // the leading space is significant to avoid other attributes like data-cke-saved-src
            String imageURL = imageTag.substringBetween( ' src="', '"' );
            System.debug( 'imageURL=' + imageURL );

            // if url contained parameters they might be html escaped, unescape them
            // or, more conservatively, replace '&amp;' with '&'
            String decodedURL = imageURL.unescapeHtml4();
            System.debug( 'decodedURL=' + decodedURL );

            // note, as of API 34.0 or later, getContent() is considered an http callout
            // so take that into consideration for your unit tests and governor limits
            // https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/apex_System_PageReference_getContent.htm
            PageReference page = new PageReference( decodedURL );
            Blob b = page.getContent();
            logoString = EncodingUtil.base64Encode(b);
            System.debug( 'blob=' + b );
            System.debug( 'Enjoy your Blob, save it as a Document, ContentVersion, whatever!' );
            System.debug(''); // I like blank lines in my logs, easier to scan/read =)
            System.debug('logo --> '+ logoString);
        }
        return logoString;
    }
    public String getStaticResourceAsBase64(String resourceName) {
        // Fetch the Blob data of the static resource
        Blob imageBlob = [SELECT Body FROM StaticResource WHERE Name = :resourceName].Body;
        
        // Convert Blob data to base64 string
        String base64String = EncodingUtil.base64Encode(imageBlob);
        
        return base64String;
    }
    public static String replaceSrcWithBase64(String textContent) {
        // Define a regex pattern to match the src attribute within <img> tags
        Pattern srcPattern = Pattern.compile('<img\\s+[^>]*src=["\']([^"\']*)["\'][^>]*>');
        Matcher srcMatcher = srcPattern.matcher(textContent);
    
        // Initialize an empty string to build the modified content
        String modifiedContent = '';
        Integer lastAppendPosition = 0;
    
        // Iterate over each match found for src
        while (srcMatcher.find()) {
            // Append content before the <img> tag
            modifiedContent += textContent.substring(lastAppendPosition, srcMatcher.start());
    
            // Extract the URL within the src attribute
            String imageURL = srcMatcher.group(1);
            System.debug('Found image URL: ' + imageURL);
    
            try {
                // Unescape any HTML entities if necessary
                String decodedURL = imageURL.unescapeHtml4();
                System.debug('Decoded image URL: ' + decodedURL);
                
                // Retrieve the image content and encode it as Base64
                PageReference page = new PageReference(decodedURL);
                Blob imageBlob = page.getContent(); // Ensure this URL is added to Remote Site Settings
                String base64Image = EncodingUtil.base64Encode(imageBlob);
    
                // Construct the Base64 src attribute
                String base64Src = 'src="data:image/png;base64,' + base64Image + '"';
                System.debug('Generated Base64 src: ' + base64Src);
                
                // Replace the original src with the Base64 version within the tag
                String modifiedImgTag = srcMatcher.group(0).replace('src="' + imageURL + '"', base64Src);
                modifiedContent += modifiedImgTag;
            } catch (Exception e) {
                System.debug('Error retrieving image content: ' + e.getMessage());
                // If there's an error, keep the original tag
                modifiedContent += srcMatcher.group(0);
            }
            
            // Update the last append position to the end of the matched tag
            lastAppendPosition = srcMatcher.end();
        }
    
        // Append any remaining content after the last match
        modifiedContent += textContent.substring(lastAppendPosition);
    
        return modifiedContent;
    }
}