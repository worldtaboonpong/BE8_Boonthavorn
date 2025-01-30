public without sharing class SObjectUtility {
	public static Map<String, String> sObjectTypeMapByPrefixID = new Map<String, String>();
	static {
		Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
		for(String s:describe.keyset())
			sObjectTypeMapByPrefixID.put(describe.get(s).getDescribe().getKeyPrefix(),s);
	}

	public static String getSObjectTypeByID(ID recordID) {
		return sObjectTypeMapByPrefixID.get(String.valueOf(recordID).substring(0,3));
	}
	
	public class SObjectUtilException extends Exception {}
}