public with sharing class PDFMakeUtility {
    public static PDFMakeUtility instance;
	public static PDFMakeUtility getInstance() {
		if (instance == null) {
			instance = new PDFMakeUtility();
		}
		return instance;
	}
    public PDFMakeUtility() {

    }
    public static String replaceTablesWithoutBorder(String content) {
        if (content == null) {
            return null; // Handle null content safely
        }
        
        // Replace <table> tags without 'border' attribute
        content = content.replaceAll(
            '<table(?![^>]*border)([^>]*)>', // Matches <table> tags without 'border' attribute
            '<table data-pdfmake="{&quot;layout&quot;:&quot;noBorders&quot;}" style="width: 700px;">'
        );
        
        return content;
    }
}