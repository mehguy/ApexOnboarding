global class ContactsBatch implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id, Name, Name__c, Description__c FROM Contacts__c';
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Contacts__c> scope) {
		for (Contacts__c item :scope) {
			if (item.Description__c == '' || item.Description__c == null) {
				item.Description__c = Date.today().format();
			}
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}