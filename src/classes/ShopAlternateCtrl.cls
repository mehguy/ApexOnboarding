public with sharing class ShopAlternateCtrl {

	public class NewContactWrapper {
		public String orderEmail;
		public String orderName;
		public String orderPhone;
		public String orderAddress;
		public String productName;
	}

	@RemoteAction
	public static List<Product__c> getProductList() {
		Id recId = [SELECT Id FROM RecordType WHERE Name = 'Made' LIMIT 1].Id;
		List<Product__c> result = [SELECT 	Id,
											Name__c,
											Cost__c,
											Title__c, 
											ImageURL__c,
											Amount__c FROM Product__c WHERE RecordTypeId = :recId LIMIT 10000];
		return result;
	}

	@RemoteAction
	public static Product__c getNewOrder(Id recId, Boolean serviceContext) {
		Product__c result = [SELECT Id,
									Name__c,
									Cost__c,
									Title__c,
									Amount__c,
									Description__c,
									ImageURL__c FROM Product__c WHERE Id = :recId LIMIT 1];

		if (serviceContext == true) {
			if (result.Amount__c == 0) {
				result = null;
			}
		}
		return result;
	}

	@RemoteAction
	public static void setNewContact(NewContactWrapper orderContact, String currentRecId) {
		Contacts__c newContact = new Contacts__c();
		newContact.Email__c = orderContact.orderEmail;
		newContact.Name = orderContact.orderName;
		newContact.Phone__c = orderContact.orderPhone;
		newContact.Address__c = orderContact.orderAddress;
		List<Contacts__c> emailCheck = [SELECT 	Id,
												Name,
												Email__c,
												Address__c FROM Contacts__c WHERE Email__c = :orderContact.orderEmail LIMIT 1];

		if (emailCheck.isEmpty()) {
			insert newContact;
		}
		else {
			newContact.Id = emailCheck[0].Id;
			update newContact;
		}
		sendEmail(orderContact);
		reduceProductAmount(currentRecId);
		copyProduct(currentRecId, orderContact.orderName);
	}

	public static void sendEmail(NewContactWrapper orderContact) {
		List<EmailTemplate> template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'PurchaseNotifier' LIMIT 1];
		if (template.isEmpty() == false) {
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			String htmlBody = template[0].HtmlValue;
			htmlBody = htmlBody.replace('newContact.Email__c', orderContact.orderEmail);
			htmlBody = htmlBody.replace('newContact.Phone__c', orderContact.orderPhone);
			htmlBody = htmlBody.replace('newContact.Address__c', orderContact.orderAddress);
			htmlBody = htmlBody.replace('selectedProduct.Name__c', orderContact.productName);
			List<String> toAddresses = new List<String> {orderContact.orderEmail};
		    message.setToAddresses(toAddresses);
		    message.setSubject(Label.OrderEmailSubj);
		    message.setHtmlBody(htmlBody);
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
	}

	public static void reduceProductAmount(Id recId) {
		Product__c products = [SELECT 	Id,
										Name__c,
										Amount__c FROM Product__c WHERE Id = :recId LIMIT 1];
		if (products.Amount__c != 0) {
			products.Amount__c = products.Amount__c - 1;
			update products;
		}									
	}

	public static void copyProduct(Id recId, String orderName) {
		Product__c copiedProduct = new Product__c();		
		Product__c product = [SELECT 	Id,
										Name__c,
										Cost__c,
										ImageURL__c,
										Title__c,
										Store__c,
										Date__c FROM Product__c WHERE Id = :recId LIMIT 1];
		copiedProduct.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sold' LIMIT 1].Id;
		copiedProduct.Name = product.Name__c + ' ' + orderName + ' ' + Date.today().format();
		copiedProduct.Name__c = product.Name__c;
		copiedProduct.Cost__c = product.Cost__c;
		copiedProduct.ImageURL__c = product.ImageURL__c;
		copiedProduct.Title__c = product.Title__c;
		copiedProduct.Store__c = product.Store__c;
		copiedProduct.Date__c = product.Date__c;
		TriggerHelper.serviceContext = true;
		insert copiedProduct;
		TriggerHelper.serviceContext = false;
	}
}