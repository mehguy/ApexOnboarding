public with sharing class ContactsExtension {

    transient public String currentAddress { get;set; }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ContactsExtension(ApexPages.StandardController stdController) {
        Contacts__c currentRecord = (Contacts__c)stdController.getRecord();
        this.currentAddress = [SELECT Address__c FROM Contacts__c WHERE Id = :currentRecord.Id LIMIT 1].Address__c;
    }

    /*public String getRecordName() {
        return 'Hello ' + (String)getContact.get('Name') + ' (' + (Id)getContact.get('Id') + ')';
    }*/
}