@isTest
public with sharing class ProductTriggerTest {

	static testMethod void ProductsTest() {

		Store__c testStore = new Store__c(StartPeriod__c = Date.today(), EndPeriod__c = Date.today());
		insert testStore;

		Test.startTest();
		Product__c testProduct = new Product__c(Name = 'test', Date__c = Date.today());
		insert testProduct;
		Product__c testProduct1 = new Product__c(Name = 'test1', Date__c = Date.today().addDays(100));
		insert testProduct1;		
		Test.stopTest();
		System.assert([SELECT Store__c FROM Product__c WHERE Id = :testProduct.Id][0].Store__c != null);
		System.assert([SELECT Store__c FROM Product__c WHERE Id = :testProduct1.Id][0].Store__c != null);
	}
}