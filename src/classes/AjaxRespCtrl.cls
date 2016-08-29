public with sharing class AjaxRespCtrl {
	
	public String jsonString { get;set; }

	public void retrieveData() {
		Map<String, String> params = ApexPages.currentPage().getParameters();

		for (String key :params.keySet()) {
			system.debug('Key: ' + key + ', Value: ' + params.get(key));
		}
		Id recId = [SELECT Id FROM RecordType WHERE Name = 'Made' LIMIT 1].Id;
		List<Product__c> lstAaData = [SELECT 	Id,
												Name__c,
												Cost__c,
												Title__c FROM Product__c WHERE RecordTypeId = :recId LIMIT 10000];
		JSONGenerator gen = JSON.createGenerator(true);

		gen.writeStartObject();
		gen.writeNumberField('sEcho', Integer.valueOf(params.get('sEcho')));
		gen.writeNumberField('iTotalRecords', 10);
		gen.writeNumberField('iTotalDisplayRecords', 10);
		gen.writeFieldName('aaData');
		gen.writeStartArray();

		for (Product__c prod :lstAaData) {
			gen.writeStartArray();
			gen.writeString(prod.Name__c);
			gen.writeNumber(prod.Cost__c);
			gen.writeString(prod.Title__c);
			gen.writeEndArray();
		}

		gen.writeEndArray();
		gen.writeEndObject();
		jsonString = gen.getAsString();
	}
}