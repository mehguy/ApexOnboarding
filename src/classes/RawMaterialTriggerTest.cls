@isTest
public with sharing class RawMaterialTriggerTest {

	static testMethod void RawMaterialsTest() {

		Store__c testStore = new Store__c(StartPeriod__c = Date.today(), EndPeriod__c = Date.today());
		insert testStore;

		Test.startTest();
		RawMaterial__c testRawMaterial = new RawMaterial__c(Name = 'test', Date__c = Date.today());
		insert testRawMaterial;
		RawMaterial__c testRawMaterial1 = new RawMaterial__c(Name = 'test1', Date__c = Date.today().addDays(100));
		insert testRawMaterial1;		
		Test.stopTest();
		System.assert([SELECT Store__c FROM RawMaterial__c WHERE Id = :testRawMaterial.Id][0].Store__c != null);
		System.assert([SELECT Store__c FROM RawMaterial__c WHERE Id = :testRawMaterial1.Id][0].Store__c != null);
	}
}