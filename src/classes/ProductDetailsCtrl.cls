public with sharing class ProductDetailsCtrl {

	public Id recordId;
	public Product__c selectedProduct { get;set; }//Get the product we are watching

	public ProductDetailsCtrl() {
		this.recordId = ApexPages.currentPage().getParameters().get(ShopCtrl.PARAMETER_ID);
		this.selectedProduct = [SELECT Id, Name__c, Cost__c, Description__c, Title__c, ImageURL__c, Amount__c
						FROM Product__c WHERE Id = :this.recordId LIMIT 1];
	}

	//Return back to the shop
	public PageReference back() {
		return Page.Shop;
	}
}