trigger RawMaterialTrigger on RawMaterial__c (before insert) {

	List<RawMaterial__c> materials = trigger.new;
	List<TriggerHelper.ProductWrapper> wrappers = new List<TriggerHelper.ProductWrapper>();

	for (RawMaterial__c material :materials) {
		TriggerHelper.ProductWrapper currentMaterial = new TriggerHelper.ProductWrapper();
		currentMaterial.id = material.id;
		currentMaterial.creationDate = material.Date__c;
		wrappers.add(currentMaterial);
	}

	wrappers = TriggerHelper.storeDistributor(wrappers);

	for (TriggerHelper.ProductWrapper material :wrappers) {
		for (RawMaterial__c item :trigger.new) {
			if (item.id == material.id) {
				item.Store__c = material.storeId;
			}
		}
	}
}