public with sharing class PurchaseNotifyCtrl {

	public Id productId;
	public Id contactId;
	public Id discountId;
	public Id defProductId;
	//Get the data of the product the customer is buying
	public Product__c orderedProduct { get {
			return [SELECT Id, Name__c, Cost__c, Description__c, ImageURL__c FROM Product__c
					WHERE Id = :productId LIMIT 1];
		}
		set; }
	//Get the customer's data
	public Contacts__c customerContact { get {
			return [SELECT Id, Name, Email__c, Phone__c, Address__c FROM Contacts__c WHERE Id = :contactId LIMIT 1];
		}
		set; }
	//Get the discount data
	public Discount__c promoData { get {
			//If there was discount, select it
			if (discountId != null) {
				return [SELECT Id, PromoCode__c, PercentsOfDiscount__c, StaticDiscount__c FROM Discount__c 
					WHERE Id = :discountId LIMIT 1];
			}
			else {
				return null;
			}
		}
		set; }
	//Select the product to get undiscounted cost
	public Product__c defaultProduct { get {
			return [SELECT Id, Cost__c FROM Product__c WHERE Id = :defProductId LIMIT 1];
		}
		set; }

	public PurchaseNotifyCtrl() {
		this.productId = ApexPages.currentPage().getParameters().get(ShopCtrl.PARAMETER_ID);
		this.contactId = ApexPages.currentPage().getParameters().get('contactId');
		this.defProductId = ApexPages.currentPage().getParameters().get('productId');
		this.discountId = ApexPages.currentPage().getParameters().get('discountId');
	}

	//Return to the shop page
	public PageReference back() {
		return Page.Shop;
	}
}