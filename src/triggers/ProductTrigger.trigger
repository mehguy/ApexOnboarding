trigger ProductTrigger on Product__c (before insert) {

	if (TriggerHelper.serviceContext == false) {

		List<Product__c> products = trigger.new;
		List<TriggerHelper.ProductWrapper> wrappers = new List<TriggerHelper.ProductWrapper>();

		for (Product__c product :products) {
			TriggerHelper.ProductWrapper currentProduct = new TriggerHelper.ProductWrapper();
			currentProduct.id = product.id;
			currentProduct.creationDate = product.Date__c;
			wrappers.add(currentProduct);
		}

		wrappers = TriggerHelper.storeDistributor(wrappers);

		for (TriggerHelper.ProductWrapper product :wrappers) {
			for (Product__c item :trigger.new) {
				if (item.id == product.id) {
					item.Store__c = product.storeId;
				}
			}
		}
	}
}