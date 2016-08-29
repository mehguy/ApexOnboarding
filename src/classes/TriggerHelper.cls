public with sharing class TriggerHelper {

	public static Boolean serviceContext = false;
	
	public class ProductWrapper {
		public Date creationDate;
		public Id id;
		public String type;
		public Id storeId;
	}

	//Set a store to the product we created
	public static List<ProductWrapper> storeDistributor (List<ProductWrapper> items) {
		//Select all the stores out there
		List<Store__c> stores = [SELECT StartPeriod__c, EndPeriod__c FROM Store__c LIMIT 10000];
		List<Store__c> newStores = new List<Store__c>();
		//Search for the stores in products/raw materials
		for (ProductWrapper item :items) {
			//Search for the store with correct dates
			for (Store__c store :stores) {
				if (item.creationDate >= store.StartPeriod__c && item.creationDate <= store.EndPeriod__c) {
					item.storeId = store.Id;
					break;
				}
			}
			//If no store found, create it
			if (item.storeId == null) {
				Store__c newStore = new Store__c();
				newStore.Name = 'Store '+item.creationDate.format();
				newStore.StartPeriod__c = item.creationDate;
				newStore.EndPeriod__c = item.creationDate;
				newStores.add(newStore);
			}
		}
		insert newStores;
		//Set the store to the product/raw material
		for (ProductWrapper item :items) {
			if (item.storeId == null){
			for (Store__c store :newStores) {
				if (item.creationDate >= store.StartPeriod__c && item.creationDate <= store.EndPeriod__c){
					item.storeId = store.Id;
					break;
					}
				}
			}
		}
		return items;
	}
}