public with sharing class NewOrderCtrl {

	public Id recordId;
	public Contacts__c newContact { get;set; }//Get entered contact data
	public Product__c selectedProduct { get;set; }//Select the product by Id
	public List<Discount__c> discountAmount { get;set; }//Select all the promo codes
	public String currentPromo { get;set; }//Get entered promo code


	public NewOrderCtrl() {
		this.recordId = ApexPages.currentPage().getParameters().get(ShopCtrl.PARAMETER_ID);
		if (recordId != null) {
			this.selectedProduct = [SELECT Id, Name__c, Cost__c, ImageURL__c, Description__c, Amount__c, Store__c, Date__c
															FROM Product__c WHERE Id = :this.recordId LIMIT 1];
			this.discountAmount = [SELECT Id, PromoCode__c, StaticDiscount__c, PercentsOfDiscount__c, Status__c, StartDate__c, EndDate__c
												FROM Discount__c LIMIT 10000];
		}
		this.newContact = new Contacts__c();
	}

	//Create a copy of the product with Sold ProductType
	public Id copyProduct(Product__c soldProduct, Contacts__c currentContact) {
		Product__c copiedProduct = new Product__c();
		copiedProduct.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sold' LIMIT 1].Id;
		copiedProduct.Name = soldProduct.Name__c + ' - ' + currentContact.Name + ' ' + Date.today().format();
		copiedProduct.Name__c = soldProduct.Name__c;
		copiedProduct.Cost__c = soldProduct.Cost__c;
		copiedProduct.ImageURL__c = soldProduct.ImageURL__c;
		copiedProduct.Description__c = soldProduct.Description__c;
		copiedProduct.Date__c = Date.today();
		copiedProduct.Amount__c = 1;
		copiedProduct.Store__c = soldProduct.Store__c;
		TriggerHelper.serviceContext = true; //disable ProductTrigger
		insert copiedProduct;
		TriggerHelper.serviceContext = false; //enable ProductTrigger
		return copiedProduct.Id;
	}

	//Verifie the promo code and check available discounts
	public Discount__c promoCheck () {
		Discount__c result = null;
		Boolean promoFound = false;
		//Search for the discount
		for (Discount__c item :discountAmount) {
			//If the entered promo code exists, check its status
			if (item.PromoCode__c == currentPromo) {
				//Promo code is found
				promoFound = true;
				//If the promo code is active, return discount value
				if (item.Status__c == 'Active') {
					result = item;
				}
				else {
					//If the status is Not Started, display an error
					if (item.Status__c == 'Not Started') {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
								Label.DiscountStart + ' ' + item.StartDate__c.format()));
					}
					//If the status is Expired, display an error
					else {
						ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 
								Label.DiscountExpire + ' ' + item.EndDate__c.format()));
					}
				}
				break;
			}
		}
		//If there's no such promo code, display an error
		if (promoFound == false) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.NoPromo));
			result = null;
		}
		return result;
	}

	public PageReference save() {
		PageReference result;
		//Try to find the entered email
		List<Contacts__c> emailCheck = [SELECT Id, Name, Email__c FROM Contacts__c WHERE 
														Email__c = :newContact.Email__c LIMIT 1];
		//If amount of products left is less than 0, display an error
		if (selectedProduct.Amount__c < = 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.OutOfStock));
			result = null;
		}
		//If the product is available, checking for the discount
		else {
			Discount__c discountFound = promoCheck();
			//If promoCheck didn't find a discount, returns null
			if (discountFound == null && currentPromo != '') {
				result = null;
			}
			//If there's a discount
			else {
				//If emailCheck didn't find the email, create new contact
				if (emailCheck.isEmpty()) {
					insert this.newContact;
				}
				//And if there is one, we update it
				else {
					newContact.Id = emailCheck[0].Id;
					update newContact;
				}
				//Reduce the amount of products avaliable by 1
				selectedProduct.Amount__c = selectedProduct.Amount__c -1;
				update selectedProduct;
				//If there was a discount, apply it
				if (discountFound != null) {
					selectedProduct.Cost__c = selectedProduct.Cost__c - discountFound.StaticDiscount__c;
					selectedProduct.Cost__c = 
						selectedProduct.Cost__c - selectedProduct.Cost__c * (discountFound.PercentsOfDiscount__c / 100);
				}
				Id productId = copyProduct(selectedProduct, newContact);
				//Go to the purchase notify page
				result = Page.PurchaseNotify;
				result.getParameters().put(ShopCtrl.PARAMETER_ID, productId);
				result.getParameters().put('contactId', this.newContact.Id);
				//Pass the Id of discount, if there was one
				if (discountFound != null) {
					result.getParameters().put('discountId', discountFound.Id);
				}
				result.getParameters().put('productId', this.selectedProduct.Id);
				try {
					//Select the email template
					EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'PurchaseNotifier' LIMIT 1];
					Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
					String htmlBody = template.HtmlValue;
					//Replace parts of the template with data
					htmlBody = htmlBody.replace('newContact.Email__c', newContact.Email__c);
					htmlBody = htmlBody.replace('newContact.Phone__c', newContact.Phone__c);
					htmlBody = htmlBody.replace('newContact.Address__c', newContact.Address__c);
					htmlBody = htmlBody.replace('selectedProduct.Name__c', selectedProduct.Name__c);
					List<String> toAddresses = new List<String> {newContact.Email__c};
	                message.setToAddresses(toAddresses);
	                message.setSubject(Label.OrderEmailSubj);
	                message.setHtmlBody(htmlBody);
	                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
				}
				catch (Exception e) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				}
			}
		}
		return result;
	}

	//Return to the Shop page
	public PageReference back() {
		return Page.Shop;
	}
}