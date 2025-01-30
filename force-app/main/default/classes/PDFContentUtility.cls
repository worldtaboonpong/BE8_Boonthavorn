public with sharing class PDFContentUtility {

    // {LOOPRELATEDOBJ:tms_OpportunityLineItem__c;LOOKUPFIELD:tms_Opportunity__c;CONDITION:'RecordType=\'test recordtype\' AND tms_BuidingName__c = \'{FIELD:tms_Building__r.Name}\'';FIELDS:tms_RentalObject__r.tms_FloorToFloor__r.Name,tms_RentalObject__r.Name}
    //     [SOURCE:{FIELD:tms_Building__r.Name}_{FIELDS:tms_RentalObject__r.tms_FloorToFloor__r.Name}]
    //     [SOURCE:{FIELD:tms_Building__r.Name}_{FIELDS:tms_RentalObject__r.tms_FloorToFloor__r.Name}_{XFIELD:tms_RentalObject__r.Name}]
    // {ENDLOOPRELATEDOBJ}

    // Multiline -> ({LOOPRELATEDOBJ:)[\w\W]+({ENDLOOPRELATEDOBJ})
    // Oneline -> ({LOOPRELATEDOBJ:).*(})
    // Oneline -> ({SOURCE:).*(})

    // RegEx
    public static final String REGEX_VFFORMAT = '(\\{VF:)\\w+(\\})';
    public static final String REGEX_LOOPRELATEDOBJFORMAT = '(\\{LOOPRELATEDOBJ:)[\\w\\W]+(\\{[\\w\\W]+ENDLOOPRELATEDOBJ\\})';
    public static final String REGEX_LOOPFORMAT = '(\\{LOOPRELATEDOBJ:).*?(\\})';
    public static final String REGEX_SOURCEFORMAT = '(\\[SOURCE:).*?(\\])';

    public static final String REGEX_VFWITHFIELDSETFORMAT = '(\\{VF:)\\w+(;FIELDSET:)\\w+(\\})';
    public static final String REGEX_FIELDFORMAT = '(\\{FIELD:)(<.+?>)*?(\\w+)(<.+?>)*(\\.\\w+)*?(<.+?>)*?(\\})';
    
    public static final String REGEX_INNERFIELDFORMAT = '(\\{FIELDS:)(<.+?>)*?(\\w+)(<.+?>)*(\\.\\w+)*?(<.+?>)*?(\\})';
    public static final String RECORDTYPE_MASTER = 'Master_Template';
    public static final String RECORDTYPE_CONTENT = 'Content';
    public static final String OBJECTNAME = 'PDF_Content__c';
    
    public static final String BODYTAG_START = '<body>';
    public static final String BODYTAG_END = '</body>';
    public static final String HEADTAG_START = '<head>';
    public static final String HEADTAG_END = '</head>';

    
    // Attribute Key
    public static final String LOOPRELATEDOBJKEY = 'LOOPRELATEDOBJ';
    public static final String LOOKUPFIELDKEY = 'LOOKUPFIELD';
    public static final String FIELDSKEY = 'FIELDS';
    public static final String CONDITIONKEY = 'CONDITION';
    
    // Custom TAG
    public static final String SEQTAG = '{No}';
    public static final String VFTAG = 'VF:';
    public static final String LOOPRELATEDOBJTAG = 'LOOPRELATEDOBJ:';
    public static final String LOOKUPFIELDTAG = 'LOOKUPFIELD:';
    public static final String FIELDTAG = 'FIELD:';
    public static final String XFIELDTAG = 'FIELDS:';
    public static final String FIELDSTAG = 'FIELDS:';
    public static final String CONDITIONTAG = 'CONDITION:';
    public static final String SOURCETAG = 'SOURCE:';
    public static final String TAG_START = '{';
    public static final String TAG_END = '}';
    public static final String BRACKET_END = ']';
    public static final String ANGLE_BRACKET_END = '>';
    public static final String VFWITHFIELDSETTAG = ';FIELDSET:';
    public static final String ENDLOOPRELATEDOBJTAG = '{ENDLOOPRELATEDOBJ}';

    // Splitter
    public static final String ATTRIBUTESPLITTER = ';';
    public static final String VALUESPLITTER = ':';
    public static final String FIELDSPLITTER = ',';
    public static final String RELATIONSPLITTER = '\\.';

    // Other
    public static final String OBJ_ATTACHMENT = 'ContentVersion';
    public static final Set<String> QUERYFIELDSET_ATTACHMENT = new Set<String>{'Id', 'ContentBodyId', 'PathOnClient'};
    
    //********** */
    // public static final Decimal defaultImageWidth = tms_QuotationImageSize__c.getInstance() != null && tms_QuotationImageSize__c.getInstance().tms_WidthMaster__c != null ?
    //                                                 tms_QuotationImageSize__c.getInstance().tms_WidthMaster__c : 400;

    public static final Decimal defaultImageWidth = 400;
    public static final Decimal defaultImageHeight = 300;

    public static final String IMAGEURL = '</p><p><img class="pagebreak imageQuotation" width="' + defaultImageWidth + '"height="' + defaultImageHeight + '" src="{0}/sfc/servlet.shepherd/version/renditionDownload?rendition=Jpg&versionId={1}&operationContext=CHATTER&contentId={2}&page=1" /> </p><p>';
    // public static final String IMAGEURL = '</p><p><img class="pagebreak imageQuotation" src="{0}/sfc/servlet.shepherd/version/renditionDownload?rendition=Jpg&versionId={1}&operationContext=CHATTER&contentId={2}&page=1" /> </p><p>';

    public static final String SEQUENCE_FORMAT = '{0}. ';


    public void generatePDFContent(Id recordId, String language, String targetLookupField, String rentalType) {
        Id recordTypeMasterId = RecordTypeUtility.getRecordTypeId(OBJECTNAME, RECORDTYPE_MASTER);
        String objectName = SObjectUtility.getSObjectTypeByID(recordId);
        Set<String> queryFieldSet = new Set<String>();

        System.debug('recordTypeMasterId: ' + recordTypeMasterId);

        DescribeSObjectResult describeResult = Id.valueof(recordId).getSObjectType().getDescribe();
        queryFieldSet.addAll(describeResult.fields.getMap().keySet());
        String queryObj = 'Contract__c';
        if(objectName == 'Opportunity'){
            queryObj = 'Opportunity__c';
        }else{
            queryObj = 'Contract__c';
        }
        System.debug('Obj = ' + queryObj);
        System.debug('recordId = ' + recordId);
        String query = 'SELECT Id, Displayed_Sequence__c FROM PDF_Content__c WHERE ' + queryObj + ' = \'' + recordId + '\'';
        List<PDF_Content__c> existedPDFContent = Database.query(query);
        Set<Decimal> existedSequence = new Set<Decimal>();
        for(PDF_Content__c content: existedPDFContent){
            // System.debug('sequence that existed : '+content.Sequence__c);
            existedSequence.add(content.Displayed_Sequence__c);
        }
        System.debug('existedSequence: ' + existedSequence);

        List<PDF_Content__c> pdfMasterList = PDFContentSelector.getPDFContentMasterByObject(objectName, recordTypeMasterId, language, rentalType, existedSequence);
        // System.debug(pdfMasterList);
        List<String> contentList = new List<String>();
        for(PDF_Content__c pdfContent : pdfMasterList) {
            contentList.add(pdfContent.Content__c);
        }
        System.debug('contentList'+contentList);

        Set<String> vfPageSet = this.getVFPageSet(contentList);
        System.debug(recordId);
        System.debug(objectName);
        System.debug(vfPageSet);
        Map<String, String> vfContentMap = this.getHTMLContent(recordId, objectName, vfPageSet);
        String condition = 'Id = \'' + recordId + '\'';
        Set<String> contentFieldAPISet = this.getSetByRegEx(contentList, REGEX_FIELDFORMAT);
        System.debug('contentFieldAPISet: ' + contentFieldAPISet);
        
        for(PDF_Content__c pdfContent : pdfMasterList) {
            if(String.isBlank(pdfContent.Content__c)) { continue; }
            for(String eachField : contentFieldAPISet) {
                pdfContent.Content__c = pdfContent.Content__c.replace(eachField, eachField.stripHtmlTags().toLowerCase());
            }
        }
        
        Set<String> stripContentFieldAPISet = new Set<String>();
        for(String eachField : contentFieldAPISet) {
            stripContentFieldAPISet.add(eachField.stripHtmlTags().toLowerCase());
        }
        // System.debug('stripContentFieldAPISet : ' + stripContentFieldAPISet);

        for(String contentFieldAPI : stripContentFieldAPISet) {
            queryFieldSet.add((contentFieldAPI.stripHtmlTags().toLowerCase().substringBetween(FIELDTAG.toLowerCase(), TAG_END.toLowerCase())));
        }
        queryFieldSet.remove(null);


        List<SObject> records = PDFContentSelector.getRecordValue(queryFieldSet, objectName, condition);
        // System.debug('records : ' + records);
        this.processPDFContent(recordId, records[0], pdfMasterList, vfContentMap, stripContentFieldAPISet, targetLookupField);
    }

    private Set<String> getSetByRegEx(List<String> contentList, String regexFormat) {
        Pattern regexPattern = Pattern.compile(regexFormat);
        Set<String> matchedSet = new Set<String>();
        Matcher regexMatcher;
        for(String content : contentList) {
            if(String.isBlank(content)) { continue; }
            regexMatcher = regexPattern.matcher(content);
            while (regexMatcher.find()) {
                matchedSet.add(regexMatcher.group(0));
            }
        }
        return matchedSet;
    }

    private Map<String, String> getHTMLContent(Id recordId, String objectName, Set<String> vfPageSet) {
        Map<String, String> vfContentMap = new Map<String, String>();
        PageReference pageRef = null;
        for(String vfPage : vfPageSet) {
            String url = '';
            String vfName = vfPage.substringBetween(VFTAG, TAG_END);
            Boolean isIncludeFieldSet = vfPage.contains(VFWITHFIELDSETTAG);
            if(isIncludeFieldSet) {
                String fieldSetName = vfName.substringAfter(VFWITHFIELDSETTAG);
                vfName = vfName.substringBefore(VFWITHFIELDSETTAG);
                url = '/apex/' + vfName + '?ObjectAPIName=' + objectName + '&FieldSetDevName=' + fieldSetName +'&id=' + recordId;
            } else {
                url = '/apex/' + vfName + '?id=' + recordId;
            }

            System.debug('VF url : ' + url);
            try {
                pageRef = new PageReference(url);
                String htmlContent = pageRef.getContent().toString();
                vfContentMap.put(vfPage, getBodyValue(htmlContent));
                // System.debug(vfPage);
                // System.debug(getBodyValue(htmlContent));
            } catch (Exception e) {
                System.debug('Error : ' + e.getMessage());
                continue;
            }
        }
        return vfContentMap;
    }

    private String getBodyValue(String htmlResponseString) {
        // System.debug(htmlResponseString.substringAfter(HEADTAG_END));
        return htmlResponseString.substringAfter(HEADTAG_END);
    }

    private Set<String> getVFPageSet(List<String> contentList) {
        Pattern vfRegexPattern = Pattern.compile(REGEX_VFFORMAT);
        Pattern vfWithFieldSetRegexPattern = Pattern.compile(REGEX_VFWITHFIELDSETFORMAT);
        Set<String> vfPageSet = new Set<String>();
        for(String content : contentList) {
            if(String.isBlank(content)) { continue; }
            Matcher vfRegexMatcher = vfRegexPattern.matcher(content);
            Matcher vfWithFieldregexMatcher = vfWithFieldSetRegexPattern.matcher(content);
            while (vfRegexMatcher.find()) {
                // System.debug(vfRegexMatcher.group(0)); 
                vfPageSet.add(vfRegexMatcher.group(0));
            }
            while (vfWithFieldregexMatcher.find()) {
                // System.debug(vfWithFieldregexMatcher.group(0)); 
                vfPageSet.add(vfWithFieldregexMatcher.group(0));
            }
        }
        return vfPageSet;
    }

    private void processPDFContent(Id recordId, SObject currentRecord, List<PDF_Content__c> pdfMasterList, Map<String, String> vfContentMap, Set<String> contentFieldAPISet, String targetLookupField) {
        Id recordTypeContentId = RecordTypeUtility.getRecordTypeId(OBJECTNAME, RECORDTYPE_CONTENT);

        List<PDF_Content__c> newPDFContentList = new List<PDF_Content__c>();
        PDF_Content__c newPDFContent = null;
        Integer runningSequence = 1;
        for(PDF_Content__c pdfContent : pdfMasterList) {

            // * Override active status of PDF Content
            Boolean isActive = true;
            try {
                // System.debug('pdfContent.tms_ExpressionCriteria__c : ' + pdfContent.tms_ExpressionCriteria__c);
                if(!String.isBlank(pdfContent.Expression_Criteria__c)) {
                    System.debug(pdfContent.Expression_Criteria__c);
                    // System.debug('currentRecord : ' + currentRecord);
                    // ******* RT_Expression??
                    RT_Expression expression = RTExpression.parseRTExpress(pdfContent.Expression_Criteria__c, currentRecord);
                    isActive = expression.evalBool();
                    System.Debug('Expression: ' + expression);
                    System.debug('isActive : ' + isActive);
                    if(!isActive) { continue; }
                }
            } catch(Exception e) {
                System.debug('Error : ' + e.getMessage() + ' with display condition \'' + pdfContent.Expression_Criteria__c + '\'');
            }

            // * Update Content by field with tag {FIELD:}
            pdfContent.Content__c = this.processContentFieldAPIByTag(currentRecord, FIELDTAG, pdfContent.Content__c, contentFieldAPISet);
            
            // * Replace PDF Content value by Visualforce template
            for(String key : vfContentMap.keySet()) {
                // System.debug(key);
                // System.debug(vfContentMap.get(key));
                pdfContent.Content__c = pdfContent.Content__c?.replace(key, vfContentMap.get(key));
                System.debug(pdfContent.Content__c);
            }

            // * Update Content in Loop
            // System.debug('pdfContent.tms_Content__c : ' + pdfContent.tms_Content__c);
            pdfContent.Content__c = this.processLoopContent(recordId, pdfContent.Content__c);

            // * Update image to content
            pdfContent.Content__c = this.processImageContent(pdfContent.Content__c);

            String displayContent = pdfContent.Content__c;
            if(pdfContent.Is_Show_Sequence__c) {
                if(pdfContent.Continue_From_Above__c) {
                    if(runningSequence > 1) runningSequence = runningSequence - 1;
                }
                displayContent = pdfContent.Content__c.replace(SEQTAG, String.valueOf(runningSequence));
                runningSequence = runningSequence + 1;
                // pdfContent.tms_Content__c = this.processSequence(runningSequence, pdfContent.tms_Content__c);
            }
            
            // * Create PDF Content for each object
            newPDFContent = new PDF_Content__c(
                                Master_Content__c = pdfContent.Id,
                                Is_Show_Sequence__c = pdfContent.Is_Show_Sequence__c,
                                Sequence__c = runningSequence - 1,
                                Content__c = pdfContent.Content__c,
                                Display_Content__c = displayContent,
                                Expression_Criteria__c = pdfContent.Expression_Criteria__c,
                                Language__c = pdfContent.Language__c,
                                Is_Active__c = isActive,
                                Rental_Type__c = pdfContent.Rental_Type__c,
                                Continue_From_Above__c = pdfContent.Continue_From_Above__c,
                                RecordTypeId = recordTypeContentId
                            );
            newPDFContent.put(targetLookupField, recordId);
            newPDFContentList.add(newPDFContent);
        }
        System.debug('contentList: ' + newPDFContentList);

        insert newPDFContentList;
    }

    private String processContentFieldAPIByTag(SObject currentRecord, String tag, String content, Set<String> contentFieldAPISet) {

        if(String.isBlank(content)) { return content; }
        for(String contentFieldAPI : contentFieldAPISet) {
            System.debug(contentFieldAPI);
            try {
                SObject loopObject = currentRecord;
                String replaceValue = '';
                String eachField = contentFieldAPI.substringBetween(tag.toLowerCase(), TAG_END.toLowerCase());
                String[] lookupFields = eachField.split(RELATIONSPLITTER);
                replaceValue = Utility.getLookupValue(loopObject, eachField);
                if(replaceValue == null) { replaceValue = ''; }
                content = content.replace(contentFieldAPI, replaceValue);
            } catch(Exception e) {
                System.debug('Error field : ' + contentFieldAPI + ', ' + e.getMessage());
            }
        }
        System.debug(content);
        return content;
    }

    private String processLoopContent(Id recordId, String content) {
        List<String> loopList = this.getListByRegEx(content, REGEX_LOOPRELATEDOBJFORMAT);
        if(loopList == null || loopList.size() == 0) { return content; }
        Map<String, List<SObject>> loopRecords = this.getLoopRecords(recordId, loopList);

        for(String key : loopRecords.keySet()) {
            List<SObject> records = loopRecords.get(key);
            String template = this.getLoopTemplateContent(key);
            if(template == null) { continue; }
            List<String> sourceList = this.getListByRegEx(template, REGEX_SOURCEFORMAT);
            if(sourceList == null || sourceList.size() == 0) sourceList.add(template);
            Set<String> innerFieldAPISet = this.getSetByRegEx(new List<String>{template.stripHtmlTags()}, REGEX_INNERFIELDFORMAT);
            Set<String> stripContentFieldAPISet = new Set<String>();
            Map<String, String> sourceLowerMap = new Map<String, String>();
            for(String eachField : innerFieldAPISet) {
                String fieldLower = eachField.stripHtmlTags().toLowerCase();
                stripContentFieldAPISet.add(fieldLower);
            }
            System.debug('sourceList : ' + sourceList);
            for(String source : sourceList) {
                String stripSource = source;
                for(String eachField : innerFieldAPISet) {
                    String fieldLower = eachField.stripHtmlTags().toLowerCase();
                    stripSource = stripSource.replace(eachField, fieldLower);
                }
                sourceLowerMap.put(source, stripSource);
            }
            System.debug('records : ' + records);

            Set<String> distinctSourceSet = new Set<String>();
            List<String> replaceTemplateList = new List<String>();
            List<String> loopContentList = new List<String>();
            for(SObject currentRecord : records) {
                String newTemplate = template;
                System.debug('newTemplate :' + newTemplate);
                Map<String, String> sourceMap = new Map<String, String>();
                String replaceSource = '';
                // System.debug('sourceLowerMap :' + sourceLowerMap);
                for(String sourceKey : sourceLowerMap.keySet()) {
                    String stripSource = sourceLowerMap.get(sourceKey);
                    // System.debug('stripSource : ' + stripSource);
                    replaceSource = this.processContentFieldAPIByTag(currentRecord, XFIELDTAG, stripSource.stripHtmlTags(), stripContentFieldAPISet);
                    // System.debug('replaceSource : ' + replaceSource);
                    if(distinctSourceSet.contains(replaceSource)) {
                        newTemplate = newTemplate.replace(sourceKey, '');
                    } else {
                        distinctSourceSet.add(replaceSource);
                        newTemplate = newTemplate.replace(sourceKey, replaceSource);
                    }
                }
                replaceTemplateList.add(newTemplate);
            }

            // System.debug(content);
            // System.debug(key);
            // System.debug(replaceTemplateList);
            String eachLoopReplacedTemplate = String.join(replaceTemplateList, '\n');
            content = content.replace(key, eachLoopReplacedTemplate);
        }

        return content;
    }

    private List<String> getListByRegEx(String content, String regexFormat) {
        Pattern regexPattern = Pattern.compile(regexFormat);
        List<String> matchedList = new List<String>();
        if(!String.isBlank(content)) {
            Matcher regexMatcher = regexPattern.matcher(content);
            while (regexMatcher.find()) {
                matchedList.add(regexMatcher.group(0));
            }
        }
        return matchedList;
    }
    private Map<String, List<SObject>> getLoopRecords(Id recordId, List<String> loopList) {
        Map<String, List<SObject>> loopRecordMap = new Map<String, List<SObject>>();
        for(String loopString : loopList) {
            Map<String, String> attributeMap = this.getLoopAttribute(loopString);
            Set<String> queryFieldSet = new Set<String>(attributeMap.get(FIELDSKEY).split(FIELDSPLITTER));
            // System.debug(attributeMap.get(CONDITIONKEY));
            // System.debug('queryFieldSet : ' + queryFieldSet);
            String condition = attributeMap.get(LOOKUPFIELDKEY) + ' = \'' + recordId + '\'';
            if(!String.isEmpty(attributeMap.get(CONDITIONKEY))) {
                condition = condition + ' AND ' + attributeMap.get(CONDITIONKEY);
            }
            List<SObject> records = PDFContentSelector.getRecordValue(queryFieldSet, attributeMap.get(LOOPRELATEDOBJKEY), condition);
            loopRecordMap.put(loopString, records);
        }
        return loopRecordMap;
    }
    private Map<String, String> getLoopAttribute(String loopString) {
        Map<String, String> attributeMap = new Map<String, String>();
        Pattern regexPattern = Pattern.compile(REGEX_LOOPFORMAT);
        Boolean isFoundLoop = false;
        String startLoopTagValue = '';
        Matcher regexMatcher = regexPattern.matcher(loopString);
        while (regexMatcher.find()) {
            startLoopTagValue = regexMatcher.group(0);
            startLoopTagValue = startLoopTagValue.stripHtmlTags();
            startLoopTagValue = startLoopTagValue.substringBetween(TAG_START, TAG_END);
        }

        List<String> attributes = startLoopTagValue.split(ATTRIBUTESPLITTER);
        for(String attribute : attributes) {
            List<String> values = attribute.split(VALUESPLITTER);
            attributeMap.put(values[0].trim(), values[1].trim());
        }
        return attributeMap;
    }

    private String processImageContent(String content) {
        List<String> sourceFileList = this.getListByRegEx(content, REGEX_SOURCEFORMAT);
        System.debug(sourceFileList);

        if(sourceFileList == null || sourceFileList.size() == 0) { return content; }
        List<String> sourceFileNameList = new List<String>();
        for(String sourceFile : sourceFileList) {
            sourceFileNameList.add('\'' + sourceFile.substringBetween('SOURCE:', BRACKET_END) + '\'');
        }
        String condition = 'PathOnClient IN (' + String.join(sourceFileNameList, FIELDSPLITTER) + ')';

        Set<String> fileNameSet = new Set<String>();
        for(String sourceFile : sourceFileList) {
            String filename = sourceFile.substringBetween('SOURCE:', BRACKET_END);
            fileNameSet.add(fileName);
        }
        // List<ContentVersion> floorImageList = tms_PDFContentSelector.getContentVersionByObject('tms_BuildingFloor__c', fileNameSet);
        // **** Change the parameter '??'
        List<ContentVersion> roImageList = PDFContentSelector.getContentVersionByObject('Units__c', fileNameSet);

        Map<String, String> sourceFileMap = new Map<String, String>();
        for(String sourceFile : sourceFileList) {
            String filename = sourceFile.substringBetween('SOURCE:', BRACKET_END);
            sourceFileMap.put(sourceFile, '');

            if(roImageList == null || roImageList.size() == 0) continue;
            for(ContentVersion roImage : roImageList) {
                String roFileName = roImage.get('Title') + '.' + roImage.get('FileExtension');
                // System.debug(roFileName);
                if(roFileName == filename) {
                    List<Object> parameters = new List<Object> { URL.getSalesforceBaseUrl().toExternalForm(), String.valueOf(roImage.get('Id')).left(15), String.valueOf(roImage.get('ContentBodyId')).left(15) };
                    String formattedText = String.format(IMAGEURL, parameters);
                    // System.debug(formattedText);
                    sourceFileMap.put(sourceFile, formattedText);
                    break;
                }
            }
        }

        for(String key : sourceFileMap.keySet()) {
            content = content.replace(key, sourceFileMap.get(key));
        }
        return content;
    }

    private String getLoopTemplateContent(String content) {
        String template = content;
        Pattern regexPattern = Pattern.compile(REGEX_LOOPFORMAT);
        Boolean isFoundLoop = false;
        String startLoopTagValue = '';
        if(!String.isBlank(content)) {
            // content = content.stripHTMLTags();
            Matcher regexMatcher = regexPattern.matcher(content);
            while (regexMatcher.find()) {
                startLoopTagValue = regexMatcher.group(0);
            }
            // System.debug('getLoopTemplateContent content : ' + content);
            // System.debug('startLoopTagValue : ' + startLoopTagValue);
            template = content.substringBetween(startLoopTagValue, ENDLOOPRELATEDOBJTAG);
        }
        // System.debug('getLoopTemplateContent template : ' + template);
        return template;
    }

    public void removeRecordByCondition(String condition) {
        List<PDF_Content__c> pdfContentList = PDFContentSelector.getPDFContentIdByCondition(condition);
        if(pdfContentList != null && pdfContentList.size() > 0) {
            Database.delete(pdfContentList, false);
        }
    }
}